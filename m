From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 2/3] sfc: add legacy method for changing a PF's MAC address
Date: Tue, 7 Jul 2015 11:37:19 +0100
Message-ID: <559BABDF.5070207@solarflare.com>
References: <559BAB66.1080905@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:51068 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755475AbbGGKh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:37:26 -0400
In-Reply-To: <559BAB66.1080905@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Some versions of MCFW do not support the MC_CMD_VADAPTOR_SET_MAC
command, and ENOSYS will be returned.

If the PF created its own vport, the function's datapath must be
stopped and the vport can be reconfigured to reflect the new MAC
address.

If the MCFW created the vport for the PF (which is the case when
the nic_data->vport_mac is blank), nothing further needs to be
done as the vport is not under the control of the PF.

This only applies to PFs because the MCFW in question does not
support VFs.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 120 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.c |  42 ------------
 drivers/net/ethernet/sfc/ef10_sriov.h |   6 ++
 3 files changed, 126 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 9740cd0..e0cb361 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -101,6 +101,11 @@ static unsigned int efx_ef10_mem_map_size(struct efx_nic *efx)
 	return resource_size(&efx->pci_dev->resource[bar]);
 }
 
+static bool efx_ef10_is_vf(struct efx_nic *efx)
+{
+	return efx->type->is_vf;
+}
+
 static int efx_ef10_get_pf_index(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_FUNCTION_INFO_OUT_LEN);
@@ -677,6 +682,48 @@ static int efx_ef10_probe_pf(struct efx_nic *efx)
 	return efx_ef10_probe(efx);
 }
 
+int efx_ef10_vadaptor_alloc(struct efx_nic *efx, unsigned int port_id)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_ALLOC_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VADAPTOR_ALLOC_IN_UPSTREAM_PORT_ID, port_id);
+	return efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_ALLOC, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+int efx_ef10_vadaptor_free(struct efx_nic *efx, unsigned int port_id)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_FREE_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VADAPTOR_FREE_IN_UPSTREAM_PORT_ID, port_id);
+	return efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_FREE, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+int efx_ef10_vport_add_mac(struct efx_nic *efx,
+			   unsigned int port_id, u8 *mac)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VPORT_ADD_MAC_ADDRESS_IN_VPORT_ID, port_id);
+	ether_addr_copy(MCDI_PTR(inbuf, VPORT_ADD_MAC_ADDRESS_IN_MACADDR), mac);
+
+	return efx_mcdi_rpc(efx, MC_CMD_VPORT_ADD_MAC_ADDRESS, inbuf,
+			    sizeof(inbuf), NULL, 0, NULL);
+}
+
+int efx_ef10_vport_del_mac(struct efx_nic *efx,
+			   unsigned int port_id, u8 *mac)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VPORT_DEL_MAC_ADDRESS_IN_VPORT_ID, port_id);
+	ether_addr_copy(MCDI_PTR(inbuf, VPORT_DEL_MAC_ADDRESS_IN_MACADDR), mac);
+
+	return efx_mcdi_rpc(efx, MC_CMD_VPORT_DEL_MAC_ADDRESS, inbuf,
+			    sizeof(inbuf), NULL, 0, NULL);
+}
+
 #ifdef CONFIG_SFC_SRIOV
 static int efx_ef10_probe_vf(struct efx_nic *efx)
 {
@@ -3804,6 +3851,72 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	WARN_ON(remove_failed);
 }
 
+static int efx_ef10_vport_set_mac_address(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	u8 mac_old[ETH_ALEN];
+	int rc, rc2;
+
+	/* Only reconfigure a PF-created vport */
+	if (is_zero_ether_addr(nic_data->vport_mac))
+		return 0;
+
+	efx_device_detach_sync(efx);
+	efx_net_stop(efx->net_dev);
+	down_write(&efx->filter_sem);
+	efx_ef10_filter_table_remove(efx);
+	up_write(&efx->filter_sem);
+
+	rc = efx_ef10_vadaptor_free(efx, nic_data->vport_id);
+	if (rc)
+		goto restore_filters;
+
+	ether_addr_copy(mac_old, nic_data->vport_mac);
+	rc = efx_ef10_vport_del_mac(efx, nic_data->vport_id,
+				    nic_data->vport_mac);
+	if (rc)
+		goto restore_vadaptor;
+
+	rc = efx_ef10_vport_add_mac(efx, nic_data->vport_id,
+				    efx->net_dev->dev_addr);
+	if (!rc) {
+		ether_addr_copy(nic_data->vport_mac, efx->net_dev->dev_addr);
+	} else {
+		rc2 = efx_ef10_vport_add_mac(efx, nic_data->vport_id, mac_old);
+		if (rc2) {
+			/* Failed to add original MAC, so clear vport_mac */
+			eth_zero_addr(nic_data->vport_mac);
+			goto reset_nic;
+		}
+	}
+
+restore_vadaptor:
+	rc2 = efx_ef10_vadaptor_alloc(efx, nic_data->vport_id);
+	if (rc2)
+		goto reset_nic;
+restore_filters:
+	down_write(&efx->filter_sem);
+	rc2 = efx_ef10_filter_table_probe(efx);
+	up_write(&efx->filter_sem);
+	if (rc2)
+		goto reset_nic;
+
+	rc2 = efx_net_open(efx->net_dev);
+	if (rc2)
+		goto reset_nic;
+
+	netif_device_attach(efx->net_dev);
+
+	return rc;
+
+reset_nic:
+	netif_err(efx, drv, efx->net_dev,
+		  "Failed to restore when changing MAC address - scheduling reset\n");
+	efx_schedule_reset(efx, RESET_TYPE_DATAPATH);
+
+	return rc ? rc : rc2;
+}
+
 static int efx_ef10_set_mac_address(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_SET_MAC_IN_LEN);
