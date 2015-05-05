From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 10/14] sfc: create vports for VFs and assign random
 MAC addresses
Date: Wed, 6 May 2015 00:58:31 +0100
Message-ID: <55495927.6010802@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:42853 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751106AbbEEX6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:58:47 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parent PF creates vports for all its child VFs and adds MAC
addresses to these.  When the VF driver loads, it can make an MCDI
call to get the MAC address that the parent PF assigned it.

The parent PF also assigns a mac address to its own vport because
implicit creation of a vAdaptor will only work on evb ports with
MAC addresses assigned.

The vport MAC address needs to be stored in the PF's nic_data
struct as it can later be changed on the vadaptor (and its net_dev
struct). When removing a vport the original MAC address must be
deleted.

A new flag is needed in the VF data structure to identify whether
a vport has been assigned to the VF.  This is to determine whether
it needs to be un-assigned before freeing the vport.  Also,
attempting to un-assign a vport which is not assigned will result
in an EALREADY error.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 262 +++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/ef10_sriov.h |  12 ++
 drivers/net/ethernet/sfc/nic.h        |   7 +
 3 files changed, 244 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index be74a70..b9545bf 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -14,53 +14,43 @@
 #include "nic.h"
 #include "mcdi_pcol.h"
 
-static int efx_ef10_pci_sriov_enable(struct efx_nic *efx, int num_vfs)
+static int efx_ef10_evb_port_assign(struct efx_nic *efx, unsigned int port_id,
+				    unsigned int vf_fn)
 {
-	int rc = 0;
-	struct pci_dev *dev = efx->pci_dev;
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_EVB_PORT_ASSIGN_IN_LEN);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
-	efx->vf_count = num_vfs;
-	rc = pci_enable_sriov(dev, num_vfs);
-	if (rc) {
-		efx->vf_count = 0;
-		netif_err(efx, probe, efx->net_dev,
-			  "Failed to enable SRIOV VFs\n");
-	}
-	return rc;
+	MCDI_SET_DWORD(inbuf, EVB_PORT_ASSIGN_IN_PORT_ID, port_id);
+	MCDI_POPULATE_DWORD_2(inbuf, EVB_PORT_ASSIGN_IN_FUNCTION,
+			      EVB_PORT_ASSIGN_IN_PF, nic_data->pf_index,
+			      EVB_PORT_ASSIGN_IN_VF, vf_fn);
+
+	return efx_mcdi_rpc(efx, MC_CMD_EVB_PORT_ASSIGN, inbuf, sizeof(inbuf),
+			    NULL, 0, NULL);
 }
 
-static int efx_ef10_pci_sriov_disable(struct efx_nic *efx)
+static int efx_ef10_vport_add_mac(struct efx_nic *efx,
+				  unsigned int port_id, u8 *mac)
 {
-	struct pci_dev *dev = efx->pci_dev;
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN);
 
-	efx->vf_count = 0;
-	pci_disable_sriov(dev);
-	return 0;
-}
+	MCDI_SET_DWORD(inbuf, VPORT_ADD_MAC_ADDRESS_IN_VPORT_ID, port_id);
+	ether_addr_copy(MCDI_PTR(inbuf, VPORT_ADD_MAC_ADDRESS_IN_MACADDR), mac);
 
-int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs)
-{
-	if (num_vfs == 0)
-		return efx_ef10_pci_sriov_disable(efx);
-	else
-		return efx_ef10_pci_sriov_enable(efx, num_vfs);
+	return efx_mcdi_rpc(efx, MC_CMD_VPORT_ADD_MAC_ADDRESS, inbuf,
+			    sizeof(inbuf), NULL, 0, NULL);
 }
 
-int efx_ef10_sriov_init(struct efx_nic *efx)
+static int efx_ef10_vport_del_mac(struct efx_nic *efx,
+				  unsigned int port_id, u8 *mac)
 {
-	return 0;
-}
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN);
 
-void efx_ef10_sriov_fini(struct efx_nic *efx)
-{
-	int rc;
+	MCDI_SET_DWORD(inbuf, VPORT_DEL_MAC_ADDRESS_IN_VPORT_ID, port_id);
+	ether_addr_copy(MCDI_PTR(inbuf, VPORT_DEL_MAC_ADDRESS_IN_MACADDR), mac);
 
-	rc = efx_ef10_pci_sriov_disable(efx);
-	if (rc)
-		netif_dbg(efx, drv, efx->net_dev,
-			  "Disabling SRIOV was not successful rc=%d\n", rc);
-	else
-		netif_dbg(efx, drv, efx->net_dev, "SRIOV disabled\n");
+	return efx_mcdi_rpc(efx, MC_CMD_VPORT_DEL_MAC_ADDRESS, inbuf,
+			    sizeof(inbuf), NULL, 0, NULL);
 }
 
 static int efx_ef10_vswitch_alloc(struct efx_nic *efx, unsigned int port_id,
@@ -127,12 +117,124 @@ static int efx_ef10_vport_free(struct efx_nic *efx, unsigned int port_id)
 			    NULL, 0, NULL);
 }
 
