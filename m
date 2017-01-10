From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/3] sfc: support ndo_get_phys_port_id even when
 !CONFIG_SFC_SRIOV
Date: Tue, 10 Jan 2017 16:23:33 +0000
Message-ID: <7ff985b9-7339-ecfb-cdae-ba4d28e36c36@solarflare.com>
References: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:28341 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751116AbdAJQYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:24:04 -0500
In-Reply-To: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

There's no good reason why this should be an SRIOV-only thing.
Thus, also move it out of SRIOV-specific files.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 17 ++++++++++++++++-
 drivers/net/ethernet/sfc/ef10_sriov.c | 14 --------------
 drivers/net/ethernet/sfc/ef10_sriov.h |  3 ---
 drivers/net/ethernet/sfc/efx.c        | 13 ++++++++++++-
 drivers/net/ethernet/sfc/net_driver.h |  5 +++--
 drivers/net/ethernet/sfc/sriov.c      | 11 -----------
 drivers/net/ethernet/sfc/sriov.h      |  3 ---
 7 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 5eb0e68..4f3c965 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5540,6 +5540,20 @@ static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 	}
 }
 
+static int efx_ef10_get_phys_port_id(struct efx_nic *efx,
+				     struct netdev_phys_item_id *ppid)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	if (!is_valid_ether_addr(nic_data->port_id))
+		return -EOPNOTSUPP;
+
+	ppid->id_len = ETH_ALEN;
+	memcpy(ppid->id, nic_data->port_id, ppid->id_len);
+
+	return 0;
+}
+
 static int efx_ef10_vlan_rx_add_vid(struct efx_nic *efx, __be16 proto, u16 vid)
 {
 	if (proto != htons(ETH_P_8021Q))
@@ -5647,11 +5661,11 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.vswitching_probe = efx_ef10_vswitching_probe_vf,
 	.vswitching_restore = efx_ef10_vswitching_restore_vf,
 	.vswitching_remove = efx_ef10_vswitching_remove_vf,
-	.sriov_get_phys_port_id = efx_ef10_sriov_get_phys_port_id,
 #endif
 	.get_mac_address = efx_ef10_get_mac_address_vf,
 	.set_mac_address = efx_ef10_set_mac_address,
 
+	.get_phys_port_id = efx_ef10_get_phys_port_id,
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
 	.rx_prefix_size = ES_DZ_RX_PREFIX_SIZE,
@@ -5776,6 +5790,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.set_mac_address = efx_ef10_set_mac_address,
 	.tso_versions = efx_ef10_tso_versions,
 
+	.get_phys_port_id = efx_ef10_get_phys_port_id,
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
 	.rx_prefix_size = ES_DZ_RX_PREFIX_SIZE,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index a949b9d..a55c53d 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -760,17 +760,3 @@ int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 
 	return 0;
 }
-
-int efx_ef10_sriov_get_phys_port_id(struct efx_nic *efx,
-				    struct netdev_phys_item_id *ppid)
-{
-	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-
-	if (!is_valid_ether_addr(nic_data->port_id))
-		return -EOPNOTSUPP;
-
-	ppid->id_len = ETH_ALEN;
-	memcpy(ppid->id, nic_data->port_id, ppid->id_len);
-
-	return 0;
-}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 9ceb7ef..2aa444e 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -56,9 +56,6 @@ int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 int efx_ef10_sriov_set_vf_link_state(struct efx_nic *efx, int vf_i,
 				     int link_state);
 
-int efx_ef10_sriov_get_phys_port_id(struct efx_nic *efx,
-				    struct netdev_phys_item_id *ppid);
-
 int efx_ef10_vswitching_probe_pf(struct efx_nic *efx);
 int efx_ef10_vswitching_probe_vf(struct efx_nic *efx);
 int efx_ef10_vswitching_restore_pf(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index bbbed2e..c1aefbd9 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2336,6 +2336,17 @@ static int efx_set_features(struct net_device *net_dev, netdev_features_t data)
 	return 0;
 }
 
