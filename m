From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH 2.6][IPSEC] conforming to rfc2406
Date: Mon, 5 Apr 2004 15:38:35 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404051538.35608.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I send patches to make 2.6 IPsec conform to rfc2406.
In section 3.4.3, RFC saids

   All ESP implementations MUST support the anti-replay service, though
   its use may be enabled or disabled by the receiver on a per-SA basis.
   This service MUST NOT be enabled unless the authentication service
   also is enabled for the SA, since otherwise the Sequence Number field
   has not been integrity protected.

Original code checks sequence number unless integrity check.

I moved sequence number checking and advancing from xfrm[46]_input.c
to each ah[64].c and esp[64].c.

Best regards,

--Kazunori Miyazawa


===== include/net/xfrm.h 1.54 vs edited =====
--- 1.54/include/net/xfrm.h	Sat Mar 20 12:35:32 2004
+++ edited/include/net/xfrm.h	Mon Apr  5 12:24:10 2004
@@ -869,7 +869,7 @@
 extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard);
 
 extern void xfrm_input_init(void);
-extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 
*seq);
+extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi);
 
 extern void xfrm_probe_algs(void);
 extern int xfrm_count_auth_supported(void);
===== net/ipv4/ah4.c 1.29 vs edited =====
--- 1.29/net/ipv4/ah4.c	Sun Jan 25 03:08:48 2004
+++ edited/net/ipv4/ah4.c	Mon Apr  5 12:11:32 2004
@@ -166,6 +166,8 @@
 		goto out;
 
 	ah = (struct ip_auth_hdr*)skb->data;
+	if (x->props.replay_window && xfrm_replay_check(x, ah->seq_no))
+		goto out;
 	ahp = x->data;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 	
@@ -209,6 +211,8 @@
 			goto out;
 		}
 	}
+	if (x->props.replay_window)
+		xfrm_replay_advance(x, ah->seq_no);
 	((struct iphdr*)work_buf)->protocol = ah->nexthdr;
 	skb->nh.raw = skb_pull(skb, ah_hlen);
 	memcpy(skb->nh.raw, work_buf, iph->ihl*4);
===== net/ipv4/esp4.c 1.36 vs edited =====
--- 1.36/net/ipv4/esp4.c	Wed Mar 10 08:21:50 2004
+++ edited/net/ipv4/esp4.c	Mon Apr  5 12:14:10 2004
@@ -227,6 +227,7 @@
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
 		goto out;
+	esph = (struct ip_esp_hdr*)skb->data;
 
 	if (elen <= 0 || (elen & (blksize-1)))
 		goto out;
@@ -236,6 +237,8 @@
 		u8 sum[esp->auth.icv_full_len];
 		u8 sum1[alen];
 		
+		if (x->props.replay_window && xfrm_replay_check(x, esp->seq_no))
+			goto out;
 		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
 
 		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
@@ -245,6 +248,9 @@
 			x->stats.integrity_failed++;
 			goto out;
 		}
+
+		if (x->props.replay_winodw)
+			xfrm_replay_advance(x, esph->seq_no);
 	}
 
 	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0)
@@ -252,7 +258,6 @@
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	esph = (struct ip_esp_hdr*)skb->data;
 	iph = skb->nh.iph;
 
 	/* Get ivec. This can be wrong, check against another impls. */
===== net/ipv4/xfrm4_input.c 1.10 vs edited =====
--- 1.10/net/ipv4/xfrm4_input.c	Sat Feb 14 16:06:45 2004
+++ edited/net/ipv4/xfrm4_input.c	Mon Apr  5 12:15:31 2004
@@ -29,30 +29,29 @@
 		IP_ECN_set_ce(inner_iph);
 }
 
-static int xfrm4_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 
*seq)
+static int xfrm4_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi)
 {
 	switch (nexthdr) {
 	case IPPROTO_IPIP:
 		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 			return -EINVAL;
 		*spi = skb->nh.iph->saddr;
-		*seq = 0;
 		return 0;
 	}
 
-	return xfrm_parse_spi(skb, nexthdr, spi, seq);
+	return xfrm_parse_spi(skb, nexthdr, spi);
 }
 
 int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 {
 	int err;
-	u32 spi, seq;
+	u32 spi;
 	struct sec_decap_state xfrm_vec[XFRM_MAX_DEPTH];
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
 	int decaps = 0;
 
-	if ((err = xfrm4_parse_spi(skb, skb->nh.iph->protocol, &spi, &seq)) != 0)
+	if ((err = xfrm4_parse_spi(skb, skb->nh.iph->protocol, &spi)) != 0)
 		goto drop;
 
 	do {
@@ -69,9 +68,6 @@
 		if (unlikely(x->km.state != XFRM_STATE_VALID))
 			goto drop_unlock;
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
-			goto drop_unlock;
-
 		if (xfrm_state_check_expire(x))
 			goto drop_unlock;
 
@@ -82,9 +78,6 @@
 		/* only the first xfrm gets the encap type */
 		encap_type = 0;
 
-		if (x->props.replay_window)
-			xfrm_replay_advance(x, seq);
-
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 
@@ -112,7 +105,7 @@
 			break;
 		}
 
-		if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi, &seq)) < 0)
+		if ((err = xfrm_parse_spi(skb, skb->nh.iph->protocol, &spi)) < 0)
 			goto drop;
 	} while (!err);
 
