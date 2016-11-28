From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/6] net: ethernet: ti: netcp: add support of cpts
Date: Mon, 28 Nov 2016 17:04:23 -0600
Message-ID: <20161128230428.6872-2-grygorii.strashko@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128230428.6872-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

This patch adds support of the cpts device found in the
gbe and 10gbe ethernet switches on the keystone 2 SoCs
(66AK2E/L/Hx, 66AK2Gx).

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |   9 +
 drivers/net/ethernet/ti/Kconfig                    |   7 +-
 drivers/net/ethernet/ti/netcp.h                    |   2 +-
 drivers/net/ethernet/ti/netcp_core.c               |  18 +-
 drivers/net/ethernet/ti/netcp_ethss.c              | 437 ++++++++++++++++++++-
 5 files changed, 459 insertions(+), 14 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index 04ba1dc..c37b54e 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -113,6 +113,15 @@ Optional properties:
 				will only initialize these ports and attach PHY
 				driver to them if needed.
 
+ Properties related to cpts configurations.
+	- cpts_clock_mult/cpts_clock_shift:
+		used for converting time counter cycles to ns as in
+
+		ns = (cycles * clock_mult) >> _shift
+
+		Defaults: clock_mult, clock_shift = calculated from
+		CPTS refclk
+
 NetCP interface properties: Interface specification for NetCP sub-modules.
 Required properties:
 - rx-channel:	the navigator packet dma channel name for rx.
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index ff7f518..dc217fd 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -75,12 +75,13 @@ config TI_CPSW
 
 config TI_CPTS
 	tristate "TI Common Platform Time Sync (CPTS) Support"
-	depends on TI_CPSW
+	depends on TI_CPSW || TI_KEYSTONE_NETCP
 	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
-	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
-	  and Layer 2 packets, and the driver offers a PTP Hardware Clock.
+	  the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
+	  The unit can time stamp PTP UDP/IPv4 and Layer 2 packets, and the
+	  driver offers a PTP Hardware Clock.
 
 config TI_KEYSTONE_NETCP
 	tristate "TI Keystone NETCP Core Support"
diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
index 17a26a4..0f58c58 100644
--- a/drivers/net/ethernet/ti/netcp.h
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -121,7 +121,7 @@ struct netcp_packet {
 	bool			rxtstamp_complete;
 	void			*ts_context;
 
-	int	(*txtstamp_complete)(void *ctx, struct netcp_packet *pkt);
+	void (*txtstamp)(void *ctx, struct sk_buff *skb);
 };
 
 static inline u32 *netcp_push_psdata(struct netcp_packet *p_info,
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 3251666..a740e60 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -100,6 +100,11 @@ struct netcp_intf_modpriv {
 	void			*module_priv;
 };
 
+struct netcp_tx_cb {
+	void	*ts_context;
+	void	(*txtstamp)(void *context, struct sk_buff *skb);
+};
+
 static LIST_HEAD(netcp_devices);
 static LIST_HEAD(netcp_modules);
 static DEFINE_MUTEX(netcp_modules_lock);
@@ -730,6 +735,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 
 	/* Call each of the RX hooks */
 	p_info.skb = skb;
+	skb->dev = netcp->ndev;
 	p_info.rxtstamp_complete = false;
 	list_for_each_entry(rx_hook, &netcp->rxhook_list_head, list) {
 		int ret;
@@ -987,6 +993,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 					  unsigned int budget)
 {
 	struct knav_dma_desc *desc;
+	struct netcp_tx_cb *tx_cb;
 	struct sk_buff *skb;
 	unsigned int dma_sz;
 	dma_addr_t dma;
@@ -1014,6 +1021,10 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			continue;
 		}
 
+		tx_cb = (struct netcp_tx_cb *)skb->cb;
+		if (tx_cb->txtstamp)
+			tx_cb->txtstamp(tx_cb->ts_context, skb);
+
 		if (netif_subqueue_stopped(netcp->ndev, skb) &&
 		    netif_running(netcp->ndev) &&
 		    (knav_pool_count(netcp->tx_pool) >
@@ -1154,6 +1165,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	struct netcp_tx_pipe *tx_pipe = NULL;
 	struct netcp_hook_list *tx_hook;
 	struct netcp_packet p_info;
+	struct netcp_tx_cb *tx_cb;
 	unsigned int dma_sz;
 	dma_addr_t dma;
 	u32 tmp = 0;
@@ -1164,7 +1176,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	p_info.tx_pipe = NULL;
 	p_info.psdata_len = 0;
 	p_info.ts_context = NULL;
-	p_info.txtstamp_complete = NULL;
+	p_info.txtstamp = NULL;
 	p_info.epib = desc->epib;
 	p_info.psdata = (u32 __force *)desc->psdata;
 	memset(p_info.epib, 0, KNAV_DMA_NUM_EPIB_WORDS * sizeof(__le32));
@@ -1189,6 +1201,10 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 		goto out;
 	}
 
+	tx_cb = (struct netcp_tx_cb *)skb->cb;
+	tx_cb->ts_context = p_info.ts_context;
+	tx_cb->txtstamp = p_info.txtstamp;
+
 	/* update descriptor */
 	if (p_info.psdata_len) {
 		/* psdata points to both native-endian and device-endian data */
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index d543298..4856521 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -23,10 +23,13 @@
 #include <linux/of_mdio.h>
 #include <linux/of_address.h>
 #include <linux/if_vlan.h>
+#include <linux/ptp_classify.h>
+#include <linux/net_tstamp.h>
 #include <linux/ethtool.h>
 
 #include "cpsw_ale.h"
 #include "netcp.h"
+#include "cpts.h"
 
 #define NETCP_DRIVER_NAME		"TI KeyStone Ethernet Driver"
 #define NETCP_DRIVER_VERSION		"v1.0"
@@ -51,6 +54,7 @@
 #define GBE13_EMAC_OFFSET		0x100
 #define GBE13_SLAVE_PORT2_OFFSET	0x200
 #define GBE13_HW_STATS_OFFSET		0x300
+#define GBE13_CPTS_OFFSET		0x500
 #define GBE13_ALE_OFFSET		0x600
 #define GBE13_HOST_PORT_NUM		0
 #define GBE13_NUM_ALE_ENTRIES		1024
@@ -74,6 +78,7 @@
 #define GBENU_SLAVE_PORT_OFFSET		0x2000
 #define GBENU_EMAC_OFFSET		0x2330
 #define GBENU_HW_STATS_OFFSET		0x1a000
+#define GBENU_CPTS_OFFSET		0x1d000
 #define GBENU_ALE_OFFSET		0x1e000
 #define GBENU_HOST_PORT_NUM		0
 #define GBENU_NUM_ALE_ENTRIES		1024
@@ -93,6 +98,7 @@
 #define XGBE10_HOST_PORT_OFFSET		0x34
 #define XGBE10_SLAVE_PORT_OFFSET	0x64
 #define XGBE10_EMAC_OFFSET		0x400
+#define XGBE10_CPTS_OFFSET		0x600
 #define XGBE10_ALE_OFFSET		0x700
 #define XGBE10_HW_STATS_OFFSET		0x800
 #define XGBE10_HOST_PORT_NUM		0
@@ -155,6 +161,7 @@
 
 #define GBE_TX_QUEUE				648
 #define	GBE_TXHOOK_ORDER			0
+#define	GBE_RXHOOK_ORDER			0
 #define GBE_DEFAULT_ALE_AGEOUT			30
 #define SLAVE_LINK_IS_XGMII(s) ((s)->link_interface >= XGMII_LINK_MAC_PHY)
 #define NETCP_LINK_STATE_INVALID		-1
@@ -169,6 +176,56 @@
 
 #define HOST_TX_PRI_MAP_DEFAULT			0x00000000
 
+#if IS_ENABLED(CONFIG_TI_CPTS)
+/* Px_TS_CTL register fields */
+#define TS_RX_ANX_F_EN				BIT(0)
+#define TS_RX_VLAN_LT1_EN			BIT(1)
+#define TS_RX_VLAN_LT2_EN			BIT(2)
+#define TS_RX_ANX_D_EN				BIT(3)
+#define TS_TX_ANX_F_EN				BIT(4)
+#define TS_TX_VLAN_LT1_EN			BIT(5)
+#define TS_TX_VLAN_LT2_EN			BIT(6)
+#define TS_TX_ANX_D_EN				BIT(7)
+#define TS_LT2_EN				BIT(8)
+#define TS_RX_ANX_E_EN				BIT(9)
+#define TS_TX_ANX_E_EN				BIT(10)
+#define TS_MSG_TYPE_EN_SHIFT			16
+#define TS_MSG_TYPE_EN_MASK			0xffff
+
+/* Px_TS_SEQ_LTYPE register fields */
+#define TS_SEQ_ID_OFS_SHIFT			16
+#define TS_SEQ_ID_OFS_MASK			0x3f
+
+/* Px_TS_CTL_LTYPE2 register fields */
+#define TS_107					BIT(16)
+#define TS_129					BIT(17)
+#define TS_130					BIT(18)
+#define TS_131					BIT(19)
+#define TS_132					BIT(20)
+#define TS_319					BIT(21)
+#define TS_320					BIT(22)
+#define TS_TTL_NONZERO				BIT(23)
+#define TS_UNI_EN				BIT(24)
+#define TS_UNI_EN_SHIFT				24
+
+#define TS_TX_ANX_ALL_EN	 \
+	(TS_TX_ANX_D_EN	| TS_TX_ANX_E_EN | TS_TX_ANX_F_EN)
+
+#define TS_RX_ANX_ALL_EN	 \
+	(TS_RX_ANX_D_EN	| TS_RX_ANX_E_EN | TS_RX_ANX_F_EN)
+
+#define TS_CTL_DST_PORT				TS_319
+#define TS_CTL_DST_PORT_SHIFT			21
+
+#define TS_CTL_MADDR_ALL	\
+	(TS_107 | TS_129 | TS_130 | TS_131 | TS_132)
+
+#define TS_CTL_MADDR_SHIFT			16
+
+/* The PTP event messages - Sync, Delay_Req, Pdelay_Req, and Pdelay_Resp. */
+#define EVENT_MSG_BITS (BIT(0) | BIT(1) | BIT(2) | BIT(3))
+#endif /* CONFIG_TI_CPTS */
+
 struct xgbe_ss_regs {
 	u32	id_ver;
 	u32	synce_count;
@@ -616,6 +673,13 @@ struct gbe_hw_stats {
 #define GBE_MAX_HW_STAT_MODS			9
 #define GBE_HW_STATS_REG_MAP_SZ			0x100
 
+struct ts_ctl {
+	int     uni;
+	u8      dst_port_map;
+	u8      maddr_map;
+	u8      ts_mcast_type;
+};
+
 struct gbe_slave {
 	void __iomem			*port_regs;
 	void __iomem			*emac_regs;
@@ -630,6 +694,7 @@ struct gbe_slave {
 	u32				mac_control;
 	u8				phy_port_t;
 	struct device_node		*phy_node;
+	struct ts_ctl                   ts_ctl;
 	struct list_head		slave_list;
 };
 
@@ -655,6 +720,7 @@ struct gbe_priv {
 	void __iomem			*switch_regs;
 	void __iomem			*host_port_regs;
 	void __iomem			*ale_reg;
+	void __iomem                    *cpts_reg;
 	void __iomem			*sgmii_port_regs;
 	void __iomem			*sgmii_port34_regs;
 	void __iomem			*xgbe_serdes_regs;
@@ -678,6 +744,9 @@ struct gbe_priv {
 	int				num_et_stats;
 	/*  Lock for updating the hwstats */
 	spinlock_t			hw_stats_lock;
+
+	int                             cpts_registered;
+	struct cpts                     *cpts;
 };
 
 struct gbe_intf {
@@ -1904,6 +1973,49 @@ static int keystone_set_settings(struct net_device *ndev,
 	return phy_ethtool_sset(phy, cmd);
 }
 
+#if IS_ENABLED(CONFIG_TI_CPTS)
+static int keystone_get_ts_info(struct net_device *ndev,
+				struct ethtool_ts_info *info)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf || !gbe_intf->gbe_dev->cpts)
+		return -EINVAL;
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->phc_index = gbe_intf->gbe_dev->cpts->phc_index;
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+	return 0;
+}
+#else
+static int keystone_get_ts_info(struct net_device *ndev,
+				struct ethtool_ts_info *info)
+{
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE;
+	info->phc_index = -1;
+	info->tx_types = 0;
+	info->rx_filters = 0;
+	return 0;
+}
+#endif /* CONFIG_TI_CPTS */
+
 static const struct ethtool_ops keystone_ethtool_ops = {
 	.get_drvinfo		= keystone_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -1914,6 +2026,7 @@ static const struct ethtool_ops keystone_ethtool_ops = {
 	.get_ethtool_stats	= keystone_get_ethtool_stats,
 	.get_settings		= keystone_get_settings,
 	.set_settings		= keystone_set_settings,
+	.get_ts_info		= keystone_get_ts_info,
 };
 
 #define mac_hi(mac)	(((mac)[0] << 0) | ((mac)[1] << 8) |	\
@@ -2357,16 +2470,279 @@ static int gbe_del_vid(void *intf_priv, int vid)
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_TI_CPTS)
+#define HAS_PHY_TXTSTAMP(p) ((p)->drv && (p)->drv->txtstamp)
+#define HAS_PHY_RXTSTAMP(p) ((p)->drv && (p)->drv->rxtstamp)
+
+static void gbe_txtstamp(void *context, struct sk_buff *skb)
+{
+	struct gbe_intf *gbe_intf = context;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	cpts_tx_timestamp(gbe_dev->cpts, skb);
+}
+
+static bool gbe_need_txtstamp(struct gbe_intf *gbe_intf,
+			      const struct netcp_packet *p_info)
+{
+	struct sk_buff *skb = p_info->skb;
+	unsigned int class = ptp_classify_raw(skb);
+
+	if (class == PTP_CLASS_NONE)
+		return false;
+
+	switch (class) {
+	case PTP_CLASS_V1_IPV4:
+	case PTP_CLASS_V1_IPV6:
+	case PTP_CLASS_V2_IPV4:
+	case PTP_CLASS_V2_IPV6:
+	case PTP_CLASS_V2_L2:
+	case (PTP_CLASS_V2_VLAN | PTP_CLASS_L2):
+	case (PTP_CLASS_V2_VLAN | PTP_CLASS_IPV4):
+	case (PTP_CLASS_V2_VLAN | PTP_CLASS_IPV6):
+		return true;
+	}
+
+	return false;
+}
+
+static int gbe_txtstamp_mark_pkt(struct gbe_intf *gbe_intf,
+				 struct netcp_packet *p_info)
+{
+	struct phy_device *phydev = p_info->skb->dev->phydev;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	if (!(skb_shinfo(p_info->skb)->tx_flags & SKBTX_HW_TSTAMP) ||
+	    !cpts_is_tx_enabled(gbe_dev->cpts))
+		return 0;
+
+	/* If phy has the txtstamp api, assume it will do it.
+	 * We mark it here because skb_tx_timestamp() is called
+	 * after all the txhooks are called.
+	 */
+	if (phydev && HAS_PHY_TXTSTAMP(phydev)) {
+		skb_shinfo(p_info->skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		return 0;
+	}
+
+	if (gbe_need_txtstamp(gbe_intf, p_info)) {
+		p_info->txtstamp = gbe_txtstamp;
+		p_info->ts_context = (void *)gbe_intf;
+		skb_shinfo(p_info->skb)->tx_flags |= SKBTX_IN_PROGRESS;
+	}
+
+	return 0;
+}
+
+static int gbe_rxtstamp(struct gbe_intf *gbe_intf, struct netcp_packet *p_info)
+{
+	struct phy_device *phydev = p_info->skb->dev->phydev;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	if (p_info->rxtstamp_complete)
+		return 0;
+
+	if (phydev && HAS_PHY_RXTSTAMP(phydev)) {
+		p_info->rxtstamp_complete = true;
+		return 0;
+	}
+
+	cpts_rx_timestamp(gbe_dev->cpts, p_info->skb);
+	p_info->rxtstamp_complete = true;
+
+	return 0;
+}
+
+static int gbe_hwtstamp_get(struct gbe_intf *gbe_intf, struct ifreq *ifr)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	struct cpts *cpts = gbe_dev->cpts;
+	struct hwtstamp_config cfg;
+
+	if (!cpts)
+		return -EOPNOTSUPP;
+
+	cfg.flags = 0;
+	cfg.tx_type = cpts_is_tx_enabled(cpts) ?
+		      HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	cfg.rx_filter = (cpts_is_rx_enabled(cpts) ?
+			 cpts->rx_enable : HWTSTAMP_FILTER_NONE);
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
+static void gbe_hwtstamp(struct gbe_intf *gbe_intf)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	struct gbe_slave *slave = gbe_intf->slave;
+	u32 ts_en, seq_id, ctl;
+
+	if (!cpts_is_rx_enabled(gbe_dev->cpts) &&
+	    !cpts_is_tx_enabled(gbe_dev->cpts)) {
+		writel(0, GBE_REG_ADDR(slave, port_regs, ts_ctl));
+		return;
+	}
+
+	seq_id = (30 << TS_SEQ_ID_OFS_SHIFT) | ETH_P_1588;
+	ts_en = EVENT_MSG_BITS << TS_MSG_TYPE_EN_SHIFT;
+	ctl = ETH_P_1588 | TS_TTL_NONZERO |
+		(slave->ts_ctl.dst_port_map << TS_CTL_DST_PORT_SHIFT) |
+		(slave->ts_ctl.uni ?  TS_UNI_EN :
+			slave->ts_ctl.maddr_map << TS_CTL_MADDR_SHIFT);
+
+	if (cpts_is_tx_enabled(gbe_dev->cpts))
+		ts_en |= (TS_TX_ANX_ALL_EN | TS_TX_VLAN_LT1_EN);
+
+	if (cpts_is_rx_enabled(gbe_dev->cpts))
+		ts_en |= (TS_RX_ANX_ALL_EN | TS_RX_VLAN_LT1_EN);
+
+	writel(ts_en,  GBE_REG_ADDR(slave, port_regs, ts_ctl));
+	writel(seq_id, GBE_REG_ADDR(slave, port_regs, ts_seq_ltype));
+	writel(ctl,    GBE_REG_ADDR(slave, port_regs, ts_ctl_ltype2));
+}
+
+static int gbe_hwtstamp_set(struct gbe_intf *gbe_intf, struct ifreq *ifr)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	struct cpts *cpts = gbe_dev->cpts;
+	struct hwtstamp_config cfg;
+
+	if (!cpts)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (cfg.flags)
+		return -EINVAL;
+
+	switch (cfg.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		cpts_tx_enable(cpts, 0);
+		break;
+	case HWTSTAMP_TX_ON:
+		cpts_tx_enable(cpts, 1);
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (cfg.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		cpts_rx_enable(cpts, 0);
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		cpts_rx_enable(cpts, HWTSTAMP_FILTER_PTP_V1_L4_EVENT);
+		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		cpts_rx_enable(cpts, HWTSTAMP_FILTER_PTP_V2_EVENT);
+		cfg.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	gbe_hwtstamp(gbe_intf);
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
+static void gbe_register_cpts(struct gbe_priv *gbe_dev)
+{
+	if (!gbe_dev->cpts)
+		return;
+
+	if (gbe_dev->cpts_registered > 0)
+		goto done;
+
+	if (cpts_register(gbe_dev->cpts)) {
+		dev_err(gbe_dev->dev, "error registering cpts device\n");
+		return;
+	}
+
+done:
+	++gbe_dev->cpts_registered;
+}
+
+static void gbe_unregister_cpts(struct gbe_priv *gbe_dev)
+{
+	if (!gbe_dev->cpts || (gbe_dev->cpts_registered <= 0))
+		return;
+
+	if (--gbe_dev->cpts_registered)
+		return;
+
+	cpts_unregister(gbe_dev->cpts);
+}
+#else
+static inline int gbe_txtstamp_mark_pkt(struct gbe_intf *gbe_intf,
+					struct netcp_packet *p_info)
+{
+	return 0;
+}
+
+static inline int gbe_rxtstamp(struct gbe_intf *gbe_intf,
+			       struct netcp_packet *p_info)
+{
+	return 0;
+}
+
+static inline int gbe_hwtstamp(struct gbe_intf *gbe_intf,
+			       struct ifreq *ifr, int cmd)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void gbe_register_cpts(struct gbe_priv *gbe_dev)
+{
+}
+
+static inline void gbe_unregister_cpts(struct gbe_priv *gbe_dev)
+{
+}
+
+static inline int gbe_hwtstamp_get(struct gbe_intf *gbe_intf, struct ifreq *req)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int gbe_hwtstamp_set(struct gbe_intf *gbe_intf, struct ifreq *req)
+{
+	return -EOPNOTSUPP;
+}
+#endif /* CONFIG_TI_CPTS */
+
 static int gbe_ioctl(void *intf_priv, struct ifreq *req, int cmd)
 {
 	struct gbe_intf *gbe_intf = intf_priv;
 	struct phy_device *phy = gbe_intf->slave->phy;
-	int ret = -EOPNOTSUPP;
+
+	if (!phy || !phy->drv->hwtstamp) {
+		switch (cmd) {
+		case SIOCGHWTSTAMP:
+			return gbe_hwtstamp_get(gbe_intf, req);
+		case SIOCSHWTSTAMP:
+			return gbe_hwtstamp_set(gbe_intf, req);
+		}
+	}
 
 	if (phy)
-		ret = phy_mii_ioctl(phy, req, cmd);
+		return phy_mii_ioctl(phy, req, cmd);
 
-	return ret;
+	return -EOPNOTSUPP;
 }
 
 static void netcp_ethss_timer(unsigned long arg)
@@ -2402,12 +2778,20 @@ static void netcp_ethss_timer(unsigned long arg)
 	add_timer(&gbe_dev->timer);
 }
 
-static int gbe_tx_hook(int order, void *data, struct netcp_packet *p_info)
+static int gbe_txhook(int order, void *data, struct netcp_packet *p_info)
 {
 	struct gbe_intf *gbe_intf = data;
 
 	p_info->tx_pipe = &gbe_intf->tx_pipe;
-	return 0;
+
+	return gbe_txtstamp_mark_pkt(gbe_intf, p_info);
+}
+
+static int gbe_rxhook(int order, void *data, struct netcp_packet *p_info)
+{
+	struct gbe_intf *gbe_intf = data;
+
+	return gbe_rxtstamp(gbe_intf, p_info);
 }
 
 static int gbe_open(void *intf_priv, struct net_device *ndev)
@@ -2457,11 +2841,14 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
 	if (ret)
 		goto fail;
 
-	netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
-			      gbe_intf);
+	netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_txhook, gbe_intf);
+	netcp_register_rxhook(netcp, GBE_RXHOOK_ORDER, gbe_rxhook, gbe_intf);
 
 	slave->open = true;
 	netcp_ethss_update_link_state(gbe_dev, slave, ndev);
+
+	gbe_register_cpts(gbe_dev);
+
 	return 0;
 
 fail:
@@ -2473,16 +2860,36 @@ static int gbe_close(void *intf_priv, struct net_device *ndev)
 {
 	struct gbe_intf *gbe_intf = intf_priv;
 	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	gbe_unregister_cpts(gbe_dev);
 
 	gbe_slave_stop(gbe_intf);
-	netcp_unregister_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
-				gbe_intf);
+
+	netcp_unregister_rxhook(netcp, GBE_RXHOOK_ORDER, gbe_rxhook, gbe_intf);
+	netcp_unregister_txhook(netcp, GBE_TXHOOK_ORDER, gbe_txhook, gbe_intf);
 
 	gbe_intf->slave->open = false;
 	atomic_set(&gbe_intf->slave->link_state, NETCP_LINK_STATE_INVALID);
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_TI_CPTS)
+static void init_slave_ts_ctl(struct gbe_slave *slave)
+{
+	slave->ts_ctl.uni = 1;
+	slave->ts_ctl.dst_port_map =
+		(TS_CTL_DST_PORT >> TS_CTL_DST_PORT_SHIFT) & 0x3;
+	slave->ts_ctl.maddr_map =
+		(TS_CTL_MADDR_ALL >> TS_CTL_MADDR_SHIFT) & 0x1f;
+}
+
+#else
+static void init_slave_ts_ctl(struct gbe_slave *slave)
+{
+}
+#endif /* CONFIG_TI_CPTS */
+
 static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 		      struct device_node *node)
 {
@@ -2597,6 +3004,8 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 	}
 
 	atomic_set(&slave->link_state, NETCP_LINK_STATE_INVALID);
+
+	init_slave_ts_ctl(slave);
 	return 0;
 }
 
@@ -2787,6 +3196,7 @@ static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
 			XGBE10_HW_STATS_OFFSET + (GBE_HW_STATS_REG_MAP_SZ * i);
 
 	gbe_dev->ale_reg = gbe_dev->switch_regs + XGBE10_ALE_OFFSET;
+	gbe_dev->cpts_reg = gbe_dev->switch_regs + XGBE10_CPTS_OFFSET;
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = XGBE10_HOST_PORT_NUM;
 	gbe_dev->ale_entries = XGBE10_NUM_ALE_ENTRIES;
@@ -2909,6 +3319,7 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 			(GBE_HW_STATS_REG_MAP_SZ * (i & 0x1));
 	}
 
+	gbe_dev->cpts_reg = gbe_dev->switch_regs + GBE13_CPTS_OFFSET;
 	gbe_dev->ale_reg = gbe_dev->switch_regs + GBE13_ALE_OFFSET;
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBE13_HOST_PORT_NUM;
@@ -2998,6 +3409,7 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 		gbe_dev->hw_stats_regs[i] = gbe_dev->switch_regs +
 			GBENU_HW_STATS_OFFSET + (GBENU_HW_STATS_REG_MAP_SZ * i);
 
+	gbe_dev->cpts_reg = gbe_dev->switch_regs + GBENU_CPTS_OFFSET;
 	gbe_dev->ale_reg = gbe_dev->switch_regs + GBENU_ALE_OFFSET;
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBENU_HOST_PORT_NUM;
@@ -3179,6 +3591,12 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		dev_dbg(gbe_dev->dev, "Created a gbe ale engine\n");
 	}
 
+	gbe_dev->cpts = cpts_create(gbe_dev->dev, gbe_dev->cpts_reg, node);
+	if (IS_ENABLED(CONFIG_TI_CPTS) && IS_ERR(gbe_dev->cpts)) {
+		ret = PTR_ERR(gbe_dev->cpts);
+		goto free_sec_ports;
+	}
+
 	/* initialize host port */
 	gbe_init_host_port(gbe_dev);
 
@@ -3267,6 +3685,7 @@ static int gbe_remove(struct netcp_device *netcp_device, void *inst_priv)
 	struct gbe_priv *gbe_dev = inst_priv;
 
 	del_timer_sync(&gbe_dev->timer);
+	cpts_release(gbe_dev->cpts);
 	cpsw_ale_stop(gbe_dev->ale);
 	cpsw_ale_destroy(gbe_dev->ale);
 	netcp_txpipe_close(&gbe_dev->tx_pipe);
-- 
2.10.1
