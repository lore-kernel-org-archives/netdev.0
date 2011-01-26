From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-2.6] bnx2: Eliminate AER error messages on systems
 not supporting it
Date: Wed, 26 Jan 2011 00:14:51 -0800
Message-ID: <1296029691-3591-2-git-send-email-mchan@broadcom.com>
References: <1296029691-3591-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3044 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab1AZJJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 04:09:03 -0500
In-Reply-To: <1296029691-3591-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On PPC for example, AER is not supported and we see unnecessary AER
error message without this patch:

bnx2 0003:01:00.1: pci_cleanup_aer_uncorrect_error_status failed 0xfffffffb

Reported-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   17 +++++++++--------
 drivers/net/bnx2.h |    1 +
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 99e7652..62c6079 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7966,11 +7966,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 		/* AER (Advanced Error Reporting) hooks */
 		err = pci_enable_pcie_error_reporting(pdev);
-		if (err) {
-			dev_err(&pdev->dev, "pci_enable_pcie_error_reporting "
-					    "failed 0x%x\n", err);
-			/* non-fatal, continue */
-		}
+		if (!err)
+			bp->flags |= BNX2_FLAG_AER_ENABLED;
 
 	} else {
 		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
@@ -8233,8 +8230,10 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	return 0;
 
 err_out_unmap:
-	if (bp->flags & BNX2_FLAG_PCIE)
+	if (bp->flags & BNX2_FLAG_AER_ENABLED) {
 		pci_disable_pcie_error_reporting(pdev);
+		bp->flags &= ~BNX2_FLAG_AER_ENABLED;
+	}
 
 	if (bp->regview) {
 		iounmap(bp->regview);
@@ -8422,8 +8421,10 @@ bnx2_remove_one(struct pci_dev *pdev)
 
 	kfree(bp->temp_stats_blk);
 
-	if (bp->flags & BNX2_FLAG_PCIE)
+	if (bp->flags & BNX2_FLAG_AER_ENABLED) {
 		pci_disable_pcie_error_reporting(pdev);
+		bp->flags &= ~BNX2_FLAG_AER_ENABLED;
+	}
 
 	free_netdev(dev);
 
@@ -8539,7 +8540,7 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 	}
 	rtnl_unlock();
 
-	if (!(bp->flags & BNX2_FLAG_PCIE))
+	if (!bp->flags & BNX2_FLAG_AER_ENABLED)
 		return result;
 
 	err = pci_cleanup_aer_uncorrect_error_status(pdev);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 5488a2e..f459fb2 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6741,6 +6741,7 @@ struct bnx2 {
 #define BNX2_FLAG_JUMBO_BROKEN		0x00000800
 #define BNX2_FLAG_CAN_KEEP_VLAN		0x00001000
 #define BNX2_FLAG_BROKEN_STATS		0x00002000
+#define BNX2_FLAG_AER_ENABLED		0x00004000
 
 	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
 
-- 
1.6.4.GIT


