From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 11/14] sfc: manually allocate and free vadaptors
Date: Wed, 6 May 2015 00:58:54 +0100
Message-ID: <5549593E.40603@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42981 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753565AbbEEX7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:59:01 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be able to use MC_CMD_VADAPTOR_SET_MAC, vadaptors must be
manually allocated and freed as automatic vadaptors will disappear
when their reference_count reaches zero, which must happen before
the MAC address is changed.

Vadaptors are allocated and freed in the vswitching_probe/remove
functions for PFs and VFs, and this means that vadaptors are restored
correctly following an MC reboot or other reset when required.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 12 +++---
 drivers/net/ethernet/sfc/ef10_sriov.c | 71 +++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sfc/ef10_sriov.h |  9 +++--
 3 files changed, 76 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index ae98e42..0dff812 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3760,9 +3760,9 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.ptp_write_host_time = efx_ef10_ptp_write_host_time_vf,
 	.ptp_set_ts_config = efx_ef10_ptp_set_ts_config_vf,
 #ifdef CONFIG_SFC_SRIOV
-	.vswitching_probe = efx_port_dummy_op_int,
-	.vswitching_restore = efx_port_dummy_op_int,
-	.vswitching_remove = efx_port_dummy_op_void,
+	.vswitching_probe = efx_ef10_vswitching_probe_vf,
+	.vswitching_restore = efx_ef10_vswitching_restore_vf,
+	.vswitching_remove = efx_ef10_vswitching_remove_vf,
 #endif
 	.revision = EFX_REV_HUNT_A0,
 	.max_dma_mask = DMA_BIT_MASK(ESF_DZ_TX_KER_BUF_ADDR_WIDTH),
@@ -3876,9 +3876,9 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.sriov_set_vf_vlan = efx_ef10_sriov_set_vf_vlan,
 	.sriov_set_vf_spoofchk = efx_ef10_sriov_set_vf_spoofchk,
 	.sriov_get_vf_config = efx_ef10_sriov_get_vf_config,
-	.vswitching_probe = efx_ef10_vswitching_probe,
-	.vswitching_restore = efx_ef10_vswitching_restore,
-	.vswitching_remove = efx_ef10_vswitching_remove,
+	.vswitching_probe = efx_ef10_vswitching_probe_pf,
+	.vswitching_restore = efx_ef10_vswitching_restore_pf,
+	.vswitching_remove = efx_ef10_vswitching_remove_pf,
 #endif
 
 	.revision = EFX_REV_HUNT_A0,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index b9545bf..1b93acf 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -117,6 +117,24 @@ static int efx_ef10_vport_free(struct efx_nic *efx, unsigned int port_id)
 			    NULL, 0, NULL);
 }
 
