From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Revert pskb change for x->type->output
Date: Fri, 20 Aug 2004 18:23:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040820082331.GA23626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Since skb_checksum_help() has been moved to xfrm[46]_output(), we don't
need the sk_buff ** argument in x->type->output anymore.  This patch
reverts it to a sk_buff *.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/xfrm.h 1.68 vs edited =====
--- 1.68/include/net/xfrm.h	2004-08-19 21:44:12 +10:00
+++ edited/include/net/xfrm.h	2004-08-20 18:08:26 +10:00
@@ -216,7 +216,7 @@
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct xfrm_decap_state *, struct sk_buff *skb);
 	int			(*post_input)(struct xfrm_state *, struct xfrm_decap_state *, struct sk_buff *skb);
-	int			(*output)(struct sk_buff **pskb);
+	int			(*output)(struct sk_buff *pskb);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
===== net/ipv4/ah4.c 1.41 vs edited =====
--- 1.41/net/ipv4/ah4.c	2004-08-14 20:59:43 +10:00
+++ edited/net/ipv4/ah4.c	2004-08-20 18:08:27 +10:00
@@ -53,10 +53,10 @@
 	return 0;
 }
 
-static int ah_output(struct sk_buff **pskb)
+static int ah_output(struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = (*pskb)->dst;
+	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x  = dst->xfrm;
 	struct iphdr *iph, *top_iph;
 	struct ip_auth_hdr *ah;
@@ -66,7 +66,7 @@
 		char 		buf[60];
 	} tmp_iph;
 
-	top_iph = (*pskb)->nh.iph;
+	top_iph = skb->nh.iph;
 	iph = &tmp_iph.iph;
 
 	iph->tos = top_iph->tos;
@@ -85,7 +85,7 @@
 	ah->nexthdr = top_iph->protocol;
 
 	top_iph->tos = 0;
-	top_iph->tot_len = htons((*pskb)->len);
+	top_iph->tot_len = htons(skb->len);
 	top_iph->frag_off = 0;
 	top_iph->ttl = 0;
 	top_iph->protocol = IPPROTO_AH;
@@ -98,7 +98,7 @@
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
-	ahp->icv(ahp, *pskb, ah->auth_data);
+	ahp->icv(ahp, skb, ah->auth_data);
 
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
===== net/ipv4/esp4.c 1.58 vs edited =====
--- 1.58/net/ipv4/esp4.c	2004-08-15 05:57:43 +10:00
+++ edited/net/ipv4/esp4.c	2004-08-20 18:08:27 +10:00
@@ -17,10 +17,10 @@
 	__u8		proto;
 };
 
