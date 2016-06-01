From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 09/12] nfp: report statistics of offloaded filters
Date: Wed,  1 Jun 2016 17:50:11 +0100
Message-ID: <1464799814-4453-10-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38224 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbcFAQvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:53 -0400
Received: by mail-wm0-f51.google.com with SMTP id a20so35122054wma.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:52 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Periodically read filter drop counts from the bar and
report them to appropriate action on user request.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       | 19 +++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  3 +
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  3 +
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  3 +
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   | 64 ++++++++++++++++++++++
 5 files changed, 92 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 5df713b8f7c5..fe6333220d97 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -62,6 +62,9 @@
 /* Max time to wait for NFP to respond on updates (in seconds) */
 #define NFP_NET_POLL_TIMEOUT	5
 
+/* Interval for reading offloaded filter stats */
+#define NFP_NET_STAT_POLL_IVL	msecs_to_jiffies(500)
+
 /* Bar allocation */
 #define NFP_NET_CRTL_BAR	0
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
 
@@ -741,6 +759,7 @@ int nfp_net_irqs_alloc(struct nfp_net *nn);
 void nfp_net_irqs_disable(struct nfp_net *nn);
 int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt);
 
+void nfp_net_filter_stats_timer(unsigned long data);
 int
 nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
 		    struct tc_cls_bpf_offload *cls_bpf);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 706927b94e28..6364e97bac66 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2697,10 +2697,13 @@ struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
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
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index c26449655419..f66b81b5d749 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -319,6 +319,9 @@
 #define NFP_NET_CFG_STATS_TX_MC_FRAMES  (NFP_NET_CFG_STATS_BASE + 0x80)
 #define NFP_NET_CFG_STATS_TX_BC_FRAMES  (NFP_NET_CFG_STATS_BASE + 0x88)
 
+#define NFP_NET_CFG_STATS_FILTER_FRAMES (NFP_NET_CFG_STATS_BASE + 0x90)
+#define NFP_NET_CFG_STATS_FILTER_BYTES  (NFP_NET_CFG_STATS_BASE + 0x98)
+
 /**
  * Per ring stats (0x1000 - 0x1800)
  * options, 64bit per entry
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index ccfef1f17627..a3a27b9917af 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -107,6 +107,9 @@ static const struct _nfp_net_et_stats nfp_net_et_stats[] = {
 	{"dev_tx_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_FRAMES)},
 	{"dev_tx_mc_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_MC_FRAMES)},
 	{"dev_tx_bc_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_BC_FRAMES)},
+
+	{"dev_filter_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_FILTER_FRAMES)},
+	{"dev_filter_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_FILTER_BYTES)},
 };
 
 #define NN_ET_GLOBAL_STATS_LEN ARRAY_SIZE(nfp_net_et_stats)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index dd2e428fd35a..caada9d61913 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -39,6 +39,8 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
+#include <linux/jiffies.h>
+#include <linux/timer.h>
 
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
@@ -47,6 +49,58 @@
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
+	latest.pkts = nn_readq(nn, NFP_NET_CFG_STATS_FILTER_FRAMES);
+	latest.bytes = nn_readq(nn, NFP_NET_CFG_STATS_FILTER_BYTES);
+
+	if (latest.pkts != nn->rx_filter.pkts)
+		nn->rx_filter_change = jiffies;
+
+	nn->rx_filter = latest;
+}
+
+static void nfp_net_bpf_stats_reset(struct nfp_net *nn)
+{
+	nn->rx_filter.pkts = nn_readq(nn, NFP_NET_CFG_STATS_FILTER_FRAMES);
+	nn->rx_filter.bytes = nn_readq(nn, NFP_NET_CFG_STATS_FILTER_BYTES);
+	nn->rx_filter_prev = nn->rx_filter;
+	nn->rx_filter_change = jiffies;
+}
+
+static int
+nfp_net_bpf_stats_update(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
+{
+	struct tc_action *a;
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
+	tc_for_each_action(a, cls_bpf->exts)
+		tcf_action_stats_update(a, bytes, pkts, nn->rx_filter_change);
+
+	preempt_enable();
+
+	return 0;
+}
+
 static int
 nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 			    struct tc_cls_bpf_offload *cls_bpf,
@@ -116,6 +170,9 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
 
 	dma_free_coherent(&nn->pdev->dev, code_sz, code, dma_addr);
+
+	nfp_net_bpf_stats_reset(nn);
+	mod_timer(&nn->rx_filter_stats_timer, jiffies + NFP_NET_STAT_POLL_IVL);
 }
 
 static int nfp_net_bpf_stop(struct nfp_net *nn)
@@ -123,11 +180,15 @@ static int nfp_net_bpf_stop(struct nfp_net *nn)
 	if (!(nn->ctrl & NFP_NET_CFG_CTRL_BPF))
 		return 0;
 
+	spin_lock_bh(&nn->rx_filter_lock);
 	nn->ctrl &= ~NFP_NET_CFG_CTRL_BPF;
+	spin_unlock_bh(&nn->rx_filter_lock);
 	nn_writel(nn, NFP_NET_CFG_CTRL, nn->ctrl);
 
 	nn->bpf_offload_skip_sw = 0;
 
+	del_timer_sync(&nn->rx_filter_stats_timer);
+
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 }
 
@@ -185,6 +246,9 @@ nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
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
