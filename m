From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 22/26] et131x: quick tidy of the debug code
Date: Tue, 25 Aug 2009 16:01:01 +0100
Message-ID: <20090825150058.16176.87981.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47828 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755398AbZHYPGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:06:23 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et131x_debug.c |   85 +++++++++++++++------------------
 1 files changed, 38 insertions(+), 47 deletions(-)


diff --git a/drivers/staging/et131x/et131x_debug.c b/drivers/staging/et131x/et131x_debug.c
index 61203c1..779130b 100644
--- a/drivers/staging/et131x/et131x_debug.c
+++ b/drivers/staging/et131x/et131x_debug.c
@@ -1,4 +1,3 @@
-/*
  * Agere Systems Inc.
  * 10/100/1000 Base-T Ethernet Driver for the ET1301 and ET131x series MACs
  *
@@ -108,22 +107,22 @@ extern dbg_info_t *et131x_dbginfo;
  * DumpTxQueueContents - Dump out the tx queue and the shadow pointers
  * @etdev: pointer to our adapter structure
  */
-void DumpTxQueueContents(int dbgLvl, struct et131x_adapter *etdev)
+void DumpTxQueueContents(int debug, struct et131x_adapter *etdev)
 {
 	MMC_t __iomem *mmc = &etdev->regs->mmc;
-	uint32_t TxQueueAddr;
+	u32 txq_addr;
 
-	if (DBG_FLAGS(et131x_dbginfo) & dbgLvl) {
-		for (TxQueueAddr = 0x200; TxQueueAddr < 0x3ff; TxQueueAddr++) {
+	if (DBG_FLAGS(et131x_dbginfo) & debug) {
+		for (txq_addr = 0x200; txq_addr < 0x3ff; txq_addr++) {
 			u32 sram_access = readl(&mmc->sram_access);
 			sram_access &= 0xFFFF;
-			sram_access |= (TxQueueAddr << 16) | ET_SRAM_REQ_ACCESS;
+			sram_access |= (txq_addr << 16) | ET_SRAM_REQ_ACCESS;
 			writel(sram_access, &mmc->sram_access);
 
 			DBG_PRINT("Addr 0x%x, Access 0x%08x\t"
 				  "Value 1 0x%08x, Value 2 0x%08x, "
 				  "Value 3 0x%08x, Value 4 0x%08x, \n",
-				  TxQueueAddr,
+				  txq_addr,
 				  readl(&mmc->sram_access),
 				  readl(&mmc->sram_word1),
 				  readl(&mmc->sram_word2),
@@ -136,6 +135,12 @@ void DumpTxQueueContents(int dbgLvl, struct et131x_adapter *etdev)
 	}
 }
 
+static const char *BlockNames[NUM_BLOCKS] = {
+	"Global", "Tx DMA", "Rx DMA", "Tx MAC",
+	"Rx MAC", "MAC", "MAC Stat", "MMC"
+};
+
+
 /**
  * DumpDeviceBlock
  * @etdev: pointer to our adapter
@@ -144,30 +149,23 @@ void DumpTxQueueContents(int dbgLvl, struct et131x_adapter *etdev)
  * mapped to a new page, each page is 4096 bytes).
  */
 #define NUM_BLOCKS 8
-void DumpDeviceBlock(int dbgLvl, struct et131x_adapter *etdev,
-		     uint32_t Block)
+void DumpDeviceBlock(int debug, struct et131x_adapter *etdev,
+		     u32 block)
 {
-	uint32_t Address1, Address2;
-	uint32_t __iomem *BigDevicePointer =
-		(uint32_t __iomem *) etdev->regs;
-	const char *BlockNames[NUM_BLOCKS] = {
-		"Global", "Tx DMA", "Rx DMA", "Tx MAC",
-		"Rx MAC", "MAC", "MAC Stat", "MMC"
-	};
+	u32 addr1, addr2;
+	u32 __iomem *regs = (u32 __iomem *) etdev->regs;
 
 	/* Output the debug counters to the debug terminal */
-	if (DBG_FLAGS(et131x_dbginfo) & dbgLvl) {
-		DBG_PRINT("%s block\n", BlockNames[Block]);
-		BigDevicePointer += Block * 1024;
-		for (Address1 = 0; Address1 < 8; Address1++) {
-			for (Address2 = 0; Address2 < 8; Address2++) {
-				if (Block == 0 &&
-				    (Address1 * 8 + Address2) == 6) {
+	if (DBG_FLAGS(et131x_dbginfo) & debug) {
+		DBG_PRINT("%s block\n", BlockNames[block]);
+		regs += block * 1024;
+		for (addr1 = 0; addr1 < 8; addr1++) {
+			for (addr2 = 0; addr2 < 8; addr2++) {
+				if (block == 0 &&
+				    (addr1 * 8 + addr2) == 6)
 					DBG_PRINT("  ISR    , ");
-				} else {
-					DBG_PRINT("0x%08x, ",
-						  readl(BigDevicePointer++));
-				}
+				else
+					DBG_PRINT("0x%08x, ", readl(regs++));
 			}
 			DBG_PRINT("\n");
 		}
@@ -182,29 +180,22 @@ void DumpDeviceBlock(int dbgLvl, struct et131x_adapter *etdev,
  * Dumps the first 64 regs of each block of the et-1310 (each block is
  * mapped to a new page, each page is 4096 bytes).
  */
-void DumpDeviceReg(int dbgLvl, struct et131x_adapter *etdev)
+void DumpDeviceReg(int debug, struct et131x_adapter *etdev)
 {
-	uint32_t Address1, Address2;
-	uint32_t Block;
-	uint32_t __iomem *BigDevicePointer =
-		(uint32_t __iomem *) etdev->regs;
-	uint32_t __iomem *Pointer;
-	const char *BlockNames[NUM_BLOCKS] = {
-		"Global", "Tx DMA", "Rx DMA", "Tx MAC",
-		"Rx MAC", "MAC", "MAC Stat", "MMC"
-	};
+	u32 addr1, addr2;
+	u32 block;
+	u32 __iomem *regs = (u32 __iomem *)etdev->regs;
+	u32 __iomem *p;
 
 	/* Output the debug counters to the debug terminal */
-	if (DBG_FLAGS(et131x_dbginfo) & dbgLvl) {
-		for (Block = 0; Block < NUM_BLOCKS; Block++) {
-			DBG_PRINT("%s block\n", BlockNames[Block]);
-			Pointer = BigDevicePointer + (Block * 1024);
-
-			for (Address1 = 0; Address1 < 8; Address1++) {
-				for (Address2 = 0; Address2 < 8; Address2++) {
-					DBG_PRINT("0x%08x, ",
-						  readl(Pointer++));
-				}
+	if (DBG_FLAGS(et131x_dbginfo) & debug) {
+		for (block = 0; block < NUM_BLOCKS; block++) {
+			DBG_PRINT("%s block\n", BlockNames[block]);
+			p = regs + block * 1024;
+
+			for (addr1 = 0; addr1 < 8; addr1++) {
+				for (addr2 = 0; addr2 < 8; addr2++)
+					DBG_PRINT("0x%08x, ", readl(p++));
 				DBG_PRINT("\n");
 			}
 			DBG_PRINT("\n");