-int esp_output(struct sk_buff **pskb)
+int esp_output(struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = (*pskb)->dst;
+	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x  = dst->xfrm;
 	struct iphdr *top_iph;
 	struct ip_esp_hdr *esph;
@@ -33,13 +33,13 @@
 	int nfrags;
 
 	/* Strip IP+ESP header. */
-	__skb_pull(*pskb, (*pskb)->h.raw - (*pskb)->data);
+	__skb_pull(skb, skb->h.raw - skb->data);
 	/* Now skb is pure payload to encrypt */
 
 	err = -ENOMEM;
 
 	/* Round to block size */
-	clen = (*pskb)->len;
+	clen = skb->len;
 
 	esp = x->data;
 	alen = esp->auth.icv_trunc_len;
@@ -49,22 +49,22 @@
 	if (esp->conf.padlen)
 		clen = (clen + esp->conf.padlen-1)&~(esp->conf.padlen-1);
 
-	if ((nfrags = skb_cow_data(*pskb, clen-(*pskb)->len+alen, &trailer)) < 0)
+	if ((nfrags = skb_cow_data(skb, clen-skb->len+alen, &trailer)) < 0)
 		goto error;
 
 	/* Fill padding... */
 	do {
 		int i;
-		for (i=0; i<clen-(*pskb)->len - 2; i++)
+		for (i=0; i<clen-skb->len - 2; i++)
 			*(u8*)(trailer->tail + i) = i+1;
 	} while (0);
-	*(u8*)(trailer->tail + clen-(*pskb)->len - 2) = (clen - (*pskb)->len)-2;
-	pskb_put(*pskb, trailer, clen - (*pskb)->len);
+	*(u8*)(trailer->tail + clen-skb->len - 2) = (clen - skb->len)-2;
+	pskb_put(skb, trailer, clen - skb->len);
 
-	__skb_push(*pskb, (*pskb)->data - (*pskb)->nh.raw);
-	top_iph = (*pskb)->nh.iph;
-	esph = (struct ip_esp_hdr *)((*pskb)->nh.raw + top_iph->ihl*4);
-	top_iph->tot_len = htons((*pskb)->len + alen);
+	__skb_push(skb, skb->data - skb->nh.raw);
+	top_iph = skb->nh.iph;
+	esph = (struct ip_esp_hdr *)(skb->nh.raw + top_iph->ihl*4);
+	top_iph->tot_len = htons(skb->len + alen);
 	*(u8*)(trailer->tail - 1) = top_iph->protocol;
 
 	/* this is non-NULL only with UDP Encapsulation */
@@ -76,7 +76,7 @@
 		uh = (struct udphdr *)esph;
 		uh->source = encap->encap_sport;
 		uh->dest = encap->encap_dport;
-		uh->len = htons((*pskb)->len + alen - top_iph->ihl*4);
+		uh->len = htons(skb->len + alen - top_iph->ihl*4);
 		uh->check = 0;
 
 		switch (encap->encap_type) {
@@ -109,7 +109,7 @@
 			if (!sg)
 				goto error;
 		}
-		skb_to_sgvec(*pskb, sg, esph->enc_data+esp->conf.ivlen-(*pskb)->data, clen);
+		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
 		crypto_cipher_encrypt(tfm, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -121,9 +121,9 @@
 	}
 
 	if (esp->auth.icv_full_len) {
-		esp->auth.icv(esp, *pskb, (u8*)esph-(*pskb)->data,
+		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
 		              sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
-		pskb_put(*pskb, trailer, alen);
+		pskb_put(skb, trailer, alen);
 	}
 
 	ip_send_check(top_iph);
===== net/ipv4/ipcomp.c 1.31 vs edited =====
--- 1.31/net/ipv4/ipcomp.c	2004-08-14 20:59:43 +10:00
+++ edited/net/ipv4/ipcomp.c	2004-08-20 18:08:27 +10:00
@@ -120,20 +120,20 @@
 	return err;
 }
 
-static int ipcomp_output(struct sk_buff **pskb)
+static int ipcomp_output(struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = (*pskb)->dst;
+	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	struct iphdr *iph;
 	struct ip_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
 	int hdr_len = 0;
 
-	iph = (*pskb)->nh.iph;
-	iph->tot_len = htons((*pskb)->len);
+	iph = skb->nh.iph;
+	iph->tot_len = htons(skb->len);
 	hdr_len = iph->ihl * 4;
-	if (((*pskb)->len - hdr_len) < ipcd->threshold) {
+	if ((skb->len - hdr_len) < ipcd->threshold) {
 		/* Don't bother compressing */
 		if (x->props.mode) {
 			ip_send_check(iph);
@@ -141,17 +141,17 @@
 		goto out_ok;
 	}
 
-	if ((skb_is_nonlinear(*pskb) || skb_cloned(*pskb)) &&
-	    skb_linearize(*pskb, GFP_ATOMIC) != 0) {
+	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
+	    skb_linearize(skb, GFP_ATOMIC) != 0) {
 	    	err = -ENOMEM;
 	    	goto error;
 	}
 	
-	err = ipcomp_compress(x, *pskb);
+	err = ipcomp_compress(x, skb);
 	if (err) {
 		if (err == -EMSGSIZE) {
 			if (x->props.mode) {
-				iph = (*pskb)->nh.iph;
+				iph = skb->nh.iph;
 				ip_send_check(iph);
 			}
 			goto out_ok;
@@ -160,8 +160,8 @@
 	}
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
-	iph = (*pskb)->nh.iph;
-	iph->tot_len = htons((*pskb)->len);
+	iph = skb->nh.iph;
+	iph->tot_len = htons(skb->len);
 	ipch = (struct ip_comp_hdr *)((char *)iph + iph->ihl * 4);
 	ipch->nexthdr = iph->protocol;
 	ipch->flags = 0;
===== net/ipv4/xfrm4_output.c 1.3 vs edited =====
--- 1.3/net/ipv4/xfrm4_output.c	2004-08-14 20:59:43 +10:00
+++ edited/net/ipv4/xfrm4_output.c	2004-08-20 18:16:45 +10:00
@@ -119,8 +119,7 @@
 
 	xfrm4_encap(skb);
 
-	err = x->type->output(pskb);
-	skb = *pskb;
+	err = x->type->output(skb);
 	if (err)
 		goto error;
 
===== net/ipv4/xfrm4_tunnel.c 1.19 vs edited =====
--- 1.19/net/ipv4/xfrm4_tunnel.c	2004-08-19 21:44:13 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2004-08-20 18:08:27 +10:00
@@ -9,9 +9,8 @@
 #include <net/ip.h>
 #include <net/protocol.h>
 
-static int ipip_output(struct sk_buff **pskb)
+static int ipip_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct iphdr *iph;
 	
 	iph = skb->nh.iph;
===== net/ipv6/ah6.c 1.41 vs edited =====
--- 1.41/net/ipv6/ah6.c	2004-08-14 20:59:44 +10:00
+++ edited/net/ipv6/ah6.c	2004-08-20 18:08:27 +10:00
@@ -154,11 +154,11 @@
 	return 0;
 }
 
-int ah6_output(struct sk_buff **pskb)
+int ah6_output(struct sk_buff *skb)
 {
 	int err;
 	int extlen;
-	struct dst_entry *dst = (*pskb)->dst;
+	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x  = dst->xfrm;
 	struct ipv6hdr *top_iph;
 	struct ip_auth_hdr *ah;
@@ -170,11 +170,11 @@
 		char hdrs[0];
 	} *tmp_ext;
 
-	top_iph = (struct ipv6hdr *)(*pskb)->data;
-	top_iph->payload_len = htons((*pskb)->len - sizeof(*top_iph));
+	top_iph = (struct ipv6hdr *)skb->data;
+	top_iph->payload_len = htons(skb->len - sizeof(*top_iph));
 
-	nexthdr = *(*pskb)->nh.raw;
-	*(*pskb)->nh.raw = IPPROTO_AH;
+	nexthdr = *skb->nh.raw;
+	*skb->nh.raw = IPPROTO_AH;
 
 	/* When there are no extension headers, we only need to save the first
 	 * 8 bytes of the base IP header.
@@ -182,7 +182,7 @@
 	memcpy(tmp_base, top_iph, sizeof(tmp_base));
 
 	tmp_ext = NULL;
-	extlen = (*pskb)->h.raw - (unsigned char *)(top_iph + 1);
+	extlen = skb->h.raw - (unsigned char *)(top_iph + 1);
 	if (extlen) {
 		extlen += sizeof(*tmp_ext);
 		tmp_ext = kmalloc(extlen, GFP_ATOMIC);
@@ -198,7 +198,7 @@
 			goto error_free_iph;
 	}
 
-	ah = (struct ip_auth_hdr *)(*pskb)->h.raw;
+	ah = (struct ip_auth_hdr *)skb->h.raw;
 	ah->nexthdr = nexthdr;
 
 	top_iph->priority    = 0;
@@ -214,7 +214,7 @@
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(++x->replay.oseq);
-	ahp->icv(ahp, *pskb, ah->auth_data);
+	ahp->icv(ahp, skb, ah->auth_data);
 
 	err = 0;
 
===== net/ipv6/esp6.c 1.40 vs edited =====
--- 1.40/net/ipv6/esp6.c	2004-08-15 17:36:52 +10:00
+++ edited/net/ipv6/esp6.c	2004-08-20 18:08:28 +10:00
@@ -37,11 +37,11 @@
 #include <net/ipv6.h>
 #include <linux/icmpv6.h>
 
-int esp6_output(struct sk_buff **pskb)
+int esp6_output(struct sk_buff *skb)
 {
 	int err;
 	int hdr_len;
-	struct dst_entry *dst = (*pskb)->dst;
+	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x  = dst->xfrm;
 	struct ipv6hdr *top_iph;
 	struct ipv6_esp_hdr *esph;
@@ -54,17 +54,17 @@
 	int nfrags;
 
 	esp = x->data;
-	hdr_len = (*pskb)->h.raw - (*pskb)->data +
+	hdr_len = skb->h.raw - skb->data +
 		  sizeof(*esph) + esp->conf.ivlen;
 
 	/* Strip IP+ESP header. */
-	__skb_pull(*pskb, hdr_len);
+	__skb_pull(skb, hdr_len);
 
 	/* Now skb is pure payload to encrypt */
 	err = -ENOMEM;
 
 	/* Round to block size */
-	clen = (*pskb)->len;
+	clen = skb->len;
 
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
@@ -73,24 +73,24 @@
 	if (esp->conf.padlen)
 		clen = (clen + esp->conf.padlen-1)&~(esp->conf.padlen-1);
 
-	if ((nfrags = skb_cow_data(*pskb, clen-(*pskb)->len+alen, &trailer)) < 0) {
+	if ((nfrags = skb_cow_data(skb, clen-skb->len+alen, &trailer)) < 0) {
 		goto error;
 	}
 
 	/* Fill padding... */
 	do {
 		int i;
-		for (i=0; i<clen-(*pskb)->len - 2; i++)
+		for (i=0; i<clen-skb->len - 2; i++)
 			*(u8*)(trailer->tail + i) = i+1;
 	} while (0);
-	*(u8*)(trailer->tail + clen-(*pskb)->len - 2) = (clen - (*pskb)->len)-2;
-	pskb_put(*pskb, trailer, clen - (*pskb)->len);
+	*(u8*)(trailer->tail + clen-skb->len - 2) = (clen - skb->len)-2;
+	pskb_put(skb, trailer, clen - skb->len);
 
-	top_iph = (struct ipv6hdr *)__skb_push(*pskb, hdr_len);
-	esph = (struct ipv6_esp_hdr *)(*pskb)->h.raw;
-	top_iph->payload_len = htons((*pskb)->len + alen - sizeof(*top_iph));
-	*(u8*)(trailer->tail - 1) = *(*pskb)->nh.raw;
-	*(*pskb)->nh.raw = IPPROTO_ESP;
+	top_iph = (struct ipv6hdr *)__skb_push(skb, hdr_len);
+	esph = (struct ipv6_esp_hdr *)skb->h.raw;
+	top_iph->payload_len = htons(skb->len + alen - sizeof(*top_iph));
+	*(u8*)(trailer->tail - 1) = *skb->nh.raw;
+	*skb->nh.raw = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);
@@ -106,7 +106,7 @@
 			if (!sg)
 				goto error;
 		}
-		skb_to_sgvec(*pskb, sg, esph->enc_data+esp->conf.ivlen-(*pskb)->data, clen);
+		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
 		crypto_cipher_encrypt(tfm, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -118,9 +118,9 @@
 	}
 
 	if (esp->auth.icv_full_len) {
-		esp->auth.icv(esp, *pskb, (u8*)esph-(*pskb)->data,
+		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
 			sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
-		pskb_put(*pskb, trailer, alen);
+		pskb_put(skb, trailer, alen);
 	}
 
 	err = 0;
===== net/ipv6/ipcomp6.c 1.22 vs edited =====
--- 1.22/net/ipv6/ipcomp6.c	2004-08-14 20:59:44 +10:00
+++ edited/net/ipv6/ipcomp6.c	2004-08-20 18:08:28 +10:00
@@ -114,10 +114,10 @@
 	return err;
 }
 
-static int ipcomp6_output(struct sk_buff **pskb)
+static int ipcomp6_output(struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = (*pskb)->dst;
+	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	struct ipv6hdr *top_iph;
 	int hdr_len;
@@ -126,23 +126,23 @@
 	int plen, dlen;
 	u8 *start, *scratch = ipcd->scratch;
 
-	hdr_len = (*pskb)->h.raw - (*pskb)->data;
+	hdr_len = skb->h.raw - skb->data;
 
 	/* check whether datagram len is larger than threshold */
-	if (((*pskb)->len - hdr_len) < ipcd->threshold) {
+	if ((skb->len - hdr_len) < ipcd->threshold) {
 		goto out_ok;
 	}
 
-	if ((skb_is_nonlinear(*pskb) || skb_cloned(*pskb)) &&
-		skb_linearize(*pskb, GFP_ATOMIC) != 0) {
+	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
+		skb_linearize(skb, GFP_ATOMIC) != 0) {
 		err = -ENOMEM;
 		goto error;
 	}
 
 	/* compression */
-	plen = (*pskb)->len - hdr_len;
+	plen = skb->len - hdr_len;
 	dlen = IPCOMP_SCRATCH_SIZE;
-	start = (*pskb)->h.raw;
+	start = skb->h.raw;
 
 	err = crypto_comp_compress(ipcd->tfm, start, plen, scratch, &dlen);
 	if (err) {
@@ -152,18 +152,18 @@
 		goto out_ok;
 	}
 	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
-	pskb_trim(*pskb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
+	pskb_trim(skb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
 
 	/* insert ipcomp header and replace datagram */
-	top_iph = (struct ipv6hdr *)(*pskb)->data;
+	top_iph = (struct ipv6hdr *)skb->data;
 
-	top_iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
+	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 
 	ipch = (struct ipv6_comp_hdr *)start;
-	ipch->nexthdr = *(*pskb)->nh.raw;
+	ipch->nexthdr = *skb->nh.raw;
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
-	*(*pskb)->nh.raw = IPPROTO_COMP;
+	*skb->nh.raw = IPPROTO_COMP;
 
 out_ok:
 	err = 0;
===== net/ipv6/xfrm6_output.c 1.3 vs edited =====
--- 1.3/net/ipv6/xfrm6_output.c	2004-08-14 20:59:44 +10:00
+++ edited/net/ipv6/xfrm6_output.c	2004-08-20 18:17:01 +10:00
@@ -113,8 +113,7 @@
 
 	xfrm6_encap(skb);
 
-	err = x->type->output(pskb);
-	skb = *pskb;
+	err = x->type->output(skb);
 	if (err)
 		goto error;
 
===== net/ipv6/xfrm6_tunnel.c 1.9 vs edited =====
--- 1.9/net/ipv6/xfrm6_tunnel.c	2004-08-19 21:44:13 +10:00
+++ edited/net/ipv6/xfrm6_tunnel.c	2004-08-20 18:08:28 +10:00
@@ -343,9 +343,8 @@
 
 EXPORT_SYMBOL(xfrm6_tunnel_free_spi);
 
-static int xfrm6_tunnel_output(struct sk_buff **pskb)
+static int xfrm6_tunnel_output(struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	struct ipv6hdr *top_iph;
 
 	top_iph = (struct ipv6hdr *)skb->data;

--ew6BAiZeqk4r7MaW--
