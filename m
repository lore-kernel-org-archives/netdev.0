From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 07/14] sfc: create VEB vswitch and vport above default
 firmware setup
Date: Wed, 6 May 2015 00:57:34 +0100
Message-ID: <554958EE.2080501@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:31363 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753530AbbEEX5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:57:43 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Adds functions to allocate and free vswitches and vports; vadaptors
are automatically allocated and freed when TX/RX queues are
initialised and finalised.  This vswitching structure is only created
if the firmware supports it, so a check that full-featured firmware
is running is performed first.

If the MC resets, the vswitching infrastructure will need to be
recreated, so mark the "must_probe_vswitching" flag when an MC reboot
is detected.

Don't try to create a vswitch if vf-count=0

This allocation of vswitches and vports does not currently support
configuring VLAN tags, but that can be added in a future change.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |   7 ++
 drivers/net/ethernet/sfc/ef10_sriov.c | 121 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h |   4 ++
 drivers/net/ethernet/sfc/efx.c        |  30 ++++++++-
 drivers/net/ethernet/sfc/net_driver.h |   3 +
 drivers/net/ethernet/sfc/nic.h        |   2 +
 drivers/net/ethernet/sfc/siena.c      |   3 +
 7 files changed, 167 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 8db717e..91a5896 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1133,6 +1133,10 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 	/* All our allocations have been reset */
 	efx_ef10_reset_mc_allocations(efx);
 
+	/* Driver-created vswitches and vports must be re-created */
+	nic_data->must_probe_vswitching = true;
+	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
+
 	/* The datapath firmware might have been changed */
 	nic_data->must_check_datapath_caps = true;
 
@@ -3715,6 +3719,9 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.sriov_set_vf_vlan = efx_ef10_sriov_set_vf_vlan,
 	.sriov_set_vf_spoofchk = efx_ef10_sriov_set_vf_spoofchk,
 	.sriov_get_vf_config = efx_ef10_sriov_get_vf_config,
+	.vswitching_probe = efx_ef10_vswitching_probe,
+	.vswitching_restore = efx_ef10_vswitching_restore,
+	.vswitching_remove = efx_ef10_vswitching_remove,
 #endif
 
 	.revision = EFX_REV_HUNT_A0,
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 63d7b0d..2aba7b7 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -45,3 +45,124 @@ int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs)
 	else
 		return efx_ef10_pci_sriov_enable(efx, num_vfs);
 }
+
+static int efx_ef10_vswitch_alloc(struct efx_nic *efx, unsigned int port_id,
+				  unsigned int vswitch_type)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VSWITCH_ALLOC_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_UPSTREAM_PORT_ID, port_id);
+	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_TYPE, vswitch_type);
+	MCDI_SET_DWORD(inbuf, VSWITCH_ALLOC_IN_NUM_VLAN_TAGS, 0);
+	MCDI_POPULATE_DWORD_1(inbuf, VSWITCH_ALLOC_IN_FLAGS,
+			      VSWITCH_ALLOC_IN_FLAG_AUTO_PORT, 0);
+
+	return efx_mcdi_rpc(efx, MC_CMD_VSWITCH_ALLOC, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+static int efx_ef10_vswitch_free(struct efx_nic *efx, unsigned int port_id)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VSWITCH_FREE_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VSWITCH_FREE_IN_UPSTREAM_PORT_ID, port_id);
+
+	return efx_mcdi_rpc(efx, MC_CMD_VSWITCH_FREE, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+static int efx_ef10_vport_alloc(struct efx_nic *efx,
+				unsigned int port_id_in,
+				unsigned int vport_type,
+				unsigned int *port_id_out)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_ALLOC_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_VPORT_ALLOC_OUT_LEN);
+	size_t outlen;
+	int rc;
+
+	EFX_WARN_ON_PARANOID(!port_id_out);
+
+	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_UPSTREAM_PORT_ID, port_id_in);
+	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_TYPE, vport_type);
+	MCDI_SET_DWORD(inbuf, VPORT_ALLOC_IN_NUM_VLAN_TAGS, 0);
+	MCDI_POPULATE_DWORD_1(inbuf, VPORT_ALLOC_IN_FLAGS,
+			      VPORT_ALLOC_IN_FLAG_AUTO_PORT, 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_VPORT_ALLOC, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		return rc;
+	if (outlen < MC_CMD_VPORT_ALLOC_OUT_LEN)
+		return -EIO;
+
+	*port_id_out = MCDI_DWORD(outbuf, VPORT_ALLOC_OUT_VPORT_ID);
+	return 0;
+}
+
+static int efx_ef10_vport_free(struct efx_nic *efx, unsigned int port_id)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_FREE_IN_LEN);
+
+	MCDI_SET_DWORD(inbuf, VPORT_FREE_IN_VPORT_ID, port_id);
+
+	return efx_mcdi_rpc(efx, MC_CMD_VPORT_FREE, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
+}
+
+/* On top of the default firmware vswitch setup, create a VEB vswitch and
+ * expansion vport for use by this function.
+ */
+int efx_ef10_vswitching_probe(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	if (pci_sriov_get_totalvfs(efx->pci_dev) <= 0)
+		return 0; /* vswitch not needed as we have no VFs */
+
+	rc = efx_ef10_vswitch_alloc(efx, EVB_PORT_ID_ASSIGNED,
+				    MC_CMD_VSWITCH_ALLOC_IN_VSWITCH_TYPE_VEB);
+	if (rc)
+		goto fail1;
+
+	rc = efx_ef10_vport_alloc(efx, EVB_PORT_ID_ASSIGNED,
+				  MC_CMD_VPORT_ALLOC_IN_VPORT_TYPE_NORMAL,
+				  &nic_data->vport_id);
+	if (rc)
+		goto fail2;
+
+	return 0;
+fail2:
+	efx_ef10_vswitch_free(efx, EVB_PORT_ID_ASSIGNED);
+fail1:
+	return rc;
+}
+
+int efx_ef10_vswitching_restore(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	if (!nic_data->must_probe_vswitching)
+		return 0;
+
+	rc = efx_ef10_vswitching_probe(efx);
+
+	if (!rc)
+		nic_data->must_probe_vswitching = false;
+	return rc;
+}
+
+void efx_ef10_vswitching_remove(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	if (nic_data->vport_id == EVB_PORT_ID_ASSIGNED)
+		return; /* No vswitch was ever created */
+
+	efx_ef10_vport_free(efx, nic_data->vport_id);
+	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
+
+	efx_ef10_vswitch_free(efx, nic_data->vport_id);
+}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 5f26d1b..676b00c 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -53,4 +53,8 @@ static inline int efx_ef10_sriov_get_vf_config(struct efx_nic *efx, int vf,
 	return -EOPNOTSUPP;
 }
 
