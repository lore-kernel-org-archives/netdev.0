From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH 3/3] csiostor:Adds debugfs support.
Date: Tue,  9 Jun 2015 18:44:46 +0530
Message-ID: <1433855686-15768-4-git-send-email-praveenm@chelsio.com>
References: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com,
	rajesh.kumar@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4092 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932341AbbFINPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 09:15:21 -0400
In-Reply-To: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds debugfs support to dump adapter log, adapter queues,
and fcoe DDP stats.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    1 +
 drivers/scsi/csiostor/Makefile               |    2 +-
 drivers/scsi/csiostor/csio_debugfs.c         | 1100 ++++++++++++++++++++++++++
 3 files changed, 1102 insertions(+), 1 deletion(-)
 create mode 100644 drivers/scsi/csiostor/csio_debugfs.c

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index af3462d..cb8b161 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1442,6 +1442,7 @@
 #define TP_MIB_FCOE_DDP_0_A	0x48
 #define TP_MIB_FCOE_DROP_0_A	0x4c
 #define TP_MIB_FCOE_BYTE_0_HI_A	0x50
+#define TP_MIB_FCOE_BYTE_0_LO_A 0x51
 #define TP_MIB_OFD_VLN_DROP_0_A	0x58
 #define TP_MIB_USM_PKTS_A	0x5c
 #define TP_MIB_RQE_DFR_PKT_A	0x64
diff --git a/drivers/scsi/csiostor/Makefile b/drivers/scsi/csiostor/Makefile
index 3681a3f..7799537 100644
--- a/drivers/scsi/csiostor/Makefile
+++ b/drivers/scsi/csiostor/Makefile
@@ -9,4 +9,4 @@ obj-$(CONFIG_SCSI_CHELSIO_FCOE) += csiostor.o
 
 csiostor-objs := csio_attr.o csio_init.o csio_lnode.o csio_scsi.o \
 		csio_hw.o csio_hw_t5.o csio_isr.o \
