From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 11/14] net: ethernet: ti: cpsw: move data platform data and slaves info to cpsw_common
Date: Sat,  6 Aug 2016 13:48:41 +0300
Message-ID: <1470480524-6851-12-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These data are common per net dev. No need to hold it in every priv
instance, so move them under cpsw_common.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 271 +++++++++++++++++++++--------------------
 1 file changed, 140 insertions(+), 131 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4080487..29ff489 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -140,9 +140,9 @@ do {								\
 #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
 #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
 
-#define cpsw_slave_index(priv)				\
-		((priv->data.dual_emac) ? priv->emac_port :	\
-		priv->data.active_slave)
+#define cpsw_slave_index(cpsw, priv)				\
+		((cpsw->data.dual_emac) ? priv->emac_port :	\
+		cpsw->data.active_slave)
 #define IRQ_NUM			2
 
 static int debug_level;
@@ -366,10 +366,12 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
 
 struct cpsw_common {
 	struct device			*dev;
+	struct cpsw_platform_data	data;
 	struct cpsw_ss_regs __iomem	*regs;
 	struct cpsw_wr_regs __iomem	*wr_regs;
 	u8 __iomem			*hw_stats;
 	struct cpsw_host_regs __iomem	*host_port_regs;
+	struct cpsw_slave		*slaves;
 	struct cpdma_ctlr		*dma;
 	struct cpdma_chan		*txch, *rxch;
 	bool				quirk_irq;
@@ -383,14 +385,12 @@ struct cpsw_priv {
 	struct napi_struct		napi_rx;
 	struct napi_struct		napi_tx;
 	struct device			*dev;
-	struct cpsw_platform_data	data;
 	u32				msg_enable;
 	u32				version;
 	u32				coal_intvl;
 	u32				bus_freq_mhz;
 	int				rx_packet_max;
 	u8				mac_addr[ETH_ALEN];
-	struct cpsw_slave		*slaves;
 	struct cpsw_ale			*ale;
 	bool				rx_pause;
 	bool				tx_pause;
@@ -492,40 +492,41 @@ static const struct cpsw_stats cpsw_gstrings_stats[] = {
 #define for_each_slave(priv, func, arg...)				\
 	do {								\
 		struct cpsw_slave *slave;				\
+		struct cpsw_common *cpsw = (priv)->cpsw;		\
 		int n;							\
-		if (priv->data.dual_emac)				\
-			(func)((priv)->slaves + priv->emac_port, ##arg);\
+		if (cpsw->data.dual_emac)				\
+			(func)((cpsw)->slaves + priv->emac_port, ##arg);\
 		else							\
-			for (n = (priv)->data.slaves,			\
-					slave = (priv)->slaves;		\
+			for (n = cpsw->data.slaves,			\
+					slave = cpsw->slaves;		\
 					n; n--)				\
 				(func)(slave++, ##arg);			\
 	} while (0)
-#define cpsw_get_slave_ndev(priv, __slave_no__)				\
-		priv->slaves[__slave_no__].ndev
-#define cpsw_get_slave_priv(priv, __slave_no__)				\
-	(((__slave_no__ < priv->data.slaves) &&				\
-		(priv->slaves[__slave_no__].ndev)) ?			\
-		netdev_priv(priv->slaves[__slave_no__].ndev) : NULL)	\
-
-#define cpsw_dual_emac_src_port_detect(status, priv, ndev, skb)		\
+#define cpsw_get_slave_ndev(cpsw, __slave_no__)				\
+		cpsw->slaves[__slave_no__].ndev
+#define cpsw_get_slave_priv(cpsw, __slave_no__)				\
+	(((__slave_no__ < cpsw->data.slaves) &&				\
+		(cpsw->slaves[__slave_no__].ndev)) ?			\
+		netdev_priv(cpsw->slaves[__slave_no__].ndev) : NULL)	\
+
+#define cpsw_dual_emac_src_port_detect(cpsw, status, priv, ndev, skb)	\
 	do {								\
-		if (!priv->data.dual_emac)				\
+		if (!cpsw->data.dual_emac)				\
 			break;						\
 		if (CPDMA_RX_SOURCE_PORT(status) == 1) {		\
-			ndev = cpsw_get_slave_ndev(priv, 0);		\
+			ndev = cpsw_get_slave_ndev(cpsw, 0);		\
 			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		} else if (CPDMA_RX_SOURCE_PORT(status) == 2) {		\
-			ndev = cpsw_get_slave_ndev(priv, 1);		\
+			ndev = cpsw_get_slave_ndev(cpsw, 1);		\
 			priv = netdev_priv(ndev);			\
 			skb->dev = ndev;				\
 		}							\
 	} while (0)
-#define cpsw_add_mcast(priv, addr)					\
+#define cpsw_add_mcast(cpsw, priv, addr)				\
 	do {								\
-		if (priv->data.dual_emac) {				\
-			struct cpsw_slave *slave = priv->slaves +	\
+		if (cpsw->data.dual_emac) {				\
+			struct cpsw_slave *slave = cpsw->slaves +	\
 						priv->emac_port;	\
 			int slave_port = cpsw_get_slave_port(		\
 						slave->slave_num);	\
@@ -547,18 +548,19 @@ static inline int cpsw_get_slave_port(u32 slave_num)
 static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
 	struct cpsw_ale *ale = priv->ale;
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
@@ -581,7 +583,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			unsigned long timeout = jiffies + HZ;
 
 			/* Disable Learn for all ports (host is port 0 and slaves are port 1 and up */
-			for (i = 0; i <= priv->data.slaves; i++) {
+			for (i = 0; i <= cpsw->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 1);
 				cpsw_ale_control_set(ale, i,
@@ -608,7 +610,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 0);
 
 			/* Enable Learn for all ports (host is port 0 and slaves are port 1 and up */
-			for (i = 0; i <= priv->data.slaves; i++) {
+			for (i = 0; i <= cpsw->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 0);
 				cpsw_ale_control_set(ale, i,
@@ -622,12 +624,13 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
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
@@ -650,7 +653,7 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 
 		/* program multicast address list into ALE register */
 		netdev_for_each_mc_addr(ha, ndev) {
-			cpsw_add_mcast(priv, (u8 *)ha->addr);
+			cpsw_add_mcast(cpsw, priv, (u8 *)ha->addr);
 		}
 	}
 }
@@ -699,16 +702,16 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	int			ret = 0;
 	struct cpsw_common	*cpsw = priv->cpsw;
 
-	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
+	cpsw_dual_emac_src_port_detect(cpsw, status, priv, ndev, skb);
 
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
@@ -852,6 +855,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	struct phy_device	*phy = slave->phy;
 	u32			mac_control = 0;
 	u32			slave_port;
+	struct cpsw_common *cpsw = priv->cpsw;
 
 	if (!phy)
 		return;
@@ -859,7 +863,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	slave_port = cpsw_get_slave_port(slave->slave_num);
 
 	if (phy->link) {
-		mac_control = priv->data.mac_control;
+		mac_control = cpsw->data.mac_control;
 
 		/* enable forwarding */
 		cpsw_ale_control_set(priv->ale, slave_port,
@@ -977,11 +981,11 @@ update_return:
 	writel(int_ctrl, &cpsw->wr_regs->int_control);
 
 	cpsw_notice(priv, timer, "Set coalesce to %d usecs.\n", coal_intvl);
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		int i;
 
-		for (i = 0; i < priv->data.slaves; i++) {
-			priv = netdev_priv(priv->slaves[i].ndev);
+		for (i = 0; i < cpsw->data.slaves; i++) {
+			priv = netdev_priv(cpsw->slaves[i].ndev);
 			priv->coal_intvl = coal_intvl;
 		}
 	} else {
@@ -1054,16 +1058,16 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 }
 
-static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
+static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
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
@@ -1075,7 +1079,7 @@ static inline int cpsw_tx_packet_submit(struct cpsw_priv *priv,
 	struct cpsw_common *cpsw = priv->cpsw;
 
 	return cpdma_chan_submit(cpsw->txch, skb, skb->data, skb->len,
-				 priv->emac_port + priv->data.dual_emac);
+				 priv->emac_port + cpsw->data.dual_emac);
 }
 
 static inline void cpsw_add_dual_emac_def_ale_entries(
@@ -1133,7 +1137,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 	slave_port = cpsw_get_slave_port(slave->slave_num);
 
-	if (priv->data.dual_emac)
+	if (cpsw->data.dual_emac)
 		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
 	else
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
@@ -1171,19 +1175,19 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 {
-	const int vlan = priv->data.default_vlan;
+	struct cpsw_common *cpsw = priv->cpsw;
+	const int vlan = cpsw->data.default_vlan;
 	u32 reg;
 	int i;
 	int unreg_mcast_mask;
-	struct cpsw_common *cpsw = priv->cpsw;
 
 	reg = (priv->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
 	       CPSW2_PORT_VLAN;
 
 	writel(vlan, &cpsw->host_port_regs->port_vlan);
 
-	for (i = 0; i < priv->data.slaves; i++)
-		slave_write(priv->slaves + i, vlan, reg);
+	for (i = 0; i < cpsw->data.slaves; i++)
+		slave_write(cpsw->slaves + i, vlan, reg);
 
 	if (priv->ndev->flags & IFF_ALLMULTI)
 		unreg_mcast_mask = ALE_ALL_PORTS;
@@ -1211,7 +1215,7 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	control_reg = readl(&cpsw->regs->control);
 	control_reg |= CPSW_VLAN_AWARE;
 	writel(control_reg, &cpsw->regs->control);
-	fifo_mode = (priv->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
+	fifo_mode = (cpsw->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
 		     CPSW_FIFO_NORMAL_MODE;
 	writel(fifo_mode, &cpsw->host_port_regs->tx_in_ctl);
 
@@ -1223,7 +1227,7 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	cpsw_ale_control_set(priv->ale, HOST_PORT_NUM,
 			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
-	if (!priv->data.dual_emac) {
+	if (!cpsw->data.dual_emac) {
 		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, HOST_PORT_NUM,
 				   0, 0);
 		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
@@ -1260,7 +1264,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		return ret;
 	}
 
-	if (!cpsw_common_res_usage_state(priv))
+	if (!cpsw_common_res_usage_state(cpsw))
 		cpsw_intr_disable(cpsw);
 	netif_carrier_off(ndev);
 
@@ -1271,19 +1275,19 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 CPSW_RTL_VERSION(reg));
 
 	/* initialize host and slave ports */
-	if (!cpsw_common_res_usage_state(priv))
+	if (!cpsw_common_res_usage_state(cpsw))
 		cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
 	/* Add default VLAN */
-	if (!priv->data.dual_emac)
+	if (!cpsw->data.dual_emac)
 		cpsw_add_default_vlan(priv);
 	else
-		cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
+		cpsw_ale_add_vlan(priv->ale, cpsw->data.default_vlan,
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
-	if (!cpsw_common_res_usage_state(priv)) {
-		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
+	if (!cpsw_common_res_usage_state(cpsw)) {
+		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(cpsw, 0);
 		int buf_num;
 
 		/* setup tx dma to fixed prio and zero offset */
@@ -1334,8 +1338,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
 		if (cpts_register(cpsw->dev, priv->cpts,
-				  priv->data.cpts_clock_mult,
-				  priv->data.cpts_clock_shift))
+				  cpsw->data.cpts_clock_mult,
+				  cpsw->data.cpts_clock_shift))
 			dev_err(priv->dev, "error registering cpts device\n");
 
 	}
@@ -1351,8 +1355,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpdma_ctlr_start(cpsw->dma);
 	cpsw_intr_enable(cpsw);
 
-	if (priv->data.dual_emac)
-		priv->slaves[priv->emac_port].open_stat = true;
+	if (cpsw->data.dual_emac)
+		cpsw->slaves[priv->emac_port].open_stat = true;
 	return 0;
 
 err_cleanup:
@@ -1372,8 +1376,8 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_stop_queue(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
-	if (cpsw_common_res_usage_state(priv) <= 1) {
-		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
+	if (cpsw_common_res_usage_state(cpsw) <= 1) {
+		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(cpsw, 0);
 
 		napi_disable(&priv_sl0->napi_rx);
 		napi_disable(&priv_sl0->napi_tx);
@@ -1384,8 +1388,8 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	}
 	for_each_slave(priv, cpsw_slave_stop, priv);
 	pm_runtime_put_sync(cpsw->dev);
-	if (priv->data.dual_emac)
-		priv->slaves[priv->emac_port].open_stat = false;
+	if (cpsw->data.dual_emac)
+		cpsw->slaves[priv->emac_port].open_stat = false;
 	return 0;
 }
 
@@ -1433,7 +1437,8 @@ fail:
 
 static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 {
-	struct cpsw_slave *slave = &priv->slaves[priv->data.active_slave];
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave = &cpsw->slaves[cpsw->data.active_slave];
 	u32 ts_en, seq_id;
 
 	if (!priv->cpts->tx_enable && !priv->cpts->rx_enable) {
@@ -1460,10 +1465,10 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	struct cpsw_common *cpsw = priv->cpsw;
 	u32 ctrl, mtype;
 
-	if (priv->data.dual_emac)
-		slave = &priv->slaves[priv->emac_port];
+	if (cpsw->data.dual_emac)
+		slave = &cpsw->slaves[priv->emac_port];
 	else
-		slave = &priv->slaves[priv->data.active_slave];
+		slave = &cpsw->slaves[cpsw->data.active_slave];
 
 	ctrl = slave_read(slave, CPSW2_CONTROL);
 	switch (priv->version) {
@@ -1582,7 +1587,8 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
 	struct cpsw_priv *priv = netdev_priv(dev);
-	int slave_no = cpsw_slave_index(priv);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -1596,9 +1602,9 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 #endif
 	}
 
-	if (!priv->slaves[slave_no].phy)
+	if (!cpsw->slaves[slave_no].phy)
 		return -EOPNOTSUPP;
-	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);
+	return phy_mii_ioctl(cpsw->slaves[slave_no].phy, req, cmd);
 }
 
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
@@ -1632,8 +1638,8 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 		return ret;
 	}
 
-	if (priv->data.dual_emac) {
-		vid = priv->slaves[priv->emac_port].port_vlan;
+	if (cpsw->data.dual_emac) {
+		vid = cpsw->slaves[priv->emac_port].port_vlan;
 		flags = ALE_VLAN;
 	}
 
@@ -1670,8 +1676,9 @@ static inline int cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
 	int ret;
 	int unreg_mcast_mask = 0;
 	u32 port_mask;
+	struct cpsw_common *cpsw = priv->cpsw;
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		port_mask = (1 << (priv->emac_port + 1)) | ALE_PORT_HOST;
 
 		if (priv->ndev->flags & IFF_ALLMULTI)
@@ -1716,7 +1723,7 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	struct cpsw_common *cpsw = priv->cpsw;
 	int ret;
 
-	if (vid == priv->data.default_vlan)
+	if (vid == cpsw->data.default_vlan)
 		return 0;
 
 	ret = pm_runtime_get_sync(cpsw->dev);
@@ -1725,15 +1732,15 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
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
@@ -1752,7 +1759,7 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	struct cpsw_common *cpsw = priv->cpsw;
 	int ret;
 
-	if (vid == priv->data.default_vlan)
+	if (vid == cpsw->data.default_vlan)
 		return 0;
 
 	ret = pm_runtime_get_sync(cpsw->dev);
@@ -1761,11 +1768,11 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
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
@@ -1805,9 +1812,9 @@ static const struct net_device_ops cpsw_netdev_ops = {
 
 static int cpsw_get_regs_len(struct net_device *ndev)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 
-	return priv->data.ale_entries * ALE_ENTRY_WORDS * sizeof(u32);
+	return cpsw->data.ale_entries * ALE_ENTRY_WORDS * sizeof(u32);
 }
 
 static void cpsw_get_regs(struct net_device *ndev,
@@ -1881,10 +1888,11 @@ static int cpsw_get_settings(struct net_device *ndev,
 			     struct ethtool_cmd *ecmd)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int slave_no = cpsw_slave_index(priv);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
 
-	if (priv->slaves[slave_no].phy)
-		return phy_ethtool_gset(priv->slaves[slave_no].phy, ecmd);
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_gset(cpsw->slaves[slave_no].phy, ecmd);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1892,10 +1900,11 @@ static int cpsw_get_settings(struct net_device *ndev,
 static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int slave_no = cpsw_slave_index(priv);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
 
-	if (priv->slaves[slave_no].phy)
-		return phy_ethtool_sset(priv->slaves[slave_no].phy, ecmd);
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_sset(cpsw->slaves[slave_no].phy, ecmd);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1903,22 +1912,24 @@ static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 static void cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int slave_no = cpsw_slave_index(priv);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
 
 	wol->supported = 0;
 	wol->wolopts = 0;
 
-	if (priv->slaves[slave_no].phy)
-		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
+	if (cpsw->slaves[slave_no].phy)
+		phy_ethtool_get_wol(cpsw->slaves[slave_no].phy, wol);
 }
 
 static int cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int slave_no = cpsw_slave_index(priv);
+	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
 
-	if (priv->slaves[slave_no].phy)
-		return phy_ethtool_set_wol(priv->slaves[slave_no].phy, wol);
+	if (cpsw->slaves[slave_no].phy)
+		return phy_ethtool_set_wol(cpsw->slaves[slave_no].phy, wol);
 	else
 		return -EOPNOTSUPP;
 }
@@ -1994,13 +2005,12 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.complete	= cpsw_ethtool_op_complete,
 };
 
-static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
+static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
 			    u32 slave_reg_ofs, u32 sliver_reg_ofs)
 {
-	struct cpsw_common	*cpsw = priv->cpsw;
 	void __iomem		*regs = cpsw->regs;
 	int			slave_num = slave->slave_num;
-	struct cpsw_slave_data	*data = priv->data.slave_data + slave_num;
+	struct cpsw_slave_data	*data = cpsw->data.slave_data + slave_num;
 
 	slave->data	= data;
 	slave->regs	= regs + slave_reg_ofs;
@@ -2173,11 +2183,11 @@ no_phy_slave:
 
 static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 {
-	struct cpsw_platform_data	*data = &priv->data;
+	struct cpsw_common		*cpsw = priv->cpsw;
+	struct cpsw_platform_data	*data = &cpsw->data;
 	struct net_device		*ndev;
 	struct cpsw_priv		*priv_sl2;
 	int ret = 0;
-	struct cpsw_common		*cpsw = priv->cpsw;
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
@@ -2186,8 +2196,7 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	}
 
 	priv_sl2 = netdev_priv(ndev);
-	priv_sl2->cpsw = priv->cpsw;
-	priv_sl2->data = *data;
+	priv_sl2->cpsw = cpsw;
 	priv_sl2->ndev = ndev;
 	priv_sl2->dev  = &ndev->dev;
 	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
@@ -2205,12 +2214,11 @@ static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 	}
 	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 
-	priv_sl2->slaves = priv->slaves;
 	priv_sl2->coal_intvl = 0;
 	priv_sl2->bus_freq_mhz = priv->bus_freq_mhz;
 	priv_sl2->ale = priv->ale;
 	priv_sl2->emac_port = 1;
-	priv->slaves[1].ndev = ndev;
+	cpsw->slaves[1].ndev = ndev;
 	priv_sl2->cpts = priv->cpts;
 	priv_sl2->version = priv->version;
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
@@ -2323,12 +2331,12 @@ static int cpsw_probe(struct platform_device *pdev)
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
@@ -2340,17 +2348,17 @@ static int cpsw_probe(struct platform_device *pdev)
 
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
 
 	clk = devm_clk_get(&pdev->dev, "fck");
@@ -2424,9 +2432,10 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
-	for (i = 0; i < priv->data.slaves; i++) {
-		struct cpsw_slave *slave = &priv->slaves[i];
-		cpsw_slave_init(slave, priv, slave_offset, sliver_offset);
+	for (i = 0; i < cpsw->data.slaves; i++) {
+		struct cpsw_slave *slave = &cpsw->slaves[i];
+
+		cpsw_slave_init(slave, cpsw, slave_offset, sliver_offset);
 		slave_offset  += slave_size;
 		sliver_offset += SLIVER_SIZE;
 	}
@@ -2547,7 +2556,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	cpsw_notice(priv, probe, "initialized device (regs %pa, irq %d)\n",
 		    &ss_res->start, ndev->irq);
 
-	if (priv->data.dual_emac) {
+	if (cpsw->data.dual_emac) {
 		ret = cpsw_probe_dual_emac(priv);
 		if (ret) {
 			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
@@ -2581,8 +2590,8 @@ static int cpsw_remove(struct platform_device *pdev)
 		return ret;
 	}
 
-	if (priv->data.dual_emac)
-		unregister_netdev(cpsw_get_slave_ndev(priv, 1));
+	if (cpsw->data.dual_emac)
+		unregister_netdev(cpsw_get_slave_ndev(cpsw, 1));
 	unregister_netdev(ndev);
 
 	cpsw_ale_destroy(priv->ale);
@@ -2590,8 +2599,8 @@ static int cpsw_remove(struct platform_device *pdev)
 	of_platform_depopulate(&pdev->dev);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
-	if (priv->data.dual_emac)
-		free_netdev(cpsw_get_slave_ndev(priv, 1));
+	if (cpsw->data.dual_emac)
+		free_netdev(cpsw_get_slave_ndev(cpsw, 1));
 	free_netdev(ndev);
 	return 0;
 }
@@ -2601,14 +2610,14 @@ static int cpsw_suspend(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
-	struct cpsw_priv	*priv = netdev_priv(ndev);
+	struct cpsw_common	*cpsw = ndev_to_cpsw(ndev);
 
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
 		if (netif_running(ndev))
@@ -2625,17 +2634,17 @@ static int cpsw_resume(struct device *dev)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
-	struct cpsw_priv	*priv = netdev_priv(ndev);
+	struct cpsw_common	*cpsw = netdev_priv(ndev);
 
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(dev);
 
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
 		if (netif_running(ndev))
-- 
1.9.1
