From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [AH6] Disallow mutable bits after AH header
Date: Fri, 23 Jul 2004 23:53:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723135320.GA26000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

As we discussed before, mutable headers should not be allowed after
the AH header.  In fact, this appears to be the intention of RFC 2402.
It is further clarified in section 3.1.1 of

http://www.ietf.org/internet-drafts/draft-ietf-ipsec-rfc2402bis-07.txt

This allows us to simplify the code in ah6.c.  As a result, this also
fixes the following issues:

* Dependence on skb->h in ah6_output().
* Bogus clearing of auth_data of 2nd AH header in ipv6_clear_mutable_options().

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/ah6.c 1.32 vs edited =====
--- 1.32/net/ipv6/ah6.c	2004-06-18 16:20:58 +10:00
+++ edited/net/ipv6/ah6.c	2004-07-23 23:44:50 +10:00
@@ -74,34 +74,29 @@
 	return 0;
 }
 
-static int ipv6_clear_mutable_options(struct sk_buff *skb, u16 *nh_offset, int dir)
+static int ipv6_clear_mutable_options(struct sk_buff *skb,
+				      unsigned int hdr_len)
 {
 	u16 offset = sizeof(struct ipv6hdr);
 	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-	unsigned int packet_len = skb->tail - skb->nh.raw;
 	u8 nexthdr = skb->nh.ipv6h->nexthdr;
-	u8 nextnexthdr = 0;
 
-	*nh_offset = ((unsigned char *)&skb->nh.ipv6h->nexthdr) - skb->nh.raw;
-
-	while (offset + 1 <= packet_len) {
+	while (offset + 1 <= hdr_len) {
 
 		switch (nexthdr) {
 
 		case NEXTHDR_HOP:
-			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			if (!zero_out_mutable_opts(exthdr)) {
 				LIMIT_NETDEBUG(
 				printk(KERN_WARNING "overrun hopopts\n")); 
-				return 0;
+				return -EINVAL;
 			}
 			nexthdr = exthdr->nexthdr;
 			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
 			break;
 
 		case NEXTHDR_ROUTING:
-			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			((struct ipv6_rt_hdr*)exthdr)->segments_left = 0; 
 			nexthdr = exthdr->nexthdr;
@@ -109,39 +104,22 @@
 			break;
 
 		case NEXTHDR_DEST:
-			*nh_offset = offset;
 			offset += ipv6_optlen(exthdr);
 			if (!zero_out_mutable_opts(exthdr))  {
 				LIMIT_NETDEBUG(
 					printk(KERN_WARNING "overrun destopt\n")); 
-				return 0;
+				return -EINVAL;
 			}
 			nexthdr = exthdr->nexthdr;
 			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
 			break;
 
-		case NEXTHDR_AUTH:
-			if (dir == XFRM_POLICY_OUT) {
-				memset(((struct ipv6_auth_hdr*)exthdr)->auth_data, 0, 
-				       (((struct ipv6_auth_hdr*)exthdr)->hdrlen - 1) << 2);
-			}
-			if (exthdr->nexthdr == NEXTHDR_DEST) {
-				offset += (((struct ipv6_auth_hdr*)exthdr)->hdrlen + 2) << 2;
-				exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-				nextnexthdr = exthdr->nexthdr;
-				if (!zero_out_mutable_opts(exthdr)) {
-					LIMIT_NETDEBUG(
-						printk(KERN_WARNING "overrun destopt\n"));
-					return 0;
-				}
-			}
-			return nexthdr;
 		default :
-			return nexthdr;
+			return 0;
 		}
 	}
 
-	return nexthdr;
+	return 0;
 }
 
 int ah6_output(struct sk_buff **pskb)
@@ -153,7 +131,6 @@
 	struct ipv6hdr *iph = NULL;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
-	u16 nh_offset = 0;
 	u8 nexthdr;
 
 	if ((*pskb)->ip_summed == CHECKSUM_HW) {
@@ -184,7 +161,11 @@
 		ah = (struct ip_auth_hdr*)((*pskb)->nh.ipv6h+1);
 		ah->nexthdr = IPPROTO_IPV6;
 	} else {
-		hdr_len = (*pskb)->h.raw - (*pskb)->nh.raw;
+		u8 *prevhdr;
+
+		hdr_len = ip6_find_1stfragopt(*pskb, &prevhdr);
+		nexthdr = *prevhdr;
+		*prevhdr = IPPROTO_AH;
 		iph = kmalloc(hdr_len, GFP_ATOMIC);
 		if (!iph) {
 			err = -ENOMEM;
@@ -192,13 +173,12 @@
 		}
 		memcpy(iph, (*pskb)->data, hdr_len);
 		(*pskb)->nh.ipv6h = (struct ipv6hdr*)skb_push(*pskb, x->props.header_len);
+		iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
 		memcpy((*pskb)->nh.ipv6h, iph, hdr_len);
-		nexthdr = ipv6_clear_mutable_options(*pskb, &nh_offset, XFRM_POLICY_OUT);
-		if (nexthdr == 0)
+		err = ipv6_clear_mutable_options(*pskb, hdr_len);
+		if (err)
 			goto error_free_iph;
 
-		(*pskb)->nh.raw[nh_offset] = IPPROTO_AH;
-		(*pskb)->nh.ipv6h->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
 		ah = (struct ip_auth_hdr*)((*pskb)->nh.raw+hdr_len);
 		(*pskb)->h.raw = (unsigned char*) ah;
 		ah->nexthdr = nexthdr;
@@ -229,8 +209,6 @@
 			IP6_ECN_clear((*pskb)->nh.ipv6h);
 	} else {
 		memcpy((*pskb)->nh.ipv6h, iph, hdr_len);
-		(*pskb)->nh.raw[nh_offset] = IPPROTO_AH;
-		(*pskb)->nh.ipv6h->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
 		kfree (iph);
 	}
 
@@ -259,7 +237,6 @@
 	 * Before process AH
 	 * [IPv6][Ext1][Ext2][AH][Dest][Payload]
 	 * |<-------------->| hdr_len
-	 * |<------------------------>| cleared_hlen
 	 *
 	 * To erase AH:
 	 * Keeping copy of cleared headers. After AH processing,
@@ -276,7 +253,6 @@
 	unsigned char *tmp_hdr = NULL;
 	u16 hdr_len;
 	u16 ah_hlen;
-	u16 cleared_hlen;
 	u16 nh_offset = 0;
 	u8 nexthdr = 0;
 	u8 *prevhdr;
@@ -291,17 +267,10 @@
 		goto out;
 
 	hdr_len = skb->data - skb->nh.raw;
-	cleared_hlen = hdr_len;
 	ah = (struct ipv6_auth_hdr*)skb->data;
 	ahp = x->data;
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
-	cleared_hlen += ah_hlen;
-
-	if (nexthdr == NEXTHDR_DEST) {
-		struct ipv6_opt_hdr *dsthdr = (struct ipv6_opt_hdr*)(skb->data + ah_hlen);
-		cleared_hlen += ipv6_optlen(dsthdr);
-	}
 
         if (ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_full_len) &&
             ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len))
@@ -310,11 +279,12 @@
 	if (!pskb_may_pull(skb, ah_hlen))
 		goto out;
 
-	tmp_hdr = kmalloc(cleared_hlen, GFP_ATOMIC);
+	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
 	if (!tmp_hdr)
 		goto out;
-	memcpy(tmp_hdr, skb->nh.raw, cleared_hlen);
-	ipv6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_IN);
+	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
+	if (ipv6_clear_mutable_options(skb, hdr_len))
+		goto out;
 	skb->nh.ipv6h->priority    = 0;
 	skb->nh.ipv6h->flow_lbl[0] = 0;
 	skb->nh.ipv6h->flow_lbl[1] = 0;
@@ -338,11 +308,6 @@
 
 	skb->nh.raw = skb_pull(skb, ah_hlen);
 	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-	if (nexthdr == NEXTHDR_DEST) {
-		memcpy(skb->nh.raw + hdr_len,
-		       tmp_hdr + hdr_len + ah_hlen,
-		       cleared_hlen - hdr_len - ah_hlen);
-	}
 	prevhdr = (u8*)(skb->nh.raw + nh_offset);
 	*prevhdr = nexthdr;
 	skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));

--ibTvN161/egqYuK8--
