From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Move generic encap code into xfrm6_output
Date: Sun, 25 Jul 2004 20:40:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040725104028.GA24547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Here is the IPv6 version of the generic tunnel encapsulation code.

It is amazing to see how similar the IPv6 transform code is to its
IPv4 counterpart (except for AH) once the tunnel encapsulation code
is gone.  Maybe we can merge them one day.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-07-25 20:34:45 +10:00
+++ b/include/net/xfrm.h	2004-07-25 20:34:45 +10:00
@@ -823,6 +823,7 @@
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_check_size(struct sk_buff *skb);
 extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
+extern int xfrm6_output(struct sk_buff **pskb);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_check_size(struct sk_buff *skb);
diff -Nru a/net/ipv6/Makefile b/net/ipv6/Makefile
--- a/net/ipv6/Makefile	2004-07-25 20:34:45 +10:00
+++ b/net/ipv6/Makefile	2004-07-25 20:34:45 +10:00
@@ -11,7 +11,7 @@
 		ip6_flowlabel.o ipv6_syms.o
 
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
-	xfrm6_tunnel.o
+	xfrm6_tunnel.o xfrm6_output.o
 ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
diff -Nru a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c	2004-07-25 20:34:45 +10:00
+++ b/net/ipv6/ah6.c	2004-07-25 20:34:45 +10:00
@@ -158,65 +158,50 @@
 int ah6_output(struct sk_buff **pskb)
 {
 	int err;
-	int hdr_len = sizeof(struct ipv6hdr);
+	int extlen;
 	struct dst_entry *dst = (*pskb)->dst;
 	struct xfrm_state *x  = dst->xfrm;
-	struct ipv6hdr *iph = NULL;
+	struct ipv6hdr *top_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
 	u8 nexthdr;
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
-
-	if (x->props.mode) {
-		err = xfrm6_tunnel_check_size(*pskb);
-		if (err)
-			goto error;
-
-		iph = (*pskb)->nh.ipv6h;
-		(*pskb)->nh.ipv6h = (struct ipv6hdr*)skb_push(*pskb, x->props.header_len);
-		(*pskb)->nh.ipv6h->version = 6;
-		(*pskb)->nh.ipv6h->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
-		(*pskb)->nh.ipv6h->nexthdr = IPPROTO_AH;
-		ipv6_addr_copy(&(*pskb)->nh.ipv6h->saddr,
-			       (struct in6_addr *) &x->props.saddr);
-		ipv6_addr_copy(&(*pskb)->nh.ipv6h->daddr,
-			       (struct in6_addr *) &x->id.daddr);
-		ah = (struct ip_auth_hdr*)((*pskb)->nh.ipv6h+1);
-		ah->nexthdr = IPPROTO_IPV6;
-	} else {
-		u8 *prevhdr;
-
-		hdr_len = ip6_find_1stfragopt(*pskb, &prevhdr);
-		nexthdr = *prevhdr;
-		*prevhdr = IPPROTO_AH;
-		iph = kmalloc(hdr_len, GFP_ATOMIC);
-		if (!iph) {
+	char tmp_base[8];
+	struct {
+		struct in6_addr daddr;
+		char hdrs[0];
+	} *tmp_ext;
+
+	top_iph = (struct ipv6hdr *)(*pskb)->data;
+	top_iph->payload_len = htons((*pskb)->len - sizeof(*top_iph));
+
+	nexthdr = *(*pskb)->nh.raw;
+	*(*pskb)->nh.raw = IPPROTO_AH;
+
+	/* When there are no extension headers, we only need to save the first
+	 * 8 bytes of the base IP header.
+	 */
+	memcpy(tmp_base, top_iph, sizeof(tmp_base));
+
+	tmp_ext = NULL;
+	extlen = (*pskb)->h.raw - (unsigned char *)(top_iph + 1);
+	if (extlen) {
+		extlen += sizeof(*tmp_ext);
+		tmp_ext = kmalloc(extlen, GFP_ATOMIC);
+		if (!tmp_ext) {
 			err = -ENOMEM;
 			goto error;
 		}
-		memcpy(iph, (*pskb)->data, hdr_len);
-		(*pskb)->nh.ipv6h = (struct ipv6hdr*)skb_push(*pskb, x->props.header_len);
-		iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
-		memcpy((*pskb)->nh.ipv6h, iph, hdr_len);
-		err = ipv6_clear_mutable_options((*pskb)->nh.ipv6h, hdr_len);
+		memcpy(tmp_ext, &top_iph->daddr, extlen);
+		err = ipv6_clear_mutable_options(top_iph,
+						 extlen - sizeof(*tmp_ext) +
+						 sizeof(*top_iph));
 		if (err)
 			goto error_free_iph;
-
-		ah = (struct ip_auth_hdr*)((*pskb)->nh.raw+hdr_len);
-		(*pskb)->h.raw = (unsigned char*) ah;
-		ah->nexthdr = nexthdr;
 	}
 
+	ah = (struct ip_auth_hdr *)(*pskb)->h.raw;
+	ah->nexthdr = nexthdr;
+
 	(*pskb)->nh.ipv6h->priority    = 0;
 	(*pskb)->nh.ipv6h->flow_lbl[0] = 0;
 	(*pskb)->nh.ipv6h->flow_lbl[1] = 0;
@@ -232,35 +217,16 @@
 	ah->seq_no = htonl(++x->replay.oseq);
 	ahp->icv(ahp, *pskb, ah->auth_data);
 
-	if (x->props.mode) {
-		(*pskb)->nh.ipv6h->hop_limit   = iph->hop_limit;
-		(*pskb)->nh.ipv6h->priority    = iph->priority; 	
-		(*pskb)->nh.ipv6h->flow_lbl[0] = iph->flow_lbl[0];
-		(*pskb)->nh.ipv6h->flow_lbl[1] = iph->flow_lbl[1];
-		(*pskb)->nh.ipv6h->flow_lbl[2] = iph->flow_lbl[2];
-		if (x->props.flags & XFRM_STATE_NOECN)
-			IP6_ECN_clear((*pskb)->nh.ipv6h);
-	} else {
-		memcpy((*pskb)->nh.ipv6h, iph, hdr_len);
-		kfree (iph);
-	}
-
-	(*pskb)->nh.raw = (*pskb)->data;
+	err = 0;
 
-	x->curlft.bytes += (*pskb)->len;
-	x->curlft.packets++;
-	spin_unlock_bh(&x->lock);
-	if (((*pskb)->dst = dst_pop(dst)) == NULL) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
-	return NET_XMIT_BYPASS;
+	memcpy(top_iph, tmp_base, sizeof(tmp_base));
+	if (tmp_ext) {
+		memcpy(&top_iph->daddr, tmp_ext, extlen);
 error_free_iph:
-	kfree(iph);
+		kfree(tmp_ext);
+	}
+
 error:
-	spin_unlock_bh(&x->lock);
-error_nolock:
-	kfree_skb(*pskb);
 	return err;
 }
 
diff -Nru a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c	2004-07-25 20:34:45 +10:00
+++ b/net/ipv6/esp6.c	2004-07-25 20:34:45 +10:00
@@ -41,10 +41,10 @@
 int esp6_output(struct sk_buff **pskb)
 {
 	int err;
-	int hdr_len = 0;
+	int hdr_len;
 	struct dst_entry *dst = (*pskb)->dst;
 	struct xfrm_state *x  = dst->xfrm;
-	struct ipv6hdr *iph = NULL, *top_iph;
+	struct ipv6hdr *top_iph;
 	struct ipv6_esp_hdr *esph;
 	struct crypto_tfm *tfm;
 	struct esp_data *esp;
@@ -53,37 +53,13 @@
 	int clen;
 	int alen;
 	int nfrags;
-	u8 *prevhdr;
-	u8 nexthdr = 0;
 
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
+	esp = x->data;
+	hdr_len = (*pskb)->h.raw - (*pskb)->data +
+		  sizeof(*esph) + esp->conf.ivlen;
 
-	if (x->props.mode) {
-		err = xfrm6_tunnel_check_size(*pskb);
-		if (err)
-			goto error;
-	} else {
-		/* Strip IP header in transport mode. Save it. */
-		hdr_len = ip6_find_1stfragopt(*pskb, &prevhdr);
-		nexthdr = *prevhdr;
-		*prevhdr = IPPROTO_ESP;
-		iph = kmalloc(hdr_len, GFP_ATOMIC);
-		if (!iph) {
-			err = -ENOMEM;
-			goto error;
-		}
-		memcpy(iph, (*pskb)->nh.raw, hdr_len);
-		__skb_pull(*pskb, hdr_len);
-	}
+	/* Strip IP+ESP header. */
+	__skb_pull(*pskb, hdr_len);
 
 	/* Now skb is pure payload to encrypt */
 	err = -ENOMEM;
@@ -91,7 +67,6 @@
 	/* Round to block size */
 	clen = (*pskb)->len;
 
-	esp = x->data;
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
 	blksize = (crypto_tfm_alg_blocksize(tfm) + 3) & ~3;
@@ -100,7 +75,6 @@
 		clen = (clen + esp->conf.padlen-1)&~(esp->conf.padlen-1);
 
 	if ((nfrags = skb_cow_data(*pskb, clen-(*pskb)->len+alen, &trailer)) < 0) {
-		if (!x->props.mode && iph) kfree(iph);
 		goto error;
 	}
 
@@ -113,34 +87,11 @@
 	*(u8*)(trailer->tail + clen-(*pskb)->len - 2) = (clen - (*pskb)->len)-2;
 	pskb_put(*pskb, trailer, clen - (*pskb)->len);
 
-	if (x->props.mode) {
-		iph = (*pskb)->nh.ipv6h;
-		top_iph = (struct ipv6hdr*)skb_push(*pskb, x->props.header_len);
-		esph = (struct ipv6_esp_hdr*)(top_iph+1);
-		*(u8*)(trailer->tail - 1) = IPPROTO_IPV6;
-		top_iph->version = 6;
-		top_iph->priority = iph->priority;
-		top_iph->flow_lbl[0] = iph->flow_lbl[0];
-		top_iph->flow_lbl[1] = iph->flow_lbl[1];
-		top_iph->flow_lbl[2] = iph->flow_lbl[2];
-		if (x->props.flags & XFRM_STATE_NOECN)
-			IP6_ECN_clear(top_iph);
-		top_iph->nexthdr = IPPROTO_ESP;
-		top_iph->payload_len = htons((*pskb)->len + alen - sizeof(struct ipv6hdr));
-		top_iph->hop_limit = iph->hop_limit;
-		ipv6_addr_copy(&top_iph->saddr,
-			       (struct in6_addr *)&x->props.saddr);
-		ipv6_addr_copy(&top_iph->daddr,
-			       (struct in6_addr *)&x->id.daddr);
-	} else { 
-		esph = (struct ipv6_esp_hdr*)skb_push(*pskb, x->props.header_len);
-		(*pskb)->h.raw = (unsigned char*)esph;
-		top_iph = (struct ipv6hdr*)skb_push(*pskb, hdr_len);
-		memcpy(top_iph, iph, hdr_len);
-		kfree(iph);
-		top_iph->payload_len = htons((*pskb)->len + alen - sizeof(struct ipv6hdr));
-		*(u8*)(trailer->tail - 1) = nexthdr;
-	}
+	top_iph = (struct ipv6hdr *)__skb_push(*pskb, hdr_len);
+	esph = (struct ipv6_esp_hdr *)(*pskb)->h.raw;
+	top_iph->payload_len = htons((*pskb)->len + alen - sizeof(*top_iph));
+	*(u8*)(trailer->tail - 1) = *(*pskb)->nh.raw;
+	*(*pskb)->nh.raw = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
@@ -173,21 +124,9 @@
 		pskb_put(*pskb, trailer, alen);
 	}
 
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
 
diff -Nru a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
--- a/net/ipv6/ipcomp6.c	2004-07-25 20:34:45 +10:00
+++ b/net/ipv6/ipcomp6.c	2004-07-25 20:34:45 +10:00
@@ -123,52 +123,14 @@
 	int err;
 	struct dst_entry *dst = (*pskb)->dst;
 	struct xfrm_state *x = dst->xfrm;
-	struct ipv6hdr *iph, *top_iph;
-	int hdr_len = 0;
+	struct ipv6hdr *top_iph;
+	int hdr_len;
 	struct ipv6_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
-	u8 *prevhdr;
-	u8 nexthdr = 0;
 	int plen, dlen;
 	u8 *start, *scratch = ipcd->scratch;
 
-	if ((*pskb)->ip_summed == CHECKSUM_HW) {
-		err = skb_checksum_help(pskb, 0);
-		if (err)
-			goto error_nolock;
-	}
-
-	spin_lock_bh(&x->lock);
-
-	err = xfrm_state_check(x, *pskb);
-	if (err)
-		goto error;
-
-	if (x->props.mode) {
-		err = xfrm6_tunnel_check_size(*pskb);
-		if (err)
-			goto error;
-
-		hdr_len = sizeof(struct ipv6hdr);
-		nexthdr = IPPROTO_IPV6;
-		iph = (*pskb)->nh.ipv6h;
-		top_iph = (struct ipv6hdr *)skb_push(*pskb, sizeof(struct ipv6hdr));
-		top_iph->version = 6;
-		top_iph->priority = iph->priority;
-		top_iph->flow_lbl[0] = iph->flow_lbl[0];
-		top_iph->flow_lbl[1] = iph->flow_lbl[1];
-		top_iph->flow_lbl[2] = iph->flow_lbl[2];
-		top_iph->nexthdr = IPPROTO_IPV6; /* initial */
-		top_iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
-		top_iph->hop_limit = iph->hop_limit;
-		memcpy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr, sizeof(struct in6_addr));
-		memcpy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr, sizeof(struct in6_addr));
-		(*pskb)->nh.raw = (*pskb)->data; /* == top_iph */
-		(*pskb)->h.raw = (*pskb)->nh.raw + hdr_len;
-	} else {
-		hdr_len = ip6_find_1stfragopt(*pskb, &prevhdr);
-		nexthdr = *prevhdr;
-	}
+	hdr_len = (*pskb)->h.raw - (*pskb)->data;
 
 	/* check whether datagram len is larger than threshold */
 	if (((*pskb)->len - hdr_len) < ipcd->threshold) {
@@ -184,7 +146,7 @@
 	/* compression */
 	plen = (*pskb)->len - hdr_len;
 	dlen = IPCOMP_SCRATCH_SIZE;
-	start = (*pskb)->data + hdr_len;
+	start = (*pskb)->h.raw;
 
 	err = crypto_comp_compress(ipcd->tfm, start, plen, scratch, &dlen);
 	if (err) {
@@ -197,39 +159,21 @@
 	pskb_trim(*pskb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
 
 	/* insert ipcomp header and replace datagram */
-	top_iph = (*pskb)->nh.ipv6h;
+	top_iph = (struct ipv6hdr *)(*pskb)->data;
 
-	if (x->props.mode && (x->props.flags & XFRM_STATE_NOECN))
-		IP6_ECN_clear(top_iph);
 	top_iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
-	(*pskb)->nh.raw = (*pskb)->data; /* top_iph */
-	ip6_find_1stfragopt(*pskb, &prevhdr); 
-	*prevhdr = IPPROTO_COMP;
 
-	ipch = (struct ipv6_comp_hdr *)((unsigned char *)top_iph + hdr_len);
-	ipch->nexthdr = nexthdr;
+	ipch = (struct ipv6_comp_hdr *)start;
+	ipch->nexthdr = *(*pskb)->nh.raw;
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
+	*(*pskb)->nh.raw = IPPROTO_COMP;
 
-	(*pskb)->h.raw = (unsigned char*)ipch;
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
 
 static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
diff -Nru a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv6/xfrm6_output.c	2004-07-25 20:34:45 +10:00
@@ -0,0 +1,123 @@
+/*
+ * xfrm6_output.c - Common IPsec encapsulation code for IPv6.
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
+#include <net/ipv6.h>
+#include <net/xfrm.h>
+
+/* Add encapsulation header.
+ *
+ * In transport mode, the IP header and mutable extension headers will be moved
+ * forward to make space for the encapsulation header.
+ *
+ * In tunnel mode, the top IP header will be constructed per RFC 2401.
+ * The following fields in it shall be filled in by x->type->output:
+ *	payload_len
+ *
+ * On exit, skb->h will be set to the start of the encapsulation header to be
+ * filled in by x->type->output and skb->nh will be set to the nextheader field
+ * of the extension header directly preceding the encapsulation header, or in
+ * its absence, that of the top IP header.  The value of skb->data will always
+ * point to the top IP header.
+ */
+static void xfrm6_encap(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb->dst;
+	struct xfrm_state *x = dst->xfrm;
+	struct ipv6hdr *iph, *top_iph;
+
+	skb_push(skb, x->props.header_len);
+	iph = skb->nh.ipv6h;
+
+	if (!x->props.mode) {
+		u8 *prevhdr;
+		int hdr_len;
+
+		hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
+		skb->nh.raw = prevhdr - hdr_len;
+		skb->h.ipv6h = iph;
+		skb->h.raw += hdr_len;
+		memmove(skb->data, iph, hdr_len);
+		return;
+	}
+
+	skb->nh.raw = skb->data;
+	top_iph = skb->nh.ipv6h;
+	skb->nh.raw = &top_iph->nexthdr;
+	skb->h.ipv6h = top_iph + 1;
+
+	top_iph->version = 6;
+	top_iph->priority = iph->priority;
+	if (x->props.flags & XFRM_STATE_NOECN)
+		IP6_ECN_clear(top_iph);
+	top_iph->flow_lbl[0] = iph->flow_lbl[0];
+	top_iph->flow_lbl[1] = iph->flow_lbl[1];
+	top_iph->flow_lbl[2] = iph->flow_lbl[2];
+	top_iph->nexthdr = IPPROTO_IPV6; 
+	top_iph->hop_limit = iph->hop_limit;
+	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
+	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+}
+
+int xfrm6_output(struct sk_buff **pskb)
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
+		err = xfrm6_tunnel_check_size(skb);
+		if (err)
+			goto error;
+	}
+
+	xfrm6_encap(skb);
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
+	skb->nh.raw = skb->data;
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
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2004-07-25 20:34:45 +10:00
+++ b/net/ipv6/xfrm6_policy.c	2004-07-25 20:34:45 +10:00
@@ -157,7 +157,7 @@
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output	= dst_prev->xfrm->type->output;
+		dst_prev->output	= xfrm6_output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
diff -Nru a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
--- a/net/ipv6/xfrm6_tunnel.c	2004-07-25 20:34:45 +10:00
+++ b/net/ipv6/xfrm6_tunnel.c	2004-07-25 20:34:45 +10:00
@@ -365,46 +365,12 @@
 static int xfrm6_tunnel_output(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
-	struct ipv6hdr *iph, *top_iph;
-	int err;
+	struct ipv6hdr *top_iph;
 
-	if ((err = xfrm6_tunnel_check_size(skb)) != 0)
-		goto error_nolock;
-
-	iph = skb->nh.ipv6h;
-
-	top_iph = (struct ipv6hdr *)skb_push(skb, x->props.header_len);
-	top_iph->version = 6;
-	top_iph->priority = iph->priority;
-	top_iph->flow_lbl[0] = iph->flow_lbl[0];
-	top_iph->flow_lbl[1] = iph->flow_lbl[1];
-	top_iph->flow_lbl[2] = iph->flow_lbl[2];
-	top_iph->nexthdr = IPPROTO_IPV6; 
+	top_iph = (struct ipv6hdr *)skb->data;
 	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
-	top_iph->hop_limit = iph->hop_limit;
-	memcpy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr, sizeof(struct in6_addr));
-	memcpy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr, sizeof(struct in6_addr));
-	skb->nh.raw = skb->data;
-	skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
-
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
-
-	return NET_XMIT_BYPASS;
 
-error_nolock:
-	kfree_skb(skb);
-	return err;
+	return 0;
 }
 
 static int xfrm6_tunnel_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)

--0OAP2g/MAC+5xKAE--
