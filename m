From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 1/3] dpaa_eth: use big endian accessors
Date: Thu, 15 Dec 2016 15:13:04 +0200
Message-ID: <1481807586-4798-2-git-send-email-madalin.bucur@nxp.com>
References: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Claudiu Manoil <claudiu.manoil@nxp.com>

Ensure correct access to the big endian QMan HW through proper
accessors.

Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>
Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 71 ++++++++++++++------------
 1 file changed, 37 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 3c48a84..624ba90 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -733,7 +733,7 @@ static int dpaa_eth_cgr_init(struct dpaa_priv *priv)
 	priv->cgr_data.cgr.cb = dpaa_eth_cgscn;
 
 	/* Enable Congestion State Change Notifications and CS taildrop */
-	initcgr.we_mask = QM_CGR_WE_CSCN_EN | QM_CGR_WE_CS_THRES;
+	initcgr.we_mask = cpu_to_be16(QM_CGR_WE_CSCN_EN | QM_CGR_WE_CS_THRES);
 	initcgr.cgr.cscn_en = QM_CGR_EN;
 
 	/* Set different thresholds based on the MAC speed.
@@ -747,7 +747,7 @@ static int dpaa_eth_cgr_init(struct dpaa_priv *priv)
 		cs_th = DPAA_CS_THRESHOLD_1G;
 	qm_cgr_cs_thres_set64(&initcgr.cgr.cs_thres, cs_th, 1);
 
-	initcgr.we_mask |= QM_CGR_WE_CSTD_EN;
+	initcgr.we_mask |= cpu_to_be16(QM_CGR_WE_CSTD_EN);
 	initcgr.cgr.cstd_en = QM_CGR_EN;
 
 	err = qman_create_cgr(&priv->cgr_data.cgr, QMAN_CGR_FLAG_USE_INIT,
@@ -896,18 +896,18 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 	if (dpaa_fq->init) {
 		memset(&initfq, 0, sizeof(initfq));
 
-		initfq.we_mask = QM_INITFQ_WE_FQCTRL;
+		initfq.we_mask = cpu_to_be16(QM_INITFQ_WE_FQCTRL);
 		/* Note: we may get to keep an empty FQ in cache */
-		initfq.fqd.fq_ctrl = QM_FQCTRL_PREFERINCACHE;
+		initfq.fqd.fq_ctrl = cpu_to_be16(QM_FQCTRL_PREFERINCACHE);
 
 		/* Try to reduce the number of portal interrupts for
 		 * Tx Confirmation FQs.
 		 */
 		if (dpaa_fq->fq_type == FQ_TYPE_TX_CONFIRM)
-			initfq.fqd.fq_ctrl |= QM_FQCTRL_HOLDACTIVE;
+			initfq.fqd.fq_ctrl |= cpu_to_be16(QM_FQCTRL_HOLDACTIVE);
 
 		/* FQ placement */
-		initfq.we_mask |= QM_INITFQ_WE_DESTWQ;
+		initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_DESTWQ);
 
 		qm_fqd_set_destwq(&initfq.fqd, dpaa_fq->channel, dpaa_fq->wq);
 
@@ -920,8 +920,8 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 		if (dpaa_fq->fq_type == FQ_TYPE_TX ||
 		    dpaa_fq->fq_type == FQ_TYPE_TX_CONFIRM ||
 		    dpaa_fq->fq_type == FQ_TYPE_TX_CONF_MQ) {
-			initfq.we_mask |= QM_INITFQ_WE_CGID;
-			initfq.fqd.fq_ctrl |= QM_FQCTRL_CGE;
+			initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_CGID);
+			initfq.fqd.fq_ctrl |= cpu_to_be16(QM_FQCTRL_CGE);
 			initfq.fqd.cgid = (u8)priv->cgr_data.cgr.cgrid;
 			/* Set a fixed overhead accounting, in an attempt to
 			 * reduce the impact of fixed-size skb shells and the
@@ -932,7 +932,7 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 			 * insufficient value, but even that is better than
 			 * no overhead accounting at all.
 			 */
