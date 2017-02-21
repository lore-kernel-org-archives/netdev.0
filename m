From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 7/9] dpaa_eth: do not ignore port api return value
Date: Tue, 21 Feb 2017 13:52:52 +0200
Message-ID: <1487677974-13678-8-git-send-email-madalin.bucur@nxp.com>
References: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <camelia.groza@nxp.com>, <linuxppc-dev@lists.ozlabs.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0062.outbound.protection.outlook.com ([104.47.34.62]:37936
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752258AbdBULxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 06:53:53 -0500
In-Reply-To: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 65 +++++++++++++++++---------
 1 file changed, 43 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index a7a595c..ae64cdb 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -1063,9 +1063,9 @@ static int dpaa_fq_free(struct device *dev, struct list_head *list)
 	return err;
 }
 
-static void dpaa_eth_init_tx_port(struct fman_port *port, struct dpaa_fq *errq,
-				  struct dpaa_fq *defq,
-				  struct dpaa_buffer_layout *buf_layout)
+static int dpaa_eth_init_tx_port(struct fman_port *port, struct dpaa_fq *errq,
+				 struct dpaa_fq *defq,
+				 struct dpaa_buffer_layout *buf_layout)
 {
 	struct fman_buffer_prefix_content buf_prefix_content;
 	struct fman_port_params params;
@@ -1084,23 +1084,29 @@ static void dpaa_eth_init_tx_port(struct fman_port *port, struct dpaa_fq *errq,
 	params.specific_params.non_rx_params.dflt_fqid = defq->fqid;
 
 	err = fman_port_config(port, &params);
-	if (err)
+	if (err) {
 		pr_err("%s: fman_port_config failed\n", __func__);
+		return err;
+	}
 
 	err = fman_port_cfg_buf_prefix_content(port, &buf_prefix_content);
-	if (err)
+	if (err) {
 		pr_err("%s: fman_port_cfg_buf_prefix_content failed\n",
 		       __func__);
+		return err;
+	}
 
 	err = fman_port_init(port);
 	if (err)
 		pr_err("%s: fm_port_init failed\n", __func__);
+
+	return err;
 }
 
-static void dpaa_eth_init_rx_port(struct fman_port *port, struct dpaa_bp **bps,
-				  size_t count, struct dpaa_fq *errq,
-				  struct dpaa_fq *defq,
-				  struct dpaa_buffer_layout *buf_layout)
+static int dpaa_eth_init_rx_port(struct fman_port *port, struct dpaa_bp **bps,
+				 size_t count, struct dpaa_fq *errq,
+				 struct dpaa_fq *defq,
+				 struct dpaa_buffer_layout *buf_layout)
 {
 	struct fman_buffer_prefix_content buf_prefix_content;
 	struct fman_port_rx_params *rx_p;
@@ -1128,32 +1134,44 @@ static void dpaa_eth_init_rx_port(struct fman_port *port, struct dpaa_bp **bps,
 	}
 
 	err = fman_port_config(port, &params);
-	if (err)
+	if (err) {
 		pr_err("%s: fman_port_config failed\n", __func__);
+		return err;
+	}
 
 	err = fman_port_cfg_buf_prefix_content(port, &buf_prefix_content);
-	if (err)
+	if (err) {
 		pr_err("%s: fman_port_cfg_buf_prefix_content failed\n",
 		       __func__);
+		return err;
+	}
 
 	err = fman_port_init(port);
 	if (err)
 		pr_err("%s: fm_port_init failed\n", __func__);
+
+	return err;
 }
 
-static void dpaa_eth_init_ports(struct mac_device *mac_dev,
-				struct dpaa_bp **bps, size_t count,
-				struct fm_port_fqs *port_fqs,
-				struct dpaa_buffer_layout *buf_layout,
-				struct device *dev)
+static int dpaa_eth_init_ports(struct mac_device *mac_dev,
+			       struct dpaa_bp **bps, size_t count,
+			       struct fm_port_fqs *port_fqs,
+			       struct dpaa_buffer_layout *buf_layout,
+			       struct device *dev)
 {
 	struct fman_port *rxport = mac_dev->port[RX];
 	struct fman_port *txport = mac_dev->port[TX];
+	int err;
 
-	dpaa_eth_init_tx_port(txport, port_fqs->tx_errq,
-			      port_fqs->tx_defq, &buf_layout[TX]);
-	dpaa_eth_init_rx_port(rxport, bps, count, port_fqs->rx_errq,
-			      port_fqs->rx_defq, &buf_layout[RX]);
+	err = dpaa_eth_init_tx_port(txport, port_fqs->tx_errq,
+				    port_fqs->tx_defq, &buf_layout[TX]);
+	if (err)
+		return err;
+
+	err = dpaa_eth_init_rx_port(rxport, bps, count, port_fqs->rx_errq,
+				    port_fqs->rx_defq, &buf_layout[RX]);
+
+	return err;
 }
 
 static int dpaa_bman_release(const struct dpaa_bp *dpaa_bp,
@@ -2649,8 +2667,10 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 	priv->rx_headroom = dpaa_get_headroom(&priv->buf_layout[RX]);
 
 	/* All real interfaces need their ports initialized */
-	dpaa_eth_init_ports(mac_dev, dpaa_bps, DPAA_BPS_NUM, &port_fqs,
-			    &priv->buf_layout[0], dev);
+	err = dpaa_eth_init_ports(mac_dev, dpaa_bps, DPAA_BPS_NUM, &port_fqs,
+				  &priv->buf_layout[0], dev);
+	if (err)
+		goto init_ports_failed;
 
 	priv->percpu_priv = devm_alloc_percpu(dev, *priv->percpu_priv);
 	if (!priv->percpu_priv) {
@@ -2683,6 +2703,7 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 napi_add_failed:
 	dpaa_napi_del(net_dev);
 alloc_percpu_failed:
+init_ports_failed:
 	dpaa_fq_free(dev, &priv->dpaa_fq_list);
 fq_alloc_failed:
 	qman_delete_cgr_safe(&priv->ingress_cgr);
-- 
2.1.0
