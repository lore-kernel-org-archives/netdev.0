From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 13 Apr 2017 17:48:18 +1000
Message-ID: <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, davem@davemloft.net,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49172 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756276AbdDMHuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:50:02 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7nUIM052044
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:02 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29sw2agfay-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:50:01 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:49:53 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7neOt28770428
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:48 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7nFcl007298
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:49:16 +1000
In-Reply-To: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
packets sent and received over all packages and channels. It's useful
to diagnose NCSI problems, especially when NCSI packages and channels
aren't probed properly. The statistics can be gained from debugfs file
as below:

 # cat /sys/kernel/debug/ncsi/eth0/stats

 CMD          OK       TIMEOUT  ERROR
 =======================================
 CIS          32       29       0
 SP           10       7        0
 DP           17       14       0
 EC           1        0        0
 ECNT         1        0        0
 AE           1        0        0
 GLS          11       0        0
 SMA          1        0        0
 EBF          1        0        0
 GVI          2        0        0
 GC           2        0        0

 RSP          OK       TIMEOUT  ERROR
 =======================================
 CIS          3        0        0
 SP           3        0        0
 DP           2        0        1
 EC           1        0        0
 ECNT         1        0        0
 AE           1        0        0
 GLS          11       0        0
 SMA          1        0        0
 EBF          1        0        0
 GVI          0        0        2
 GC           2        0        0

 AEN          OK       TIMEOUT  ERROR
 =======================================

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/internal.h    |  10 +++
 net/ncsi/ncsi-aen.c    |  15 +++-
 net/ncsi/ncsi-cmd.c    |  18 +++-
 net/ncsi/ncsi-debug.c  | 235 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c |   8 ++
 net/ncsi/ncsi-rsp.c    |  21 ++++-
 6 files changed, 304 insertions(+), 3 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index e9ede4f..009c41d 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -283,6 +283,16 @@ struct ncsi_dev_priv {
 	struct packet_type  ptype;           /* NCSI packet Rx handler     */
 	struct list_head    node;            /* Form NCSI device list      */
 #ifdef CONFIG_NET_NCSI_DEBUG
+	struct {
+		struct dentry  *dentry;
+#define NCSI_PKT_STAT_OK	0
+#define NCSI_PKT_STAT_TIMEOUT	1
+#define NCSI_PKT_STAT_ERROR	2
+#define NCSI_PKT_STAT_MAX	3
+		unsigned long  cmd[128][NCSI_PKT_STAT_MAX];
+		unsigned long  rsp[128][NCSI_PKT_STAT_MAX];
+		unsigned long  aen[256][NCSI_PKT_STAT_MAX];
+	} stats;
 	struct dentry       *dentry;         /* Procfs directory           */
 #endif
 };
diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
index 6898e72..adcaa56 100644
--- a/net/ncsi/ncsi-aen.c
+++ b/net/ncsi/ncsi-aen.c
@@ -206,16 +206,29 @@ int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb)
 	}
 
 	if (!nah) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		ndp->stats.aen[h->type][NCSI_PKT_STAT_ERROR]++;
+#endif
 		netdev_warn(ndp->ndev.dev, "Invalid AEN (0x%x) received\n",
 			    h->type);
 		return -ENOENT;
 	}
 
 	ret = ncsi_validate_aen_pkt(h, nah->payload);
-	if (ret)
+	if (ret) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		ndp->stats.aen[h->type][NCSI_PKT_STAT_ERROR]++;
+#endif
 		goto out;
+	}
 
 	ret = nah->handler(ndp, h);
+#ifdef CONFIG_NET_NCSI_DEBUG
+	if (ret)
+		ndp->stats.aen[h->type][NCSI_PKT_STAT_ERROR]++;
+	else
+		ndp->stats.aen[h->type][NCSI_PKT_STAT_OK]++;
+#endif
 out:
 	consume_skb(skb);
 	return ret;
diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index db7083b..c6b2bc5 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -323,6 +323,9 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	}
 
 	if (!nch) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		nca->ndp->stats.cmd[nca->type][NCSI_PKT_STAT_ERROR]++;
+#endif
 		netdev_err(nca->ndp->ndev.dev,
 			   "Cannot send packet with type 0x%02x\n", nca->type);
 		return -ENOENT;
@@ -331,13 +334,20 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	/* Get packet payload length and allocate the request */
 	nca->payload = nch->payload;
 	nr = ncsi_alloc_command(nca);
