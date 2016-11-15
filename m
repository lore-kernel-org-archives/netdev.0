From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v8 4/9] dpaa_eth: add ethtool statistics
Date: Tue, 15 Nov 2016 10:41:04 +0200
Message-ID: <1479199269-9748-5-git-send-email-madalin.bucur@nxp.com>
References: <1479199269-9748-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@infinera.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479199269-9748-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a series of counters to be exported through ethtool:
- add detailed counters for reception errors;
- add detailed counters for QMan enqueue reject events;
- count the number of fragmented skbs received from the stack;
- count all frames received on the Tx confirmation path;
- add congestion group statistics;
- count the number of interrupts for each CPU.

Signed-off-by: Ioana Ciornei <ioana.ciornei@nxp.com>
Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  54 +++++-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |  33 ++++
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c | 199 +++++++++++++++++++++
 3 files changed, 284 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 0e7f1c7..fcb9cac 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -700,10 +700,15 @@ static void dpaa_eth_cgscn(struct qman_portal *qm, struct qman_cgr *cgr,
 	struct dpaa_priv *priv = (struct dpaa_priv *)container_of(cgr,
 		struct dpaa_priv, cgr_data.cgr);
 
-	if (congested)
+	if (congested) {
+		priv->cgr_data.congestion_start_jiffies = jiffies;
 		netif_tx_stop_all_queues(priv->net_dev);
-	else
+		priv->cgr_data.cgr_congested_count++;
+	} else {
+		priv->cgr_data.congested_jiffies +=
+			(jiffies - priv->cgr_data.congestion_start_jiffies);
 		netif_tx_wake_all_queues(priv->net_dev);
+	}
 }
 
 static int dpaa_eth_cgr_init(struct dpaa_priv *priv)
@@ -1217,6 +1222,37 @@ static void dpaa_fd_release(const struct net_device *net_dev,
 	dpaa_bman_release(dpaa_bp, &bmb, 1);
 }
 
+static void count_ern(struct dpaa_percpu_priv *percpu_priv,
+		      const union qm_mr_entry *msg)
+{
+	switch (msg->ern.rc & QM_MR_RC_MASK) {
+	case QM_MR_RC_CGR_TAILDROP:
+		percpu_priv->ern_cnt.cg_tdrop++;
+		break;
+	case QM_MR_RC_WRED:
+		percpu_priv->ern_cnt.wred++;
+		break;
+	case QM_MR_RC_ERROR:
+		percpu_priv->ern_cnt.err_cond++;
+		break;
+	case QM_MR_RC_ORPWINDOW_EARLY:
+		percpu_priv->ern_cnt.early_window++;
+		break;
+	case QM_MR_RC_ORPWINDOW_LATE:
+		percpu_priv->ern_cnt.late_window++;
+		break;
+	case QM_MR_RC_FQ_TAILDROP:
+		percpu_priv->ern_cnt.fq_tdrop++;
+		break;
+	case QM_MR_RC_ORPWINDOW_RETIRED:
+		percpu_priv->ern_cnt.fq_retired++;
+		break;
+	case QM_MR_RC_ORP_ZERO:
+		percpu_priv->ern_cnt.orp_zero++;
+		break;
+	}
+}
+
 /* Turn on HW checksum computation for this outgoing frame.
  * If the current protocol is not something we support in this regard
  * (or if the stack has already computed the SW checksum), we do nothing.
@@ -1882,6 +1918,7 @@ static int dpaa_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 	    likely(skb_shinfo(skb)->nr_frags < DPAA_SGT_MAX_ENTRIES)) {
 		/* Just create a S/G fd based on the skb */
 		err = skb_to_sg_fd(priv, skb, &fd);
