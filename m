From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 13/16] sfc: add ndo_set_vf_vlan() function for EF10
Date: Mon, 18 May 2015 16:31:07 +0100
Message-ID: <555A05BB.1070503@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:61925 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753797AbbERPc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:32:57 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The max vlan tags that can be offloaded is 2, including any upstream VLAN
aggregator. Currently there is no way for the net driver to know whether
the upstream vswitch (if any) is using vlan tags, so there is no way to
know how many tags we can request.
Along with the implementation for the ndo_set_vf_vlan callback, this patch
also adds 2 VLAN tags for the driver created VEB switch if possible, that
way it is possible to offload as many tags as are allowed.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 159 ++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/ef10_sriov.h |  10 +--
 2 files changed, 157 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index d9c2ea4..49238fc 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -57,15 +57,29 @@ static int efx_ef10_vswitch_alloc(struct efx_nic *efx, unsigned int port_id,
 				  unsigned int vswitch_type)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_VSWITCH_ALLOC_IN_LEN);
+	int rc;
 
 	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_UPSTREAM_PORT_ID, port_id);
 	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_TYPE, vswitch_type);
-	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_NUM_VLAN_TAGS, 0);
+	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_NUM_VLAN_TAGS, 2);
 	MCDI_POPULATE_DWORD_1(inbuf, VSWITCH_ALLOC_IN_FLAGS,
 			      VSWITCH_ALLOC_IN_FLAG_AUTO_PORT, 0);
 
-	return efx_mcdi_rpc(efx, MC_CMD_VSWITCH_ALLOC, inbuf, sizeof(inbuf),
-			    NULL, 0, NULL);
+	/* Quietly try to allocate 2 VLAN tags */
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_VSWITCH_ALLOC, inbuf, sizeof(inbuf),
+				NULL, 0, NULL);
+
+	/* If 2 VLAN tags is too many, revert to trying with 1 VLAN tags */
+	if (rc == -EPROTO) {
+		MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_NUM_VLAN_TAGS, 1);
+		rc = efx_mcdi_rpc(efx, MC_CMD_VSWITCH_ALLOC, inbuf,
+				  sizeof(inbuf), NULL, 0, NULL);
+	} else if (rc) {
+		efx_mcdi_display_error(efx, MC_CMD_VSWITCH_ALLOC,
+				       MC_CMD_VSWITCH_ALLOC_IN_LEN,
+				       NULL, 0, rc);
+	}
+	return rc;
 }
 
 static int efx_ef10_vswitch_free(struct efx_nic *efx, unsigned int port_id)
@@ -81,6 +95,7 @@ static int efx_ef10_vswitch_free(struct efx_nic *efx, unsigned int port_id)
 static int efx_ef10_vport_alloc(struct efx_nic *efx,
 				unsigned int port_id_in,
 				unsigned int vport_type,
+				u16 vlan,
 				unsigned int *port_id_out)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_ALLOC_IN_LEN);
@@ -92,9 +107,13 @@ static int efx_ef10_vport_alloc(struct efx_nic *efx,
 
 	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_UPSTREAM_PORT_ID, port_id_in);
 	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_TYPE, vport_type);
-	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_NUM_VLAN_TAGS, 0);
+	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_NUM_VLAN_TAGS,
+		       (vlan != EFX_EF10_NO_VLAN));
 	MCDI_POPULATE_DWORD_1(inbuf, VPORT_ALLOC_IN_FLAGS,
 			      VPORT_ALLOC_IN_FLAG_AUTO_PORT, 0);
+	if (vlan != EFX_EF10_NO_VLAN)
+		MCDI_POPULATE_DWORD_1(inbuf, VPORT_ALLOC_IN_VLAN_TAGS,
+				      VPORT_ALLOC_IN_VLAN_TAG_0, vlan);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_VPORT_ALLOC, inbuf, sizeof(inbuf),
 			  outbuf, sizeof(outbuf), &outlen);
@@ -186,7 +205,7 @@ static int efx_ef10_sriov_assign_vf_vport(struct efx_nic *efx,
 
 	rc = efx_ef10_vport_alloc(efx, EVB_PORT_ID_ASSIGNED,
 				  MC_CMD_VPORT_ALLOC_IN_VPORT_TYPE_NORMAL,
-				  &vf->vport_id);
+				  vf->vlan, &vf->vport_id);
 	if (rc)
 		return rc;
 
@@ -218,6 +237,7 @@ static int efx_ef10_sriov_alloc_vf_vswitching(struct efx_nic *efx)
 	for (i = 0; i < efx->vf_count; i++) {
 		random_ether_addr(nic_data->vf[i].mac);
 		nic_data->vf[i].efx = NULL;
+		nic_data->vf[i].vlan = EFX_EF10_NO_VLAN;
 
 		rc = efx_ef10_sriov_assign_vf_vport(efx, i);
 		if (rc)
@@ -271,7 +291,7 @@ int efx_ef10_vswitching_probe_pf(struct efx_nic *efx)
 
 	rc = efx_ef10_vport_alloc(efx, EVB_PORT_ID_ASSIGNED,
 				  MC_CMD_VPORT_ALLOC_IN_VPORT_TYPE_NORMAL,
-				  &nic_data->vport_id);
+				  EFX_EF10_NO_VLAN, &nic_data->vport_id);
 	if (rc)
 		goto fail2;
 
@@ -522,6 +542,131 @@ fail:
 	return rc;
 }
 
