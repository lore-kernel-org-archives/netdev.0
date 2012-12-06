From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5 net-next] cnic, bnx2x, bnx2: Simplify cnic probing.
Date: Thu, 6 Dec 2012 12:33:12 -0800
Message-ID: <1354825992-8547-5-git-send-email-mchan@broadcom.com>
References: <1354825992-8547-1-git-send-email-mchan@broadcom.com>
 <1354825992-8547-2-git-send-email-mchan@broadcom.com>
 <1354825992-8547-3-git-send-email-mchan@broadcom.com>
 <1354825992-8547-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4808 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422829Ab2LFUSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 15:18:00 -0500
In-Reply-To: <1354825992-8547-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using symbol_get(), cnic can now directly call the cnic_probe
functions in struct bnx2x and struct bnx2.  symbol_get() is not reliable
as it fails when the module is still initializing.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c             |    2 +-
 drivers/net/ethernet/broadcom/bnx2.h             |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 +++-
 drivers/net/ethernet/broadcom/cnic.c             |   21 +++++++++------------
 drivers/net/ethernet/broadcom/cnic_if.h          |    7 ++-----
 6 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index a9b2fea..c16526d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -434,7 +434,6 @@ struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
 
 	return cp;
 }
-EXPORT_SYMBOL(bnx2_cnic_probe);
 
 static void
 bnx2_cnic_stop(struct bnx2 *bp)
@@ -8422,6 +8421,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->cnic_eth_dev.max_iscsi_conn =
 			(bnx2_shmem_rd(bp, BNX2_ISCSI_MAX_CONN) &
 			 BNX2_ISCSI_MAX_CONN_MASK) >> BNX2_ISCSI_MAX_CONN_SHIFT;
+	bp->cnic_probe = bnx2_cnic_probe;
 #endif
 	pci_save_state(pdev);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 38a640d..172efbe 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6984,6 +6984,7 @@ struct bnx2 {
 #ifdef BCM_CNIC
 	struct mutex		cnic_lock;
 	struct cnic_eth_dev	cnic_eth_dev;
+	struct cnic_eth_dev	*(*cnic_probe)(struct net_device *);
 #endif
 
 	const struct firmware	*mips_firmware;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 02ea644..defa7d6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1337,6 +1337,7 @@ struct bnx2x {
 	u8			cnic_support;
 	bool			cnic_enabled;
 	bool			cnic_loaded;
+	struct cnic_eth_dev	*(*cnic_probe)(struct net_device *);
 
 	/* Flag that indicates that we can start looking for FCoE L2 queue
 	 * completions in the default status block.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 75aea83..f34ff59 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12018,6 +12018,8 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
 	return control & PCI_MSIX_FLAGS_QSIZE;
 }
 
+struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *);
+
 static int bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -12097,6 +12099,7 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	bp->igu_sb_cnt = max_non_def_sbs;
 	bp->msg_enable = debug;
 	bp->cnic_support = cnic_cnt;
+	bp->cnic_probe = bnx2x_cnic_probe;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -13038,6 +13041,5 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	   cp->starting_cid);
 	return cp;
 }
-EXPORT_SYMBOL(bnx2x_cnic_probe);
 
 
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index b865093..df8c30d 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -40,6 +40,7 @@
 #include <net/ip6_checksum.h>
 #include <scsi/iscsi_if.h>
 
+#define BCM_CNIC	1
 #include "cnic_if.h"
 #include "bnx2.h"
 #include "bnx2x/bnx2x.h"
@@ -5449,14 +5450,12 @@ static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
 	struct pci_dev *pdev;
 	struct cnic_dev *cdev;
 	struct cnic_local *cp;
+	struct bnx2 *bp = netdev_priv(dev);
 	struct cnic_eth_dev *ethdev = NULL;
-	struct cnic_eth_dev *(*probe)(struct net_device *) = NULL;
 
-	probe = symbol_get(bnx2_cnic_probe);
-	if (probe) {
-		ethdev = (*probe)(dev);
-		symbol_put(bnx2_cnic_probe);
-	}
+	if (bp->cnic_probe)
+		ethdev = (bp->cnic_probe)(dev);
+
 	if (!ethdev)
 		return NULL;
 
@@ -5511,14 +5510,12 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	struct pci_dev *pdev;
 	struct cnic_dev *cdev;
 	struct cnic_local *cp;
+	struct bnx2x *bp = netdev_priv(dev);
 	struct cnic_eth_dev *ethdev = NULL;
-	struct cnic_eth_dev *(*probe)(struct net_device *) = NULL;
 
-	probe = symbol_get(bnx2x_cnic_probe);
-	if (probe) {
-		ethdev = (*probe)(dev);
-		symbol_put(bnx2x_cnic_probe);
-	}
+	if (bp->cnic_probe)
+		ethdev = bp->cnic_probe(dev);
+
 	if (!ethdev)
 		return NULL;
 
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 502e11e..2a35436 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.15"
-#define CNIC_MODULE_RELDATE	"Dec 04, 2012"
+#define CNIC_MODULE_VERSION	"2.5.16"
+#define CNIC_MODULE_RELDATE	"Dec 05, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
@@ -353,7 +353,4 @@ extern int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
 
 extern int cnic_unregister_driver(int ulp_type);
 
-extern struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev);
-extern struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev);
-
 #endif
-- 
1.7.1
