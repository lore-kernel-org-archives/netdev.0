From: "Michael Chan" <mchan@broadcom.com>
Subject: [1/4][BNX2]: Support NVRAM on 5709.
Date: Mon, 16 Jul 2007 13:07:04 -0700
Message-ID: <1184616424.17688.18.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1261 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbXGPTO1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 15:14:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Support NVRAM on 5709.

The NVRAM interface is slightly modified on the 5709.  To properly
support it, we need to change the buffered flag in the flash data
structure into multiple flags to indicate buffered operation, address
translation, and the use of write enable (WREN).  The 5709 flash
only requires the buffered operation bit to be set.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d23861c..311c859 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -126,91 +126,102 @@ static struct pci_device_id bnx2_pci_tbl[] = {
 
 static struct flash_spec flash_table[] =
 {
+#define BUFFERED_FLAGS		(BNX2_NV_BUFFERED | BNX2_NV_TRANSLATE)
+#define NONBUFFERED_FLAGS	(BNX2_NV_WREN)
 	/* Slow EEPROM */
 	{0x00000000, 0x40830380, 0x009f0081, 0xa184a053, 0xaf000400,
-	 1, SEEPROM_PAGE_BITS, SEEPROM_PAGE_SIZE,
+	 BUFFERED_FLAGS, SEEPROM_PAGE_BITS, SEEPROM_PAGE_SIZE,
 	 SEEPROM_BYTE_ADDR_MASK, SEEPROM_TOTAL_SIZE,
 	 "EEPROM - slow"},
 	/* Expansion entry 0001 */
 	{0x08000002, 0x4b808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 0001"},
 	/* Saifun SA25F010 (non-buffered flash) */
 	/* strap, cfg1, & write1 need updates */
 	{0x04000001, 0x47808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, SAIFUN_FLASH_BASE_TOTAL_SIZE*2,
 	 "Non-buffered flash (128kB)"},
 	/* Saifun SA25F020 (non-buffered flash) */
 	/* strap, cfg1, & write1 need updates */
 	{0x0c000003, 0x4f808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, SAIFUN_FLASH_BASE_TOTAL_SIZE*4,
 	 "Non-buffered flash (256kB)"},
 	/* Expansion entry 0100 */
 	{0x11000000, 0x53808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 0100"},
 	/* Entry 0101: ST M45PE10 (non-buffered flash, TetonII B0) */
 	{0x19000002, 0x5b808201, 0x000500db, 0x03840253, 0xaf020406,
-	 0, ST_MICRO_FLASH_PAGE_BITS, ST_MICRO_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, ST_MICRO_FLASH_PAGE_BITS, ST_MICRO_FLASH_PAGE_SIZE,
 	 ST_MICRO_FLASH_BYTE_ADDR_MASK, ST_MICRO_FLASH_BASE_TOTAL_SIZE*2,
 	 "Entry 0101: ST M45PE10 (128kB non-bufferred)"},
 	/* Entry 0110: ST M45PE20 (non-buffered flash)*/
 	{0x15000001, 0x57808201, 0x000500db, 0x03840253, 0xaf020406,
-	 0, ST_MICRO_FLASH_PAGE_BITS, ST_MICRO_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, ST_MICRO_FLASH_PAGE_BITS, ST_MICRO_FLASH_PAGE_SIZE,
 	 ST_MICRO_FLASH_BYTE_ADDR_MASK, ST_MICRO_FLASH_BASE_TOTAL_SIZE*4,
 	 "Entry 0110: ST M45PE20 (256kB non-bufferred)"},
 	/* Saifun SA25F005 (non-buffered flash) */
 	/* strap, cfg1, & write1 need updates */
 	{0x1d000003, 0x5f808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, SAIFUN_FLASH_BASE_TOTAL_SIZE,
 	 "Non-buffered flash (64kB)"},
 	/* Fast EEPROM */
 	{0x22000000, 0x62808380, 0x009f0081, 0xa184a053, 0xaf000400,
-	 1, SEEPROM_PAGE_BITS, SEEPROM_PAGE_SIZE,
+	 BUFFERED_FLAGS, SEEPROM_PAGE_BITS, SEEPROM_PAGE_SIZE,
 	 SEEPROM_BYTE_ADDR_MASK, SEEPROM_TOTAL_SIZE,
 	 "EEPROM - fast"},
 	/* Expansion entry 1001 */
 	{0x2a000002, 0x6b808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 1001"},
 	/* Expansion entry 1010 */
 	{0x26000001, 0x67808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 1010"},
 	/* ATMEL AT45DB011B (buffered flash) */
 	{0x2e000003, 0x6e808273, 0x00570081, 0x68848353, 0xaf000400,
-	 1, BUFFERED_FLASH_PAGE_BITS, BUFFERED_FLASH_PAGE_SIZE,
+	 BUFFERED_FLAGS, BUFFERED_FLASH_PAGE_BITS, BUFFERED_FLASH_PAGE_SIZE,
 	 BUFFERED_FLASH_BYTE_ADDR_MASK, BUFFERED_FLASH_TOTAL_SIZE,
 	 "Buffered flash (128kB)"},
 	/* Expansion entry 1100 */
 	{0x33000000, 0x73808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 1100"},
 	/* Expansion entry 1101 */
 	{0x3b000002, 0x7b808201, 0x00050081, 0x03840253, 0xaf020406,
-	 0, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
+	 NONBUFFERED_FLAGS, SAIFUN_FLASH_PAGE_BITS, SAIFUN_FLASH_PAGE_SIZE,
 	 SAIFUN_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 1101"},
 	/* Ateml Expansion entry 1110 */
 	{0x37000001, 0x76808273, 0x00570081, 0x68848353, 0xaf000400,
-	 1, BUFFERED_FLASH_PAGE_BITS, BUFFERED_FLASH_PAGE_SIZE,
+	 BUFFERED_FLAGS, BUFFERED_FLASH_PAGE_BITS, BUFFERED_FLASH_PAGE_SIZE,
 	 BUFFERED_FLASH_BYTE_ADDR_MASK, 0,
 	 "Entry 1110 (Atmel)"},
 	/* ATMEL AT45DB021B (buffered flash) */
 	{0x3f000003, 0x7e808273, 0x00570081, 0x68848353, 0xaf000400,
-	 1, BUFFERED_FLASH_PAGE_BITS, BUFFERED_FLASH_PAGE_SIZE,
+	 BUFFERED_FLAGS, BUFFERED_FLASH_PAGE_BITS, BUFFERED_FLASH_PAGE_SIZE,
 	 BUFFERED_FLASH_BYTE_ADDR_MASK, BUFFERED_FLASH_TOTAL_SIZE*2,
 	 "Buffered flash (256kB)"},
 };
 
+static struct flash_spec flash_5709 = {
+	.flags		= BNX2_NV_BUFFERED,
+	.page_bits	= BCM5709_FLASH_PAGE_BITS,
+	.page_size	= BCM5709_FLASH_PAGE_SIZE,
+	.addr_mask	= BCM5709_FLASH_BYTE_ADDR_MASK,
+	.total_size	= BUFFERED_FLASH_TOTAL_SIZE*2,
+	.name		= "5709 Buffered flash (256kB)",
+};
+
 MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
 static inline u32 bnx2_tx_avail(struct bnx2 *bp)
@@ -3289,7 +3300,7 @@ bnx2_enable_nvram_write(struct bnx2 *bp)
 	val = REG_RD(bp, BNX2_MISC_CFG);
 	REG_WR(bp, BNX2_MISC_CFG, val | BNX2_MISC_CFG_NVM_WR_EN_PCI);
 
-	if (!bp->flash_info->buffered) {
+	if (bp->flash_info->flags & BNX2_NV_WREN) {
 		int j;
 
 		REG_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
@@ -3349,7 +3360,7 @@ bnx2_nvram_erase_page(struct bnx2 *bp, u32 offset)
 	u32 cmd;
 	int j;
 
-	if (bp->flash_info->buffered)
+	if (bp->flash_info->flags & BNX2_NV_BUFFERED)
 		/* Buffered flash, no erase needed */
 		return 0;
 
@@ -3392,8 +3403,8 @@ bnx2_nvram_read_dword(struct bnx2 *bp, u32 offset, u8 *ret_val, u32 cmd_flags)
 	/* Build the command word. */
 	cmd = BNX2_NVM_COMMAND_DOIT | cmd_flags;
 
-	/* Calculate an offset of a buffered flash. */
-	if (bp->flash_info->buffered) {
+	/* Calculate an offset of a buffered flash, not needed for 5709. */
+	if (bp->flash_info->flags & BNX2_NV_TRANSLATE) {
 		offset = ((offset / bp->flash_info->page_size) <<
 			   bp->flash_info->page_bits) +
 			  (offset % bp->flash_info->page_size);
@@ -3439,8 +3450,8 @@ bnx2_nvram_write_dword(struct bnx2 *bp, u32 offset, u8 *val, u32 cmd_flags)
 	/* Build the command word. */
 	cmd = BNX2_NVM_COMMAND_DOIT | BNX2_NVM_COMMAND_WR | cmd_flags;
 
-	/* Calculate an offset of a buffered flash. */
-	if (bp->flash_info->buffered) {
+	/* Calculate an offset of a buffered flash, not needed for 5709. */
+	if (bp->flash_info->flags & BNX2_NV_TRANSLATE) {
 		offset = ((offset / bp->flash_info->page_size) <<
 			  bp->flash_info->page_bits) +
 			 (offset % bp->flash_info->page_size);
@@ -3478,15 +3489,19 @@ static int
 bnx2_init_nvram(struct bnx2 *bp)
 {
 	u32 val;
-	int j, entry_count, rc;
+	int j, entry_count, rc = 0;
 	struct flash_spec *flash;
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		bp->flash_info = &flash_5709;
+		goto get_flash_size;
+	}
+
 	/* Determine the selected interface. */
 	val = REG_RD(bp, BNX2_NVM_CFG1);
 
 	entry_count = sizeof(flash_table) / sizeof(struct flash_spec);
 
-	rc = 0;
 	if (val & 0x40000000) {
 
 		/* Flash interface has been reconfigured */
@@ -3542,6 +3557,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 		return -ENODEV;
 	}
 
+get_flash_size:
 	val = REG_RD_IND(bp, bp->shmem_base + BNX2_SHARED_HW_CFG_CONFIG2);
 	val &= BNX2_SHARED_HW_CFG2_NVM_SIZE_MASK;
 	if (val)
@@ -3706,7 +3722,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 		buf = align_buf;
 	}
 
-	if (bp->flash_info->buffered == 0) {
+	if (!(bp->flash_info->flags & BNX2_NV_BUFFERED)) {
 		flash_buffer = kmalloc(264, GFP_KERNEL);
 		if (flash_buffer == NULL) {
 			rc = -ENOMEM;
@@ -3739,7 +3755,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 		bnx2_enable_nvram_access(bp);
 
 		cmd_flags = BNX2_NVM_COMMAND_FIRST;
-		if (bp->flash_info->buffered == 0) {
+		if (!(bp->flash_info->flags & BNX2_NV_BUFFERED)) {
 			int j;
 
 			/* Read the whole page into the buffer
@@ -3767,7 +3783,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 		/* Loop to write back the buffer data from page_start to
 		 * data_start */
 		i = 0;
-		if (bp->flash_info->buffered == 0) {
+		if (!(bp->flash_info->flags & BNX2_NV_BUFFERED)) {
 			/* Erase the page */
 			if ((rc = bnx2_nvram_erase_page(bp, page_start)) != 0)
 				goto nvram_write_end;
@@ -3791,7 +3807,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 		/* Loop to write the new data from data_start to data_end */
 		for (addr = data_start; addr < data_end; addr += 4, i += 4) {
 			if ((addr == page_end - 4) ||
-				((bp->flash_info->buffered) &&
+				((bp->flash_info->flags & BNX2_NV_BUFFERED) &&
 				 (addr == data_end - 4))) {
 
 				cmd_flags |= BNX2_NVM_COMMAND_LAST;
@@ -3808,7 +3824,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 offset, u8 *data_buf,
 
 		/* Loop to write back the buffer data from data_end
 		 * to page_end */
-		if (bp->flash_info->buffered == 0) {
+		if (!(bp->flash_info->flags & BNX2_NV_BUFFERED)) {
 			for (addr = data_end; addr < page_end;
 				addr += 4, i += 4) {
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index d8cd1af..102adfe 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6433,6 +6433,11 @@ struct sw_bd {
 #define ST_MICRO_FLASH_PAGE_SIZE		256
 #define ST_MICRO_FLASH_BASE_TOTAL_SIZE		65536
 
+#define BCM5709_FLASH_PAGE_BITS			8
+#define BCM5709_FLASH_PHY_PAGE_SIZE		(1 << BCM5709_FLASH_PAGE_BITS)
+#define BCM5709_FLASH_BYTE_ADDR_MASK		(BCM5709_FLASH_PHY_PAGE_SIZE-1)
+#define BCM5709_FLASH_PAGE_SIZE			256
+
 #define NVRAM_TIMEOUT_COUNT			30000
 
 
@@ -6449,7 +6454,10 @@ struct flash_spec {
 	u32 config2;
 	u32 config3;
 	u32 write1;
-	u32 buffered;
+	u32 flags;
+#define BNX2_NV_BUFFERED	0x00000001
+#define BNX2_NV_TRANSLATE	0x00000002
+#define BNX2_NV_WREN		0x00000004
 	u32 page_bits;
 	u32 page_size;
 	u32 addr_mask;


