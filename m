From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 10/17] sfc: Implement ndo_vlan_rx_{add,kill}_vid()
 callbacks
Date: Wed, 15 Jun 2016 17:48:32 +0100
Message-ID: <e5ebdbfb-4e9f-7d35-8dfa-11c456eb759a@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:59198 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753138AbcFOQuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:35 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Supports HW VLAN filtering, en/disabled using ethtool.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 86 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/efx.c        | 38 +++++++++++++++-
 drivers/net/ethernet/sfc/net_driver.h |  2 +
 3 files changed, 124 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 6dd0a79..a3c00ff 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -101,6 +101,7 @@ struct efx_ef10_filter_table {
 	bool mc_promisc;
 /* Whether in multicast promiscuous mode when last changed */
 	bool mc_promisc_last;
+	bool vlan_filter;
 	struct list_head vlan_list;
 };
 
@@ -323,6 +324,11 @@ static int efx_ef10_add_vlan(struct efx_nic *efx, u16 vid)
 
 	vlan = efx_ef10_find_vlan(efx, vid);
 	if (vlan) {
+		/* We add VID 0 on init. 8021q adds it on module init
+		 * for all interfaces with VLAN filtring feature.
+		 */
+		if (vid == 0)
+			goto done_unlock;
 		netif_warn(efx, drv, efx->net_dev,
 			   "VLAN %u already added\n", vid);
 		rc = -EALREADY;
@@ -348,6 +354,7 @@ static int efx_ef10_add_vlan(struct efx_nic *efx, u16 vid)
 			goto fail_filter_add_vlan;
 	}
 
+done_unlock:
 	mutex_unlock(&nic_data->vlan_lock);
 	return 0;
 
@@ -377,6 +384,35 @@ static void efx_ef10_del_vlan_internal(struct efx_nic *efx,
 	kfree(vlan);
 }
 
+static int efx_ef10_del_vlan(struct efx_nic *efx, u16 vid)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_ef10_vlan *vlan;
+	int rc = 0;
+
+	/* 8021q removes VID 0 on module unload for all interfaces
+	 * with VLAN filtering feature. We need to keep it to receive
+	 * untagged traffic.
+	 */
+	if (vid == 0)
+		return 0;
+
+	mutex_lock(&nic_data->vlan_lock);
+
+	vlan = efx_ef10_find_vlan(efx, vid);
+	if (!vlan) {
+		netif_err(efx, drv, efx->net_dev,
+			  "VLAN %u to be deleted not found\n", vid);
+		rc = -ENOENT;
+	} else {
+		efx_ef10_del_vlan_internal(efx, vlan);
+	}
+
+	mutex_unlock(&nic_data->vlan_lock);
+
+	return rc;
+}
+
 static void efx_ef10_cleanup_vlans(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
@@ -542,8 +578,18 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail_add_vid_unspec;
 
+	/* If VLAN filtering is enabled, we need VID 0 to get untagged
+	 * traffic.  It is added automatically if 8021q module is loaded,
+	 * but we can't rely on it since module may be not loaded.
+	 */
+	rc = efx_ef10_add_vlan(efx, 0);
+	if (rc)
+		goto fail_add_vid_0;
+
 	return 0;
 
+fail_add_vid_0:
+	efx_ef10_cleanup_vlans(efx);
 fail_add_vid_unspec:
 	mutex_destroy(&nic_data->vlan_lock);
 	efx_ptp_remove(efx);
@@ -3928,6 +3974,8 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	}
 
 	table->mc_promisc_last = false;
+	table->vlan_filter =
+		!!(efx->net_dev->features & NETIF_F_HW_VLAN_CTAG_FILTER);
 	INIT_LIST_HEAD(&table->vlan_list);
 
 	efx->filter_state = table;
@@ -4400,6 +4448,12 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
+	/* Do not install unspecified VID if VLAN filtering is enabled.
+	 * Do not install all specified VIDs if VLAN filtering is disabled.
+	 */
+	if ((vlan->vid == EFX_FILTER_VID_UNSPEC) == table->vlan_filter)
+		return;
+
 	/* Insert/renew unicast filters */
 	if (table->uc_promisc) {
 		efx_ef10_filter_insert_def(efx, vlan, false, false);
@@ -4463,6 +4517,7 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct net_device *net_dev = efx->net_dev;
 	struct efx_ef10_filter_vlan *vlan;
+	bool vlan_filter;
 
 	if (!efx_dev_registered(efx))
 		return;
@@ -4480,6 +4535,16 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	efx_ef10_filter_mc_addr_list(efx);
 	netif_addr_unlock_bh(net_dev);
 
+	/* If VLAN filtering changes, all old filters are finally removed.
+	 * Do it in advance to avoid conflicts for unicast untagged and
+	 * VLAN 0 tagged filters.
+	 */
+	vlan_filter = !!(net_dev->features & NETIF_F_HW_VLAN_CTAG_FILTER);
+	if (table->vlan_filter != vlan_filter) {
+		table->vlan_filter = vlan_filter;
+		efx_ef10_filter_remove_old(efx);
+	}
+
 	list_for_each_entry(vlan, &table->vlan_list, list)
 		efx_ef10_filter_vlan_sync_rx_mode(efx, vlan);
 
@@ -5014,8 +5079,25 @@ static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 	}
 }
 
