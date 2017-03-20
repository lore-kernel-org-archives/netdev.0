From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] vmbus: no longer expose iterator internals
Date: Mon, 20 Mar 2017 13:28:05 -0700
Message-ID: <20170320202805.19362-3-sthemmin@microsoft.com>
References: <20170320202805.19362-1-sthemmin@microsoft.com>
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36300 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932252AbdCTU2X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 16:28:23 -0400
Received: by mail-pf0-f176.google.com with SMTP id o126so70546718pfb.3
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 13:28:15 -0700 (PDT)
In-Reply-To: <20170320202805.19362-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since NAPI no longer needs to jump out of iterator early,
no need to expose the internal iterator steps.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/hv/ring_buffer.c | 51 ++++++++++++++++++++++++------------------------
 include/linux/hyperv.h   | 22 +--------------------
 2 files changed, 27 insertions(+), 46 deletions(-)

diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
index c3f1a9e33cef..280e2010913f 100644
--- a/drivers/hv/ring_buffer.c
+++ b/drivers/hv/ring_buffer.c
@@ -458,13 +458,31 @@ struct vmpacket_descriptor *hv_pkt_iter_first(struct vmbus_channel *channel)
 EXPORT_SYMBOL_GPL(hv_pkt_iter_first);
 
 /*
+ * Update host ring buffer after iterating over packets.
+ */
+static void hv_pkt_iter_close(struct vmbus_channel *channel)
+{
+	struct hv_ring_buffer_info *rbi = &channel->inbound;
+
+	/*
+	 * Make sure all reads are done before we update the read index since
+	 * the writer may start writing to the read area once the read index
+	 * is updated.
+	 */
+	virt_rmb();
+	rbi->ring_buffer->read_index = rbi->priv_read_index;
+
+	hv_signal_on_read(channel);
+}
+
+/*
  * Get next vmbus packet from ring buffer.
  *
  * Advances the current location (priv_read_index) and checks for more
- * data. If the end of the ring buffer is reached, then return NULL.
+ * data. If at end of list, return NULL and update host.
  */
 struct vmpacket_descriptor *
-__hv_pkt_iter_next(struct vmbus_channel *channel,
+hv_pkt_iter_next(struct vmbus_channel *channel,
 		   const struct vmpacket_descriptor *desc)
 {
 	struct hv_ring_buffer_info *rbi = &channel->inbound;
@@ -476,29 +494,12 @@ __hv_pkt_iter_next(struct vmbus_channel *channel,
 	if (rbi->priv_read_index >= dsize)
 		rbi->priv_read_index -= dsize;
 
-	/* more data? */
-	if (hv_pkt_iter_avail(rbi) < sizeof(struct vmpacket_descriptor))
+	/* if no more data? */
+	if (hv_pkt_iter_avail(rbi) < sizeof(struct vmpacket_descriptor)) {
+		hv_pkt_iter_close(channel);
 		return NULL;
-	else
-		return hv_get_ring_buffer(rbi) + rbi->priv_read_index;
-}
-EXPORT_SYMBOL_GPL(__hv_pkt_iter_next);
-
-/*
- * Update host ring buffer after iterating over packets.
- */
-void hv_pkt_iter_close(struct vmbus_channel *channel)
-{
-	struct hv_ring_buffer_info *rbi = &channel->inbound;
-
-	/*
-	 * Make sure all reads are done before we update the read index since
-	 * the writer may start writing to the read area once the read index
-	 * is updated.
-	 */
-	virt_rmb();
-	rbi->ring_buffer->read_index = rbi->priv_read_index;
+	}
 
-	hv_signal_on_read(channel);
+	return hv_get_ring_buffer(rbi) + rbi->priv_read_index;
 }
-EXPORT_SYMBOL_GPL(hv_pkt_iter_close);
+EXPORT_SYMBOL_GPL(hv_pkt_iter_next);
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 36162485d663..7df6ab5b3067 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1550,32 +1550,12 @@ static inline u32 hv_pkt_datalen(const struct vmpacket_descriptor *desc)
 	return (desc->len8 << 3) - (desc->offset8 << 3);
 }
 
-
 struct vmpacket_descriptor *
 hv_pkt_iter_first(struct vmbus_channel *channel);
 
 struct vmpacket_descriptor *
-__hv_pkt_iter_next(struct vmbus_channel *channel,
-		   const struct vmpacket_descriptor *pkt);
-
-void hv_pkt_iter_close(struct vmbus_channel *channel);
-
-/*
- * Get next packet descriptor from iterator
- * If at end of list, return NULL and update host.
- */
-static inline struct vmpacket_descriptor *
 hv_pkt_iter_next(struct vmbus_channel *channel,
-		 const struct vmpacket_descriptor *pkt)
-{
-	struct vmpacket_descriptor *nxt;
-
-	nxt = __hv_pkt_iter_next(channel, pkt);
-	if (!nxt)
-		hv_pkt_iter_close(channel);
-
-	return nxt;
-}
+		   const struct vmpacket_descriptor *pkt);
 
 #define foreach_vmbus_pkt(pkt, channel) \
 	for (pkt = hv_pkt_iter_first(channel); pkt; \
-- 
2.11.0
