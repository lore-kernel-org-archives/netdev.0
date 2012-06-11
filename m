From: Tony Cheneau <tony.cheneauh@amnesiak.org>
Subject: [PATCH net-next 4/4] 6lowpan: len field is not stored and accessed
 properly
Date: Mon, 11 Jun 2012 00:40:25 -0400
Message-ID: <20120611004025.6f6129ca@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com
To: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:53005 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab2FKEvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 00:51:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lenght field should be encoded (and accessed) the other way around.
As it is currently written, it could lead to interroperability issues.

Also, I rewrote the code so that iphc0 argument of
lowpan_alloc_new_frame could be removed.
---
 net/ieee802154/6lowpan.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index af2f12e..b400156 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -654,7 +654,7 @@ static void lowpan_fragment_timer_expired(unsigned
long entry_addr) }
 
 static struct lowpan_fragment *
-lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 tag)
+lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
 {
 	struct lowpan_fragment *frame;
 
@@ -665,7 +665,7 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u8
iphc0, u8 len, u16 tag) 
 	INIT_LIST_HEAD(&frame->list);
 
-	frame->length = (iphc0 & 7) | (len << 3);
+	frame->length = len;
 	frame->tag = tag;
 
 	/* allocate buffer for frame assembling */
@@ -721,13 +721,17 @@ lowpan_process_data(struct sk_buff *skb)
 	case LOWPAN_DISPATCH_FRAGN:
 	{
 		struct lowpan_fragment *frame;
-		u8 len, offset;
-		u16 tag;
+		/* slen stores the rightmost 8 bits of the 11 bits
length */
+		u8 slen, offset;
+		u16 len, tag;
 		bool found = false;
 
-		len = lowpan_fetch_skb_u8(skb); /* frame length */
+		slen = lowpan_fetch_skb_u8(skb); /* frame length */
 		tag = lowpan_fetch_skb_u16(skb);
 
+		/* adds the 3 MSB to the 8 LSB to retrieve the 11 bits
length */
+		len = ((iphc0 & 7) << 8) | slen;
+
 		/*
 		 * check if frame assembling with the same tag is
 		 * already in progress
@@ -742,7 +746,7 @@ lowpan_process_data(struct sk_buff *skb)
 
 		/* alloc new frame structure */
 		if (!found) {
-			frame = lowpan_alloc_new_frame(skb, iphc0,
len, tag);
+			frame = lowpan_alloc_new_frame(skb, len, tag);
 			if (!frame)
 				goto unlock_and_drop;
 		}
@@ -1000,8 +1004,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
 	tag = fragment_tag++;
 
 	/* first fragment header */
-	head[0] = LOWPAN_DISPATCH_FRAG1 | (payload_length & 0x7);
-	head[1] = (payload_length >> 3) & 0xff;
+	head[0] = LOWPAN_DISPATCH_FRAG1 | ((payload_length >> 8) &
0x7);
+	head[1] = payload_length & 0xff;
 	head[2] = tag >> 8;
 	head[3] = tag & 0xff;
 
-- 
1.7.3.4
