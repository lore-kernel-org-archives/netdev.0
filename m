From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Move generic encap code into xfrm4_output
Date: Sat, 10 Jul 2004 10:51:46 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710005146.GA11023@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I've finally finished merging the general encapsulation code for IPv4.
Here is the patch.

The idea is basically to make x->type->output similar in structure to
x->type->input.  That means moving the tunnel encapsulation and other
generic code out.

They have ended up in xfrm4_output.c.

The advantage of this is that we have exactly one copy of the tunnel
encapsulation code.  So if we need to change it (e.g., set the TTL
according to the route) then it's easier and less error-prone.

In fact, in doing so I've already noticed that the ECN wasn't being
copied correctly in everything except xfrm4_tunnel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW, the ECN encapsulation stuff needs to be updated wrt RFC 3168.
I'll send in a patch later.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-07-10 10:43:34 +10:00
+++ b/include/net/xfrm.h	2004-07-10 10:43:34 +10:00
@@ -818,6 +818,7 @@
 extern int xfrm_check_selectors(struct xfrm_state **x, int n, struct flowi *fl);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv(struct sk_buff *skb);
+extern int xfrm4_output(struct sk_buff **pskb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_check_size(struct sk_buff *skb);
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2004-07-10 10:43:34 +10:00
+++ b/net/ipv4/Makefile	2004-07-10 10:43:34 +10:00
@@ -23,4 +23,5 @@
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 
-obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o xfrm4_tunnel.o
+obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
+		      xfrm4_tunnel.o xfrm4_output.o
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	2004-07-10 10:43:34 +10:00
+++ b/net/ipv4/ah4.c	2004-07-10 10:43:34 +10:00
@@ -67,52 +67,24 @@
 		char 		buf[60];
 	} tmp_iph;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(pskb, 0);
-		if (err)
-			goto error_nolock;
-	}
+	top_iph = (*pskb)->nh.iph;
+	iph = &tmp_iph.iph;
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, *pskb);
-	if (err)
-		goto error;
-
-	iph = (*pskb)->nh.iph;
-	if (x->props.mode) {
-		err = xfrm4_tunnel_check_size(*pskb);
+	iph->tos = top_iph->tos;
+	iph->ttl = top_iph->ttl;
+	iph->frag_off = top_iph->frag_off;
+	iph->daddr = top_iph->daddr;
+
+	if (top_iph->ihl != 5) {
+		memcpy(iph+1, top_iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
+		err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
 		if (err)
 			goto error;
-		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
-		top_iph->ihl = 5;
-		top_iph->version = 4;
-		top_iph->tos = iph->tos;
-		if (x->props.flags & XFRM_STATE_NOECN)
-			IP_ECN_clear(top_iph);
-		top_iph->frag_off = iph->frag_off & ~htons(IP_MF|IP_OFFSET);
-		if (!(iph->frag_off&htons(IP_DF)))
-			__ip_select_ident(top_iph, dst, 0);
-		top_iph->ttl = iph->ttl;
-		top_iph->saddr = x->props.saddr.a4;
-		top_iph->daddr = x->id.daddr.a4;
-		memcpy(&tmp_iph, top_iph, 20);
-		memset(&(IPCB(*pskb)->opt), 0, sizeof(struct ip_options));
-		ah = (struct ip_auth_hdr*)(top_iph+1);
-		ah->nexthdr = IPPROTO_IPIP;
-	} else {
-		memcpy(&tmp_iph, (*pskb)->data, iph->ihl*4);
-		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
-		memcpy(top_iph, &tmp_iph, iph->ihl*4);
-		if (top_iph->ihl != 5) {
-			err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
-			if (err)
-				goto error;
-		}
-		ah = (struct ip_auth_hdr*)((char*)top_iph+iph->ihl*4);
-		ah->nexthdr = iph->protocol;
 	}
 
-	iph = &tmp_iph.iph;
+	ah = (struct ip_auth_hdr *)((char *)top_iph+top_iph->ihl*4);
+	ah->nexthdr = top_iph->protocol;
+
 	top_iph->tos = 0;
 	top_iph->tot_len = htons((*pskb)->len);
 	top_iph->frag_off = 0;
@@ -128,31 +100,19 @@
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
 	ahp->icv(ahp, *pskb, ah->auth_data);
+
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
 	top_iph->frag_off = iph->frag_off;
-	if (!x->props.mode) {
-		top_iph->daddr = iph->daddr;
-		if (iph->ihl != 5)
-			memcpy(top_iph+1, iph+1, iph->ihl*4 - sizeof(struct iphdr));
-	}
-	ip_send_check(top_iph);
+	top_iph->daddr = iph->daddr;
+	if (top_iph->ihl != 5)
+		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 
-	(*pskb)->nh.raw = (*pskb)->data;
+	ip_send_check(top_iph);
 
-	x->curlft.bytes += (*pskb)->len;
-	x->curlft.packets++;
-	spin_unlock_bh(&x->lock);
-	if (((*pskb)->dst = dst_pop(dst)) == NULL) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	return NET_XMIT_BYPASS;
+	err = 0;
 
 error:
-	spin_unlock_bh(&x->lock);
-error_nolock:
-	kfree_skb(*pskb);
 	return err;
 }
 
diff -Nru a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	2004-07-10 10:43:34 +10:00
+++ b/net/ipv4/esp4.c	2004-07-10 10:43:34 +10:00
@@ -23,7 +23,7 @@
 	int err;
 	struct dst_entry *dst = (*pskb)->dst;
 	struct xfrm_state *x  = dst->xfrm;
-	struct iphdr *iph, *top_iph;
+	struct iphdr *top_iph;
 	struct ip_esp_hdr *esph;
 	struct crypto_tfm *tfm;
 	struct esp_data *esp;
@@ -32,32 +32,9 @@
 	int clen;
 	int alen;
 	int nfrags;
-	union {
-		struct iphdr	iph;
-		char 		buf[60];
-	} tmp_iph;
-
-	if ((*pskb)->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(pskb, 0);
-		if (err)
-			goto error_nolock;
-	}
-
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, *pskb);
-	if (err)
-		goto error;
 