+int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i, u16 vlan,
+			       u8 qos)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct ef10_vf *vf;
+	u16 old_vlan, new_vlan;
+	int rc = 0, rc2 = 0;
+
+	if (vf_i >= efx->vf_count)
+		return -EINVAL;
+	if (qos != 0)
+		return -EINVAL;
+
+	vf = nic_data->vf + vf_i;
+
+	new_vlan = (vlan == 0) ? EFX_EF10_NO_VLAN : vlan;
+	if (new_vlan == vf->vlan)
+		return 0;
+
+	if (vf->efx) {
+		efx_device_detach_sync(vf->efx);
+		efx_net_stop(vf->efx->net_dev);
+
+		down_write(&vf->efx->filter_sem);
+		vf->efx->type->filter_table_remove(vf->efx);
+
+		rc = efx_ef10_vadaptor_free(vf->efx, EVB_PORT_ID_ASSIGNED);
+		if (rc)
+			goto restore_filters;
+	}
+
+	if (vf->vport_assigned) {
+		rc = efx_ef10_evb_port_assign(efx, EVB_PORT_ID_NULL, vf_i);
+		if (rc) {
+			netif_warn(efx, drv, efx->net_dev,
+				   "Failed to change vlan on VF %d.\n", vf_i);
+			netif_warn(efx, drv, efx->net_dev,
+				   "This is likely because the VF is bound to a driver in a VM.\n");
+			netif_warn(efx, drv, efx->net_dev,
+				   "Please unload the driver in the VM.\n");
+			goto restore_vadaptor;
+		}
+		vf->vport_assigned = 0;
+	}
+
+	if (!is_zero_ether_addr(vf->mac)) {
+		rc = efx_ef10_vport_del_mac(efx, vf->vport_id, vf->mac);
+		if (rc)
+			goto restore_evb_port;
+	}
+
+	if (vf->vport_id) {
+		rc = efx_ef10_vport_free(efx, vf->vport_id);
+		if (rc)
+			goto restore_mac;
+		vf->vport_id = 0;
+	}
+
+	/* Do the actual vlan change */
+	old_vlan = vf->vlan;
+	vf->vlan = new_vlan;
+
+	/* Restore everything in reverse order */
+	rc = efx_ef10_vport_alloc(efx, EVB_PORT_ID_ASSIGNED,
+				  MC_CMD_VPORT_ALLOC_IN_VPORT_TYPE_NORMAL,
+				  vf->vlan, &vf->vport_id);
+	if (rc)
+		goto reset_nic;
+
+restore_mac:
+	if (!is_zero_ether_addr(vf->mac)) {
+		rc2 = efx_ef10_vport_add_mac(efx, vf->vport_id, vf->mac);
+		if (rc2) {
+			eth_zero_addr(vf->mac);
+			goto reset_nic;
+		}
+	}
+
+restore_evb_port:
+	rc2 = efx_ef10_evb_port_assign(efx, vf->vport_id, vf_i);
+	if (rc2)
+		goto reset_nic;
+	else
+		vf->vport_assigned = 1;
+
+restore_vadaptor:
+	if (vf->efx) {
+		rc2 = efx_ef10_vadaptor_alloc(vf->efx, EVB_PORT_ID_ASSIGNED);
+		if (rc2)
+			goto reset_nic;
+	}
+
+restore_filters:
+	if (vf->efx) {
+		rc2 = vf->efx->type->filter_table_probe(vf->efx);
+		if (rc2)
+			goto reset_nic;
+
+		up_write(&vf->efx->filter_sem);
+
+		rc2 = efx_net_open(vf->efx->net_dev);
+		if (rc2)
+			goto reset_nic;
+
+		netif_device_attach(vf->efx->net_dev);
+	}
+	return rc;
+
+reset_nic:
+	if (vf->efx) {
+		up_write(&vf->efx->filter_sem);
+		netif_err(efx, drv, efx->net_dev,
+			  "Failed to restore VF - scheduling reset.\n");
+		efx_schedule_reset(vf->efx, RESET_TYPE_DATAPATH);
+	} else {
+		netif_err(efx, drv, efx->net_dev,
+			  "Failed to restore the VF and cannot reset the VF "
+			  "- VF is not functional.\n");
+		netif_err(efx, drv, efx->net_dev,
+			  "Please reload the driver attached to the VF.\n");
+	}
+
+	return rc ? rc : rc2;
+}
+
 int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 				 struct ifla_vf_info *ivf)
 {
@@ -540,7 +685,7 @@ int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf_i,
 	ivf->min_tx_rate = 0;
 	ivf->max_tx_rate = 0;
 	ether_addr_copy(ivf->mac, vf->mac);
-	ivf->vlan = 0;
+	ivf->vlan = (vf->vlan == EFX_EF10_NO_VLAN) ? 0 : vf->vlan;
 	ivf->qos = 0;
 
 	return 0;
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 8c92a8d..0428265 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -18,12 +18,15 @@
  * @vport_id: vport ID for the VF
  * @vport_assigned: record whether the vport is currently assigned to the VF
  * @mac: MAC address for the VF, zero when address is removed from the vport
+ * @vlan: Default VLAN for the VF or #EFX_EF10_NO_VLAN
  */
 struct ef10_vf {
 	struct efx_nic *efx;
 	unsigned int vport_id;
 	unsigned int vport_assigned;
 	u8 mac[ETH_ALEN];
+	u16 vlan;
+#define EFX_EF10_NO_VLAN       0
 };
 
 static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
@@ -43,11 +46,8 @@ static inline void efx_ef10_sriov_flr(struct efx_nic *efx, unsigned vf_i) {}
 
 int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf, u8 *mac);
 
-static inline int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf,
-					     u16 vlan, u8 qos)
-{
-	return -EOPNOTSUPP;
-}
+int efx_ef10_sriov_set_vf_vlan(struct efx_nic *efx, int vf_i,
+			       u16 vlan, u8 qos);
 
 static inline int efx_ef10_sriov_set_vf_spoofchk(struct efx_nic *efx, int vf,
 						 bool spoofchk)
