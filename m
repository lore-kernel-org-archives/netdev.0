From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 3/3] driver: net: ethernet: cpsw: dual emac interface implementation
Date: Tue, 12 Feb 2013 01:22:20 +0530
Message-ID: <1360612340-9266-4-git-send-email-mugunthanvnm@ti.com>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41877 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759741Ab3BKTw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:52:56 -0500
In-Reply-To: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CPSW switch can act as Dual EMAC by segregating the switch ports
using VLAN and port VLAN as per the TRM description in
14.3.2.10.2 Dual Mac Mode

Following CPSW components will be common for both the interfaces.
* Interrupt source is common for both eth interfaces
* Interrupt pacing is common for both interfaces
* Hardware statistics is common for all the ports
* CPDMA is common for both eth interface
* CPTS is common for both the interface and it should not be enabled on
  both the interface as timestamping information doesn't contain port
  information.

Constrains
* Reserved VID of One port should not be used in other interface which will
  enable switching functionality
* Same VID must not be used in both the interface which will enable switching
  functionality

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    2 +
 drivers/net/ethernet/ti/cpsw.c                 |  335 ++++++++++++++++++++----
 include/linux/platform_data/cpsw.h             |    3 +
 3 files changed, 288 insertions(+), 52 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 6ddd028..ecfdf75 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -24,6 +24,8 @@ Required properties:
 Optional properties:
 - ti,hwmods		: Must be "cpgmac0"
 - no_bd_ram		: Must be 0 or 1