@@ -3866,6 +3979,13 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 		netif_err(efx, drv, efx->net_dev,
 			  "Cannot change MAC address; use sfboot to enable"
 			  " mac-spoofing on this interface\n");
+	} else if (rc == -ENOSYS && !efx_ef10_is_vf(efx)) {
+		/* If the active MCFW does not support MC_CMD_VADAPTOR_SET_MAC
+		 * fall-back to the method of changing the MAC address on the
+		 * vport.  This only applies to PFs because such versions of
+		 * MCFW do not support VFs.
+		 */
+		rc = efx_ef10_vport_set_mac_address(efx);
 	}
 
 	return rc;
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 6c9b6e4..7485f71 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -29,30 +29,6 @@ static int efx_ef10_evb_port_assign(struct efx_nic *efx, unsigned int port_id,
 			    NULL, 0, NULL);
 }
 
-static int efx_ef10_vport_add_mac(struct efx_nic *efx,
-				  unsigned int port_id, u8 *mac)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN);
-
-	MCDI_SET_DWORD(inbuf, VPORT_ADD_MAC_ADDRESS_IN_VPORT_ID, port_id);
-	ether_addr_copy(MCDI_PTR(inbuf, VPORT_ADD_MAC_ADDRESS_IN_MACADDR), mac);
-
-	return efx_mcdi_rpc(efx, MC_CMD_VPORT_ADD_MAC_ADDRESS, inbuf,
-			    sizeof(inbuf), NULL, 0, NULL);
-}
-
-static int efx_ef10_vport_del_mac(struct efx_nic *efx,
-				  unsigned int port_id, u8 *mac)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN);
-
-	MCDI_SET_DWORD(inbuf, VPORT_DEL_MAC_ADDRESS_IN_VPORT_ID, port_id);
-	ether_addr_copy(MCDI_PTR(inbuf, VPORT_DEL_MAC_ADDRESS_IN_MACADDR), mac);
-
-	return efx_mcdi_rpc(efx, MC_CMD_VPORT_DEL_MAC_ADDRESS, inbuf,
-			    sizeof(inbuf), NULL, 0, NULL);
-}
-
 static int efx_ef10_vswitch_alloc(struct efx_nic *efx, unsigned int port_id,
 				  unsigned int vswitch_type)
 {
@@ -136,24 +112,6 @@ static int efx_ef10_vport_free(struct efx_nic *efx, unsigned int port_id)
 			    NULL, 0, NULL);
 }
 
-static int efx_ef10_vadaptor_alloc(struct efx_nic *efx, unsigned int port_id)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_ALLOC_IN_LEN);
-
-	MCDI_SET_DWORD(inbuf, VADAPTOR_ALLOC_IN_UPSTREAM_PORT_ID, port_id);
-	return efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_ALLOC, inbuf, sizeof(inbuf),
-			    NULL, 0, NULL);
-}
-
-static int efx_ef10_vadaptor_free(struct efx_nic *efx, unsigned int port_id)
-{
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_FREE_IN_LEN);
-
-	MCDI_SET_DWORD(inbuf, VADAPTOR_FREE_IN_UPSTREAM_PORT_ID, port_id);
-	return efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_FREE, inbuf, sizeof(inbuf),
-			    NULL, 0, NULL);
-}
-
 static void efx_ef10_sriov_free_vf_vports(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index db4ef53..6d25b92 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -65,5 +65,11 @@ int efx_ef10_vswitching_restore_pf(struct efx_nic *efx);
 int efx_ef10_vswitching_restore_vf(struct efx_nic *efx);
 void efx_ef10_vswitching_remove_pf(struct efx_nic *efx);
 void efx_ef10_vswitching_remove_vf(struct efx_nic *efx);
+int efx_ef10_vport_add_mac(struct efx_nic *efx,
+			   unsigned int port_id, u8 *mac);
+int efx_ef10_vport_del_mac(struct efx_nic *efx,
+			   unsigned int port_id, u8 *mac);
+int efx_ef10_vadaptor_alloc(struct efx_nic *efx, unsigned int port_id);
+int efx_ef10_vadaptor_free(struct efx_nic *efx, unsigned int port_id);
 
 #endif /* EF10_SRIOV_H */
