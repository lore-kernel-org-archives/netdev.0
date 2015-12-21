From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4: add dcb info node in debugfs
Date: Mon, 21 Dec 2015 12:46:08 +0530
Message-ID: <1450682170-7106-4-git-send-email-hariprasad@chelsio.com>
References: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:30789 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751299AbbLUHO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 02:14:58 -0500
In-Reply-To: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new /sys/kernel/debug/cxgb4/*/dcb_info node to dump out
various Data Center Bridging information.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c     |  11 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h     |  11 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 191 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   1 +
 4 files changed, 203 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 052c660..dde7b80 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -20,17 +20,6 @@
 
 #include "cxgb4.h"
 
-/* DCBx version control
- */
-static const char * const dcb_ver_array[] = {
-	"Unknown",
-	"DCBx-CIN",
-	"DCBx-CEE 1.01",
-	"DCBx-IEEE",
-	"", "", "",
-	"Auto Negotiated"
-};
-
 static inline bool cxgb4_dcb_state_synced(enum cxgb4_dcb_state state)
 {
 	if (state == CXGB4_DCB_STATE_FW_ALLSYNCED ||
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
index ccf24d3..6581ba8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h
@@ -70,6 +70,17 @@
 					    CXGB4_DCB_STATE_FW_ALLSYNCED); \
 	} while (0)
 