+		percpu_priv->tx_frag_skbuffs++;
 	} else {
 		/* If the egress skb contains more fragments than we support
 		 * we have no choice but to linearize it ourselves.
@@ -1918,6 +1955,15 @@ static void dpaa_rx_error(struct net_device *net_dev,
 
 	percpu_priv->stats.rx_errors++;
 
+	if (fd->status & FM_FD_ERR_DMA)
+		percpu_priv->rx_errors.dme++;
+	if (fd->status & FM_FD_ERR_PHYSICAL)
+		percpu_priv->rx_errors.fpe++;
+	if (fd->status & FM_FD_ERR_SIZE)
+		percpu_priv->rx_errors.fse++;
+	if (fd->status & FM_FD_ERR_PRS_HDR_ERR)
+		percpu_priv->rx_errors.phe++;
+
 	dpaa_fd_release(net_dev, fd);
 }
 
@@ -1973,6 +2019,8 @@ static void dpaa_tx_conf(struct net_device *net_dev,
 		percpu_priv->stats.tx_errors++;
 	}
 
+	percpu_priv->tx_confirm++;
+
 	skb = dpaa_cleanup_tx_fd(priv, fd);
 
 	consume_skb(skb);
@@ -1987,6 +2035,7 @@ static inline int dpaa_eth_napi_schedule(struct dpaa_percpu_priv *percpu_priv,
 
 		percpu_priv->np.p = portal;
 		napi_schedule(&percpu_priv->np.napi);
+		percpu_priv->in_interrupt++;
 		return 1;
 	}
 	return 0;
@@ -2171,6 +2220,7 @@ static void egress_ern(struct qman_portal *portal,
 
 	percpu_priv->stats.tx_dropped++;
 	percpu_priv->stats.tx_fifo_errors++;
+	count_ern(percpu_priv, msg);
 
 	skb = dpaa_cleanup_tx_fd(priv, fd);
 	dev_kfree_skb_any(skb);
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index d6ab335..711fb06 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -95,6 +95,25 @@ struct dpaa_bp {
 	atomic_t refs;
 };
 
+struct dpaa_rx_errors {
+	u64 dme;		/* DMA Error */
+	u64 fpe;		/* Frame Physical Error */
+	u64 fse;		/* Frame Size Error */
+	u64 phe;		/* Header Error */
+};
+
+/* Counters for QMan ERN frames - one counter per rejection code */
+struct dpaa_ern_cnt {
+	u64 cg_tdrop;		/* Congestion group taildrop */
+	u64 wred;		/* WRED congestion */
+	u64 err_cond;		/* Error condition */
+	u64 early_window;	/* Order restoration, frame too early */
+	u64 late_window;	/* Order restoration, frame too late */
+	u64 fq_tdrop;		/* FQ taildrop */
+	u64 fq_retired;		/* FQ is retired */
+	u64 orp_zero;		/* ORP disabled */
+};
+
 struct dpaa_napi_portal {
 	struct napi_struct napi;
 	struct qman_portal *p;
@@ -104,7 +123,13 @@ struct dpaa_napi_portal {
 struct dpaa_percpu_priv {
 	struct net_device *net_dev;
 	struct dpaa_napi_portal np;
+	u64 in_interrupt;
+	u64 tx_confirm;
+	/* fragmented (non-linear) skbuffs received from the stack */
+	u64 tx_frag_skbuffs;
 	struct rtnl_link_stats64 stats;
+	struct dpaa_rx_errors rx_errors;
+	struct dpaa_ern_cnt ern_cnt;
 };
 
 struct dpaa_buffer_layout {
@@ -133,6 +158,14 @@ struct dpaa_priv {
 		 * (and the same) congestion group.
 		 */
 		struct qman_cgr cgr;
+		/* If congested, when it began. Used for performance stats. */
+		u32 congestion_start_jiffies;
+		/* Number of jiffies the Tx port was congested. */
+		u32 congested_jiffies;
+		/* Counter for the number of times the CGR
+		 * entered congestion state
+		 */
+		u32 cgr_congested_count;
 	} cgr_data;
 	/* Use a per-port CGR for ingress traffic. */
 	bool use_ingress_cgr;
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
index 3580a62..27e7044 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c
@@ -36,6 +36,42 @@
 #include "dpaa_eth.h"
 #include "mac.h"
 
+static const char dpaa_stats_percpu[][ETH_GSTRING_LEN] = {
+	"interrupts",
+	"rx packets",
+	"tx packets",
+	"tx confirm",
+	"tx S/G",
+	"tx error",
+	"rx error",
+};
+
+static char dpaa_stats_global[][ETH_GSTRING_LEN] = {
+	/* dpa rx errors */
+	"rx dma error",
+	"rx frame physical error",
+	"rx frame size error",
+	"rx header error",
+
+	/* demultiplexing errors */
+	"qman cg_tdrop",
+	"qman wred",
+	"qman error cond",
+	"qman early window",
+	"qman late window",
+	"qman fq tdrop",
+	"qman fq retired",
+	"qman orp disabled",
+
+	/* congestion related stats */
+	"congestion time (ms)",
+	"entered congestion",
+	"congested (0/1)"
+};
+
+#define DPAA_STATS_PERCPU_LEN ARRAY_SIZE(dpaa_stats_percpu)
+#define DPAA_STATS_GLOBAL_LEN ARRAY_SIZE(dpaa_stats_global)
+
 static int dpaa_get_settings(struct net_device *net_dev,
 			     struct ethtool_cmd *et_cmd)
 {
@@ -205,6 +241,166 @@ static int dpaa_set_pauseparam(struct net_device *net_dev,
 	return err;
 }
 
+static int dpaa_get_sset_count(struct net_device *net_dev, int type)
+{
+	unsigned int total_stats, num_stats;
+
+	num_stats   = num_online_cpus() + 1;
+	total_stats = num_stats * (DPAA_STATS_PERCPU_LEN + DPAA_BPS_NUM) +
+			DPAA_STATS_GLOBAL_LEN;
+
+	switch (type) {
+	case ETH_SS_STATS:
+		return total_stats;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void copy_stats(struct dpaa_percpu_priv *percpu_priv, int num_cpus,
+		       int crr_cpu, u64 *bp_count, u64 *data)
+{
+	int num_values = num_cpus + 1;
+	int crr = 0, j;
+
+	/* update current CPU's stats and also add them to the total values */
+	data[crr * num_values + crr_cpu] = percpu_priv->in_interrupt;
+	data[crr++ * num_values + num_cpus] += percpu_priv->in_interrupt;
+
+	data[crr * num_values + crr_cpu] = percpu_priv->stats.rx_packets;
+	data[crr++ * num_values + num_cpus] += percpu_priv->stats.rx_packets;
+
+	data[crr * num_values + crr_cpu] = percpu_priv->stats.tx_packets;
+	data[crr++ * num_values + num_cpus] += percpu_priv->stats.tx_packets;
+
+	data[crr * num_values + crr_cpu] = percpu_priv->tx_confirm;
+	data[crr++ * num_values + num_cpus] += percpu_priv->tx_confirm;
+
+	data[crr * num_values + crr_cpu] = percpu_priv->tx_frag_skbuffs;
+	data[crr++ * num_values + num_cpus] += percpu_priv->tx_frag_skbuffs;
+
+	data[crr * num_values + crr_cpu] = percpu_priv->stats.tx_errors;
+	data[crr++ * num_values + num_cpus] += percpu_priv->stats.tx_errors;
+
+	data[crr * num_values + crr_cpu] = percpu_priv->stats.rx_errors;
+	data[crr++ * num_values + num_cpus] += percpu_priv->stats.rx_errors;
+
+	for (j = 0; j < DPAA_BPS_NUM; j++) {
+		data[crr * num_values + crr_cpu] = bp_count[j];
+		data[crr++ * num_values + num_cpus] += bp_count[j];
+	}
+}
+
+static void dpaa_get_ethtool_stats(struct net_device *net_dev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	u64 bp_count[DPAA_BPS_NUM], cg_time, cg_num;
+	struct dpaa_percpu_priv *percpu_priv;
+	struct dpaa_rx_errors rx_errors;
+	unsigned int num_cpus, offset;
+	struct dpaa_ern_cnt ern_cnt;
+	struct dpaa_bp *dpaa_bp;
+	struct dpaa_priv *priv;
+	int total_stats, i, j;
+	bool cg_status;
+
+	total_stats = dpaa_get_sset_count(net_dev, ETH_SS_STATS);
+	priv     = netdev_priv(net_dev);
+	num_cpus = num_online_cpus();
+
+	memset(&bp_count, 0, sizeof(bp_count));
+	memset(&rx_errors, 0, sizeof(struct dpaa_rx_errors));
+	memset(&ern_cnt, 0, sizeof(struct dpaa_ern_cnt));
+	memset(data, 0, total_stats * sizeof(u64));
+
+	for_each_online_cpu(i) {
+		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
+		for (j = 0; j < DPAA_BPS_NUM; j++) {
+			dpaa_bp = priv->dpaa_bps[j];
+			if (!dpaa_bp->percpu_count)
+				continue;
+			bp_count[j] = *(per_cpu_ptr(dpaa_bp->percpu_count, i));
+		}
+		rx_errors.dme += percpu_priv->rx_errors.dme;
+		rx_errors.fpe += percpu_priv->rx_errors.fpe;
+		rx_errors.fse += percpu_priv->rx_errors.fse;
+		rx_errors.phe += percpu_priv->rx_errors.phe;
+
+		ern_cnt.cg_tdrop     += percpu_priv->ern_cnt.cg_tdrop;
+		ern_cnt.wred         += percpu_priv->ern_cnt.wred;
+		ern_cnt.err_cond     += percpu_priv->ern_cnt.err_cond;
+		ern_cnt.early_window += percpu_priv->ern_cnt.early_window;
+		ern_cnt.late_window  += percpu_priv->ern_cnt.late_window;
+		ern_cnt.fq_tdrop     += percpu_priv->ern_cnt.fq_tdrop;
+		ern_cnt.fq_retired   += percpu_priv->ern_cnt.fq_retired;
+		ern_cnt.orp_zero     += percpu_priv->ern_cnt.orp_zero;
+
+		copy_stats(percpu_priv, num_cpus, i, bp_count, data);
+	}
+
+	offset = (num_cpus + 1) * (DPAA_STATS_PERCPU_LEN + DPAA_BPS_NUM);
+	memcpy(data + offset, &rx_errors, sizeof(struct dpaa_rx_errors));
+
+	offset += sizeof(struct dpaa_rx_errors) / sizeof(u64);
+	memcpy(data + offset, &ern_cnt, sizeof(struct dpaa_ern_cnt));
+
+	/* gather congestion related counters */
+	cg_num    = 0;
+	cg_status = 0;
+	cg_time   = jiffies_to_msecs(priv->cgr_data.congested_jiffies);
+	if (qman_query_cgr_congested(&priv->cgr_data.cgr, &cg_status) == 0) {
+		cg_num    = priv->cgr_data.cgr_congested_count;
+
+		/* reset congestion stats (like QMan API does */
+		priv->cgr_data.congested_jiffies   = 0;
+		priv->cgr_data.cgr_congested_count = 0;
+	}
+
+	offset += sizeof(struct dpaa_ern_cnt) / sizeof(u64);
+	data[offset++] = cg_time;
+	data[offset++] = cg_num;
+	data[offset++] = cg_status;
+}
+
+static void dpaa_get_strings(struct net_device *net_dev, u32 stringset,
+			     u8 *data)
+{
+	unsigned int i, j, num_cpus, size;
+	char string_cpu[ETH_GSTRING_LEN];
+	u8 *strings;
+
+	memset(string_cpu, 0, sizeof(string_cpu));
+	strings   = data;
+	num_cpus  = num_online_cpus();
+	size      = DPAA_STATS_GLOBAL_LEN * ETH_GSTRING_LEN;
+
+	for (i = 0; i < DPAA_STATS_PERCPU_LEN; i++) {
+		for (j = 0; j < num_cpus; j++) {
+			snprintf(string_cpu, ETH_GSTRING_LEN, "%s [CPU %d]",
+				 dpaa_stats_percpu[i], j);
+			memcpy(strings, string_cpu, ETH_GSTRING_LEN);
+			strings += ETH_GSTRING_LEN;
+		}
+		snprintf(string_cpu, ETH_GSTRING_LEN, "%s [TOTAL]",
+			 dpaa_stats_percpu[i]);
+		memcpy(strings, string_cpu, ETH_GSTRING_LEN);
+		strings += ETH_GSTRING_LEN;
+	}
+	for (i = 0; i < DPAA_BPS_NUM; i++) {
+		for (j = 0; j < num_cpus; j++) {
+			snprintf(string_cpu, ETH_GSTRING_LEN,
+				 "bpool %c [CPU %d]", 'a' + i, j);
+			memcpy(strings, string_cpu, ETH_GSTRING_LEN);
+			strings += ETH_GSTRING_LEN;
+		}
+		snprintf(string_cpu, ETH_GSTRING_LEN, "bpool %c [TOTAL]",
+			 'a' + i);
+		memcpy(strings, string_cpu, ETH_GSTRING_LEN);
+		strings += ETH_GSTRING_LEN;
+	}
+	memcpy(strings, dpaa_stats_global, size);
+}
+
 const struct ethtool_ops dpaa_ethtool_ops = {
 	.get_settings = dpaa_get_settings,
 	.set_settings = dpaa_set_settings,
@@ -215,4 +411,7 @@ const struct ethtool_ops dpaa_ethtool_ops = {
 	.get_pauseparam = dpaa_get_pauseparam,
 	.set_pauseparam = dpaa_set_pauseparam,
 	.get_link = ethtool_op_get_link,
+	.get_sset_count = dpaa_get_sset_count,
+	.get_ethtool_stats = dpaa_get_ethtool_stats,
+	.get_strings = dpaa_get_strings,
 };
-- 
2.1.0
