From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 4/5] be2net: dynamically allocate adapter->vf_cfg
Date: Wed, 6 Apr 2011 23:08:30 -0500
Message-ID: <20110407040830.GA4231@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55054 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750950Ab1DGEIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:08:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of a fixed sized array for vf_cfg, allocate the size dynamically
depending on number of VFs the device supports.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h      |    4 +---
 drivers/net/benet/be_main.c |   14 ++++++++++++--
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index eba405b..1d976b8 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -92,8 +92,6 @@ static inline char *nic_name(struct pci_dev *pdev)
 
 #define FW_VER_LEN		32
 
-#define BE_MAX_VF		32
-
 struct be_dma_mem {
 	void *va;
 	dma_addr_t dma;
@@ -336,7 +334,7 @@ struct be_adapter {
 
 	bool be3_native;
 	bool sriov_enabled;
-	struct be_vf_cfg vf_cfg[BE_MAX_VF];
+	struct be_vf_cfg *vf_cfg;
 	u8 is_virtfn;
 	u32 sli_family;
 	u8 hba_port_num;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9d6982a..6a43b26 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2837,6 +2837,7 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	be_ctrl_cleanup(adapter);
 
+	kfree(adapter->vf_cfg);
 	be_sriov_disable(adapter);
 
 	be_msix_disable(adapter);
@@ -3021,16 +3022,23 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	}
 
 	be_sriov_enable(adapter);
+	if (adapter->sriov_enabled) {
+		adapter->vf_cfg = kcalloc(num_vfs,
+			sizeof(struct be_vf_cfg), GFP_KERNEL);
+
+		if (!adapter->vf_cfg)
+			goto free_netdev;
+	}
 
 	status = be_ctrl_init(adapter);
 	if (status)
-		goto free_netdev;
+		goto free_vf_cfg;
 
 	if (lancer_chip(adapter)) {
 		status = lancer_test_and_set_rdy_state(adapter);
 		if (status) {
 			dev_err(&pdev->dev, "Adapter in non recoverable error\n");
-			goto free_netdev;
+			goto ctrl_clean;
 		}
 	}
 
@@ -3092,6 +3100,8 @@ stats_clean:
 	be_stats_cleanup(adapter);
 ctrl_clean:
 	be_ctrl_cleanup(adapter);
+free_vf_cfg:
+	kfree(adapter->vf_cfg);
 free_netdev:
 	be_sriov_disable(adapter);
 	free_netdev(netdev);
-- 
1.7.1

