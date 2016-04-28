From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4vf: Add support to enable logging of firmware mailbox commands for VF
Date: Thu, 28 Apr 2016 13:23:19 +0530
Message-ID: <1461829999-20270-3-git-send-email-hariprasad@chelsio.com>
References: <1461829999-20270-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:50257 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752432AbcD1HtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 03:49:25 -0400
In-Reply-To: <1461829999-20270-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new /sys/kernel/debug/ support to dump firmware mailbox commands
and replies for debugging purpose.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |   4 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 112 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  29 ++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  72 ++++++++-----
 4 files changed, 192 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 4a707c32d76f..734dd776c22f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -387,6 +387,10 @@ struct adapter {
 	/* various locks */
 	spinlock_t stats_lock;
 
+	/* support for mailbox command/reply logging */
+#define T4VF_OS_LOG_MBOX_CMDS 256
+	struct mbox_cmd_log *mbox_log;
+
 	/* list of MAC addresses in MPS Hash */
 	struct list_head mac_hlist;
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 730fec73d5a6..04fc6f6d1e25 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1704,6 +1704,105 @@ static const struct ethtool_ops cxgb4vf_ethtool_ops = {
  */
 
 /*
+ * Show Firmware Mailbox Command/Reply Log
+ *
+ * Note that we don't do any locking when dumping the Firmware Mailbox Log so
+ * it's possible that we can catch things during a log update and therefore
+ * see partially corrupted log entries.  But i9t's probably Good Enough(tm).
+ * If we ever decide that we want to make sure that we're dumping a coherent
+ * log, we'd need to perform locking in the mailbox logging and in
+ * mboxlog_open() where we'd need to grab the entire mailbox log in one go
+ * like we do for the Firmware Device Log.  But as stated above, meh ...
+ */
+static int mboxlog_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adapter = seq->private;
+	struct mbox_cmd_log *log = adapter->mbox_log;
+	struct mbox_cmd *entry;
+	int entry_idx, i;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq,
+			   "%10s  %15s  %5s  %5s  %s\n",
+			   "Seq#", "Tstamp", "Atime", "Etime",
+			   "Command/Reply");
+		return 0;
+	}
+
+	entry_idx = log->cursor + ((uintptr_t)v - 2);
+	if (entry_idx >= log->size)
+		entry_idx -= log->size;
+	entry = mbox_cmd_log_entry(log, entry_idx);
+
+	/* skip over unused entries */
+	if (entry->timestamp == 0)
+		return 0;
+
+	seq_printf(seq, "%10u  %15llu  %5d  %5d",
+		   entry->seqno, entry->timestamp,
+		   entry->access, entry->execute);
+	for (i = 0; i < MBOX_LEN / 8; i++) {
+		u64 flit = entry->cmd[i];
+		u32 hi = (u32)(flit >> 32);
+		u32 lo = (u32)flit;
+
+		seq_printf(seq, "  %08x %08x", hi, lo);
+	}
+	seq_puts(seq, "\n");
+	return 0;
+}
+
+static inline void *mboxlog_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct adapter *adapter = seq->private;
+	struct mbox_cmd_log *log = adapter->mbox_log;
+
+	return ((pos <= log->size) ? (void *)(uintptr_t)(pos + 1) : NULL);
+}
+
+static void *mboxlog_start(struct seq_file *seq, loff_t *pos)
+{
+	return *pos ? mboxlog_get_idx(seq, *pos) : SEQ_START_TOKEN;
+}
+
+static void *mboxlog_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return mboxlog_get_idx(seq, *pos);
+}
+
+static void mboxlog_stop(struct seq_file *seq, void *v)
+{
+}
+
+static const struct seq_operations mboxlog_seq_ops = {
+	.start = mboxlog_start,
+	.next  = mboxlog_next,
+	.stop  = mboxlog_stop,
+	.show  = mboxlog_show
+};
+
+static int mboxlog_open(struct inode *inode, struct file *file)
+{
+	int res = seq_open(file, &mboxlog_seq_ops);
+
+	if (!res) {
+		struct seq_file *seq = file->private_data;
+
+		seq->private = inode->i_private;
+	}
+	return res;
+}
+
+static const struct file_operations mboxlog_fops = {
+	.owner   = THIS_MODULE,
+	.open    = mboxlog_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+/*
  * Show SGE Queue Set information.  We display QPL Queues Sets per line.
  */
 #define QPL	4
@@ -2122,6 +2221,7 @@ struct cxgb4vf_debugfs_entry {
 };
 
 static struct cxgb4vf_debugfs_entry debugfs_files[] = {
+	{ "mboxlog",    S_IRUGO, &mboxlog_fops },
 	{ "sge_qinfo",  S_IRUGO, &sge_qinfo_debugfs_fops },
 	{ "sge_qstats", S_IRUGO, &sge_qstats_proc_fops },
 	{ "resources",  S_IRUGO, &resources_proc_fops },
@@ -2664,6 +2764,16 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->pdev_dev = &pdev->dev;
 
+	adapter->mbox_log = kzalloc(sizeof(*adapter->mbox_log) +
+				    (sizeof(struct mbox_cmd) *
+				     T4VF_OS_LOG_MBOX_CMDS),
+				    GFP_KERNEL);
+	if (!adapter->mbox_log) {
+		err = -ENOMEM;
+		goto err_free_adapter;
+	}
+	adapter->mbox_log->size = T4VF_OS_LOG_MBOX_CMDS;
+
 	/*
 	 * Initialize SMP data synchronization resources.
 	 */
@@ -2913,6 +3023,7 @@ err_unmap_bar0:
 	iounmap(adapter->regs);
 
 err_free_adapter:
+	kfree(adapter->mbox_log);
 	kfree(adapter);
 
 err_release_regions:
@@ -2982,6 +3093,7 @@ static void cxgb4vf_pci_remove(struct pci_dev *pdev)
 		iounmap(adapter->regs);
 		if (!is_t4(adapter->params.chip))
 			iounmap(adapter->bar2);
+		kfree(adapter->mbox_log);
 		kfree(adapter);
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 9b40a85cc1e4..438374a05791 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -36,6 +36,7 @@
 #ifndef __T4VF_COMMON_H__
 #define __T4VF_COMMON_H__
 
+#include "../cxgb4/t4_hw.h"
 #include "../cxgb4/t4fw_api.h"
 
 #define CHELSIO_CHIP_CODE(version, revision) (((version) << 4) | (revision))
@@ -227,6 +228,34 @@ struct adapter_params {
 	u8 nports;			/* # of Ethernet "ports" */
 };
 
+/* Firmware Mailbox Command/Reply log.  All values are in Host-Endian format.
+ * The access and execute times are signed in order to accommodate negative
+ * error returns.
+ */
+struct mbox_cmd {
+	u64 cmd[MBOX_LEN / 8];		/* a Firmware Mailbox Command/Reply */
+	u64 timestamp;			/* OS-dependent timestamp */
+	u32 seqno;			/* sequence number */
+	s16 access;			/* time (ms) to access mailbox */
+	s16 execute;			/* time (ms) to execute */
+};
+
+struct mbox_cmd_log {
+	unsigned int size;		/* number of entries in the log */
+	unsigned int cursor;		/* next position in the log to write */
+	u32 seqno;			/* next sequence number */
+	/* variable length mailbox command log starts here */
+};
+
+/* Given a pointer to a Firmware Mailbox Command Log and a log entry index,
+ * return a pointer to the specified entry.
+ */
+static inline struct mbox_cmd *mbox_cmd_log_entry(struct mbox_cmd_log *log,
+						  unsigned int entry_idx)
+{
+	return &((struct mbox_cmd *)&(log)[1])[entry_idx];
+}
+
 #include "adapter.h"
 
 #ifndef PCI_VENDOR_ID_CHELSIO
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index fed83d88fc4e..955ff7c61f1b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -76,21 +76,33 @@ static void get_mbox_rpl(struct adapter *adapter, __be64 *rpl, int size,
 		*rpl++ = cpu_to_be64(t4_read_reg64(adapter, mbox_data));
 }
 
-/*
- * Dump contents of mailbox with a leading tag.
+/**
+ *	t4vf_record_mbox - record a Firmware Mailbox Command/Reply in the log
+ *	@adapter: the adapter
+ *	@cmd: the Firmware Mailbox Command or Reply
+ *	@size: command length in bytes
+ *	@access: the time (ms) needed to access the Firmware Mailbox
+ *	@execute: the time (ms) the command spent being executed
  */
-static void dump_mbox(struct adapter *adapter, const char *tag, u32 mbox_data)
+static void t4vf_record_mbox(struct adapter *adapter, const __be64 *cmd,
+			     int size, int access, int execute)
 {
-	dev_err(adapter->pdev_dev,
-		"mbox %s: %llx %llx %llx %llx %llx %llx %llx %llx\n", tag,
-		(unsigned long long)t4_read_reg64(adapter, mbox_data +  0),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data +  8),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data + 16),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data + 24),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data + 32),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data + 40),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data + 48),
-		(unsigned long long)t4_read_reg64(adapter, mbox_data + 56));
+	struct mbox_cmd_log *log = adapter->mbox_log;
+	struct mbox_cmd *entry;
+	int i;
+
+	entry = mbox_cmd_log_entry(log, log->cursor++);
+	if (log->cursor == log->size)
+		log->cursor = 0;
+
+	for (i = 0; i < size / 8; i++)
+		entry->cmd[i] = be64_to_cpu(cmd[i]);
+	while (i < MBOX_LEN / 8)
+		entry->cmd[i++] = 0;
+	entry->timestamp = jiffies;
+	entry->seqno = log->seqno++;
+	entry->access = access;
+	entry->execute = execute;
 }
 
 /**
@@ -120,10 +132,13 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 		1, 1, 3, 5, 10, 10, 20, 50, 100
 	};
 
+	u16 access = 0, execute = 0;
 	u32 v, mbox_data;
-	int i, ms, delay_idx;
+	int i, ms, delay_idx, ret;
 	const __be64 *p;
 	u32 mbox_ctl = T4VF_CIM_BASE_ADDR + CIM_VF_EXT_MAILBOX_CTRL;
+	u32 cmd_op = FW_CMD_OP_G(be32_to_cpu(((struct fw_cmd_hdr *)cmd)->hi));
+	__be64 cmd_rpl[MBOX_LEN / 8];
 
 	/* In T6, mailbox size is changed to 128 bytes to avoid
 	 * invalidating the entire prefetch buffer.
@@ -148,8 +163,11 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
 		v = MBOWNER_G(t4_read_reg(adapter, mbox_ctl));
-	if (v != MBOX_OWNER_DRV)
-		return v == MBOX_OWNER_FW ? -EBUSY : -ETIMEDOUT;
+	if (v != MBOX_OWNER_DRV) {
+		ret = (v == MBOX_OWNER_FW) ? -EBUSY : -ETIMEDOUT;
+		t4vf_record_mbox(adapter, cmd, size, access, ret);
+		return ret;
+	}
 
 	/*
 	 * Write the command array into the Mailbox Data register array and
@@ -164,6 +182,8 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	 * Data registers before doing the write to the VF Mailbox Control
 	 * register.
 	 */
