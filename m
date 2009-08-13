From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [PATCH] ipv6: Log the explicit address that triggered DAD
 failure
Date: Thu, 13 Aug 2009 10:16:04 +0200
Message-ID: <1250151364.6641.75.camel@fnki-nb00130>
References: <1250089107.6641.36.camel@fnki-nb00130>
	 <4A836D70.1040702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:34650 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbZHMIQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 04:16:12 -0400
In-Reply-To: <4A836D70.1040702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-12 at 21:33 -0400, Brian Haley wrote:
[...]
> The other thing I've come across that is similar to this is the
> issue that when DAD fails, /sbin/ip doesn't show that it did,
> the address just stays in a tentative state forever:
> 
>     inet6 dead:beef::1/64 scope global tentative 
>        valid_lft forever preferred_lft forever
> 
> Does anyone have an issue of adding a "dadfailed" flag to make
> this more obvious:
> 
>     inet6 dead:beef::1/64 scope global tentative dadfailed
>        valid_lft forever preferred_lft forever

It looks like you would have to spend the last available bit in
ifa_flags for that, not sure if that is worth it, how about setting it
to tentative|deprecated instead?

Some action should maybe also happen in the case that the address wasn't
tentative anymore in ndisc_recv_na(). At least it should also log the
address itself:

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9eb68e9..1ba42bd 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -955,8 +955,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		 */
 		if (skb->pkt_type != PACKET_LOOPBACK)
 			ND_PRINTK1(KERN_WARNING
-			   "ICMPv6 NA: someone advertises our address on %s!\n",
-			   ifp->idev->dev->name);
+			   "ICMPv6 NA: someone advertises our address %pI6 on %s!\n",
+			   &ifp->addr, ifp->idev->dev->name);
 		in6_ifa_put(ifp);
 		return;
 	}


