From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPV6] fix ipv6 header handling of AH input.
Date: Sun, 15 Jun 2003 22:06:32 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615220632.0701a5cd.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch fixes ipv6 header handling of ah input and moves
the routine to clear mutable options.
It reduces unnecessary header clearing when a packet has only ESP.

This patch for linux-2.5.70 + CS1.1307

Best regards,

--Kazunori Miyazawa (Yokogawa Electric Corporation)

Index: linux25/include/net/xfrm.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/net/xfrm.h,v
retrieving revision 1.1.1.25
retrieving revision 1.1.1.25.4.1
diff -u -r1.1.1.25 -r1.1.1.25.4.1
--- linux25/include/net/xfrm.h	10 Jun 2003 13:21:39 -0000	1.1.1.25
+++ linux25/include/net/xfrm.h	13 Jun 2003 14:43:37 -0000	1.1.1.25.4.1
@@ -782,7 +782,6 @@
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_check_size(struct sk_buff *skb);
 extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
-extern int xfrm6_clear_mutable_options(struct sk_buff *skb, u16 *nh_offset, int dir);
 extern int xfrm_user_policy(struct sock *sk, int optname, u8 *optval, int optlen);
 
 void xfrm_policy_init(void);
Index: linux25/net/ipv6/ah6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ah6.c,v
retrieving revision 1.1.1.13
retrieving revision 1.1.1.13.16.2
diff -u -r1.1.1.13 -r1.1.1.13.16.2
--- linux25/net/ipv6/ah6.c	26 May 2003 08:04:11 -0000	1.1.1.13
+++ linux25/net/ipv6/ah6.c	15 Jun 2003 12:18:24 -0000	1.1.1.13.16.2
@@ -36,6 +36,114 @@
 #include <net/xfrm.h>
 #include <asm/scatterlist.h>
 
+static int zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
+{
+	u8 *opt = (u8 *)opthdr;
+	int len = ipv6_optlen(opthdr);
+	int off = 0;
+	int optlen = 0;
+
+	off += 2;
+	len -= 2;
+
+	while (len > 0) {
+
+		switch (opt[off]) {
+
+		case IPV6_TLV_PAD0:
+			optlen = 1;
+			break;
+		default:
+			if (len < 2) 
+				goto bad;
+			optlen = opt[off+1]+2;
+			if (len < optlen)
+				goto bad;
+			if (opt[off] & 0x20)
+				memset(&opt[off+2], 0, opt[off+1]);
+			break;
+		}
+
+		off += optlen;
+		len -= optlen;
+	}
+	if (len == 0)
+		return 1;
+
+bad:
+	return 0;
+}
+
+static int ipv6_clear_mutable_options(struct sk_buff *skb, u16 *nh_offset, int dir)
+{
+	u16 offset = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+	unsigned int packet_len = skb->tail - skb->nh.raw;
+	u8 nexthdr = skb->nh.ipv6h->nexthdr;
+	u8 nextnexthdr = 0;
+
+	*nh_offset = ((unsigned char *)&skb->nh.ipv6h->nexthdr) - skb->nh.raw;
+
+	while (offset + 1 <= packet_len) {
+
+		switch (nexthdr) {
+
+		case NEXTHDR_HOP:
+			*nh_offset = offset;
+			offset += ipv6_optlen(exthdr);
+			if (!zero_out_mutable_opts(exthdr)) {
+				if (net_ratelimit())
+					printk(KERN_WARNING "overrun hopopts\n"); 
+				return 0;
+			}
+			nexthdr = exthdr->nexthdr;
+			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+			break;
+
+		case NEXTHDR_ROUTING:
+			*nh_offset = offset;
+			offset += ipv6_optlen(exthdr);
+			((struct ipv6_rt_hdr*)exthdr)->segments_left = 0; 
+			nexthdr = exthdr->nexthdr;
+			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+			break;
+
+		case NEXTHDR_DEST:
+			*nh_offset = offset;
+			offset += ipv6_optlen(exthdr);
+			if (!zero_out_mutable_opts(exthdr))  {
+				if (net_ratelimit())
+					printk(KERN_WARNING "overrun destopt\n"); 
+				return 0;
+			}
+			nexthdr = exthdr->nexthdr;
+			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+			break;
+
+		case NEXTHDR_AUTH:
+			if (dir == XFRM_POLICY_OUT) {
+				memset(((struct ipv6_auth_hdr*)exthdr)->auth_data, 0, 
+				       (((struct ipv6_auth_hdr*)exthdr)->hdrlen - 1) << 2);
+			}
+			if (exthdr->nexthdr == NEXTHDR_DEST) {
+				offset += (((struct ipv6_auth_hdr*)exthdr)->hdrlen + 2) << 2;
+				exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+				nextnexthdr = exthdr->nexthdr;
+				if (!zero_out_mutable_opts(exthdr)) {
+					if (net_ratelimit())
+						printk(KERN_WARNING "overrun destopt\n");
+					return 0;
+				}
+			}
+			return nexthdr;
+		default :
+			return nexthdr;
+		}
+	}
+
+	return nexthdr;
+}
+
 int ah6_output(struct sk_buff *skb)
 {
 	int err;
@@ -80,7 +188,7 @@
 		memcpy(iph, skb->data, hdr_len);
 		skb->nh.ipv6h = (struct ipv6hdr*)skb_push(skb, x->props.header_len);
 		memcpy(skb->nh.ipv6h, iph, hdr_len);
-		nexthdr = xfrm6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_OUT);
+		nexthdr = ipv6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_OUT);
 		if (nexthdr == 0)
 			goto error;
 
