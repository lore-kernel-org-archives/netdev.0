From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: [PATCH net-next v2 4/4] Change byte order when storing/accessing len field
Date: Fri,  6 Jul 2012 00:50:25 -0400
Message-ID: <1341550225-13112-5-git-send-email-tony.cheneau@amnesiak.org>
References: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:41256 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2GFExT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 00:53:19 -0400
In-Reply-To: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Length field should be encoded using big endian byte order, such as intend by
the specs.
As it is currently written, the len field would not be decoded properly on an
implementation following the correct byte ordering. Hence, it could lead to
interoperability issues.

Also, code has been rewritten so that iphc0 argument of lowpan_alloc_new_frame()
is no longer necessary.

---
 net/ieee802154/6lowpan.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index b886e07..33a4093 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -649,7 +649,7 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 }
 
 static struct lowpan_fragment *
-lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 tag)
+lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
 {
 	struct lowpan_fragment *frame;
 
@@ -660,7 +660,7 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 tag)
 
 	INIT_LIST_HEAD(&frame->list);
 
-	frame->length = (iphc0 & 7) | (len << 3);
+	frame->length = len;
 	frame->tag = tag;
 
 	/* allocate buffer for frame assembling */
@@ -718,14 +718,18 @@ lowpan_process_data(struct sk_buff *skb)
 	case LOWPAN_DISPATCH_FRAGN:
 	{
 		struct lowpan_fragment *frame;
-		u8 len, offset;
-		u16 tag;
+		/* slen stores the rightmost 8 bits of the 11 bits length */
+		u8 slen, offset;
+		u16 len, tag;
 		bool found = false;
 
-		if (lowpan_fetch_skb_u8(skb, &len) || /* frame length */
+		if (lowpan_fetch_skb_u8(skb, &slen) || /* frame length */
 		    lowpan_fetch_skb_u16(skb, &tag))  /* fragment tag */
 			goto drop;
 
+		/* adds the 3 MSB to the 8 LSB to retrieve the 11 bits length */
+		len = ((iphc0 & 7) << 8) | slen;
+
 		/*
 		 * check if frame assembling with the same tag is
 		 * already in progress
@@ -740,7 +744,7 @@ lowpan_process_data(struct sk_buff *skb)
 
 		/* alloc new frame structure */
 		if (!found) {
-			frame = lowpan_alloc_new_frame(skb, iphc0, len, tag);
+			frame = lowpan_alloc_new_frame(skb, len, tag);
 			if (!frame)
 				goto unlock_and_drop;
 		}
@@ -1008,8 +1012,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
 	tag = fragment_tag++;
 
 	/* first fragment header */
-	head[0] = LOWPAN_DISPATCH_FRAG1 | (payload_length & 0x7);
-	head[1] = (payload_length >> 3) & 0xff;
+	head[0] = LOWPAN_DISPATCH_FRAG1 | ((payload_length >> 8) & 0x7);
+	head[1] = payload_length & 0xff;
 	head[2] = tag >> 8;
 	head[3] = tag & 0xff;
 
-- 
1.7.3.4