+- dual_emac		: Specifies Switch to act as Dual EMAC
+- dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 4b964bb..4ceed6e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -122,6 +122,10 @@ do {								\
 #define CPSW_VLAN_AWARE		BIT(1)
 #define CPSW_ALE_VLAN_AWARE	1
 
+#define CPSW_FIFO_NORMAL_MODE		(0 << 15)
+#define CPSW_FIFO_DUAL_MAC_MODE		(1 << 15)
+#define CPSW_FIFO_RATE_LIMIT_MODE	(2 << 15)
+
 #define cpsw_enable_irq(priv)	\
 	do {			\
 		u32 i;		\
@@ -254,7 +258,7 @@ struct cpsw_ss_regs {
 struct cpsw_host_regs {
 	u32	max_blks;
 	u32	blk_cnt;
-	u32	flow_thresh;
+	u32	tx_in_ctl;
 	u32	port_vlan;
 	u32	tx_pri_map;
 	u32	cpdma_tx_pri_map;
@@ -281,6 +285,9 @@ struct cpsw_slave {
 	u32				mac_control;
 	struct cpsw_slave_data		*data;
 	struct phy_device		*phy;
+	struct net_device		*ndev;
+	u32				port_vlan;
+	u32				open_stat;
 };
 
 static inline u32 slave_read(struct cpsw_slave *slave, u32 offset)
@@ -320,15 +327,63 @@ struct cpsw_priv {
 	u32 irqs_table[4];
 	u32 num_irqs;
 	struct cpts *cpts;
+	u32 emac_port;
 };
 
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
-#define for_each_slave(priv, func, arg...)			\
-	do {							\
-		int idx;					\
-		for (idx = 0; idx < (priv)->data.slaves; idx++)	\
-			(func)((priv)->slaves + idx, ##arg);	\
+#define for_each_slave(priv, func, arg...)				\
+	do {								\
+		int idx;						\
+		if (priv->data.dual_emac)				\
+			(func)((priv)->slaves + priv->emac_port, ##arg);\
+		else							\
+			for (idx = 0; idx < (priv)->data.slaves; idx++)	\
+				(func)((priv)->slaves + idx, ##arg);	\
+	} while (0)
+#define cpsw_get_slave_ndev(priv, __slave_no__)				\
+	(priv->slaves[__slave_no__].ndev)
+#define cpsw_get_slave_priv(priv, __slave_no__)				\
+	((priv->slaves[__slave_no__].ndev) ?				\
+		netdev_priv(priv->slaves[__slave_no__].ndev) : NULL)	\
+
+#define cpsw_dual_emac_src_port_detect(status, priv, ndev, skb)		\
+	do {								\
+		if (!priv->data.dual_emac)				\
+			break;						\
+		if (CPDMA_RX_SOURCE_PORT(status) == 1) {		\
+			ndev = cpsw_get_slave_ndev(priv, 0);		\
+			priv = netdev_priv(ndev);			\
+			skb->dev = ndev;				\
+		} else if (CPDMA_RX_SOURCE_PORT(status) == 2) {		\
+			ndev = cpsw_get_slave_ndev(priv, 1);		\
+			priv = netdev_priv(ndev);			\
+			skb->dev = ndev;				\
+		}							\
 	} while (0)
+#define cpsw_add_mcast(priv, addr)					\
+	do {								\
+		if (priv->data.dual_emac) {				\
+			struct cpsw_slave *slave = priv->slaves +	\
+						priv->emac_port;	\
+			int slave_port = cpsw_get_slave_port(priv,	\
+						slave->slave_num);	\
+			cpsw_ale_add_mcast(priv->ale, addr,		\
+				1 << slave_port | 1 << priv->host_port,	\
+				ALE_VLAN, slave->port_vlan, 0);		\
+		} else {						\
+			cpsw_ale_add_mcast(priv->ale, addr,		\
+				ALE_ALL_PORTS << priv->host_port,	\
+				0, 0, 0);				\
+		}							\
+	} while (0)
+
+static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
+{
+	if (priv->host_port == 0)
+		return slave_num + 1;
+	else
+		return slave_num;
+}
 
 static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 {
@@ -348,8 +403,7 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 
 		/* program multicast address list into ALE register */
 		netdev_for_each_mc_addr(ha, ndev) {
-			cpsw_ale_add_mcast(priv->ale, (u8 *)ha->addr,
-				ALE_ALL_PORTS << priv->host_port, 0, 0, 0);
+			cpsw_add_mcast(priv, (u8 *)ha->addr);
 		}
 	}
 }
@@ -396,6 +450,8 @@ void cpsw_rx_handler(void *token, int len, int status)
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 	int			ret = 0;
 
+	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
+
 	/* free and bail if we are shutting down */
 	if (unlikely(!netif_running(ndev)) ||
 			unlikely(!netif_carrier_ok(ndev))) {
@@ -437,18 +493,17 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
 		cpsw_intr_disable(priv);
 		cpsw_disable_irq(priv);
 		napi_schedule(&priv->napi);
+	} else {
+		priv = cpsw_get_slave_priv(priv, 1);
+		if (likely(priv) && likely(netif_running(priv->ndev))) {
+			cpsw_intr_disable(priv);
+			cpsw_disable_irq(priv);
+			napi_schedule(&priv->napi);
+		}
 	}
 	return IRQ_HANDLED;
 }
 
-static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
-{
-	if (priv->host_port == 0)
-		return slave_num + 1;
-	else
-		return slave_num;
-}
-
 static int cpsw_poll(struct napi_struct *napi, int budget)
 {
 	struct cpsw_priv	*priv = napi_to_priv(napi);
@@ -566,6 +621,54 @@ static inline int __show_stat(char *buf, int maxlen, const char *name, u32 val)
 				leader + strlen(name), val);
 }
 
+static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
+{
+	u32 i;
+	u32 usage_count = 0;
+
+	if (!priv->data.dual_emac)
+		return 0;
+
+	for (i = 0; i < priv->data.slaves; i++)
+		if (priv->slaves[i].open_stat)
+			usage_count++;
+
+	return usage_count;
+}
+
+static inline int cpsw_tx_packet_submit(struct net_device *ndev,
+			struct cpsw_priv *priv, struct sk_buff *skb)
+{
+	if (!priv->data.dual_emac)
+		return cpdma_chan_submit(priv->txch, skb, skb->data,
+				  skb->len, 0, GFP_KERNEL);
+
+	if (ndev == cpsw_get_slave_ndev(priv, 0))
+		return cpdma_chan_submit(priv->txch, skb, skb->data,
+				  skb->len, 1, GFP_KERNEL);
+	else
+		return cpdma_chan_submit(priv->txch, skb, skb->data,
+				  skb->len, 2, GFP_KERNEL);
+}
+
+static inline void cpsw_add_dual_emac_def_ale_entries(
+		struct cpsw_priv *priv, struct cpsw_slave *slave,
+		u32 slave_port)
+{
+	u32 port_mask = 1 << slave_port | 1 << priv->host_port;
+
+	if (priv->version == CPSW_VERSION_1)
+		slave_write(slave, slave->port_vlan, CPSW1_PORT_VLAN);
+	else
+		slave_write(slave, slave->port_vlan, CPSW2_PORT_VLAN);
+	cpsw_ale_add_vlan(priv->ale, slave->port_vlan, port_mask,
+			  port_mask, port_mask, 0);
+	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+			   port_mask, ALE_VLAN, slave->port_vlan, 0);
+	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
+		priv->host_port, ALE_VLAN, slave->port_vlan);
+}
+
 static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	char name[32];
@@ -595,8 +698,11 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
 
-	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
-			   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
+	if (priv->data.dual_emac)
+		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
+	else
+		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
 	slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
@@ -634,6 +740,7 @@ static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 static void cpsw_init_host_port(struct cpsw_priv *priv)
 {
 	u32 control_reg;
+	u32 fifo_mode;
 
 	/* soft reset the controller and initialize ale */
 	soft_reset("cpsw", &priv->regs->soft_reset);
@@ -645,6 +752,9 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	control_reg = readl(&priv->regs->control);
 	control_reg |= CPSW_VLAN_AWARE;
 	writel(control_reg, &priv->regs->control);
+	fifo_mode = (priv->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
+		     CPSW_FIFO_NORMAL_MODE;
+	writel(fifo_mode, &priv->host_port_regs->tx_in_ctl);
 
 	/* setup host port priority mapping */
 	__raw_writel(CPDMA_TX_PRIORITY_MAP,
@@ -654,9 +764,12 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	cpsw_ale_control_set(priv->ale, priv->host_port,
 			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
-	cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port, 0, 0);
-	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
-			   1 << priv->host_port, 0, 0, ALE_MCAST_FWD_2);
+	if (!priv->data.dual_emac) {
+		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port,
+				   0, 0);
+		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
+				   1 << priv->host_port, 0, 0, ALE_MCAST_FWD_2);
+	}
 }
 
 static int cpsw_ndo_open(struct net_device *ndev)
@@ -665,7 +778,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	int i, ret;
 	u32 reg;
 
-	cpsw_intr_disable(priv);
+	if (!cpsw_common_res_usage_state(priv))
+		cpsw_intr_disable(priv);
 	netif_carrier_off(ndev);
 
 	pm_runtime_get_sync(&priv->pdev->dev);
@@ -677,46 +791,54 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 CPSW_RTL_VERSION(reg));
 
 	/* initialize host and slave ports */
-	cpsw_init_host_port(priv);
+	if (!cpsw_common_res_usage_state(priv))
+		cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
 	/* Add default VLAN */
-	cpsw_add_default_vlan(priv);
+	if (!priv->data.dual_emac)
+		cpsw_add_default_vlan(priv);
 
-	/* setup tx dma to fixed prio and zero offset */
-	cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
-	cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
+	if (!cpsw_common_res_usage_state(priv)) {
+		/* setup tx dma to fixed prio and zero offset */
+		cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
+		cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
 
-	/* disable priority elevation and enable statistics on all ports */
-	__raw_writel(0, &priv->regs->ptype);
+		/* disable priority elevation */
+		__raw_writel(0, &priv->regs->ptype);
 
-	/* enable statistics collection only on the host port */
-	__raw_writel(0x7, &priv->regs->stat_port_en);
+		/* enable statistics collection only on all ports */
+		__raw_writel(0x7, &priv->regs->stat_port_en);
 
-	if (WARN_ON(!priv->data.rx_descs))
-		priv->data.rx_descs = 128;
+		if (WARN_ON(!priv->data.rx_descs))
+			priv->data.rx_descs = 128;
 
-	for (i = 0; i < priv->data.rx_descs; i++) {
-		struct sk_buff *skb;
+		for (i = 0; i < priv->data.rx_descs; i++) {
+			struct sk_buff *skb;
 
-		ret = -ENOMEM;
-		skb = netdev_alloc_skb_ip_align(priv->ndev,
-						priv->rx_packet_max);
-		if (!skb)
-			break;
-		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
+			ret = -ENOMEM;
+			skb = netdev_alloc_skb_ip_align(priv->ndev,
+							priv->rx_packet_max);
+			if (!skb)
+				break;
+			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
 					skb_tailroom(skb), 0, GFP_KERNEL);
-		if (WARN_ON(ret < 0))
-			break;
+			if (WARN_ON(ret < 0))
+				break;
+		}
+		/* continue even if we didn't manage to submit all
+		 * receive descs
+		 */
+		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 	}
-	/* continue even if we didn't manage to submit all receive descs */
-	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 	napi_enable(&priv->napi);
 	cpdma_ctlr_eoi(priv->dma);
 
+	if (priv->data.dual_emac)
+		priv->slaves[priv->emac_port].open_stat = true;
 	return 0;
 }
 