+static int efx_ef10_vadaptor_alloc(struct efx_nic *efx, unsigned int port_id)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_ALLOC_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VADAPTOR_ALLOC_IN_UPSTREAM_PORT_ID, port_id);
+	return efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_ALLOC, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+static int efx_ef10_vadaptor_free(struct efx_nic *efx, unsigned int port_id)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_FREE_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VADAPTOR_FREE_IN_UPSTREAM_PORT_ID, port_id);
+	return efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_FREE, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
 static void efx_ef10_sriov_free_vf_vports(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
@@ -231,14 +249,17 @@ fail:
 /* On top of the default firmware vswitch setup, create a VEB vswitch and
  * expansion vport for use by this function.
  */
-int efx_ef10_vswitching_probe(struct efx_nic *efx)
+int efx_ef10_vswitching_probe_pf(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct net_device *net_dev = efx->net_dev;
 	int rc;
 
-	if (pci_sriov_get_totalvfs(efx->pci_dev) <= 0)
-		return 0; /* vswitch not needed as we have no VFs */
+	if (pci_sriov_get_totalvfs(efx->pci_dev) <= 0) {
+		/* vswitch not needed as we have no VFs */
+		efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+		return 0;
+	}
 
 	rc = efx_ef10_vswitch_alloc(efx, EVB_PORT_ID_ASSIGNED,
 				    MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_VEB);
@@ -254,10 +275,16 @@ int efx_ef10_vswitching_probe(struct efx_nic *efx)
 	rc = efx_ef10_vport_add_mac(efx, nic_data->vport_id, net_dev->dev_addr);
 	if (rc)
 		goto fail3;
-
 	ether_addr_copy(nic_data->vport_mac, net_dev->dev_addr);
 
+	rc = efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+	if (rc)
+		goto fail4;
+
 	return 0;
+fail4:
+	efx_ef10_vport_del_mac(efx, nic_data->vport_id, nic_data->vport_mac);
+	eth_zero_addr(nic_data->vport_mac);
 fail3:
 	efx_ef10_vport_free(efx, nic_data->vport_id);
 	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
@@ -267,7 +294,14 @@ fail1:
 	return rc;
 }
 
-int efx_ef10_vswitching_restore(struct efx_nic *efx)
+int efx_ef10_vswitching_probe_vf(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	return efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+}
+
+int efx_ef10_vswitching_restore_pf(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	int rc;
@@ -275,7 +309,7 @@ int efx_ef10_vswitching_restore(struct efx_nic *efx)
 	if (!nic_data->must_probe_vswitching)
 		return 0;
 
-	rc = efx_ef10_vswitching_probe(efx);
+	rc = efx_ef10_vswitching_probe_pf(efx);
 	if (rc)
 		goto fail;
 
@@ -288,12 +322,30 @@ fail:
 	return rc;
 }
 
-void efx_ef10_vswitching_remove(struct efx_nic *efx)
+int efx_ef10_vswitching_restore_vf(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	if (!nic_data->must_probe_vswitching)
+		return 0;
+
+	rc = efx_ef10_vadaptor_free(efx, EVB_PORT_ID_ASSIGNED);
+	if (rc)
+		return rc;
+
+	nic_data->must_probe_vswitching = false;
+	return 0;
+}
+
+void efx_ef10_vswitching_remove_pf(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
 	efx_ef10_sriov_free_vf_vswitching(efx);
 
+	efx_ef10_vadaptor_free(efx, nic_data->vport_id);
+
 	if (nic_data->vport_id == EVB_PORT_ID_ASSIGNED)
 		return; /* No vswitch was ever created */
 
@@ -308,6 +360,11 @@ void efx_ef10_vswitching_remove(struct efx_nic *efx)
 	efx_ef10_vswitch_free(efx, nic_data->vport_id);
 }
 
+void efx_ef10_vswitching_remove_vf(struct efx_nic *efx)
+{
+	efx_ef10_vadaptor_free(efx, EVB_PORT_ID_ASSIGNED);
+}
+
 static int efx_ef10_pci_sriov_enable(struct efx_nic *efx, int num_vfs)
 {
 	int rc = 0;
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 42d7145..86bac7eb 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -60,8 +60,11 @@ static inline int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf,
 	return -EOPNOTSUPP;
 }
 
-int efx_ef10_vswitching_probe(struct efx_nic *efx);
-int efx_ef10_vswitching_restore(struct efx_nic *efx);
-void efx_ef10_vswitching_remove(struct efx_nic *efx);
+int efx_ef10_vswitching_probe_pf(struct efx_nic *efx);
+int efx_ef10_vswitching_probe_vf(struct efx_nic *efx);
+int efx_ef10_vswitching_restore_pf(struct efx_nic *efx);
+int efx_ef10_vswitching_restore_vf(struct efx_nic *efx);
+void efx_ef10_vswitching_remove_pf(struct efx_nic *efx);
+void efx_ef10_vswitching_remove_vf(struct efx_nic *efx);
 
 #endif /* EF10_SRIOV_H */
