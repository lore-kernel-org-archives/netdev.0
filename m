From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 03:45:06 +0200
Message-ID: <20080731014506.GA23402@xi.wantstofly.org>
References: <20080730235004.GC21999@xi.wantstofly.org> <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org> <20080730.181047.39922732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44784 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686AbYGaBpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 21:45:09 -0400
Content-Disposition: inline
In-Reply-To: <20080730.181047.39922732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 06:10:47PM -0700, David Miller wrote:

> > The hacky patch below (on top of 2.6.27-rc1 + stubbing out the
> > sk_can_gso() check) reduces the 1 GiB 1000 Mb/s sendfile test from:
>  ...
> > I.e. dramatic CPU time improvements, and some overall speedup as well.
> > 
> > I wonder if something like this can be done in a less hacky fashion --
> > the hard part I guess is deciding when to keep coalescing (to reduce
> > CPU overhead) vs. when to push out what has been coalesced so far (in
> > order to keep the pipe filled), and I'm not sure I have good ideas
> > about how to make that decision.
> 
> Interesting, I'll take a closer look at this.
> 
> Actually your patch is less of a surprise, because one of the issues I
> had to surmount constantly when rewriting the TSO output path was the
> implicit conflict between TSO deferral (to accumulate segments) and
> the nagle logic.
> 
> Anyways, thanks, I'll think about this patch and your data and see
> where we can go with that part.
> 
> In the mean time could you possibly cook up a cleaned up "use software
> GSO for SG+CSUM capable devices" patch?  I think I want to apply it,
> especially since all of the things Herbert and I have suspected is
> completely confirmed by your data and tests.

OK, how about:



From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [NET] use software GSO for SG+CSUM capable netdevices

If a netdevice does not support hardware GSO, allowing the stack to
use GSO anyway and then splitting the GSO skb into MSS-sized pieces
as it is handed to the netdevice for transmitting is likely still
a win at least as far as CPU usage is concerned, since it reduces
the number of trips through the output path.

This patch enables the use of GSO on any netdevice that supports SG
and hardware checksumming.  If a GSO skb is then sent to a netdevice
that supports SG and checksumming but does not support hardware GSO,
net/core/dev.c:dev_hard_start_xmit() will take care of doing the
necessary GSO segmentation in software.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.27-rc1/include/net/sock.h
===================================================================
--- linux-2.6.27-rc1.orig/include/net/sock.h
+++ linux-2.6.27-rc1/include/net/sock.h
@@ -1085,7 +1085,13 @@ extern struct dst_entry *sk_dst_check(st
 
 static inline int sk_can_gso(const struct sock *sk)
 {
-	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
+	int caps = sk->sk_route_caps;
+	int type = sk->sk_gso_type;
+
+	return (caps & NETIF_F_SG) &&
+		 (((type == SKB_GSO_TCPV4 || type == SKB_GSO_UDP) &&
+			(caps & NETIF_F_V4_CSUM)) ||
+		  (type == SKB_GSO_TCPV6 && (caps & NETIF_F_V6_CSUM)));
 }
 
 extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