+	if (cmd_op != FW_VI_STATS_CMD)
+		t4vf_record_mbox(adapter, cmd, size, access, 0);
 	for (i = 0, p = cmd; i < size; i += 8)
 		t4_write_reg64(adapter, mbox_data + i, be64_to_cpu(*p++));
 	t4_read_reg(adapter, mbox_data);         /* flush write */
@@ -209,31 +229,33 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 			 * We return the (negated) firmware command return
 			 * code (this depends on FW_SUCCESS == 0).
 			 */
+			get_mbox_rpl(adapter, cmd_rpl, size, mbox_data);
 
 			/* return value in low-order little-endian word */
-			v = t4_read_reg(adapter, mbox_data);
-			if (FW_CMD_RETVAL_G(v))
-				dump_mbox(adapter, "FW Error", mbox_data);
+			v = be64_to_cpu(cmd_rpl[0]);
 
 			if (rpl) {
 				/* request bit in high-order BE word */
 				WARN_ON((be32_to_cpu(*(const __be32 *)cmd)
 					 & FW_CMD_REQUEST_F) == 0);
-				get_mbox_rpl(adapter, rpl, size, mbox_data);
+				memcpy(rpl, cmd_rpl, size);
 				WARN_ON((be32_to_cpu(*(__be32 *)rpl)
 					 & FW_CMD_REQUEST_F) != 0);
 			}
 			t4_write_reg(adapter, mbox_ctl,
 				     MBOWNER_V(MBOX_OWNER_NONE));
+			execute = i + ms;
+			if (cmd_op != FW_VI_STATS_CMD)
+				t4vf_record_mbox(adapter, cmd_rpl, size, access,
+						 execute);
 			return -FW_CMD_RETVAL_G(v);
 		}
 	}
 
-	/*
-	 * We timed out.  Return the error ...
-	 */
-	dump_mbox(adapter, "FW Timeout", mbox_data);
-	return -ETIMEDOUT;
+	/* We timed out.  Return the error ... */
+	ret = -ETIMEDOUT;
+	t4vf_record_mbox(adapter, cmd, size, access, ret);
+	return ret;
 }
 
 #define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
-- 
2.3.4
