From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Always leave subnet anycast group on link down
Date: Thu, 21 Jul 2016 14:11:11 -0600
Message-ID: <8246d7f6-49ba-408c-6a2e-f06ad8c7ae46@cumulusnetworks.com>
References: <a457dbfa-4320-a9b0-2bba-1ac488a61e50@brocade.com>
 <c805a77e-f21d-754c-79fe-12be45262888@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32964 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbcGUULN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 16:11:13 -0400
Received: by mail-pf0-f170.google.com with SMTP id y134so33520056pfg.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 13:11:13 -0700 (PDT)
In-Reply-To: <c805a77e-f21d-754c-79fe-12be45262888@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/16 7:44 AM, Mike Manning wrote:
>
> Default kernel behavior is to delete IPv6 addresses on link
> down, which entails deletion of the address-derived
> subnet-router anycast address. The latter does not happen
> with sysctl setting to keep global IPv6 addrs on link down,
> so every link down/up causes an increment of the anycast
> refcount, cf aca_users in __ipv6_dev_ac_inc(). This bogus
> refcount stops the anycast being removed on subsequent
> calls to delete the address. The solution is to leave the
> group for this subnet anycast on link down also for the
> callflow when global IPv6 addresses are kept.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/ipv6/addrconf.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 47f837a..3c69e56 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3562,6 +3562,8 @@ restart:
>  		if (state != INET6_IFADDR_STATE_DEAD) {
>  			__ipv6_ifa_notify(RTM_DELADDR, ifa);
>  			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
> +		} else if (idev->cnf.forwarding) {
> +			addrconf_leave_anycast(ifa);
>  		}
>
>  		write_lock_bh(&idev->lock);
>


mcast has the same problem, so this should be:

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 24f1b0898e40..6287a8b9f428 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3636,6 +3636,10 @@ static int addrconf_ifdown(struct net_device 
*dev, int how)
                 if (state != INET6_IFADDR_STATE_DEAD) {
                         __ipv6_ifa_notify(RTM_DELADDR, ifa);
                         inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
+               } else {
+                       if (idev->cnf.forwarding)
+                               addrconf_leave_anycast(ifa);
+                       addrconf_leave_solict(ifa->idev, &ifa->addr);
                 }

                 write_lock_bh(&idev->lock);