+static void efx_ef10_sriov_free_vf_vports(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int i;
+
+	if (!nic_data->vf)
+		return;
+
+	for (i = 0; i < efx->vf_count; i++) {
+		struct ef10_vf *vf = nic_data->vf + i;
+
+		if (vf->vport_assigned) {
+			efx_ef10_evb_port_assign(efx, EVB_PORT_ID_NULL, i);
+			vf->vport_assigned = 0;
+		}
+
+		if (!is_zero_ether_addr(vf->mac)) {
+			efx_ef10_vport_del_mac(efx, vf->vport_id, vf->mac);
+			eth_zero_addr(vf->mac);
+		}
+
+		if (vf->vport_id) {
+			efx_ef10_vport_free(efx, vf->vport_id);
+			vf->vport_id = 0;
+		}
+	}
+}
+
+static void efx_ef10_sriov_free_vf_vswitching(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	efx_ef10_sriov_free_vf_vports(efx);
+	kfree(nic_data->vf);
+	nic_data->vf = NULL;
+}
+
+static int efx_ef10_sriov_assign_vf_vport(struct efx_nic *efx,
+					  unsigned int vf_i)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct ef10_vf *vf = nic_data->vf + vf_i;
+	int rc;
+
+	if (WARN_ON_ONCE(!nic_data->vf))
+		return -EOPNOTSUPP;
+
+	rc = efx_ef10_vport_alloc(efx, EVB_PORT_ID_ASSIGNED,
+				  MC_CMD_VPORT_ALLOC_IN_VPORT_TYPE_NORMAL,
+				  &vf->vport_id);
+	if (rc)
+		return rc;
+
+	rc = efx_ef10_vport_add_mac(efx, vf->vport_id, vf->mac);
+	if (rc) {
+		eth_zero_addr(vf->mac);
+		return rc;
+	}
+
+	rc =  efx_ef10_evb_port_assign(efx, vf->vport_id, vf_i);
+	if (rc)
+		return rc;
+
+	vf->vport_assigned = 1;
+	return 0;
+}
+
+static int efx_ef10_sriov_alloc_vf_vswitching(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	unsigned int i;
+	int rc;
+
+	nic_data->vf = kcalloc(efx->vf_count, sizeof(struct ef10_vf),
+			       GFP_KERNEL);
+	if (!nic_data->vf)
+		return -ENOMEM;
+
+	for (i = 0; i < efx->vf_count; i++) {
+		random_ether_addr(nic_data->vf[i].mac);
+
+		rc = efx_ef10_sriov_assign_vf_vport(efx, i);
+		if (rc)
+			goto fail;
+	}
+
+	return 0;
+fail:
+	efx_ef10_sriov_free_vf_vports(efx);
+	kfree(nic_data->vf);
+	nic_data->vf = NULL;
+	return rc;
+}
+
+static int efx_ef10_sriov_restore_vf_vswitching(struct efx_nic *efx)
+{
+	unsigned int i;
+	int rc;
+
+	for (i = 0; i < efx->vf_count; i++) {
+		rc = efx_ef10_sriov_assign_vf_vport(efx, i);
+		if (rc)
+			goto fail;
+	}
+
+	return 0;
+fail:
+	efx_ef10_sriov_free_vf_vswitching(efx);
+	return rc;
+}
+
 /* On top of the default firmware vswitch setup, create a VEB vswitch and
  * expansion vport for use by this function.
  */
 int efx_ef10_vswitching_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct net_device *net_dev = efx->net_dev;
 	int rc;
 
 	if (pci_sriov_get_totalvfs(efx->pci_dev) <= 0)
@@ -149,7 +251,16 @@ int efx_ef10_vswitching_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail2;
 
+	rc = efx_ef10_vport_add_mac(efx, nic_data->vport_id, net_dev->dev_addr);
+	if (rc)
+		goto fail3;
+
+	ether_addr_copy(nic_data->vport_mac, net_dev->dev_addr);
+
 	return 0;
