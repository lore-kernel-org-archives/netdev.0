From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 5/6] [6LoWPAN] UDP header decompression
Date: Thu, 10 Nov 2011 20:40:53 +0300
Message-ID: <1320946853-7566-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111110173258.GA8056@avtobot.cybertron>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44728 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab1KJRjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 12:39:33 -0500
Received: by wyh15 with SMTP id 15so2988236wyh.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 09:39:32 -0800 (PST)
In-Reply-To: <20111110173258.GA8056@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides possibility to decompress UDP headers.
Derived from Contiki OS.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   61 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 9bf82d7..602f318 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -311,6 +311,62 @@ static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
 	return ret;
 }
 
+static int
+lowpan_uncompress_udp_header(struct sk_buff *skb)
+{
+	struct udphdr *uh = udp_hdr(skb);
+	u8 tmp;
+
+	tmp = lowpan_fetch_skb_u8(skb);
+
+	if ((tmp & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
+		pr_debug("(%s): UDP header uncompression\n", __func__);
+		switch (tmp & LOWPAN_NHC_UDP_CS_P_11) {
+		case LOWPAN_NHC_UDP_CS_P_00:
+			memcpy(&uh->source, &skb->data[0], 2);
+			memcpy(&uh->dest, &skb->data[2], 2);
+			skb_pull(skb, 4);
+			break;
+		case LOWPAN_NHC_UDP_CS_P_01:
+			memcpy(&uh->source, &skb->data[0], 2);
+			uh->dest =
+			   skb->data[2] + LOWPAN_NHC_UDP_8BIT_PORT;
+			skb_pull(skb, 3);
+			break;
+		case LOWPAN_NHC_UDP_CS_P_10:
+			uh->source = skb->data[0] + LOWPAN_NHC_UDP_8BIT_PORT;
+			memcpy(&uh->dest, &skb->data[1], 2);
+			skb_pull(skb, 3);
+			break;
+		case LOWPAN_NHC_UDP_CS_P_11:
+			uh->source =
+			   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] >> 4);
+			uh->dest =
+			   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] & 0x0f);
+			skb_pull(skb, 1);
+			break;
+		default:
+			pr_debug("(%s) ERROR: unknown UDP format\n", __func__);
+			goto err;
+			break;
+		}
+
+		pr_debug("(%s): uncompressed UDP ports: src = %d, dst = %d\n",
+					__func__, uh->source, uh->dest);
+
+		/* copy checksum */
+		memcpy(&uh->check, &skb->data[0], 2);
+		skb_pull(skb, 2);
+	} else {
+		pr_debug("(%s): ERROR: unsupported NH format\n", __func__);
+		goto err;
+	}
+
+	return 0;
+err:
+	return -EINVAL;
+}
+
 static int lowpan_header_create(struct sk_buff *skb,
 			   struct net_device *dev,
 			   unsigned short type, const void *_daddr,
@@ -842,7 +898,10 @@ lowpan_process_data(struct sk_buff *skb)
 			goto drop;
 	}
 
-	/* TODO: UDP header parse */
+	/* UDP data uncompression */
+	if (iphc0 & LOWPAN_IPHC_NH_C)
+		if (lowpan_uncompress_udp_header(skb))
+			goto drop;
 
 	/* Not fragmented package */
 	hdr.payload_len = htons(skb->len);
-- 
1.7.2.5
