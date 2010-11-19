From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 5/5] sfc: Implement RFS acceleration
Date: Fri, 19 Nov 2010 18:48:53 +0000
Message-ID: <1290192533.2671.45.camel@bwh-desktop>
References: <1290192176.2671.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23689 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab0KSSs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 13:48:56 -0500
In-Reply-To: <1290192176.2671.38.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/sfc/Kconfig  |    4 ++
 drivers/net/sfc/efx.c    |   66 ++++++++++++++++++++++++++----
 drivers/net/sfc/efx.h    |    9 ++++
 drivers/net/sfc/filter.c |  100 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 170 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index a65c986..8d286c3 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -20,3 +20,7 @@ config SFC_MTD
 	  This exposes the on-board flash memory as MTD devices (e.g.
 	  /dev/mtd1).  This makes it possible to upload new firmware
 	  to the NIC.
+config SFC_RFS_ACCEL
+	bool
+	depends on SFC && RPS && GENERIC_HARDIRQS
+	default y
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 05df20e..ee2118a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -21,6 +21,7 @@
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include <linux/gfp.h>
+#include <linux/cpu_rmap.h>
 #include "net_driver.h"
 #include "efx.h"
 #include "mdio_10g.h"
@@ -119,6 +120,8 @@ static int napi_weight = 64;
  * monitor.  On Falcon-based NICs, this will:
  * - Check the on-board hardware monitor;
  * - Poll the link state and reconfigure the hardware as necessary.
+ * If RFS is enabled, this will scan part of the RX IP filter table and
+ * remove filters for inactive flows.
  */
 static unsigned int efx_monitor_interval = 1 * HZ;
 
@@ -1163,10 +1166,32 @@ static int efx_wanted_channels(void)
 	return count;
 }
 
+static int
+efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
+{
+#ifdef CONFIG_SFC_RFS_ACCEL
+	int i, rc;
+
+	efx->net_dev->rx_cpu_rmap = alloc_irq_cpu_rmap(efx->n_rx_channels);
+	if (!efx->net_dev->rx_cpu_rmap)
+		return -ENOMEM;
+	for (i = 0; i < efx->n_rx_channels; i++) {
+		rc = irq_cpu_rmap_add(efx->net_dev->rx_cpu_rmap,
+				      xentries[i].vector);
+		if (rc) {
+			free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+			efx->net_dev->rx_cpu_rmap = NULL;
+			return rc;
+		}
+	}
+#endif
+	return 0;
+}
+
 /* Probe the number and type of interrupts we are able to obtain, and
  * the resulting numbers of channels and RX queues.
  */
-static void efx_probe_interrupts(struct efx_nic *efx)
+static int efx_probe_interrupts(struct efx_nic *efx)
 {
 	int max_channels =
 		min_t(int, efx->type->phys_addr_channels, EFX_MAX_CHANNELS);
@@ -1208,6 +1233,11 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 				efx->n_tx_channels = efx->n_channels;
 				efx->n_rx_channels = efx->n_channels;
 			}
+			rc = efx_init_rx_cpu_rmap(efx, xentries);
+			if (rc) {
+				pci_disable_msix(efx->pci_dev);
+				return rc;
+			}
 			for (i = 0; i < n_channels; i++)
 				efx_get_channel(efx, i)->irq =
 					xentries[i].vector;
@@ -1241,6 +1271,8 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		efx->n_tx_channels = 1;
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
+
+	return 0;
 }
 
 static void efx_remove_interrupts(struct efx_nic *efx)
@@ -1299,7 +1331,9 @@ static int efx_probe_nic(struct efx_nic *efx)
 
 	/* Determine the number of channels and queues by trying to hook
 	 * in MSI-X interrupts. */
-	efx_probe_interrupts(efx);
+	rc = efx_probe_interrupts(efx);
+	if (rc)
+		goto fail;
 
 	if (efx->n_channels > 1)
 		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
@@ -1314,6 +1348,10 @@ static int efx_probe_nic(struct efx_nic *efx)
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
 
 	return 0;
