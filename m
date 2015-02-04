From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] qlogic: Deletion of unnecessary checks before two function
 calls
Date: Wed, 04 Feb 2015 14:13:37 +0100
Message-ID: <54D21B01.30802@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 4 Feb 2015 14:07:56 +0100

The functions kfree() and vfree() perform also input parameter validation.
Thus the test around their calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 24 ++++++++--------------
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  3 +--
 2 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 2528c3f..a430a34a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -294,9 +294,7 @@ int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 {
-	if (recv_ctx->sds_rings != NULL)
-		kfree(recv_ctx->sds_rings);
-
+	kfree(recv_ctx->sds_rings);
 	recv_ctx->sds_rings = NULL;
 }
 
@@ -1257,8 +1255,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	if (ahw->op_mode != QLCNIC_NON_PRIV_FUNC) {
 		if (fw_dump->tmpl_hdr == NULL ||
 				adapter->fw_version > prev_fw_version) {
-			if (fw_dump->tmpl_hdr)
-				vfree(fw_dump->tmpl_hdr);
+			vfree(fw_dump->tmpl_hdr);
 			if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
 				dev_info(&pdev->dev,
 					"Supports FW dump capability\n");
@@ -2374,13 +2371,12 @@ void qlcnic_free_tx_rings(struct qlcnic_adapter *adapter)
 
 	for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
 		tx_ring = &adapter->tx_ring[ring];
-		if (tx_ring && tx_ring->cmd_buf_arr != NULL) {
+		if (tx_ring) {
 			vfree(tx_ring->cmd_buf_arr);
 			tx_ring->cmd_buf_arr = NULL;
 		}
 	}
-	if (adapter->tx_ring != NULL)
-		kfree(adapter->tx_ring);
+	kfree(adapter->tx_ring);
 }
 
 int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
@@ -2758,13 +2754,9 @@ static void qlcnic_remove(struct pci_dev *pdev)
 	}
 
 	qlcnic_dcb_free(adapter->dcb);
-
 	qlcnic_detach(adapter);
-
-	if (adapter->npars != NULL)
-		kfree(adapter->npars);
-	if (adapter->eswitch != NULL)
-		kfree(adapter->eswitch);
+	kfree(adapter->npars);
+	kfree(adapter->eswitch);
 
 	if (qlcnic_82xx_check(adapter))
 		qlcnic_clr_all_drv_state(adapter, 0);
@@ -2932,13 +2924,13 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 {
-	if (adapter->fhash.fmax && adapter->fhash.fhead)
+	if (adapter->fhash.fmax)
 		kfree(adapter->fhash.fhead);
 
 	adapter->fhash.fhead = NULL;
 	adapter->fhash.fmax = 0;
 
-	if (adapter->rx_fhash.fmax && adapter->rx_fhash.fhead)
+	if (adapter->rx_fhash.fmax)
 		kfree(adapter->rx_fhash.fhead);
 
 	adapter->rx_fhash.fmax = 0;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index c9f57fb..332bb8a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1407,8 +1407,7 @@ void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *adapter)
 	current_version = qlcnic_83xx_get_fw_version(adapter);
 
 	if (fw_dump->tmpl_hdr == NULL || current_version > prev_version) {
-		if (fw_dump->tmpl_hdr)
-			vfree(fw_dump->tmpl_hdr);
+		vfree(fw_dump->tmpl_hdr);
 		if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
 			dev_info(&pdev->dev, "Supports FW dump capability\n");
 	}
-- 
2.2.2