-	if (x->props.mode) {
-		err = xfrm4_tunnel_check_size(*pskb);
-		if (err)
-			goto error;
-	} else {
-		/* Strip IP header in transport mode. Save it. */
-		iph = (*pskb)->nh.iph;
-		memcpy(&tmp_iph, iph, iph->ihl*4);
-		__skb_pull(*pskb, iph->ihl*4);
-	}
+	/* Strip IP+ESP header. */
+	__skb_pull(*pskb, (*pskb)->h.raw - (*pskb)->data);
 	/* Now skb is pure payload to encrypt */
 
 	err = -ENOMEM;
@@ -85,35 +62,11 @@
 	*(u8*)(trailer->tail + clen-(*pskb)->len - 2) = (clen - (*pskb)->len)-2;
 	pskb_put(*pskb, trailer, clen - (*pskb)->len);
 
-	iph = (*pskb)->nh.iph;
-	if (x->props.mode) {
-		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
-		esph = (struct ip_esp_hdr*)(top_iph+1);
-		*(u8*)(trailer->tail - 1) = IPPROTO_IPIP;
-		top_iph->ihl = 5;
-		top_iph->version = 4;
-		top_iph->tos = iph->tos;	/* DS disclosed */
-		if (x->props.flags & XFRM_STATE_NOECN)
-			IP_ECN_clear(top_iph);
-		top_iph->tot_len = htons((*pskb)->len + alen);
-		top_iph->frag_off = iph->frag_off&htons(IP_DF);
-		if (!(top_iph->frag_off))
-			ip_select_ident(top_iph, dst, NULL);
-		top_iph->ttl = iph->ttl;	/* TTL disclosed */
-		top_iph->check = 0;
-		top_iph->saddr = x->props.saddr.a4;
-		top_iph->daddr = x->id.daddr.a4;
-		memset(&(IPCB(*pskb)->opt), 0, sizeof(struct ip_options));
-	} else {
-		esph = (struct ip_esp_hdr*)skb_push(*pskb, x->props.header_len);
-		top_iph = (struct iphdr*)skb_push(*pskb, iph->ihl*4);
-		memcpy(top_iph, &tmp_iph, iph->ihl*4);
-		iph = &tmp_iph.iph;
-		top_iph->tot_len = htons((*pskb)->len + alen);
-		top_iph->check = 0;
-		top_iph->frag_off = iph->frag_off;
-		*(u8*)(trailer->tail - 1) = iph->protocol;
-	}
+	__skb_push(*pskb, (*pskb)->data - (*pskb)->nh.raw);
+	top_iph = (*pskb)->nh.iph;
+	esph = (struct ip_esp_hdr *)((*pskb)->nh.raw + top_iph->ihl*4);
+	top_iph->tot_len = htons((*pskb)->len + alen);
+	*(u8*)(trailer->tail - 1) = top_iph->protocol;
 
 	/* this is non-NULL only with UDP Encapsulation */
 	if (x->encap) {
@@ -124,7 +77,7 @@
 		uh = (struct udphdr *)esph;
 		uh->source = encap->encap_sport;
 		uh->dest = encap->encap_dport;
-		uh->len = htons((*pskb)->len + alen - iph->ihl*4);
+		uh->len = htons((*pskb)->len + alen - top_iph->ihl*4);
 		uh->check = 0;
 
 		switch (encap->encap_type) {
@@ -176,21 +129,9 @@
 
 	ip_send_check(top_iph);
 
-	(*pskb)->nh.raw = (*pskb)->data;
-
-	x->curlft.bytes += (*pskb)->len;
-	x->curlft.packets++;
-	spin_unlock_bh(&x->lock);
-	if (((*pskb)->dst = dst_pop(dst)) == NULL) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	return NET_XMIT_BYPASS;
+	err = 0;
 
 error:
-	spin_unlock_bh(&x->lock);
-error_nolock:
-	kfree_skb(*pskb);
 	return err;
 }
 
diff -Nru a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
--- a/net/ipv4/ipcomp.c	2004-07-10 10:43:34 +10:00
+++ b/net/ipv4/ipcomp.c	2004-07-10 10:43:34 +10:00
@@ -121,28 +121,6 @@
 	return err;
 }
 
