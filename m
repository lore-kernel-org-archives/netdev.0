From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: Add support for devlog
Date: Wed,  7 Jan 2015 08:48:00 +0530
Message-ID: <1420600683-23289-2-git-send-email-hariprasad@chelsio.com>
References: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	anish@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19177 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754817AbbAGDN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:13:57 -0500
In-Reply-To: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for device log entry in debugfs

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    8 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  198 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   26 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |   12 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   81 ++++++++
 5 files changed, 325 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 5ab5c31..73b1f3a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -290,11 +290,19 @@ enum chip_type {
 	T5_LAST_REV	= T5_A1,
 };
 
+struct devlog_params {
+	u32 memtype;                    /* which memory (EDC0, EDC1, MC) */
+	u32 start;                      /* start of log in firmware memory */
+	u32 size;                       /* size of log */
+};
+
 struct adapter_params {
 	struct sge_params sge;
 	struct tp_params  tp;
 	struct vpd_params vpd;
 	struct pci_params pci;
+	struct devlog_params devlog;
+	enum pcie_memwin drv_memwin;
 
 	unsigned int sf_size;             /* serial flash size in bytes */
 	unsigned int sf_nsec;             /* # of flash sectors */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index c98a350..1d3d1c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -43,6 +43,203 @@
 #include "cxgb4_debugfs.h"
 #include "l2t.h"
 
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
+	if (!dinfo)
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
 static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
 			loff_t *ppos)
 {
@@ -121,6 +318,7 @@ int t4_setup_debugfs(struct adapter *adap)
 	u32 size;
 
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
+		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 	};
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 04e675b..6de41cc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5541,6 +5541,8 @@ static int adap_init0(struct adapter *adap)
 	enum dev_state state;
 	u32 params[7], val[7];
 	struct fw_caps_config_cmd caps_cmd;
+	struct fw_devlog_cmd devlog_cmd;
+	u32 devlog_meminfo;
 	int reset = 1;
 
 	/* Contact FW, advertising Master capability */
@@ -5621,6 +5623,30 @@ static int adap_init0(struct adapter *adap)
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
+	devlog_cmd.op_to_write = htonl(FW_CMD_OP_V(FW_DEVLOG_CMD) |
+				       FW_CMD_REQUEST_F | FW_CMD_READ_F);
+	devlog_cmd.retval_len16 = htonl(FW_LEN16(devlog_cmd));
+	ret = t4_wr_mbox(adap, adap->mbox, &devlog_cmd, sizeof(devlog_cmd),
+			 &devlog_cmd);
+	if (ret == 0) {
+		devlog_meminfo =
+			ntohl(devlog_cmd.memtype_devlog_memaddr16_devlog);
+		adap->params.devlog.memtype =
+			FW_DEVLOG_CMD_MEMTYPE_DEVLOG_G(devlog_meminfo);
+		adap->params.devlog.start =
+			FW_DEVLOG_CMD_MEMADDR16_DEVLOG_G(devlog_meminfo) << 4;
+		adap->params.devlog.size = ntohl(devlog_cmd.memsize_devlog);
+	}
+
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
index 7c0aec8..de82833 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -673,6 +673,7 @@ enum fw_cmd_opcodes {
 	FW_RSS_IND_TBL_CMD             = 0x20,
 	FW_RSS_GLB_CONFIG_CMD          = 0x22,
 	FW_RSS_VI_CONFIG_CMD           = 0x23,
+	FW_DEVLOG_CMD                  = 0x25,
 	FW_CLIP_CMD                    = 0x28,
 	FW_LASTC2E_CMD                 = 0x40,
 	FW_ERROR_CMD                   = 0x80,
@@ -3038,4 +3039,84 @@ enum fw_hdr_flags {
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
+#define FW_DEVLOG_CMD_MEMTYPE_DEVLOG_S		28
+#define FW_DEVLOG_CMD_MEMTYPE_DEVLOG_M		0xf
+#define FW_DEVLOG_CMD_MEMTYPE_DEVLOG_G(x)	\
+	(((x) >> FW_DEVLOG_CMD_MEMTYPE_DEVLOG_S) & \
+	 FW_DEVLOG_CMD_MEMTYPE_DEVLOG_M)
+
+#define FW_DEVLOG_CMD_MEMADDR16_DEVLOG_S	0
+#define FW_DEVLOG_CMD_MEMADDR16_DEVLOG_M	0xfffffff
+#define FW_DEVLOG_CMD_MEMADDR16_DEVLOG_G(x)	\
+	(((x) >> FW_DEVLOG_CMD_MEMADDR16_DEVLOG_S) & \
+	 FW_DEVLOG_CMD_MEMADDR16_DEVLOG_M)
+
 #endif /* _T4FW_INTERFACE_H_ */
-- 
1.7.1
