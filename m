From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 2/2] sfc: Track RPS flow IDs per channel instead of per
 function
Date: Thu, 26 May 2016 17:02:12 +0100
Message-ID: <57471E04.60401@solarflare.com>
References: <57471D92.2000708@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:17262 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754311AbcEZQCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 12:02:23 -0400
In-Reply-To: <57471D92.2000708@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Otherwise we get confused when two flows on different channels get the
 same flow ID.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 32 +++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/net_driver.h | 12 ++++++++----
 drivers/net/ethernet/sfc/rx.c         | 29 +++++++++++++++++++++--------
 3 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0705ec86..097f363 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1726,14 +1726,33 @@ static int efx_probe_filters(struct efx_nic *efx)
 
 #ifdef CONFIG_RFS_ACCEL
 	if (efx->type->offload_features & NETIF_F_NTUPLE) {
-		efx->rps_flow_id = kcalloc(efx->type->max_rx_ip_filters,
-					   sizeof(*efx->rps_flow_id),
-					   GFP_KERNEL);
-		if (!efx->rps_flow_id) {
+		struct efx_channel *channel;
+		int i, success = 1;
+
+		efx_for_each_channel(channel, efx) {
+			channel->rps_flow_id =
+				kcalloc(efx->type->max_rx_ip_filters,
+					sizeof(*channel->rps_flow_id),
+					GFP_KERNEL);
+			if (!channel->rps_flow_id)
+				success = 0;
+			else
+				for (i = 0;
+				     i < efx->type->max_rx_ip_filters;
+				     ++i)
+					channel->rps_flow_id[i] =
+						RPS_FLOW_ID_INVALID;
+		}
+
+		if (!success) {
+			efx_for_each_channel(channel, efx)
+				kfree(channel->rps_flow_id);
 			efx->type->filter_table_remove(efx);
 			rc = -ENOMEM;
 			goto out_unlock;
 		}
+
+		efx->rps_expire_index = efx->rps_expire_channel = 0;
 	}
 #endif
 out_unlock:
@@ -1744,7 +1763,10 @@ out_unlock:
 static void efx_remove_filters(struct efx_nic *efx)
 {
 #ifdef CONFIG_RFS_ACCEL
-	kfree(efx->rps_flow_id);
+	struct efx_channel *channel;
+
+	efx_for_each_channel(channel, efx)
+		kfree(channel->rps_flow_id);
 #endif
 	down_write(&efx->filter_sem);
 	efx->type->filter_table_remove(efx);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 38c4223..d13ddf9 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -403,6 +403,8 @@ enum efx_sync_events_state {
  * @event_test_cpu: Last CPU to handle interrupt or test event for this channel
  * @irq_count: Number of IRQs since last adaptive moderation decision
  * @irq_mod_score: IRQ moderation score
+ * @rps_flow_id: Flow IDs of filters allocated for accelerated RFS,
+ *      indexed by filter ID
  * @n_rx_tobe_disc: Count of RX_TOBE_DISC errors
  * @n_rx_ip_hdr_chksum_err: Count of RX IP header checksum errors
  * @n_rx_tcp_udp_chksum_err: Count of RX TCP and UDP checksum errors
@@ -446,6 +448,8 @@ struct efx_channel {
 	unsigned int irq_mod_score;
 #ifdef CONFIG_RFS_ACCEL
 	unsigned int rfs_filters_added;
+#define RPS_FLOW_ID_INVALID 0xFFFFFFFF
+	u32 *rps_flow_id;
 #endif
 
 	unsigned n_rx_tobe_disc;
@@ -889,9 +893,9 @@ struct vfdi_status;
  * @filter_sem: Filter table rw_semaphore, for freeing the table
  * @filter_lock: Filter table lock, for mere content changes
  * @filter_state: Architecture-dependent filter table state
- * @rps_flow_id: Flow IDs of filters allocated for accelerated RFS,
- *	indexed by filter ID
- * @rps_expire_index: Next index to check for expiry in @rps_flow_id
+ * @rps_expire_channel: Next channel to check for expiry
+ * @rps_expire_index: Next index to check for expiry in
+ *	@rps_expire_channel's @rps_flow_id
  * @active_queues: Count of RX and TX queues that haven't been flushed and drained.
  * @rxq_flush_pending: Count of number of receive queues that need to be flushed.
  *	Decremented when the efx_flush_rx_queue() is called.
@@ -1035,7 +1039,7 @@ struct efx_nic {
 	spinlock_t filter_lock;
 	void *filter_state;
 #ifdef CONFIG_RFS_ACCEL
-	u32 *rps_flow_id;
+	unsigned int rps_expire_channel;
 	unsigned int rps_expire_index;
 #endif
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 52790f0..1533c08 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -855,6 +855,9 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 	int nhoff;
 	int rc;
 
+	if (flow_id == RPS_FLOW_ID_INVALID)
+		return -EINVAL;
+
 	hptr = skb_header_pointer(skb, 0, headlen, header);
 	if (!hptr)
 		return -EINVAL;
@@ -919,8 +922,8 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 		return rc;
 
 	/* Remember this so we can check whether to expire the filter later */
-	efx->rps_flow_id[rc] = flow_id;
-	channel = efx_get_channel(efx, skb_get_rx_queue(skb));
+	channel = efx_get_channel(efx, rxq_index);
+	channel->rps_flow_id[rc] = flow_id;
 	++channel->rfs_filters_added;
 
 	if (ether_type == htons(ETH_P_IP))
@@ -942,24 +945,34 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 bool __efx_filter_rfs_expire(struct efx_nic *efx, unsigned int quota)
 {
 	bool (*expire_one)(struct efx_nic *efx, u32 flow_id, unsigned int index);
-	unsigned int index, size;
+	unsigned int channel_idx, index, size;
 	u32 flow_id;
 
 	if (!spin_trylock_bh(&efx->filter_lock))
 		return false;
 
 	expire_one = efx->type->filter_rfs_expire_one;
+	channel_idx = efx->rps_expire_channel;
 	index = efx->rps_expire_index;
 	size = efx->type->max_rx_ip_filters;
 	while (quota--) {
-		flow_id = efx->rps_flow_id[index];
-		if (expire_one(efx, flow_id, index))
+		struct efx_channel *channel = efx_get_channel(efx, channel_idx);
+		flow_id = channel->rps_flow_id[index];
+
+		if (flow_id != RPS_FLOW_ID_INVALID &&
+		    expire_one(efx, flow_id, index)) {
 			netif_info(efx, rx_status, efx->net_dev,
-				   "expired filter %d [flow %u]\n",
-				   index, flow_id);
-		if (++index == size)
+				   "expired filter %d [queue %u flow %u]\n",
+				   index, channel_idx, flow_id);
+			channel->rps_flow_id[index] = RPS_FLOW_ID_INVALID;
+		}
+		if (++index == size) {
+			if (++channel_idx == efx->n_channels)
+				channel_idx = 0;
 			index = 0;
+		}
 	}
+	efx->rps_expire_channel = channel_idx;
 	efx->rps_expire_index = index;
 
 	spin_unlock_bh(&efx->filter_lock);
