From: kuznet@ms2.inr.ac.ru
Subject: Re: off by one error in 3des cbc keying
Date: Tue, 12 Nov 2002 16:55:57 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211121355.QAA00322@sex.inr.ac.ru>
References: <20021111200321.GA30957@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20021111200321.GA30957@outpost.ds9a.nl> from "bert hubert" at Nov 11, 2 09:03:21 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > It is. But your example shows that something is wrong there. Fix will follow
> > later.
> 
> Ok, let me know if I can test.

Enclosed.

Comments for Dave:

1. udp.c: silly bug, local input policy did not work on udp sockets.
2. ah.c,esp.c: even sillier bug: 0 was used as  tunnels protocol. Funny enough,
   it worked between linuxes. :-) By <gem@asplinux.ru>


Another fix for wrongly formatted ICV for ESP will follow
tonight after test for interoperability with freebsd.

The problem with expiration remains unsolved. I still cannot reproduce this
and cannot find a situation when kernel can create two larvals with one
identity. :-( Searching.

Alexey


===== net/ipv4/ah.c 1.6 vs edited =====
--- 1.6/net/ipv4/ah.c	Fri Nov  8 11:34:37 2002
+++ edited/net/ipv4/ah.c	Tue Nov 12 02:43:59 2002
@@ -189,7 +189,7 @@
 		top_iph->saddr = x->props.saddr.xfrm4_addr;
 		top_iph->daddr = x->id.daddr.xfrm4_addr;
 		ah = (struct ip_auth_hdr*)(top_iph+1);
-		ah->nexthdr = IPPROTO_IP;
+		ah->nexthdr = IPPROTO_IPIP;
 	} else {
 		memcpy(&tmp_iph, skb->data, iph->ihl*4);
 		top_iph = (struct iphdr*)skb_push(skb, x->props.header_len);
===== net/ipv4/esp.c 1.4 vs edited =====
--- 1.4/net/ipv4/esp.c	Fri Nov  8 11:34:37 2002
+++ edited/net/ipv4/esp.c	Tue Nov 12 02:43:59 2002
@@ -370,7 +370,7 @@
 	if (x->props.mode) {
 		top_iph = (struct iphdr*)skb_push(skb, x->props.header_len);
 		esph = (struct ip_esp_hdr*)(top_iph+1);
-		*(u8*)(trailer->tail - 1) = IPPROTO_IP;
+		*(u8*)(trailer->tail - 1) = IPPROTO_IPIP;
 		top_iph->ihl = 5;
 		top_iph->version = 4;
 		top_iph->tos = iph->tos;	/* DS disclosed */
===== net/ipv4/udp.c 1.27 vs edited =====
--- 1.27/net/ipv4/udp.c	Tue Nov 12 02:37:12 2002
+++ edited/net/ipv4/udp.c	Tue Nov 12 16:30:49 2002
@@ -944,7 +944,7 @@
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
 	 */
-	if (!xfrm_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb)) {
 		kfree_skb(skb);
 		return -1;
 	}
===== net/ipv4/xfrm_input.c 1.3 vs edited =====
--- 1.3/net/ipv4/xfrm_input.c	Fri Nov  8 11:34:37 2002
+++ edited/net/ipv4/xfrm_input.c	Tue Nov 12 02:43:59 2002
@@ -91,7 +91,7 @@
 		iph = skb->nh.iph;
 
 		if (x->props.mode) {
-			if (iph->protocol != IPPROTO_IP)
+			if (iph->protocol != IPPROTO_IPIP)
 				goto drop;
 			skb->nh.raw = skb->data;
 			iph = skb->nh.iph;
