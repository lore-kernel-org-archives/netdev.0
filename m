From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 22/22] csiostor: Cleanup chip specific operations.
Date: Tue, 12 Mar 2013 17:16:34 +0530
Message-ID: <1363088794-31453-23-git-send-email-vipul@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12757 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932833Ab3CLLyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 07:54:09 -0400
In-Reply-To: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Bhushan <arvindb@chelsio.com>

This patch removes chip specific operations from the common hardware
paths, as well as the Makefile change to accomodate the new files.

Signed-off-by: Arvind Bhushan <arvindb@chelsio.com>
Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
 drivers/scsi/csiostor/Makefile    |    3 +-
 drivers/scsi/csiostor/csio_hw.c   |  559 ++++++++-----------------------------
 drivers/scsi/csiostor/csio_hw.h   |   47 ++--
 drivers/scsi/csiostor/csio_init.c |   48 +++-
 drivers/scsi/csiostor/csio_init.h |   29 +--
 drivers/scsi/csiostor/csio_wr.c   |   19 +-
 6 files changed, 193 insertions(+), 512 deletions(-)

diff --git a/drivers/scsi/csiostor/Makefile b/drivers/scsi/csiostor/Makefile
index b581966..913b9a9 100644
--- a/drivers/scsi/csiostor/Makefile
+++ b/drivers/scsi/csiostor/Makefile
@@ -8,4 +8,5 @@ ccflags-y += -I$(srctree)/drivers/net/ethernet/chelsio/cxgb4
 obj-$(CONFIG_SCSI_CHELSIO_FCOE) += csiostor.o
 
 csiostor-objs := csio_attr.o csio_init.o csio_lnode.o csio_scsi.o \
-		csio_hw.o csio_isr.o csio_mb.o csio_rnode.o csio_wr.o
+		csio_hw.o csio_hw_t4.o csio_hw_t5.o csio_isr.o \
+		csio_mb.o csio_rnode.o csio_wr.o
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index bdd78fb..a0b4c89 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -61,7 +61,7 @@ int csio_msi = 2;
 static int dev_num;
 
 /* FCoE Adapter types & its description */
