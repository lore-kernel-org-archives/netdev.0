From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 1/2 net v2] 6lowpan: rework data fetching from skb
Date: Fri, 11 May 2012 18:58:10 +0400
Message-ID: <1336748290-25649-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43169 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757515Ab2EKO71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 10:59:27 -0400
Received: by bkcji2 with SMTP id ji2so2317058bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 07:59:25 -0700 (PDT)
In-Reply-To: <4fabc166.9208cc0a.4de8.ffff9211@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reworks functions responsible for fetching data from skb. Now they
work more accurately and can notify if something went wrong.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   75 ++++++++++++++++++++++++++-------------------
 1 files changed, 43 insertions(+), 32 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 32eb417..c2bbf01 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -291,25 +291,31 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 	*hc06_ptr += 2;
 }
 
-static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
+static inline int lowpan_fetch_skb_u8(struct sk_buff *skb, u8 *val)
 {
-	u8 ret;
+	if (WARN_ON_ONCE(!pskb_may_pull(skb, 1))) {
+		/*
+		 * Uhhh, something went terribly wrong.
+		 * Check the bottom layers code
+		 */
+		return -EINVAL;
+	}
 
-	ret = skb->data[0];
+	*val = skb->data[0];
 	skb_pull(skb, 1);
 
-	return ret;
+	return 0;
 }
 
-static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
+static inline int lowpan_fetch_skb_u16(struct sk_buff *skb, u16 *val)
 {
-	u16 ret;
-
-	BUG_ON(!pskb_may_pull(skb, 2));
+	if (WARN_ON_ONCE(!pskb_may_pull(skb, 2)))
+		return -EINVAL;
 
-	ret = skb->data[0] | (skb->data[1] << 8);
+	*val = skb->data[0] | (skb->data[1] << 8);
 	skb_pull(skb, 2);
-	return ret;
+
+	return 0;
 }
 
 static int
@@ -318,7 +324,8 @@ lowpan_uncompress_udp_header(struct sk_buff *skb)
 	struct udphdr *uh = udp_hdr(skb);
 	u8 tmp;
 