@@ -138,20 +246,46 @@
 
 int ah6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
-	int ah_hlen;
-	struct ipv6hdr *iph;
+	/*
+	 * Before process AH
+	 * [IPv6][Ext1][Ext2][AH][Dest][Payload]
+	 * |<-------------->| hdr_len
+	 * |<------------------------>| cleared_hlen
+	 *
+	 * To erase AH:
+	 * Keeping copy of cleared headers. After AH processing,
+	 * Moving the pointer of skb->nh.raw by using skb_pull as long as AH
+	 * header length. Then copy back the copy as long as hdr_len
+	 * If destination header following AH exists, copy it into after [Ext2].
+	 * 
+	 * |<>|[IPv6][Ext1][Ext2][Dest][Payload]
+	 * There is offset of AH before IPv6 header after the process.
+	 */
+
+	struct ipv6hdr *iph = skb->nh.ipv6h;
 	struct ipv6_auth_hdr *ah;
 	struct ah_data *ahp;
 	unsigned char *tmp_hdr = NULL;
-	int hdr_len = skb->h.raw - skb->nh.raw;
+	u16 hdr_len = skb->data - skb->nh.raw;
+	u16 ah_hlen;
+	u16 cleared_hlen = hdr_len;
+	u16 nh_offset = 0;
 	u8 nexthdr = 0;
+	u8 *prevhdr;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
 
 	ah = (struct ipv6_auth_hdr*)skb->data;
 	ahp = x->data;
-        ah_hlen = (ah->hdrlen + 2) << 2;
+	nexthdr = ah->nexthdr;
+	ah_hlen = (ah->hdrlen + 2) << 2;
+	cleared_hlen += ah_hlen;
+
+	if (nexthdr == NEXTHDR_DEST) {
+		struct ipv6_opt_hdr *dsthdr = (struct ipv6_opt_hdr*)(skb->data + ah_hlen);
+		cleared_hlen += ipv6_optlen(dsthdr);
+	}
 
         if (ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_full_len) &&
             ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len))
@@ -166,12 +300,16 @@
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		goto out;
 
-	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
+	tmp_hdr = kmalloc(cleared_hlen, GFP_ATOMIC);
 	if (!tmp_hdr)
 		goto out;