@@ -737,12 +859,17 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_stop_queue(priv->ndev);
 	napi_disable(&priv->napi);
 	netif_carrier_off(priv->ndev);
-	cpsw_intr_disable(priv);
-	cpdma_ctlr_int_ctrl(priv->dma, false);
-	cpdma_ctlr_stop(priv->dma);
-	cpsw_ale_stop(priv->ale);
+
+	if (cpsw_common_res_usage_state(priv) <= 1) {
+		cpsw_intr_disable(priv);
+		cpdma_ctlr_int_ctrl(priv->dma, false);
+		cpdma_ctlr_stop(priv->dma);
+		cpsw_ale_stop(priv->ale);
+	}
 	for_each_slave(priv, cpsw_slave_stop, priv);
 	pm_runtime_put_sync(&priv->pdev->dev);
+	if (priv->data.dual_emac)
+		priv->slaves[priv->emac_port].open_stat = false;
 	return 0;
 }
 
@@ -766,8 +893,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	ret = cpdma_chan_submit(priv->txch, skb, skb->data,
-				skb->len, 0, GFP_KERNEL);
+	ret = cpsw_tx_packet_submit(ndev, priv, skb);
 	if (unlikely(ret != 0)) {
 		cpsw_err(priv, tx_err, "desc submit failed\n");
 		goto fail;
@@ -836,9 +962,14 @@ static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 
 static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 {
-	struct cpsw_slave *slave = &priv->slaves[priv->data.cpts_active_slave];
+	struct cpsw_slave *slave;
 	u32 ctrl, mtype;
 
+	if (priv->data.dual_emac)
+		slave = &priv->slaves[priv->emac_port];
+	else
+		slave = &priv->slaves[priv->data.cpts_active_slave];
+
 	ctrl = slave_read(slave, CPSW2_CONTROL);
 	ctrl &= ~CTRL_ALL_TS_MASK;
 
@@ -1124,6 +1255,7 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 	slave->data	= data;
 	slave->regs	= regs + slave_reg_ofs;
 	slave->sliver	= regs + sliver_reg_ofs;
+	slave->port_vlan = data->dual_emac_res_vlan;
 }
 
 static int cpsw_probe_dt(struct cpsw_platform_data *data,
@@ -1204,6 +1336,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->mac_control = prop;
 
+	if (!of_property_read_u32(node, "dual_emac", &prop))
+		data->dual_emac = prop;
+
 	/*
 	 * Populate all the child nodes here...
 	 */
@@ -1237,6 +1372,18 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		if (mac_addr)
 			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 
+		if (data->dual_emac) {
+			if (of_property_read_u32(node, "dual_emac_res_vlan",
+						 &prop)) {
+				pr_err("Missing dual_emac_res_vlan in DT.\n");
+				slave_data->dual_emac_res_vlan = i+1;
+				pr_err("Using %d as Reserved VLAN for %d slave\n",
+				       slave_data->dual_emac_res_vlan, i);
+			} else {
+				slave_data->dual_emac_res_vlan = prop;
+			}
+		}
+
 		i++;
 	}
 
@@ -1247,6 +1394,79 @@ error_ret:
 	return ret;
 }
 