+static int efx_ef10_vlan_rx_add_vid(struct efx_nic *efx, __be16 proto, u16 vid)
+{
+	if (proto != htons(ETH_P_8021Q))
+		return -EINVAL;
+
+	return efx_ef10_add_vlan(efx, vid);
+}
+
+static int efx_ef10_vlan_rx_kill_vid(struct efx_nic *efx, __be16 proto, u16 vid)
+{
+	if (proto != htons(ETH_P_8021Q))
+		return -EINVAL;
+
+	return efx_ef10_del_vlan(efx, vid);
+}
+
 #define EF10_OFFLOAD_FEATURES		\
 	(NETIF_F_IP_CSUM |		\
+	 NETIF_F_HW_VLAN_CTAG_FILTER |	\
 	 NETIF_F_IPV6_CSUM |		\
 	 NETIF_F_RXHASH |		\
 	 NETIF_F_NTUPLE)
@@ -5097,6 +5179,8 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 #endif
 	.ptp_write_host_time = efx_ef10_ptp_write_host_time_vf,
 	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config_vf,
+	.vlan_rx_add_vid = efx_ef10_vlan_rx_add_vid,
+	.vlan_rx_kill_vid = efx_ef10_vlan_rx_kill_vid,
 #ifdef CONFIG_SFC_SRIOV
 	.vswitching_probe = efx_ef10_vswitching_probe_vf,
 	.vswitching_restore = efx_ef10_vswitching_restore_vf,
@@ -5207,6 +5291,8 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.ptp_write_host_time = efx_ef10_ptp_write_host_time,
 	.ptp_set_ts_sync_events = efx_ef10_ptp_set_ts_sync_events,
 	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config,
+	.vlan_rx_add_vid = efx_ef10_vlan_rx_add_vid,
+	.vlan_rx_kill_vid = efx_ef10_vlan_rx_kill_vid,
 #ifdef CONFIG_SFC_SRIOV
 	.sriov_configure = efx_ef10_sriov_configure,
 	.sriov_init = efx_ef10_sriov_init,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2eecd28..902bcf2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2322,14 +2322,46 @@ static void efx_set_rx_mode(struct net_device *net_dev)
 static int efx_set_features(struct net_device *net_dev, netdev_features_t data)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	int rc;
 
 	/* If disabling RX n-tuple filtering, clear existing filters */
-	if (net_dev->features & ~data & NETIF_F_NTUPLE)
-		return efx->type->filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
+	if (net_dev->features & ~data & NETIF_F_NTUPLE) {
+		rc = efx->type->filter_clear_rx(efx, EFX_FILTER_PRI_MANUAL);
+		if (rc)
+			return rc;
+	}
+
+	/* If Rx VLAN filter is changed, update filters via mac_reconfigure */
+	if ((net_dev->features ^ data) & NETIF_F_HW_VLAN_CTAG_FILTER) {
+		/* efx_set_rx_mode() will schedule MAC work to update filters
+		 * when a new features are finally set in net_dev.
+		 */
+		efx_set_rx_mode(net_dev);
+	}
 
 	return 0;
 }
 
+static int efx_vlan_rx_add_vid(struct net_device *net_dev, __be16 proto, u16 vid)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->vlan_rx_add_vid)
+		return efx->type->vlan_rx_add_vid(efx, proto, vid);
+	else
+		return -EOPNOTSUPP;
+}
+
+static int efx_vlan_rx_kill_vid(struct net_device *net_dev, __be16 proto, u16 vid)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->vlan_rx_kill_vid)
+		return efx->type->vlan_rx_kill_vid(efx, proto, vid);
+	else
+		return -EOPNOTSUPP;
+}
+
 static const struct net_device_ops efx_netdev_ops = {
 	.ndo_open		= efx_net_open,
 	.ndo_stop		= efx_net_stop,
@@ -2342,6 +2374,8 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_set_mac_address	= efx_set_mac_address,
 	.ndo_set_rx_mode	= efx_set_rx_mode,
 	.ndo_set_features	= efx_set_features,
+	.ndo_vlan_rx_add_vid	= efx_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= efx_vlan_rx_kill_vid,
 #ifdef CONFIG_SFC_SRIOV
 	.ndo_set_vf_mac		= efx_sriov_set_vf_mac,
 	.ndo_set_vf_vlan	= efx_sriov_set_vf_vlan,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 26abb5c..7613f79 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1334,6 +1334,8 @@ struct efx_nic_type {
 	int (*ptp_set_ts_config)(struct efx_nic *efx,
 				 struct hwtstamp_config *init);
 	int (*sriov_configure)(struct efx_nic *efx, int num_vfs);
+	int (*vlan_rx_add_vid)(struct efx_nic *efx, __be16 proto, u16 vid);
+	int (*vlan_rx_kill_vid)(struct efx_nic *efx, __be16 proto, u16 vid);
 	int (*sriov_init)(struct efx_nic *efx);
 	void (*sriov_fini)(struct efx_nic *efx);
 	bool (*sriov_wanted)(struct efx_nic *efx);