-			initfq.we_mask |= QM_INITFQ_WE_OAC;
+			initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_OAC);
 			qm_fqd_set_oac(&initfq.fqd, QM_OAC_CG);
 			qm_fqd_set_oal(&initfq.fqd,
 				       min(sizeof(struct sk_buff) +
@@ -941,9 +941,9 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 		}
 
 		if (td_enable) {
-			initfq.we_mask |= QM_INITFQ_WE_TDTHRESH;
+			initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_TDTHRESH);
 			qm_fqd_set_taildrop(&initfq.fqd, DPAA_FQ_TD, 1);
-			initfq.fqd.fq_ctrl = QM_FQCTRL_TDE;
+			initfq.fqd.fq_ctrl = cpu_to_be16(QM_FQCTRL_TDE);
 		}
 
 		if (dpaa_fq->fq_type == FQ_TYPE_TX) {
@@ -951,7 +951,8 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 			if (queue_id >= 0)
 				confq = priv->conf_fqs[queue_id];
 			if (confq) {
-				initfq.we_mask |= QM_INITFQ_WE_CONTEXTA;
+				initfq.we_mask |=
+					cpu_to_be16(QM_INITFQ_WE_CONTEXTA);
 			/* ContextA: OVOM=1(use contextA2 bits instead of ICAD)
 			 *	     A2V=1 (contextA A2 field is valid)
 			 *	     A0V=1 (contextA A0 field is valid)
@@ -959,8 +960,8 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 			 * ContextA A2: EBD=1 (deallocate buffers inside FMan)
 			 * ContextB B0(ASPID): 0 (absolute Virtual Storage ID)
 			 */
-				initfq.fqd.context_a.hi = 0x1e000000;
-				initfq.fqd.context_a.lo = 0x80000000;
+				qm_fqd_context_a_set64(&initfq.fqd,
+						       0x1e00000080000000ULL);
 			}
 		}
 
@@ -968,13 +969,13 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 		if (priv->use_ingress_cgr &&
 		    (dpaa_fq->fq_type == FQ_TYPE_RX_DEFAULT ||
 		     dpaa_fq->fq_type == FQ_TYPE_RX_ERROR)) {
-			initfq.we_mask |= QM_INITFQ_WE_CGID;
-			initfq.fqd.fq_ctrl |= QM_FQCTRL_CGE;
+			initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_CGID);
+			initfq.fqd.fq_ctrl |= cpu_to_be16(QM_FQCTRL_CGE);
 			initfq.fqd.cgid = (u8)priv->ingress_cgr.cgrid;
 			/* Set a fixed overhead accounting, just like for the
 			 * egress CGR.
 			 */