-	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
-	ah = (struct ipv6_auth_hdr*)skb->data;
-	iph = skb->nh.ipv6h;
+	memcpy(tmp_hdr, skb->nh.raw, cleared_hlen);
+	ipv6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_IN);
+	iph->priority    = 0;
+	iph->flow_lbl[0] = 0;
+	iph->flow_lbl[1] = 0;
+	iph->flow_lbl[2] = 0;
+	iph->hop_limit   = 0;
 
         {
 		u8 auth_data[ahp->icv_trunc_len];
@@ -187,9 +325,15 @@
 		}
 	}
 
-	nexthdr = ((struct ipv6hdr*)tmp_hdr)->nexthdr = ah->nexthdr;
-	skb->nh.raw = skb_pull(skb, (ah->hdrlen+2)<<2);
+	skb->nh.raw = skb_pull(skb, ah_hlen);
 	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
+	if (nexthdr == NEXTHDR_DEST) {
+		memcpy(skb->nh.raw + hdr_len,
+		       tmp_hdr + hdr_len + ah_hlen,
+		       cleared_hlen - hdr_len - ah_hlen);
+	}
+	prevhdr = (u8*)(skb->nh.raw + nh_offset);
+	*prevhdr = nexthdr;
 	skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	skb_pull(skb, hdr_len);
 	skb->h.raw = skb->data;
Index: linux25/net/ipv6/ipv6_syms.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ipv6_syms.c,v
retrieving revision 1.1.1.13
retrieving revision 1.1.1.13.4.1
diff -u -r1.1.1.13 -r1.1.1.13.4.1
--- linux25/net/ipv6/ipv6_syms.c	10 Jun 2003 13:21:55 -0000	1.1.1.13
+++ linux25/net/ipv6/ipv6_syms.c	13 Jun 2003 14:43:37 -0000	1.1.1.13.4.1
@@ -37,7 +37,6 @@
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 EXPORT_SYMBOL(ip6_find_1stfragopt);
 EXPORT_SYMBOL(xfrm6_rcv);
-EXPORT_SYMBOL(xfrm6_clear_mutable_options);
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(fl6_sock_lookup);
 EXPORT_SYMBOL(ipv6_ext_hdr);
Index: linux25/net/ipv6/xfrm6_input.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/xfrm6_input.c,v
retrieving revision 1.1.1.7
retrieving revision 1.1.1.7.22.1
diff -u -r1.1.1.7 -r1.1.1.7.22.1
--- linux25/net/ipv6/xfrm6_input.c	6 May 2003 12:43:55 -0000	1.1.1.7
+++ linux25/net/ipv6/xfrm6_input.c	13 Jun 2003 14:43:37 -0000	1.1.1.7.22.1
@@ -15,114 +15,6 @@
 
 static kmem_cache_t *secpath_cachep;
 