+/* DCBx version control
+ */
+static const char * const dcb_ver_array[] = {
+	"Unknown",
+	"DCBx-CIN",
+	"DCBx-CEE 1.01",
+	"DCBx-IEEE",
+	"", "", "",
+	"Auto Negotiated"
+};
+
 /* States we can be in for a port's Data Center Bridging.
  */
 enum cxgb4_dcb_state {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 62a343f..a008afdb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -44,6 +44,7 @@
 #include "t4fw_api.h"
 #include "cxgb4_debugfs.h"
 #include "clip_tbl.h"
+#include "cxgb4_dcb.h"
 #include "l2t.h"
 
 /* generic seq_file support for showing a table of size rows x width. */
@@ -2219,6 +2220,193 @@ static const struct file_operations rss_vf_config_debugfs_fops = {
 	.release = seq_release_private
 };
 
+#ifdef CONFIG_CHELSIO_T4_DCB
+/* Data Center Briging information for each port */
+static int dcb_info_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adap = seq->private;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Data Center Bridging Information\n");
+	} else {
+		int port = (uintptr_t)v - 2;
+		struct net_device *dev = adap->port[port];
+		struct port_info *pi = netdev2pinfo(dev);
+		struct port_dcb_info *dcb = &pi->dcb;
+
+		seq_puts(seq, "\n");
+		seq_printf(seq, "Port: %d (DCB negotiated: %s)\n",
+			   port,
+			   cxgb4_dcb_enabled(dev) ? "yes" : "no");
+
+		if (cxgb4_dcb_enabled(dev))
+			seq_printf(seq, "[ DCBx Version %s ]\n",
+				   dcb_ver_array[dcb->dcb_version]);
+
+		if (dcb->msgs) {
+			int i;
+
+			seq_puts(seq, "\n  Index\t\t\t  :\t");
+			for (i = 0; i < 8; i++)
+				seq_printf(seq, " %3d", i);
+			seq_puts(seq, "\n\n");
+		}
+
+		if (dcb->msgs & CXGB4_DCB_FW_PGID) {
+			int prio, pgid;
+
+			seq_puts(seq, "  Priority Group IDs\t  :\t");
+			for (prio = 0; prio < 8; prio++) {
+				pgid = (dcb->pgid >> 4 * (7 - prio)) & 0xf;
+				seq_printf(seq, " %3d", pgid);
+			}
+			seq_puts(seq, "\n");
+		}
+
+		if (dcb->msgs & CXGB4_DCB_FW_PGRATE) {
+			int pg;
+
+			seq_puts(seq, "  Priority Group BW(%)\t  :\t");
+			for (pg = 0; pg < 8; pg++)
+				seq_printf(seq, " %3d", dcb->pgrate[pg]);
+			seq_puts(seq, "\n");
+
+			if (dcb->dcb_version == FW_PORT_DCB_VER_IEEE) {
+				seq_puts(seq, "  TSA Algorithm\t\t  :\t");
+				for (pg = 0; pg < 8; pg++)
+					seq_printf(seq, " %3d", dcb->tsa[pg]);
+				seq_puts(seq, "\n");
+			}
+
+			seq_printf(seq, "  Max PG Traffic Classes  [%3d  ]\n",
+				   dcb->pg_num_tcs_supported);
+
+			seq_puts(seq, "\n");
+		}
+
+		if (dcb->msgs & CXGB4_DCB_FW_PRIORATE) {
+			int prio;
+
+			seq_puts(seq, "  Priority Rate\t:\t");
+			for (prio = 0; prio < 8; prio++)
+				seq_printf(seq, " %3d", dcb->priorate[prio]);
+			seq_puts(seq, "\n");
+		}
+
+		if (dcb->msgs & CXGB4_DCB_FW_PFC) {
+			int prio, pfcen;
+
+			seq_puts(seq, "  Priority Flow Control   :\t");
+			for (prio = 0; prio < 8; prio++) {
+				pfcen = (dcb->pfcen >> 1 * (7 - prio)) & 0x1;
+				seq_printf(seq, " %3d", pfcen);
+			}
+			seq_puts(seq, "\n");
+
+			seq_printf(seq, "  Max PFC Traffic Classes [%3d  ]\n",
+				   dcb->pfc_num_tcs_supported);
+
+			seq_puts(seq, "\n");
+		}
+
+		if (dcb->msgs & CXGB4_DCB_FW_APP_ID) {
+			int app, napps;
+
+			seq_puts(seq, "  Application Information:\n");
+			seq_puts(seq, "  App    Priority    Selection         Protocol\n");
+			seq_puts(seq, "  Index  Map         Field             ID\n");
+			for (app = 0, napps = 0;
+				app < CXGB4_MAX_DCBX_APP_SUPPORTED; app++) {
+				struct app_priority *ap =
+					&dcb->app_priority[app];
+				static const char * const sel_names[] = {
+					"Ethertype",
+					"Socket TCP",
+					"Socket UDP",
+					"Socket All",
+				};
+				const char *sel_name;
+
+				/* skip empty slots */
+				if (ap->protocolid == 0)
+					continue;
+				napps++;
+
+				if (ap->sel_field < ARRAY_SIZE(sel_names))
+					sel_name = sel_names[ap->sel_field];
+				else
+					sel_name = "UNKNOWN";
+
+				seq_printf(seq, "  %3d    %#04x        %-10s (%d)"
+					   "    %#06x (%d)\n",
+					   app,
+					   ap->user_prio_map,
+					   sel_name, ap->sel_field,
+					   ap->protocolid, ap->protocolid);
+			}
+			if (napps == 0)
+				seq_puts(seq, "    --- None ---\n");
+		}
+	}
+	return 0;
+}
+
+static inline void *dcb_info_get_idx(struct adapter *adap, loff_t pos)
+{
+	return (pos <= adap->params.nports
+		? (void *)((uintptr_t)pos + 1)
+		: NULL);
+}
+
+static void *dcb_info_start(struct seq_file *seq, loff_t *pos)
+{
+	struct adapter *adap = seq->private;
+
+	return (*pos
+		? dcb_info_get_idx(adap, *pos)
+		: SEQ_START_TOKEN);
+}
+
+static void dcb_info_stop(struct seq_file *seq, void *v)
+{
+}
+
+static void *dcb_info_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct adapter *adap = seq->private;
+
+	(*pos)++;
+	return dcb_info_get_idx(adap, *pos);
+}
+
+static const struct seq_operations dcb_info_seq_ops = {
+	.start = dcb_info_start,
+	.next  = dcb_info_next,
+	.stop  = dcb_info_stop,
+	.show  = dcb_info_show
+};
+
+static int dcb_info_open(struct inode *inode, struct file *file)
+{
+	int res = seq_open(file, &dcb_info_seq_ops);
+
+	if (!res) {
+		struct seq_file *seq = file->private_data;
+
+		seq->private = inode->i_private;
+	}
+	return res;
+}
+
+static const struct file_operations dcb_info_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = dcb_info_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+#endif /* CONFIG_CHELSIO_T4_DCB */
+
 /**
  * ethqset2pinfo - return port_info of an Ethernet Queue Set
  * @adap: the adapter
@@ -3049,6 +3237,9 @@ int t4_setup_debugfs(struct adapter *adap)
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
+#ifdef CONFIG_CHELSIO_T4_DCB
+		{ "dcb_info", &dcb_info_debugfs_fops, S_IRUSR, 0 },
+#endif
 		{ "tids", &tid_info_debugfs_fops, S_IRUSR, 0},
 		{ "blocked_fl", &blocked_fl_fops, S_IRUSR | S_IWUSR, 0 },
 		{ "meminfo", &meminfo_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index cf711d5..4fd7f1a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -293,6 +293,7 @@ unsigned int cxgb4_port_chan(const struct net_device *dev);
 unsigned int cxgb4_port_viid(const struct net_device *dev);
 unsigned int cxgb4_tp_smt_idx(enum chip_type chip, unsigned int viid);
 unsigned int cxgb4_port_idx(const struct net_device *dev);
+int cxgb4_dcb_enabled(const struct net_device *dev);
 unsigned int cxgb4_best_mtu(const unsigned short *mtus, unsigned short mtu,
 			    unsigned int *idx);
 unsigned int cxgb4_best_aligned_mtu(const unsigned short *mtus,
-- 
2.3.4