-			initfq.we_mask |= QM_INITFQ_WE_OAC;
+			initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_OAC);
 			qm_fqd_set_oac(&initfq.fqd, QM_OAC_CG);
 			qm_fqd_set_oal(&initfq.fqd,
 				       min(sizeof(struct sk_buff) +
@@ -984,9 +985,8 @@ static int dpaa_fq_init(struct dpaa_fq *dpaa_fq, bool td_enable)
 
 		/* Initialization common to all ingress queues */
 		if (dpaa_fq->flags & QMAN_FQ_FLAG_NO_ENQUEUE) {
-			initfq.we_mask |= QM_INITFQ_WE_CONTEXTA;
-			initfq.fqd.fq_ctrl |=
-				QM_FQCTRL_HOLDACTIVE;
+			initfq.we_mask |= cpu_to_be16(QM_INITFQ_WE_CONTEXTA);
+			initfq.fqd.fq_ctrl |= cpu_to_be16(QM_FQCTRL_HOLDACTIVE);
 			initfq.fqd.context_a.stashing.exclusive =
 				QM_STASHING_EXCL_DATA | QM_STASHING_EXCL_CTX |
 				QM_STASHING_EXCL_ANNOTATION;
@@ -1350,7 +1350,7 @@ static int dpaa_enable_tx_csum(struct dpaa_priv *priv,
 	parse_result->l4_off = (u8)skb_transport_offset(skb);
 
 	/* Enable L3 (and L4, if TCP or UDP) HW checksum. */
-	fd->cmd |= FM_FD_CMD_RPD | FM_FD_CMD_DTC;
+	fd->cmd |= cpu_to_be32(FM_FD_CMD_RPD | FM_FD_CMD_DTC);
 
 	/* On P1023 and similar platforms fd->cmd interpretation could
 	 * be disabled by setting CONTEXT_A bit ICMD; currently this bit
@@ -1732,7 +1732,7 @@ static int skb_to_contig_fd(struct dpaa_priv *priv,
 
 	/* Fill in the rest of the FD fields */
 	qm_fd_set_contig(fd, priv->tx_headroom, skb->len);
-	fd->cmd |= FM_FD_CMD_FCO;
+	fd->cmd |= cpu_to_be32(FM_FD_CMD_FCO);
 
 	/* Map the entire buffer size that may be seen by FMan, but no more */
 	addr = dma_map_single(dev, skbh,
@@ -1840,7 +1840,7 @@ static int skb_to_sg_fd(struct dpaa_priv *priv,
 	}
 
 	fd->bpid = FSL_DPAA_BPID_INV;
-	fd->cmd |= FM_FD_CMD_FCO;
+	fd->cmd |= cpu_to_be32(FM_FD_CMD_FCO);
 	qm_fd_addr_set64(fd, addr);
 
 	return 0;
@@ -1867,7 +1867,7 @@ static inline int dpaa_xmit(struct dpaa_priv *priv,
 
 	egress_fq = priv->egress_fqs[queue];
 	if (fd->bpid == FSL_DPAA_BPID_INV)
-		fd->cmd |= qman_fq_fqid(priv->conf_fqs[queue]);
+		fd->cmd |= cpu_to_be32(qman_fq_fqid(priv->conf_fqs[queue]));
 
 	/* Trace this Tx fd */
 	trace_dpaa_tx_fd(priv->net_dev, egress_fq, fd);
@@ -1960,17 +1960,17 @@ static void dpaa_rx_error(struct net_device *net_dev,
 {
 	if (net_ratelimit())
 		netif_err(priv, hw, net_dev, "Err FD status = 0x%08x\n",
-			  fd->status & FM_FD_STAT_RX_ERRORS);
+			  be32_to_cpu(fd->status) & FM_FD_STAT_RX_ERRORS);
 
 	percpu_priv->stats.rx_errors++;
 
-	if (fd->status & FM_FD_ERR_DMA)
+	if (be32_to_cpu(fd->status) & FM_FD_ERR_DMA)
 		percpu_priv->rx_errors.dme++;
-	if (fd->status & FM_FD_ERR_PHYSICAL)
+	if (be32_to_cpu(fd->status) & FM_FD_ERR_PHYSICAL)
 		percpu_priv->rx_errors.fpe++;
-	if (fd->status & FM_FD_ERR_SIZE)
+	if (be32_to_cpu(fd->status) & FM_FD_ERR_SIZE)
 		percpu_priv->rx_errors.fse++;
-	if (fd->status & FM_FD_ERR_PRS_HDR_ERR)
+	if (be32_to_cpu(fd->status) & FM_FD_ERR_PRS_HDR_ERR)
 		percpu_priv->rx_errors.phe++;
 
 	dpaa_fd_release(net_dev, fd);
@@ -1986,7 +1986,7 @@ static void dpaa_tx_error(struct net_device *net_dev,
 
 	if (net_ratelimit())
 		netif_warn(priv, hw, net_dev, "FD status = 0x%08x\n",
-			   fd->status & FM_FD_STAT_TX_ERRORS);
+			   be32_to_cpu(fd->status) & FM_FD_STAT_TX_ERRORS);
 
 	percpu_priv->stats.tx_errors++;
 
@@ -2020,10 +2020,11 @@ static void dpaa_tx_conf(struct net_device *net_dev,
 {
 	struct sk_buff	*skb;
 
-	if (unlikely(fd->status & FM_FD_STAT_TX_ERRORS) != 0) {
+	if (unlikely(be32_to_cpu(fd->status) & FM_FD_STAT_TX_ERRORS)) {
 		if (net_ratelimit())
 			netif_warn(priv, hw, net_dev, "FD status = 0x%08x\n",
-				   fd->status & FM_FD_STAT_TX_ERRORS);
+				   be32_to_cpu(fd->status) &
+				   FM_FD_STAT_TX_ERRORS);
 
 		percpu_priv->stats.tx_errors++;
 	}
@@ -2100,6 +2101,8 @@ static enum qman_cb_dqrr_result rx_default_dqrr(struct qman_portal *portal,
 	struct sk_buff *skb;
 	int *count_ptr;
 
+	fd_status = be32_to_cpu(fd->status);
+	fd_format = qm_fd_get_format(fd);
 	net_dev = ((struct dpaa_fq *)fq)->net_dev;
 	priv = netdev_priv(net_dev);
 	dpaa_bp = dpaa_bpid2pool(dq->fd.bpid);
@@ -2417,12 +2420,12 @@ static int dpaa_ingress_cgr_init(struct dpaa_priv *priv)
 	}
 
 	/* Enable CS TD, but disable Congestion State Change Notifications. */
-	initcgr.we_mask = QM_CGR_WE_CS_THRES;
+	initcgr.we_mask = cpu_to_be16(QM_CGR_WE_CS_THRES);
 	initcgr.cgr.cscn_en = QM_CGR_EN;
 	cs_th = DPAA_INGRESS_CS_THRESHOLD;
 	qm_cgr_cs_thres_set64(&initcgr.cgr.cs_thres, cs_th, 1);
 
-	initcgr.we_mask |= QM_CGR_WE_CSTD_EN;
+	initcgr.we_mask |= cpu_to_be16(QM_CGR_WE_CSTD_EN);
 	initcgr.cgr.cstd_en = QM_CGR_EN;
 
 	/* This CGR will be associated with the SWP affined to the current CPU.
-- 
2.1.0