-static int zero_out_mutable_opts(struct ipv6_opt_hdr *opthdr)
-{
-	u8 *opt = (u8 *)opthdr;
-	int len = ipv6_optlen(opthdr);
-	int off = 0;
-	int optlen = 0;
-
-	off += 2;
-	len -= 2;
-
-	while (len > 0) {
-
-		switch (opt[off]) {
-
-		case IPV6_TLV_PAD0:
-			optlen = 1;
-			break;
-		default:
-			if (len < 2) 
-				goto bad;
-			optlen = opt[off+1]+2;
-			if (len < optlen)
-				goto bad;
-			if (opt[off] & 0x20)
-				memset(&opt[off+2], 0, opt[off+1]);
-			break;
-		}
-
-		off += optlen;
-		len -= optlen;
-	}
-	if (len == 0)
-		return 1;
-
-bad:
-	return 0;
-}
-
-int xfrm6_clear_mutable_options(struct sk_buff *skb, u16 *nh_offset, int dir)
-{
-	u16 offset = sizeof(struct ipv6hdr);
-	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-	unsigned int packet_len = skb->tail - skb->nh.raw;
-	u8 nexthdr = skb->nh.ipv6h->nexthdr;
-	u8 nextnexthdr = 0;
-
-	*nh_offset = ((unsigned char *)&skb->nh.ipv6h->nexthdr) - skb->nh.raw;
-
-	while (offset + 1 <= packet_len) {
-
-		switch (nexthdr) {
-
-		case NEXTHDR_HOP:
-			*nh_offset = offset;
-			offset += ipv6_optlen(exthdr);
-			if (!zero_out_mutable_opts(exthdr)) {
-				if (net_ratelimit())
-					printk(KERN_WARNING "overrun hopopts\n"); 
-				return 0;
-			}
-			nexthdr = exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-			break;
-
-		case NEXTHDR_ROUTING:
-			*nh_offset = offset;
-			offset += ipv6_optlen(exthdr);
-			((struct ipv6_rt_hdr*)exthdr)->segments_left = 0; 
-			nexthdr = exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-			break;
-
-		case NEXTHDR_DEST:
-			*nh_offset = offset;
-			offset += ipv6_optlen(exthdr);
-			if (!zero_out_mutable_opts(exthdr))  {
-				if (net_ratelimit())
-					printk(KERN_WARNING "overrun destopt\n"); 
-				return 0;
-			}
-			nexthdr = exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-			break;
-
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
-					if (net_ratelimit())
-						printk(KERN_WARNING "overrun destopt\n");
-					return 0;
-				}
-			}
-			return nexthdr;
-		default :
-			return nexthdr;
-		}
-	}
-
-	return nexthdr;
-}
-
 int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
 {
 	struct sk_buff *skb = *pskb;
@@ -132,26 +24,12 @@
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
 	int decaps = 0;
-	struct ipv6hdr *hdr = skb->nh.ipv6h;
-	unsigned char *tmp_hdr = NULL;
-	int hdr_len = 0;
-	u16 nh_offset = 0;
 	int nexthdr = 0;
+	u8 *prevhdr = NULL;
 
-	nh_offset = ((unsigned char*)&skb->nh.ipv6h->nexthdr) - skb->nh.raw;
-	hdr_len = sizeof(struct ipv6hdr);
-
-	tmp_hdr = kmalloc(hdr_len, GFP_ATOMIC);
-	if (!tmp_hdr)
-		goto drop;
-	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
-
-	nexthdr = xfrm6_clear_mutable_options(skb, &nh_offset, XFRM_POLICY_IN);
-	hdr->priority    = 0;
-	hdr->flow_lbl[0] = 0;
-	hdr->flow_lbl[1] = 0;
-	hdr->flow_lbl[2] = 0;
-	hdr->hop_limit   = 0;
+	ip6_find_1stfragopt(skb, &prevhdr);
+	nexthdr = *prevhdr;
+	*nhoffp = prevhdr - skb->nh.raw;
 
 	if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
 		goto drop;
@@ -204,12 +82,6 @@
 			goto drop;
 	} while (!err);
 
-	if (!decaps) {
-		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-		skb->nh.raw[nh_offset] = nexthdr;
-		skb->nh.ipv6h->payload_len = htons(hdr_len + skb->len - sizeof(struct ipv6hdr));
-	}
-
 	/* Allocate new secpath or COW existing one. */
 	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
 		kmem_cache_t *pool = skb->sp ? skb->sp->pool : secpath_cachep;
@@ -243,7 +115,6 @@
 		netif_rx(skb);
 		return -1;
 	} else {
-		*nhoffp = nh_offset;
 		return 1;
 	}
 
@@ -251,7 +122,6 @@
 	spin_unlock(&x->lock);
 	xfrm_state_put(x);
 drop:
-	if (tmp_hdr) kfree(tmp_hdr);
 	while (--xfrm_nr >= 0)
 		xfrm_state_put(xfrm_vec[xfrm_nr].xvec);
 	kfree_skb(skb);
