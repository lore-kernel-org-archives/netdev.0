From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v3 13/13] net: ethernet: ti: cpsw: move ale, cpts and drivers params under cpsw_common
Date: Wed, 10 Aug 2016 02:22:44 +0300
Message-ID: <1470784964-26440-14-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ale, cpts, version, rx_packet_max, bus_freq, interrupt pacing
parameters are common per net device that uses the same h/w. So,
move them to common driver structure.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 235 +++++++++++++++++++----------------------
 1 file changed, 106 insertions(+), 129 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 2c2e36a..b4d3b41 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -373,28 +373,28 @@ struct cpsw_common {
 	struct cpsw_wr_regs __iomem	*wr_regs;
 	u8 __iomem			*hw_stats;
 	struct cpsw_host_regs __iomem	*host_port_regs;
+	u32				version;
+	u32				coal_intvl;
+	u32				bus_freq_mhz;
+	int				rx_packet_max;
 	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
 	struct cpdma_chan		*txch, *rxch;
+	struct cpsw_ale			*ale;
 	bool				quirk_irq;
 	bool				rx_irq_disabled;
 	bool				tx_irq_disabled;
 	u32 irqs_table[IRQ_NUM];
+	struct cpts			*cpts;
 };
 
 struct cpsw_priv {
 	struct net_device		*ndev;
 	struct device			*dev;
 	u32				msg_enable;
-	u32				version;
-	u32				coal_intvl;
-	u32				bus_freq_mhz;
-	int				rx_packet_max;
 	u8				mac_addr[ETH_ALEN];
-	struct cpsw_ale			*ale;
 	bool				rx_pause;
 	bool				tx_pause;
-	struct cpts *cpts;
 	u32 emac_port;
 	struct cpsw_common *cpsw;
 };
@@ -502,22 +502,16 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 					n; n--)				\
 				(func)(slave++, ##arg);			\
 	} while (0)
-#define cpsw_get_slave_priv(cpsw, __slave_no__)				\
-	(((__slave_no__ < cpsw->data.slaves) &&				\
-		(cpsw->slaves[__slave_no__].ndev)) ?			\
-		netdev_priv(cpsw->slaves[__slave_no__].ndev) : NULL)	\
 
-#define cpsw_dual_emac_src_port_detect(cpsw, status, priv, ndev, skb)	\
+#define cpsw_dual_emac_src_port_detect(cpsw, status, ndev, skb)		\
 	do {								\
 		if (!cpsw->data.dual_emac)				\
 			break;						\
 		if (CPDMA_RX_SOURCE_PORT(status) == 1) {		\
 			ndev = cpsw->slaves[0].ndev;			\
-			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		} else if (CPDMA_RX_SOURCE_PORT(status) == 2) {		\
 			ndev = cpsw->slaves[1].ndev;			\
-			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		}							\
 	} while (0)
