From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: Add cxgb4_debugfs.c and devlog support
Date: Thu, 16 Oct 2014 06:52:01 +0530
Message-ID: <1413422524-14054-2-git-send-email-hariprasad@chelsio.com>
References: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46060
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750820AbaJPBQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:16:32 -0400
In-Reply-To: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the debugfs stuff is moved to cxgb4_debugfs.c.
Also add support for device log entry in debugfs

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    9 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  358 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |   52 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  121 ++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   12 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   72 ++++
 7 files changed, 532 insertions(+), 94 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index 1df65c9..de34d4b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,5 +4,5 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o cxgb4_debugfs.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 410ed58..081b7ef 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -284,10 +284,18 @@ enum chip_type {
 	T5_LAST_REV	= T5_A1,
 };
 
+struct devlog_params {
+	u32 memtype;                    /* which memory (EDC0, EDC1, MC) */
+	u32 start;                      /* start of log in firmware memory */
+	u32 size;                       /* size of log */
+};
+
 struct adapter_params {
 	struct tp_params  tp;
 	struct vpd_params vpd;
 	struct pci_params pci;
+	struct devlog_params devlog;
+	enum pcie_memwin drv_memwin;
 
 	unsigned int sf_size;             /* serial flash size in bytes */
 	unsigned int sf_nsec;             /* # of flash sectors */
@@ -1083,4 +1091,5 @@ void t4_db_dropped(struct adapter *adapter);
 int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 			 u32 addr, u32 val);
 void t4_sge_decode_idma_state(struct adapter *adapter, int state);