===== net/ipv6/ah6.c 1.26 vs edited =====
--- 1.26/net/ipv6/ah6.c	Sun Jan 25 03:08:48 2004
+++ edited/net/ipv6/ah6.c	Mon Apr  5 12:21:22 2004
@@ -286,6 +286,8 @@
 	hdr_len = skb->data - skb->nh.raw;
 	cleared_hlen = hdr_len;
 	ah = (struct ipv6_auth_hdr*)skb->data;
+	if (x->props.replay_window && xfrm_replay_check(x, ah->seq_no))
+		goto out;
 	ahp = x->data;
 	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
@@ -329,6 +331,8 @@
 		}
 	}
 
+	if (x->props.replay_window)
+		xfrm_replay_advance(x, ah->seq_no);
 	skb->nh.raw = skb_pull(skb, ah_hlen);
 	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 	if (nexthdr == NEXTHDR_DEST) {
===== net/ipv6/esp6.c 1.24 vs edited =====
--- 1.24/net/ipv6/esp6.c	Wed Mar 10 08:21:50 2004
+++ edited/net/ipv6/esp6.c	Mon Apr  5 12:22:39 2004
@@ -210,6 +210,7 @@
 		ret = -EINVAL;
 		goto out_nofree;
 	}
+	esph = (struct ipv6_esp_hdr*)skb->data;
 
 	if (elen <= 0 || (elen & (blksize-1))) {
 		ret = -EINVAL;
@@ -228,6 +229,10 @@
 		u8 sum[esp->auth.icv_full_len];
 		u8 sum1[alen];
 
+		if (x->props.replay_window && xfrm_replay_check(x, esph->seq_no)) {
+			ret = -EINVAL;
+			goto out;
+		}
 		esp->auth.icv(esp, skb, 0, skb->len-alen, sum);
 
 		if (skb_copy_bits(skb, skb->len-alen, sum1, alen))
@@ -238,6 +243,9 @@
 			ret = -EINVAL;
 			goto out;
 		}
+
+		if (x->props.replay_window)
+			xfrm_replay_advance(x, esph->seq_no);
 	}
 
 	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0) {
@@ -247,7 +255,6 @@
 
 	skb->ip_summed = CHECKSUM_NONE;
 
-	esph = (struct ipv6_esp_hdr*)skb->data;
 	iph = skb->nh.ipv6h;
 
 	/* Get ivec. This can be wrong, check against another impls. */
===== net/ipv6/xfrm6_input.c 1.15 vs edited =====
--- 1.15/net/ipv6/xfrm6_input.c	Sat Feb 14 16:06:45 2004
+++ edited/net/ipv6/xfrm6_input.c	Mon Apr  5 12:23:15 2004
@@ -29,7 +29,7 @@
 {
 	struct sk_buff *skb = *pskb;
 	int err;
-	u32 spi, seq;
+	u32 spi;
 	struct sec_decap_state xfrm_vec[XFRM_MAX_DEPTH];
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
@@ -41,7 +41,7 @@
 	nexthdr = *prevhdr;
 	*nhoffp = prevhdr - skb->nh.raw;
 
-	if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
+	if ((err = xfrm_parse_spi(skb, nexthdr, &spi)) != 0)
 		goto drop;
 	
 	do {
@@ -57,9 +57,6 @@
 		if (unlikely(x->km.state != XFRM_STATE_VALID))
 			goto drop_unlock;
 
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
-			goto drop_unlock;
-
 		if (xfrm_state_check_expire(x))
 			goto drop_unlock;
 
@@ -67,9 +64,6 @@
 		if (nexthdr <= 0)
 			goto drop_unlock;
 
-		if (x->props.replay_window)
-			xfrm_replay_advance(x, seq);
-
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 
@@ -94,7 +88,7 @@
 			break;
 		}
 
-		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) < 0)
+		if ((err = xfrm_parse_spi(skb, nexthdr, &spi)) < 0)
 			goto drop;
 	} while (!err);
 
===== net/xfrm/xfrm_input.c 1.13 vs edited =====
--- 1.13/net/xfrm/xfrm_input.c	Mon Jul 28 11:22:27 2003
+++ edited/net/xfrm/xfrm_input.c	Mon Apr  5 12:20:23 2004
@@ -43,24 +43,21 @@
 
 /* Fetch spi and seq from ipsec header */
 
-int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 *seq)
+int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi)
 {
-	int offset, offset_seq;
+	int offset;
 
 	switch (nexthdr) {
 	case IPPROTO_AH:
 		offset = offsetof(struct ip_auth_hdr, spi);
-		offset_seq = offsetof(struct ip_auth_hdr, seq_no);
 		break;
 	case IPPROTO_ESP:
 		offset = offsetof(struct ip_esp_hdr, spi);
-		offset_seq = offsetof(struct ip_esp_hdr, seq_no);
 		break;
 	case IPPROTO_COMP:
 		if (!pskb_may_pull(skb, sizeof(struct ip_comp_hdr)))
 			return -EINVAL;
 		*spi = ntohl(ntohs(*(u16*)(skb->h.raw + 2)));
-		*seq = 0;
 		return 0;
 	default:
 		return 1;
@@ -70,7 +67,6 @@
 		return -EINVAL;
 
 	*spi = *(u32*)(skb->h.raw + offset);
-	*seq = *(u32*)(skb->h.raw + offset_seq);
 	return 0;
 }
 
