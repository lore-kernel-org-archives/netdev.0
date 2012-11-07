From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/7] be2net: remove roce on lancer
Date: Wed, 7 Nov 2012 09:19:00 +0530
Message-ID: <029f044d-01df-4938-9a86-5bd886988ed3@CMEXHTCAS2.ad.emulex.com>
References: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25378 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab2KGDqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:20 -0500
In-Reply-To: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roce interface is suppored only on Skyhawk-R.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   12 ++----------
 drivers/net/ethernet/emulex/benet/be_main.c |   16 +---------------
 drivers/net/ethernet/emulex/benet/be_roce.c |    5 +----
 3 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index e391d5a..472d98e 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -411,7 +411,6 @@ struct be_adapter {
 	bool stats_cmd_sent;
 	u32 if_type;
 	struct {
-		u8 __iomem *base;	/* Door Bell */
 		u32 size;
 		u32 total_size;
 		u64 io_addr;
@@ -473,9 +472,8 @@ struct be_adapter {
 
 #define BEx_chip(adapter)	(BE3_chip(adapter) || BE2_chip(adapter))
 
-#define be_roce_supported(adapter) ((adapter->if_type == SLI_INTF_TYPE_3 || \
-				     skyhawk_chip(adapter)) && \
-				     (adapter->function_mode & RDMA_ENABLED))
+#define be_roce_supported(adapter)	(skyhawk_chip(adapter) && \
+					(adapter->function_mode & RDMA_ENABLED))
 
 extern const struct ethtool_ops be_ethtool_ops;
 
@@ -650,12 +648,6 @@ static inline bool be_is_wol_excluded(struct be_adapter *adapter)
 	}
 }
 
-static inline bool be_type_2_3(struct be_adapter *adapter)
-{
-	return (adapter->if_type == SLI_INTF_TYPE_2 ||
-		adapter->if_type == SLI_INTF_TYPE_3) ? true : false;
-}
-
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, u8 link_status);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5c475cc..b2c72b8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3621,8 +3621,6 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
 	if (adapter->db)
 		pci_iounmap(adapter->pdev, adapter->db);
-	if (adapter->roce_db.base)
-		pci_iounmap(adapter->pdev, adapter->roce_db.base);
 }
 
 static int db_bar(struct be_adapter *adapter)
@@ -3635,19 +3633,7 @@ static int db_bar(struct be_adapter *adapter)
 
 static int be_roce_map_pci_bars(struct be_adapter *adapter)
 {
-	struct pci_dev *pdev = adapter->pdev;
-	u8 __iomem *addr;
-
-	if (lancer_chip(adapter) && adapter->if_type == SLI_INTF_TYPE_3) {
-		addr = pci_iomap(pdev, 2, 0);
-		if (addr == NULL)
-			return -ENOMEM;
-
-		adapter->roce_db.base = addr;
-		adapter->roce_db.io_addr = pci_resource_start(pdev, 2);
-		adapter->roce_db.size = 8192;
-		adapter->roce_db.total_size = pci_resource_len(pdev, 2);
-	} else if (skyhawk_chip(adapter)) {
+	if (skyhawk_chip(adapter)) {
 		adapter->roce_db.size = 4096;
 		adapter->roce_db.io_addr = pci_resource_start(adapter->pdev,
 							      db_bar(adapter));
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c b/drivers/net/ethernet/emulex/benet/be_roce.c
index 866900e..55d32aa 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.c
+++ b/drivers/net/ethernet/emulex/benet/be_roce.c
@@ -47,10 +47,7 @@ static void _be_roce_dev_add(struct be_adapter *adapter)
 		dev_info.dpp_unmapped_len = 0;
 	}
 	dev_info.pdev = adapter->pdev;
-	if (skyhawk_chip(adapter))
-		dev_info.db = adapter->db;
-	else
-		dev_info.db = adapter->roce_db.base;
+	dev_info.db = adapter->db;
 	dev_info.unmapped_db = adapter->roce_db.io_addr;
 	dev_info.db_page_size = adapter->roce_db.size;
 	dev_info.db_total_size = adapter->roce_db.total_size;
-- 
1.7.1