+fail3:
+	efx_ef10_vport_free(efx, nic_data->vport_id);
+	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
 fail2:
 	efx_ef10_vswitch_free(efx, EVB_PORT_ID_ASSIGNED);
 fail1:
@@ -165,9 +276,15 @@ int efx_ef10_vswitching_restore(struct efx_nic *efx)
 		return 0;
 
 	rc = efx_ef10_vswitching_probe(efx);
+	if (rc)
+		goto fail;
+
+	rc = efx_ef10_sriov_restore_vf_vswitching(efx);
+	if (rc)
+		goto fail;
 
-	if (!rc)
-		nic_data->must_probe_vswitching = false;
+	nic_data->must_probe_vswitching = false;
+fail:
 	return rc;
 }
 
@@ -175,11 +292,82 @@ void efx_ef10_vswitching_remove(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
+	efx_ef10_sriov_free_vf_vswitching(efx);
+
 	if (nic_data->vport_id == EVB_PORT_ID_ASSIGNED)
 		return; /* No vswitch was ever created */
 
+	if (!is_zero_ether_addr(nic_data->vport_mac)) {
+		efx_ef10_vport_del_mac(efx, nic_data->vport_id,
+				       efx->net_dev->dev_addr);
+		eth_zero_addr(nic_data->vport_mac);
+	}
 	efx_ef10_vport_free(efx, nic_data->vport_id);
 	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
 
 	efx_ef10_vswitch_free(efx, nic_data->vport_id);
 }
+
+static int efx_ef10_pci_sriov_enable(struct efx_nic *efx, int num_vfs)
+{
+	int rc = 0;
+	struct pci_dev *dev = efx->pci_dev;
+
+	efx->vf_count = num_vfs;
+
+	rc = efx_ef10_sriov_alloc_vf_vswitching(efx);
+	if (rc)
+		goto fail1;
+
+	rc = pci_enable_sriov(dev, num_vfs);
+	if (rc)
+		goto fail2;
+
+	return 0;
+fail2:
+	efx_ef10_sriov_free_vf_vswitching(efx);
+fail1:
+	efx->vf_count = 0;
+	netif_err(efx, probe, efx->net_dev,
+		  "Failed to enable SRIOV VFs\n");
+	return rc;
+}
+
+static int efx_ef10_pci_sriov_disable(struct efx_nic *efx)
+{
+	struct pci_dev *dev = efx->pci_dev;
+
+	pci_disable_sriov(dev);
+	efx_ef10_sriov_free_vf_vswitching(efx);
+	efx->vf_count = 0;
+	return 0;
+}
+
+int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs)
+{
+	if (num_vfs == 0)
+		return efx_ef10_pci_sriov_disable(efx);
+	else
+		return efx_ef10_pci_sriov_enable(efx, num_vfs);
+}
+
+int efx_ef10_sriov_init(struct efx_nic *efx)
+{
+	return 0;
+}
+
+void efx_ef10_sriov_fini(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	int rc;
+
+	if (!nic_data->vf)
+		return;
+
+	rc = efx_ef10_pci_sriov_disable(efx);
+	if (rc)
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Disabling SRIOV was not successful rc=%d\n", rc);
+	else
+		netif_dbg(efx, drv, efx->net_dev, "SRIOV disabled\n");
+}
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 40833db..42d7145 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -12,6 +12,18 @@
 
 #include "net_driver.h"
 
+/**
+ * struct ef10_vf - PF's store of VF data
+ * @vport_id: vport ID for the VF
+ * @vport_assigned: record whether the vport is currently assigned to the VF
+ * @mac: MAC address for the VF, zero when address is removed from the vport
+ */
+struct ef10_vf {
+	unsigned int vport_id;
+	unsigned int vport_assigned;
+	u8 mac[ETH_ALEN];
+};
+
 static inline bool efx_ef10_sriov_wanted(struct efx_nic *efx)
 {
 	return false;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index b350c39..e833e97 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -496,6 +496,9 @@ enum {
  * @vport_id: The function's vport ID, only relevant for PFs
  * @must_probe_vswitching: Flag: vswitching has yet to be setup after MC reboot
  * @pf_index: The number for this PF, or the parent PF if this is a VF
+#ifdef CONFIG_SFC_SRIOV
+ * @vf: Pointer to VF data structure
+#endif
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -519,6 +522,10 @@ struct efx_ef10_nic_data {
 	unsigned int vport_id;
 	bool must_probe_vswitching;
 	unsigned int pf_index;
+#ifdef CONFIG_SFC_SRIOV
+	struct ef10_vf *vf;
+#endif
+	u8 vport_mac[ETH_ALEN];
 };
 
 int efx_init_sriov(void);
