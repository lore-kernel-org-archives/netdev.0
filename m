From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 06/16] sfc: Store the efx_nic struct of the current
 VF in the VF data struct
Date: Mon, 18 May 2015 16:28:50 +0100
Message-ID: <555A0532.5040301@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:45805 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753813AbbERP26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:28:58 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialised in efx_probe_vf and removal is dealt with in
efx_ef10_remove.

vf->efx is needed in future patches to change the MAC address
of the VF via the parent PF, while the driver is bound to the
VF.
Example: ip link set dev vf NUM mac LLADDR

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 32 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.c |  3 +++
 drivers/net/ethernet/sfc/ef10_sriov.h |  2 ++
 3 files changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 8b6579a..78d3236 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -544,6 +544,25 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	int rc;
 
+#ifdef CONFIG_SFC_SRIOV
+	struct efx_ef10_nic_data *nic_data_pf;
+	struct pci_dev *pci_dev_pf;
+	struct efx_nic *efx_pf;
+	struct ef10_vf *vf;
+
+	if (efx->pci_dev->is_virtfn) {
+		pci_dev_pf = efx->pci_dev->physfn;
+		if (pci_dev_pf) {
+			efx_pf = pci_get_drvdata(pci_dev_pf);
+			nic_data_pf = efx_pf->nic_data;
+			vf = nic_data_pf->vf + nic_data->vf_index;
+			vf->efx = NULL;
+		} else
+			netif_info(efx, drv, efx->net_dev,
+				   "Could not get the PF id from VF\n");
+	}
+#endif
+
 	efx_ptp_remove(efx);
 
 	efx_mcdi_mon_remove(efx);
@@ -582,6 +601,19 @@ static int efx_ef10_probe_vf(struct efx_nic *efx)
 	if (rc)
 		goto fail;
 
+	if (efx->pci_dev->is_virtfn) {
+		if (efx->pci_dev->physfn) {
+			struct efx_nic *efx_pf =
+				pci_get_drvdata(efx->pci_dev->physfn);
+			struct efx_ef10_nic_data *nic_data_p = efx_pf->nic_data;
+			struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+			nic_data_p->vf[nic_data->vf_index].efx = efx;
+		} else
+			netif_info(efx, drv, efx->net_dev,
+				   "Could not get the PF id from VF\n");
+	}
+
 	return 0;
 
 fail:
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 1b93acf..6208dd7 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -160,6 +160,8 @@ static void efx_ef10_sriov_free_vf_vports(struct efx_nic *efx)
 			efx_ef10_vport_free(efx, vf->vport_id);
 			vf->vport_id = 0;
 		}
+
+		vf->efx = NULL;
 	}
 }
 
@@ -215,6 +217,7 @@ static int efx_ef10_sriov_alloc_vf_vswitching(struct efx_nic *efx)
 
 	for (i = 0; i < efx->vf_count; i++) {
 		random_ether_addr(nic_data->vf[i].mac);
+		nic_data->vf[i].efx = NULL;
 
 		rc = efx_ef10_sriov_assign_vf_vport(efx, i);
 		if (rc)
diff --git a/drivers/net/ethernet/sfc/ef10_sriov.h b/drivers/net/ethernet/sfc/ef10_sriov.h
index 8b67163..6f27a0d 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.h
+++ b/drivers/net/ethernet/sfc/ef10_sriov.h
@@ -14,11 +14,13 @@
 
 /**
  * struct ef10_vf - PF's store of VF data
+ * @efx: efx_nic struct for the current VF
  * @vport_id: vport ID for the VF
  * @vport_assigned: record whether the vport is currently assigned to the VF
  * @mac: MAC address for the VF, zero when address is removed from the vport
  */
 struct ef10_vf {
+	struct efx_nic *efx;
 	unsigned int vport_id;
 	unsigned int vport_assigned;
 	u8 mac[ETH_ALEN];
