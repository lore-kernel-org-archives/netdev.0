From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: allocate rx pages on the same node as the
 interrupt
Date: Wed, 4 May 2016 18:02:42 +0100
Message-ID: <572A2B32.1030509@solarflare.com>
References: <572A29AF.1040607@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Pieczko <dpieczko@solarflare.com>
To: <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:59444 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754554AbcEDRCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:02:55 -0400
In-Reply-To: <572A29AF.1040607@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

When the interrupt servicing a channel is on a NUMA node that is
not local to the device, performance is improved by allocating
rx pages on the node local to the interrupt (remote to the device)

The performance-optimal case, where interrupts and applications
are pinned to CPUs on the same node as the device, is not altered
by this change.

This change gave a 1% improvement in transaction rate using Nginx
with all interrupts and Nginx threads on the node remote to the
device. It also gave a small reduction in round-trip latency,
again with the interrupt and application on a different node to
the device.

Allocating rx pages based on the channel->irq_node value is only
valid for the initial driver-load interrupt affinities; if an
interrupt is moved later, the wrong node may be used for the
allocation.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 38 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/net_driver.h |  3 +++
 drivers/net/ethernet/sfc/rx.c         | 18 ++++++++++++++---
 3 files changed, 56 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index e6fdf35..f7e6ce5 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -449,6 +449,7 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 	channel->efx = efx;
 	channel->channel = i;
 	channel->type = &efx_default_channel_type;
+	channel->irq_mem_node = NUMA_NO_NODE;
 
 	for (j = 0; j < EFX_TXQ_TYPES; j++) {
 		tx_queue = &channel->tx_queue[j];
@@ -1569,6 +1570,38 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 	return 0;
 }
 
+#ifndef CONFIG_SMP
+static void efx_set_interrupt_affinity(struct efx_nic *efx __always_unused)
+{
+}
+
+static void efx_clear_interrupt_affinity(struct efx_nic *efx __always_unused)
+{
+}
+#else
+static void efx_set_interrupt_affinity(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+	unsigned int cpu;
+
+	efx_for_each_channel(channel, efx) {
+		cpu = cpumask_local_spread(channel->channel,
+					   pcibus_to_node(efx->pci_dev->bus));
+
+		irq_set_affinity_hint(channel->irq, cpumask_of(cpu));
+		channel->irq_mem_node = cpu_to_mem(cpu);
+	}
+}
+
+static void efx_clear_interrupt_affinity(struct efx_nic *efx)
+{
+	struct efx_channel *channel;
+
+	efx_for_each_channel(channel, efx)
+		irq_set_affinity_hint(channel->irq, NULL);
+}
+#endif /* CONFIG_SMP */
+
 static int efx_soft_enable_interrupts(struct efx_nic *efx)
 {
 	struct efx_channel *channel, *end_channel;
@@ -3017,6 +3050,7 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 	cancel_work_sync(&efx->reset_work);
 
 	efx_disable_interrupts(efx);
+	efx_clear_interrupt_affinity(efx);
 	efx_nic_fini_interrupt(efx);
 	efx_fini_port(efx);
 	efx->type->fini(efx);
@@ -3166,6 +3200,9 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	rc = efx_nic_init_interrupt(efx);
 	if (rc)
 		goto fail5;
+
+	efx_set_interrupt_affinity(efx);
+
 	rc = efx_enable_interrupts(efx);
 	if (rc)
 		goto fail6;
@@ -3173,6 +3210,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	return 0;
 
  fail6:
+	efx_clear_interrupt_affinity(efx);
 	efx_nic_fini_interrupt(efx);
  fail5:
 	efx_fini_port(efx);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 38c4223..28c3673 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -423,6 +423,7 @@ enum efx_sync_events_state {
  * @sync_events_state: Current state of sync events on this channel
  * @sync_timestamp_major: Major part of the last ptp sync event
  * @sync_timestamp_minor: Minor part of the last ptp sync event
+ * @irq_mem_node: Memory NUMA node of interrupt
  */
 struct efx_channel {
 	struct efx_nic *efx;
@@ -468,6 +469,8 @@ struct efx_channel {
 	enum efx_sync_events_state sync_events_state;
 	u32 sync_timestamp_major;
 	u32 sync_timestamp_minor;
+
+	int irq_mem_node;
 };
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8956995..eed0c3b 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -163,9 +163,21 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue, bool atomic)
 	do {
 		page = efx_reuse_page(rx_queue);
 		if (page == NULL) {
-			page = alloc_pages(__GFP_COLD | __GFP_COMP |
-					   (atomic ? GFP_ATOMIC : GFP_KERNEL),
-					   efx->rx_buffer_order);
+			/* GFP_ATOMIC may fail because of various reasons,
+			 * and we re-schedule rx_fill from non-atomic
+			 * context in such a case.  So, use __GFP_NO_WARN
+			 * in case of atomic.
+			 */
+			struct efx_channel *channel;
+
+			channel = efx_rx_queue_channel(rx_queue);
+			page = alloc_pages_node(channel->irq_mem_node,
+						__GFP_COMP |
+						(atomic ?
+						 (GFP_ATOMIC | __GFP_NOWARN)
+						 : GFP_KERNEL),
+						efx->rx_buffer_order);
+
 			if (unlikely(page == NULL))
 				return -ENOMEM;
 			dma_addr =
