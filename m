From: Andreas Jaggi <aj@open.ch>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Mon, 13 Jul 2009 18:01:42 +0200
Message-ID: <20090713160142.GA9252@urbino.open.ch>
References: <20090713133225.GA20946@urbino.open.ch> <20090713083303.61a59b63@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	kaber@trash.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:41100 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330AbZGMQBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2009 12:01:32 -0400
Content-Disposition: inline
In-Reply-To: <20090713083303.61a59b63@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2009 at 08:33:03AM -0700, Stephen Hemminger wrote:
> Why make it an option? Sounds like it should always be on.

In some scenarios people might want to set the ToS value for all
GRE tunnel packets to a fixed value (cf. ip tunnel tos option).


Signed-off-by: Andreas Jaggi <aj@open.ch>

diff -urN vanilla-linux-2.6.29.4/include/linux/if_tunnel.h dev-gre/include/linux/if_tunnel.h
--- vanilla-linux-2.6.29.4/include/linux/if_tunnel.h	2009-05-19 01:52:34.000000000 +0200
+++ dev-gre/include/linux/if_tunnel.h	2009-07-13 15:15:26.000000000 +0200
@@ -24,6 +24,7 @@
 #define GRE_REC		__constant_htons(0x0700)
 #define GRE_FLAGS	__constant_htons(0x00F8)
 #define GRE_VERSION	__constant_htons(0x0007)
+#define GRE_COPY_TOS	__constant_htons(0x0008)
 
 struct ip_tunnel_parm
 {
diff -urN vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c dev-gre/net/ipv4/ip_gre.c
--- vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c	2009-05-19 01:52:34.000000000 +0200
+++ dev-gre/net/ipv4/ip_gre.c	2009-07-13 17:56:21.000000000 +0200
@@ -677,7 +677,7 @@
 	}
 
 	tos = tiph->tos;
-	if (tos&1) {
+	if ((tunnel->parms.o_flags & GRE_COPY_TOS) || (tos & 1)) {
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
 		tos &= ~1;
@@ -804,7 +804,7 @@
 			iph->ttl = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
 	}
 
-	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
+	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags & ~GRE_FLAGS;
 	((__be16 *)(iph + 1))[1] = (dev->type == ARPHRD_ETHER) ?
 				   htons(ETH_P_TEB) : skb->protocol;
 
@@ -1080,7 +1080,7 @@
 	__be16 *p = (__be16*)(iph+1);
 
 	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
-	p[0]		= t->parms.o_flags;
+	p[0]		= t->parms.o_flags & ~GRE_FLAGS;
 	p[1]		= htons(type);
 
 	/*
@@ -1503,6 +1503,7 @@
 	t->parms.iph.ttl = p.iph.ttl;
 	t->parms.iph.tos = p.iph.tos;
 	t->parms.iph.frag_off = p.iph.frag_off;
+	t->parms.o_flags |= p.o_flags & GRE_COPY_TOS;
 
 	if (t->parms.link != p.link) {
 		t->parms.link = p.link;
