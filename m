From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/5] be2net: get rid of memory mapped pci-cfg space address
Date: Mon, 22 Aug 2011 16:43:30 +0530
Message-ID: <1314011613-4519-3-git-send-email-sathya.perla@emulex.com>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:12581 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756833Ab1HVLOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:14:19 -0400
In-Reply-To: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of adapter->pcicfg and its use. Use pci_config_read/write_dword()
instead.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 -
 drivers/net/ethernet/emulex/benet/be_main.c |   27 ++++++++-------------------
 2 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 12b5b51..868d7f4 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -298,7 +298,6 @@ struct be_adapter {
 
 	u8 __iomem *csr;
 	u8 __iomem *db;		/* Door Bell */
-	u8 __iomem *pcicfg;	/* PCI config space */
 
 	struct mutex mbox_lock; /* For serializing mbox cmds to BE card */
 	struct be_dma_mem mbox_mem;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 09eb699..2375c0c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -141,13 +141,15 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 
 static void be_intr_set(struct be_adapter *adapter, bool enable)
 {
-	u8 __iomem *addr = adapter->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET;
-	u32 reg = ioread32(addr);
-	u32 enabled = reg & MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
+	u32 reg, enabled;
 
 	if (adapter->eeh_err)
 		return;
 
+	pci_read_config_dword(adapter->pdev, PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET,
+				&reg);
+	enabled = reg & MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
+
 	if (!enabled && enable)
 		reg |= MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
 	else if (enabled && !enable)
@@ -155,7 +157,8 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 	else
 		return;
 
-	iowrite32(reg, addr);
+	pci_write_config_dword(adapter->pdev,
+			PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET, reg);
 }
 
 static void be_rxq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
@@ -2951,14 +2954,12 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
 		iounmap(adapter->csr);
 	if (adapter->db)
 		iounmap(adapter->db);
-	if (adapter->pcicfg && be_physfn(adapter))
-		iounmap(adapter->pcicfg);
 }
 
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
-	int pcicfg_reg, db_reg;
+	int db_reg;
 
 	if (lancer_chip(adapter)) {
 		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 0),
@@ -2978,10 +2979,8 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	}
 
 	if (adapter->generation == BE_GEN2) {
-		pcicfg_reg = 1;
 		db_reg = 4;
 	} else {
-		pcicfg_reg = 0;
 		if (be_physfn(adapter))
 			db_reg = 4;
 		else
@@ -2993,16 +2992,6 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 		goto pci_map_err;
 	adapter->db = addr;
 
-	if (be_physfn(adapter)) {
-		addr = ioremap_nocache(
-				pci_resource_start(adapter->pdev, pcicfg_reg),
-				pci_resource_len(adapter->pdev, pcicfg_reg));
-		if (addr == NULL)
-			goto pci_map_err;
-		adapter->pcicfg = addr;
-	} else
-		adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
-
 	return 0;
 pci_map_err:
 	be_unmap_pci_bars(adapter);
-- 
1.7.4

