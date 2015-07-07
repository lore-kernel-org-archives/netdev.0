From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 1/3] sfc: refactor code in efx_ef10_set_mac_address()
Date: Tue, 7 Jul 2015 11:37:00 +0100
Message-ID: <559BABCC.9060704@solarflare.com>
References: <559BAB66.1080905@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:48095 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756459AbbGGKhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:37:06 -0400
In-Reply-To: <559BAB66.1080905@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Re-organize the structure of error handling to avoid having
to duplicate the netif_err() around the ifdefs.

The only change to the behaviour of the error-handling is that
the PF's data structure to record VF details should only be
updated if the original command succeeded.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 45 ++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 8476434..9740cd0 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3829,38 +3829,27 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 		efx_net_open(efx->net_dev);
 	netif_device_attach(efx->net_dev);
 
-#if !defined(CONFIG_SFC_SRIOV)
-	if (rc == -EPERM)
-		netif_err(efx, drv, efx->net_dev,
-			  "Cannot change MAC address; use sfboot to enable mac-spoofing"
-			  " on this interface\n");
-#else
-	if (rc == -EPERM) {
+#ifdef CONFIG_SFC_SRIOV
+	if (efx->pci_dev->is_virtfn && efx->pci_dev->physfn) {
 		struct pci_dev *pci_dev_pf = efx->pci_dev->physfn;
 
-		/* Switch to PF and change MAC address on vport */
-		if (efx->pci_dev->is_virtfn && pci_dev_pf) {
-			struct efx_nic *efx_pf = pci_get_drvdata(pci_dev_pf);
+		if (rc == -EPERM) {
+			struct efx_nic *efx_pf;
 
-			if (!efx_ef10_sriov_set_vf_mac(efx_pf,
-						       nic_data->vf_index,
-						       efx->net_dev->dev_addr))
-				return 0;
-		}
-		netif_err(efx, drv, efx->net_dev,
-			  "Cannot change MAC address; use sfboot to enable mac-spoofing"
-			  " on this interface\n");
-	} else if (efx->pci_dev->is_virtfn) {
-		/* Successfully changed by VF (with MAC spoofing), so update the
-		 * parent PF if possible.
-		 */
-		struct pci_dev *pci_dev_pf = efx->pci_dev->physfn;
+			/* Switch to PF and change MAC address on vport */
+			efx_pf = pci_get_drvdata(pci_dev_pf);
 
-		if (pci_dev_pf) {
+			rc = efx_ef10_sriov_set_vf_mac(efx_pf,
+						       nic_data->vf_index,
+						       efx->net_dev->dev_addr);
+		} else if (!rc) {
 			struct efx_nic *efx_pf = pci_get_drvdata(pci_dev_pf);
 			struct efx_ef10_nic_data *nic_data = efx_pf->nic_data;
 			unsigned int i;
 
+			/* MAC address successfully changed by VF (with MAC
+			 * spoofing) so update the parent PF if possible.
+			 */
 			for (i = 0; i < efx_pf->vf_count; ++i) {
 				struct ef10_vf *vf = nic_data->vf + i;
 
@@ -3871,8 +3860,14 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 				}
 			}
 		}
-	}
+	} else
 #endif
+	if (rc == -EPERM) {
+		netif_err(efx, drv, efx->net_dev,
+			  "Cannot change MAC address; use sfboot to enable"
+			  " mac-spoofing on this interface\n");
+	}
+
 	return rc;
 }
 