+int efx_ef10_vswitching_probe(struct efx_nic *efx);
+int efx_ef10_vswitching_restore(struct efx_nic *efx);
+void efx_ef10_vswitching_remove(struct efx_nic *efx);
+
 #endif /* EF10_SRIOV_H */
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 917b137..f1dd34c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1721,21 +1721,33 @@ static int efx_probe_all(struct efx_nic *efx)
 	}
 	efx->rxq_entries = efx->txq_entries = EFX_DEFAULT_DMAQ_SIZE;
 
+#ifdef CONFIG_SFC_SRIOV
+	rc = efx->type->vswitching_probe(efx);
+	if (rc) /* not fatal; the PF will still work fine */
+		netif_warn(efx, probe, efx->net_dev,
+			   "failed to setup vswitching rc=%d;"
+			   " VFs may not function\n", rc);
+#endif
+
 	rc = efx_probe_filters(efx);
 	if (rc) {
 		netif_err(efx, probe, efx->net_dev,
 			  "failed to create filter tables\n");
-		goto fail3;
+		goto fail4;
 	}
 
 	rc = efx_probe_channels(efx);
 	if (rc)
-		goto fail4;
+		goto fail5;
 
 	return 0;
 
- fail4:
+ fail5:
 	efx_remove_filters(efx);
+ fail4:
+#ifdef CONFIG_SFC_SRIOV
+	efx->type->vswitching_remove(efx);
+#endif
  fail3:
 	efx_remove_port(efx);
  fail2:
@@ -1825,6 +1837,9 @@ static void efx_remove_all(struct efx_nic *efx)
 {
 	efx_remove_channels(efx);
 	efx_remove_filters(efx);
+#ifdef CONFIG_SFC_SRIOV
+	efx->type->vswitching_remove(efx);
+#endif
 	efx_remove_port(efx);
 	efx_remove_nic(efx);
 }
@@ -2417,6 +2432,15 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	rc = efx_enable_interrupts(efx);
 	if (rc)
 		goto fail;
+
+#ifdef CONFIG_SFC_SRIOV
+	rc = efx->type->vswitching_restore(efx);
+	if (rc) /* not fatal; the PF will still work fine */
+		netif_warn(efx, probe, efx->net_dev,
+			   "failed to restore vswitching rc=%d;"
+			   " VFs may not function\n", rc);
+#endif
+
 	efx_restore_filters(efx);
 	if (efx->type->sriov_reset)
 		efx->type->sriov_reset(efx);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 339dc32..0cb3e0e 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1341,6 +1341,9 @@ struct efx_nic_type {
 				     bool spoofchk);
 	int (*sriov_get_vf_config)(struct efx_nic *efx, int vf_i,
 				   struct ifla_vf_info *ivi);
+	int (*vswitching_probe)(struct efx_nic *efx);
+	int (*vswitching_restore)(struct efx_nic *efx);
+	void (*vswitching_remove)(struct efx_nic *efx);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index f29e4ec..d7dcc01 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -494,6 +494,7 @@ enum {
  * @rx_dpcpu_fw_id: Firmware ID of the RxDPCPU
  * @tx_dpcpu_fw_id: Firmware ID of the TxDPCPU
  * @vport_id: The function's vport ID, only relevant for PFs
+ * @must_probe_vswitching: Flag: vswitching has yet to be setup after MC reboot
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -515,6 +516,7 @@ struct efx_ef10_nic_data {
 	unsigned int rx_dpcpu_fw_id;
 	unsigned int tx_dpcpu_fw_id;
 	unsigned int vport_id;
+	bool must_probe_vswitching;
 };
 
 int efx_init_sriov(void);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 72e8a6b..5c2995e 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -1011,6 +1011,9 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.sriov_set_vf_vlan = efx_siena_sriov_set_vf_vlan,
 	.sriov_set_vf_spoofchk = efx_siena_sriov_set_vf_spoofchk,
 	.sriov_get_vf_config = efx_siena_sriov_get_vf_config,
+	.vswitching_probe = efx_port_dummy_op_int,
+	.vswitching_restore = efx_port_dummy_op_int,
+	.vswitching_remove = efx_port_dummy_op_void,
 #endif
 
 	.revision = EFX_REV_SIENA_A0,
