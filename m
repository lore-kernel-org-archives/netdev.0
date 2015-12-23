From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next v2 5/5] sfc: Downgrade or remove some error messages
Date: Wed, 23 Dec 2015 08:58:15 +0000
Message-ID: <567A6227.40404@solarflare.com>
References: <567A6170.6010104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:37979 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751746AbbLWI6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 03:58:47 -0500
In-Reply-To: <567A6170.6010104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on configuration the NIC may return errors for unprivileged
functions and/or VFs. Where these are expected and handled, reduce the
level of any output.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 20 ++++++++++++++------
 drivers/net/ethernet/sfc/efx.c  |  7 ++++---
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index b0c6c61..98d33d4 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -486,10 +486,17 @@ static int efx_ef10_alloc_piobufs(struct efx_nic *efx, unsigned int n)
 	BUILD_BUG_ON(MC_CMD_ALLOC_PIOBUF_IN_LEN != 0);
 
 	for (i = 0; i < n; i++) {
-		rc = efx_mcdi_rpc(efx, MC_CMD_ALLOC_PIOBUF, NULL, 0,
-				  outbuf, sizeof(outbuf), &outlen);
-		if (rc)
+		rc = efx_mcdi_rpc_quiet(efx, MC_CMD_ALLOC_PIOBUF, NULL, 0,
+					outbuf, sizeof(outbuf), &outlen);
+		if (rc) {
+			/* Don't display the MC error if we didn't have space
+			 * for a VF.
+			 */
+			if (!(efx_ef10_is_vf(efx) && rc == -ENOSPC))
+				efx_mcdi_display_error(efx, MC_CMD_ALLOC_PIOBUF,
+						       0, outbuf, outlen, rc);
 			break;
+		}
 		if (outlen < MC_CMD_ALLOC_PIOBUF_OUT_LEN) {
 			rc = -EIO;
 			break;
@@ -4028,9 +4035,10 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 
 	rc = efx_ef10_filter_insert(efx, &spec, true);
 	if (rc < 0) {
-		netif_warn(efx, drv, efx->net_dev,
-			   "%scast mismatch filter insert failed rc=%d\n",
-			   multicast ? "Multi" : "Uni", rc);
+		netif_printk(efx, drv, rc == -EPERM ? KERN_DEBUG : KERN_WARNING,
+			     efx->net_dev,
+			     "%scast mismatch filter insert failed rc=%d\n",
+			     multicast ? "Multi" : "Uni", rc);
 	} else if (multicast) {
 		table->mcdef_id = efx_ef10_filter_get_unsafe_id(efx, rc);
 		if (!nic_data->workaround_26807) {
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 6f69743..0705ec86 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3174,14 +3174,15 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	rtnl_lock();
 	rc = efx_mtd_probe(efx);
 	rtnl_unlock();
-	if (rc)
+	if (rc && rc != -EPERM)
 		netif_warn(efx, probe, efx->net_dev,
 			   "failed to create MTDs (%d)\n", rc);
 
 	rc = pci_enable_pcie_error_reporting(pci_dev);
 	if (rc && rc != -EINVAL)
-		netif_warn(efx, probe, efx->net_dev,
-			   "pci_enable_pcie_error_reporting failed (%d)\n", rc);
+		netif_notice(efx, probe, efx->net_dev,
+			     "PCIE error reporting unavailable (%d).\n",
+			     rc);
 
 	return 0;
 
-- 
2.4.3