+void t4_free_mem(void *addr);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
new file mode 100644
index 0000000..0704af5
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -0,0 +1,358 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
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
+#include <linux/seq_file.h>
+#include <linux/debugfs.h>
+#include <linux/string_helpers.h>
+#include <linux/sort.h>
+
+#include "cxgb4.h"
+#include "t4_regs.h"
+#include "t4fw_api.h"
+#include "cxgb4_debugfs.h"
+#include "l2t.h"
+
+/* Firmware Device Log dump.
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
+/* Information gathered by Device Log Open routine for the display routine.
+ */
+struct devlog_info {
+	unsigned int nentries;		/* number of entries in log[] */
+	unsigned int first;		/* first [temporal] entry in log[] */
+	struct fw_devlog_e log[0];	/* Firmware Device Log */
+};
+
+/* Dump a Firmaware Device Log entry.
+ */
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
+		/* Get a pointer to the log entry to display.  Skip unused log
+		 * entries.
+		 */
+		index = dinfo->first + fidx;
+		if (index >= dinfo->nentries)
+			index -= dinfo->nentries;
+		e = &dinfo->log[index];
+		if (e->timestamp == 0)
+			return 0;
+
+		/* Print the message.  This depends on the firmware using
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
+/* Sequential File Operations for Device Log.
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
+static const struct seq_operations devlog_seq_ops = {
+	.start = devlog_start,
+	.next  = devlog_next,
+	.stop  = devlog_stop,
+	.show  = devlog_show
+};
+
+/* Set up for reading the firmware's device log.  We read the entire log here
+ * and then display it incrementally in devlog_show().
+ */
+static int devlog_open(struct inode *inode, struct file *file)
+{
+	struct adapter *adap = inode->i_private;
+	struct devlog_params *dparams = &adap->params.devlog;
+	struct devlog_info *dinfo;
+	unsigned int index;
+	u32 fseqno;
+	int ret;
+
+	/* If we don't know where the log is we can't do anything.
+	 */
+	if (dparams->start == 0)
+		return -ENXIO;
+
+	/* Allocate the space to read in the firmware's device log and set up
+	 * for the iterated call to our display function.
+	 */
+	dinfo = __seq_open_private(file, &devlog_seq_ops,
+				   sizeof(*dinfo) + dparams->size);
+	if (dinfo == NULL)
+		return -ENOMEM;
+
+	/* Record the basic log buffer information and read in the raw log.
+	 */
+	dinfo->nentries = (dparams->size / sizeof(struct fw_devlog_e));
+	dinfo->first = 0;
+	spin_lock(&adap->win0_lock);
+	ret = t4_memory_rw(adap, adap->params.drv_memwin, dparams->memtype,
+			   dparams->start, dparams->size, (__be32 *)dinfo->log,
+			   T4_MEMORY_READ);
+	spin_unlock(&adap->win0_lock);
+	if (ret) {
+		seq_release_private(inode, file);
+		return ret;
+	}
+
+	/* Translate log multi-byte integral elements into host native format
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
+static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
+			loff_t *ppos)
+{
+	loff_t pos = *ppos;
+	loff_t avail = file_inode(file)->i_size;
+	unsigned int mem = (uintptr_t)file->private_data & 3;
+	struct adapter *adap = file->private_data - mem;
+	__be32 *data;
+	int ret;
+
+	if (pos < 0)
+		return -EINVAL;
+	if (pos >= avail)
+		return 0;
+	if (count > avail - pos)
+		count = avail - pos;
+
+	data = t4_alloc_mem(count);
+	if (!data)
+		return -ENOMEM;
+
+	spin_lock(&adap->win0_lock);
+	ret = t4_memory_rw(adap, 0, mem, pos, count, data, T4_MEMORY_READ);
+	spin_unlock(&adap->win0_lock);
+	if (ret) {
+		t4_free_mem(data);
+		return ret;
+	}
+	ret = copy_to_user(buf, data, count);
+
+	t4_free_mem(data);
+	if (ret)
+		return -EFAULT;
+
+	*ppos = pos + count;
+	return count;
+}
+
+static const struct file_operations mem_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = simple_open,
+	.read    = mem_read,
+	.llseek  = default_llseek,
+};
+
+static void add_debugfs_mem(struct adapter *adap, const char *name,
+			    unsigned int idx, unsigned int size_mb)
+{
+	struct dentry *de;
+
+	de = debugfs_create_file(name, S_IRUSR, adap->debugfs_root,
+				 (void *)adap + idx, &mem_debugfs_fops);
+	if (de && de->d_inode)
+		de->d_inode->i_size = size_mb << 20;
+}
+
+/* Add an array of Debug FS files.
+ */
+void add_debugfs_files(struct adapter *adap,
+		       struct t4_debugfs_entry *files,
+		       unsigned int nfiles)
+{
+	int i;
+
+	/* debugfs support is best effort */
+	for (i = 0; i < nfiles; i++)
+		debugfs_create_file(files[i].name, files[i].mode,
+				    adap->debugfs_root,
+				    (void *)adap + files[i].data,
+				    files[i].ops);
+}
+
+int t4_setup_debugfs(struct adapter *adap)
+{
+	int i;
+	u32 size;
+
+	static struct t4_debugfs_entry t4_debugfs_files[] = {
+		{ "devlog", &devlog_fops, S_IRUSR, 0 },
+		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
+	};
+
+	add_debugfs_files(adap,
+			  t4_debugfs_files,
+			  ARRAY_SIZE(t4_debugfs_files));
+
+	i = t4_read_reg(adap, MA_TARGET_MEM_ENABLE);
+	if (i & EDRAM0_ENABLE) {
+		size = t4_read_reg(adap, MA_EDRAM0_BAR);
+		add_debugfs_mem(adap, "edc0", MEM_EDC0, EDRAM_SIZE_GET(size));
+	}
+	if (i & EDRAM1_ENABLE) {
+		size = t4_read_reg(adap, MA_EDRAM1_BAR);
+		add_debugfs_mem(adap, "edc1", MEM_EDC1, EDRAM_SIZE_GET(size));
+	}
+	if (is_t4(adap->params.chip)) {
+		size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
+		if (i & EXT_MEM_ENABLE)
+			add_debugfs_mem(adap, "mc", MEM_MC,
+					EXT_MEM_SIZE_GET(size));
+	} else {
+		if (i & EXT_MEM_ENABLE) {
+			size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
+			add_debugfs_mem(adap, "mc0", MEM_MC0,
+					EXT_MEM_SIZE_GET(size));
+		}
+		if (i & EXT_MEM1_ENABLE) {
+			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR);
+			add_debugfs_mem(adap, "mc1", MEM_MC1,
+					EXT_MEM_SIZE_GET(size));
+		}
+	}
+	return 0;
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
new file mode 100644
index 0000000..a3d8867
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h
@@ -0,0 +1,52 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CXGB4_DEBUGFS_H
+#define __CXGB4_DEBUGFS_H
+
+#include <linux/export.h>
+
+struct t4_debugfs_entry {
+	const char *name;
+	const struct file_operations *ops;
+	mode_t mode;
+	unsigned char data;
+};
+
+int t4_setup_debugfs(struct adapter *adap);
+void add_debugfs_files(struct adapter *adap,
+		       struct t4_debugfs_entry *files,
+		       unsigned int nfiles);
+
+#endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5b38e95..645defa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -68,6 +68,7 @@
 #include "t4_msg.h"
 #include "t4fw_api.h"
 #include "cxgb4_dcb.h"
+#include "cxgb4_debugfs.h"
 #include "l2t.h"
 
 #include <../drivers/net/bonding/bonding.h>
@@ -1283,7 +1284,7 @@ void *t4_alloc_mem(size_t size)
 /*
  * Free memory allocated through alloc_mem().
  */
-static void t4_free_mem(void *addr)
+void t4_free_mem(void *addr)
 {
 	if (is_vmalloc_addr(addr))
 		vfree(addr);
@@ -3113,103 +3114,12 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.flash_device      = set_flash,
 };
 
-/*
- * debugfs support
- */
-static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
-			loff_t *ppos)
-{
-	loff_t pos = *ppos;
-	loff_t avail = file_inode(file)->i_size;
-	unsigned int mem = (uintptr_t)file->private_data & 3;
-	struct adapter *adap = file->private_data - mem;
-	__be32 *data;
-	int ret;
-
-	if (pos < 0)
-		return -EINVAL;
-	if (pos >= avail)
-		return 0;
-	if (count > avail - pos)
-		count = avail - pos;
-
-	data = t4_alloc_mem(count);
-	if (!data)
-		return -ENOMEM;
-
-	spin_lock(&adap->win0_lock);
-	ret = t4_memory_rw(adap, 0, mem, pos, count, data, T4_MEMORY_READ);
-	spin_unlock(&adap->win0_lock);
-	if (ret) {
-		t4_free_mem(data);
-		return ret;
-	}
-	ret = copy_to_user(buf, data, count);
-
-	t4_free_mem(data);
-	if (ret)
-		return -EFAULT;
-
-	*ppos = pos + count;
-	return count;
-}
-
-static const struct file_operations mem_debugfs_fops = {
-	.owner   = THIS_MODULE,
-	.open    = simple_open,
-	.read    = mem_read,
-	.llseek  = default_llseek,
-};
-
-static void add_debugfs_mem(struct adapter *adap, const char *name,
-			    unsigned int idx, unsigned int size_mb)
-{
-	struct dentry *de;
-
-	de = debugfs_create_file(name, S_IRUSR, adap->debugfs_root,
-				 (void *)adap + idx, &mem_debugfs_fops);
-	if (de && de->d_inode)
-		de->d_inode->i_size = size_mb << 20;
-}
-
 static int setup_debugfs(struct adapter *adap)
 {
-	int i;
-	u32 size;
-
 	if (IS_ERR_OR_NULL(adap->debugfs_root))
 		return -1;
 
-	i = t4_read_reg(adap, MA_TARGET_MEM_ENABLE);
-	if (i & EDRAM0_ENABLE) {
-		size = t4_read_reg(adap, MA_EDRAM0_BAR);
-		add_debugfs_mem(adap, "edc0", MEM_EDC0,	EDRAM_SIZE_GET(size));
-	}
-	if (i & EDRAM1_ENABLE) {
-		size = t4_read_reg(adap, MA_EDRAM1_BAR);
-		add_debugfs_mem(adap, "edc1", MEM_EDC1, EDRAM_SIZE_GET(size));
-	}
-	if (is_t4(adap->params.chip)) {
-		size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
-		if (i & EXT_MEM_ENABLE)
-			add_debugfs_mem(adap, "mc", MEM_MC,
-					EXT_MEM_SIZE_GET(size));
-	} else {
-		if (i & EXT_MEM_ENABLE) {
-			size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
-			add_debugfs_mem(adap, "mc0", MEM_MC0,
-					EXT_MEM_SIZE_GET(size));
-		}
-		if (i & EXT_MEM1_ENABLE) {
-			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR);
-			add_debugfs_mem(adap, "mc1", MEM_MC1,
-					EXT_MEM_SIZE_GET(size));
-		}
-	}
-	if (adap->l2t)
-		debugfs_create_file("l2t", S_IRUSR, adap->debugfs_root, adap,
-				    &t4_l2t_fops);
-	return 0;
+	return t4_setup_debugfs(adap);
 }
 
 /*
@@ -5656,6 +5566,8 @@ static int adap_init0(struct adapter *adap)
 	enum dev_state state;
 	u32 params[7], val[7];
 	struct fw_caps_config_cmd caps_cmd;
+	struct fw_devlog_cmd devlog_cmd;
+	u32 devlog_meminfo;
 	int reset = 1;
 
 	/*
@@ -5744,6 +5656,29 @@ static int adap_init0(struct adapter *adap)
 	if (ret < 0)
 		goto bye;
 
+	/* Read firmware device log parameters.  We really need to find a way
+	 * to get these parameters initialized with some default values (which
+	 * are likely to be correct) for the case where we either don't
+	 * attache to the firmware or it's crashed when we probe the adapter.
+	 * That way we'll still be able to perform early firmware startup
+	 * debugging ...  If the request to get the Firmware's Device Log
+	 * parameters fails, we'll live so we don't make that a fatal error.
+	 */
+	memset(&devlog_cmd, 0, sizeof(devlog_cmd));
+	devlog_cmd.op_to_write = htonl(FW_CMD_OP(FW_DEVLOG_CMD) |
+				       FW_CMD_REQUEST | FW_CMD_READ);
+	devlog_cmd.retval_len16 = htonl(FW_LEN16(devlog_cmd));
+	ret = t4_wr_mbox(adap, adap->mbox, &devlog_cmd, sizeof(devlog_cmd),
+			 &devlog_cmd);
+	if (ret == 0) {
+		devlog_meminfo =
+			ntohl(devlog_cmd.memtype_devlog_memaddr16_devlog);
+		adap->params.devlog.memtype =
+			FW_DEVLOG_CMD_MEMTYPE_DEVLOG_GET(devlog_meminfo);
+		adap->params.devlog.start =
+			FW_DEVLOG_CMD_MEMADDR16_DEVLOG_GET(devlog_meminfo) << 4;
+		adap->params.devlog.size = ntohl(devlog_cmd.memsize_devlog);
+	}
 	/*
 	 * Find out what ports are available to us.  Note that we need to do
 	 * this before calling adap_init0_no_config() since it needs nports
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index c19a90e..5e5eee6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -110,6 +110,18 @@ enum {
 	SGE_INGPADBOUNDARY_SHIFT = 5,/* ingress queue pad boundary */
 };
 
