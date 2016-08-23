From: sthemmin@exchange.microsoft.com
Subject: [PATCH 05/14] hv_netvsc: make inline functions static
Date: Tue, 23 Aug 2016 12:17:48 -0700
Message-ID: <1471979877-17802-5-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:41662
        "EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754339AbcHWSJG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:09:06 -0400
In-Reply-To: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Several new functions were introduced into hyperv.h but only used in one file.
Move them and let compiler decide on inline.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 85 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/hyperv.h      | 84 --------------------------------------------
 2 files changed, 84 insertions(+), 85 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index fe83de3..4ef2af6 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -34,6 +34,89 @@
 #include "hyperv_net.h"
 
 /*
+ * An API to support in-place processing of incoming VMBUS packets.
+ */
+#define VMBUS_PKT_TRAILER	8
+
+static struct vmpacket_descriptor *
+get_next_pkt_raw(struct vmbus_channel *channel)
+{
+	struct hv_ring_buffer_info *ring_info = &channel->inbound;
+	u32 read_loc = ring_info->priv_read_index;
+	void *ring_buffer = hv_get_ring_buffer(ring_info);
+	struct vmpacket_descriptor *cur_desc;
+	u32 packetlen;
+	u32 dsize = ring_info->ring_datasize;
+	u32 delta = read_loc - ring_info->ring_buffer->read_index;
+	u32 bytes_avail_toread = (hv_get_bytes_to_read(ring_info) - delta);
+
+	if (bytes_avail_toread < sizeof(struct vmpacket_descriptor))
+		return NULL;
+
+	if ((read_loc + sizeof(*cur_desc)) > dsize)
+		return NULL;
+
+	cur_desc = ring_buffer + read_loc;
+	packetlen = cur_desc->len8 << 3;
+
+	/*
+	 * If the packet under consideration is wrapping around,
+	 * return failure.
+	 */
+	if ((read_loc + packetlen + VMBUS_PKT_TRAILER) > (dsize - 1))
+		return NULL;
+
+	return cur_desc;
+}
+
+/*
+ * A helper function to step through packets "in-place"
+ * This API is to be called after each successful call
+ * get_next_pkt_raw().
+ */
+static void put_pkt_raw(struct vmbus_channel *channel,
+			struct vmpacket_descriptor *desc)
+{
+	struct hv_ring_buffer_info *ring_info = &channel->inbound;
+	u32 read_loc = ring_info->priv_read_index;
+	u32 packetlen = desc->len8 << 3;
+	u32 dsize = ring_info->ring_datasize;
+
+	BUG_ON((read_loc + packetlen + VMBUS_PKT_TRAILER) > dsize);
+
+	/*
+	 * Include the packet trailer.
+	 */
+	ring_info->priv_read_index += packetlen + VMBUS_PKT_TRAILER;
+}
+
+/*
+ * This call commits the read index and potentially signals the host.
+ * Here is the pattern for using the "in-place" consumption APIs:
+ *
+ * while (get_next_pkt_raw() {
+ *	process the packet "in-place";
+ *	put_pkt_raw();
+ * }
+ * if (packets processed in place)
+ *	commit_rd_index();
+ */
+static void commit_rd_index(struct vmbus_channel *channel)
+{
+	struct hv_ring_buffer_info *ring_info = &channel->inbound;
+	/*
+	 * Make sure all reads are done before we update the read index since
+	 * the writer may start writing to the read area once the read index
+	 * is updated.
+	 */
+	virt_rmb();
+	ring_info->ring_buffer->read_index = ring_info->priv_read_index;
+
+	if (hv_need_to_signal_on_read(ring_info))
+		vmbus_set_event(channel);
+}
+
+/*
  * Switch the data path from the synthetic interface to the VF
  * interface.
  */
@@ -749,7 +832,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	return msg_size;
 }
 
-static inline int netvsc_send_pkt(
+static int netvsc_send_pkt(
 	struct hv_device *device,
 	struct hv_netvsc_packet *packet,
 	struct netvsc_device *net_device,
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index b10954a..a6bc974 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1422,88 +1422,4 @@ static inline  bool hv_need_to_signal_on_read(struct hv_ring_buffer_info *rbi)
 	return false;
 }
 
-/*
- * An API to support in-place processing of incoming VMBUS packets.
- */
-#define VMBUS_PKT_TRAILER	8
-
-static inline struct vmpacket_descriptor *
-get_next_pkt_raw(struct vmbus_channel *channel)
-{
-	struct hv_ring_buffer_info *ring_info = &channel->inbound;
-	u32 read_loc = ring_info->priv_read_index;
-	void *ring_buffer = hv_get_ring_buffer(ring_info);
-	struct vmpacket_descriptor *cur_desc;
-	u32 packetlen;
-	u32 dsize = ring_info->ring_datasize;
-	u32 delta = read_loc - ring_info->ring_buffer->read_index;
-	u32 bytes_avail_toread = (hv_get_bytes_to_read(ring_info) - delta);
-
-	if (bytes_avail_toread < sizeof(struct vmpacket_descriptor))
-		return NULL;
-
-	if ((read_loc + sizeof(*cur_desc)) > dsize)
-		return NULL;
-
-	cur_desc = ring_buffer + read_loc;
-	packetlen = cur_desc->len8 << 3;
-
-	/*
-	 * If the packet under consideration is wrapping around,
-	 * return failure.
-	 */
-	if ((read_loc + packetlen + VMBUS_PKT_TRAILER) > (dsize - 1))
-		return NULL;
-
-	return cur_desc;
-}
-
-/*
- * A helper function to step through packets "in-place"
- * This API is to be called after each successful call
- * get_next_pkt_raw().
- */
-static inline void put_pkt_raw(struct vmbus_channel *channel,
-				struct vmpacket_descriptor *desc)
-{
-	struct hv_ring_buffer_info *ring_info = &channel->inbound;
-	u32 read_loc = ring_info->priv_read_index;
-	u32 packetlen = desc->len8 << 3;
-	u32 dsize = ring_info->ring_datasize;
-
-	if ((read_loc + packetlen + VMBUS_PKT_TRAILER) > dsize)
-		BUG();
-	/*
-	 * Include the packet trailer.
-	 */
-	ring_info->priv_read_index += packetlen + VMBUS_PKT_TRAILER;
-}
-
-/*
- * This call commits the read index and potentially signals the host.
- * Here is the pattern for using the "in-place" consumption APIs:
- *
- * while (get_next_pkt_raw() {
- *	process the packet "in-place";
- *	put_pkt_raw();
- * }
- * if (packets processed in place)
- *	commit_rd_index();
- */
-static inline void commit_rd_index(struct vmbus_channel *channel)
-{
-	struct hv_ring_buffer_info *ring_info = &channel->inbound;
-	/*
-	 * Make sure all reads are done before we update the read index since
-	 * the writer may start writing to the read area once the read index
-	 * is updated.
-	 */
-	virt_rmb();
-	ring_info->ring_buffer->read_index = ring_info->priv_read_index;
-
-	if (hv_need_to_signal_on_read(ring_info))
-		vmbus_set_event(channel);
-}
-
-
 #endif /* _HYPERV_H */
-- 
2.9.3