-		csio_mb.o csio_rnode.o csio_wr.o
+		csio_mb.o csio_rnode.o csio_wr.o csio_debugfs.o
diff --git a/drivers/scsi/csiostor/csio_debugfs.c b/drivers/scsi/csiostor/csio_debugfs.c
new file mode 100644
index 0000000..1ed6235
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_debugfs.c
@@ -0,0 +1,1100 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2015 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/aer.h>
+#include <linux/mm.h>
+#include <linux/notifier.h>
+#include <linux/kdebug.h>
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+#include <linux/string.h>
+#include <linux/export.h>
+#include <linux/delay.h>
+
+#include "t4fw_api.h"
+#include "csio_init.h"
+#include "csio_defs.h"
+#include "csio_hw.h"
+
+static struct dentry *csio_debugfs_root;
+
+#define DEFINE_SIMPLE_DEBUGFS_FILE(name) \
+static int name##_open(struct inode *inode, struct file *file) \
+{ \
+	return single_open(file, name##_show, inode->i_private); \
+} \
+static const struct file_operations name##_fops = { \
+	.owner   = THIS_MODULE, \
+	.open    = name##_open, \
+	.read    = seq_read, \
+	.llseek  = seq_lseek, \
+	.release = single_release \
+}
+
+struct csio_debugfs_entry {
+	const char *name;
+	const struct file_operations *ops;
+	umode_t mode;
+	unsigned char data;
+};
+
+struct seq_tab {
+	int (*show)(struct seq_file *seq, void *v, int idx);
+	unsigned int rows;        /* # of entries */
+	unsigned char width;      /* size in bytes of each entry */
+	unsigned char skip_first; /* whether the first line is a header */
+	char data[0];             /* the table data */
+};
+
+struct tp_fcoe_stats {
+	uint32_t frames_ddp;
+	uint32_t frames_drop;
+	uint64_t octets_ddp;
+};
+
+/*
+ * Information gathered by Device Log Open routine for the display routine.
+ */
+struct devlog_info {
+	unsigned int nentries;		/* number of entries in log[] */
+	unsigned int first;		/* first [temporal] entry in log[] */
+	struct fw_devlog_e log[0];	/* Firmware Device Log */
+};
+
+/*
+ * Firmware Device Log dump.
+ */
+static const char * const devlog_level_strings[] = {
+	[FW_DEVLOG_LEVEL_EMERG]		= "EMERG",
+	[FW_DEVLOG_LEVEL_CRIT]		= "CRIT",
+	[FW_DEVLOG_LEVEL_ERR]		= "ERR",
+	[FW_DEVLOG_LEVEL_NOTICE]	= "NOTICE",
+	[FW_DEVLOG_LEVEL_INFO]		= "INFO",
+	[FW_DEVLOG_LEVEL_DEBUG]		= "DEBUG"
+};
+
+static const char * const devlog_facility_strings[] = {
+	[FW_DEVLOG_FACILITY_CORE]	= "CORE",
+	[FW_DEVLOG_FACILITY_SCHED]	= "SCHED",
+	[FW_DEVLOG_FACILITY_TIMER]	= "TIMER",
+	[FW_DEVLOG_FACILITY_RES]	= "RES",
+	[FW_DEVLOG_FACILITY_HW]		= "HW",
+	[FW_DEVLOG_FACILITY_FLR]	= "FLR",
+	[FW_DEVLOG_FACILITY_DMAQ]	= "DMAQ",
+	[FW_DEVLOG_FACILITY_PHY]	= "PHY",
+	[FW_DEVLOG_FACILITY_MAC]	= "MAC",
+	[FW_DEVLOG_FACILITY_PORT]	= "PORT",
+	[FW_DEVLOG_FACILITY_VI]		= "VI",
+	[FW_DEVLOG_FACILITY_FILTER]	= "FILTER",
+	[FW_DEVLOG_FACILITY_ACL]	= "ACL",
+	[FW_DEVLOG_FACILITY_TM]		= "TM",
+	[FW_DEVLOG_FACILITY_QFC]	= "QFC",
+	[FW_DEVLOG_FACILITY_DCB]	= "DCB",
+	[FW_DEVLOG_FACILITY_ETH]	= "ETH",
+	[FW_DEVLOG_FACILITY_OFLD]	= "OFLD",
+	[FW_DEVLOG_FACILITY_RI]		= "RI",
+	[FW_DEVLOG_FACILITY_ISCSI]	= "ISCSI",
+	[FW_DEVLOG_FACILITY_FCOE]	= "FCOE",
+	[FW_DEVLOG_FACILITY_FOISCSI]	= "FOISCSI",
+	[FW_DEVLOG_FACILITY_FOFCOE]	= "FOFCOE"
+};
+
+/* generic seq_file support for showing a table of size rows x width. */
+static void *seq_tab_get_idx(struct seq_tab *tb, loff_t pos)
+{
+	pos -= tb->skip_first;
+	return pos >= tb->rows ? NULL : &tb->data[pos * tb->width];
+}
+
+static void *seq_tab_start(struct seq_file *seq, loff_t *pos)
+{
+	struct seq_tab *tb = seq->private;
+
+	if (tb->skip_first && *pos == 0)
+		return SEQ_START_TOKEN;
+
+	return seq_tab_get_idx(tb, *pos);
+}
+
+static void *seq_tab_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	v = seq_tab_get_idx(seq->private, *pos + 1);
+	if (v)
+		++*pos;
+	return v;
+}
+
+static void seq_tab_stop(struct seq_file *seq, void *v)
+{
+}
+
+static int seq_tab_show(struct seq_file *seq, void *v)
+{
+	const struct seq_tab *tb = seq->private;
+
+	return tb->show(seq, v, ((char *)v - tb->data) / tb->width);
+}
+
+static const struct seq_operations seq_tab_ops = {
+	.start = seq_tab_start,
+	.next  = seq_tab_next,
+	.stop  = seq_tab_stop,
+	.show  = seq_tab_show
+};
+
+static struct seq_tab *seq_open_tab(struct file *f, unsigned int rows,
+			     unsigned int width, unsigned int have_header,
+			     int (*show)(struct seq_file *seq, void *v, int i))
+{
+	struct seq_tab *p;
+
+	p = __seq_open_private(f, &seq_tab_ops, sizeof(*p) + rows * width);
+	if (p) {
+		p->show = show;
+		p->rows = rows;
+		p->width = width;
+		p->skip_first = have_header != 0;
+	}
+	return p;
+}
+
+/*
+ * Trim the size of a seq_tab to the supplied number of rows.  The operation is
+ * irreversible.
+ */
+static int seq_tab_trim(struct seq_tab *p, unsigned int new_rows)
+{
+	if (new_rows > p->rows)
+		return -EINVAL;
+	p->rows = new_rows;
+		return 0;
+}
+
+static inline int csio_hw_wait_op_done(struct csio_hw *hw, int reg,
+		uint32_t mask, int polarity, int attempts, int delay)
+{
+	return csio_hw_wait_op_done_val(hw, reg, mask, polarity, attempts,
+					delay, NULL);
+}
+
+/**
+ *	csio_hw_read_indirect - read indirectly addressed registers
+ *	@hw: the adapter
+ *	@addr_reg: register holding the indirect address
+ *	@data_reg: register holding the value of the indirect register
+ *	@vals: where the read register values are stored
+ *	@nregs: how many indirect registers to read
+ *	@start_idx: index of first indirect register to read
+ *
+ *	Reads registers that are accessed indirectly through an address/data
+ *	register pair.
+ */
+static void csio_hw_read_indirect(struct csio_hw *hw, unsigned int addr_reg,
+			     unsigned int data_reg, uint32_t *vals,
+			     unsigned int nregs, unsigned int start_idx)
+{
+	while (nregs--) {
+		csio_wr_reg32(hw, start_idx, addr_reg);
+		*vals++ = csio_rd_reg32(hw, data_reg);
+		start_idx++;
+	}
+}
+
+/**
+ *	csio_hw_mem_read - read EDC 0, EDC 1 or MC into buffer
+ *	@hw: the HW module
+ *	@mtype: memory type: MEM_EDC0, MEM_EDC1 or MEM_MC
+ *	@addr: address within indicated memory type
+ *	@len: amount of memory to read
+ *	@buf: host memory buffer
+ *
+ *	Reads an [almost] arbitrary memory region in the firmware: the
+ *	firmware memory address, length and host buffer must be aligned on
+ *	32-bit boudaries.  The memory is returned as a raw byte sequence from
+ *	the firmware's memory.  If this memory contains data structures which
+ *	contain multi-byte integers, it's the callers responsibility to
+ *	perform appropriate byte order conversions.
+ */
+static int
+csio_hw_mem_read(struct csio_hw *hw, int mtype, uint32_t addr, uint32_t len,
+		uint32_t *buf)
+{
+	uint32_t pos, start, end, offset;
+	int ret;
+
+	/*
+	 * Argument sanity checks ...
+	 */
+	if ((addr & 0x3) || (len & 0x3))
+		return -EINVAL;
+
+	/*
+	 * The underlaying EDC/MC read routines read 64 bytes at a time so we
+	 * need to round down the start and round up the end.  We'll start
+	 * copying out of the first line at (addr - start) a word at a time.
+	 */
+	start = addr & ~(64-1);
+	end = (addr + len + 64-1) & ~(64-1);
+	offset = (addr - start)/sizeof(__be32);
+
+	for (pos = start; pos < end; pos += 64, offset = 0) {
+		uint32_t data[16];
+
+		/*
+		 * Read the chip's memory block and bail if there's an error.
+		 */
+		if (mtype == MEM_MC) {
+			ret = hw->chip_ops->chip_mc_read(hw, 0, pos,
+						(__be32 *)data, NULL);
+		} else {
+			ret = hw->chip_ops->chip_edc_read(hw, mtype, pos,
+						(__be32 *)data, NULL);
+		}
+
+		if (ret)
+			return ret;
+
+		/*
+		 * Copy the data into the caller's memory buffer.
+		 */
+		while (offset < 16 && len > 0) {
+			*buf++ = data[offset++];
+			len -= sizeof(uint32_t);
+		}
+	}
+
+	return 0;
+}
+
+/**
+ *	csio_hw_read_cimq_cfg - read CIM queue configuration
+ *	@hw: the adapter
+ *	@base: holds the queue base addresses in bytes
+ *	@size: holds the queue sizes in bytes
+ *	@thres: holds the queue full thresholds in bytes
+ *
+ *	Returns the current configuration of the CIM queues, starting with
+ *	the IBQs, then the OBQs.
+ */
+static void csio_hw_read_cimq_cfg(struct csio_hw *hw, uint16_t *base,
+				uint16_t *size,	uint16_t *thres)
+{
+	unsigned int i, v;
+	int cim_num_obq = CIM_NUM_OBQ_T5;
+
+	for (i = 0; i < CIM_NUM_IBQ; i++) {
+		csio_wr_reg32(hw, IBQSELECT_F | QUENUMSELECT_V(i),
+				CIM_QUEUE_CONFIG_REF_A);
+		v = csio_rd_reg32(hw, CIM_QUEUE_CONFIG_CTRL_A);
+		/* value is in 256-byte units */
+		*base++ = CIMQBASE_G(v) * 256;
+		*size++ = CIMQSIZE_G(v) * 256;
+		*thres++ = QUEFULLTHRSH_G(v) * 8; /* 8-byte unit */
+	}
+	for (i = 0; i < cim_num_obq; i++) {
+		csio_wr_reg32(hw, OBQSELECT_F | QUENUMSELECT_V(i),
+				CIM_QUEUE_CONFIG_REF_A);
+		v = csio_rd_reg32(hw, CIM_QUEUE_CONFIG_CTRL_A);
+		/* value is in 256-byte units */
+		*base++ = CIMQBASE_G(v) * 256;
+		*size++ = CIMQSIZE_G(v) * 256;
+	}
+}
+
+/**
+ *	csio_hw_read_cim_ibq - read the contents of a CIM inbound queue
+ *	@hw: the adapter
+ *	@qid: the queue index
+ *	@data: where to store the queue contents
+ *	@n: capacity of @data in 32-bit words
+ *
+ *	Reads the contents of the selected CIM queue starting at address 0 up
+ *	to the capacity of @data.  @n must be a multiple of 4.  Returns < 0 on
+ *	error and the number of 32-bit words actually read on success.
+ */
+static int csio_hw_read_cim_ibq(struct csio_hw *hw, unsigned int qid,
+				uint32_t *data, size_t n)
+{
+	int i, err, attempts;
+	unsigned int addr;
+	const unsigned int nwords = CIM_IBQ_SIZE * 4;
+
+	if (qid > 5 || (n & 3))
+		return -EINVAL;
+
+	addr = qid * nwords;
+	if (n > nwords)
+		n = nwords;
+
+	/* It might take 3-10ms before the IBQ debug read access is allowed.
+	 * Wait for 1 Sec with a delay of 1 usec.
+	 */
+	attempts = 1000000;
+
+	for (i = 0; i < n; i++, addr++) {
+		csio_wr_reg32(hw, IBQDBGADDR_V(addr) | IBQDBGEN_F,
+				CIM_IBQ_DBG_CFG_A);
+		err = csio_hw_wait_op_done(hw, CIM_IBQ_DBG_CFG_A, IBQDBGBUSY_F,
+					0, attempts, 1);
+		if (err)
+			return err;
+		*data++ = csio_rd_reg32(hw, CIM_IBQ_DBG_DATA_A);
+	}
+	csio_wr_reg32(hw, 0, CIM_IBQ_DBG_CFG_A);
+	return i;
+}
+
+/**
+ *	csio_hw_read_cim_obq - read the contents of a CIM outbound queue
+ *	@hw: the adapter
+ *	@qid: the queue index
+ *	@data: where to store the queue contents
+ *	@n: capacity of @data in 32-bit words
+ *
+ *	Reads the contents of the selected CIM queue starting at address 0 up
+ *	to the capacity of @data.  @n must be a multiple of 4.  Returns < 0 on
+ *	error and the number of 32-bit words actually read on success.
+ */
+static int csio_hw_read_cim_obq(struct csio_hw *hw, unsigned int qid,
+				uint32_t *data, size_t n)
+{
+	int i, err;
+	unsigned int addr, v, nwords;
+	int cim_num_obq = CIM_NUM_OBQ_T5;
+
+	if ((qid > (cim_num_obq - 1)) || (n & 3))
+		return -EINVAL;
+
+	csio_wr_reg32(hw, OBQSELECT_F | QUENUMSELECT_V(qid),
+			CIM_QUEUE_CONFIG_REF_A);
+	v = csio_rd_reg32(hw, CIM_QUEUE_CONFIG_CTRL_A);
+
+	addr = CIMQBASE_G(v) * 64;    /* muliple of 256 -> muliple of 4 */
+	nwords = CIMQSIZE_G(v) * 64;  /* same */
+	if (n > nwords)
+		n = nwords;
+
+	for (i = 0; i < n; i++, addr++) {
+		csio_wr_reg32(hw, OBQDBGADDR_V(addr) | OBQDBGEN_F,
+				CIM_OBQ_DBG_CFG_A);
+		err = csio_hw_wait_op_done(hw, CIM_OBQ_DBG_CFG_A, OBQDBGBUSY_F,
+					0, 2, 1);
+		if (err)
+			return err;
+		*data++ = csio_rd_reg32(hw, CIM_OBQ_DBG_DATA_A);
+	}
+	csio_wr_reg32(hw, 0, CIM_OBQ_DBG_CFG_A);
+	return i;
+}
+
+/**
+ *	csio_hw_cim_read - read a block from CIM internal address space
+ *	@hw: the adapter
+ *	@addr: the start address within the CIM address space
+ *	@n: number of words to read
+ *	@valp: where to store the result
+ *
+ *	Reads a block of 4-byte words from the CIM intenal address space.
+ */
+static int csio_hw_cim_read(struct csio_hw *hw, unsigned int addr,
+			unsigned int n, unsigned int *valp)
+{
+	int ret = 0;
+
+	if (csio_rd_reg32(hw, CIM_HOST_ACC_CTRL_A) & HOSTBUSY_F)
+		return -EBUSY;
+
+	for ( ; !ret && n--; addr += 4) {
+		csio_wr_reg32(hw, addr, CIM_HOST_ACC_CTRL_A);
+		ret = csio_hw_wait_op_done(hw, CIM_HOST_ACC_CTRL_A, HOSTBUSY_F,
+					0, 5, 2);
+
+		if (!ret)
+			*valp++ = csio_rd_reg32(hw, CIM_HOST_ACC_DATA_A);
+	}
+
+	return ret;
+}
+
+/**
+ *	csio_hw_cim_write - write a block into CIM internal address space
+ *	@hw: the adapter
+ *	@addr: the start address within the CIM address space
+ *	@n: number of words to write
+ *	@valp: set of values to write
+ *
+ *	Writes a block of 4-byte words into the CIM intenal address space.
+ */
+static int csio_hw_cim_write(struct csio_hw *hw, unsigned int addr,
+			unsigned int n, const unsigned int *valp)
+{
+	int ret = 0;
+
+	if (csio_rd_reg32(hw, CIM_HOST_ACC_CTRL_A) & HOSTBUSY_F)
+		return -EBUSY;
+
+	for ( ; !ret && n--; addr += 4) {
+		csio_wr_reg32(hw, *valp++, CIM_HOST_ACC_DATA_A);
+		csio_wr_reg32(hw, addr | HOSTWRITE_F, CIM_HOST_ACC_CTRL_A);
+		ret = csio_hw_wait_op_done(hw, CIM_HOST_ACC_CTRL_A, HOSTBUSY_F,
+				      0, 5, 2);
+	}
+	return ret;
+}
+
+static int csio_hw_cim_write1(struct csio_hw *hw, unsigned int addr,
+			 unsigned int val)
+{
+	return csio_hw_cim_write(hw, addr, 1, &val);
+}
+
+/**
+ *	csio_hw_cim_read_la - read CIM LA capture buffer
+ *	@hw: the adapter
+ *	@la_buf: where to store the LA data
+ *	@wrptr: the HW write pointer within the capture buffer
+ *
+ *	Reads the contents of the CIM LA buffer with the most recent entry at
+ *	the end	of the returned data and with the entry at @wrptr first.
+ *	We try to leave the LA in the running state we find it in.
+ */
+static int csio_hw_cim_read_la(struct csio_hw *hw, uint32_t *la_buf,
+			unsigned int *wrptr)
+{
+	int i, ret;
+	unsigned int cfg, val, idx;
+
+	ret = csio_hw_cim_read(hw, UP_UP_DBG_LA_CFG_A, 1, &cfg);
+	if (ret)
+		return ret;
+
+	if (cfg & UPDBGLAEN_F) {	/* LA is running, freeze it */
+		ret = csio_hw_cim_write1(hw, UP_UP_DBG_LA_CFG_A, 0);
+		if (ret)
+			return ret;
+	}
+
+	ret = csio_hw_cim_read(hw, UP_UP_DBG_LA_CFG_A, 1, &val);
+	if (ret)
+		goto restart;
+
+	idx = UPDBGLAWRPTR_G(val);
+	if (wrptr)
+		*wrptr = idx;
+
+	for (i = 0; i < hw->params.cim_la_size; i++) {
+		ret = csio_hw_cim_write1(hw, UP_UP_DBG_LA_CFG_A,
+				    UPDBGLARDPTR_V(idx) | UPDBGLARDEN_F);
+		if (ret)
+			break;
+		ret = csio_hw_cim_read(hw, UP_UP_DBG_LA_CFG_A, 1, &val);
+		if (ret)
+			break;
+		if (val & UPDBGLARDEN_F) {
+			ret = -ETIMEDOUT;
+			break;
+		}
+		ret = csio_hw_cim_read(hw, UP_UP_DBG_LA_DATA_A, 1, &la_buf[i]);
+		if (ret)
+			break;
+		idx = (idx + 1) & UPDBGLARDPTR_M;
+	}
+restart:
+	if (cfg & UPDBGLAEN_F) {
+		int r = csio_hw_cim_write1(hw, UP_UP_DBG_LA_CFG_A,
+				      cfg & ~UPDBGLARDEN_F);
+		if (!ret)
+			ret = r;
+	}
+	return ret;
+}
+
+static int cim_la_show(struct seq_file *seq, void *v, int idx)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "Status   Data      PC     LS0Stat  LS0Addr "
+			"            LS0Data\n");
+	else {
+		const uint32_t *p = v;
+
+		seq_printf(seq,
+			"  %02x  %x%07x %x%07x  %08x %08x %08x%08x%08x%08x\n",
+			(p[0] >> 4) & 0xff, p[0] & 0xf, p[1] >> 4,
+			p[1] & 0xf, p[2] >> 4, p[2] & 0xf, p[3], p[4], p[5],
+			p[6], p[7]);
+	}
+	return 0;
+}
+
+static int cim_la_show_3in1(struct seq_file *seq, void *v, int idx)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Status   Data      PC\n");
+	} else {
+		const uint32_t *p = v;
+
+		seq_printf(seq, "  %02x   %08x %08x\n", p[5] & 0xff, p[6],
+			p[7]);
+		seq_printf(seq, "  %02x   %02x%06x %02x%06x\n",
+			(p[3] >> 8) & 0xff, p[3] & 0xff, p[4] >> 8,
+			p[4] & 0xff, p[5] >> 8);
+		seq_printf(seq, "  %02x   %x%07x %x%07x\n", (p[0] >> 4) & 0xff,
+			p[0] & 0xf, p[1] >> 4, p[1] & 0xf, p[2] >> 4);
+	}
+	return 0;
+}
+
+static int cim_la_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	unsigned int cfg;
+	struct seq_tab *p;
+	struct csio_hw *hw = inode->i_private;
+
+	ret = csio_hw_cim_read(hw, UP_UP_DBG_LA_CFG_A, 1, &cfg);
+	if (ret)
+		return ret;
+
+	p = seq_open_tab(file, hw->params.cim_la_size / 8, 8 * sizeof(uint32_t),
+		1, cfg & UPDBGLACAPTPCONLY_F ? cim_la_show_3in1 : cim_la_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret = csio_hw_cim_read_la(hw, (uint32_t *)p->data, NULL);
+	if (ret)
+		seq_release_private(inode, file);
+	return ret;
+}
+
+static const struct file_operations cim_la_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_la_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
+static int cim_qcfg_show(struct seq_file *seq, void *v)
+{
+	static const char * const qname[] = {
+		"TP0", "TP1", "ULP", "SGE0", "SGE1", "NC-SI",
+		"ULP0", "ULP1", "ULP2", "ULP3", "SGE", "NC-SI",
+		"SGE0-RX", "SGE1-RX"
+	};
+
+	int i;
+	struct csio_hw *hw = seq->private;
+	uint16_t base[CIM_NUM_IBQ + CIM_NUM_OBQ_T5];
+	uint16_t size[CIM_NUM_IBQ + CIM_NUM_OBQ_T5];
+	uint32_t stat[(4 * (CIM_NUM_IBQ + CIM_NUM_OBQ_T5))];
+	uint16_t thres[CIM_NUM_IBQ];
+	uint32_t obq_wr_t5[2 * CIM_NUM_OBQ_T5], *wr;
+	uint32_t *p = stat;
+	int cim_num_obq = CIM_NUM_OBQ_T5;
+
+	i = csio_hw_cim_read(hw, UP_IBQ_0_SHADOW_RDADDR_A, ARRAY_SIZE(stat),
+				stat);
+	if (!i) {
+		i = csio_hw_cim_read(hw, UP_OBQ_0_SHADOW_REALADDR_A,
+				ARRAY_SIZE(obq_wr_t5), obq_wr_t5);
+		wr = obq_wr_t5;
+	}
+	if (i)
+		return i;
+
+	csio_hw_read_cimq_cfg(hw, base, size, thres);
+
+	seq_printf(seq,
+		   "  Queue  Base  Size Thres  RdPtr WrPtr  SOP  EOP Avail\n");
+	for (i = 0; i < CIM_NUM_IBQ; i++, p += 4)
+		seq_printf(seq, "%7s %5x %5u %5u %6x  %4x %4u %4u %5u\n",
+			   qname[i], base[i], size[i], thres[i],
+			   IBQRDADDR_G(p[0]), IBQWRADDR_G(p[1]),
+			   QUESOPCNT_G(p[3]), QUEEOPCNT_G(p[3]),
+			   QUEREMFLITS_G(p[2]) * 16);
+	for ( ; i < CIM_NUM_IBQ + cim_num_obq; i++, p += 4, wr += 2)
+		seq_printf(seq, "%7s %5x %5u %12x  %4x %4u %4u %5u\n",
+			   qname[i], base[i], size[i],
+			   QUERDADDR_G(p[0]) & 0x3fff, wr[0] - base[i],
+			   QUESOPCNT_G(p[3]), QUEEOPCNT_G(p[3]),
+			   QUEREMFLITS_G(p[2]) * 16);
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(cim_qcfg);
+
+static int cimq_show(struct seq_file *seq, void *v, int idx)
+{
+	const uint32_t *p = v;
+
+	seq_printf(seq, "%#06x: %08x %08x %08x %08x\n", idx * 16, p[0], p[1],
+		   p[2], p[3]);
+	return 0;
+}
+
+static int cim_ibq_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	struct seq_tab *p;
+	unsigned int qid = (uintptr_t)inode->i_private & 7;
+	struct csio_hw *hw = inode->i_private - qid;
+
+	p = seq_open_tab(file, CIM_IBQ_SIZE, 4 * sizeof(uint32_t),
+			0, cimq_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret = csio_hw_read_cim_ibq(hw, qid, (uint32_t *)p->data,
+			CIM_IBQ_SIZE * 4);
+	if (ret < 0)
+		seq_release_private(inode, file);
+	else
+		ret = 0;
+	return ret;
+}
+
+static const struct file_operations cim_ibq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_ibq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
+static int cim_obq_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	struct seq_tab *p;
+	unsigned int qid = (uintptr_t)inode->i_private & 7;
+	struct csio_hw *hw = inode->i_private - qid;
+
+	p = seq_open_tab(file, 6 * CIM_OBQ_SIZE, 4 * sizeof(uint32_t),
+			0, cimq_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret = csio_hw_read_cim_obq(hw, qid, (uint32_t *)p->data,
+			6 * CIM_OBQ_SIZE * 4);
+	if (ret < 0) {
+		seq_release_private(inode, file);
+	} else {
+		seq_tab_trim(p, ret / 4);
+		ret = 0;
+	}
+	return ret;
+}
+
+static const struct file_operations cim_obq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_obq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
+/**
+ *      csio_hw_get_fcoe_stats - read TP's FCoE MIB counters for a port
+ *      @adap: the adapter
+ *      @idx: the port index
+ *      @st: holds the counter values
+ *
+ *      Returns the values of TP's FCoE counters for the selected port.
+ */
+static void csio_hw_get_fcoe_stats(struct csio_hw *hw, unsigned int idx,
+				struct tp_fcoe_stats *st)
+{
+	uint32_t val[2];
+
+	csio_hw_read_indirect(hw, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			&st->frames_ddp, 1, TP_MIB_FCOE_DDP_0_A + idx);
+	csio_hw_read_indirect(hw, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			&st->frames_drop, 1, TP_MIB_FCOE_DROP_0_A + idx);
+	csio_hw_read_indirect(hw, TP_MIB_INDEX_A, TP_MIB_DATA_A, val,
+			2, TP_MIB_FCOE_BYTE_0_HI_A + 2 * idx);
+	st->octets_ddp = ((uint64_t)val[0] << 32) | val[1];
+}
+
+static int fcoe_stats_show(struct seq_file *seq, void *v)
+{
+	struct tp_fcoe_stats stats[4];
+	struct csio_hw *hw = seq->private;
+
+	spin_lock(&hw->stats_lock);
+	csio_hw_get_fcoe_stats(hw, 0, &stats[0]);
+	csio_hw_get_fcoe_stats(hw, 1, &stats[1]);
+	csio_hw_get_fcoe_stats(hw, 2, &stats[2]);
+	csio_hw_get_fcoe_stats(hw, 3, &stats[3]);
+	spin_unlock(&hw->stats_lock);
+
+	seq_puts(seq, "                   channel 0        "
+		"channel 1        channel 2        channel 3\n");
+	seq_printf(seq, "octetsDDP:  %16llu %16llu %16llu %16llu\n",
+			stats[0].octets_ddp, stats[1].octets_ddp,
+			stats[2].octets_ddp, stats[3].octets_ddp);
+	seq_printf(seq, "framesDDP:  %16u %16u %16u %16u\n",
+			stats[0].frames_ddp, stats[1].frames_ddp,
+			stats[2].frames_ddp, stats[3].frames_ddp);
+	seq_printf(seq, "framesDrop: %16u %16u %16u %16u\n",
+			stats[0].frames_drop, stats[1].frames_drop,
+			stats[2].frames_drop, stats[3].frames_drop);
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(fcoe_stats);
+
+/*
+ * Sequential File Operations for Device Log.
+ */
+static inline void *devlog_get_idx(struct devlog_info *dinfo, loff_t pos)
+{
+	if (pos > dinfo->nentries)
+		return NULL;
+
+	return (void *)(uintptr_t)(pos + 1);
+}
+
+static void *devlog_start(struct seq_file *seq, loff_t *pos)
+{
+	struct devlog_info *dinfo = seq->private;
+
+	return (*pos
+		? devlog_get_idx(dinfo, *pos)
+		: SEQ_START_TOKEN);
+}
+
+static void *devlog_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct devlog_info *dinfo = seq->private;
+
+	(*pos)++;
+	return devlog_get_idx(dinfo, *pos);
+}
+
+static void devlog_stop(struct seq_file *seq, void *v)
+{
+}
+
+static int devlog_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_printf(seq, "%10s  %15s  %8s  %8s  %s\n",
+			   "Seq#", "Tstamp", "Level", "Facility", "Message");
+	else {
+		struct devlog_info *dinfo = seq->private;
+		int fidx = (uintptr_t)v - 2;
+		unsigned long index;
+		struct fw_devlog_e *e;
+
+		/*
+		 * Get a pointer to the log entry to display.  Skip unused log
+		 * entries.
+		 */
+		index = dinfo->first + fidx;
+		if (index >= dinfo->nentries)
+			index -= dinfo->nentries;
+		e = &dinfo->log[index];
+		if (e->timestamp == 0)
+			return 0;
+
+		/*
+		 * Print the message.  This depends on the firmware using
+		 * exactly the same formating strings as the kernel so we may
+		 * eventually have to put a format interpreter in here ...
+		 */
+		seq_printf(seq, "%10d  %15llu  %8s  %8s  ",
+			   e->seqno, e->timestamp,
+			   (e->level < ARRAY_SIZE(devlog_level_strings)
+			    ? devlog_level_strings[e->level]
+			    : "UNKNOWN"),
+			   (e->facility < ARRAY_SIZE(devlog_facility_strings)
+			    ? devlog_facility_strings[e->facility]
+			    : "UNKNOWN"));
+		seq_printf(seq, e->fmt, e->params[0], e->params[1],
+			   e->params[2], e->params[3], e->params[4],
+			   e->params[5], e->params[6], e->params[7]);
+	}
+
+	return 0;
+}
+
+static const struct seq_operations devlog_seq_ops = {
+	.start = devlog_start,
+	.next  = devlog_next,
+	.stop  = devlog_stop,
+	.show  = devlog_show
+};
+
+/*
+ * Set up for reading the firmware's device log.  We read the entire log here
+ * and then display it incrementally in devlog_show().
+ */
+static int devlog_open(struct inode *inode, struct file *file)
+{
+	struct csio_hw *hw = inode->i_private;
+	struct devlog_params *dparams = &hw->devlog;
+	struct devlog_info *dinfo;
+	unsigned int index;
+	u32 fseqno;
+	int ret;
+
+	/*
+	 * If we don't know where the log is we can't do anything.
+	 */
+	if (dparams->start == 0)
+		return -ENXIO;
+
+	/*
+	 * Allocate the space to read in the firmware's device log and set up
+	 * for the iterated call to our display function.
+	 */
+	dinfo = __seq_open_private(file, &devlog_seq_ops,
+				   sizeof(*dinfo) + dparams->size);
+	if (dinfo == NULL)
+		return -ENOMEM;
+
+	/*
+	 * Record the basic log buffer information and read in the raw log.
+	 */
+	dinfo->nentries = (dparams->size / sizeof(struct fw_devlog_e));
+	dinfo->first = 0;
+	ret = csio_hw_mem_read(hw, dparams->memtype, dparams->start,
+			  dparams->size, (unsigned int *)dinfo->log);
+	if (ret < 0) {
+		seq_release_private(inode, file);
+		return ret;
+	}
+
+	/*
+	 * Translate log multi-byte integral elements into host native format
+	 * and determine where the first entry in the log is.
+	 */
+	for (fseqno = ~((u32)0), index = 0; index < dinfo->nentries; index++) {
+		struct fw_devlog_e *e = &dinfo->log[index];
+		int i;
+		__u32 seqno;
+
+		if (e->timestamp == 0)
+			continue;
+
+		e->timestamp = (__force __be64)be64_to_cpu(e->timestamp);
+		seqno = be32_to_cpu(e->seqno);
+		for (i = 0; i < 8; i++)
+			e->params[i] =
+				(__force __be32)be32_to_cpu(e->params[i]);
+
+		if (seqno < fseqno) {
+			fseqno = seqno;
+			dinfo->first = index;
+		}
+	}
+
+	return 0;
+}
+
+static const struct file_operations devlog_fops = {
+	.owner   = THIS_MODULE,
+	.open    = devlog_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
+static ssize_t
+csio_mem_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
+{
+	loff_t pos = *ppos;
+	loff_t avail = file_inode(file)->i_size;
+	unsigned int mem = (uintptr_t)file->private_data & 3;
+	struct csio_hw *hw = file->private_data - mem;
+
+	if (pos < 0)
+		return -EINVAL;
+	if (pos >= avail)
+		return 0;
+	if (count > avail - pos)
+		count = avail - pos;
+
+	while (count) {
+		size_t len;
+		int ret, ofst;
+		__be32 data[16];
+
+		if (mem == MEM_MC)
+			ret = hw->chip_ops->chip_mc_read(hw, 0, pos,
+							 data, NULL);
+		else
+			ret = hw->chip_ops->chip_edc_read(hw, mem, pos,
+							  data, NULL);
+		if (ret)
+			return ret;
+
+		ofst = pos % sizeof(data);
+		len = min(count, sizeof(data) - ofst);
+		if (copy_to_user(buf, (u8 *)data + ofst, len))
+			return -EFAULT;
+
+		buf += len;
+		pos += len;
+		count -= len;
+	}
+	count = pos - *ppos;
+	*ppos = pos;
+	return count;
+}
+
+static const struct file_operations csio_mem_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = simple_open,
+	.read    = csio_mem_read,
+	.llseek  = default_llseek,
+};
+
+static void
+csio_crt_debugfs_file(struct csio_hw *hw, struct csio_debugfs_entry entry)
+{
+	debugfs_create_file_size(entry.name, entry.mode, hw->debugfs_root,
+			(void *)hw + entry.data, entry.ops, (5 << 20));
+}
+
+static void
+csio_add_debugfs_files(struct csio_hw *hw)
+{
+	int i;
+
+	static struct csio_debugfs_entry csio_debugfs_files[] = {
+		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
+		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
+		{ "devlog", &devlog_fops, S_IRUSR, 0 },
+		{ "ibq_tp0",  &cim_ibq_fops, S_IRUSR, 0 },
+		{ "ibq_tp1",  &cim_ibq_fops, S_IRUSR, 1 },
+		{ "ibq_ulp",  &cim_ibq_fops, S_IRUSR, 2 },
+		{ "ibq_sge0", &cim_ibq_fops, S_IRUSR, 3 },
+		{ "ibq_sge1", &cim_ibq_fops, S_IRUSR, 4 },
+		{ "ibq_ncsi", &cim_ibq_fops, S_IRUSR, 5 },
+		{ "obq_ulp0", &cim_obq_fops, S_IRUSR, 0 },
+		{ "obq_ulp1", &cim_obq_fops, S_IRUSR, 1 },
+		{ "obq_ulp2", &cim_obq_fops, S_IRUSR, 2 },
+		{ "obq_ulp3", &cim_obq_fops, S_IRUSR, 3 },
+		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
+		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
+		{ "obq_sge_rx_q0", &cim_obq_fops, S_IRUSR, 6 },
+		{ "obq_sge_rx_q1", &cim_obq_fops, S_IRUSR, 7 },
+		{ "fcoe_stats", &fcoe_stats_fops, S_IRUSR, 0 },
+	};
+
+	for (i = 0; i < ARRAY_SIZE(csio_debugfs_files); i++)
+		csio_crt_debugfs_file(hw, csio_debugfs_files[i]);
+}
+
+void csio_add_debugfs_mem(struct csio_hw *hw, const char *name,
+				 unsigned int idx, unsigned int size_mb)
+{
+	debugfs_create_file_size(name, S_IRUSR, hw->debugfs_root,
+				 (void *)hw + idx, &csio_mem_debugfs_fops,
+				 size_mb << 20);
+}
+
+static int csio_setup_debugfs(struct csio_hw *hw)
+{
+	int i;
+
+	if (IS_ERR_OR_NULL(hw->debugfs_root))
+		return -1;
+
+	/* debugfs support is best effort */
+	csio_add_debugfs_files(hw);
+
+	i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE_A);
+	if (i & EDRAM0_ENABLE_F)
+		csio_add_debugfs_mem(hw, "edc0", MEM_EDC0, 5);
+	if (i & EDRAM1_ENABLE_F)
+		csio_add_debugfs_mem(hw, "edc1", MEM_EDC1, 5);
+
+	hw->chip_ops->chip_dfs_create_ext_mem(hw);
+	return 0;
+}
+
+/*
+ * csio_dfs_create - Creates and sets up per-hw debugfs.
+ *
+ */
+int
+csio_dfs_create(struct csio_hw *hw)
+{
+	if (csio_debugfs_root) {
+		hw->debugfs_root = debugfs_create_dir(pci_name(hw->pdev),
+							csio_debugfs_root);
+		csio_setup_debugfs(hw);
+	}
+
+	return 0;
+}
+
+/*
+ * csio_dfs_destroy - Destroys per-hw debugfs.
+ */
+int
+csio_dfs_destroy(struct csio_hw *hw)
+{
+	debugfs_remove_recursive(hw->debugfs_root);
+
+	return 0;
+}
+
+/*
+ * csio_dfs_init - Debug filesystem initialization for the module.
+ *
+ */
+int
+csio_dfs_init(void)
+{
+	csio_debugfs_root = debugfs_create_dir(KBUILD_MODNAME, NULL);
+	if (!csio_debugfs_root)
+		pr_warn("Could not create debugfs entry, continuing\n");
+
+	return 0;
+}
+
+/*
+ * csio_dfs_exit - debugfs cleanup for the module.
+ */
+void
+csio_dfs_exit(void)
+{
+	debugfs_remove(csio_debugfs_root);
+}
-- 
2.0.2
