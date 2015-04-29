From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC,v3 08/10] dpaa_eth: add debugfs counters
Date: Wed, 29 Apr 2015 17:56:43 +0300
Message-ID: <1430319405-31280-7-git-send-email-madalin.bucur@freescale.com>
References: <1430319405-31280-1-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-2-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-3-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-4-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-5-git-send-email-madalin.bucur@freescale.com>
 <1430319405-31280-6-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0108.outbound.protection.outlook.com ([65.55.169.108]:28256
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423305AbbD2O5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2015 10:57:00 -0400
In-Reply-To: <1430319405-31280-6-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a series of counters to be exported through debugfs:
- add detailed counters for reception errors;
- add detailed counters for QMan enqueue reject events;
- count the number of fragmented skbs received from the stack;
- count all frames received on the Tx confirmation path;
- add congestion group statistics;
- count the number of interrupts for each CPU.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     | 12 +++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     | 35 ++++++++++++++++++
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  | 41 ++++++++++++++++++++--
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |  2 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  |  1 +
 5 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index c2f1f1a..3a36594 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -98,6 +98,15 @@ static void _dpa_rx_error(struct net_device *net_dev,
 
 	percpu_priv->stats.rx_errors++;
 
+	if (fd->status & FM_PORT_FRM_ERR_DMA)
+		percpu_priv->rx_errors.dme++;
+	if (fd->status & FM_PORT_FRM_ERR_PHYSICAL)
+		percpu_priv->rx_errors.fpe++;
+	if (fd->status & FM_PORT_FRM_ERR_SIZE)
+		percpu_priv->rx_errors.fse++;
+	if (fd->status & FM_PORT_FRM_ERR_PRS_HDR_ERR)
+		percpu_priv->rx_errors.phe++;
+
 	dpa_fd_release(net_dev, fd);
 }
 
@@ -161,6 +170,8 @@ static void __hot _dpa_tx_conf(struct net_device	*net_dev,
 		percpu_priv->stats.tx_errors++;
 	}
 
+	percpu_priv->tx_confirm++;
+
 	skb = _dpa_cleanup_tx_fd(priv, fd);
 
 	dev_kfree_skb(skb);
@@ -296,6 +307,7 @@ static void priv_ern(struct qman_portal		*portal,
 
 	percpu_priv->stats.tx_dropped++;
 	percpu_priv->stats.tx_fifo_errors++;
+	count_ern(percpu_priv, msg);
 
 	/* If we intended this buffer to go into the pool
 	 * when the FM was done, we need to put it in
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index b379424..e6b6630 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -199,6 +199,25 @@ struct dpa_bp {
 	void (*free_buf_cb)(void *addr);
 };
 
+struct dpa_rx_errors {
+	u64 dme;		/* DMA Error */
+	u64 fpe;		/* Frame Physical Error */
+	u64 fse;		/* Frame Size Error */
+	u64 phe;		/* Header Error */
+};
+
+/* Counters for QMan ERN frames - one counter per rejection code */
+struct dpa_ern_cnt {
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
 struct dpa_napi_portal {
 	struct napi_struct napi;
 	struct qman_portal *p;
@@ -207,7 +226,13 @@ struct dpa_napi_portal {
 struct dpa_percpu_priv_s {
 	struct net_device *net_dev;
 	struct dpa_napi_portal *np;
+	u64 in_interrupt;
+	u64 tx_confirm;
+	/* fragmented (non-linear) skbuffs received from the stack */
+	u64 tx_frag_skbuffs;
 	struct rtnl_link_stats64 stats;
+	struct dpa_rx_errors rx_errors;
+	struct dpa_ern_cnt ern_cnt;
 };
 
 struct dpa_priv_s {
@@ -235,6 +260,15 @@ struct dpa_priv_s {
 		 * (and the same) congestion group.
 		 */
 		struct qman_cgr cgr;
+		/* If congested, when it began. Used for performance stats. */
+		u32 congestion_start_jiffies;
+		/* Number of jiffies the Tx port was congested. */
+		u32 congested_jiffies;
+		/**
+		 * Counter for the number of times the CGR
+		 * entered congestion state
+		 */
+		u32 cgr_congested_count;
 	} cgr_data;
 	/* Use a per-port CGR for ingress traffic. */
 	bool use_ingress_cgr;
@@ -296,6 +330,7 @@ static inline int dpaa_eth_napi_schedule(struct dpa_percpu_priv_s *percpu_priv,
 
 			np->p = portal;
 			napi_schedule(&np->napi);
+			percpu_priv->in_interrupt++;
 			return 1;
 		}
 	}
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
index 3949991..fc90285 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
@@ -774,10 +774,15 @@ static void dpaa_eth_cgscn(struct qman_portal *qm, struct qman_cgr *cgr,
 	struct dpa_priv_s *priv = (struct dpa_priv_s *)container_of(cgr,
 		struct dpa_priv_s, cgr_data.cgr);
 
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
 
 int dpaa_eth_cgr_init(struct dpa_priv_s *priv)
@@ -1218,6 +1223,38 @@ dpa_fd_release(const struct net_device *net_dev, const struct qm_fd *fd)
 }
 EXPORT_SYMBOL(dpa_fd_release);
 
+void count_ern(struct dpa_percpu_priv_s *percpu_priv,
+	       const struct qm_mr_entry *msg)
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
+EXPORT_SYMBOL(count_ern);
+
 /**
  * Turn on HW checksum computation for this outgoing frame.
  * If the current protocol is not something we support in this regard
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
index 2cc2fef..32658d1 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
@@ -121,6 +121,8 @@ void dpaa_eth_init_ports(struct mac_device *mac_dev,
 void dpa_release_sgt(struct qm_sg_entry *sgt);
 void __attribute__((nonnull))
 dpa_fd_release(const struct net_device *net_dev, const struct qm_fd *fd);
+void count_ern(struct dpa_percpu_priv_s *percpu_priv,
+	       const struct qm_mr_entry *msg);
 int dpa_enable_tx_csum(struct dpa_priv_s *priv,
 		       struct sk_buff *skb,
 		       struct qm_fd *fd,
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
index c0d15f1..548e5bb 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
@@ -657,6 +657,7 @@ int __hot dpa_tx(struct sk_buff *skb, struct net_device *net_dev)
 	    likely(skb_shinfo(skb)->nr_frags < DPA_SGT_MAX_ENTRIES)) {
 		/* Just create a S/G fd based on the skb */
 		err = skb_to_sg_fd(priv, skb, &fd);
+		percpu_priv->tx_frag_skbuffs++;
 	} else {
 		/* Make sure we have enough headroom to accommodate private
 		 * data, parse results, etc. Normally this shouldn't happen if
-- 
1.7.11.7