-	if (!nr)
+	if (!nr) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		nca->ndp->stats.cmd[nca->type][NCSI_PKT_STAT_ERROR]++;
+#endif
 		return -ENOMEM;
+	}
 
 	/* Prepare the packet */
 	nca->id = nr->id;
 	ret = nch->handler(nr->cmd, nca);
 	if (ret) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		nca->ndp->stats.cmd[nca->type][NCSI_PKT_STAT_ERROR]++;
+#endif
 		ncsi_free_request(nr);
 		return ret;
 	}
@@ -359,9 +369,15 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	skb_get(nr->cmd);
 	ret = dev_queue_xmit(nr->cmd);
 	if (ret < 0) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		nca->ndp->stats.cmd[nca->type][NCSI_PKT_STAT_ERROR]++;
+#endif
 		ncsi_free_request(nr);
 		return ret;
 	}
 
+#ifdef CONFIG_NET_NCSI_DEBUG
+	nca->ndp->stats.cmd[nca->type][NCSI_PKT_STAT_OK]++;
+#endif
 	return 0;
 }
diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
index 6c00e9b..29c233c 100644
--- a/net/ncsi/ncsi-debug.c
+++ b/net/ncsi/ncsi-debug.c
@@ -23,6 +23,235 @@
 #include "ncsi-pkt.h"
 
 static struct dentry *ncsi_dentry;