-static void ipcomp_tunnel_encap(struct xfrm_state *x, struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb->dst;
-	struct iphdr *iph, *top_iph;
-
-	iph = skb->nh.iph;
-	top_iph = (struct iphdr *)skb_push(skb, sizeof(struct iphdr));
-	top_iph->ihl = 5;
-	top_iph->version = 4;
-	top_iph->tos = iph->tos;
-	top_iph->tot_len = htons(skb->len);
-	if (!(iph->frag_off&htons(IP_DF)))
-		__ip_select_ident(top_iph, dst, 0);
-	top_iph->ttl = iph->ttl;
-	top_iph->check = 0;
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
-	top_iph->frag_off = iph->frag_off&~htons(IP_MF|IP_OFFSET);
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
-	skb->nh.raw = skb->data;
-}
-
 static int ipcomp_output(struct sk_buff **pskb)
 {
 	int err;
@@ -153,39 +131,17 @@
 	struct ipcomp_data *ipcd = x->data;
 	int hdr_len = 0;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(pskb, 0);
-		if (err)
-			goto error_nolock;
-	}
-
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, *pskb);
-	if (err)
-		goto error;
-
-	if (x->props.mode) {
-		err = xfrm4_tunnel_check_size(*pskb);
-		if (err)
-			goto error;
-	} else {
-		/* Don't bother compressing */
-		iph = (*pskb)->nh.iph;
-		hdr_len = iph->ihl * 4;
-	}
+	iph = (*pskb)->nh.iph;
+	iph->tot_len = htons((*pskb)->len);
+	hdr_len = iph->ihl * 4;
 	if (((*pskb)->len - hdr_len) < ipcd->threshold) {
+		/* Don't bother compressing */
 		if (x->props.mode) {
-			ipcomp_tunnel_encap(x, *pskb);
-			iph = (*pskb)->nh.iph;
-			iph->protocol = IPPROTO_IPIP;
 			ip_send_check(iph);
 		}
 		goto out_ok;
 	}
 