-static const struct csio_adap_desc csio_fcoe_adapters[] = {
+static const struct csio_adap_desc csio_t4_fcoe_adapters[] = {
 	{"T440-Dbg 10G", "Chelsio T440-Dbg 10G [FCoE]"},
 	{"T420-CR 10G", "Chelsio T420-CR 10G [FCoE]"},
 	{"T422-CR 10G/1G", "Chelsio T422-CR 10G/1G [FCoE]"},
@@ -77,7 +77,38 @@ static const struct csio_adap_desc csio_fcoe_adapters[] = {
 	{"B404-BT 1G", "Chelsio B404-BT 1G [FCoE]"},
 	{"T480-CR 10G", "Chelsio T480-CR 10G [FCoE]"},
 	{"T440-LP-CR 10G", "Chelsio T440-LP-CR 10G [FCoE]"},
-	{"T4 FPGA", "Chelsio T4 FPGA [FCoE]"}
+	{"AMSTERDAM 10G", "Chelsio AMSTERDAM 10G [FCoE]"},
+	{"HUAWEI T480 10G", "Chelsio HUAWEI T480 10G [FCoE]"},
+	{"HUAWEI T440 10G", "Chelsio HUAWEI T440 10G [FCoE]"},
+	{"HUAWEI STG 10G", "Chelsio HUAWEI STG 10G [FCoE]"},
+	{"ACROMAG XAUI 10G", "Chelsio ACROMAG XAUI 10G [FCoE]"},
+	{"ACROMAG SFP+ 10G", "Chelsio ACROMAG SFP+ 10G [FCoE]"},
+	{"QUANTA SFP+ 10G", "Chelsio QUANTA SFP+ 10G [FCoE]"},
+	{"HUAWEI 10Gbase-T", "Chelsio HUAWEI 10Gbase-T [FCoE]"},
+	{"HUAWEI T4TOE 10G", "Chelsio HUAWEI T4TOE 10G [FCoE]"}
+};
+
+static const struct csio_adap_desc csio_t5_fcoe_adapters[] = {
+	{"T580-Dbg 10G", "Chelsio T580-Dbg 10G [FCoE]"},
+	{"T520-CR 10G", "Chelsio T520-CR 10G [FCoE]"},
+	{"T522-CR 10G/1G", "Chelsio T452-CR 10G/1G [FCoE]"},
+	{"T540-CR 10G", "Chelsio T540-CR 10G [FCoE]"},
+	{"T520-BCH 10G", "Chelsio T520-BCH 10G [FCoE]"},
+	{"T540-BCH 10G", "Chelsio T540-BCH 10G [FCoE]"},
+	{"T540-CH 10G", "Chelsio T540-CH 10G [FCoE]"},
+	{"T520-SO 10G", "Chelsio T520-SO 10G [FCoE]"},
+	{"T520-CX4 10G", "Chelsio T520-CX4 10G [FCoE]"},
+	{"T520-BT 10G", "Chelsio T520-BT 10G [FCoE]"},
+	{"T504-BT 1G", "Chelsio T504-BT 1G [FCoE]"},
+	{"B520-SR 10G", "Chelsio B520-SR 10G [FCoE]"},
+	{"B504-BT 1G", "Chelsio B504-BT 1G [FCoE]"},
+	{"T580-CR 10G", "Chelsio T580-CR 10G [FCoE]"},
+	{"T540-LP-CR 10G", "Chelsio T540-LP-CR 10G [FCoE]"},
+	{"AMSTERDAM 10G", "Chelsio AMSTERDAM 10G [FCoE]"},
+	{"T580-LP-CR 40G", "Chelsio T580-LP-CR 40G [FCoE]"},
+	{"T520-LL-CR 10G", "Chelsio T520-LL-CR 10G [FCoE]"},
+	{"T560-CR 40G", "Chelsio T560-CR 40G [FCoE]"},
+	{"T580-CR 40G", "Chelsio T580-CR 40G [FCoE]"}
 };
 
 static void csio_mgmtm_cleanup(struct csio_mgmtm *);
@@ -124,7 +155,7 @@ int csio_is_hw_removing(struct csio_hw *hw)
  *	at the time it indicated completion is stored there.  Returns 0 if the
  *	operation completes and	-EAGAIN	otherwise.
  */
-static int
+int
 csio_hw_wait_op_done_val(struct csio_hw *hw, int reg, uint32_t mask,
 			 int polarity, int attempts, int delay, uint32_t *valp)
 {
@@ -145,6 +176,24 @@ csio_hw_wait_op_done_val(struct csio_hw *hw, int reg, uint32_t mask,
 	}
 }
 
+/*
+ *	csio_hw_tp_wr_bits_indirect - set/clear bits in an indirect TP register
+ *	@hw: the adapter
+ *	@addr: the indirect TP register address
+ *	@mask: specifies the field within the register to modify
+ *	@val: new value for the field
+ *
+ *	Sets a field of an indirect TP register to the given value.
+ */
+void
+csio_hw_tp_wr_bits_indirect(struct csio_hw *hw, unsigned int addr,
+			unsigned int mask, unsigned int val)
+{
+	csio_wr_reg32(hw, addr, TP_PIO_ADDR);
+	val |= csio_rd_reg32(hw, TP_PIO_DATA) & ~mask;
+	csio_wr_reg32(hw, val, TP_PIO_DATA);
+}
+
 void
 csio_set_reg_field(struct csio_hw *hw, uint32_t reg, uint32_t mask,
 		   uint32_t value)
@@ -157,242 +206,22 @@ csio_set_reg_field(struct csio_hw *hw, uint32_t reg, uint32_t mask,
 
 }
 
-/*
- *	csio_hw_mc_read - read from MC through backdoor accesses
- *	@hw: the hw module
- *	@addr: address of first byte requested
- *	@data: 64 bytes of data containing the requested address
- *	@ecc: where to store the corresponding 64-bit ECC word
- *
- *	Read 64 bytes of data from MC starting at a 64-byte-aligned address
- *	that covers the requested address @addr.  If @parity is not %NULL it
- *	is assigned the 64-bit ECC word for the read data.
- */
-int
-csio_hw_mc_read(struct csio_hw *hw, uint32_t addr, __be32 *data,
-		uint64_t *ecc)
-{
-	int i;
-
-	if (csio_rd_reg32(hw, MC_BIST_CMD) & START_BIST)
-		return -EBUSY;
-	csio_wr_reg32(hw, addr & ~0x3fU, MC_BIST_CMD_ADDR);
-	csio_wr_reg32(hw, 64, MC_BIST_CMD_LEN);
-	csio_wr_reg32(hw, 0xc, MC_BIST_DATA_PATTERN);
-	csio_wr_reg32(hw, BIST_OPCODE(1) | START_BIST |  BIST_CMD_GAP(1),
-		      MC_BIST_CMD);
-	i = csio_hw_wait_op_done_val(hw, MC_BIST_CMD, START_BIST,
-		 0, 10, 1, NULL);
-	if (i)
-		return i;
-
-#define MC_DATA(i) MC_BIST_STATUS_REG(MC_BIST_STATUS_RDATA, i)
-
-	for (i = 15; i >= 0; i--)
-		*data++ = htonl(csio_rd_reg32(hw, MC_DATA(i)));
-	if (ecc)
-		*ecc = csio_rd_reg64(hw, MC_DATA(16));
-#undef MC_DATA
-	return 0;
-}
-
-/*
- *	csio_hw_edc_read - read from EDC through backdoor accesses
- *	@hw: the hw module
- *	@idx: which EDC to access
- *	@addr: address of first byte requested
- *	@data: 64 bytes of data containing the requested address
- *	@ecc: where to store the corresponding 64-bit ECC word
- *
- *	Read 64 bytes of data from EDC starting at a 64-byte-aligned address
- *	that covers the requested address @addr.  If @parity is not %NULL it
- *	is assigned the 64-bit ECC word for the read data.
- */
-int
-csio_hw_edc_read(struct csio_hw *hw, int idx, uint32_t addr, __be32 *data,
-		uint64_t *ecc)
-{
-	int i;
-
-	idx *= EDC_STRIDE;
-	if (csio_rd_reg32(hw, EDC_BIST_CMD + idx) & START_BIST)
-		return -EBUSY;
-	csio_wr_reg32(hw, addr & ~0x3fU, EDC_BIST_CMD_ADDR + idx);
-	csio_wr_reg32(hw, 64, EDC_BIST_CMD_LEN + idx);
-	csio_wr_reg32(hw, 0xc, EDC_BIST_DATA_PATTERN + idx);
-	csio_wr_reg32(hw, BIST_OPCODE(1) | BIST_CMD_GAP(1) | START_BIST,
-		     EDC_BIST_CMD + idx);
-	i = csio_hw_wait_op_done_val(hw, EDC_BIST_CMD + idx, START_BIST,
-		 0, 10, 1, NULL);
-	if (i)
-		return i;
-
-#define EDC_DATA(i) (EDC_BIST_STATUS_REG(EDC_BIST_STATUS_RDATA, i) + idx)
-
-	for (i = 15; i >= 0; i--)
-		*data++ = htonl(csio_rd_reg32(hw, EDC_DATA(i)));
-	if (ecc)
-		*ecc = csio_rd_reg64(hw, EDC_DATA(16));
-#undef EDC_DATA
-	return 0;
-}
-
-/*
- *      csio_mem_win_rw - read/write memory through PCIE memory window
- *      @hw: the adapter
- *      @addr: address of first byte requested
- *      @data: MEMWIN0_APERTURE bytes of data containing the requested address
- *      @dir: direction of transfer 1 => read, 0 => write
- *
- *      Read/write MEMWIN0_APERTURE bytes of data from MC starting at a
- *      MEMWIN0_APERTURE-byte-aligned address that covers the requested
- *      address @addr.
- */
-static int
-csio_mem_win_rw(struct csio_hw *hw, u32 addr, u32 *data, int dir)
-{
-	int i;
-
-	/*
-	 * Setup offset into PCIE memory window.  Address must be a
-	 * MEMWIN0_APERTURE-byte-aligned address.  (Read back MA register to
-	 * ensure that changes propagate before we attempt to use the new
-	 * values.)
-	 */
-	csio_wr_reg32(hw, addr & ~(MEMWIN0_APERTURE - 1),
-			PCIE_MEM_ACCESS_OFFSET);
-	csio_rd_reg32(hw, PCIE_MEM_ACCESS_OFFSET);
-
-	/* Collecting data 4 bytes at a time upto MEMWIN0_APERTURE */
-	for (i = 0; i < MEMWIN0_APERTURE; i = i + sizeof(__be32)) {
-		if (dir)
-			*data++ = csio_rd_reg32(hw, (MEMWIN0_BASE + i));
-		else
-			csio_wr_reg32(hw, *data++, (MEMWIN0_BASE + i));
-	}
-
-	return 0;
-}
-
-/*
- *      csio_memory_rw - read/write EDC 0, EDC 1 or MC via PCIE memory window
- *      @hw: the csio_hw
- *      @mtype: memory type: MEM_EDC0, MEM_EDC1 or MEM_MC
- *      @addr: address within indicated memory type
- *      @len: amount of memory to transfer
- *      @buf: host memory buffer
- *      @dir: direction of transfer 1 => read, 0 => write
- *
- *      Reads/writes an [almost] arbitrary memory region in the firmware: the
- *      firmware memory address, length and host buffer must be aligned on
- *      32-bit boudaries.  The memory is transferred as a raw byte sequence
- *      from/to the firmware's memory.  If this memory contains data
- *      structures which contain multi-byte integers, it's the callers
- *      responsibility to perform appropriate byte order conversions.
- */
-static int
-csio_memory_rw(struct csio_hw *hw, int mtype, u32 addr, u32 len,
-		uint32_t *buf, int dir)
-{
-	uint32_t pos, start, end, offset, memoffset;
-	int ret;
-	uint32_t *data;
-
-	/*
-	 * Argument sanity checks ...
-	 */
-	if ((addr & 0x3) || (len & 0x3))
-		return -EINVAL;
-
-	data = kzalloc(MEMWIN0_APERTURE, GFP_KERNEL);
-	if (!data)
-		return -ENOMEM;
-
-	/* Offset into the region of memory which is being accessed
-	 * MEM_EDC0 = 0
-	 * MEM_EDC1 = 1
-	 * MEM_MC   = 2
-	 */
-	memoffset = (mtype * (5 * 1024 * 1024));
-
-	/* Determine the PCIE_MEM_ACCESS_OFFSET */
-	addr = addr + memoffset;
-
-	/*
-	 * The underlaying EDC/MC read routines read MEMWIN0_APERTURE bytes
-	 * at a time so we need to round down the start and round up the end.
-	 * We'll start copying out of the first line at (addr - start) a word
-	 * at a time.
-	 */
-	start = addr & ~(MEMWIN0_APERTURE-1);
-	end = (addr + len + MEMWIN0_APERTURE-1) & ~(MEMWIN0_APERTURE-1);
-	offset = (addr - start)/sizeof(__be32);
-
-	for (pos = start; pos < end; pos += MEMWIN0_APERTURE, offset = 0) {
-		/*
-		 * If we're writing, copy the data from the caller's memory
-		 * buffer
-		 */
-		if (!dir) {
-			/*
-			 * If we're doing a partial write, then we need to do
-			 * a read-modify-write ...
-			 */
-			if (offset || len < MEMWIN0_APERTURE) {
-				ret = csio_mem_win_rw(hw, pos, data, 1);
-				if (ret) {
-					kfree(data);
-					return ret;
-				}
-			}
-			while (offset < (MEMWIN0_APERTURE/sizeof(__be32)) &&
-								len > 0) {
-				data[offset++] = *buf++;
-				len -= sizeof(__be32);
-			}
-		}
-
-		/*
-		 * Transfer a block of memory and bail if there's an error.
-		 */
-		ret = csio_mem_win_rw(hw, pos, data, dir);
-		if (ret) {
-			kfree(data);
-			return ret;
-		}
-
-		/*
-		 * If we're reading, copy the data into the caller's memory
-		 * buffer.
-		 */
-		if (dir)
-			while (offset < (MEMWIN0_APERTURE/sizeof(__be32)) &&
-								len > 0) {
-				*buf++ = data[offset++];
-				len -= sizeof(__be32);
-			}
-	}
-
-	kfree(data);
-
-	return 0;
-}
-
 static int
 csio_memory_write(struct csio_hw *hw, int mtype, u32 addr, u32 len, u32 *buf)
 {
-	return csio_memory_rw(hw, mtype, addr, len, buf, 0);
+	return hw->chip_ops->chip_memory_rw(hw, MEMWIN_CSIOSTOR, mtype,
+					    addr, len, buf, 0);
 }
 
 /*
  * EEPROM reads take a few tens of us while writes can take a bit over 5 ms.
  */
-#define EEPROM_MAX_RD_POLL 40
-#define EEPROM_MAX_WR_POLL 6
-#define EEPROM_STAT_ADDR   0x7bfc
-#define VPD_BASE           0x400
-#define VPD_BASE_OLD	   0
-#define VPD_LEN            512
+#define EEPROM_MAX_RD_POLL	40
+#define EEPROM_MAX_WR_POLL	6
+#define EEPROM_STAT_ADDR	0x7bfc
+#define VPD_BASE		0x400
+#define VPD_BASE_OLD		0
+#define VPD_LEN			1024
 #define VPD_INFO_FLD_HDR_SIZE	3
 
 /*
@@ -817,23 +646,6 @@ out:
 	return 0;
 }
 
-/*
- *	csio_hw_flash_cfg_addr - return the address of the flash
- *				configuration file
- *	@hw: the HW module
- *
- *	Return the address within the flash where the Firmware Configuration
- *	File is stored.
- */
-static unsigned int
-csio_hw_flash_cfg_addr(struct csio_hw *hw)
-{
-	if (hw->params.sf_size == 0x100000)
-		return FPGA_FLASH_CFG_OFFSET;
-	else
-		return FLASH_CFG_OFFSET;
-}
-
 static void
 csio_hw_print_fw_version(struct csio_hw *hw, char *str)
 {
@@ -898,13 +710,13 @@ csio_hw_check_fw_version(struct csio_hw *hw)
 	minor = FW_HDR_FW_VER_MINOR_GET(hw->fwrev);
 	micro = FW_HDR_FW_VER_MICRO_GET(hw->fwrev);
 
-	if (major != FW_VERSION_MAJOR) {            /* major mismatch - fail */
+	if (major != FW_VERSION_MAJOR(hw)) {	/* major mismatch - fail */
 		csio_err(hw, "card FW has major version %u, driver wants %u\n",
-			 major, FW_VERSION_MAJOR);
+			 major, FW_VERSION_MAJOR(hw));
 		return -EINVAL;
 	}
 
-	if (minor == FW_VERSION_MINOR && micro == FW_VERSION_MICRO)
+	if (minor == FW_VERSION_MINOR(hw) && micro == FW_VERSION_MICRO(hw))
 		return 0;        /* perfect match */
 
 	/* Minor/micro version mismatch */
@@ -1044,7 +856,7 @@ static void
 csio_set_pcie_completion_timeout(struct csio_hw *hw, u8 range)
 {
 	uint16_t val;
-	uint32_t pcie_cap;
+	int pcie_cap;
 
 	if (!csio_pci_capability(hw->pdev, PCI_CAP_ID_EXP, &pcie_cap)) {
 		pci_read_config_word(hw->pdev,
@@ -1056,84 +868,6 @@ csio_set_pcie_completion_timeout(struct csio_hw *hw, u8 range)
 	}
 }
 
-
-/*
- * Return the specified PCI-E Configuration Space register from our Physical
- * Function.  We try first via a Firmware LDST Command since we prefer to let
- * the firmware own all of these registers, but if that fails we go for it
- * directly ourselves.
- */
-static uint32_t
-csio_read_pcie_cfg4(struct csio_hw *hw, int reg)
-{
-	u32 val = 0;
-	struct csio_mb *mbp;
-	int rv;
-	struct fw_ldst_cmd *ldst_cmd;
-
-	mbp = mempool_alloc(hw->mb_mempool, GFP_ATOMIC);
-	if (!mbp) {
-		CSIO_INC_STATS(hw, n_err_nomem);
-		pci_read_config_dword(hw->pdev, reg, &val);
-		return val;
-	}
-
-	csio_mb_ldst(hw, mbp, CSIO_MB_DEFAULT_TMO, reg);
-
-	rv = csio_mb_issue(hw, mbp);
-
-	/*
-	 * If the LDST Command suucceeded, exctract the returned register
-	 * value.  Otherwise read it directly ourself.
-	 */
-	if (rv == 0) {
-		ldst_cmd = (struct fw_ldst_cmd *)(mbp->mb);
-		val = ntohl(ldst_cmd->u.pcie.data[0]);
-	} else
-		pci_read_config_dword(hw->pdev, reg, &val);
-
-	mempool_free(mbp, hw->mb_mempool);
-
-	return val;
-} /* csio_read_pcie_cfg4 */
-
-static int
-csio_hw_set_mem_win(struct csio_hw *hw)
-{
-	u32 bar0;
-
-	/*
-	 * Truncation intentional: we only read the bottom 32-bits of the
-	 * 64-bit BAR0/BAR1 ...  We use the hardware backdoor mechanism to
-	 * read BAR0 instead of using pci_resource_start() because we could be
-	 * operating from within a Virtual Machine which is trapping our
-	 * accesses to our Configuration Space and we need to set up the PCI-E
-	 * Memory Window decoders with the actual addresses which will be
-	 * coming across the PCI-E link.
-	 */
-	bar0 = csio_read_pcie_cfg4(hw, PCI_BASE_ADDRESS_0);
-	bar0 &= PCI_BASE_ADDRESS_MEM_MASK;
-
-	/*
-	 * Set up memory window for accessing adapter memory ranges.  (Read
-	 * back MA register to ensure that changes propagate before we attempt
-	 * to use the new values.)
-	 */
-	csio_wr_reg32(hw, (bar0 + MEMWIN0_BASE) | BIR(0) |
-		WINDOW(ilog2(MEMWIN0_APERTURE) - 10),
-		PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN, 0));
-	csio_wr_reg32(hw, (bar0 + MEMWIN1_BASE) | BIR(0) |
-		WINDOW(ilog2(MEMWIN1_APERTURE) - 10),
-		PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN, 1));
-	csio_wr_reg32(hw, (bar0 + MEMWIN2_BASE) | BIR(0) |
-		WINDOW(ilog2(MEMWIN2_APERTURE) - 10),
-		PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN, 2));
-	csio_rd_reg32(hw, PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN, 2));
-	return 0;
-} /* csio_hw_set_mem_win */
-
-
-
 /*****************************************************************************/
 /* HW State machine assists                                                  */
 /*****************************************************************************/