+int efx_get_phys_port_id(struct net_device *net_dev,
+			 struct netdev_phys_item_id *ppid)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (efx->type->get_phys_port_id)
+		return efx->type->get_phys_port_id(efx, ppid);
+	else
+		return -EOPNOTSUPP;
+}
+
 static int efx_vlan_rx_add_vid(struct net_device *net_dev, __be16 proto, u16 vid)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
@@ -2376,8 +2387,8 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_set_vf_spoofchk	= efx_sriov_set_vf_spoofchk,
 	.ndo_get_vf_config	= efx_sriov_get_vf_config,
 	.ndo_set_vf_link_state  = efx_sriov_set_vf_link_state,
-	.ndo_get_phys_port_id   = efx_sriov_get_phys_port_id,
 #endif
+	.ndo_get_phys_port_id   = efx_get_phys_port_id,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
 #endif
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 1c62c1a..49db9e8 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1220,6 +1220,7 @@ struct efx_mtd_partition {
  * @ptp_set_ts_config: Set hardware timestamp configuration.  The flags
  *	and tx_type will already have been validated but this operation
  *	must validate and update rx_filter.
+ * @get_phys_port_id: Get the underlying physical port id.
  * @set_mac_address: Set the MAC address of the device
  * @tso_versions: Returns mask of firmware-assisted TSO versions supported.
  *	If %NULL, then device does not support any TSO version.
@@ -1358,6 +1359,8 @@ struct efx_nic_type {
 	int (*sriov_configure)(struct efx_nic *efx, int num_vfs);
 	int (*vlan_rx_add_vid)(struct efx_nic *efx, __be16 proto, u16 vid);
 	int (*vlan_rx_kill_vid)(struct efx_nic *efx, __be16 proto, u16 vid);
+	int (*get_phys_port_id)(struct efx_nic *efx,
+				struct netdev_phys_item_id *ppid);
 	int (*sriov_init)(struct efx_nic *efx);
 	void (*sriov_fini)(struct efx_nic *efx);
 	bool (*sriov_wanted)(struct efx_nic *efx);
@@ -1372,8 +1375,6 @@ struct efx_nic_type {
 				   struct ifla_vf_info *ivi);
 	int (*sriov_set_vf_link_state)(struct efx_nic *efx, int vf_i,
 				       int link_state);
-	int (*sriov_get_phys_port_id)(struct efx_nic *efx,
-				      struct netdev_phys_item_id *ppid);
 	int (*vswitching_probe)(struct efx_nic *efx);
 	int (*vswitching_restore)(struct efx_nic *efx);
 	void (*vswitching_remove)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/sriov.c b/drivers/net/ethernet/sfc/sriov.c
index 9abcf4a..0b766fd 100644
--- a/drivers/net/ethernet/sfc/sriov.c
+++ b/drivers/net/ethernet/sfc/sriov.c
@@ -73,14 +73,3 @@ int efx_sriov_set_vf_link_state(struct net_device *net_dev, int vf_i,
 	else
 		return -EOPNOTSUPP;
 }
-
-int efx_sriov_get_phys_port_id(struct net_device *net_dev,
-			       struct netdev_phys_item_id *ppid)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-
-	if (efx->type->sriov_get_phys_port_id)
-		return efx->type->sriov_get_phys_port_id(efx, ppid);
-	else
-		return -EOPNOTSUPP;
-}
diff --git a/drivers/net/ethernet/sfc/sriov.h b/drivers/net/ethernet/sfc/sriov.h
index ba1762e..84c7984 100644
--- a/drivers/net/ethernet/sfc/sriov.h
+++ b/drivers/net/ethernet/sfc/sriov.h
@@ -23,9 +23,6 @@ int efx_sriov_get_vf_config(struct net_device *net_dev, int vf_i,
 			    struct ifla_vf_info *ivi);
 int efx_sriov_set_vf_link_state(struct net_device *net_dev, int vf_i,
 				int link_state);
-int efx_sriov_get_phys_port_id(struct net_device *net_dev,
-			       struct netdev_phys_item_id *ppid);
-
 #endif /* CONFIG_SFC_SRIOV */
 
 #endif /* EFX_SRIOV_H */