-	if (x->props.mode) 
-		ipcomp_tunnel_encap(x, *pskb);
-
 	if ((skb_is_nonlinear(*pskb) || skb_cloned(*pskb)) &&
 	    skb_linearize(*pskb, GFP_ATOMIC) != 0) {
 	    	err = -ENOMEM;
@@ -197,7 +153,6 @@
 		if (err == -EMSGSIZE) {
 			if (x->props.mode) {
 				iph = (*pskb)->nh.iph;
-				iph->protocol = IPPROTO_IPIP;
 				ip_send_check(iph);
 			}
 			goto out_ok;
@@ -207,36 +162,19 @@
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
 	iph = (*pskb)->nh.iph;
-	if (x->props.mode && (x->props.flags & XFRM_STATE_NOECN))
-		IP_ECN_clear(iph);
 	iph->tot_len = htons((*pskb)->len);
-	iph->check = 0;
 	ipch = (struct ip_comp_hdr *)((char *)iph + iph->ihl * 4);
-	ipch->nexthdr = x->props.mode ? IPPROTO_IPIP : iph->protocol;
+	ipch->nexthdr = iph->protocol;
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
 	iph->protocol = IPPROTO_COMP;
 	ip_send_check(iph);
-	(*pskb)->nh.raw = (*pskb)->data;
 
 out_ok:
-	x->curlft.bytes += (*pskb)->len;
-	x->curlft.packets++;
-	spin_unlock_bh(&x->lock);
-	
-	if (((*pskb)->dst = dst_pop(dst)) == NULL) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	err = NET_XMIT_BYPASS;
+	err = 0;
 
-out_exit:
-	return err;
 error:
-	spin_unlock_bh(&x->lock);
-error_nolock:
-	kfree_skb(*pskb);
-	goto out_exit;
+	return err;
 }
 
 static void ipcomp4_err(struct sk_buff *skb, u32 info)
diff -Nru a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/xfrm4_output.c	2004-07-10 10:43:34 +10:00
@@ -0,0 +1,120 @@
+/*
+ * xfrm4_output.c - Common IPsec encapsulation code for IPv4.
+ * Copyright (c) 2004 Herbert Xu <herbert@gondor.apana.org.au>
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <net/inet_ecn.h>
+#include <net/ip.h>
+#include <net/xfrm.h>
+
+/* Add encapsulation header.
+ *
+ * In transport mode, the IP header will be moved forward to make space
+ * for the encapsulation header.
+ *
+ * In tunnel mode, the top IP header will be constructed per RFC 2401.
+ * The following fields in it shall be filled in by x->type->output:
+ *	tot_len
+ *	check
+ *
+ * On exit, skb->h will be set to the start of the payload to be processed
+ * by x->type->output and skb->nh will be set to the top IP header.
+ */
+static void xfrm4_encap(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb->dst;
+	struct xfrm_state *x = dst->xfrm;
+	struct iphdr *iph, *top_iph;
+
+	iph = skb->nh.iph;
+	skb->h.ipiph = iph;
+
+	skb->nh.raw = skb_push(skb, x->props.header_len);
+	top_iph = skb->nh.iph;
+
+	if (!x->props.mode) {
+		skb->h.raw += iph->ihl*4;
+		memmove(top_iph, iph, iph->ihl*4);
+		return;
+	}
+
+	top_iph->ihl = 5;
+	top_iph->version = 4;
+
+	/* DS disclosed */
+	top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
+	if (x->props.flags & XFRM_STATE_NOECN)
+		IP_ECN_clear(top_iph);
+
+	top_iph->frag_off = iph->frag_off & htons(IP_DF);
+	if (!top_iph->frag_off)
+		__ip_select_ident(top_iph, dst, 0);
+
+	/* TTL disclosed */
+	top_iph->ttl = iph->ttl;
+
+	top_iph->saddr = x->props.saddr.a4;
+	top_iph->daddr = x->id.daddr.a4;
+	top_iph->protocol = IPPROTO_IPIP;
+
+	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+}
+
+int xfrm4_output(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+	struct dst_entry *dst = skb->dst;
+	struct xfrm_state *x = dst->xfrm;
+	int err;
+	
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = skb_checksum_help(pskb, 0);
+		skb = *pskb;
+		if (err)
+			goto error_nolock;
+	}
+
+	spin_lock_bh(&x->lock);
+	err = xfrm_state_check(x, skb);
+	if (err)
+		goto error;
+
+	if (x->props.mode) {
+		err = xfrm4_tunnel_check_size(skb);
+		if (err)
+			goto error;
+	}
+
+	xfrm4_encap(skb);
+
+	err = x->type->output(pskb);
+	skb = *pskb;
+	if (err)
+		goto error;
+
+	x->curlft.bytes += skb->len;
+	x->curlft.packets++;
+
+	spin_unlock_bh(&x->lock);
+	
+	if (!(skb->dst = dst_pop(dst))) {
+		err = -EHOSTUNREACH;
+		goto error_nolock;
+	}
+	err = NET_XMIT_BYPASS;
+
+out_exit:
+	return err;
+error:
+	spin_unlock_bh(&x->lock);
+error_nolock:
+	kfree_skb(skb);
+	goto out_exit;
+}
diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2004-07-10 10:43:34 +10:00
+++ b/net/ipv4/xfrm4_policy.c	2004-07-10 10:43:34 +10:00
@@ -139,7 +139,7 @@
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= dst_prev->xfrm->type->output;
+		dst_prev->output	= xfrm4_output;
 		if (rt->peer)
 			atomic_inc(&rt->peer->refcnt);
 		x->u.rt.peer = rt->peer;
