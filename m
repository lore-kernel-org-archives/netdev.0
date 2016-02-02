From: subashab@codeaurora.org
Subject: [PATCH v2] ipv6: addrconf: Fix recursive spin lock call
Date: Tue, 2 Feb 2016 02:11:10 -0000
Message-ID: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Eric Dumazet" <edumazet@google.com>, "Erik Kline" <ek@google.com>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>
To: "Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43172 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcBBCLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 21:11:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A rcu stall with the following backtrace was seen on a system with
forwarding, optimistic_dad and use_optimistic set. To reproduce,
set these flags and allow ipv6 autoconf.

This occurs because the device write_lock is acquired while already
holding the read_lock. Back trace below -

INFO: rcu_preempt self-detected stall on CPU { 1}  (t=2100 jiffies
 g=3992 c=3991 q=4471)
<6> Task dump for CPU 1:
<2> kworker/1:0     R  running task    12168    15   2 0x00000002
<2> Workqueue: ipv6_addrconf addrconf_dad_work
<6> Call trace:
<2> [<ffffffc000084da8>] el1_irq+0x68/0xdc
<2> [<ffffffc000cc4e0c>] _raw_write_lock_bh+0x20/0x30
<2> [<ffffffc000bc5dd8>] __ipv6_dev_ac_inc+0x64/0x1b4
<2> [<ffffffc000bcbd2c>] addrconf_join_anycast+0x9c/0xc4
<2> [<ffffffc000bcf9f0>] __ipv6_ifa_notify+0x160/0x29c
<2> [<ffffffc000bcfb7c>] ipv6_ifa_notify+0x50/0x70
<2> [<ffffffc000bd035c>] addrconf_dad_work+0x314/0x334
<2> [<ffffffc0000b64c8>] process_one_work+0x244/0x3fc
<2> [<ffffffc0000b7324>] worker_thread+0x2f8/0x418
<2> [<ffffffc0000bb40c>] kthread+0xe0/0xec

v2: do addrconf_dad_kick inside read lock and then acquire write
lock for ipv6_ifa_notify as suggested by Eric

Fixes: 7fd2561e4ebdd ("net: ipv6: Add a sysctl to make optimistic
addresses useful candidates")

Cc: Eric Dumazet <edumazet@google.com>
Cc: Erik Kline <ek@google.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv6/addrconf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 38eedde..9efd9ff 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3538,6 +3538,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
+	bool notify = false;

 	addrconf_join_solict(dev, &ifp->addr);

@@ -3583,7 +3584,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 			/* Because optimistic nodes can use this address,
 			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
 			 */
-			ipv6_ifa_notify(RTM_NEWADDR, ifp);
+			notify = true;
 		}
 	}

@@ -3591,6 +3592,8 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 out:
 	spin_unlock(&ifp->lock);
 	read_unlock_bh(&idev->lock);
+	if (notify)
+		ipv6_ifa_notify(RTM_NEWADDR, ifp);
 }

 static void addrconf_dad_start(struct inet6_ifaddr *ifp)
-- 
