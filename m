From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 7/7] cpsw: use the time stamping capabilities of the cpts
Date: Mon, 15 Oct 2012 21:48:13 +0200
Message-ID: <9291e80fa37f8e05d5dea211d80b53cb66f8d1de.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:51747 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab2JOTt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:49:27 -0400
Received: by mail-wg0-f42.google.com with SMTP id fm10so14715wgb.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:49:25 -0700 (PDT)
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index aeaa3bb..06a134f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -35,6 +35,7 @@
 #include <linux/platform_data/cpsw.h>
 
 #include "cpsw_ale.h"
+#include "cpts.h"
 #include "davinci_cpdma.h"
 
 #define CPSW_DEBUG	(NETIF_MSG_HW		| NETIF_MSG_WOL		| \
@@ -236,6 +237,7 @@ struct cpsw_priv {
 	/* snapshot of IRQ numbers */
 	u32 irqs_table[4];
 	u32 num_irqs;
+	struct cpts cpts;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
@@ -272,6 +274,7 @@ void cpsw_tx_handler(void *token, int len, int status)
 
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
+	cpts_tx_timestamp(&priv->cpts, skb);
 	priv->stats.tx_packets++;
 	priv->stats.tx_bytes += len;
 	dev_kfree_skb_any(skb);
@@ -292,6 +295,7 @@ void cpsw_rx_handler(void *token, int len, int status)
 	}
 	if (likely(status >= 0)) {
 		skb_put(skb, len);
+		cpts_rx_timestamp(&priv->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
 		netif_receive_skb(skb);
 		priv->stats.rx_bytes += len;
@@ -610,6 +614,11 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
+	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP && priv->cpts.tx_enable)
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+
+	skb_tx_timestamp(skb);
+
 	ret = cpdma_chan_submit(priv->txch, skb, skb->data,
 				skb->len, GFP_KERNEL);
 	if (unlikely(ret != 0)) {
@@ -647,6 +656,21 @@ static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
 		dev_err(&ndev->dev, "multicast traffic cannot be filtered!\n");
 }
 
+static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
+{
+	struct cpsw_priv *priv = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return cpts_hwtstamp_ioctl(&priv->cpts, req);
+	}
+
+	return -ENOTSUPP;
+}
+
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
@@ -687,6 +711,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_stop		= cpsw_ndo_stop,
 	.ndo_start_xmit		= cpsw_ndo_start_xmit,
 	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
+	.ndo_do_ioctl		= cpsw_ndo_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
@@ -988,6 +1013,8 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	priv->regs = regs;
 	priv->host_port = data->host_port_num;
 	priv->host_port_regs = regs + data->host_port_reg_ofs;
+	priv->cpts.reg = regs + data->cpts_reg_ofs;
+	priv->cpts.tsp = regs + priv->data.slave_data[0].slave_reg_ofs;
 
 	priv->cpsw_ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	if (!priv->cpsw_ss_res) {
@@ -1109,6 +1136,11 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		goto clean_irq_ret;
 	}
 
+	if (cpts_register(&pdev->dev, &priv->cpts))
+		dev_err(priv->dev, "error registering cpts device\n");
+
+	__raw_writel(ETH_P_1588, &priv->regs->ts_ltype);
+
 	cpsw_notice(priv, probe, "initialized device (regs %x, irq %d)\n",
 		  priv->cpsw_res->start, ndev->irq);
 
@@ -1148,6 +1180,7 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
 	pr_info("removing device");
 	platform_set_drvdata(pdev, NULL);
 
+	cpts_unregister(&priv->cpts);
 	free_irq(ndev->irq, priv);
 	cpsw_ale_destroy(priv->ale);
 	cpdma_chan_destroy(priv->txch);
-- 
1.7.2.5
