From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 15/15] sfc: leak vports if a VF is assigned during
 PF unload
Date: Tue, 2 Jun 2015 11:41:00 +0100
Message-ID: <556D883C.5070205@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:58832 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755833AbbFBKlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:41:06 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

If any VF is assigned as the PF is unloaded, do not attempt to
remove its vport or the vswitch.  These will be removed if the
driver binds to the PF again, as an entity reset occurs during
probe.

A 'force' flag is added to efx_ef10_pci_sriov_disable() to
distinguish between disabling SR-IOV and driver unload.
SR-IOV cannot be disabled if VFs are assigned to guests.

If the PF driver is unloaded while VFs are assigned, the driver
may try to bind to the VF again at a later point if the driver
has been reloaded and the VF returns to the same domain as the PF.
In this case, the PF will not have a VF data structure, so the VF
can check this and drop out of probe early.

In this case, efx->vf_count will be zero but VFs will be present.
The user is advised to remove the VF and re-create it. The check
at the beginning of efx_ef10_pci_sriov_disable() that
efx->vf_count is non-zero is removed to allow SR-IOV to be
disabled in this case. Also, if the PF driver is unloaded, it
will disable SR-IOV to remove these unknown VFs.

By not disabling bus-mastering if VFs are still assigned, the VF
will continue to pass traffic after the PF has been removed.

