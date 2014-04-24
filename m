From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/3] bnx2x: Memory leak during VF removal
Date: Thu, 24 Apr 2014 19:29:52 +0300
Message-ID: <1398356994-30759-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1398356994-30759-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54427 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbaDXQaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:30:12 -0400
In-Reply-To: <1398356994-30759-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When removing a VF interface, the driver fails to release that VF's mailbox
and bulletin board allocated memory.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 13 +++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  2 ++
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a78edac..b260913 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13233,6 +13233,8 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 				iounmap(bp->doorbells);
 
 			bnx2x_release_firmware(bp);
+		} else {
+			bnx2x_vf_pci_dealloc(bp);
 		}
 		bnx2x_free_mem_bp(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 5c523b3..046c9cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2896,6 +2896,14 @@ void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 	return bp->regview + PXP_VF_ADDR_DB_START;
 }
 
+void bnx2x_vf_pci_dealloc(struct bnx2x *bp)
+{
+	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->vf2pf_mbox_mapping,
+		       sizeof(struct bnx2x_vf_mbx_msg));
+	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->pf2vf_bulletin_mapping,
+		       sizeof(union pf_vf_bulletin));
+}
+
 int bnx2x_vf_pci_alloc(struct bnx2x *bp)
 {
 	mutex_init(&bp->vf2pf_mutex);
@@ -2915,10 +2923,7 @@ int bnx2x_vf_pci_alloc(struct bnx2x *bp)
 	return 0;
 
 alloc_mem_err:
-	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->vf2pf_mbox_mapping,
-		       sizeof(struct bnx2x_vf_mbx_msg));
-	BNX2X_PCI_FREE(bp->vf2pf_mbox, bp->pf2vf_bulletin_mapping,
-		       sizeof(union pf_vf_bulletin));
+	bnx2x_vf_pci_dealloc(bp);
 	return -ENOMEM;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 8bf7645..bb16c4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -502,6 +502,7 @@ static inline int bnx2x_vf_ustorm_prods_offset(struct bnx2x *bp,
 enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp);
 void bnx2x_timer_sriov(struct bnx2x *bp);
 void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp);
+void bnx2x_vf_pci_dealloc(struct bnx2x *bp);
 int bnx2x_vf_pci_alloc(struct bnx2x *bp);
 int bnx2x_enable_sriov(struct bnx2x *bp);
 void bnx2x_disable_sriov(struct bnx2x *bp);
@@ -568,6 +569,7 @@ static inline void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 	return NULL;
 }
 
+static inline void bnx2x_vf_pci_dealloc(struct bnx2 *bp) {return 0; }
 static inline int bnx2x_vf_pci_alloc(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp) {}
 static inline int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs) {return 0; }
-- 
1.8.1.4