@@ -1234,7 +968,9 @@ retry:
 		for (;;) {
 			uint32_t pcie_fw;
 
+			spin_unlock_irq(&hw->lock);
 			msleep(50);
+			spin_lock_irq(&hw->lock);
 			waiting -= 50;
 
 			/*
@@ -2121,9 +1857,9 @@ csio_hw_flash_config(struct csio_hw *hw, u32 *fw_cfg_param, char *path)
 	uint32_t *cfg_data;
 	int value_to_add = 0;
 
-	if (request_firmware(&cf, CSIO_CF_FNAME, dev) < 0) {
-		csio_err(hw, "could not find config file " CSIO_CF_FNAME
-			 ",err: %d\n", ret);
+	if (request_firmware(&cf, CSIO_CF_FNAME(hw), dev) < 0) {
+		csio_err(hw, "could not find config file %s, err: %d\n",
+			 CSIO_CF_FNAME(hw), ret);
 		return -ENOENT;
 	}
 
@@ -2147,9 +1883,24 @@ csio_hw_flash_config(struct csio_hw *hw, u32 *fw_cfg_param, char *path)
 
 	ret = csio_memory_write(hw, mtype, maddr,
 				cf->size + value_to_add, cfg_data);
+
+	if ((ret == 0) && (value_to_add != 0)) {
+		union {
+			u32 word;
+			char buf[4];
+		} last;
+		size_t size = cf->size & ~0x3;
+		int i;
+
+		last.word = cfg_data[size >> 2];
+		for (i = value_to_add; i < 4; i++)
+			last.buf[i] = 0;
+		ret = csio_memory_write(hw, mtype, maddr + size, 4, &last.word);
+	}
 	if (ret == 0) {
-		csio_info(hw, "config file upgraded to " CSIO_CF_FNAME "\n");
-		strncpy(path, "/lib/firmware/" CSIO_CF_FNAME, 64);
+		csio_info(hw, "config file upgraded to %s\n",
+			  CSIO_CF_FNAME(hw));
+		snprintf(path, 64, "%s%s", "/lib/firmware/", CSIO_CF_FNAME(hw));
 	}
 
 leave:
@@ -2179,7 +1930,7 @@ csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 {
 	unsigned int mtype, maddr;
 	int rv;
-	uint32_t finiver, finicsum, cfcsum;
+	uint32_t finiver = 0, finicsum = 0, cfcsum = 0;
 	int using_flash;
 	char path[64];
 
@@ -2207,7 +1958,7 @@ csio_hw_use_fwconfig(struct csio_hw *hw, int reset, u32 *fw_cfg_param)
 			 * config file from flash.
 			 */
 			mtype = FW_MEMTYPE_CF_FLASH;
-			maddr = csio_hw_flash_cfg_addr(hw);
+			maddr = hw->chip_ops->chip_flash_cfg_addr(hw);
 			using_flash = 1;
 		} else {
 			/*
@@ -2346,30 +2097,32 @@ csio_hw_flash_fw(struct csio_hw *hw)
 	struct pci_dev *pci_dev = hw->pdev;
 	struct device *dev = &pci_dev->dev ;
 
-	if (request_firmware(&fw, CSIO_FW_FNAME, dev) < 0) {
-		csio_err(hw, "could not find firmware image " CSIO_FW_FNAME
-		",err: %d\n", ret);
+	if (request_firmware(&fw, CSIO_FW_FNAME(hw), dev) < 0) {
+		csio_err(hw, "could not find firmware image %s, err: %d\n",
+			 CSIO_FW_FNAME(hw), ret);
 		return -EINVAL;
 	}
 
 	hdr = (const struct fw_hdr *)fw->data;
 	fw_ver = ntohl(hdr->fw_ver);
-	if (FW_HDR_FW_VER_MAJOR_GET(fw_ver) != FW_VERSION_MAJOR)
+	if (FW_HDR_FW_VER_MAJOR_GET(fw_ver) != FW_VERSION_MAJOR(hw))
 		return -EINVAL;      /* wrong major version, won't do */
 
 	/*
 	 * If the flash FW is unusable or we found something newer, load it.
 	 */
-	if (FW_HDR_FW_VER_MAJOR_GET(hw->fwrev) != FW_VERSION_MAJOR ||
+	if (FW_HDR_FW_VER_MAJOR_GET(hw->fwrev) != FW_VERSION_MAJOR(hw) ||
 	    fw_ver > hw->fwrev) {
 		ret = csio_hw_fw_upgrade(hw, hw->pfn, fw->data, fw->size,
 				    /*force=*/false);
 		if (!ret)
-			csio_info(hw, "firmware upgraded to version %pI4 from "
-				  CSIO_FW_FNAME "\n", &hdr->fw_ver);
+			csio_info(hw,
+				  "firmware upgraded to version %pI4 from %s\n",
+				  &hdr->fw_ver, CSIO_FW_FNAME(hw));
 		else
 			csio_err(hw, "firmware upgrade failed! err=%d\n", ret);
-	}
+	} else
+		ret = -EINVAL;
 
 	release_firmware(fw);
 
@@ -2410,7 +2163,7 @@ csio_hw_configure(struct csio_hw *hw)
 	/* Set pci completion timeout value to 4 seconds. */
 	csio_set_pcie_completion_timeout(hw, 0xd);
 
-	csio_hw_set_mem_win(hw);
+	hw->chip_ops->chip_set_mem_win(hw, MEMWIN_CSIOSTOR);
 
 	rv = csio_hw_get_fw_version(hw, &hw->fwrev);
 	if (rv != 0)
@@ -2478,6 +2231,8 @@ csio_hw_configure(struct csio_hw *hw)
 	} else {
 		if (hw->fw_state == CSIO_DEV_STATE_INIT) {
 
+			hw->flags |= CSIO_HWF_USING_SOFT_PARAMS;
+
 			/* device parameters */
 			rv = csio_get_device_params(hw);
 			if (rv != 0)
@@ -2651,7 +2406,7 @@ csio_hw_intr_disable(struct csio_hw *hw)
 
 }
 
-static void
+void
 csio_hw_fatal_err(struct csio_hw *hw)
 {
 	csio_set_reg_field(hw, SGE_CONTROL, GLOBALENABLE, 0);
@@ -2990,14 +2745,6 @@ csio_hws_pcierr(struct csio_hw *hw, enum csio_hw_ev evt)
 /* END: HW SM                                                                */
 /*****************************************************************************/
 
-/* Slow path handlers */
-struct intr_info {
-	unsigned int mask;       /* bits to check in interrupt status */
-	const char *msg;         /* message to print or NULL */
-	short stat_idx;          /* stat counter to increment or -1 */
-	unsigned short fatal;    /* whether the condition reported is fatal */
-};
-
 /*
  *	csio_handle_intr_status - table driven interrupt handler
  *	@hw: HW instance
@@ -3011,7 +2758,7 @@ struct intr_info {
  *	by an entry specifying mask 0.  Returns the number of fatal interrupt
  *	conditions.
  */
-static int
+int
 csio_handle_intr_status(struct csio_hw *hw, unsigned int reg,
 				 const struct intr_info *acts)
 {
@@ -3038,80 +2785,6 @@ csio_handle_intr_status(struct csio_hw *hw, unsigned int reg,
 }
 
 /*
- * Interrupt handler for the PCIE module.
- */
-static void
-csio_pcie_intr_handler(struct csio_hw *hw)
-{
-	static struct intr_info sysbus_intr_info[] = {
-		{ RNPP, "RXNP array parity error", -1, 1 },
-		{ RPCP, "RXPC array parity error", -1, 1 },
-		{ RCIP, "RXCIF array parity error", -1, 1 },
-		{ RCCP, "Rx completions control array parity error", -1, 1 },
-		{ RFTP, "RXFT array parity error", -1, 1 },
-		{ 0, NULL, 0, 0 }
-	};
-	static struct intr_info pcie_port_intr_info[] = {
-		{ TPCP, "TXPC array parity error", -1, 1 },
-		{ TNPP, "TXNP array parity error", -1, 1 },
-		{ TFTP, "TXFT array parity error", -1, 1 },
-		{ TCAP, "TXCA array parity error", -1, 1 },
-		{ TCIP, "TXCIF array parity error", -1, 1 },
-		{ RCAP, "RXCA array parity error", -1, 1 },
-		{ OTDD, "outbound request TLP discarded", -1, 1 },
-		{ RDPE, "Rx data parity error", -1, 1 },
-		{ TDUE, "Tx uncorrectable data error", -1, 1 },
-		{ 0, NULL, 0, 0 }
-	};
-	static struct intr_info pcie_intr_info[] = {
-		{ MSIADDRLPERR, "MSI AddrL parity error", -1, 1 },
-		{ MSIADDRHPERR, "MSI AddrH parity error", -1, 1 },
-		{ MSIDATAPERR, "MSI data parity error", -1, 1 },
-		{ MSIXADDRLPERR, "MSI-X AddrL parity error", -1, 1 },
-		{ MSIXADDRHPERR, "MSI-X AddrH parity error", -1, 1 },
-		{ MSIXDATAPERR, "MSI-X data parity error", -1, 1 },
-		{ MSIXDIPERR, "MSI-X DI parity error", -1, 1 },
-		{ PIOCPLPERR, "PCI PIO completion FIFO parity error", -1, 1 },
-		{ PIOREQPERR, "PCI PIO request FIFO parity error", -1, 1 },
-		{ TARTAGPERR, "PCI PCI target tag FIFO parity error", -1, 1 },
-		{ CCNTPERR, "PCI CMD channel count parity error", -1, 1 },
-		{ CREQPERR, "PCI CMD channel request parity error", -1, 1 },
-		{ CRSPPERR, "PCI CMD channel response parity error", -1, 1 },
-		{ DCNTPERR, "PCI DMA channel count parity error", -1, 1 },
-		{ DREQPERR, "PCI DMA channel request parity error", -1, 1 },
-		{ DRSPPERR, "PCI DMA channel response parity error", -1, 1 },
-		{ HCNTPERR, "PCI HMA channel count parity error", -1, 1 },
-		{ HREQPERR, "PCI HMA channel request parity error", -1, 1 },
-		{ HRSPPERR, "PCI HMA channel response parity error", -1, 1 },
-		{ CFGSNPPERR, "PCI config snoop FIFO parity error", -1, 1 },
-		{ FIDPERR, "PCI FID parity error", -1, 1 },
-		{ INTXCLRPERR, "PCI INTx clear parity error", -1, 1 },
-		{ MATAGPERR, "PCI MA tag parity error", -1, 1 },
-		{ PIOTAGPERR, "PCI PIO tag parity error", -1, 1 },
-		{ RXCPLPERR, "PCI Rx completion parity error", -1, 1 },
-		{ RXWRPERR, "PCI Rx write parity error", -1, 1 },
-		{ RPLPERR, "PCI replay buffer parity error", -1, 1 },
-		{ PCIESINT, "PCI core secondary fault", -1, 1 },
-		{ PCIEPINT, "PCI core primary fault", -1, 1 },
-		{ UNXSPLCPLERR, "PCI unexpected split completion error", -1,
-		  0 },
-		{ 0, NULL, 0, 0 }
-	};
-
-	int fat;
-
-	fat = csio_handle_intr_status(hw,
-				    PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS,
-				    sysbus_intr_info) +
-	      csio_handle_intr_status(hw,
-				    PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS,
-				    pcie_port_intr_info) +
-	      csio_handle_intr_status(hw, PCIE_INT_CAUSE, pcie_intr_info);
-	if (fat)
-		csio_hw_fatal_err(hw);
-}
-
-/*
  * TP interrupt handler.
  */
 static void csio_tp_intr_handler(struct csio_hw *hw)
@@ -3517,7 +3190,7 @@ static void csio_ncsi_intr_handler(struct csio_hw *hw)
  */
 static void csio_xgmac_intr_handler(struct csio_hw *hw, int port)
 {
-	uint32_t v = csio_rd_reg32(hw, PORT_REG(port, XGMAC_PORT_INT_CAUSE));
+	uint32_t v = csio_rd_reg32(hw, CSIO_MAC_INT_CAUSE_REG(hw, port));
 
 	v &= TXFIFO_PRTY_ERR | RXFIFO_PRTY_ERR;
 	if (!v)
@@ -3527,7 +3200,7 @@ static void csio_xgmac_intr_handler(struct csio_hw *hw, int port)
 		csio_fatal(hw, "XGMAC %d Tx FIFO parity error\n", port);
 	if (v & RXFIFO_PRTY_ERR)
 		csio_fatal(hw, "XGMAC %d Rx FIFO parity error\n", port);
-	csio_wr_reg32(hw, v, PORT_REG(port, XGMAC_PORT_INT_CAUSE));
+	csio_wr_reg32(hw, v, CSIO_MAC_INT_CAUSE_REG(hw, port));
 	csio_hw_fatal_err(hw);
 }
 
@@ -3596,7 +3269,7 @@ csio_hw_slow_intr_handler(struct csio_hw *hw)
 		csio_xgmac_intr_handler(hw, 3);
 
 	if (cause & PCIE)
-		csio_pcie_intr_handler(hw);
+		hw->chip_ops->chip_pcie_intr_handler(hw);
 
 	if (cause & MC)
 		csio_mem_intr_handler(hw, MEM_MC);
@@ -4262,6 +3935,7 @@ csio_hw_get_device_id(struct csio_hw *hw)
 			     &hw->params.pci.device_id);
 
 	csio_dev_id_cached(hw);
+	hw->chip_id = (hw->params.pci.device_id & CSIO_HW_CHIP_MASK);
 
 } /* csio_hw_get_device_id */
 
@@ -4280,19 +3954,21 @@ csio_hw_set_description(struct csio_hw *hw, uint16_t ven_id, uint16_t dev_id)
 		prot_type = (dev_id & CSIO_ASIC_DEVID_PROTO_MASK);
 		adap_type = (dev_id & CSIO_ASIC_DEVID_TYPE_MASK);
 
-		if (prot_type == CSIO_FPGA) {
+		if (prot_type == CSIO_T4_FCOE_ASIC) {
+			memcpy(hw->hw_ver,
+			       csio_t4_fcoe_adapters[adap_type].model_no, 16);
 			memcpy(hw->model_desc,
-				csio_fcoe_adapters[13].description, 32);
-		} else if (prot_type == CSIO_T4_FCOE_ASIC) {
+			       csio_t4_fcoe_adapters[adap_type].description,
+			       32);
+		} else if (prot_type == CSIO_T5_FCOE_ASIC) {
 			memcpy(hw->hw_ver,
-			       csio_fcoe_adapters[adap_type].model_no, 16);
+			       csio_t5_fcoe_adapters[adap_type].model_no, 16);
 			memcpy(hw->model_desc,
-				csio_fcoe_adapters[adap_type].description, 32);
+			       csio_t5_fcoe_adapters[adap_type].description,
+			       32);
 		} else {
 			char tempName[32] = "Chelsio FCoE Controller";
 			memcpy(hw->model_desc, tempName, 32);
-
-			CSIO_DB_ASSERT(0);
 		}
 	}
 } /* csio_hw_set_description */
