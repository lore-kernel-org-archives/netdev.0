From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 21/26] et131x: clean up MMC_SRAM_
Date: Tue, 25 Aug 2009 16:00:53 +0100
Message-ID: <20090825150047.16176.42488.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47823 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755401AbZHYPGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:06:15 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_address_map.h |   34 ++++++---------------------
 drivers/staging/et131x/et131x_debug.c       |   12 ++++------
 2 files changed, 13 insertions(+), 33 deletions(-)


diff --git a/drivers/staging/et131x/et1310_address_map.h b/drivers/staging/et131x/et1310_address_map.h
index d2ac26c..01c990c 100644
--- a/drivers/staging/et131x/et1310_address_map.h
+++ b/drivers/staging/et131x/et1310_address_map.h
@@ -2264,7 +2264,7 @@ typedef struct _MAC_STAT_t {		/* Location: */
 /* START OF MMC REGISTER ADDRESS MAP */
 
 /*
- * structure for Main Memory Controller Control reg in mmc address map.
+ * Main Memory Controller Control reg in mmc address map.
  * located at address 0x7000
  */
  
@@ -2277,31 +2277,13 @@ typedef struct _MAC_STAT_t {		/* Location: */
 #define ET_MMC_FORCE_CE		64
 
 /*
- * structure for Main Memory Controller Host Memory Access Address reg in mmc
- * address map.  Located at address 0x7004
+ * Main Memory Controller Host Memory Access Address reg in mmc
+ * address map.  Located at address 0x7004. Top 16 bits hold the address bits
  */
-typedef union _MMC_SRAM_ACCESS_t {
-	u32 value;
-	struct {
-#ifdef _BIT_FIELDS_HTOL
-		u32 byte_enable:16;	/* bits 16-31 */
-		u32 reserved2:2;		/* bits 14-15 */
-		u32 req_addr:10;		/* bits 4-13 */
-		u32 reserved1:1;		/* bit 3 */
-		u32 is_ctrl_word:1;	/* bit 2 */
-		u32 wr_access:1;		/* bit 1 */
-		u32 req_access:1;		/* bit 0 */
-#else
-		u32 req_access:1;		/* bit 0 */
-		u32 wr_access:1;		/* bit 1 */
-		u32 is_ctrl_word:1;	/* bit 2 */
-		u32 reserved1:1;		/* bit 3 */
-		u32 req_addr:10;		/* bits 4-13 */
-		u32 reserved2:2;		/* bits 14-15 */
-		u32 byte_enable:16;	/* bits 16-31 */
-#endif
-	} bits;
-} MMC_SRAM_ACCESS_t, *PMMC_SRAM_ACCESS_t;
+
+#define ET_SRAM_REQ_ACCESS	1
+#define ET_SRAM_WR_ACCESS	2
+#define ET_SRAM_IS_CTRL		4
 
 /*
  * structure for Main Memory Controller Host Memory Access Data reg in mmc
@@ -2314,7 +2296,7 @@ typedef union _MMC_SRAM_ACCESS_t {
  */
 typedef struct _MMC_t {			/* Location: */
 	u32 mmc_ctrl;		/*  0x7000 */
-	MMC_SRAM_ACCESS_t sram_access;	/*  0x7004 */
+	u32 sram_access;	/*  0x7004 */
 	u32 sram_word1;		/*  0x7008 */
 	u32 sram_word2;		/*  0x700C */
 	u32 sram_word3;		/*  0x7010 */
diff --git a/drivers/staging/et131x/et131x_debug.c b/drivers/staging/et131x/et131x_debug.c
index 4346c82..61203c1 100644
--- a/drivers/staging/et131x/et131x_debug.c
+++ b/drivers/staging/et131x/et131x_debug.c
@@ -115,18 +115,16 @@ void DumpTxQueueContents(int dbgLvl, struct et131x_adapter *etdev)
 
 	if (DBG_FLAGS(et131x_dbginfo) & dbgLvl) {
 		for (TxQueueAddr = 0x200; TxQueueAddr < 0x3ff; TxQueueAddr++) {
-			MMC_SRAM_ACCESS_t sram_access;
-
-			sram_access.value = readl(&mmc->sram_access.value);
-			sram_access.bits.req_addr = TxQueueAddr;
-			sram_access.bits.req_access = 1;
-			writel(sram_access.value, &mmc->sram_access.value);
+			u32 sram_access = readl(&mmc->sram_access);
+			sram_access &= 0xFFFF;
+			sram_access |= (TxQueueAddr << 16) | ET_SRAM_REQ_ACCESS;
+			writel(sram_access, &mmc->sram_access);
 
 			DBG_PRINT("Addr 0x%x, Access 0x%08x\t"
 				  "Value 1 0x%08x, Value 2 0x%08x, "
 				  "Value 3 0x%08x, Value 4 0x%08x, \n",
 				  TxQueueAddr,
-				  readl(&mmc->sram_access.value),
+				  readl(&mmc->sram_access),
 				  readl(&mmc->sram_word1),
 				  readl(&mmc->sram_word2),
 				  readl(&mmc->sram_word3),

