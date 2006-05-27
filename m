From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/4] [IPSEC] proto: Move transport mode input path into xfrm_mode_transport
Date: Sat, 27 May 2006 21:35:03 +1000
Message-ID: <20060527113503.GC4737@gondor.apana.org.au>
References: <20060527113236.GA4203@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="KDt/GgjP6HVcx58l"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:18956 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751472AbWE0LfG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 07:35:06 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060527113236.GA4203@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--KDt/GgjP6HVcx58l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[IPSEC] proto: Move transport mode input path into xfrm_mode_transport

Now that we have xfrm_mode objects we can move the transport mode specific
input decapsulation code into xfrm_mode_transport.  This removes duplicate
code as well as unnecessary header movement in case of tunnel mode SAs
since we will discard the original IP header immediately.

This also fixes a minor bug for transport-mode ESP where the IP payload
length is set to the correct value minus the header length (with extension
headers for IPv6).

Of course the other neat thing is that we no longer have to allocate
temporary buffers to hold the IP headers for ESP and IPComp.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--KDt/GgjP6HVcx58l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p3.patch"

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -119,6 +119,7 @@ error:
 static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int ah_hlen;
+	int ihl;
 	struct iphdr *iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
@@ -149,13 +150,14 @@ static int ah_input(struct xfrm_state *x
 	ah = (struct ip_auth_hdr*)skb->data;
 	iph = skb->nh.iph;
 
-	memcpy(work_buf, iph, iph->ihl*4);
+	ihl = skb->data - skb->nh.raw;
+	memcpy(work_buf, iph, ihl);
 
 	iph->ttl = 0;
 	iph->tos = 0;
 	iph->frag_off = 0;
 	iph->check = 0;
-	if (iph->ihl != 5) {
+	if (ihl > sizeof(*iph)) {
 		u32 dummy;
 		if (ip_clear_mutable_options(iph, &dummy))
 			goto out;
@@ -164,7 +166,7 @@ static int ah_input(struct xfrm_state *x
 		u8 auth_data[MAX_AH_AUTH_LEN];
 		
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
-		skb_push(skb, skb->data - skb->nh.raw);
+		skb_push(skb, ihl);
 		ahp->icv(ahp, skb, ah->auth_data);
 		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
 			x->stats.integrity_failed++;
@@ -172,11 +174,8 @@ static int ah_input(struct xfrm_state *x
 		}
 	}
 	((struct iphdr*)work_buf)->protocol = ah->nexthdr;
-	skb->nh.raw = skb_pull(skb, ah_hlen);
-	memcpy(skb->nh.raw, work_buf, iph->ihl*4);
-	skb->nh.iph->tot_len = htons(skb->len);
-	skb_pull(skb, skb->nh.iph->ihl*4);
-	skb->h.raw = skb->data;
+	skb->h.raw = memcpy(skb->nh.raw += ah_hlen, work_buf, ihl);
+	__skb_pull(skb, ah_hlen + ihl);
 
 	return 0;
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -143,10 +143,9 @@ static int esp_input(struct xfrm_state *
 	int alen = esp->auth.icv_trunc_len;
 	int elen = skb->len - sizeof(struct ip_esp_hdr) - esp->conf.ivlen - alen;
 	int nfrags;
-	int encap_len = 0;
+	int ihl;
 	u8 nexthdr[2];
 	struct scatterlist *sg;
-	u8 workbuf[60];
 	int padlen;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
@@ -177,7 +176,6 @@ static int esp_input(struct xfrm_state *
 	skb->ip_summed = CHECKSUM_NONE;
 
 	esph = (struct ip_esp_hdr*)skb->data;
-	iph = skb->nh.iph;
 
 	/* Get ivec. This can be wrong, check against another impls. */
 	if (esp->conf.ivlen)
@@ -204,12 +202,12 @@ static int esp_input(struct xfrm_state *
 
 	/* ... check padding bits here. Silly. :-) */ 
 
+	iph = skb->nh.iph;
+	ihl = iph->ihl * 4;
+
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
-		struct udphdr *uh;
-
-		uh = (struct udphdr *)(iph + 1);
-		encap_len = (void*)esph - (void*)uh;
+		struct udphdr *uh = (void *)(skb->nh.raw + ihl);
 
 		/*
 		 * 1) if the NAT-T peer's IP or port changed then
@@ -246,11 +244,7 @@ static int esp_input(struct xfrm_state *
 
 	iph->protocol = nexthdr[1];
 	pskb_trim(skb, skb->len - alen - padlen - 2);
-	memcpy(workbuf, skb->nh.raw, iph->ihl*4);
-	skb->h.raw = skb_pull(skb, sizeof(struct ip_esp_hdr) + esp->conf.ivlen);
-	skb->nh.raw += encap_len + sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
-	memcpy(skb->nh.raw, workbuf, iph->ihl*4);
-	skb->nh.iph->tot_len = htons(skb->len);
+	skb->h.raw = __skb_pull(skb, sizeof(*esph) + esp->conf.ivlen) - ihl;
 
 	return 0;
 
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -45,7 +45,6 @@ static LIST_HEAD(ipcomp_tfms_list);
 static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err, plen, dlen;
-	struct iphdr *iph;
 	struct ipcomp_data *ipcd = x->data;
 	u8 *start, *scratch;
 	struct crypto_tfm *tfm;
@@ -74,8 +73,6 @@ static int ipcomp_decompress(struct xfrm
 		
 	skb_put(skb, dlen - plen);
 	memcpy(skb->data, scratch, dlen);
-	iph = skb->nh.iph;
-	iph->tot_len = htons(dlen + iph->ihl * 4);
 out:	
 	put_cpu();
 	return err;
@@ -83,14 +80,9 @@ out:	
 
 static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	u8 nexthdr;
 	int err = 0;
 	struct iphdr *iph;
-	union {
-		struct iphdr	iph;
-		char 		buf[60];
-	} tmp_iph;
-
+	struct ip_comp_hdr *ipch;
 
 	if ((skb_is_nonlinear(skb) || skb_cloned(skb)) &&
 	    skb_linearize(skb, GFP_ATOMIC) != 0) {
@@ -102,15 +94,10 @@ static int ipcomp_input(struct xfrm_stat
 
 	/* Remove ipcomp header and decompress original payload */	
 	iph = skb->nh.iph;
-	memcpy(&tmp_iph, iph, iph->ihl * 4);
-	nexthdr = *(u8 *)skb->data;
-	skb_pull(skb, sizeof(struct ip_comp_hdr));
-	skb->nh.raw += sizeof(struct ip_comp_hdr);
-	memcpy(skb->nh.raw, &tmp_iph, tmp_iph.iph.ihl * 4);
-	iph = skb->nh.iph;
-	iph->tot_len = htons(ntohs(iph->tot_len) - sizeof(struct ip_comp_hdr));
-	iph->protocol = nexthdr;
-	skb->h.raw = skb->data;
+	ipch = (void *)skb->data;
+	iph->protocol = ipch->nexthdr;
+	skb->h.raw = skb->nh.raw + sizeof(*ipch);
+	__skb_pull(skb, sizeof(*ipch));
 	err = ipcomp_decompress(x, skb);
 
 out:	
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -38,8 +38,22 @@ static int xfrm4_transport_output(struct
 	return 0;
 }
 
+/* Remove encapsulation header.
+ *
+ * The IP header will be moved over the top of the encapsulation header.
+ *
+ * On entry, skb->h shall point to where the IP header should be and skb->nh
+ * shall be set to where the IP header currently is.  skb->data shall point
+ * to the start of the payload.
+ */
 static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	int ihl = skb->data - skb->h.raw;
+
+	if (skb->h.raw != skb->nh.raw)
+		skb->nh.raw = memmove(skb->h.raw, skb->nh.raw, ihl);
+	skb->nh.iph->tot_len = htons(skb->len + ihl);
+	skb->h.raw = skb->data;
 	return 0;
 }
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -292,7 +292,7 @@ static int ah6_input(struct xfrm_state *
 
 		memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
 		memset(ah->auth_data, 0, ahp->icv_trunc_len);
-		skb_push(skb, skb->data - skb->nh.raw);
+		skb_push(skb, hdr_len);
 		ahp->icv(ahp, skb, ah->auth_data);
 		if (memcmp(ah->auth_data, auth_data, ahp->icv_trunc_len)) {
 			LIMIT_NETDEBUG(KERN_WARNING "ipsec ah authentication error\n");
@@ -301,12 +301,8 @@ static int ah6_input(struct xfrm_state *
 		}
 	}
 
-	skb->nh.raw = skb_pull(skb, ah_hlen);
-	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-	skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
-	skb_pull(skb, hdr_len);
-	skb->h.raw = skb->data;
-
+	skb->h.raw = memcpy(skb->nh.raw += ah_hlen, tmp_hdr, hdr_len);
+	__skb_pull(skb, ah_hlen + hdr_len);
 
 	kfree(tmp_hdr);
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -142,25 +142,17 @@ static int esp6_input(struct xfrm_state 
 
 	int hdr_len = skb->h.raw - skb->nh.raw;
 	int nfrags;
-	unsigned char *tmp_hdr = NULL;
 	int ret = 0;
 
 	if (!pskb_may_pull(skb, sizeof(struct ipv6_esp_hdr))) {
 		ret = -EINVAL;
-		goto out_nofree;
+		goto out;
 	}
 
 	if (elen <= 0 || (elen & (blksize-1))) {
 		ret = -EINVAL;
-		goto out_nofree;
-	}
-
-	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
-	if (!tmp_hdr) {
-		ret = -ENOMEM;
-		goto out_nofree;
+		goto out;
 	}
-	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
 
 	/* If integrity check is required, do this. */
         if (esp->auth.icv_full_len) {
@@ -222,16 +214,12 @@ static int esp6_input(struct xfrm_state 
 		/* ... check padding bits here. Silly. :-) */ 
 
 		pskb_trim(skb, skb->len - alen - padlen - 2);
-		skb->h.raw = skb_pull(skb, sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen);
-		skb->nh.raw += sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
-		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-		skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 		ret = nexthdr[1];
 	}
 
+	skb->h.raw = __skb_pull(skb, sizeof(*esph) + esp->conf.ivlen) - hdr_len;
+
 out:
-	kfree(tmp_hdr);
-out_nofree:
 	return ret;
 }
 
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -66,10 +66,8 @@ static LIST_HEAD(ipcomp6_tfms_list);
 static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = 0;
-	u8 nexthdr = 0;
-	int hdr_len = skb->h.raw - skb->nh.raw;
-	unsigned char *tmp_hdr = NULL;
 	struct ipv6hdr *iph;
+	struct ipv6_comp_hdr *ipch;
 	int plen, dlen;
 	struct ipcomp_data *ipcd = x->data;
 	u8 *start, *scratch;
@@ -86,17 +84,9 @@ static int ipcomp6_input(struct xfrm_sta
 
 	/* Remove ipcomp header and decompress original payload */
 	iph = skb->nh.ipv6h;
-	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
-	if (!tmp_hdr)
-		goto out;
-	memcpy(tmp_hdr, iph, hdr_len);
-	nexthdr = *(u8 *)skb->data;
-	skb_pull(skb, sizeof(struct ipv6_comp_hdr)); 
-	skb->nh.raw += sizeof(struct ipv6_comp_hdr);
-	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-	iph = skb->nh.ipv6h;
-	iph->payload_len = htons(ntohs(iph->payload_len) - sizeof(struct ipv6_comp_hdr));
-	skb->h.raw = skb->data;
+	ipch = (void *)skb->data;
+	skb->h.raw = skb->nh.raw + sizeof(*ipch);
+	__skb_pull(skb, sizeof(*ipch));
 
 	/* decompression */
 	plen = skb->len;
@@ -125,18 +115,11 @@ static int ipcomp6_input(struct xfrm_sta
 
 	skb_put(skb, dlen - plen);
 	memcpy(skb->data, scratch, dlen);
+	err = ipch->nexthdr;
 
-	iph = skb->nh.ipv6h;
-	iph->payload_len = htons(skb->len);
-	
 out_put_cpu:
 	put_cpu();
 out:
-	kfree(tmp_hdr);
-	if (err)
-		goto error_out;
-	return nexthdr;
-error_out:
 	return err;
 }
 
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -42,8 +42,23 @@ static int xfrm6_transport_output(struct
 	return 0;
 }
 
+/* Remove encapsulation header.
+ *
+ * The IP header will be moved over the top of the encapsulation header.
+ *
+ * On entry, skb->h shall point to where the IP header should be and skb->nh
+ * shall be set to where the IP header currently is.  skb->data shall point
+ * to the start of the payload.
+ */
 static int xfrm6_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	int ihl = skb->data - skb->h.raw;
+
+	if (skb->h.raw != skb->nh.raw)
+		skb->nh.raw = memmove(skb->h.raw, skb->nh.raw, ihl);
+	skb->nh.ipv6h->payload_len = htons(skb->len + ihl -
+					   sizeof(struct ipv6hdr));
+	skb->h.raw = skb->data;
 	return 0;
 }
 

--KDt/GgjP6HVcx58l--