+/* PCI-e memory window access */
+enum pcie_memwin {
+	MEMWIN_NIC      = 0,
+	MEMWIN_RSVD1    = 1,
+	MEMWIN_RSVD2    = 2,
+	MEMWIN_RDMA     = 3,
+	MEMWIN_RSVD4    = 4,
+	MEMWIN_FOISCSI  = 5,
+	MEMWIN_CSIOSTOR = 6,
+	MEMWIN_RSVD7    = 7,
+};
+
 struct sge_qstat {                /* data written to SGE queue status entries */
 	__be32 qid;
 	__be16 cidx;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 3409756..e9ceb3a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -618,6 +618,7 @@ enum fw_cmd_opcodes {
 	FW_RSS_IND_TBL_CMD             = 0x20,
 	FW_RSS_GLB_CONFIG_CMD          = 0x22,
 	FW_RSS_VI_CONFIG_CMD           = 0x23,
+	FW_DEVLOG_CMD                  = 0x25,
 	FW_CLIP_CMD                    = 0x28,
 	FW_LASTC2E_CMD                 = 0x40,
 	FW_ERROR_CMD                   = 0x80,
@@ -2279,4 +2280,75 @@ enum fw_hdr_flags {
 	FW_HDR_FLAGS_RESET_HALT = 0x00000001,
 };
 
+/* length of the formatting string  */
+#define FW_DEVLOG_FMT_LEN	192
+
+/* maximum number of the formatting string parameters */
+#define FW_DEVLOG_FMT_PARAMS_NUM 8
+
+/* priority levels */
+enum fw_devlog_level {
+	FW_DEVLOG_LEVEL_EMERG	= 0x0,
+	FW_DEVLOG_LEVEL_CRIT	= 0x1,
+	FW_DEVLOG_LEVEL_ERR	= 0x2,
+	FW_DEVLOG_LEVEL_NOTICE	= 0x3,
+	FW_DEVLOG_LEVEL_INFO	= 0x4,
+	FW_DEVLOG_LEVEL_DEBUG	= 0x5,
+	FW_DEVLOG_LEVEL_MAX	= 0x5,
+};
+
+/* facilities that may send a log message */
+enum fw_devlog_facility {
+	FW_DEVLOG_FACILITY_CORE		= 0x00,
+	FW_DEVLOG_FACILITY_CF		= 0x01,
+	FW_DEVLOG_FACILITY_SCHED	= 0x02,
+	FW_DEVLOG_FACILITY_TIMER	= 0x04,
+	FW_DEVLOG_FACILITY_RES		= 0x06,
+	FW_DEVLOG_FACILITY_HW		= 0x08,
+	FW_DEVLOG_FACILITY_FLR		= 0x10,
+	FW_DEVLOG_FACILITY_DMAQ		= 0x12,
+	FW_DEVLOG_FACILITY_PHY		= 0x14,
+	FW_DEVLOG_FACILITY_MAC		= 0x16,
+	FW_DEVLOG_FACILITY_PORT		= 0x18,
+	FW_DEVLOG_FACILITY_VI		= 0x1A,
+	FW_DEVLOG_FACILITY_FILTER	= 0x1C,
+	FW_DEVLOG_FACILITY_ACL		= 0x1E,
+	FW_DEVLOG_FACILITY_TM		= 0x20,
+	FW_DEVLOG_FACILITY_QFC		= 0x22,
+	FW_DEVLOG_FACILITY_DCB		= 0x24,
+	FW_DEVLOG_FACILITY_ETH		= 0x26,
+	FW_DEVLOG_FACILITY_OFLD		= 0x28,
+	FW_DEVLOG_FACILITY_RI		= 0x2A,
+	FW_DEVLOG_FACILITY_ISCSI	= 0x2C,
+	FW_DEVLOG_FACILITY_FCOE		= 0x2E,
+	FW_DEVLOG_FACILITY_FOISCSI	= 0x30,
+	FW_DEVLOG_FACILITY_FOFCOE	= 0x32,
+	FW_DEVLOG_FACILITY_MAX		= 0x32,
+};
+
+/* log message format */
+struct fw_devlog_e {
+	__be64	timestamp;
+	__be32	seqno;
+	__be16	reserved1;
+	__u8	level;
+	__u8	facility;
+	__u8	fmt[FW_DEVLOG_FMT_LEN];
+	__be32	params[FW_DEVLOG_FMT_PARAMS_NUM];
+	__be32	reserved3[4];
+};
+
+struct fw_devlog_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	__u8   level;
+	__u8   r2[7];
+	__be32 memtype_devlog_memaddr16_devlog;
+	__be32 memsize_devlog;
+	__be32 r3[2];
+};
+
+#define FW_DEVLOG_CMD_MEMTYPE_DEVLOG_GET(x)	(((x) >> 28) & 0xf)
+#define FW_DEVLOG_CMD_MEMADDR16_DEVLOG_GET(x)	(((x) >> 0) & 0xfffffff)
+
 #endif /* _T4FW_INTERFACE_H_ */
-- 
1.7.1
