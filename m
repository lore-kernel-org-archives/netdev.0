From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] IPSec: IPv6 AH/ESP fixes
Date: 28 Mar 2003 10:54:16 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048870457.16800.5.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Below is a patch for your consideration for some AH/ESP problems
that I encountered during tunnel mode testings.

Please review and let me know if any changes are required.

Thanks,
Tom

diff -ur linux-2.5.66-orig/net/ipv6/ah6.c linux-2.5.66/net/ipv6/ah6.c
--- linux-2.5.66-orig/net/ipv6/ah6.c	2003-03-27 16:20:40.000000000 -0600
+++ linux-2.5.66/net/ipv6/ah6.c	2003-03-27 14:42:29.000000000 -0600
@@ -199,7 +199,7 @@
 		}
 	}
 
-	nexthdr = ah->nexthdr;
+	nexthdr = ((struct ipv6hdr*)tmp_hdr)->nexthdr = ah->nexthdr;
 	skb->nh.raw = skb_pull(skb, (ah->hdrlen+2)<<2);
 	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 	skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
@@ -287,7 +287,7 @@
 	
 	x->props.header_len = XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV);
 	if (x->props.mode)
-		x->props.header_len += 20;
+		x->props.header_len += 40;
 	x->data = ahp;
 
 	return 0;
diff -ur linux-2.5.66-orig/net/ipv6/esp6.c linux-2.5.66/net/ipv6/esp6.c
--- linux-2.5.66-orig/net/ipv6/esp6.c	2003-03-27 16:21:05.000000000 -0600
+++ linux-2.5.66/net/ipv6/esp6.c	2003-03-27 14:42:29.000000000 -0600
@@ -108,7 +108,7 @@
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x  = dst->xfrm;
 	struct ipv6hdr *iph = NULL, *top_iph;
-	struct ip_esp_hdr *esph;
+	struct ipv6_esp_hdr *esph;
 	struct crypto_tfm *tfm;
 	struct esp_data *esp;
 	struct sk_buff *trailer;
@@ -154,7 +154,7 @@
 	esp = x->data;
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
-	blksize = crypto_tfm_alg_blocksize(tfm);
+	blksize = (crypto_tfm_alg_blocksize(tfm) + 3) & ~3;
 	clen = (clen + 2 + blksize-1)&~(blksize-1);
 	if (esp->conf.padlen)
 		clen = (clen + esp->conf.padlen-1)&~(esp->conf.padlen-1);
@@ -176,7 +176,7 @@
 	if (x->props.mode) {
 		iph = skb->nh.ipv6h;
 		top_iph = (struct ipv6hdr*)skb_push(skb, x->props.header_len);
-		esph = (struct ip_esp_hdr*)(top_iph+1);
+		esph = (struct ipv6_esp_hdr*)(top_iph+1);
 		*(u8*)(trailer->tail - 1) = IPPROTO_IPV6;
 		top_iph->version = 6;
 		top_iph->priority = iph->priority;
@@ -184,13 +184,13 @@
 		top_iph->flow_lbl[1] = iph->flow_lbl[1];
 		top_iph->flow_lbl[2] = iph->flow_lbl[2];
 		top_iph->nexthdr = IPPROTO_ESP;
-		top_iph->payload_len = htons(skb->len + alen);
+		top_iph->payload_len = htons(skb->len + alen - sizeof(struct ipv6hdr));
 		top_iph->hop_limit = iph->hop_limit;
-		memcpy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr, sizeof(struct ipv6hdr));
-		memcpy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr, sizeof(struct ipv6hdr));
+		memcpy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr, sizeof(struct in6_addr));
+		memcpy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr, sizeof(struct in6_addr));
 	} else { 
 		/* XXX exthdr */
-		esph = (struct ip_esp_hdr*)skb_push(skb, x->props.header_len);
+		esph = (struct ipv6_esp_hdr*)skb_push(skb, x->props.header_len);
 		skb->h.raw = (unsigned char*)esph;
 		top_iph = (struct ipv6hdr*)skb_push(skb, hdr_len);
 		memcpy(top_iph, iph, hdr_len);
@@ -257,7 +257,7 @@
 int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *iph;
-	struct ip_esp_hdr *esph;
+	struct ipv6_esp_hdr *esph;
 	struct esp_data *esp = x->data;
 	struct sk_buff *trailer;
 	int blksize = crypto_tfm_alg_blocksize(esp->conf.tfm);
@@ -269,7 +269,7 @@
 	u8 ret_nexthdr = 0;
 	unsigned char *tmp_hdr = NULL;
 
-	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
+	if (!pskb_may_pull(skb, sizeof(struct ipv6_esp_hdr)))
 		goto out;
 
 	if (elen <= 0 || (elen & (blksize-1)))
@@ -301,7 +301,7 @@
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	esph = (struct ip_esp_hdr*)skb->data;
+	esph = (struct ipv6_esp_hdr*)skb->data;
 	iph = skb->nh.ipv6h;
 
 	/* Get ivec. This can be wrong, check against another impls. */
@@ -336,7 +336,7 @@
 		}
 		/* ... check padding bits here. Silly. :-) */ 
 
-		ret_nexthdr = nexthdr[1];
+		ret_nexthdr = ((struct ipv6hdr*)tmp_hdr)->nexthdr = nexthdr[1];
 		pskb_trim(skb, skb->len - alen - padlen - 2);
 		skb->h.raw = skb_pull(skb, 8 + esp->conf.ivlen);
 		skb->nh.raw += 8 + esp->conf.ivlen;
@@ -370,7 +370,7 @@
 		int type, int code, int offset, __u32 info)
 {
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
-	struct ip_esp_hdr *esph = (struct ip_esp_hdr*)(skb->data+offset);
+	struct ipv6_esp_hdr *esph = (struct ipv6_esp_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_DEST_UNREACH ||
@@ -416,7 +416,7 @@
 		if (x->aalg->alg_key_len == 0 || x->aalg->alg_key_len > 512)
 			goto error;
 	}
-	if (x->ealg == NULL || x->ealg->alg_key_len == 0)
+	if (x->ealg == NULL)
 		goto error;
 
 	esp = kmalloc(sizeof(*esp), GFP_KERNEL);
diff -ur linux-2.5.66-orig/net/ipv6/xfrm6_input.c linux-2.5.66/net/ipv6/xfrm6_input.c
--- linux-2.5.66-orig/net/ipv6/xfrm6_input.c	2003-03-27 16:08:24.000000000 -0600
+++ linux-2.5.66/net/ipv6/xfrm6_input.c	2003-03-27 13:37:54.000000000 -0600
@@ -186,6 +186,8 @@
 
 		xfrm_vec[xfrm_nr++] = x;
 
+		iph = skb->nh.ipv6h;
+
 		if (x->props.mode) { /* XXX */
 			if (iph->nexthdr != IPPROTO_IPV6)
 				goto drop;
@@ -199,9 +201,11 @@
 			goto drop;
 	} while (!err);
 
-	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-	skb->nh.raw[nh_offset] = nexthdr;
-	skb->nh.ipv6h->payload_len = htons(hdr_len + skb->len - sizeof(struct ipv6hdr));
+	if (!decaps) {
+		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
+		skb->nh.raw[nh_offset] = nexthdr;
+		skb->nh.ipv6h->payload_len = htons(hdr_len + skb->len - sizeof(struct ipv6hdr));
+	}
 
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