When using the max_vfs module parameter, if VFs are already
present do not try to initialise any more.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 20 ++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.c | 35 ++++++++++++++++++++++++-----------
 drivers/net/ethernet/sfc/ef10_sriov.h |  2 ++
 drivers/net/ethernet/sfc/efx.c        |  4 +++-
 4 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 6b8d8f2..8476434 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -681,6 +681,24 @@ static int efx_ef10_probe_pf(struct efx_nic *efx)
 static int efx_ef10_probe_vf(struct efx_nic *efx)
 {
 	int rc;
+	struct pci_dev *pci_dev_pf;
+
+	/* If the parent PF has no VF data structure, it doesn't know about this
+	 * VF so fail probe.  The VF needs to be re-created.  This can happen
+	 * if the PF driver is unloaded while the VF is assigned to a guest.
+	 */
+	pci_dev_pf = efx->pci_dev->physfn;
+	if (pci_dev_pf) {
+		struct efx_nic *efx_pf = pci_get_drvdata(pci_dev_pf);
+		struct efx_ef10_nic_data *nic_data_pf = efx_pf->nic_data;
+
+		if (!nic_data_pf->vf) {
+			netif_info(efx, drv, efx->net_dev,
+				   "The VF cannot link to its parent PF; "
+				   "please destroy and re-create the VF\n");
+			return -EBUSY;
+		}
+	}
 
 	rc = efx_ef10_probe(efx);
 	if (rc)
@@ -698,6 +716,8 @@ static int efx_ef10_probe_vf(struct efx_nic *efx)
 			struct efx_ef10_nic_data *nic_data = efx->nic_data;
 
 			nic_data_p->vf[nic_data->vf_index].efx = efx;
+			nic_data_p->vf[nic_data->vf_index].pci_dev =
+				efx->pci_dev;
 		} else
 			netif_info(efx, drv, efx->net_dev,
 				   "Could not get the PF id from VF\n");
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 41ab18d..6c9b6e4 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -165,6 +165,11 @@ static void efx_ef10_sriov_free_vf_vports(struct efx_nic *efx)
 	for (i = 0; i < efx->vf_count; i++) {
 		struct ef10_vf *vf = nic_data->vf + i;
 
+		/* If VF is assigned, do not free the vport  */
+		if (vf->pci_dev &&
+		    vf->pci_dev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
+			continue;
+
 		if (vf->vport_assigned) {
 			efx_ef10_evb_port_assign(efx, EVB_PORT_ID_NULL, i);
 			vf->vport_assigned = 0;
@@ -380,7 +385,9 @@ void efx_ef10_vswitching_remove_pf(struct efx_nic *efx)
 	efx_ef10_vport_free(efx, nic_data->vport_id);
 	nic_data->vport_id = EVB_PORT_ID_ASSIGNED;
 
-	efx_ef10_vswitch_free(efx, nic_data->vport_id);
+	/* Only free the vswitch if no VFs are assigned */
+	if (!pci_vfs_assigned(efx->pci_dev))
+		efx_ef10_vswitch_free(efx, nic_data->vport_id);
 }
 
 void efx_ef10_vswitching_remove_vf(struct efx_nic *efx)
@@ -413,20 +420,22 @@ fail1:
 	return rc;
 }
 
-static int efx_ef10_pci_sriov_disable(struct efx_nic *efx)
+static int efx_ef10_pci_sriov_disable(struct efx_nic *efx, bool force)
 {
 	struct pci_dev *dev = efx->pci_dev;
+	unsigned int vfs_assigned = 0;
 
-	if (!efx->vf_count)
-		return 0;
+	vfs_assigned = pci_vfs_assigned(dev);
 
-	if (pci_vfs_assigned(dev)) {
-		netif_err(efx, drv, efx->net_dev, "VFs are assigned to guests; "
-			  "please detach them before disabling SR-IOV\n");
+	if (vfs_assigned && !force) {
+		netif_info(efx, drv, efx->net_dev, "VFs are assigned to guests; "
+			   "please detach them before disabling SR-IOV\n");
 		return -EBUSY;
 	}
 
-	pci_disable_sriov(dev);
+	if (!vfs_assigned)
+		pci_disable_sriov(dev);
+
 	efx_ef10_sriov_free_vf_vswitching(efx);
 	efx->vf_count = 0;
 	return 0;
@@ -435,7 +444,7 @@ static int efx_ef10_pci_sriov_disable(struct efx_nic *efx)
 int efx_ef10_sriov_configure(struct efx_nic *efx, int num_vfs)
 {
 	if (num_vfs == 0)
-		return efx_ef10_pci_sriov_disable(efx);
+		return efx_ef10_pci_sriov_disable(efx, false);
 	else
 		return efx_ef10_pci_sriov_enable(efx, num_vfs);
 }
@@ -451,8 +460,12 @@ void efx_ef10_sriov_fini(struct efx_nic *efx)
 	unsigned int i;
 	int rc;
 
-	if (!nic_data->vf)
+	if (!nic_data->vf) {
+		/* Remove any un-assigned orphaned VFs */
+		if (pci_num_vf(efx->pci_dev) && !pci_vfs_assigned(efx->pci_dev))
+			pci_disable_sriov(efx->pci_dev);
 		return;
+	}
 
 	/* Remove any VFs in the host */
 	for (i = 0; i < efx->vf_count; ++i) {
@@ -462,7 +475,7 @@ void efx_ef10_sriov_fini(struct efx_nic *efx)
 			vf_efx->pci_dev->driver->remove(vf_efx->pci_dev);
 	}
 
-	rc = efx_ef10_pci_sriov_disable(efx);
+	rc = efx_ef10_pci_sriov_disable(efx, true);
 	if (rc)
 		netif_dbg(efx, drv, efx->net_dev,
 			  "Disabling SRIOV was not successful rc=%d\n", rc);
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index ffc92a5..db4ef53 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -15,6 +15,7 @@
 /**
  * struct ef10_vf - PF's store of VF data
  * @efx: efx_nic struct for the current VF
+ * @pci_dev: the pci_dev struct for the VF, retained while the VF is assigned
  * @vport_id: vport ID for the VF
  * @vport_assigned: record whether the vport is currently assigned to the VF
  * @mac: MAC address for the VF, zero when address is removed from the vport
@@ -22,6 +23,7 @@
  */
 struct ef10_vf {
 	struct efx_nic *efx;
+	struct pci_dev *pci_dev;
 	unsigned int vport_id;
 	unsigned int vport_assigned;
 	u8 mac[ETH_ALEN];
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 62b2139..0c42ed9 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1298,7 +1298,9 @@ static void efx_fini_io(struct efx_nic *efx)
 		efx->membase_phys = 0;
 	}
 
-	pci_disable_device(efx->pci_dev);
+	/* Don't disable bus-mastering if VFs are assigned */
+	if (!pci_vfs_assigned(efx->pci_dev))
+		pci_disable_device(efx->pci_dev);
 }
 
 void efx_set_default_rx_indir_table(struct efx_nic *efx)
