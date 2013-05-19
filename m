From: David Hauweele <david@hauweele.net>
Subject: [PATCH 1/1] 6lowpan: Fix fragmentation with link-local compressed addresses
Date: Sun, 19 May 2013 20:13:31 +0200
Message-ID: <1368987211-19826-1-git-send-email-david@hauweele.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Hauweele <david@hauweele.net>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a new 6lowpan fragment is received, a skbuff is allocated for
the reassembled packet. However when a 6lowpan packet compresses
link-local addresses based on link-layer addresses, the processing
function relies on the skb mac control block to find the related
link-layer address.

This patch copies the control block from the first fragment into
the newly allocated skb to keep a trace of the link-layer addresses
in case of a link-local compressed address.

Signed-off-by: David Hauweele <david@hauweele.net>
---
 net/ieee802154/6lowpan.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 55e1fd5..d9a41e2 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -702,6 +702,13 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
 	skb_reserve(frame->skb, sizeof(struct ipv6hdr));
 	skb_put(frame->skb, frame->length);
 
+	/*
+	 * copy the first control block to keep a
+	 * trace of the link-layer addresses in case
+	 * of a link-local compressed address
+	 */
+	memcpy(frame->skb->cb, skb->cb, sizeof(skb->cb));
+
 	init_timer(&frame->timer);
 	/* time out is the same as for ipv6 - 60 sec */
 	frame->timer.expires = jiffies + LOWPAN_FRAG_TIMEOUT;
-- 
1.7.10.4