+
+fail:
+	efx->type->remove(efx);
+	return rc;
 }
 
 static void efx_remove_nic(struct efx_nic *efx)
@@ -1411,13 +1449,15 @@ static void efx_start_all(struct efx_nic *efx)
 	if (efx->reset_pending != RESET_TYPE_NONE)
 		efx_mcdi_mode_poll(efx);
 
-	/* Start the hardware monitor if there is one. Otherwise (we're link
-	 * event driven), we have to poll the PHY because after an event queue
-	 * flush, we could have a missed a link state change */
-	if (efx->type->monitor != NULL) {
+	/* Start the periodic monitor if necessary */
+	if (efx->type->monitor || efx_filter_rfs_enabled())
 		queue_delayed_work(efx->workqueue, &efx->monitor_work,
 				   efx_monitor_interval);
-	} else {
+
+	/* If we normally rely on link state events, we have to poll
+	 * the PHY because after an event queue flush, we could have a
+	 * missed a link state change */
+	if (!efx->type->monitor) {
 		mutex_lock(&efx->mac_lock);
 		if (efx->phy_op->poll(efx))
 			efx_link_status_changed(efx);
@@ -1548,17 +1588,18 @@ static void efx_monitor(struct work_struct *data)
 	netif_vdbg(efx, timer, efx->net_dev,
 		   "hardware monitor executing on CPU %d\n",
 		   raw_smp_processor_id());
-	BUG_ON(efx->type->monitor == NULL);
 
 	/* If the mac_lock is already held then it is likely a port
 	 * reconfiguration is already in place, which will likely do
 	 * most of the work of monitor() anyway. */
-	if (mutex_trylock(&efx->mac_lock)) {
+	if (efx->type->monitor && mutex_trylock(&efx->mac_lock)) {
 		if (efx->port_enabled)
 			efx->type->monitor(efx);
 		mutex_unlock(&efx->mac_lock);
 	}
 
+	efx_filter_rfs_expire(efx);
+
 	queue_delayed_work(efx->workqueue, &efx->monitor_work,
 			   efx_monitor_interval);
 }
@@ -1841,6 +1882,9 @@ static const struct net_device_ops efx_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
 #endif
+#ifdef CONFIG_SFC_RFS_ACCEL
+	.ndo_rx_flow_steer	= efx_filter_rfs,
+#endif
 };
 
 static void efx_update_name(struct efx_nic *efx)
@@ -2276,6 +2320,10 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
+#ifdef CONFIG_SFC_RFS_ACCEL
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+#endif
 	efx_nic_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 10a1bf4..8b8cf63 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -77,6 +77,15 @@ extern int efx_filter_remove_filter(struct efx_nic *efx,
 extern void efx_filter_table_clear(struct efx_nic *efx,
 				   enum efx_filter_table_id table_id,
 				   enum efx_filter_priority priority);
+#ifdef CONFIG_SFC_RFS_ACCEL
+extern int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+			  u16 rxq_index, u32 flow_id);
+extern void efx_filter_rfs_expire(struct efx_nic *efx);
+#define efx_filter_rfs_enabled() 1
+#else
+static inline void efx_filter_rfs_expire(struct efx_nic *efx) {}
+#define efx_filter_rfs_enabled() 0
+#endif
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index e0ad1b8..2f64703 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -7,6 +7,8 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
+#include <net/ip.h>
+
 #include "efx.h"
 #include "filter.h"
 #include "io.h"
@@ -43,6 +45,10 @@ struct efx_filter_state {
 	spinlock_t	lock;
 	struct efx_filter_table table[EFX_FILTER_TABLE_COUNT];
 	unsigned	search_depth[EFX_FILTER_TYPE_COUNT];
+#ifdef CONFIG_SFC_RFS_ACCEL
+	u32		*rps_flow_id;
+	unsigned	rps_expire_index;
+#endif
 };
 
 /* The filter hash function is LFSR polynomial x^16 + x^3 + 1 of a 32-bit
@@ -411,6 +417,13 @@ int efx_probe_filters(struct efx_nic *efx)
 	spin_lock_init(&state->lock);
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+#ifdef CONFIG_SFC_RFS_ACCEL
+		state->rps_flow_id = kcalloc(FR_BZ_RX_FILTER_TBL0_ROWS,
+					     sizeof(*state->rps_flow_id),
+					     GFP_KERNEL);
+		if (!state->rps_flow_id)
+			goto fail;
+#endif
 		table = &state->table[EFX_FILTER_TABLE_RX_IP];
 		table->offset = FR_BZ_RX_FILTER_TBL0;
 		table->size = FR_BZ_RX_FILTER_TBL0_ROWS;
@@ -455,5 +468,92 @@ void efx_remove_filters(struct efx_nic *efx)
 		kfree(state->table[table_id].used_bitmap);
 		vfree(state->table[table_id].spec);
 	}
+#ifdef CONFIG_SFC_RFS_ACCEL
+	kfree(state->rps_flow_id);
+#endif
 	kfree(state);
 }
+
+#ifdef CONFIG_SFC_RFS_ACCEL
+
+int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+		   u16 rxq_index, u32 flow_id)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_filter_state *state = efx->filter_state;
+	struct efx_filter_spec spec;
+	const struct iphdr *ip;
+	const __be16 *ports;
+	int nhoff;
+	int rc;
+
+	nhoff = skb_network_offset(skb);
+
+	if (skb->protocol != htons(ETH_P_IP))
+		return -EPROTONOSUPPORT;
+
+	/* RFS must validate the IP header length before calling us */
+	EFX_BUG_ON_PARANOID(!pskb_may_pull(skb, nhoff + sizeof(*ip)));
+	ip = (const struct iphdr *)(skb->data + nhoff);
+	if (ip->frag_off & htons(IP_MF | IP_OFFSET))
+		return -EPROTONOSUPPORT;
+	EFX_BUG_ON_PARANOID(!pskb_may_pull(skb, nhoff + 4 * ip->ihl + 4));
+	ports = (const __be16 *)(skb->data + nhoff + 4 * ip->ihl);
+
+	switch (ip->protocol) {
+	case IPPROTO_TCP:
+		efx_filter_set_rx_tcp_full(&spec,
+					   ntohl(ip->saddr), ntohs(ports[0]),
+					   ntohl(ip->daddr), ntohs(ports[1]));
+		break;
+	case IPPROTO_UDP:
+		efx_filter_set_rx_udp_full(&spec,
+					   ntohl(ip->saddr), ntohs(ports[0]),
+					   ntohl(ip->daddr), ntohs(ports[1]));
+		break;
+	default:
+		return -EPROTONOSUPPORT;
+	}
+	spec.priority = EFX_FILTER_PRI_HINT;
+	spec.dmaq_id = rxq_index;
+
+	rc = efx_filter_insert_filter(efx, &spec, true);
+	if (rc >= 0)
+		state->rps_flow_id[rc] = flow_id;
+
+	return rc;
+}
+
+void efx_filter_rfs_expire(struct efx_nic *efx)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	struct efx_filter_table *table = &state->table[EFX_FILTER_TABLE_RX_IP];
+	unsigned mask = table->size - 1;
+	unsigned index;
+	unsigned stop;
+
+	spin_lock_bh(&state->lock);
+
+	/* Check filters in batches of 1024 */
+	index = state->rps_expire_index;
+	stop = (index + 1024) & mask;
+	
+	while (index != stop) {
+		if (test_bit(index, table->used_bitmap) &&
+		    table->spec[index].priority == EFX_FILTER_PRI_HINT &&
+		    rps_may_expire_flow(efx->net_dev,
+					table->spec[index].dmaq_id,
+					state->rps_flow_id[index], index))
+			efx_filter_table_clear_entry(efx, table, index);
+		index = (index + 1) & mask;
+	}
+
+	state->rps_expire_index = stop;
+	if (table->used == 0)
+		efx_filter_table_reset_search_depth(state,
+						    EFX_FILTER_TABLE_RX_IP);
+
+	spin_unlock_bh(&state->lock);
+}
+
+#endif /* CONFIG_SFC_RFS_ACCEL */
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