+static int cpsw_probe_dual_emac(struct platform_device *pdev,
+				struct cpsw_priv *priv)
+{
+	struct cpsw_platform_data	*data = &priv->data;
+	struct net_device		*ndev;
+	struct cpsw_priv		*priv_sl2;
+	int ret = 0, i;
+
+	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
+	if (!ndev) {
+		pr_err("cpsw: error allocating net_device\n");
+		return -ENOMEM;
+	}
+
+	priv_sl2 = netdev_priv(ndev);
+	spin_lock_init(&priv_sl2->lock);
+	priv_sl2->data = *data;
+	priv_sl2->pdev = pdev;
+	priv_sl2->ndev = ndev;
+	priv_sl2->dev  = &ndev->dev;
+	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
+	priv_sl2->rx_packet_max = max(rx_packet_max, 128);
+
+	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
+		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
+			ETH_ALEN);
+		pr_info("cpsw: Detected MACID = %pM\n", priv_sl2->mac_addr);
+	} else {
+		random_ether_addr(priv_sl2->mac_addr);
+		pr_info("cpsw: Random MACID = %pM\n", priv_sl2->mac_addr);
+	}
+	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
+
+	priv_sl2->slaves = priv->slaves;
+	priv_sl2->clk = priv->clk;
+
+	priv_sl2->cpsw_res = priv->cpsw_res;
+	priv_sl2->regs = priv->regs;
+	priv_sl2->host_port = priv->host_port;
+	priv_sl2->host_port_regs = priv->host_port_regs;
+	priv_sl2->wr_regs = priv->wr_regs;
+	priv_sl2->dma = priv->dma;
+	priv_sl2->txch = priv->txch;
+	priv_sl2->rxch = priv->rxch;
+	priv_sl2->ale = priv->ale;
+	priv_sl2->emac_port = 1;
+	priv->slaves[1].ndev = ndev;
+	priv_sl2->cpts = priv->cpts;
+	priv_sl2->version = priv->version;
+
+	for (i = 0; i < priv->num_irqs; i++) {
+		priv_sl2->irqs_table[i] = priv->irqs_table[i];
+		priv_sl2->num_irqs = priv->num_irqs;
+	}
+
+	ndev->features |= NETIF_F_HW_VLAN_FILTER;
+
+	ndev->netdev_ops = &cpsw_netdev_ops;
+	SET_ETHTOOL_OPS(ndev, &cpsw_ethtool_ops);
+	netif_napi_add(ndev, &priv_sl2->napi, cpsw_poll, CPSW_POLL_WEIGHT);
+
+	/* register the network device */
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+	ret = register_netdev(ndev);
+	if (ret) {
+		pr_err("cpsw: error registering net device\n");
+		free_netdev(ndev);
+		ret = -ENODEV;
+	}
+
+	return ret;
+}
+
 static int cpsw_probe(struct platform_device *pdev)
 {
 	struct cpsw_platform_data	*data = pdev->dev.platform_data;
@@ -1310,6 +1530,9 @@ static int cpsw_probe(struct platform_device *pdev)
 	for (i = 0; i < data->slaves; i++)
 		priv->slaves[i].slave_num = i;
 
+	priv->slaves[0].ndev = ndev;
+	priv->emac_port = 0;
+
 	priv->clk = clk_get(&pdev->dev, "fck");
 	if (IS_ERR(priv->clk)) {
 		dev_err(&pdev->dev, "fck is not found\n");
@@ -1484,6 +1707,14 @@ static int cpsw_probe(struct platform_device *pdev)
 	cpsw_notice(priv, probe, "initialized device (regs %x, irq %d)\n",
 		  priv->cpsw_res->start, ndev->irq);
 
+	if (priv->data.dual_emac) {
+		ret = cpsw_probe_dual_emac(pdev, priv);
+		if (ret) {
+			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
+			goto clean_irq_ret;
+		}
+	}
+
 	return 0;
 
 clean_irq_ret:
diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
index e962cfd..798fb80 100644
--- a/include/linux/platform_data/cpsw.h
+++ b/include/linux/platform_data/cpsw.h
@@ -21,6 +21,8 @@ struct cpsw_slave_data {
 	char		phy_id[MII_BUS_ID_SIZE];
 	int		phy_if;
 	u8		mac_addr[ETH_ALEN];
+	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
+
 };
 
 struct cpsw_platform_data {
@@ -36,6 +38,7 @@ struct cpsw_platform_data {
 	u32	rx_descs;	/* Number of Rx Descriptios */
 	u32	mac_control;	/* Mac control register */
 	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
+	bool	dual_emac;	/* Enable Dual EMAC mode */
 };
 
 #endif /* __CPSW_H__ */
-- 
1.7.9.5
