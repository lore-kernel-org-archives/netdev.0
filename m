From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 13/14] sfc: force removal of VF and vport on driver
 removal
Date: Mon, 1 Jun 2015 14:03:33 +0100
Message-ID: <556C5825.4060702@solarflare.com>
References: <556C5704.4060901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:21626 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363AbbFANDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 09:03:41 -0400
In-Reply-To: <556C5704.4060901@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

When the driver unloads, force the unbind and removal of any
VFs in the host with the PF.  The PF cannot remove vports and
vswitches if they are still being used by a VF driver, and when
unloading the sfc driver the removal order is not guaranteed,
so the instruction from the PF to the VF to unbind enforces a
suitable ordering so that vswitches and vports can be removed.

As a result of this, manually unbinding the driver from a single
PF will result in all of its VFs in the host also being removed.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 9 +++++++++
 drivers/net/ethernet/sfc/efx.c        | 3 ++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index 083c534..41ab18d 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -448,11 +448,20 @@ int efx_ef10_sriov_init(struct efx_nic *efx)
 void efx_ef10_sriov_fini(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	unsigned int i;
 	int rc;
 
 	if (!nic_data->vf)
 		return;
 
+	/* Remove any VFs in the host */
+	for (i = 0; i < efx->vf_count; ++i) {
+		struct efx_nic *vf_efx = nic_data->vf[i].efx;
+
+		if (vf_efx)
+			vf_efx->pci_dev->driver->remove(vf_efx->pci_dev);
+	}
+
 	rc = efx_ef10_pci_sriov_disable(efx);
 	if (rc)
 		netif_dbg(efx, drv, efx->net_dev,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index fe3481c..6887871 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2867,7 +2867,8 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 }
 
 /* Final NIC shutdown
- * This is called only at module unload (or hotplug removal).
+ * This is called only at module unload (or hotplug removal).  A PF can call
+ * this on its VFs to ensure they are unbound first.
  */
 static void efx_pci_remove(struct pci_dev *pci_dev)
 {