diff -Nru a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
--- a/net/ipv4/xfrm4_tunnel.c	2004-07-10 10:43:34 +10:00
+++ b/net/ipv4/xfrm4_tunnel.c	2004-07-10 10:43:34 +10:00
@@ -36,52 +36,13 @@
 static int ipip_output(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
-	struct iphdr *iph, *top_iph;
-	int tos, err;
-
-	if ((err = xfrm4_tunnel_check_size(skb)) != 0)
-		goto error_nolock;
-		
+	struct iphdr *iph;
+	
 	iph = skb->nh.iph;
+	iph->tot_len = htons(skb->len);
+	ip_send_check(iph);
 
-	spin_lock_bh(&x->lock);
-
-	tos = iph->tos;
-
-	top_iph = (struct iphdr *) skb_push(skb, x->props.header_len);
-	top_iph->ihl = 5;
-	top_iph->version = 4;
-	top_iph->tos = INET_ECN_encapsulate(tos, iph->tos);
-	top_iph->tot_len = htons(skb->len);
-	top_iph->frag_off = iph->frag_off & ~htons(IP_MF|IP_OFFSET);
-	if (!(iph->frag_off & htons(IP_DF)))
-		__ip_select_ident(top_iph, dst, 0);
-	top_iph->ttl = iph->ttl;
-	top_iph->protocol = IPPROTO_IPIP;
-	top_iph->check = 0;
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
-	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
-	ip_send_check(top_iph);
-
-	skb->nh.raw = skb->data;
-	x->curlft.bytes += skb->len;
-	x->curlft.packets++;
-
-	spin_unlock_bh(&x->lock);
-
-	if ((skb->dst = dst_pop(dst)) == NULL) {
-		kfree_skb(skb);
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	return NET_XMIT_BYPASS;
-
-error_nolock:
-	kfree_skb(skb);
-	return err;
+	return 0;
 }
 
 static int ipip_xfrm_rcv(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)

--/04w6evG8XlLl3ft--