+static struct ncsi_pkt_handler {
+	unsigned char	type;
+	const char	*name;
+} ncsi_pkt_handlers[] = {
+	{ NCSI_PKT_CMD_CIS,    "CIS"    },
+	{ NCSI_PKT_CMD_SP,     "SP"     },
+	{ NCSI_PKT_CMD_DP,     "DP"     },
+	{ NCSI_PKT_CMD_EC,     "EC"     },
+	{ NCSI_PKT_CMD_DC,     "DC"     },
+	{ NCSI_PKT_CMD_RC,     "RC"     },
+	{ NCSI_PKT_CMD_ECNT,   "ECNT"   },
+	{ NCSI_PKT_CMD_DCNT,   "DCNT"   },
+	{ NCSI_PKT_CMD_AE,     "AE"     },
+	{ NCSI_PKT_CMD_SL,     "SL"     },
+	{ NCSI_PKT_CMD_GLS,    "GLS"    },
+	{ NCSI_PKT_CMD_SVF,    "SVF"    },
+	{ NCSI_PKT_CMD_EV,     "EV"     },
+	{ NCSI_PKT_CMD_DV,     "DV"     },
+	{ NCSI_PKT_CMD_SMA,    "SMA"    },
+	{ NCSI_PKT_CMD_EBF,    "EBF"    },
+	{ NCSI_PKT_CMD_DBF,    "DBF"    },
+	{ NCSI_PKT_CMD_EGMF,   "EGMF"   },
+	{ NCSI_PKT_CMD_DGMF,   "DGMF"   },
+	{ NCSI_PKT_CMD_SNFC,   "SNFC"   },
+	{ NCSI_PKT_CMD_GVI,    "GVI"    },
+	{ NCSI_PKT_CMD_GC,     "GC"     },
+	{ NCSI_PKT_CMD_GP,     "GP"     },
+	{ NCSI_PKT_CMD_GCPS,   "GCPS"   },
+	{ NCSI_PKT_CMD_GNS,    "GNS"    },
+	{ NCSI_PKT_CMD_GNPTS,  "GNPTS"  },
+	{ NCSI_PKT_CMD_GPS,    "GPS"    },
+	{ NCSI_PKT_CMD_OEM,    "OEM"    },
+	{ NCSI_PKT_CMD_PLDM,   "PLDM"   },
+	{ NCSI_PKT_CMD_GPUUID, "GPUUID" },
+};
+
+static bool ncsi_dev_stats_index(struct ncsi_dev_priv *ndp, loff_t pos,
+				 unsigned long *type, unsigned long *index,
+				 unsigned long *entries)
+{
+	int i;
+	unsigned long ranges[3][2] = {
+		{ 1,
+		  ARRAY_SIZE(ndp->stats.cmd) - 1		},
+		{ ranges[0][1] + 2,
+		  ranges[1][0] + ARRAY_SIZE(ndp->stats.rsp) - 1	},
+		{ ranges[1][1] + 2,
+		  ranges[2][0] + ARRAY_SIZE(ndp->stats.aen) - 1 }
+	};
+
+	for (i = 0; i < 3; i++) {
+		if (pos == (ranges[i][0] - 1)) {
+			*index = i;
+			*entries = 0;
+			return true;
+		}
+
+		if (pos >= ranges[i][0] && pos <= ranges[i][1]) {
+			*type = i;
+			*index = (pos - ranges[i][0]);
+			*entries = NCSI_PKT_STAT_MAX;
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static void *ncsi_dev_stats_data(struct ncsi_dev_priv *ndp, loff_t pos)
+{
+	unsigned long type, index, entries;
+	bool valid;
+
+	valid = ncsi_dev_stats_index(ndp, pos, &type, &index, &entries);
+	if (!valid)
+		return NULL;
+
+	/* The bits in return value are assigned as below:
+	 *
+	 * Bit[7:0]:   Number of ulong entries
+	 * Bit[23:8]:  Offset to that specific data entry
+	 * Bit[30:24]: Type of packet statistics
+	 * Bit[31]:    0x1 as valid flag.
+	 */
+	if (!entries)
+		index += ((unsigned long)SEQ_START_TOKEN);
+	else
+		index = (1 << 31) | (type << 24) | (index << 8) | entries;
+
+	return (void *)index;
+}
+
+static void *ncsi_dev_stats_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct ncsi_dev_priv *ndp = seq->private;
+	void *data;
+
+	data = ncsi_dev_stats_data(ndp, *pos);
+	++(*pos);
+
+	return data;
+}
+
+static void *ncsi_dev_stats_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ncsi_dev_priv *ndp = seq->private;
+	void *data;
+
+	data = ncsi_dev_stats_data(ndp, *pos);
+	++(*pos);
+	return data;
+}
+
+static void ncsi_dev_stats_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static const char *ncsi_pkt_type_name(unsigned int type)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ncsi_pkt_handlers); i++) {
+		if (ncsi_pkt_handlers[i].type == type)
+			return ncsi_pkt_handlers[i].name;
+	}
+
+	return "N/A";
+}
+
+static const char *ncsi_dev_stats_pkt_name(unsigned long type,
+					   unsigned long index)
+{
+	switch (type) {
+	case 0: /* Command */
+	case 1: /* Response */
+		return ncsi_pkt_type_name(index);
+	case 2: /* AEN */
+		switch (index) {
+		case NCSI_PKT_AEN_LSC:
+			return "LSC";
+		case NCSI_PKT_AEN_CR:
+			return "CR";
+		case NCSI_PKT_AEN_HNCDSC:
+			return "HNCDSC";
+		default:
+			return "N/A";
+		}
+	}
+
+	return "N/A";
+}
+
+static int ncsi_dev_stats_seq_show(struct seq_file *seq, void *v)
+{
+	struct ncsi_dev_priv *ndp = seq->private;
+	unsigned long type, index, entries, *data;
+	const char *name;
+
+	if (v >= SEQ_START_TOKEN && v <= (SEQ_START_TOKEN + 2)) {
+		static const char * const header[] = { "CMD", "RSP", "AEN" };
+
+		seq_puts(seq, "\n");
+		seq_printf(seq, "%-12s %-8s %-8s %-8s\n",
+			   header[v - SEQ_START_TOKEN],
+			   "OK", "TIMEOUT", "ERROR");
+		seq_puts(seq, "=======================================\n");
+		return 0;
+	}
+
+	index = (unsigned long)v;
+	type = (index >> 24) & 0x7F;
+	entries = (index & 0xFF);
+	index = ((index >> 8) & 0xFFFF);
+	name = ncsi_dev_stats_pkt_name(type, index);
+	if (WARN_ON_ONCE(entries != NCSI_PKT_STAT_MAX))
+		return 0;
+
+	switch (type) {
+	case 0: /* Command */
+		data = &ndp->stats.cmd[0][0];
+		break;
+	case 1: /* Response */
+		data = &ndp->stats.rsp[0][0];
+		break;
+	case 2: /* AEN */
+		data = &ndp->stats.aen[0][0];
+		break;
+	default:
+		pr_warn("%s: Unsupported type %ld\n", __func__, type);
+		return 0;
+	}
+
+	data += (index * NCSI_PKT_STAT_MAX);
+	if (*data || *(data + 1) || *(data + 2)) {
+		seq_printf(seq, "%-12s %-8ld %-8ld %-8ld\n",
+			   name, *data, *(data + 1), *(data + 2));
+	}
+
+	return 0;
+}
+
+static const struct seq_operations ncsi_dev_stats_seq_ops = {
+	.start = ncsi_dev_stats_seq_start,
+	.next  = ncsi_dev_stats_seq_next,
+	.stop  = ncsi_dev_stats_seq_stop,
+	.show  = ncsi_dev_stats_seq_show,
+};
+
+static int ncsi_dev_stats_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *sf;
+	int ret;
+
+	ret = seq_open(file, &ncsi_dev_stats_seq_ops);
+	if (!ret) {
+		sf = file->private_data;
+		sf->private = inode->i_private;
+	}
+
+	return ret;
+}
+
+static const struct file_operations ncsi_dev_stats_fops = {
+	.owner   = THIS_MODULE,
+	.open    = ncsi_dev_stats_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
 
 int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp)
 {
@@ -42,11 +271,17 @@ int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp)
 	if (!ndp->dentry)
 		return -ENOMEM;
 
