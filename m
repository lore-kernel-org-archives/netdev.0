From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: addrconf: Fix recursive spin lock call
Date: Mon, 01 Feb 2016 11:37:34 -0800
Message-ID: <1454355454.7627.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2cf017eba84341c95d22fda2952a3f6f.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: subashab@codeaurora.org, Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36016 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbcBAThg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 14:37:36 -0500
Received: by mail-pf0-f177.google.com with SMTP id n128so88192589pfn.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 11:37:36 -0800 (PST)
In-Reply-To: <2cf017eba84341c95d22fda2952a3f6f.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-02-01 at 19:13 +0000, subashab@codeaurora.org wrote:
> A rcu stall with the following backtrace was seen on a system with
> forwarding, optimistic_dad and use_optimistic set. To reproduce,
> set these flags and then start ipv6 autoconf.
> 
> This occurs because the device write_lock is acquired while already
> holding the read_lock. Back trace below -
> 
> INFO: rcu_preempt self-detected stall on CPU { 1}  (t=2100 jiffies
>  g=3992 c=3991 q=4471)
> <6> Task dump for CPU 1:
> <2> kworker/1:0     R  running task    12168    15      2 0x00000002
> <2> Workqueue: ipv6_addrconf addrconf_dad_work
> <6> Call trace:
> <2> [<ffffffc000084da8>] el1_irq+0x68/0xdc
> <2> [<ffffffc000cc4e0c>] _raw_write_lock_bh+0x20/0x30
> <2> [<ffffffc000bc5dd8>] __ipv6_dev_ac_inc+0x64/0x1b4
> <2> [<ffffffc000bcbd2c>] addrconf_join_anycast+0x9c/0xc4
> <2> [<ffffffc000bcf9f0>] __ipv6_ifa_notify+0x160/0x29c
> <2> [<ffffffc000bcfb7c>] ipv6_ifa_notify+0x50/0x70
> <2> [<ffffffc000bd035c>] addrconf_dad_work+0x314/0x334
> <2> [<ffffffc0000b64c8>] process_one_work+0x244/0x3fc
> <2> [<ffffffc0000b7324>] worker_thread+0x2f8/0x418
> <2> [<ffffffc0000bb40c>] kthread+0xe0/0xec
> 
> Change-Id: I270c05598622d400b178d758fdbd8296cf521ee8
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/ipv6/addrconf.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2163871..ae8ac1a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3301,7 +3301,9 @@ static void addrconf_dad_begin(struct inet6_ifaddr
> *ifp)
>  			/* Because optimistic nodes can use this address,
>  			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
>  			 */
> +			read_unlock_bh(&idev->lock);
>  			ipv6_ifa_notify(RTM_NEWADDR, ifp);
> +			read_lock_bh(&idev->lock);
>  		}
>  	}
> 

Hi

1) Thanks for looking at this problem ;)

2) Your patch was mangled.

3) Seems to lack 'Fixes: 7fd2561e4ebdd ("net: ipv6: Add a sysctl to make
optimistic addresses useful candidates") tag

4) You should CC patch author, Erik Kline (I did that)

5) releasing the lock as you did is probably racy.

I would rather try :

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 38eeddedfc21..d6b7ab07f914 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3538,6 +3538,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
+	bool notify = false;
 
 	addrconf_join_solict(dev, &ifp->addr);
 
@@ -3583,7 +3584,8 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 			/* Because optimistic nodes can use this address,
 			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
 			 */
-			ipv6_ifa_notify(RTM_NEWADDR, ifp);
+			notify = true;
+			in6_ifa_hold(ifp);
 		}
 	}
 
@@ -3591,6 +3593,10 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 out:
 	spin_unlock(&ifp->lock);
 	read_unlock_bh(&idev->lock);
+	if (notify) {
+		ipv6_ifa_notify(RTM_NEWADDR, ifp);
+		in6_ifa_put(ifp);
+	}
 }
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp)