@@ -4321,6 +3997,9 @@ csio_hw_init(struct csio_hw *hw)
 
 	strcpy(hw->name, CSIO_HW_NAME);
 
+	/* Initialize the HW chip ops with T4/T5 specific ops */
+	hw->chip_ops = csio_is_t4(hw->chip_id) ? &t4_ops : &t5_ops;
+
 	/* Set the model & its description */
 
 	ven_id = hw->params.pci.vendor_id;
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index 9edcca4..489fc09 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -48,6 +48,7 @@
 #include <scsi/scsi_device.h>
 #include <scsi/scsi_transport_fc.h>
 
+#include "csio_hw_chip.h"
 #include "csio_wr.h"
 #include "csio_mb.h"
 #include "csio_scsi.h"
@@ -60,13 +61,6 @@
  */
 #define	FW_HOSTERROR			255
 
-#define CSIO_FW_FNAME		"cxgb4/t4fw.bin"
-#define CSIO_CF_FNAME		"cxgb4/t4-config.txt"
-
-#define FW_VERSION_MAJOR	1
-#define FW_VERSION_MINOR	2
-#define FW_VERSION_MICRO	8
-
 #define CSIO_HW_NAME		"Chelsio FCoE Adapter"
 #define CSIO_MAX_PFN		8
 #define CSIO_MAX_PPORTS		4
