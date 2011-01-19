From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 5/5] sfc: Implement hardware acceleration of
 RFS
Date: Wed, 19 Jan 2011 21:06:33 +0000
Message-ID: <1295471193.11126.90.camel@bwh-desktop>
References: <1295470787.11126.82.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15514 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab1ASVGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 16:06:37 -0500
In-Reply-To: <1295470787.11126.82.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
I consider this experimental still, so it's not signed-off.

Ben.

 drivers/net/sfc/efx.c        |   49 +++++++++++++++++++++-
 drivers/net/sfc/efx.h        |   16 +++++++
 drivers/net/sfc/filter.c     |   94 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/net_driver.h |    3 +
 4 files changed, 160 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 002bac7..607316d 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -21,6 +21,7 @@
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include <linux/gfp.h>
+#include <linux/cpu_rmap.h>
 #include "net_driver.h"
 #include "efx.h"
 #include "nic.h"
@@ -307,6 +308,8 @@ static int efx_poll(struct napi_struct *napi, int budget)
 			channel->irq_mod_score = 0;
 		}
 
+		efx_filter_rfs_expire(channel);
+
 		/* There is no race here; although napi_disable() will
 		 * only wait for napi_complete(), this isn't a problem
 		 * since efx_channel_processed() will have no effect if
@@ -1175,10 +1178,32 @@ static int efx_wanted_channels(void)
 	return count;
 }
 
+static int
+efx_init_rx_cpu_rmap(struct efx_nic *efx, struct msix_entry *xentries)
+{
+#ifdef CONFIG_RFS_ACCEL
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
@@ -1220,6 +1245,11 @@ static void efx_probe_interrupts(struct efx_nic *efx)
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
@@ -1253,6 +1283,8 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		efx->n_tx_channels = 1;
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
+
+	return 0;
 }
 
 static void efx_remove_interrupts(struct efx_nic *efx)
@@ -1302,7 +1334,9 @@ static int efx_probe_nic(struct efx_nic *efx)
 
 	/* Determine the number of channels and queues by trying to hook
 	 * in MSI-X interrupts. */
-	efx_probe_interrupts(efx);
+	rc = efx_probe_interrupts(efx);
+	if (rc)
+		goto fail;
 
 	if (efx->n_channels > 1)
 		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
@@ -1317,6 +1351,10 @@ static int efx_probe_nic(struct efx_nic *efx)
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
 
 	return 0;
+
+fail:
+	efx->type->remove(efx);
+	return rc;
 }
 
 static void efx_remove_nic(struct efx_nic *efx)
@@ -1849,6 +1887,9 @@ static const struct net_device_ops efx_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
 #endif
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer	= efx_filter_rfs,
+#endif
 };
 
 static void efx_update_name(struct efx_nic *efx)
@@ -2288,6 +2329,10 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
+#ifdef CONFIG_RFS_ACCEL
+	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
+	efx->net_dev->rx_cpu_rmap = NULL;
+#endif
 	efx_nic_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index d43a7e5..82c6c53 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -74,6 +74,22 @@ extern int efx_filter_remove_filter(struct efx_nic *efx,
 				    struct efx_filter_spec *spec);
 extern void efx_filter_clear_rx(struct efx_nic *efx,
 				enum efx_filter_priority priority);
+#ifdef CONFIG_RFS_ACCEL
+extern int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+			  u16 rxq_index, u32 flow_id);
+extern unsigned __efx_filter_rfs_expire(struct efx_nic *efx, unsigned quota);
+static inline void efx_filter_rfs_expire(struct efx_channel *channel)
+{
+	if (channel->rfs_filters_added >= 100) {
+		channel->rfs_filters_added -=
+			__efx_filter_rfs_expire(channel->efx, 100);
+	}
+}
+#define efx_filter_rfs_enabled() 1
+#else
+static inline void efx_filter_rfs_expire(struct efx_channel *channel) {}
+#define efx_filter_rfs_enabled() 0
+#endif
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index 47a1b79..987cae4 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/in.h>
+#include <net/ip.h>
 #include "efx.h"
 #include "filter.h"
 #include "io.h"
@@ -51,6 +52,10 @@ struct efx_filter_table {
 struct efx_filter_state {
 	spinlock_t	lock;
 	struct efx_filter_table table[EFX_FILTER_TABLE_COUNT];
+#ifdef CONFIG_RFS_ACCEL
+	u32		*rps_flow_id;
+	unsigned	rps_expire_index;
+#endif
 };
 
 /* The filter hash function is LFSR polynomial x^16 + x^3 + 1 of a 32-bit
@@ -567,6 +572,13 @@ int efx_probe_filters(struct efx_nic *efx)
 	spin_lock_init(&state->lock);
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+#ifdef CONFIG_RFS_ACCEL
+		state->rps_flow_id = kcalloc(FR_BZ_RX_FILTER_TBL0_ROWS,
+					     sizeof(*state->rps_flow_id),
+					     GFP_KERNEL);
+		if (!state->rps_flow_id)
+			goto fail;
+#endif
 		table = &state->table[EFX_FILTER_TABLE_RX_IP];
 		table->id = EFX_FILTER_TABLE_RX_IP;
 		table->offset = FR_BZ_RX_FILTER_TBL0;
@@ -612,5 +624,87 @@ void efx_remove_filters(struct efx_nic *efx)
 		kfree(state->table[table_id].used_bitmap);
 		vfree(state->table[table_id].spec);
 	}
+#ifdef CONFIG_RFS_ACCEL
+	kfree(state->rps_flow_id);
+#endif
 	kfree(state);
 }
+
+#ifdef CONFIG_RFS_ACCEL
+
+int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+		   u16 rxq_index, u32 flow_id)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_channel *channel;
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
+	efx_filter_init_rx(&spec, EFX_FILTER_PRI_HINT, 0, rxq_index);
+	rc = efx_filter_set_ipv4_full(&spec, ip->protocol,
+				      ip->daddr, ports[1], ip->saddr, ports[0]);
+	if (rc)
+		return rc;
+
+	rc = efx_filter_insert_filter(efx, &spec, true);
+	if (rc < 0)
+		return rc;
+
+	/* Remember this so we can check whether to expire the filter later */
+	state->rps_flow_id[rc] = flow_id;
+	channel = efx_get_channel(efx, skb_get_rx_queue(skb));
+	++channel->rfs_filters_added;
+
+	return rc;
+}
+
+unsigned __efx_filter_rfs_expire(struct efx_nic *efx, unsigned quota)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	struct efx_filter_table *table = &state->table[EFX_FILTER_TABLE_RX_IP];
+	unsigned mask = table->size - 1;
+	unsigned index;
+	unsigned stop;
+
+	if (!spin_trylock_bh(&state->lock))
+		return 0;
+
+	index = state->rps_expire_index;
+	stop = (index + quota) & mask;
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
+		efx_filter_table_reset_search_depth(table);
+
+	spin_unlock_bh(&state->lock);
+	return quota;
+}
+
+#endif /* CONFIG_RFS_ACCEL */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 28df866..b92f442 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -358,6 +358,9 @@ struct efx_channel {
 
 	unsigned int irq_count;
 	unsigned int irq_mod_score;
+#ifdef CONFIG_RFS_ACCEL
+	unsigned int rfs_filters_added;
+#endif
 
 	int rx_alloc_level;
 	int rx_alloc_push_pages;
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

