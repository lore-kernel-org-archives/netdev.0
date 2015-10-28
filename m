From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 3/4] sfc: Use cpu_to_mem() to support memoryless
 nodes
Date: Wed, 28 Oct 2015 15:01:51 +0000
Message-ID: <5630E35F.5060706@solarflare.com>
References: <5630E2FD.3070609@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:12472 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753192AbbJ1PCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 11:02:04 -0400
In-Reply-To: <5630E2FD.3070609@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

With CONFIG_HAVE_MEMORYLESS_NODES cpu_to_node() may return
nodes without memory, which is not a good choice when later
using that to allocate memory. cpu_to_mem() instead provides
the most appropriate NUMA node to allocate from.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        | 2 +-
 drivers/net/ethernet/sfc/net_driver.h | 4 ++--
 drivers/net/ethernet/sfc/rx.c         | 3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 89fbd03..84f9e90 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -445,7 +445,7 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 	channel->efx = efx;
 	channel->channel = i;
 	channel->type = &efx_default_channel_type;
-	channel->irq_node = NUMA_NO_NODE;
+	channel->irq_mem_node = NUMA_NO_NODE;
 
 	for (j = 0; j < EFX_TXQ_TYPES; j++) {
 		tx_queue = &channel->tx_queue[j];
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0ab9080a..bab6cc0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -419,7 +419,7 @@ enum efx_sync_events_state {
  * @sync_events_state: Current state of sync events on this channel
  * @sync_timestamp_major: Major part of the last ptp sync event
  * @sync_timestamp_minor: Minor part of the last ptp sync event
- * @irq_node: NUMA node of interrupt
+ * @irq_mem_node: Memory NUMA node of interrupt
  */
 struct efx_channel {
 	struct efx_nic *efx;
@@ -479,7 +479,7 @@ struct efx_channel {
 	u32 sync_timestamp_major;
 	u32 sync_timestamp_minor;
 
-	int irq_node;
+	int irq_mem_node;
 };
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index c5ef1e8..095d1af 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -171,7 +171,8 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue, bool atomic)
 			struct efx_channel *channel;
 
 			channel = efx_rx_queue_channel(rx_queue);
-			page = alloc_pages_node(channel->irq_node, __GFP_COMP |
+			page = alloc_pages_node(channel->irq_mem_node,
+						__GFP_COMP |
 						(atomic ?
 						 (GFP_ATOMIC | __GFP_NOWARN)
 						 : GFP_KERNEL),