@@ -123,8 +117,6 @@ extern int csio_msi;
 #define CSIO_VENDOR_ID				0x1425
 #define CSIO_ASIC_DEVID_PROTO_MASK		0xFF00
 #define CSIO_ASIC_DEVID_TYPE_MASK		0x00FF
-#define CSIO_FPGA				0xA000
-#define CSIO_T4_FCOE_ASIC			0x4600
 
 #define CSIO_GLBL_INTR_MASK		(CIM | MPS | PL | PCIE | MC | EDC0 | \
 					 EDC1 | LE | TP | MA | PM_TX | PM_RX | \
@@ -207,17 +199,6 @@ enum {
 	SF_SIZE = SF_SEC_SIZE * 16,   /* serial flash size */
 };
 
-enum { MEM_EDC0, MEM_EDC1, MEM_MC };
-
-enum {
-	MEMWIN0_APERTURE = 2048,
-	MEMWIN0_BASE     = 0x1b800,
-	MEMWIN1_APERTURE = 32768,
-	MEMWIN1_BASE     = 0x28000,
-	MEMWIN2_APERTURE = 65536,
-	MEMWIN2_BASE     = 0x30000,
-};
-
 /* serial flash and firmware constants */
 enum {
 	SF_ATTEMPTS = 10,             /* max retries for SF operations */
@@ -239,9 +220,6 @@ enum {
 	FLASH_CFG_MAX_SIZE    = 0x10000 , /* max size of the flash config file*/
 	FLASH_CFG_OFFSET      = 0x1f0000,
 	FLASH_CFG_START_SEC   = FLASH_CFG_OFFSET / SF_SEC_SIZE,
-	FPGA_FLASH_CFG_OFFSET = 0xf0000 , /* if FPGA mode, then cfg file is
-					   * at 1MB - 64KB */
-	FPGA_FLASH_CFG_START_SEC  = FPGA_FLASH_CFG_OFFSET / SF_SEC_SIZE,
 };
 
 /*
@@ -259,6 +237,8 @@ enum {
 	FLASH_FW_START = FLASH_START(FLASH_FW_START_SEC),
 	FLASH_FW_MAX_SIZE = FLASH_MAX_SIZE(FLASH_FW_NSECS),
 
+	/* Location of Firmware Configuration File in FLASH. */
+	FLASH_CFG_START = FLASH_START(FLASH_CFG_START_SEC),
 };
 
 #undef FLASH_START