-	tmp = lowpan_fetch_skb_u8(skb);
+	if (lowpan_fetch_skb_u8(skb, &tmp))
+		goto err;
 
 	if ((tmp & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
 		pr_debug("(%s): UDP header uncompression\n", __func__);
@@ -710,7 +717,9 @@ lowpan_process_data(struct sk_buff *skb)
 	/* at least two bytes will be used for the encoding */
 	if (skb->len < 2)
 		goto drop;
-	iphc0 = lowpan_fetch_skb_u8(skb);
+
+	if (lowpan_fetch_skb_u8(skb, &iphc0))
+		goto drop;
 
 	/* fragments assembling */
 	switch (iphc0 & LOWPAN_DISPATCH_MASK) {
@@ -722,8 +731,9 @@ lowpan_process_data(struct sk_buff *skb)
 		u16 tag;
 		bool found = false;
 
-		len = lowpan_fetch_skb_u8(skb); /* frame length */
-		tag = lowpan_fetch_skb_u16(skb);
+		if (lowpan_fetch_skb_u8(skb, &len) || /* frame length */
+		    lowpan_fetch_skb_u16(skb, &tag))  /* fragment tag */
+			goto drop;
 
 		/*
 		 * check if frame assembling with the same tag is
@@ -747,7 +757,8 @@ lowpan_process_data(struct sk_buff *skb)
 		if ((iphc0 & LOWPAN_DISPATCH_MASK) == LOWPAN_DISPATCH_FRAG1)
 			goto unlock_and_drop;
 
-		offset = lowpan_fetch_skb_u8(skb); /* fetch offset */
+		if (lowpan_fetch_skb_u8(skb, &offset)) /* fetch offset */
+			goto unlock_and_drop;
 
 		/* if payload fits buffer, copy it */
 		if (likely((offset * 8 + skb->len) <= frame->length))
@@ -769,7 +780,10 @@ lowpan_process_data(struct sk_buff *skb)
 			dev_kfree_skb(skb);
 			skb = frame->skb;
 			kfree(frame);
-			iphc0 = lowpan_fetch_skb_u8(skb);
+
+			if (lowpan_fetch_skb_u8(skb, &iphc0))
+				goto unlock_and_drop;
+
 			break;
 		}
 		spin_unlock(&flist_lock);
@@ -780,7 +794,8 @@ lowpan_process_data(struct sk_buff *skb)
 		break;
 	}
 
-	iphc1 = lowpan_fetch_skb_u8(skb);
+	if (lowpan_fetch_skb_u8(skb, &iphc1))
+		goto drop;
 
 	_saddr = mac_cb(skb)->sa.hwaddr;
 	_daddr = mac_cb(skb)->da.hwaddr;
@@ -791,9 +806,8 @@ lowpan_process_data(struct sk_buff *skb)
 	if (iphc1 & LOWPAN_IPHC_CID) {
 		pr_debug("(%s): CID flag is set, increase header with one\n",
 								__func__);
-		if (!skb->len)
+		if (lowpan_fetch_skb_u8(skb, &num_context))
 			goto drop;
-		num_context = lowpan_fetch_skb_u8(skb);
 	}
 
 	hdr.version = 6;
@@ -805,9 +819,9 @@ lowpan_process_data(struct sk_buff *skb)
 	 * ECN + DSCP + 4-bit Pad + Flow Label (4 bytes)
 	 */
 	case 0: /* 00b */
-		if (!skb->len)
+		if (lowpan_fetch_skb_u8(skb, &tmp))
 			goto drop;
-		tmp = lowpan_fetch_skb_u8(skb);
+
 		memcpy(&hdr.flow_lbl, &skb->data[0], 3);
 		skb_pull(skb, 3);
 		hdr.priority = ((tmp >> 2) & 0x0f);
@@ -819,9 +833,9 @@ lowpan_process_data(struct sk_buff *skb)
 	 * ECN + DSCP (1 byte), Flow Label is elided
 	 */
 	case 1: /* 10b */
-		if (!skb->len)
+		if (lowpan_fetch_skb_u8(skb, &tmp))
 			goto drop;
-		tmp = lowpan_fetch_skb_u8(skb);
+
 		hdr.priority = ((tmp >> 2) & 0x0f);
 		hdr.flow_lbl[0] = ((tmp << 6) & 0xC0) | ((tmp >> 2) & 0x30);
 		hdr.flow_lbl[1] = 0;
@@ -832,9 +846,9 @@ lowpan_process_data(struct sk_buff *skb)
 	 * ECN + 2-bit Pad + Flow Label (3 bytes), DSCP is elided
 	 */
 	case 2: /* 01b */
-		if (!skb->len)
+		if (lowpan_fetch_skb_u8(skb, &tmp))
 			goto drop;
-		tmp = lowpan_fetch_skb_u8(skb);
+
 		hdr.flow_lbl[0] = (skb->data[0] & 0x0F) | ((tmp >> 2) & 0x30);
 		memcpy(&hdr.flow_lbl[1], &skb->data[0], 2);
 		skb_pull(skb, 2);
@@ -853,9 +867,9 @@ lowpan_process_data(struct sk_buff *skb)
 	/* Next Header */
 	if ((iphc0 & LOWPAN_IPHC_NH_C) == 0) {
 		/* Next header is carried inline */
-		if (!skb->len)
+		if (lowpan_fetch_skb_u8(skb, &(hdr.nexthdr)))
 			goto drop;
-		hdr.nexthdr = lowpan_fetch_skb_u8(skb);
+
 		pr_debug("(%s): NH flag is set, next header is carried "
 			 "inline: %02x\n", __func__, hdr.nexthdr);
 	}
@@ -864,9 +878,8 @@ lowpan_process_data(struct sk_buff *skb)
 	if ((iphc0 & 0x03) != LOWPAN_IPHC_TTL_I)
 		hdr.hop_limit = lowpan_ttl_values[iphc0 & 0x03];
 	else {
-		if (!skb->len)
+		if (lowpan_fetch_skb_u8(skb, &(hdr.hop_limit)))
 			goto drop;
-		hdr.hop_limit = lowpan_fetch_skb_u8(skb);
 	}
 
 	/* Extract SAM to the tmp variable */
@@ -894,10 +907,8 @@ lowpan_process_data(struct sk_buff *skb)
 			pr_debug("(%s): destination address non-context-based"
 				 " multicast compression\n", __func__);
 			if (0 < tmp && tmp < 3) {
-				if (!skb->len)
+				if (lowpan_fetch_skb_u8(skb, &prefix[1]))
 					goto drop;
-				else
-					prefix[1] = lowpan_fetch_skb_u8(skb);
 			}
 
 			err = lowpan_uncompress_addr(skb, &hdr.daddr, prefix,
-- 
1.7.2.3
