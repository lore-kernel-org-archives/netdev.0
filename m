From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 12/16] net: bpf: allow offloaded filters to update stats
Date: Fri, 26 Aug 2016 19:06:11 +0100
Message-ID: <1472234775-29453-13-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37887 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbcHZSI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:08:56 -0400
Received: by mail-wm0-f43.google.com with SMTP id i5so3354809wmg.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:08:01 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Periodically poll stats and call into offloaded actions
to update them.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       | 19 +++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  3 ++
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   | 63 ++++++++++++++++++++++
 3 files changed, 85 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index ea6f5e667f27..13c6a9001b4d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -62,6 +62,9 @@
 /* Max time to wait for NFP to respond on updates (in seconds) */
 #define NFP_NET_POLL_TIMEOUT	5
 
+/* Interval for reading offloaded filter stats */
+#define NFP_NET_STAT_POLL_IVL	msecs_to_jiffies(100)
+
 /* Bar allocation */
 #define NFP_NET_CTRL_BAR	0
 #define NFP_NET_Q0_BAR		2
@@ -405,6 +408,11 @@ static inline bool nfp_net_fw_ver_eq(struct nfp_net_fw_version *fw_ver,
 	       fw_ver->minor == minor;
 }
 
+struct nfp_stat_pair {
+	u64 pkts;
+	u64 bytes;
+};
+
 /**
  * struct nfp_net - NFP network device structure
  * @pdev:               Backpointer to PCI device
@@ -428,6 +436,11 @@ static inline bool nfp_net_fw_ver_eq(struct nfp_net_fw_version *fw_ver,
  * @rss_cfg:            RSS configuration
  * @rss_key:            RSS secret key
  * @rss_itbl:           RSS indirection table
+ * @rx_filter:		Filter offload statistics - dropped packets/bytes
+ * @rx_filter_prev:	Filter offload statistics - values from previous update
+ * @rx_filter_change:	Jiffies when statistics last changed
+ * @rx_filter_stats_timer:  Timer for polling filter offload statistics
+ * @rx_filter_lock:	Lock protecting timer state changes (teardown)
  * @max_tx_rings:       Maximum number of TX rings supported by the Firmware
  * @max_rx_rings:       Maximum number of RX rings supported by the Firmware
  * @num_tx_rings:       Currently configured number of TX rings
@@ -504,6 +517,11 @@ struct nfp_net {
 	u8 rss_key[NFP_NET_CFG_RSS_KEY_SZ];
 	u8 rss_itbl[NFP_NET_CFG_RSS_ITBL_SZ];
 
+	struct nfp_stat_pair rx_filter, rx_filter_prev;
+	unsigned long rx_filter_change;
+	struct timer_list rx_filter_stats_timer;
+	spinlock_t rx_filter_lock;
+
 	int max_tx_rings;
 	int max_rx_rings;
 
@@ -775,6 +793,7 @@ static inline void nfp_net_debugfs_adapter_del(struct nfp_net *nn)
 }
 #endif /* CONFIG_NFP_NET_DEBUG */
 
+void nfp_net_filter_stats_timer(unsigned long data);
 int
 nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
 		    struct tc_cls_bpf_offload *cls_bpf);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index ff0e6b02934c..053bda8a0fbd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2708,10 +2708,13 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
 	nn->rxd_cnt = NFP_NET_RX_DESCS_DEFAULT;
 
 	spin_lock_init(&nn->reconfig_lock);
+	spin_lock_init(&nn->rx_filter_lock);
 	spin_lock_init(&nn->link_status_lock);
 
 	setup_timer(&nn->reconfig_timer,
 		    nfp_net_reconfig_timer, (unsigned long)nn);
+	setup_timer(&nn->rx_filter_stats_timer,
+		    nfp_net_filter_stats_timer, (unsigned long)nn);
 
 	return nn;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 3a3dba1a03f0..4b8ce01a8dd2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -51,6 +51,60 @@
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
+void nfp_net_filter_stats_timer(unsigned long data)
+{
+	struct nfp_net *nn = (void *)data;
+	struct nfp_stat_pair latest;
+
+	spin_lock_bh(&nn->rx_filter_lock);
+
+	if (nn->ctrl & NFP_NET_CFG_CTRL_BPF)
+		mod_timer(&nn->rx_filter_stats_timer,
+			  jiffies + NFP_NET_STAT_POLL_IVL);
+
+	spin_unlock_bh(&nn->rx_filter_lock);
+
+	latest.pkts = nn_readq(nn, NFP_NET_CFG_STATS_APP1_FRAMES);
+	latest.bytes = nn_readq(nn, NFP_NET_CFG_STATS_APP1_BYTES);
+
+	if (latest.pkts != nn->rx_filter.pkts)
+		nn->rx_filter_change = jiffies;
+
+	nn->rx_filter = latest;
+}
+
+static void nfp_net_bpf_stats_reset(struct nfp_net *nn)
+{
+	nn->rx_filter.pkts = nn_readq(nn, NFP_NET_CFG_STATS_APP1_FRAMES);
+	nn->rx_filter.bytes = nn_readq(nn, NFP_NET_CFG_STATS_APP1_BYTES);
+	nn->rx_filter_prev = nn->rx_filter;
+	nn->rx_filter_change = jiffies;
+}
+
+static int
+nfp_net_bpf_stats_update(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
+{
+	struct tc_action *a;
+	LIST_HEAD(actions);
+	u64 bytes, pkts;
+
+	pkts = nn->rx_filter.pkts - nn->rx_filter_prev.pkts;
+	bytes = nn->rx_filter.bytes - nn->rx_filter_prev.bytes;
+	bytes -= pkts * ETH_HLEN;
+
+	nn->rx_filter_prev = nn->rx_filter;
+
+	preempt_disable();
+
+	tcf_exts_to_list(cls_bpf->exts, &actions);
+	list_for_each_entry(a, &actions, list)
+		tcf_action_stats_update(a, bytes, pkts, nn->rx_filter_change);
+
+	preempt_enable();
+
+	return 0;
+}
+
 static int
 nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 {
@@ -147,6 +201,9 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
 
 	dma_free_coherent(&nn->pdev->dev, code_sz, code, dma_addr);
+
+	nfp_net_bpf_stats_reset(nn);
+	mod_timer(&nn->rx_filter_stats_timer, jiffies + NFP_NET_STAT_POLL_IVL);
 }
 
 static int nfp_net_bpf_stop(struct nfp_net *nn)
@@ -154,9 +211,12 @@ static int nfp_net_bpf_stop(struct nfp_net *nn)
 	if (!(nn->ctrl & NFP_NET_CFG_CTRL_BPF))
 		return 0;
 
+	spin_lock_bh(&nn->rx_filter_lock);
 	nn->ctrl &= ~NFP_NET_CFG_CTRL_BPF;
+	spin_unlock_bh(&nn->rx_filter_lock);
 	nn_writel(nn, NFP_NET_CFG_CTRL, nn->ctrl);
 
+	del_timer_sync(&nn->rx_filter_stats_timer);
 	nn->bpf_offload_skip_sw = 0;
 
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
@@ -214,6 +274,9 @@ nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
 	case TC_CLSBPF_DESTROY:
 		return nfp_net_bpf_stop(nn);
 
+	case TC_CLSBPF_STATS:
+		return nfp_net_bpf_stats_update(nn, cls_bpf);
+
 	default:
 		return -ENOTSUPP;
 	}
-- 
1.9.1
