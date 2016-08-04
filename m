From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 3/3] net: ethernet: ti: cpsw: split common driver data and private net data
Date: Fri,  5 Aug 2016 00:14:32 +0300
Message-ID: <1470345272-874-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
	linux-kernel@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34083 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966678AbcHDVOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 17:14:47 -0400
Received: by mail-lf0-f43.google.com with SMTP id l69so190482577lfg.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 14:14:45 -0700 (PDT)
In-Reply-To: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify driver by splitting common driver data and net dev
private data. In case of dual_emac mode 2 networks devices
are created, each of them contains its own private data.
But 2 net devices share a bunch of h/w resources, that shouldn't
be duplicated.
This patch leads to the following:
- no functional changes
- reduce code size
- reduce memory usage
- reduce number of conversion to priv function
- reduce number of arguments for some functions
- increase code readability
- create prerequisites to add multichannel support,
  when channels are shared between net devices

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 775 +++++++++++++++++++----------------------
 1 file changed, 364 insertions(+), 411 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 85ee9f5..7a84515 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -141,8 +141,8 @@ do {								\
 #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
 
 #define cpsw_slave_index(priv)				\
-		((priv->data.dual_emac) ? priv->emac_port :	\
-		priv->data.active_slave)
+		((cpsw->data.dual_emac) ? priv->emac_port :	\
+		cpsw->data.active_slave)
 
 static int debug_level;
 module_param(debug_level, int, 0);
@@ -364,29 +364,34 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 }
 
 struct cpsw_priv {
-	struct platform_device		*pdev;
 	struct net_device		*ndev;
-	struct napi_struct		napi_rx;
-	struct napi_struct		napi_tx;
 	struct device			*dev;
+	u8				mac_addr[ETH_ALEN];
+	bool				rx_pause;
+	bool				tx_pause;
+	u32				msg_enable;
+	u32				emac_port;
+};
+
+struct cpsw_common {
+	struct net_device		*ndev; /* holds base ndev */
+	struct platform_device		*pdev;
 	struct cpsw_platform_data	data;
+	struct napi_struct		napi_rx;
+	struct napi_struct		napi_tx;
+	struct cpdma_chan		*txch, *rxch;
+	struct cpsw_slave		*slaves;
 	struct cpsw_ss_regs __iomem	*regs;
 	struct cpsw_wr_regs __iomem	*wr_regs;
 	u8 __iomem			*hw_stats;
 	struct cpsw_host_regs __iomem	*host_port_regs;
-	u32				msg_enable;
-	u32				version;
-	u32				coal_intvl;
-	u32				bus_freq_mhz;
-	int				rx_packet_max;
 	struct clk			*clk;
-	u8				mac_addr[ETH_ALEN];
-	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
-	struct cpdma_chan		*txch, *rxch;
 	struct cpsw_ale			*ale;
-	bool				rx_pause;
-	bool				tx_pause;
+	int				rx_packet_max;
+	u32				bus_freq_mhz;
+	u32				version;
+	u32				coal_intvl;
 	bool				quirk_irq;
 	bool				rx_irq_disabled;
 	bool				tx_irq_disabled;
@@ -394,9 +399,10 @@ struct cpsw_priv {
 	u32 irqs_table[4];
 	u32 num_irqs;
 	struct cpts *cpts;
-	u32 emac_port;
 };
 
+static struct cpsw_common *cpsw;
+
 struct cpsw_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int type;
@@ -485,78 +491,79 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 
 #define CPSW_STATS_LEN	ARRAY_SIZE(cpsw_gstrings_stats)
 
-#define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
 #define for_each_slave(priv, func, arg...)				\
 	do {								\
 		struct cpsw_slave *slave;				\
 		int n;							\
-		if (priv->data.dual_emac)				\
-			(func)((priv)->slaves + priv->emac_port, ##arg);\
+		if (cpsw->data.dual_emac)				\
+			(func)(cpsw->slaves + priv->emac_port, ##arg);\
 		else							\
-			for (n = (priv)->data.slaves,			\
-					slave = (priv)->slaves;		\
+			for (n = cpsw->data.slaves,			\
+					slave = cpsw->slaves;		\
 					n; n--)				\
 				(func)(slave++, ##arg);			\
 	} while (0)
-#define cpsw_get_slave_ndev(priv, __slave_no__)				\
-	((__slave_no__ < priv->data.slaves) ?				\
-		priv->slaves[__slave_no__].ndev : NULL)
-#define cpsw_get_slave_priv(priv, __slave_no__)				\
-	(((__slave_no__ < priv->data.slaves) &&				\
-		(priv->slaves[__slave_no__].ndev)) ?			\
-		netdev_priv(priv->slaves[__slave_no__].ndev) : NULL)	\
+#define cpsw_get_slave_ndev(__slave_no__)				\
+	((__slave_no__ < cpsw->data.slaves) ?				\
+		cpsw->slaves[__slave_no__].ndev : NULL)
+#define cpsw_get_slave_priv(__slave_no__)				\
+	(((__slave_no__ < cpsw->data.slaves) &&				\
+		(cpsw->slaves[__slave_no__].ndev)) ?			\
+		netdev_priv(cpsw->slaves[__slave_no__].ndev) : NULL)	\
 
 #define cpsw_dual_emac_src_port_detect(status, priv, ndev, skb)		\
 	do {								\
-		if (!priv->data.dual_emac)				\
+		if (!cpsw->data.dual_emac) {				\
+			priv = netdev_priv(ndev);			\
 			break;						\
+		}							\
+									\
 		if (CPDMA_RX_SOURCE_PORT(status) == 1) {		\
-			ndev = cpsw_get_slave_ndev(priv, 0);		\
+			ndev = cpsw_get_slave_ndev(0);		\
 			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		} else if (CPDMA_RX_SOURCE_PORT(status) == 2) {		\
-			ndev = cpsw_get_slave_ndev(priv, 1);		\
+			ndev = cpsw_get_slave_ndev(1);		\
 			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		}							\
 	} while (0)
 #define cpsw_add_mcast(priv, addr)					\
 	do {								\
-		if (priv->data.dual_emac) {				\
-			struct cpsw_slave *slave = priv->slaves +	\
+		if (cpsw->data.dual_emac) {				\
+			struct cpsw_slave *slave = cpsw->slaves +	\
 						priv->emac_port;	\
-			int slave_port = cpsw_get_slave_port(priv,	\
+			int slave_port = cpsw_get_slave_port(		\
 						slave->slave_num);	\
-			cpsw_ale_add_mcast(priv->ale, addr,		\
+			cpsw_ale_add_mcast(cpsw->ale, addr,		\
 				1 << slave_port | ALE_PORT_HOST,	\
 				ALE_VLAN, slave->port_vlan, 0);		\
 		} else {						\
-			cpsw_ale_add_mcast(priv->ale, addr,		\
+			cpsw_ale_add_mcast(cpsw->ale, addr,		\
 				ALE_ALL_PORTS,				\
 				0, 0, 0);				\
 		}							\
 	} while (0)
 
-static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
+static inline int cpsw_get_slave_port(u32 slave_num)
 {
 	return slave_num + 1;
 }
 
 static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpsw_ale *ale = priv->ale;
+	struct cpsw_ale *ale = cpsw->ale;
 	int i;
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		bool flag = false;
 
 		/* Enabling promiscuous mode for one interface will be
 		 * common for both the interface as the interface shares
 		 * the same hardware resource.
 		 */
-		for (i = 0; i < priv->data.slaves; i++)
-			if (priv->slaves[i].ndev->flags & IFF_PROMISC)
+		for (i = 0; i < cpsw->data.slaves; i++)
+			if (cpsw->slaves[i].ndev->flags & IFF_PROMISC)
 				flag = true;
 
 		if (!enable && flag) {
@@ -579,7 +586,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			unsigned long timeout = jiffies + HZ;
 
 			/* Disable Learn for all ports (host is port 0 and slaves are port 1 and up */
-			for (i = 0; i <= priv->data.slaves; i++) {
+			for (i = 0; i <= cpsw->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 1);
 				cpsw_ale_control_set(ale, i,
@@ -606,7 +613,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 0);
 
 			/* Enable Learn for all ports (host is port 0 and slaves are port 1 and up */
-			for (i = 0; i <= priv->data.slaves; i++) {
+			for (i = 0; i <= cpsw->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 0);
 				cpsw_ale_control_set(ale, i,
@@ -622,15 +629,15 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int vid;
 
-	if (priv->data.dual_emac)
-		vid = priv->slaves[priv->emac_port].port_vlan;
+	if (cpsw->data.dual_emac)
+		vid = cpsw->slaves[priv->emac_port].port_vlan;
 	else
-		vid = priv->data.default_vlan;
+		vid = cpsw->data.default_vlan;
 
 	if (ndev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
 		cpsw_set_promiscious(ndev, true);
-		cpsw_ale_set_allmulti(priv->ale, IFF_ALLMULTI);
+		cpsw_ale_set_allmulti(cpsw->ale, IFF_ALLMULTI);
 		return;
 	} else {
 		/* Disable promiscuous mode */
@@ -638,10 +645,10 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	}
 
 	/* Restore allmulti on vlans if necessary */
-	cpsw_ale_set_allmulti(priv->ale, priv->ndev->flags & IFF_ALLMULTI);
+	cpsw_ale_set_allmulti(cpsw->ale, priv->ndev->flags & IFF_ALLMULTI);
 
 	/* Clear all mcast from ALE */
-	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS, vid);
+	cpsw_ale_flush_multicast(cpsw->ale, ALE_ALL_PORTS, vid);
 
 	if (!netdev_mc_empty(ndev)) {
 		struct netdev_hw_addr *ha;
@@ -653,21 +660,21 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	}
 }
 
-static void cpsw_intr_enable(struct cpsw_priv *priv)
+static void cpsw_intr_enable(void)
 {
-	__raw_writel(0xFF, &priv->wr_regs->tx_en);
-	__raw_writel(0xFF, &priv->wr_regs->rx_en);
+	__raw_writel(0xFF, &cpsw->wr_regs->tx_en);
+	__raw_writel(0xFF, &cpsw->wr_regs->rx_en);
 
-	cpdma_ctlr_int_ctrl(priv->dma, true);
+	cpdma_ctlr_int_ctrl(cpsw->dma, true);
 	return;
 }
 
-static void cpsw_intr_disable(struct cpsw_priv *priv)
+static void cpsw_intr_disable(void)
 {
-	__raw_writel(0, &priv->wr_regs->tx_en);
-	__raw_writel(0, &priv->wr_regs->rx_en);
+	__raw_writel(0, &cpsw->wr_regs->tx_en);
+	__raw_writel(0, &cpsw->wr_regs->rx_en);
 
-	cpdma_ctlr_int_ctrl(priv->dma, false);
+	cpdma_ctlr_int_ctrl(cpsw->dma, false);
 	return;
 }
 
@@ -675,14 +682,13 @@ static void cpsw_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
-	struct cpsw_priv	*priv = netdev_priv(ndev);
 
 	/* Check whether the queue is stopped due to stalled tx dma, if the
 	 * queue is stopped then start the queue as we have free desc for tx
 	 */
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_wake_queue(ndev);
-	cpts_tx_timestamp(priv->cpts, skb);
+	cpts_tx_timestamp(cpsw->cpts, skb);
 	ndev->stats.tx_packets++;
 	ndev->stats.tx_bytes += len;
 	dev_kfree_skb_any(skb);
@@ -693,19 +699,19 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	struct sk_buff		*skb = token;
 	struct sk_buff		*new_skb;
 	struct net_device	*ndev = skb->dev;
-	struct cpsw_priv	*priv = netdev_priv(ndev);
+	struct cpsw_priv	*priv;
 	int			ret = 0;
 
 	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
 
 	if (unlikely(status < 0) || unlikely(!netif_running(ndev))) {
 		bool ndev_status = false;
-		struct cpsw_slave *slave = priv->slaves;
+		struct cpsw_slave *slave = cpsw->slaves;
 		int n;
 
-		if (priv->data.dual_emac) {
+		if (cpsw->data.dual_emac) {
 			/* In dual emac mode check for all interfaces */
-			for (n = priv->data.slaves; n; n--, slave++)
+			for (n = cpsw->data.slaves; n; n--, slave++)
 				if (netif_running(slave->ndev))
 					ndev_status = true;
 		}
@@ -726,10 +732,10 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		return;
 	}
 
-	new_skb = netdev_alloc_skb_ip_align(ndev, priv->rx_packet_max);
+	new_skb = netdev_alloc_skb_ip_align(ndev, cpsw->rx_packet_max);
 	if (new_skb) {
 		skb_put(skb, len);
-		cpts_rx_timestamp(priv->cpts, skb);
+		cpts_rx_timestamp(cpsw->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
 		netif_receive_skb(skb);
 		ndev->stats.rx_bytes += len;
@@ -740,56 +746,56 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	}
 
 requeue:
-	ret = cpdma_chan_submit(priv->rxch, new_skb, new_skb->data,
-			skb_tailroom(new_skb), 0);
+	ret = cpdma_chan_submit(cpsw->rxch, new_skb, new_skb->data,
+				skb_tailroom(new_skb), 0);
 	if (WARN_ON(ret < 0))
 		dev_kfree_skb_any(new_skb);
 }
 
 static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 {
-	struct cpsw_priv *priv = dev_id;
+	struct cpsw_common *cpsw = dev_id;
 
-	writel(0, &priv->wr_regs->tx_en);
-	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
+	writel(0, &cpsw->wr_regs->tx_en);
+	cpdma_ctlr_eoi(cpsw->dma, CPDMA_EOI_TX);
 
-	if (priv->quirk_irq) {
-		disable_irq_nosync(priv->irqs_table[1]);
-		priv->tx_irq_disabled = true;
+	if (cpsw->quirk_irq) {
+		disable_irq_nosync(cpsw->irqs_table[1]);
+		cpsw->tx_irq_disabled = true;
 	}
 
-	napi_schedule(&priv->napi_tx);
+	napi_schedule(&cpsw->napi_tx);
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 {
-	struct cpsw_priv *priv = dev_id;
+	struct cpsw_common *cpsw = dev_id;
 
-	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
-	writel(0, &priv->wr_regs->rx_en);
+	cpdma_ctlr_eoi(cpsw->dma, CPDMA_EOI_RX);
+	writel(0, &cpsw->wr_regs->rx_en);
 
-	if (priv->quirk_irq) {
-		disable_irq_nosync(priv->irqs_table[0]);
-		priv->rx_irq_disabled = true;
+	if (cpsw->quirk_irq) {
+		disable_irq_nosync(cpsw->irqs_table[0]);
+		cpsw->rx_irq_disabled = true;
 	}
 
-	napi_schedule(&priv->napi_rx);
+	napi_schedule(&cpsw->napi_rx);
 	return IRQ_HANDLED;
 }
 
 static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 {
-	struct cpsw_priv	*priv = napi_to_priv(napi_tx);
+	struct cpsw_priv *priv = netdev_priv(cpsw->ndev);
 	int			num_tx;
 
-	num_tx = cpdma_chan_process(priv->txch, budget);
+	num_tx = cpdma_chan_process(cpsw->txch, budget);
 	if (num_tx < budget) {
 		napi_complete(napi_tx);
-		writel(0xff, &priv->wr_regs->tx_en);
-		if (priv->quirk_irq && priv->tx_irq_disabled) {
-			priv->tx_irq_disabled = false;
-			enable_irq(priv->irqs_table[1]);
+		writel(0xff, &cpsw->wr_regs->tx_en);
+		if (cpsw->quirk_irq && cpsw->tx_irq_disabled) {
+			cpsw->tx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[1]);
 		}
 	}
 
@@ -799,16 +805,16 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 
 static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 {
-	struct cpsw_priv	*priv = napi_to_priv(napi_rx);
+	struct cpsw_priv *priv = netdev_priv(cpsw->ndev);
 	int			num_rx;
 
-	num_rx = cpdma_chan_process(priv->rxch, budget);
+	num_rx = cpdma_chan_process(cpsw->rxch, budget);
 	if (num_rx < budget) {
 		napi_complete(napi_rx);
-		writel(0xff, &priv->wr_regs->rx_en);
-		if (priv->quirk_irq && priv->rx_irq_disabled) {
-			priv->rx_irq_disabled = false;
-			enable_irq(priv->irqs_table[0]);
+		writel(0xff, &cpsw->wr_regs->rx_en);
+		if (cpsw->quirk_irq && cpsw->rx_irq_disabled) {
+			cpsw->rx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[0]);
 		}
 	}
 
@@ -849,13 +855,13 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	if (!phy)
 		return;
 
-	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+	slave_port = cpsw_get_slave_port(slave->slave_num);
 
 	if (phy->link) {
-		mac_control = priv->data.mac_control;
+		mac_control = cpsw->data.mac_control;
 
 		/* enable forwarding */
-		cpsw_ale_control_set(priv->ale, slave_port,
+		cpsw_ale_control_set(cpsw->ale, slave_port,
 				     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
 		if (phy->speed == 1000)
@@ -879,7 +885,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	} else {
 		mac_control = 0;
 		/* disable forwarding */
-		cpsw_ale_control_set(priv->ale, slave_port,
+		cpsw_ale_control_set(cpsw->ale, slave_port,
 				     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
 	}
 
@@ -911,9 +917,7 @@ static void cpsw_adjust_link(struct net_device *ndev)
 static int cpsw_get_coalesce(struct net_device *ndev,
 				struct ethtool_coalesce *coal)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-
-	coal->rx_coalesce_usecs = priv->coal_intvl;
+	coal->rx_coalesce_usecs = cpsw->coal_intvl;
 	return 0;
 }
 
@@ -929,8 +933,8 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 
 	coal_intvl = coal->rx_coalesce_usecs;
 
-	int_ctrl =  readl(&priv->wr_regs->int_control);
-	prescale = priv->bus_freq_mhz * 4;
+	int_ctrl =  readl(&cpsw->wr_regs->int_control);
+	prescale = cpsw->bus_freq_mhz * 4;
 
 	if (!coal->rx_coalesce_usecs) {
 		int_ctrl &= ~(CPSW_INTPRESCALE_MASK | CPSW_INTPACEEN);
@@ -958,27 +962,18 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	}
 
 	num_interrupts = (1000 * addnl_dvdr) / coal_intvl;
-	writel(num_interrupts, &priv->wr_regs->rx_imax);
-	writel(num_interrupts, &priv->wr_regs->tx_imax);
+	writel(num_interrupts, &cpsw->wr_regs->rx_imax);
+	writel(num_interrupts, &cpsw->wr_regs->tx_imax);
 
 	int_ctrl |= CPSW_INTPACEEN;
 	int_ctrl &= (~CPSW_INTPRESCALE_MASK);
 	int_ctrl |= (prescale & CPSW_INTPRESCALE_MASK);
 
 update_return:
-	writel(int_ctrl, &priv->wr_regs->int_control);
+	writel(int_ctrl, &cpsw->wr_regs->int_control);
 
 	cpsw_notice(priv, timer, "Set coalesce to %d usecs.\n", coal_intvl);
-	if (priv->data.dual_emac) {
-		int i;
-
-		for (i = 0; i < priv->data.slaves; i++) {
-			priv = netdev_priv(priv->slaves[i].ndev);
-			priv->coal_intvl = coal_intvl;
-		}
-	} else {
-		priv->coal_intvl = coal_intvl;
-	}
+	cpsw->coal_intvl = coal_intvl;
 
 	return 0;
 }
@@ -1012,7 +1007,6 @@ static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 static void cpsw_get_ethtool_stats(struct net_device *ndev,
 				    struct ethtool_stats *stats, u64 *data)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpdma_chan_stats rx_stats;
 	struct cpdma_chan_stats tx_stats;
 	u32 val;
@@ -1020,13 +1014,13 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	int i;
 
 	/* Collect Davinci CPDMA stats for Rx and Tx Channel */
-	cpdma_chan_get_stats(priv->rxch, &rx_stats);
-	cpdma_chan_get_stats(priv->txch, &tx_stats);
+	cpdma_chan_get_stats(cpsw->rxch, &rx_stats);
+	cpdma_chan_get_stats(cpsw->txch, &tx_stats);
 
 	for (i = 0; i < CPSW_STATS_LEN; i++) {
 		switch (cpsw_gstrings_stats[i].type) {
 		case CPSW_STATS:
-			val = readl(priv->hw_stats +
+			val = readl(cpsw->hw_stats +
 				    cpsw_gstrings_stats[i].stat_offset);
 			data[i] = val;
 			break;
@@ -1046,16 +1040,16 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 }
 
-static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
+static int cpsw_common_res_usage_state(void)
 {
 	u32 i;
 	u32 usage_count = 0;
 
-	if (!priv->data.dual_emac)
+	if (!cpsw->data.dual_emac)
 		return 0;
 
-	for (i = 0; i < priv->data.slaves; i++)
-		if (priv->slaves[i].open_stat)
+	for (i = 0; i < cpsw->data.slaves; i++)
+		if (cpsw->slaves[i].open_stat)
 			usage_count++;
 
 	return usage_count;
@@ -1064,8 +1058,8 @@ static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
 static inline int cpsw_tx_packet_submit(struct cpsw_priv *priv,
 					struct sk_buff *skb)
 {
-	return cpdma_chan_submit(priv->txch, skb, skb->data, skb->len,
-				 priv->emac_port + priv->data.dual_emac);
+	return cpdma_chan_submit(cpsw->txch, skb, skb->data, skb->len,
+				 priv->emac_port + cpsw->data.dual_emac);
 }
 
 static inline void cpsw_add_dual_emac_def_ale_entries(
@@ -1074,16 +1068,17 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 {
 	u32 port_mask = 1 << slave_port | ALE_PORT_HOST;
 
-	if (priv->version == CPSW_VERSION_1)
+	if (cpsw->version == CPSW_VERSION_1)
 		slave_write(slave, slave->port_vlan, CPSW1_PORT_VLAN);
 	else
 		slave_write(slave, slave->port_vlan, CPSW2_PORT_VLAN);
-	cpsw_ale_add_vlan(priv->ale, slave->port_vlan, port_mask,
+	cpsw_ale_add_vlan(cpsw->ale, slave->port_vlan, port_mask,
 			  port_mask, port_mask, 0);
-	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+	cpsw_ale_add_mcast(cpsw->ale, priv->ndev->broadcast,
 			   port_mask, ALE_VLAN, slave->port_vlan, 0);
-	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
-		HOST_PORT_NUM, ALE_VLAN | ALE_SECURE, slave->port_vlan);
+	cpsw_ale_add_ucast(cpsw->ale, priv->mac_addr,
+			   HOST_PORT_NUM, ALE_VLAN | ALE_SECURE,
+			   slave->port_vlan);
 }
 
 static void soft_reset_slave(struct cpsw_slave *slave)
@@ -1103,7 +1098,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	/* setup priority mapping */
 	__raw_writel(RX_PRIORITY_MAPPING, &slave->sliver->rx_pri_map);
 
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_1:
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW1_TX_PRI_MAP);
 		break;
@@ -1115,17 +1110,17 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	}
 
 	/* setup max packet size, and mac address */
-	__raw_writel(priv->rx_packet_max, &slave->sliver->rx_maxlen);
+	__raw_writel(cpsw->rx_packet_max, &slave->sliver->rx_maxlen);
 	cpsw_set_slave_mac(slave, priv);
 
 	slave->mac_control = 0;	/* no link yet */
 
-	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+	slave_port = cpsw_get_slave_port(slave->slave_num);
 
-	if (priv->data.dual_emac)
+	if (cpsw->data.dual_emac)
 		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
 	else
-		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+		cpsw_ale_add_mcast(cpsw->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
 	if (slave->data->phy_node) {
@@ -1155,30 +1150,30 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	phy_start(slave->phy);
 
 	/* Configure GMII_SEL register */
-	cpsw_phy_sel(&priv->pdev->dev, slave->phy->interface, slave->slave_num);
+	cpsw_phy_sel(&cpsw->pdev->dev, slave->phy->interface, slave->slave_num);
 }
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 {
-	const int vlan = priv->data.default_vlan;
+	const int vlan = cpsw->data.default_vlan;
 	u32 reg;
 	int i;
 	int unreg_mcast_mask;
 
-	reg = (priv->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
+	reg = (cpsw->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
 	       CPSW2_PORT_VLAN;
 
-	writel(vlan, &priv->host_port_regs->port_vlan);
+	writel(vlan, &cpsw->host_port_regs->port_vlan);
 
-	for (i = 0; i < priv->data.slaves; i++)
-		slave_write(priv->slaves + i, vlan, reg);
+	for (i = 0; i < cpsw->data.slaves; i++)
+		slave_write(cpsw->slaves + i, vlan, reg);
 
 	if (priv->ndev->flags & IFF_ALLMULTI)
 		unreg_mcast_mask = ALE_ALL_PORTS;
 	else
 		unreg_mcast_mask = ALE_PORT_1 | ALE_PORT_2;
 
-	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS,
+	cpsw_ale_add_vlan(cpsw->ale, vlan, ALE_ALL_PORTS,
 			  ALE_ALL_PORTS, ALE_ALL_PORTS,
 			  unreg_mcast_mask);
 }
@@ -1189,47 +1184,47 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	u32 fifo_mode;
 
 	/* soft reset the controller and initialize ale */
-	soft_reset("cpsw", &priv->regs->soft_reset);
-	cpsw_ale_start(priv->ale);
+	soft_reset("cpsw", &cpsw->regs->soft_reset);
+	cpsw_ale_start(cpsw->ale);
 
 	/* switch to vlan unaware mode */
-	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM, ALE_VLAN_AWARE,
+	cpsw_ale_control_set(cpsw->ale, HOST_PORT_NUM, ALE_VLAN_AWARE,
 			     CPSW_ALE_VLAN_AWARE);
-	control_reg = readl(&priv->regs->control);
+	control_reg = readl(&cpsw->regs->control);
 	control_reg |= CPSW_VLAN_AWARE;
-	writel(control_reg, &priv->regs->control);
-	fifo_mode = (priv->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
+	writel(control_reg, &cpsw->regs->control);
+	fifo_mode = (cpsw->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
 		     CPSW_FIFO_NORMAL_MODE;
-	writel(fifo_mode, &priv->host_port_regs->tx_in_ctl);
+	writel(fifo_mode, &cpsw->host_port_regs->tx_in_ctl);
 
 	/* setup host port priority mapping */
 	__raw_writel(CPDMA_TX_PRIORITY_MAP,
-		     &priv->host_port_regs->cpdma_tx_pri_map);
-	__raw_writel(0, &priv->host_port_regs->cpdma_rx_chan_map);
+		     &cpsw->host_port_regs->cpdma_tx_pri_map);
+	__raw_writel(0, &cpsw->host_port_regs->cpdma_rx_chan_map);
 
-	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM,
+	cpsw_ale_control_set(cpsw->ale, HOST_PORT_NUM,
 			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
-	if (!priv->data.dual_emac) {
-		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
+	if (!cpsw->data.dual_emac) {
+		cpsw_ale_add_ucast(cpsw->ale, priv->mac_addr, HOST_PORT_NUM,
 				   0, 0);
-		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+		cpsw_ale_add_mcast(cpsw->ale, priv->ndev->broadcast,
 				   ALE_PORT_HOST, 0, 0, ALE_MCAST_FWD_2);
 	}
 }
 
-static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
+static void cpsw_slave_stop(struct cpsw_slave *slave)
 {
 	u32 slave_port;
 
-	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+	slave_port = cpsw_get_slave_port(slave->slave_num);
 
 	if (!slave->phy)
 		return;
 	phy_stop(slave->phy);
 	phy_disconnect(slave->phy);
 	slave->phy = NULL;
-	cpsw_ale_control_set(priv->ale, slave_port,
+	cpsw_ale_control_set(cpsw->ale, slave_port,
 			     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
 	soft_reset_slave(slave);
 }
@@ -1240,75 +1235,74 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	int i, ret;
 	u32 reg;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
-	if (!cpsw_common_res_usage_state(priv))
-		cpsw_intr_disable(priv);
+	if (!cpsw_common_res_usage_state())
+		cpsw_intr_disable();
 	netif_carrier_off(ndev);
 
-	reg = priv->version;
+	reg = cpsw->version;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
 		 CPSW_MAJOR_VERSION(reg), CPSW_MINOR_VERSION(reg),
 		 CPSW_RTL_VERSION(reg));
 
 	/* initialize host and slave ports */
-	if (!cpsw_common_res_usage_state(priv))
+	if (!cpsw_common_res_usage_state())
 		cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
 	/* Add default VLAN */
-	if (!priv->data.dual_emac)
+	if (!cpsw->data.dual_emac)
 		cpsw_add_default_vlan(priv);
 	else
-		cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
+		cpsw_ale_add_vlan(cpsw->ale, cpsw->data.default_vlan,
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
-	if (!cpsw_common_res_usage_state(priv)) {
-		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
+	if (!cpsw_common_res_usage_state()) {
 		int buf_num;
 
 		/* setup tx dma to fixed prio and zero offset */
-		cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
-		cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
+		cpdma_control_set(cpsw->dma, CPDMA_TX_PRIO_FIXED, 1);
+		cpdma_control_set(cpsw->dma, CPDMA_RX_BUFFER_OFFSET, 0);
 
 		/* disable priority elevation */
-		__raw_writel(0, &priv->regs->ptype);
+		__raw_writel(0, &cpsw->regs->ptype);
 
 		/* enable statistics collection only on all ports */
-		__raw_writel(0x7, &priv->regs->stat_port_en);
+		__raw_writel(0x7, &cpsw->regs->stat_port_en);
 
 		/* Enable internal fifo flow control */
-		writel(0x7, &priv->regs->flow_control);
+		writel(0x7, &cpsw->regs->flow_control);
 
-		napi_enable(&priv_sl0->napi_rx);
-		napi_enable(&priv_sl0->napi_tx);
+		napi_enable(&cpsw->napi_rx);
+		napi_enable(&cpsw->napi_tx);
 
-		if (priv_sl0->tx_irq_disabled) {
-			priv_sl0->tx_irq_disabled = false;
-			enable_irq(priv->irqs_table[1]);
+		if (cpsw->tx_irq_disabled) {
+			cpsw->tx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[1]);
 		}
 
-		if (priv_sl0->rx_irq_disabled) {
-			priv_sl0->rx_irq_disabled = false;
-			enable_irq(priv->irqs_table[0]);
+		if (cpsw->rx_irq_disabled) {
+			cpsw->rx_irq_disabled = false;
+			enable_irq(cpsw->irqs_table[0]);
 		}
 
-		buf_num = cpdma_chan_get_rx_buf_num(priv->dma);
+		buf_num = cpdma_chan_get_rx_buf_num(cpsw->dma);
 		for (i = 0; i < buf_num; i++) {
 			struct sk_buff *skb;
 
 			ret = -ENOMEM;
 			skb = __netdev_alloc_skb_ip_align(priv->ndev,
-					priv->rx_packet_max, GFP_KERNEL);
+					cpsw->rx_packet_max, GFP_KERNEL);
 			if (!skb)
 				goto err_cleanup;
-			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), 0);
+			ret = cpdma_chan_submit(cpsw->rxch, skb, skb->data,
+						skb_tailroom(skb), 0);
 			if (ret < 0) {
 				kfree_skb(skb);
 				goto err_cleanup;
@@ -1319,32 +1313,32 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 */
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
-		if (cpts_register(&priv->pdev->dev, priv->cpts,
-				  priv->data.cpts_clock_mult,
-				  priv->data.cpts_clock_shift))
+		if (cpts_register(&cpsw->pdev->dev, cpsw->cpts,
+				  cpsw->data.cpts_clock_mult,
+				  cpsw->data.cpts_clock_shift))
 			dev_err(priv->dev, "error registering cpts device\n");
 
 	}
 
 	/* Enable Interrupt pacing if configured */
-	if (priv->coal_intvl != 0) {
+	if (cpsw->coal_intvl != 0) {
 		struct ethtool_coalesce coal;
 
-		coal.rx_coalesce_usecs = priv->coal_intvl;
+		coal.rx_coalesce_usecs = cpsw->coal_intvl;
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
-	cpdma_ctlr_start(priv->dma);
-	cpsw_intr_enable(priv);
+	cpdma_ctlr_start(cpsw->dma);
+	cpsw_intr_enable();
 
-	if (priv->data.dual_emac)
-		priv->slaves[priv->emac_port].open_stat = true;
+	if (cpsw->data.dual_emac)
+		cpsw->slaves[priv->emac_port].open_stat = true;
 	return 0;
 
 err_cleanup:
-	cpdma_ctlr_stop(priv->dma);
-	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&priv->pdev->dev);
+	cpdma_ctlr_stop(cpsw->dma);
+	for_each_slave(priv, cpsw_slave_stop);
+	pm_runtime_put_sync(&cpsw->pdev->dev);
 	netif_carrier_off(priv->ndev);
 	return ret;
 }
@@ -1357,20 +1351,18 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_stop_queue(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
-	if (cpsw_common_res_usage_state(priv) <= 1) {
-		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
-
-		napi_disable(&priv_sl0->napi_rx);
-		napi_disable(&priv_sl0->napi_tx);
-		cpts_unregister(priv->cpts);
-		cpsw_intr_disable(priv);
-		cpdma_ctlr_stop(priv->dma);
-		cpsw_ale_stop(priv->ale);
-	}
-	for_each_slave(priv, cpsw_slave_stop, priv);
-	pm_runtime_put_sync(&priv->pdev->dev);
-	if (priv->data.dual_emac)
-		priv->slaves[priv->emac_port].open_stat = false;
+	if (cpsw_common_res_usage_state() <= 1) {
+		napi_disable(&cpsw->napi_rx);
+		napi_disable(&cpsw->napi_tx);
+		cpts_unregister(cpsw->cpts);
+		cpsw_intr_disable();
+		cpdma_ctlr_stop(cpsw->dma);
+		cpsw_ale_stop(cpsw->ale);
+	}
+	for_each_slave(priv, cpsw_slave_stop);
+	pm_runtime_put_sync(&cpsw->pdev->dev);
+	if (cpsw->data.dual_emac)
+		cpsw->slaves[priv->emac_port].open_stat = false;
 	return 0;
 }
 
@@ -1389,7 +1381,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	}
 
 	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-				priv->cpts->tx_enable)
+				cpsw->cpts->tx_enable)
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 	skb_tx_timestamp(skb);
@@ -1403,7 +1395,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	/* If there is no more tx desc left free then we need to
 	 * tell the kernel to stop sending us tx frames.
 	 */
-	if (unlikely(!cpdma_check_free_tx_desc(priv->txch)))
+	if (unlikely(!cpdma_check_free_tx_desc(cpsw->txch)))
 		netif_stop_queue(ndev);
 
 	return NETDEV_TX_OK;
@@ -1415,12 +1407,12 @@ fail:
 
 #ifdef CONFIG_TI_CPTS
 
-static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
+static void cpsw_hwtstamp_v1(void)
 {
-	struct cpsw_slave *slave = &priv->slaves[priv->data.active_slave];
+	struct cpsw_slave *slave = &cpsw->slaves[cpsw->data.active_slave];
 	u32 ts_en, seq_id;
 
-	if (!priv->cpts->tx_enable && !priv->cpts->rx_enable) {
+	if (!cpsw->cpts->tx_enable && !cpsw->cpts->rx_enable) {
 		slave_write(slave, 0, CPSW1_TS_CTL);
 		return;
 	}
@@ -1428,10 +1420,10 @@ static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 	seq_id = (30 << CPSW_V1_SEQ_ID_OFS_SHIFT) | ETH_P_1588;
 	ts_en = EVENT_MSG_BITS << CPSW_V1_MSG_TYPE_OFS;
 
-	if (priv->cpts->tx_enable)
+	if (cpsw->cpts->tx_enable)
 		ts_en |= CPSW_V1_TS_TX_EN;
 
-	if (priv->cpts->rx_enable)
+	if (cpsw->cpts->rx_enable)
 		ts_en |= CPSW_V1_TS_RX_EN;
 
 	slave_write(slave, ts_en, CPSW1_TS_CTL);
@@ -1443,30 +1435,30 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	struct cpsw_slave *slave;
 	u32 ctrl, mtype;
 
-	if (priv->data.dual_emac)
-		slave = &priv->slaves[priv->emac_port];
+	if (cpsw->data.dual_emac)
+		slave = &cpsw->slaves[priv->emac_port];
 	else
-		slave = &priv->slaves[priv->data.active_slave];
+		slave = &cpsw->slaves[cpsw->data.active_slave];
 
 	ctrl = slave_read(slave, CPSW2_CONTROL);
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_2:
 		ctrl &= ~CTRL_V2_ALL_TS_MASK;
 
-		if (priv->cpts->tx_enable)
+		if (cpsw->cpts->tx_enable)
 			ctrl |= CTRL_V2_TX_TS_BITS;
 
-		if (priv->cpts->rx_enable)
+		if (cpsw->cpts->rx_enable)
 			ctrl |= CTRL_V2_RX_TS_BITS;
 		break;
 	case CPSW_VERSION_3:
 	default:
 		ctrl &= ~CTRL_V3_ALL_TS_MASK;
 
-		if (priv->cpts->tx_enable)
+		if (cpsw->cpts->tx_enable)
 			ctrl |= CTRL_V3_TX_TS_BITS;
 
-		if (priv->cpts->rx_enable)
+		if (cpsw->cpts->rx_enable)
 			ctrl |= CTRL_V3_RX_TS_BITS;
 		break;
 	}
@@ -1475,18 +1467,18 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 
 	slave_write(slave, mtype, CPSW2_TS_SEQ_MTYPE);
 	slave_write(slave, ctrl, CPSW2_CONTROL);
-	__raw_writel(ETH_P_1588, &priv->regs->ts_ltype);
+	__raw_writel(ETH_P_1588, &cpsw->regs->ts_ltype);
 }
 
 static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 {
 	struct cpsw_priv *priv = netdev_priv(dev);
-	struct cpts *cpts = priv->cpts;
+	struct cpts *cpts = cpsw->cpts;
 	struct hwtstamp_config cfg;
 
-	if (priv->version != CPSW_VERSION_1 &&
-	    priv->version != CPSW_VERSION_2 &&
-	    priv->version != CPSW_VERSION_3)
+	if (cpsw->version != CPSW_VERSION_1 &&
+	    cpsw->version != CPSW_VERSION_2 &&
+	    cpsw->version != CPSW_VERSION_3)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
@@ -1526,9 +1518,9 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 
 	cpts->tx_enable = cfg.tx_type == HWTSTAMP_TX_ON;
 
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_1:
-		cpsw_hwtstamp_v1(priv);
+		cpsw_hwtstamp_v1();
 		break;
 	case CPSW_VERSION_2:
 	case CPSW_VERSION_3:
@@ -1543,13 +1535,12 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 
 static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 {
-	struct cpsw_priv *priv = netdev_priv(dev);
-	struct cpts *cpts = priv->cpts;
+	struct cpts *cpts = cpsw->cpts;
 	struct hwtstamp_config cfg;
 
-	if (priv->version != CPSW_VERSION_1 &&
-	    priv->version != CPSW_VERSION_2 &&
-	    priv->version != CPSW_VERSION_3)
+	if (cpsw->version != CPSW_VERSION_1 &&
+	    cpsw->version != CPSW_VERSION_2 &&
+	    cpsw->version != CPSW_VERSION_3)
 		return -EOPNOTSUPP;
 
 	cfg.flags = 0;
@@ -1579,9 +1570,9 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 #endif
 	}
 
-	if (!priv->slaves[slave_no].phy)
+	if (!cpsw->slaves[slave_no].phy)
 		return -EOPNOTSUPP;
-	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);
+	return phy_mii_ioctl(cpsw->slaves[slave_no].phy, req, cmd);
 }
 
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
@@ -1590,10 +1581,10 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 
 	cpsw_err(priv, tx_err, "transmit timeout, restarting dma\n");
 	ndev->stats.tx_errors++;
-	cpsw_intr_disable(priv);
-	cpdma_chan_stop(priv->txch);
-	cpdma_chan_start(priv->txch);
-	cpsw_intr_enable(priv);
+	cpsw_intr_disable();
+	cpdma_chan_stop(cpsw->txch);
+	cpdma_chan_start(cpsw->txch);
+	cpsw_intr_enable();
 }
 
 static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
@@ -1607,27 +1598,27 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
-	if (priv->data.dual_emac) {
-		vid = priv->slaves[priv->emac_port].port_vlan;
+	if (cpsw->data.dual_emac) {
+		vid = cpsw->slaves[priv->emac_port].port_vlan;
 		flags = ALE_VLAN;
 	}
 
-	cpsw_ale_del_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
+	cpsw_ale_del_ucast(cpsw->ale, priv->mac_addr, HOST_PORT_NUM,
 			   flags, vid);
-	cpsw_ale_add_ucast(priv->ale, addr->sa_data, HOST_PORT_NUM,
+	cpsw_ale_add_ucast(cpsw->ale, addr->sa_data, HOST_PORT_NUM,
 			   flags, vid);
 
 	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 	for_each_slave(priv, cpsw_set_slave_mac, priv);
 
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 
 	return 0;
 }
@@ -1635,12 +1626,10 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cpsw_ndo_poll_controller(struct net_device *ndev)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-
-	cpsw_intr_disable(priv);
-	cpsw_rx_interrupt(priv->irqs_table[0], priv);
-	cpsw_tx_interrupt(priv->irqs_table[1], priv);
-	cpsw_intr_enable(priv);
+	cpsw_intr_disable();
+	cpsw_rx_interrupt(cpsw->irqs_table[0], cpsw);
+	cpsw_tx_interrupt(cpsw->irqs_table[1], cpsw);
+	cpsw_intr_enable();
 }
 #endif
 
@@ -1651,7 +1640,7 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 	int unreg_mcast_mask = 0;
 	u32 port_mask;
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		port_mask = (1 << (priv->emac_port + 1)) | ALE_PORT_HOST;
 
 		if (priv->ndev->flags & IFF_ALLMULTI)
@@ -1665,27 +1654,27 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 			unreg_mcast_mask = ALE_PORT_1 | ALE_PORT_2;
 	}
 
-	ret = cpsw_ale_add_vlan(priv->ale, vid, port_mask, 0, port_mask,
+	ret = cpsw_ale_add_vlan(cpsw->ale, vid, port_mask, 0, port_mask,
 				unreg_mcast_mask);
 	if (ret != 0)
 		return ret;
 
-	ret = cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
+	ret = cpsw_ale_add_ucast(cpsw->ale, priv->mac_addr,
 				 HOST_PORT_NUM, ALE_VLAN, vid);
 	if (ret != 0)
 		goto clean_vid;
 
-	ret = cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+	ret = cpsw_ale_add_mcast(cpsw->ale, priv->ndev->broadcast,
 				 port_mask, ALE_VLAN, vid, 0);
 	if (ret != 0)
 		goto clean_vlan_ucast;
 	return 0;
 
 clean_vlan_ucast:
-	cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
+	cpsw_ale_del_ucast(cpsw->ale, priv->mac_addr,
 			   HOST_PORT_NUM, ALE_VLAN, vid);
 clean_vid:
-	cpsw_ale_del_vlan(priv->ale, vid, 0);
+	cpsw_ale_del_vlan(cpsw->ale, vid, 0);
 	return ret;
 }
 
@@ -1695,24 +1684,24 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	if (vid == priv->data.default_vlan)
+	if (vid == cpsw->data.default_vlan)
 		return 0;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		/* In dual EMAC, reserved VLAN id should not be used for
 		 * creating VLAN interfaces as this can break the dual
 		 * EMAC port separation
 		 */
 		int i;
 
-		for (i = 0; i < priv->data.slaves; i++) {
-			if (vid == priv->slaves[i].port_vlan)
+		for (i = 0; i < cpsw->data.slaves; i++) {
+			if (vid == cpsw->slaves[i].port_vlan)
 				return -EINVAL;
 		}
 	}
@@ -1720,7 +1709,7 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
 	ret = cpsw_add_vlan_ale_entry(priv, vid);
 
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 	return ret;
 }
 
@@ -1730,37 +1719,37 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	if (vid == priv->data.default_vlan)
+	if (vid == cpsw->data.default_vlan)
 		return 0;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 		return ret;
 	}
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		int i;
 
-		for (i = 0; i < priv->data.slaves; i++) {
-			if (vid == priv->slaves[i].port_vlan)
+		for (i = 0; i < cpsw->data.slaves; i++) {
+			if (vid == cpsw->slaves[i].port_vlan)
 				return -EINVAL;
 		}
 	}
 
 	dev_info(priv->dev, "removing vlanid %d from vlan filter\n", vid);
-	ret = cpsw_ale_del_vlan(priv->ale, vid, 0);
+	ret = cpsw_ale_del_vlan(cpsw->ale, vid, 0);
 	if (ret != 0)
 		return ret;
 
-	ret = cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
+	ret = cpsw_ale_del_ucast(cpsw->ale, priv->mac_addr,
 				 HOST_PORT_NUM, ALE_VLAN, vid);
 	if (ret != 0)
 		return ret;
 
-	ret = cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
+	ret = cpsw_ale_del_mcast(cpsw->ale, priv->ndev->broadcast,
 				 0, ALE_VLAN, vid);
-	pm_runtime_put(&priv->pdev->dev);
+	pm_runtime_put(&cpsw->pdev->dev);
 	return ret;
 }
 
@@ -1783,31 +1772,26 @@ static const struct net_device_ops cpsw_netdev_ops = {
 
 static int cpsw_get_regs_len(struct net_device *ndev)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-
-	return priv->data.ale_entries * ALE_ENTRY_WORDS * sizeof(u32);
+	return cpsw->data.ale_entries * ALE_ENTRY_WORDS * sizeof(u32);
 }
 
 static void cpsw_get_regs(struct net_device *ndev,
 			  struct ethtool_regs *regs, void *p)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
 	u32 *reg = p;
 
 	/* update CPSW IP version */
-	regs->version = priv->version;
+	regs->version = cpsw->version;
 
-	cpsw_ale_dump(priv->ale, reg);
+	cpsw_ale_dump(cpsw->ale, reg);
 }
 
 static void cpsw_get_drvinfo(struct net_device *ndev,
 			     struct ethtool_drvinfo *info)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-
 	strlcpy(info->driver, "cpsw", sizeof(info->driver));
 	strlcpy(info->version, "1.0", sizeof(info->version));
-	strlcpy(info->bus_info, priv->pdev->name, sizeof(info->bus_info));
+	strlcpy(info->bus_info, cpsw->pdev->name, sizeof(info->bus_info));
 }
 
 static u32 cpsw_get_msglevel(struct net_device *ndev)
@@ -1826,8 +1810,6 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 			    struct ethtool_ts_info *info)
 {
 #ifdef CONFIG_TI_CPTS
-	struct cpsw_priv *priv = netdev_priv(ndev);
-
 	info->so_timestamping =
 		SOF_TIMESTAMPING_TX_HARDWARE |
 		SOF_TIMESTAMPING_TX_SOFTWARE |
@@ -1835,7 +1817,7 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 		SOF_TIMESTAMPING_RX_SOFTWARE |
 		SOF_TIMESTAMPING_SOFTWARE |
 		SOF_TIMESTAMPING_RAW_HARDWARE;
-	info->phc_index = priv->cpts->phc_index;
+	info->phc_index = cpsw->cpts->phc_index;
 	info->tx_types =
 		(1 << HWTSTAMP_TX_OFF) |
 		(1 << HWTSTAMP_TX_ON);
@@ -1860,8 +1842,8 @@ static int cpsw_get_settings(struct net_device *ndev,
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int slave_no = cpsw_slave_index(priv);
 
-	if (priv->slaves[slave_no].phy)
-		return phy_ethtool_gset(priv->slaves[slave_no].phy, ecmd);
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_gset(cpsw->slaves[slave_no].phy, ecmd);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1871,8 +1853,8 @@ static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int slave_no = cpsw_slave_index(priv);
 
-	if (priv->slaves[slave_no].phy)
-		return phy_ethtool_sset(priv->slaves[slave_no].phy, ecmd);
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_sset(cpsw->slaves[slave_no].phy, ecmd);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1885,8 +1867,8 @@ static void cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 	wol->supported = 0;
 	wol->wolopts = 0;
 
-	if (priv->slaves[slave_no].phy)
-		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
+	if (cpsw->slaves[slave_no].phy)
+		phy_ethtool_get_wol(cpsw->slaves[slave_no].phy, wol);
 }
 
 static int cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
@@ -1894,8 +1876,8 @@ static int cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int slave_no = cpsw_slave_index(priv);
 
-	if (priv->slaves[slave_no].phy)
-		return phy_ethtool_set_wol(priv->slaves[slave_no].phy, wol);
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_set_wol(cpsw->slaves[slave_no].phy, wol);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1928,10 +1910,10 @@ static int cpsw_ethtool_op_begin(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&cpsw->pdev->dev);
 	if (ret < 0) {
 		cpsw_err(priv, drv, "ethtool begin failed %d\n", ret);
-		pm_runtime_put_noidle(&priv->pdev->dev);
+		pm_runtime_put_noidle(&cpsw->pdev->dev);
 	}
 
 	return ret;
@@ -1942,7 +1924,7 @@ static void cpsw_ethtool_op_complete(struct net_device *ndev)
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
-	ret = pm_runtime_put(&priv->pdev->dev);
+	ret = pm_runtime_put(&cpsw->pdev->dev);
 	if (ret < 0)
 		cpsw_err(priv, drv, "ethtool complete failed %d\n", ret);
 }
@@ -1970,12 +1952,12 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.complete	= cpsw_ethtool_op_complete,
 };
 
-static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
+static void cpsw_slave_init(struct cpsw_slave *slave,
 			    u32 slave_reg_ofs, u32 sliver_reg_ofs)
 {
-	void __iomem		*regs = priv->regs;
+	void __iomem		*regs = cpsw->regs;
 	int			slave_num = slave->slave_num;
-	struct cpsw_slave_data	*data = priv->data.slave_data + slave_num;
+	struct cpsw_slave_data	*data = cpsw->data.slave_data + slave_num;
 
 	slave->data	= data;
 	slave->regs	= regs + slave_reg_ofs;
@@ -2149,10 +2131,10 @@ no_phy_slave:
 static int cpsw_probe_dual_emac(struct platform_device *pdev,
 				struct cpsw_priv *priv)
 {
-	struct cpsw_platform_data	*data = &priv->data;
+	struct cpsw_platform_data	*data = &cpsw->data;
 	struct net_device		*ndev;
 	struct cpsw_priv		*priv_sl2;
-	int ret = 0, i;
+	int ret = 0;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
@@ -2161,12 +2143,9 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	}
 
 	priv_sl2 = netdev_priv(ndev);
-	priv_sl2->data = *data;
-	priv_sl2->pdev = pdev;
 	priv_sl2->ndev = ndev;
 	priv_sl2->dev  = &ndev->dev;
 	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
-	priv_sl2->rx_packet_max = max(rx_packet_max, 128);
 
 	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
 		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
@@ -2178,31 +2157,10 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	}
 	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 
-	priv_sl2->slaves = priv->slaves;
-	priv_sl2->clk = priv->clk;
-
-	priv_sl2->coal_intvl = 0;
-	priv_sl2->bus_freq_mhz = priv->bus_freq_mhz;
-
-	priv_sl2->regs = priv->regs;
-	priv_sl2->host_port_regs = priv->host_port_regs;
-	priv_sl2->wr_regs = priv->wr_regs;
-	priv_sl2->hw_stats = priv->hw_stats;
-	priv_sl2->dma = priv->dma;
-	priv_sl2->txch = priv->txch;
-	priv_sl2->rxch = priv->rxch;
-	priv_sl2->ale = priv->ale;
 	priv_sl2->emac_port = 1;
-	priv->slaves[1].ndev = ndev;
-	priv_sl2->cpts = priv->cpts;
-	priv_sl2->version = priv->version;
+	cpsw->slaves[1].ndev = ndev;
 
-	for (i = 0; i < priv->num_irqs; i++) {
-		priv_sl2->irqs_table[i] = priv->irqs_table[i];
-		priv_sl2->num_irqs = priv->num_irqs;
-	}
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
-
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
 
@@ -2271,6 +2229,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	int ret = 0, i;
 	int irq;
 
+	cpsw = devm_kzalloc(&pdev->dev, sizeof(struct cpsw_common), GFP_KERNEL);
+
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
 		dev_err(&pdev->dev, "error allocating net_device\n");
@@ -2279,13 +2239,14 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 	priv = netdev_priv(ndev);
-	priv->pdev = pdev;
+	cpsw->pdev = pdev;
 	priv->ndev = ndev;
+	cpsw->ndev = ndev;
 	priv->dev  = &ndev->dev;
 	priv->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
-	priv->rx_packet_max = max(rx_packet_max, 128);
-	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
-	if (!priv->cpts) {
+	cpsw->rx_packet_max = max(rx_packet_max, 128);
+	cpsw->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
+	if (!cpsw->cpts) {
 		dev_err(&pdev->dev, "error allocating cpts\n");
 		ret = -ENOMEM;
 		goto clean_ndev_ret;
@@ -2306,12 +2267,12 @@ static int cpsw_probe(struct platform_device *pdev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
-	if (cpsw_probe_dt(&priv->data, pdev)) {
+	if (cpsw_probe_dt(&cpsw->data, pdev)) {
 		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
-	data = &priv->data;
+	data = &cpsw->data;
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
@@ -2323,27 +2284,27 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 
-	priv->slaves = devm_kzalloc(&pdev->dev,
+	cpsw->slaves = devm_kzalloc(&pdev->dev,
 				    sizeof(struct cpsw_slave) * data->slaves,
 				    GFP_KERNEL);
-	if (!priv->slaves) {
+	if (!cpsw->slaves) {
 		ret = -ENOMEM;
 		goto clean_runtime_disable_ret;
 	}
 	for (i = 0; i < data->slaves; i++)
-		priv->slaves[i].slave_num = i;
+		cpsw->slaves[i].slave_num = i;
 
-	priv->slaves[0].ndev = ndev;
+	cpsw->slaves[0].ndev = ndev;
 	priv->emac_port = 0;
 
-	priv->clk = devm_clk_get(&pdev->dev, "fck");
-	if (IS_ERR(priv->clk)) {
+	cpsw->clk = devm_clk_get(&pdev->dev, "fck");
+	if (IS_ERR(cpsw->clk)) {
 		dev_err(priv->dev, "fck is not found\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
-	priv->coal_intvl = 0;
-	priv->bus_freq_mhz = clk_get_rate(priv->clk) / 1000000;
+	cpsw->coal_intvl = 0;
+	cpsw->bus_freq_mhz = clk_get_rate(cpsw->clk) / 1000000;
 
 	ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	ss_regs = devm_ioremap_resource(&pdev->dev, ss_res);
@@ -2351,7 +2312,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = PTR_ERR(ss_regs);
 		goto clean_runtime_disable_ret;
 	}
-	priv->regs = ss_regs;
+	cpsw->regs = ss_regs;
 
 	/* Need to enable clocks with runtime PM api to access module
 	 * registers
@@ -2361,24 +2322,24 @@ static int cpsw_probe(struct platform_device *pdev)
 		pm_runtime_put_noidle(&pdev->dev);
 		goto clean_runtime_disable_ret;
 	}
-	priv->version = readl(&priv->regs->id_ver);
+	cpsw->version = readl(&cpsw->regs->id_ver);
 	pm_runtime_put_sync(&pdev->dev);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	priv->wr_regs = devm_ioremap_resource(&pdev->dev, res);
-	if (IS_ERR(priv->wr_regs)) {
-		ret = PTR_ERR(priv->wr_regs);
+	cpsw->wr_regs = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(cpsw->wr_regs)) {
+		ret = PTR_ERR(cpsw->wr_regs);
 		goto clean_runtime_disable_ret;
 	}
 
 	memset(&dma_params, 0, sizeof(dma_params));
 	memset(&ale_params, 0, sizeof(ale_params));
 
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_1:
-		priv->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
-		priv->cpts->reg      = ss_regs + CPSW1_CPTS_OFFSET;
-		priv->hw_stats	     = ss_regs + CPSW1_HW_STATS;
+		cpsw->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
+		cpsw->cpts->reg      = ss_regs + CPSW1_CPTS_OFFSET;
+		cpsw->hw_stats	     = ss_regs + CPSW1_HW_STATS;
 		dma_params.dmaregs   = ss_regs + CPSW1_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW1_STATERAM_OFFSET;
 		ale_params.ale_regs  = ss_regs + CPSW1_ALE_OFFSET;
@@ -2390,9 +2351,9 @@ static int cpsw_probe(struct platform_device *pdev)
 	case CPSW_VERSION_2:
 	case CPSW_VERSION_3:
 	case CPSW_VERSION_4:
-		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
-		priv->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
-		priv->hw_stats	     = ss_regs + CPSW2_HW_STATS;
+		cpsw->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
+		cpsw->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
+		cpsw->hw_stats	     = ss_regs + CPSW2_HW_STATS;
 		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW2_STATERAM_OFFSET;
 		ale_params.ale_regs  = ss_regs + CPSW2_ALE_OFFSET;
@@ -2403,13 +2364,14 @@ static int cpsw_probe(struct platform_device *pdev)
 			(u32 __force) ss_res->start + CPSW2_BD_OFFSET;
 		break;
 	default:
-		dev_err(priv->dev, "unknown version 0x%08x\n", priv->version);
+		dev_err(priv->dev, "unknown version 0x%08x\n", cpsw->version);
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
-	for (i = 0; i < priv->data.slaves; i++) {
-		struct cpsw_slave *slave = &priv->slaves[i];
-		cpsw_slave_init(slave, priv, slave_offset, sliver_offset);
+	for (i = 0; i < cpsw->data.slaves; i++) {
+		struct cpsw_slave *slave = &cpsw->slaves[i];
+
+		cpsw_slave_init(slave, slave_offset, sliver_offset);
 		slave_offset  += slave_size;
 		sliver_offset += SLIVER_SIZE;
 	}
@@ -2429,19 +2391,19 @@ static int cpsw_probe(struct platform_device *pdev)
 	dma_params.has_ext_regs		= true;
 	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
 
-	priv->dma = cpdma_ctlr_create(&dma_params);
-	if (!priv->dma) {
+	cpsw->dma = cpdma_ctlr_create(&dma_params);
+	if (!cpsw->dma) {
 		dev_err(priv->dev, "error initializing dma\n");
 		ret = -ENOMEM;
 		goto clean_runtime_disable_ret;
 	}
 
-	priv->txch = cpdma_chan_create(priv->dma, tx_chan_num(0),
+	cpsw->txch = cpdma_chan_create(cpsw->dma, tx_chan_num(0),
 				       cpsw_tx_handler);
-	priv->rxch = cpdma_chan_create(priv->dma, rx_chan_num(0),
+	cpsw->rxch = cpdma_chan_create(cpsw->dma, rx_chan_num(0),
 				       cpsw_rx_handler);
 
-	if (WARN_ON(!priv->txch || !priv->rxch)) {
+	if (WARN_ON(!cpsw->txch || !cpsw->rxch)) {
 		dev_err(priv->dev, "error initializing dma channels\n");
 		ret = -ENOMEM;
 		goto clean_dma_ret;
@@ -2452,8 +2414,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	ale_params.ale_entries		= data->ale_entries;
 	ale_params.ale_ports		= data->slaves;
 
-	priv->ale = cpsw_ale_create(&ale_params);
-	if (!priv->ale) {
+	cpsw->ale = cpsw_ale_create(&ale_params);
+	if (!cpsw->ale) {
 		dev_err(priv->dev, "error initializing ale engine\n");
 		ret = -ENODEV;
 		goto clean_dma_ret;
@@ -2470,7 +2432,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (of_id) {
 		pdev->id_entry = of_id->data;
 		if (pdev->id_entry->driver_data)
-			priv->quirk_irq = true;
+			cpsw->quirk_irq = true;
 	}
 
 	/* Grab RX and TX IRQs. Note that we also have RX_THRESHOLD and
@@ -2488,9 +2450,9 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	priv->irqs_table[0] = irq;
+	cpsw->irqs_table[0] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_rx_interrupt,
-			       0, dev_name(&pdev->dev), priv);
+			       0, dev_name(&pdev->dev), cpsw);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
@@ -2503,21 +2465,21 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
-	priv->irqs_table[1] = irq;
+	cpsw->irqs_table[1] = irq;
 	ret = devm_request_irq(&pdev->dev, irq, cpsw_tx_interrupt,
-			       0, dev_name(&pdev->dev), priv);
+			       0, dev_name(&pdev->dev), cpsw);
 	if (ret < 0) {
 		dev_err(priv->dev, "error attaching irq (%d)\n", ret);
 		goto clean_ale_ret;
 	}
-	priv->num_irqs = 2;
+	cpsw->num_irqs = 2;
 
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
-	netif_napi_add(ndev, &priv->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
-	netif_tx_napi_add(ndev, &priv->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &cpsw->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
+	netif_tx_napi_add(ndev, &cpsw->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
@@ -2531,7 +2493,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	cpsw_notice(priv, probe, "initialized device (regs %pa, irq %d)\n",
 		    &ss_res->start, ndev->irq);
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		ret = cpsw_probe_dual_emac(pdev, priv);
 		if (ret) {
 			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
@@ -2542,9 +2504,9 @@ static int cpsw_probe(struct platform_device *pdev)
 	return 0;
 
 clean_ale_ret:
-	cpsw_ale_destroy(priv->ale);
+	cpsw_ale_destroy(cpsw->ale);
 clean_dma_ret:
-	cpdma_ctlr_destroy(priv->dma);
+	cpdma_ctlr_destroy(cpsw->dma);
 clean_runtime_disable_ret:
 	pm_runtime_disable(&pdev->dev);
 clean_ndev_ret:
@@ -2555,7 +2517,6 @@ clean_ndev_ret:
 static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct cpsw_priv *priv = netdev_priv(ndev);
 	int ret;
 
 	ret = pm_runtime_get_sync(&pdev->dev);
@@ -2564,17 +2525,17 @@ static int cpsw_remove(struct platform_device *pdev)
 		return ret;
 	}
 
-	if (priv->data.dual_emac)
-		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
+	if (cpsw->data.dual_emac)
+		unregister_netdev(cpsw_get_slave_ndev(1));
 	unregister_netdev(ndev);
 
-	cpsw_ale_destroy(priv->ale);
-	cpdma_ctlr_destroy(priv->dma);
+	cpsw_ale_destroy(cpsw->ale);
+	cpdma_ctlr_destroy(cpsw->dma);
 	of_platform_depopulate(&pdev->dev);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
-	if (priv->data.dual_emac)
-		free_netdev(cpsw_get_slave_ndev(priv, 1));
+	if (cpsw->data.dual_emac)
+		free_netdev(cpsw_get_slave_ndev(1));
 	free_netdev(ndev);
 	return 0;
 }
@@ -2582,47 +2543,39 @@ static int cpsw_remove(struct platform_device *pdev)
 #ifdef CONFIG_PM_SLEEP
 static int cpsw_suspend(struct device *dev)
 {
-	struct platform_device	*pdev = to_platform_device(dev);
-	struct net_device	*ndev = platform_get_drvdata(pdev);
-	struct cpsw_priv	*priv = netdev_priv(ndev);
-
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		int i;
 
-		for (i = 0; i < priv->data.slaves; i++) {
-			if (netif_running(priv->slaves[i].ndev))
-				cpsw_ndo_stop(priv->slaves[i].ndev);
+		for (i = 0; i < cpsw->data.slaves; i++) {
+			if (netif_running(cpsw->slaves[i].ndev))
+				cpsw_ndo_stop(cpsw->slaves[i].ndev);
 		}
 	} else {
-		if (netif_running(ndev))
-			cpsw_ndo_stop(ndev);
+		if (netif_running(cpsw->ndev))
+			cpsw_ndo_stop(cpsw->ndev);
 	}
 
 	/* Select sleep pin state */
-	pinctrl_pm_select_sleep_state(&pdev->dev);
+	pinctrl_pm_select_sleep_state(&cpsw->pdev->dev);
 
 	return 0;
 }
 
 static int cpsw_resume(struct device *dev)
 {
-	struct platform_device	*pdev = to_platform_device(dev);
-	struct net_device	*ndev = platform_get_drvdata(pdev);
-	struct cpsw_priv	*priv = netdev_priv(ndev);
-
 	/* Select default pin state */
-	pinctrl_pm_select_default_state(&pdev->dev);
+	pinctrl_pm_select_default_state(&cpsw->pdev->dev);
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		int i;
 
-		for (i = 0; i < priv->data.slaves; i++) {
-			if (netif_running(priv->slaves[i].ndev))
-				cpsw_ndo_open(priv->slaves[i].ndev);
+		for (i = 0; i < cpsw->data.slaves; i++) {
+			if (netif_running(cpsw->slaves[i].ndev))
+				cpsw_ndo_open(cpsw->slaves[i].ndev);
 		}
 	} else {
-		if (netif_running(ndev))
-			cpsw_ndo_open(ndev);
+		if (netif_running(cpsw->ndev))
+			cpsw_ndo_open(cpsw->ndev);
 	}
 	return 0;
 }
-- 
1.9.1