@@ -310,7 +290,7 @@ struct csio_adap_desc {
 struct pci_params {
 	uint16_t   vendor_id;
 	uint16_t   device_id;
-	uint32_t   vpd_cap_addr;
+	int        vpd_cap_addr;
 	uint16_t   speed;
 	uint8_t    width;
 };
@@ -513,6 +493,7 @@ struct csio_hw {
 	uint32_t		fwrev;
 	uint32_t		tp_vers;
 	char			chip_ver;
+	uint16_t		chip_id;		/* Tells T4/T5 chip */
 	uint32_t		cfg_finiver;
 	uint32_t		cfg_finicsum;
 	uint32_t		cfg_cfcsum;
@@ -556,6 +537,9 @@ struct csio_hw {
 							 */
 
 	struct csio_fcoe_res_info  fres_info;		/* Fcoe resource info */
+	struct csio_hw_chip_ops	*chip_ops;		/* T4/T5 Chip specific
+							 * Operations
+							 */
 
 	/* MSIX vectors */
 	struct csio_msix_entries msix_entries[CSIO_MAX_MSIX_VECS];
@@ -636,9 +620,16 @@ csio_us_to_core_ticks(struct csio_hw *hw, uint32_t us)
 #define csio_dbg(__hw, __fmt, ...)
 #endif
 
+int csio_hw_wait_op_done_val(struct csio_hw *, int, uint32_t, int,
+			     int, int, uint32_t *);
+void csio_hw_tp_wr_bits_indirect(struct csio_hw *, unsigned int,
+				 unsigned int, unsigned int);
 int csio_mgmt_req_lookup(struct csio_mgmtm *, struct csio_ioreq *);
 void csio_hw_intr_disable(struct csio_hw *);
-int csio_hw_slow_intr_handler(struct csio_hw *hw);
+int csio_hw_slow_intr_handler(struct csio_hw *);
+int csio_handle_intr_status(struct csio_hw *, unsigned int,
+			    const struct intr_info *);
+
 int csio_hw_start(struct csio_hw *);
 int csio_hw_stop(struct csio_hw *);
 int csio_hw_reset(struct csio_hw *);
@@ -647,19 +638,17 @@ int csio_is_hw_removing(struct csio_hw *);
 
 int csio_fwevtq_handler(struct csio_hw *);
 void csio_evtq_worker(struct work_struct *);
-int csio_enqueue_evt(struct csio_hw *hw, enum csio_evt type,
-				void *evt_msg, uint16_t len);
+int csio_enqueue_evt(struct csio_hw *, enum csio_evt, void *, uint16_t);
 void csio_evtq_flush(struct csio_hw *hw);
 
 int csio_request_irqs(struct csio_hw *);
 void csio_intr_enable(struct csio_hw *);
 void csio_intr_disable(struct csio_hw *, bool);
+void csio_hw_fatal_err(struct csio_hw *);
 
 struct csio_lnode *csio_lnode_alloc(struct csio_hw *);
 int csio_config_queues(struct csio_hw *);
 
-int csio_hw_mc_read(struct csio_hw *, uint32_t, __be32 *, uint64_t *);
-int csio_hw_edc_read(struct csio_hw *, int, uint32_t, __be32 *, uint64_t *);
 int csio_hw_init(struct csio_hw *);
 void csio_hw_exit(struct csio_hw *);
 #endif /* ifndef __CSIO_HW_H__ */
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index 0604b5f..00346fe 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -81,9 +81,11 @@ csio_mem_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		__be32 data[16];
 
 		if (mem == MEM_MC)
-			ret = csio_hw_mc_read(hw, pos, data, NULL);
+			ret = hw->chip_ops->chip_mc_read(hw, 0, pos,
+							 data, NULL);
 		else
-			ret = csio_hw_edc_read(hw, mem, pos, data, NULL);
+			ret = hw->chip_ops->chip_edc_read(hw, mem, pos,
+							  data, NULL);
 		if (ret)
 			return ret;
 
@@ -108,7 +110,7 @@ static const struct file_operations csio_mem_debugfs_fops = {
 	.llseek  = default_llseek,
 };
 
-static void csio_add_debugfs_mem(struct csio_hw *hw, const char *name,
+void csio_add_debugfs_mem(struct csio_hw *hw, const char *name,
 				 unsigned int idx, unsigned int size_mb)
 {
 	struct dentry *de;
@@ -131,9 +133,8 @@ static int csio_setup_debugfs(struct csio_hw *hw)
 		csio_add_debugfs_mem(hw, "edc0", MEM_EDC0, 5);
 	if (i & EDRAM1_ENABLE)
 		csio_add_debugfs_mem(hw, "edc1", MEM_EDC1, 5);
-	if (i & EXT_MEM_ENABLE)
-		csio_add_debugfs_mem(hw, "mc", MEM_MC,
-		      EXT_MEM_SIZE_GET(csio_rd_reg32(hw, MA_EXT_MEMORY_BAR)));
+
+	hw->chip_ops->chip_dfs_create_ext_mem(hw);
 	return 0;
 }
 
@@ -1169,7 +1170,7 @@ static struct pci_error_handlers csio_err_handler = {
 };
 
 static DEFINE_PCI_DEVICE_TABLE(csio_pci_tbl) = {
-	CSIO_DEVICE(CSIO_DEVID_T440DBG_FCOE, 0),	/* T440DBG FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T440DBG_FCOE, 0),        /* T4 DEBUG FCOE */
 	CSIO_DEVICE(CSIO_DEVID_T420CR_FCOE, 0),		/* T420CR FCOE */
 	CSIO_DEVICE(CSIO_DEVID_T422CR_FCOE, 0),		/* T422CR FCOE */
 	CSIO_DEVICE(CSIO_DEVID_T440CR_FCOE, 0),		/* T440CR FCOE */
@@ -1184,8 +1185,34 @@ static DEFINE_PCI_DEVICE_TABLE(csio_pci_tbl) = {
 	CSIO_DEVICE(CSIO_DEVID_B404_FCOE, 0),		/* B404 FCOE */
 	CSIO_DEVICE(CSIO_DEVID_T480CR_FCOE, 0),		/* T480 CR FCOE */
 	CSIO_DEVICE(CSIO_DEVID_T440LPCR_FCOE, 0),	/* T440 LP-CR FCOE */
-	CSIO_DEVICE(CSIO_DEVID_PE10K, 0),		/* PE10K FCOE */
-	CSIO_DEVICE(CSIO_DEVID_PE10K_PF1, 0),	/* PE10K FCOE on PF1 */
+	CSIO_DEVICE(CSIO_DEVID_AMSTERDAM_T4_FCOE, 0),   /* AMSTERDAM T4 FCOE */
+	CSIO_DEVICE(CSIO_DEVID_HUAWEI_T480_FCOE, 0),    /* HUAWEI T480 FCOE */
+	CSIO_DEVICE(CSIO_DEVID_HUAWEI_T440_FCOE, 0),    /* HUAWEI T440 FCOE */
+	CSIO_DEVICE(CSIO_DEVID_HUAWEI_STG310_FCOE, 0),  /* HUAWEI STG FCOE */
+	CSIO_DEVICE(CSIO_DEVID_ACROMAG_XMC_XAUI, 0),    /* ACROMAG XAUI FCOE */
+	CSIO_DEVICE(CSIO_DEVID_QUANTA_MEZZ_SFP_FCOE, 0),/* QUANTA MEZZ FCOE */
+	CSIO_DEVICE(CSIO_DEVID_HUAWEI_10GT_FCOE, 0),    /* HUAWEI 10GT FCOE */
+	CSIO_DEVICE(CSIO_DEVID_HUAWEI_T440_TOE_FCOE, 0),/* HUAWEI T4 TOE FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T580DBG_FCOE, 0),        /* T5 DEBUG FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T520CR_FCOE, 0),         /* T520CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T522CR_FCOE, 0),         /* T522CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T540CR_FCOE, 0),         /* T540CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T520BCH_FCOE, 0),        /* T520BCH FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T540BCH_FCOE, 0),        /* T540BCH FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T540CH_FCOE, 0),         /* T540CH FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T520SO_FCOE, 0),         /* T520SO FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T520CX_FCOE, 0),         /* T520CX FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T520BT_FCOE, 0),         /* T520BT FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T504BT_FCOE, 0),         /* T504BT FCOE */
+	CSIO_DEVICE(CSIO_DEVID_B520_FCOE, 0),           /* B520 FCOE */
+	CSIO_DEVICE(CSIO_DEVID_B504_FCOE, 0),           /* B504 FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T580CR2_FCOE, 0),	/* T580 CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T540LPCR_FCOE, 0),       /* T540 LP-CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_AMSTERDAM_T5_FCOE, 0),   /* AMSTERDAM T5 FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T580LPCR_FCOE, 0),       /* T580 LP-CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T520LLCR_FCOE, 0),       /* T520 LL-CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T560CR_FCOE, 0),         /* T560 CR FCOE */
+	CSIO_DEVICE(CSIO_DEVID_T580CR_FCOE, 0),         /* T580 CR FCOE */
 	{ 0, 0, 0, 0, 0, 0, 0 }
 };
 
@@ -1259,4 +1286,5 @@ MODULE_DESCRIPTION(CSIO_DRV_DESC);
 MODULE_LICENSE(CSIO_DRV_LICENSE);
 MODULE_DEVICE_TABLE(pci, csio_pci_tbl);
 MODULE_VERSION(CSIO_DRV_VERSION);
-MODULE_FIRMWARE(CSIO_FW_FNAME);
+MODULE_FIRMWARE(FW_FNAME_T4);
+MODULE_FIRMWARE(FW_FNAME_T5);
diff --git a/drivers/scsi/csiostor/csio_init.h b/drivers/scsi/csiostor/csio_init.h
index 0838fd7..5cc5d31 100644
--- a/drivers/scsi/csiostor/csio_init.h
+++ b/drivers/scsi/csiostor/csio_init.h
@@ -52,31 +52,6 @@
 #define CSIO_DRV_DESC			"Chelsio FCoE driver"
 #define CSIO_DRV_VERSION		"1.0.0"
 
-#define CSIO_DEVICE(devid, idx)					\
-{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
-
-#define CSIO_IS_T4_FPGA(_dev)		(((_dev) == CSIO_DEVID_PE10K) ||\
-					 ((_dev) == CSIO_DEVID_PE10K_PF1))
-
-/* FCoE device IDs */
-#define CSIO_DEVID_PE10K		0xA000
-#define CSIO_DEVID_PE10K_PF1		0xA001
-#define CSIO_DEVID_T440DBG_FCOE		0x4600
-#define CSIO_DEVID_T420CR_FCOE		0x4601
-#define CSIO_DEVID_T422CR_FCOE		0x4602
-#define CSIO_DEVID_T440CR_FCOE		0x4603
-#define CSIO_DEVID_T420BCH_FCOE		0x4604
-#define CSIO_DEVID_T440BCH_FCOE		0x4605
-#define CSIO_DEVID_T440CH_FCOE		0x4606
-#define CSIO_DEVID_T420SO_FCOE		0x4607
-#define CSIO_DEVID_T420CX_FCOE		0x4608
-#define CSIO_DEVID_T420BT_FCOE		0x4609
-#define CSIO_DEVID_T404BT_FCOE		0x460A
-#define CSIO_DEVID_B420_FCOE		0x460B
-#define CSIO_DEVID_B404_FCOE		0x460C
-#define CSIO_DEVID_T480CR_FCOE		0x460D
-#define CSIO_DEVID_T440LPCR_FCOE	0x460E
-
 extern struct fc_function_template csio_fc_transport_funcs;
 extern struct fc_function_template csio_fc_transport_vport_funcs;
 
@@ -100,6 +75,10 @@ struct csio_lnode *csio_shost_init(struct csio_hw *, struct device *, bool,
 void csio_shost_exit(struct csio_lnode *);
 void csio_lnodes_exit(struct csio_hw *, bool);
 
+/* DebugFS helper routines */
+void csio_add_debugfs_mem(struct csio_hw *, const char *,
+		unsigned int, unsigned int);
+
 static inline struct Scsi_Host *
 csio_ln_to_shost(struct csio_lnode *ln)
 {
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index 713e77d..4255ce2 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -85,8 +85,8 @@ csio_wr_ring_fldb(struct csio_hw *hw, struct csio_q *flq)
 	 */
 	if (flq->inc_idx >= 8) {
 		csio_wr_reg32(hw, DBPRIO(1) | QID(flq->un.fl.flid) |
-			      PIDX(flq->inc_idx / 8),
-			      MYPF_REG(SGE_PF_KDOORBELL));
+				  CSIO_HW_PIDX(hw, flq->inc_idx / 8),
+				  MYPF_REG(SGE_PF_KDOORBELL));
 		flq->inc_idx &= 7;
 	}
 }
@@ -989,7 +989,8 @@ csio_wr_issue(struct csio_hw *hw, int qidx, bool prio)
 	wmb();
 	/* Ring SGE Doorbell writing q->pidx into it */
 	csio_wr_reg32(hw, DBPRIO(prio) | QID(q->un.eq.physeqid) |
-		      PIDX(q->inc_idx), MYPF_REG(SGE_PF_KDOORBELL));
+			  CSIO_HW_PIDX(hw, q->inc_idx),
+			  MYPF_REG(SGE_PF_KDOORBELL));
 	q->inc_idx = 0;
 
 	return 0;
@@ -1352,6 +1353,9 @@ csio_wr_fixup_host_params(struct csio_hw *hw)
 	/* default value of rx_dma_offset of the NIC driver */
 	csio_set_reg_field(hw, SGE_CONTROL, PKTSHIFT_MASK,
 			   PKTSHIFT(CSIO_SGE_RX_DMA_OFFSET));
+
+	csio_hw_tp_wr_bits_indirect(hw, TP_INGRESS_CONFIG,
+				    CSUM_HAS_PSEUDO_HDR, 0);
 }
 
 static void
@@ -1467,10 +1471,11 @@ csio_wr_set_sge(struct csio_hw *hw)
 	 * and generate an interrupt when this occurs so we can recover.
 	 */
 	csio_set_reg_field(hw, SGE_DBFIFO_STATUS,
-			   HP_INT_THRESH(HP_INT_THRESH_MASK) |
-			   LP_INT_THRESH(LP_INT_THRESH_MASK),
-			   HP_INT_THRESH(CSIO_SGE_DBFIFO_INT_THRESH) |
-			   LP_INT_THRESH(CSIO_SGE_DBFIFO_INT_THRESH));
+		   HP_INT_THRESH(HP_INT_THRESH_MASK) |
+		   CSIO_HW_LP_INT_THRESH(hw, CSIO_HW_M_LP_INT_THRESH(hw)),
+		   HP_INT_THRESH(CSIO_SGE_DBFIFO_INT_THRESH) |
+		   CSIO_HW_LP_INT_THRESH(hw, CSIO_SGE_DBFIFO_INT_THRESH));
+
 	csio_set_reg_field(hw, SGE_DOORBELL_CONTROL, ENABLE_DROP,
 			   ENABLE_DROP);
 
-- 
1.7.1