@@ -528,11 +522,11 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 						priv->emac_port;	\
 			int slave_port = cpsw_get_slave_port(		\
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
@@ -545,9 +539,8 @@ static inline int cpsw_get_slave_port(u32 slave_num)
 
 static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpsw_common *cpsw = priv->cpsw;
-	struct cpsw_ale *ale = priv->ale;
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
+	struct cpsw_ale *ale = cpsw->ale;
 	int i;
 
 	if (cpsw->data.dual_emac) {
@@ -633,7 +626,7 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	if (ndev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
 		cpsw_set_promiscious(ndev, true);
-		cpsw_ale_set_allmulti(priv->ale, IFF_ALLMULTI);
+		cpsw_ale_set_allmulti(cpsw->ale, IFF_ALLMULTI);
 		return;
 	} else {
 		/* Disable promiscuous mode */
@@ -641,10 +634,10 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 	}
 
 	/* Restore allmulti on vlans if necessary */
-	cpsw_ale_set_allmulti(priv->ale, priv->ndev->flags & IFF_ALLMULTI);
+	cpsw_ale_set_allmulti(cpsw->ale, priv->ndev->flags & IFF_ALLMULTI);
 
 	/* Clear all mcast from ALE */
-	cpsw_ale_flush_multicast(priv->ale, ALE_ALL_PORTS, vid);
+	cpsw_ale_flush_multicast(cpsw->ale, ALE_ALL_PORTS, vid);
 
 	if (!netdev_mc_empty(ndev)) {
 		struct netdev_hw_addr *ha;
@@ -678,14 +671,14 @@ static void cpsw_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
-	struct cpsw_priv	*priv = netdev_priv(ndev);
+	struct cpsw_common	*cpsw = ndev_to_cpsw(ndev);
 
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
@@ -696,11 +689,10 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	struct sk_buff		*skb = token;
 	struct sk_buff		*new_skb;
 	struct net_device	*ndev = skb->dev;
-	struct cpsw_priv	*priv = netdev_priv(ndev);
 	int			ret = 0;
-	struct cpsw_common	*cpsw = priv->cpsw;
+	struct cpsw_common	*cpsw = ndev_to_cpsw(ndev);
 
-	cpsw_dual_emac_src_port_detect(cpsw, status, priv, ndev, skb);
+	cpsw_dual_emac_src_port_detect(cpsw, status, ndev, skb);
 
 	if (unlikely(status < 0) || unlikely(!netif_running(ndev))) {
 		bool ndev_status = false;
@@ -730,10 +722,10 @@ static void cpsw_rx_handler(void *token, int len, int status)
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
@@ -858,7 +850,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 		mac_control = cpsw->data.mac_control;
 
 		/* enable forwarding */
-		cpsw_ale_control_set(priv->ale, slave_port,
+		cpsw_ale_control_set(cpsw->ale, slave_port,
 				     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
 		if (phy->speed == 1000)
@@ -882,7 +874,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	} else {
 		mac_control = 0;
 		/* disable forwarding */
-		cpsw_ale_control_set(priv->ale, slave_port,
+		cpsw_ale_control_set(cpsw->ale, slave_port,
 				     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
 	}
 
@@ -914,9 +906,9 @@ static void cpsw_adjust_link(struct net_device *ndev)
 static int cpsw_get_coalesce(struct net_device *ndev,
 				struct ethtool_coalesce *coal)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
-	coal->rx_coalesce_usecs = priv->coal_intvl;
+	coal->rx_coalesce_usecs = cpsw->coal_intvl;
 	return 0;
 }
 
@@ -934,7 +926,7 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	coal_intvl = coal->rx_coalesce_usecs;
 
 	int_ctrl =  readl(&cpsw->wr_regs->int_control);
-	prescale = priv->bus_freq_mhz * 4;
+	prescale = cpsw->bus_freq_mhz * 4;
 
 	if (!coal->rx_coalesce_usecs) {
 		int_ctrl &= ~(CPSW_INTPRESCALE_MASK | CPSW_INTPACEEN);
@@ -973,16 +965,7 @@ update_return:
 	writel(int_ctrl, &cpsw->wr_regs->int_control);
 
 	cpsw_notice(priv, timer, "Set coalesce to %d usecs.\n", coal_intvl);
-	if (cpsw->data.dual_emac) {
-		int i;
-
-		for (i = 0; i < cpsw->data.slaves; i++) {
-			priv = netdev_priv(cpsw->slaves[i].ndev);
-			priv->coal_intvl = coal_intvl;
-		}
-	} else {
-		priv->coal_intvl = coal_intvl;
-	}
+	cpsw->coal_intvl = coal_intvl;
 
 	return 0;
 }
@@ -1078,18 +1061,20 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 		struct cpsw_priv *priv, struct cpsw_slave *slave,
 		u32 slave_port)
 {
+	struct cpsw_common *cpsw = priv->cpsw;
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
+			   HOST_PORT_NUM, ALE_VLAN |
+			   ALE_SECURE, slave->port_vlan);
 }
 
 static void soft_reset_slave(struct cpsw_slave *slave)
@@ -1110,7 +1095,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	/* setup priority mapping */
 	__raw_writel(RX_PRIORITY_MAPPING, &slave->sliver->rx_pri_map);
 
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_1:
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW1_TX_PRI_MAP);
 		break;
@@ -1122,7 +1107,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	}
 
 	/* setup max packet size, and mac address */
-	__raw_writel(priv->rx_packet_max, &slave->sliver->rx_maxlen);
+	__raw_writel(cpsw->rx_packet_max, &slave->sliver->rx_maxlen);
 	cpsw_set_slave_mac(slave, priv);
 
 	slave->mac_control = 0;	/* no link yet */
@@ -1132,7 +1117,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	if (cpsw->data.dual_emac)
 		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
 	else
-		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+		cpsw_ale_add_mcast(cpsw->ale, priv->ndev->broadcast,
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
 	if (slave->data->phy_node) {
@@ -1173,7 +1158,7 @@ static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 	int i;
 	int unreg_mcast_mask;
 
-	reg = (priv->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
+	reg = (cpsw->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
 	       CPSW2_PORT_VLAN;
 
 	writel(vlan, &cpsw->host_port_regs->port_vlan);
@@ -1186,7 +1171,7 @@ static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 	else
 		unreg_mcast_mask = ALE_PORT_1 | ALE_PORT_2;
 
-	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS,
+	cpsw_ale_add_vlan(cpsw->ale, vlan, ALE_ALL_PORTS,
 			  ALE_ALL_PORTS, ALE_ALL_PORTS,
 			  unreg_mcast_mask);
 }
@@ -1199,10 +1184,10 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 
 	/* soft reset the controller and initialize ale */
 	soft_reset("cpsw", &cpsw->regs->soft_reset);
-	cpsw_ale_start(priv->ale);
+	cpsw_ale_start(cpsw->ale);
 
 	/* switch to vlan unaware mode */
-	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM, ALE_VLAN_AWARE,
+	cpsw_ale_control_set(cpsw->ale, HOST_PORT_NUM, ALE_VLAN_AWARE,
 			     CPSW_ALE_VLAN_AWARE);
 	control_reg = readl(&cpsw->regs->control);
 	control_reg |= CPSW_VLAN_AWARE;
@@ -1216,18 +1201,18 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 		     &cpsw->host_port_regs->cpdma_tx_pri_map);
 	__raw_writel(0, &cpsw->host_port_regs->cpdma_rx_chan_map);
 
-	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM,
+	cpsw_ale_control_set(cpsw->ale, HOST_PORT_NUM,
 			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
 	if (!cpsw->data.dual_emac) {
-		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
+		cpsw_ale_add_ucast(cpsw->ale, priv->mac_addr, HOST_PORT_NUM,
 				   0, 0);
-		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+		cpsw_ale_add_mcast(cpsw->ale, priv->ndev->broadcast,
 				   ALE_PORT_HOST, 0, 0, ALE_MCAST_FWD_2);
 	}
 }
 
-static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
+static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_common *cpsw)
 {
 	u32 slave_port;
 
@@ -1238,7 +1223,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	phy_stop(slave->phy);
 	phy_disconnect(slave->phy);
 	slave->phy = NULL;
-	cpsw_ale_control_set(priv->ale, slave_port,
+	cpsw_ale_control_set(cpsw->ale, slave_port,
 			     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
 	soft_reset_slave(slave);
 }
@@ -1260,7 +1245,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_intr_disable(cpsw);
 	netif_carrier_off(ndev);
 
-	reg = priv->version;
+	reg = cpsw->version;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
 		 CPSW_MAJOR_VERSION(reg), CPSW_MINOR_VERSION(reg),
@@ -1275,7 +1260,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	if (!cpsw->data.dual_emac)
 		cpsw_add_default_vlan(priv);
 	else
-		cpsw_ale_add_vlan(priv->ale, cpsw->data.default_vlan,
+		cpsw_ale_add_vlan(cpsw->ale, cpsw->data.default_vlan,
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
 	if (!cpsw_common_res_usage_state(cpsw)) {
@@ -1313,7 +1298,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 			ret = -ENOMEM;
 			skb = __netdev_alloc_skb_ip_align(priv->ndev,
-					priv->rx_packet_max, GFP_KERNEL);
+					cpsw->rx_packet_max, GFP_KERNEL);
 			if (!skb)
 				goto err_cleanup;
 			ret = cpdma_chan_submit(cpsw->rxch, skb, skb->data,
@@ -1328,7 +1313,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 */
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
-		if (cpts_register(cpsw->dev, priv->cpts,
+		if (cpts_register(cpsw->dev, cpsw->cpts,
 				  cpsw->data.cpts_clock_mult,
 				  cpsw->data.cpts_clock_shift))
 			dev_err(priv->dev, "error registering cpts device\n");
@@ -1336,10 +1321,10 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	}
 
 	/* Enable Interrupt pacing if configured */
-	if (priv->coal_intvl != 0) {
+	if (cpsw->coal_intvl != 0) {
 		struct ethtool_coalesce coal;
 
-		coal.rx_coalesce_usecs = priv->coal_intvl;
+		coal.rx_coalesce_usecs = cpsw->coal_intvl;
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
@@ -1352,7 +1337,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 err_cleanup:
 	cpdma_ctlr_stop(cpsw->dma);
-	for_each_slave(priv, cpsw_slave_stop, priv);
+	for_each_slave(priv, cpsw_slave_stop, cpsw);
 	pm_runtime_put_sync(cpsw->dev);
 	netif_carrier_off(priv->ndev);
 	return ret;
@@ -1370,12 +1355,12 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	if (cpsw_common_res_usage_state(cpsw) <= 1) {
 		napi_disable(&cpsw->napi_rx);
 		napi_disable(&cpsw->napi_tx);
-		cpts_unregister(priv->cpts);
+		cpts_unregister(cpsw->cpts);
 		cpsw_intr_disable(cpsw);
 		cpdma_ctlr_stop(cpsw->dma);
-		cpsw_ale_stop(priv->ale);
+		cpsw_ale_stop(cpsw->ale);
 	}
-	for_each_slave(priv, cpsw_slave_stop, priv);
+	for_each_slave(priv, cpsw_slave_stop, cpsw);
 	pm_runtime_put_sync(cpsw->dev);
 	if (cpsw->data.dual_emac)
 		cpsw->slaves[priv->emac_port].open_stat = false;
@@ -1398,7 +1383,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	}
 
 	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-				priv->cpts->tx_enable)
+				cpsw->cpts->tx_enable)
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 	skb_tx_timestamp(skb);
@@ -1424,13 +1409,12 @@ fail:
 
 #ifdef CONFIG_TI_CPTS
 
-static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
+static void cpsw_hwtstamp_v1(struct cpsw_common *cpsw)
 {
-	struct cpsw_common *cpsw = priv->cpsw;
 	struct cpsw_slave *slave = &cpsw->slaves[cpsw->data.active_slave];
 	u32 ts_en, seq_id;
 
-	if (!priv->cpts->tx_enable && !priv->cpts->rx_enable) {
+	if (!cpsw->cpts->tx_enable && !cpsw->cpts->rx_enable) {
 		slave_write(slave, 0, CPSW1_TS_CTL);
 		return;
 	}
@@ -1438,10 +1422,10 @@ static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 	seq_id = (30 << CPSW_V1_SEQ_ID_OFS_SHIFT) | ETH_P_1588;
 	ts_en = EVENT_MSG_BITS << CPSW_V1_MSG_TYPE_OFS;
 
-	if (priv->cpts->tx_enable)
+	if (cpsw->cpts->tx_enable)
 		ts_en |= CPSW_V1_TS_TX_EN;
 
-	if (priv->cpts->rx_enable)
+	if (cpsw->cpts->rx_enable)
 		ts_en |= CPSW_V1_TS_RX_EN;
 
 	slave_write(slave, ts_en, CPSW1_TS_CTL);
@@ -1460,24 +1444,24 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 		slave = &cpsw->slaves[cpsw->data.active_slave];
 
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
@@ -1492,12 +1476,13 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 {
 	struct cpsw_priv *priv = netdev_priv(dev);
-	struct cpts *cpts = priv->cpts;
 	struct hwtstamp_config cfg;
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpts *cpts = cpsw->cpts;
 
-	if (priv->version != CPSW_VERSION_1 &&
-	    priv->version != CPSW_VERSION_2 &&
-	    priv->version != CPSW_VERSION_3)
+	if (cpsw->version != CPSW_VERSION_1 &&
+	    cpsw->version != CPSW_VERSION_2 &&
+	    cpsw->version != CPSW_VERSION_3)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
@@ -1537,9 +1522,9 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 
 	cpts->tx_enable = cfg.tx_type == HWTSTAMP_TX_ON;
 
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_1:
-		cpsw_hwtstamp_v1(priv);
+		cpsw_hwtstamp_v1(cpsw);
 		break;
 	case CPSW_VERSION_2:
 	case CPSW_VERSION_3:
@@ -1554,13 +1539,13 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 
 static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 {
-	struct cpsw_priv *priv = netdev_priv(dev);
-	struct cpts *cpts = priv->cpts;
+	struct cpsw_common *cpsw = ndev_to_cpsw(dev);
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
@@ -1632,9 +1617,9 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 		flags = ALE_VLAN;
 	}
 
-	cpsw_ale_del_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
+	cpsw_ale_del_ucast(cpsw->ale, priv->mac_addr, HOST_PORT_NUM,
 			   flags, vid);
-	cpsw_ale_add_ucast(priv->ale, addr->sa_data, HOST_PORT_NUM,
+	cpsw_ale_add_ucast(cpsw->ale, addr->sa_data, HOST_PORT_NUM,
 			   flags, vid);
 
 	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
@@ -1680,27 +1665,27 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
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
 
@@ -1766,16 +1751,16 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
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
 	pm_runtime_put(cpsw->dev);
 	return ret;
@@ -1808,13 +1793,13 @@ static int cpsw_get_regs_len(struct net_device *ndev)
 static void cpsw_get_regs(struct net_device *ndev,
 			  struct ethtool_regs *regs, void *p)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
 	u32 *reg = p;
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
 	/* update CPSW IP version */
-	regs->version = priv->version;
+	regs->version = cpsw->version;
 
-	cpsw_ale_dump(priv->ale, reg);
+	cpsw_ale_dump(cpsw->ale, reg);
 }
 
 static void cpsw_get_drvinfo(struct net_device *ndev,
@@ -1844,7 +1829,7 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 			    struct ethtool_ts_info *info)
 {
 #ifdef CONFIG_TI_CPTS
-	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
 	info->so_timestamping =
 		SOF_TIMESTAMPING_TX_HARDWARE |
@@ -1853,7 +1838,7 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 		SOF_TIMESTAMPING_RX_SOFTWARE |
 		SOF_TIMESTAMPING_SOFTWARE |
 		SOF_TIMESTAMPING_RAW_HARDWARE;
-	info->phc_index = priv->cpts->phc_index;
+	info->phc_index = cpsw->cpts->phc_index;
 	info->tx_types =
 		(1 << HWTSTAMP_TX_OFF) |
 		(1 << HWTSTAMP_TX_ON);
@@ -2188,7 +2173,6 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	priv_sl2->ndev = ndev;
 	priv_sl2->dev  = &ndev->dev;
 	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
-	priv_sl2->rx_packet_max = max(rx_packet_max, 128);
 
 	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
 		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
@@ -2202,13 +2186,8 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	}
 	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 
-	priv_sl2->coal_intvl = 0;
-	priv_sl2->bus_freq_mhz = priv->bus_freq_mhz;
-	priv_sl2->ale = priv->ale;
 	priv_sl2->emac_port = 1;
 	cpsw->slaves[1].ndev = ndev;
-	priv_sl2->cpts = priv->cpts;
-	priv_sl2->version = priv->version;
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
@@ -2296,9 +2275,9 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->ndev = ndev;
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
@@ -2355,8 +2334,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
-	priv->coal_intvl = 0;
-	priv->bus_freq_mhz = clk_get_rate(clk) / 1000000;
+	cpsw->bus_freq_mhz = clk_get_rate(clk) / 1000000;
 
 	ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	ss_regs = devm_ioremap_resource(&pdev->dev, ss_res);
@@ -2374,7 +2352,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		pm_runtime_put_noidle(&pdev->dev);
 		goto clean_runtime_disable_ret;
 	}
-	priv->version = readl(&cpsw->regs->id_ver);
+	cpsw->version = readl(&cpsw->regs->id_ver);
 	pm_runtime_put_sync(&pdev->dev);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
@@ -2387,10 +2365,10 @@ static int cpsw_probe(struct platform_device *pdev)
 	memset(&dma_params, 0, sizeof(dma_params));
 	memset(&ale_params, 0, sizeof(ale_params));
 
-	switch (priv->version) {
+	switch (cpsw->version) {
 	case CPSW_VERSION_1:
 		cpsw->host_port_regs = ss_regs + CPSW1_HOST_PORT_OFFSET;
-		priv->cpts->reg      = ss_regs + CPSW1_CPTS_OFFSET;
+		cpsw->cpts->reg      = ss_regs + CPSW1_CPTS_OFFSET;
 		cpsw->hw_stats	     = ss_regs + CPSW1_HW_STATS;
 		dma_params.dmaregs   = ss_regs + CPSW1_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW1_STATERAM_OFFSET;
@@ -2404,7 +2382,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	case CPSW_VERSION_3:
 	case CPSW_VERSION_4:
 		cpsw->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
-		priv->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
+		cpsw->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
 		cpsw->hw_stats	     = ss_regs + CPSW2_HW_STATS;
 		dma_params.dmaregs   = ss_regs + CPSW2_CPDMA_OFFSET;
 		dma_params.txhdp     = ss_regs + CPSW2_STATERAM_OFFSET;
@@ -2416,7 +2394,7 @@ static int cpsw_probe(struct platform_device *pdev)
 			(u32 __force) ss_res->start + CPSW2_BD_OFFSET;
 		break;
 	default:
-		dev_err(priv->dev, "unknown version 0x%08x\n", priv->version);
+		dev_err(priv->dev, "unknown version 0x%08x\n", cpsw->version);
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
@@ -2466,8 +2444,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	ale_params.ale_entries		= data->ale_entries;
 	ale_params.ale_ports		= data->slaves;
 
-	priv->ale = cpsw_ale_create(&ale_params);
-	if (!priv->ale) {
+	cpsw->ale = cpsw_ale_create(&ale_params);
+	if (!cpsw->ale) {
 		dev_err(priv->dev, "error initializing ale engine\n");
 		ret = -ENODEV;
 		goto clean_dma_ret;
@@ -2555,7 +2533,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	return 0;
 
 clean_ale_ret:
-	cpsw_ale_destroy(priv->ale);
+	cpsw_ale_destroy(cpsw->ale);
 clean_dma_ret:
 	cpdma_ctlr_destroy(cpsw->dma);
 clean_runtime_disable_ret:
@@ -2568,8 +2546,7 @@ clean_ndev_ret:
 static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 	int ret;
 
 	ret = pm_runtime_get_sync(&pdev->dev);
@@ -2582,7 +2559,7 @@ static int cpsw_remove(struct platform_device *pdev)
 		unregister_netdev(cpsw->slaves[1].ndev);
 	unregister_netdev(ndev);
 
-	cpsw_ale_destroy(priv->ale);
+	cpsw_ale_destroy(cpsw->ale);
 	cpdma_ctlr_destroy(cpsw->dma);
 	of_platform_depopulate(&pdev->dev);
 	pm_runtime_put_sync(&pdev->dev);
-- 
1.9.1
