From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Fri, 30 Mar 2012 19:23:35 -0400
Message-ID: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
To: Chris Metcalf <cmetcalf@tilera.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit fixes a number of issues seen with the driver:

- Improve handling of return credits to the hardware shim
- Use skb_frag_size() appropriately
- Add netpoll support to run console over UDP

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilepro.c |   75 +++++++++++++++++++++++------------
 1 files changed, 50 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index d9951af..eb4ea08 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -342,6 +342,21 @@ inline int __netio_fastio1(u32 fastio_index, u32 arg0)
 }
 
 
+static void tile_net_return_credit(struct tile_net_cpu *info)
+{
+	struct tile_netio_queue *queue = &info->queue;
+	netio_queue_user_impl_t *qup = &queue->__user_part;
+
+	/* Return four credits after every fourth packet. */
+	if (--qup->__receive_credit_remaining == 0) {
+		u32 interval = qup->__receive_credit_interval;
+		qup->__receive_credit_remaining = interval;
+		__netio_fastio_return_credits(qup->__fastio_index, interval);
+	}
+}
+
+
+
 /*
  * Provide a linux buffer to LIPP.
  */
@@ -864,19 +879,11 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 
 		stats->rx_packets++;
 		stats->rx_bytes += len;
-
-		if (small)
-			info->num_needed_small_buffers++;
-		else
-			info->num_needed_large_buffers++;
 	}
 
-	/* Return four credits after every fourth packet. */
-	if (--qup->__receive_credit_remaining == 0) {
-		u32 interval = qup->__receive_credit_interval;
-		qup->__receive_credit_remaining = interval;
-		__netio_fastio_return_credits(qup->__fastio_index, interval);
-	}
+	/* ISSUE: It would be nice to defer this until the packet has */
+	/* actually been processed. */
+	tile_net_return_credit(info);
 
 	/* Consume this packet. */
 	qup->__packet_receive_read = index2;
@@ -1543,7 +1550,7 @@ static int tile_net_drain_lipp_buffers(struct tile_net_priv *priv)
 
 	/* Drain all the LIPP buffers. */
 	while (true) {
-		int buffer;
+		unsigned int buffer;
 
 		/* NOTE: This should never fail. */
 		if (hv_dev_pread(priv->hv_devhdl, 0, (HV_VirtAddr)&buffer,
@@ -1707,7 +1714,7 @@ static unsigned int tile_net_tx_frags(lepp_frag_t *frags,
 		if (!hash_default) {
 			void *va = pfn_to_kaddr(pfn) + f->page_offset;
 			BUG_ON(PageHighMem(skb_frag_page(f)));
-			finv_buffer_remote(va, f->size, 0);
+			finv_buffer_remote(va, skb_frag_size(f), 0);
 		}
 
 		cpa = ((phys_addr_t)pfn << PAGE_SHIFT) + f->page_offset;
@@ -1735,8 +1742,8 @@ static unsigned int tile_net_tx_frags(lepp_frag_t *frags,
  * Sometimes, if "sendfile()" requires copying, we will be called with
  * "data" containing the header and payload, with "frags" being empty.
  *
- * In theory, "sh->nr_frags" could be 3, but in practice, it seems
- * that this will never actually happen.
+ * Sometimes, for example when using NFS over TCP, a single segment can
+ * span 3 fragments, which must be handled carefully in LEPP.
  *
  * See "emulate_large_send_offload()" for some reference code, which
  * does not handle checksumming.
@@ -1844,10 +1851,8 @@ static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&priv->eq_lock, irqflags);
 
-	/*
-	 * Handle completions if needed to make room.
-	 * HACK: Spin until there is sufficient room.
-	 */
+	/* Handle completions if needed to make room. */
+	/* NOTE: Return NETDEV_TX_BUSY if there is still no room. */
 	if (lepp_num_free_comp_slots(eq) == 0) {
 		nolds = tile_net_lepp_grab_comps(eq, olds, wanted, 0);
 		if (nolds == 0) {
@@ -1861,6 +1866,7 @@ busy:
 	cmd_tail = eq->cmd_tail;
 
 	/* Prepare to advance, detecting full queue. */
+	/* NOTE: Return NETDEV_TX_BUSY if the queue is full. */
 	cmd_next = cmd_tail + cmd_size;
 	if (cmd_tail < cmd_head && cmd_next >= cmd_head)
 		goto busy;
@@ -2023,10 +2029,8 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&priv->eq_lock, irqflags);
 
-	/*
-	 * Handle completions if needed to make room.
-	 * HACK: Spin until there is sufficient room.
-	 */
+	/* Handle completions if needed to make room. */
+	/* NOTE: Return NETDEV_TX_BUSY if there is still no room. */
 	if (lepp_num_free_comp_slots(eq) == 0) {
 		nolds = tile_net_lepp_grab_comps(eq, olds, wanted, 0);
 		if (nolds == 0) {
@@ -2040,6 +2044,7 @@ busy:
 	cmd_tail = eq->cmd_tail;
 
 	/* Copy the commands, or fail. */
+	/* NOTE: Return NETDEV_TX_BUSY if the queue is full. */
 	for (i = 0; i < num_frags; i++) {
 
 		/* Prepare to advance, detecting full queue. */
@@ -2260,6 +2265,23 @@ static int tile_net_get_mac(struct net_device *dev)
 	return 0;
 }
 
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void tile_net_netpoll(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	disable_percpu_irq(priv->intr_id);
+	tile_net_handle_ingress_interrupt(priv->intr_id, dev);
+	enable_percpu_irq(priv->intr_id, 0);
+}
+#endif
+
+
 static const struct net_device_ops tile_net_ops = {
 	.ndo_open = tile_net_open,
 	.ndo_stop = tile_net_stop,
@@ -2268,7 +2290,10 @@ static const struct net_device_ops tile_net_ops = {
 	.ndo_get_stats = tile_net_get_stats,
 	.ndo_change_mtu = tile_net_change_mtu,
 	.ndo_tx_timeout = tile_net_tx_timeout,
-	.ndo_set_mac_address = tile_net_set_mac_address
+	.ndo_set_mac_address = tile_net_set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = tile_net_netpoll,
+#endif
 };
 
 
@@ -2408,7 +2433,7 @@ static void tile_net_cleanup(void)
  */
 static int tile_net_init_module(void)
 {
-	pr_info("Tilera IPP Net Driver\n");
+	pr_info("Tilera Network Driver\n");
 
 	tile_net_devs[0] = tile_net_dev_init("xgbe0");
 	tile_net_devs[1] = tile_net_dev_init("xgbe1");
-- 
1.6.5.2