+	ndp->stats.dentry = debugfs_create_file("stats", 0400, ndp->dentry,
+						ndp, &ncsi_dev_stats_fops);
+	if (!ndp->stats.dentry)
+		return -ENOMEM;
+
 	return 0;
 }
 
 void ncsi_dev_release_debug(struct ncsi_dev_priv *ndp)
 {
+	debugfs_remove(ndp->stats.dentry);
 	debugfs_remove(ndp->dentry);
 }
 
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 84f1405..29063d5 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -530,6 +530,9 @@ static void ncsi_request_timeout(unsigned long data)
 	struct ncsi_request *nr = (struct ncsi_request *)data;
 	struct ncsi_dev_priv *ndp = nr->ndp;
 	unsigned long flags;
+#ifdef CONFIG_NET_NCSI_DEBUG
+	struct ncsi_pkt_hdr *hdr;
+#endif
 
 	/* If the request already had associated response,
 	 * let the response handler to release it.
@@ -542,6 +545,11 @@ static void ncsi_request_timeout(unsigned long data)
 	}
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
+#ifdef CONFIG_NET_NCSI_DEBUG
+	hdr = (struct ncsi_pkt_hdr *)skb_network_header(nr->cmd);
+	ndp->stats.cmd[hdr->type][NCSI_PKT_STAT_TIMEOUT]++;
+#endif
+
 	/* Release the request */
 	ncsi_free_request(nr);
 }
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 087db77..30bd97e 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -998,6 +998,9 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (!nrh) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		ndp->stats.rsp[hdr->type - 0x80][NCSI_PKT_STAT_ERROR]++;
+#endif
 		netdev_err(nd->dev, "Received unrecognized packet (0x%x)\n",
 			   hdr->type);
 		return -ENOENT;
@@ -1007,12 +1010,18 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	spin_lock_irqsave(&ndp->lock, flags);
 	nr = &ndp->requests[hdr->id];
 	if (!nr->used) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		ndp->stats.rsp[hdr->type - 0x80][NCSI_PKT_STAT_TIMEOUT]++;
+#endif
 		spin_unlock_irqrestore(&ndp->lock, flags);
 		return -ENODEV;
 	}
 
 	nr->rsp = skb;
 	if (!nr->enabled) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		ndp->stats.rsp[hdr->type - 0x80][NCSI_PKT_STAT_TIMEOUT]++;
+#endif
 		spin_unlock_irqrestore(&ndp->lock, flags);
 		ret = -ENOENT;
 		goto out;
@@ -1024,11 +1033,21 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	if (payload < 0)
 		payload = ntohs(hdr->length);
 	ret = ncsi_validate_rsp_pkt(nr, payload);
-	if (ret)
+	if (ret) {
+#ifdef CONFIG_NET_NCSI_DEBUG
+		ndp->stats.rsp[hdr->type - 0x80][NCSI_PKT_STAT_ERROR]++;
+#endif
 		goto out;
+	}
 
 	/* Process the packet */
 	ret = nrh->handler(nr);
+#ifdef CONFIG_NET_NCSI_DEBUG
+	if (ret)
+		ndp->stats.rsp[hdr->type - 0x80][NCSI_PKT_STAT_ERROR]++;
+	else
+		ndp->stats.rsp[hdr->type - 0x80][NCSI_PKT_STAT_OK]++;
+#endif
 out:
 	ncsi_free_request(nr);
 	return ret;
-- 
2.7.4
