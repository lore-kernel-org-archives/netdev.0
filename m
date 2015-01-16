From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next v8 4/4] net: netcp: Enhance GBE driver to support 10G Ethernet
Date: Thu, 15 Jan 2015 19:12:52 -0500
Message-ID: <1421367172-19793-4-git-send-email-m-karicheri2@ti.com>
References: <1421367172-19793-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>
To: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:54432 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752750AbbAPAMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 19:12:52 -0500
In-Reply-To: <1421367172-19793-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wingman Kwok <w-kwok2@ti.com>

This patch enhances the NetCP gbe driver to support 10GbE subsystem
available in Keystone NetCP. The 3-port 10GbE switch sub-module contains
the following components:- 10GbE Switch, MDIO Module, 2 PCS-R Modules
(10GBase-R) and 2 SGMII modules (10/100/1000Base-T). The GBE driver
together with netcp core driver provides support for 10G Ethernet
on Keystone SoCs.

10GbE hardware spec is available at

http://www.ti.com/general/docs/lit/getliterature.tsp?baseLiteratureNumber=spruhj5&fileType=pdf

 Cc: David Miller <davem@davemloft.net>
 Cc: Rob Herring <robh+dt@kernel.org>
 Cc: Grant Likely <grant.likely@linaro.org>
 Cc: Santosh Shilimkar <santosh.shilimkar@kernel.org>
 Cc: Pawel Moll <pawel.moll@arm.com>
 Cc: Mark Rutland <mark.rutland@arm.com>
 Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
 Cc: Kumar Gala <galak@codeaurora.org>

Signed-off-by: Wingman Kwok <w-kwok2@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/Makefile         |    2 +-
 drivers/net/ethernet/ti/netcp_ethss.c    |  470 +++++++++++++++++++++++++++-
 drivers/net/ethernet/ti/netcp_xgbepcsr.c |  501 ++++++++++++++++++++++++++++++
 3 files changed, 958 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/netcp_xgbepcsr.c

diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 6d4dde8..465d03d 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -13,4 +13,4 @@ ti_cpsw-y := cpsw_ale.o cpsw.o cpts.o
 
 obj-$(CONFIG_TI_KEYSTONE_NETCP) += keystone_netcp.o
 keystone_netcp-y := netcp_core.o netcp_ethss.o	netcp_sgmii.o \
-			cpsw_ale.o cpts.o
+			netcp_xgbepcsr.o cpsw_ale.o cpts.o
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 58f00c5..fa1041a 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -1,5 +1,5 @@
 /*
- * Keystone GBE subsystem code
+ * Keystone GBE and XGBE subsystem code
  *
  * Copyright (C) 2014 Texas Instruments Incorporated
  * Authors:	Sandeep Nair <sandeep_n@ti.com>
@@ -53,6 +53,23 @@
 #define GBE13_NUM_ALE_PORTS		(GBE13_NUM_SLAVES + 1)
 #define GBE13_NUM_ALE_ENTRIES		1024
 
+/* 10G Ethernet SS defines */
+#define XGBE_MODULE_NAME		"netcp-xgbe"
+#define XGBE_SS_VERSION_10		0x4ee42100
+
+#define XGBE_SERDES_REG_INDEX		1
+#define XGBE10_SGMII_MODULE_OFFSET	0x100
+#define XGBE10_SWITCH_MODULE_OFFSET	0x1000
+#define XGBE10_HOST_PORT_OFFSET		0x1034
+#define XGBE10_SLAVE_PORT_OFFSET	0x1064
+#define XGBE10_EMAC_OFFSET		0x1400
+#define XGBE10_ALE_OFFSET		0x1700
+#define XGBE10_HW_STATS_OFFSET		0x1800
+#define XGBE10_HOST_PORT_NUM		0
+#define XGBE10_NUM_SLAVES		2
+#define XGBE10_NUM_ALE_PORTS		(XGBE10_NUM_SLAVES + 1)
+#define XGBE10_NUM_ALE_ENTRIES		1024
+
 #define	GBE_TIMER_INTERVAL			(HZ / 2)
 
 /* Soft reset register values */
@@ -63,12 +80,15 @@
 
 #define MACSL_RX_ENABLE_CSF			BIT(23)
 #define MACSL_ENABLE_EXT_CTL			BIT(18)
+#define MACSL_XGMII_ENABLE			BIT(13)
+#define MACSL_XGIG_MODE				BIT(8)
 #define MACSL_GIG_MODE				BIT(7)
 #define MACSL_GMII_ENABLE			BIT(5)
 #define MACSL_FULLDUPLEX			BIT(0)
 
 #define GBE_CTL_P0_ENABLE			BIT(2)
 #define GBE_REG_VAL_STAT_ENABLE_ALL		0xff
+#define XGBE_REG_VAL_STAT_ENABLE_ALL		0xf
 #define GBE_STATS_CD_SEL			BIT(28)
 
 #define GBE_PORT_MASK(x)			(BIT(x) - 1)
@@ -78,11 +98,19 @@
 		(MACSL_GIG_MODE | MACSL_GMII_ENABLE |		\
 		 MACSL_ENABLE_EXT_CTL |	MACSL_RX_ENABLE_CSF)
 
+#define GBE_DEF_10G_MAC_CONTROL				\
+		(MACSL_XGIG_MODE | MACSL_XGMII_ENABLE |		\
+		 MACSL_ENABLE_EXT_CTL |	MACSL_RX_ENABLE_CSF)
+
 #define GBE_STATSA_MODULE			0
 #define GBE_STATSB_MODULE			1
 #define GBE_STATSC_MODULE			2
 #define GBE_STATSD_MODULE			3
 
+#define XGBE_STATS0_MODULE			0
+#define XGBE_STATS1_MODULE			1
+#define XGBE_STATS2_MODULE			2
+
 #define MAX_SLAVES				GBE13_NUM_SLAVES
 /* s: 0-based slave_port */
 #define SGMII_BASE(s) \
@@ -91,12 +119,144 @@
 #define GBE_TX_QUEUE				648
 #define	GBE_TXHOOK_ORDER			0
 #define GBE_DEFAULT_ALE_AGEOUT			30
+#define SLAVE_LINK_IS_XGMII(s) ((s)->link_interface >= XGMII_LINK_MAC_PHY)
 #define NETCP_LINK_STATE_INVALID		-1
 
 #define GBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
 		offsetof(struct gbe##_##rb, rn)
+#define XGBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
+		offsetof(struct xgbe##_##rb, rn)
 #define GBE_REG_ADDR(p, rb, rn) (p->rb + p->rb##_ofs.rn)
 
+struct xgbe_ss_regs {
+	u32	id_ver;
+	u32	synce_count;
+	u32	synce_mux;
+	u32	control;
+};
+
+struct xgbe_switch_regs {
+	u32	id_ver;
+	u32	control;
+	u32	emcontrol;
+	u32	stat_port_en;
+	u32	ptype;
+	u32	soft_idle;
+	u32	thru_rate;
+	u32	gap_thresh;
+	u32	tx_start_wds;
+	u32	flow_control;
+	u32	cppi_thresh;
+};
+
+struct xgbe_port_regs {
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;
+	u32	sa_lo;
+	u32	sa_hi;
+	u32	ts_ctl;
+	u32	ts_seq_ltype;
+	u32	ts_vlan;
+	u32	ts_ctl_ltype2;
+	u32	ts_ctl2;
+	u32	control;
+};
+
+struct xgbe_host_port_regs {
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;
+	u32	src_id;
+	u32	rx_pri_map;
+	u32	rx_maxlen;
+};
+
+struct xgbe_emac_regs {
+	u32	id_ver;
+	u32	mac_control;
+	u32	mac_status;
+	u32	soft_reset;
+	u32	rx_maxlen;
+	u32	__reserved_0;
+	u32	rx_pause;
+	u32	tx_pause;
+	u32	em_control;
+	u32	__reserved_1;
+	u32	tx_gap;
+	u32	rsvd[4];
+};
+
+struct xgbe_host_hw_stats {
+	u32	rx_good_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	__rsvd_0[3];
+	u32	rx_oversized_frames;
+	u32	__rsvd_1;
+	u32	rx_undersized_frames;
+	u32	__rsvd_2;
+	u32	overrun_type4;
+	u32	overrun_type5;
+	u32	rx_bytes;
+	u32	tx_good_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	__rsvd_3[9];
+	u32	tx_bytes;
+	u32	tx_64byte_frames;
+	u32	tx_65_to_127byte_frames;
+	u32	tx_128_to_255byte_frames;
+	u32	tx_256_to_511byte_frames;
+	u32	tx_512_to_1023byte_frames;
+	u32	tx_1024byte_frames;
+	u32	net_bytes;
+	u32	rx_sof_overruns;
+	u32	rx_mof_overruns;
+	u32	rx_dma_overruns;
+};
+
+struct xgbe_hw_stats {
+	u32	rx_good_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	rx_pause_frames;
+	u32	rx_crc_errors;
+	u32	rx_align_code_errors;
+	u32	rx_oversized_frames;
+	u32	rx_jabber_frames;
+	u32	rx_undersized_frames;
+	u32	rx_fragments;
+	u32	overrun_type4;
+	u32	overrun_type5;
+	u32	rx_bytes;
+	u32	tx_good_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	tx_pause_frames;
+	u32	tx_deferred_frames;
+	u32	tx_collision_frames;
+	u32	tx_single_coll_frames;
+	u32	tx_mult_coll_frames;
+	u32	tx_excessive_collisions;
+	u32	tx_late_collisions;
+	u32	tx_underrun;
+	u32	tx_carrier_sense_errors;
+	u32	tx_bytes;
+	u32	tx_64byte_frames;
+	u32	tx_65_to_127byte_frames;
+	u32	tx_128_to_255byte_frames;
+	u32	tx_256_to_511byte_frames;
+	u32	tx_512_to_1023byte_frames;
+	u32	tx_1024byte_frames;
+	u32	net_bytes;
+	u32	rx_sof_overruns;
+	u32	rx_mof_overruns;
+	u32	rx_dma_overruns;
+};
+
+#define XGBE10_NUM_STAT_ENTRIES (sizeof(struct xgbe_hw_stats)/sizeof(u32))
+
 struct gbe_ss_regs {
 	u32	id_ver;
 	u32	synce_count;
@@ -230,6 +390,7 @@ struct gbe_hw_stats {
 
 #define GBE13_NUM_HW_STAT_ENTRIES (sizeof(struct gbe_hw_stats)/sizeof(u32))
 #define GBE13_NUM_HW_STATS_MOD			2
+#define XGBE10_NUM_HW_STATS_MOD			3
 #define GBE_MAX_HW_STAT_MODS			3
 #define GBE_HW_STATS_REG_MAP_SZ			0x100
 
@@ -303,6 +464,7 @@ struct gbe_intf {
 };
 
 static struct netcp_module gbe_module;
+static struct netcp_module xgbe_module;
 
 /* Statistic management */
 struct netcp_ethtool_stat {
@@ -471,6 +633,118 @@ static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 	{GBE_STATSD_INFO(rx_dma_overruns)},
 };
 
+#define XGBE_STATS0_INFO(field)	"GBE_0:"#field, XGBE_STATS0_MODULE, \
+				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
+				offsetof(struct xgbe_hw_stats, field)
+
+#define XGBE_STATS1_INFO(field)	"GBE_1:"#field, XGBE_STATS1_MODULE, \
+				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
+				offsetof(struct xgbe_hw_stats, field)
+
+#define XGBE_STATS2_INFO(field)	"GBE_2:"#field, XGBE_STATS2_MODULE, \
+				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
+				offsetof(struct xgbe_hw_stats, field)
+
+static const struct netcp_ethtool_stat xgbe10_et_stats[] = {
+	/* GBE module 0 */
+	{XGBE_STATS0_INFO(rx_good_frames)},
+	{XGBE_STATS0_INFO(rx_broadcast_frames)},
+	{XGBE_STATS0_INFO(rx_multicast_frames)},
+	{XGBE_STATS0_INFO(rx_oversized_frames)},
+	{XGBE_STATS0_INFO(rx_undersized_frames)},
+	{XGBE_STATS0_INFO(overrun_type4)},
+	{XGBE_STATS0_INFO(overrun_type5)},
+	{XGBE_STATS0_INFO(rx_bytes)},
+	{XGBE_STATS0_INFO(tx_good_frames)},
+	{XGBE_STATS0_INFO(tx_broadcast_frames)},
+	{XGBE_STATS0_INFO(tx_multicast_frames)},
+	{XGBE_STATS0_INFO(tx_bytes)},
+	{XGBE_STATS0_INFO(tx_64byte_frames)},
+	{XGBE_STATS0_INFO(tx_65_to_127byte_frames)},
+	{XGBE_STATS0_INFO(tx_128_to_255byte_frames)},
+	{XGBE_STATS0_INFO(tx_256_to_511byte_frames)},
+	{XGBE_STATS0_INFO(tx_512_to_1023byte_frames)},
+	{XGBE_STATS0_INFO(tx_1024byte_frames)},
+	{XGBE_STATS0_INFO(net_bytes)},
+	{XGBE_STATS0_INFO(rx_sof_overruns)},
+	{XGBE_STATS0_INFO(rx_mof_overruns)},
+	{XGBE_STATS0_INFO(rx_dma_overruns)},
+	/* XGBE module 1 */
+	{XGBE_STATS1_INFO(rx_good_frames)},
+	{XGBE_STATS1_INFO(rx_broadcast_frames)},
+	{XGBE_STATS1_INFO(rx_multicast_frames)},
+	{XGBE_STATS1_INFO(rx_pause_frames)},
+	{XGBE_STATS1_INFO(rx_crc_errors)},
+	{XGBE_STATS1_INFO(rx_align_code_errors)},
+	{XGBE_STATS1_INFO(rx_oversized_frames)},
+	{XGBE_STATS1_INFO(rx_jabber_frames)},
+	{XGBE_STATS1_INFO(rx_undersized_frames)},
+	{XGBE_STATS1_INFO(rx_fragments)},
+	{XGBE_STATS1_INFO(overrun_type4)},
+	{XGBE_STATS1_INFO(overrun_type5)},
+	{XGBE_STATS1_INFO(rx_bytes)},
+	{XGBE_STATS1_INFO(tx_good_frames)},
+	{XGBE_STATS1_INFO(tx_broadcast_frames)},
+	{XGBE_STATS1_INFO(tx_multicast_frames)},
+	{XGBE_STATS1_INFO(tx_pause_frames)},
+	{XGBE_STATS1_INFO(tx_deferred_frames)},
+	{XGBE_STATS1_INFO(tx_collision_frames)},
+	{XGBE_STATS1_INFO(tx_single_coll_frames)},
+	{XGBE_STATS1_INFO(tx_mult_coll_frames)},
+	{XGBE_STATS1_INFO(tx_excessive_collisions)},
+	{XGBE_STATS1_INFO(tx_late_collisions)},
+	{XGBE_STATS1_INFO(tx_underrun)},
+	{XGBE_STATS1_INFO(tx_carrier_sense_errors)},
+	{XGBE_STATS1_INFO(tx_bytes)},
+	{XGBE_STATS1_INFO(tx_64byte_frames)},
+	{XGBE_STATS1_INFO(tx_65_to_127byte_frames)},
+	{XGBE_STATS1_INFO(tx_128_to_255byte_frames)},
+	{XGBE_STATS1_INFO(tx_256_to_511byte_frames)},
+	{XGBE_STATS1_INFO(tx_512_to_1023byte_frames)},
+	{XGBE_STATS1_INFO(tx_1024byte_frames)},
+	{XGBE_STATS1_INFO(net_bytes)},
+	{XGBE_STATS1_INFO(rx_sof_overruns)},
+	{XGBE_STATS1_INFO(rx_mof_overruns)},
+	{XGBE_STATS1_INFO(rx_dma_overruns)},
+	/* XGBE module 2 */
+	{XGBE_STATS2_INFO(rx_good_frames)},
+	{XGBE_STATS2_INFO(rx_broadcast_frames)},
+	{XGBE_STATS2_INFO(rx_multicast_frames)},
+	{XGBE_STATS2_INFO(rx_pause_frames)},
+	{XGBE_STATS2_INFO(rx_crc_errors)},
+	{XGBE_STATS2_INFO(rx_align_code_errors)},
+	{XGBE_STATS2_INFO(rx_oversized_frames)},
+	{XGBE_STATS2_INFO(rx_jabber_frames)},
+	{XGBE_STATS2_INFO(rx_undersized_frames)},
+	{XGBE_STATS2_INFO(rx_fragments)},
+	{XGBE_STATS2_INFO(overrun_type4)},
+	{XGBE_STATS2_INFO(overrun_type5)},
+	{XGBE_STATS2_INFO(rx_bytes)},
+	{XGBE_STATS2_INFO(tx_good_frames)},
+	{XGBE_STATS2_INFO(tx_broadcast_frames)},
+	{XGBE_STATS2_INFO(tx_multicast_frames)},
+	{XGBE_STATS2_INFO(tx_pause_frames)},
+	{XGBE_STATS2_INFO(tx_deferred_frames)},
+	{XGBE_STATS2_INFO(tx_collision_frames)},
+	{XGBE_STATS2_INFO(tx_single_coll_frames)},
+	{XGBE_STATS2_INFO(tx_mult_coll_frames)},
+	{XGBE_STATS2_INFO(tx_excessive_collisions)},
+	{XGBE_STATS2_INFO(tx_late_collisions)},
+	{XGBE_STATS2_INFO(tx_underrun)},
+	{XGBE_STATS2_INFO(tx_carrier_sense_errors)},
+	{XGBE_STATS2_INFO(tx_bytes)},
+	{XGBE_STATS2_INFO(tx_64byte_frames)},
+	{XGBE_STATS2_INFO(tx_65_to_127byte_frames)},
+	{XGBE_STATS2_INFO(tx_128_to_255byte_frames)},
+	{XGBE_STATS2_INFO(tx_256_to_511byte_frames)},
+	{XGBE_STATS2_INFO(tx_512_to_1023byte_frames)},
+	{XGBE_STATS2_INFO(tx_1024byte_frames)},
+	{XGBE_STATS2_INFO(net_bytes)},
+	{XGBE_STATS2_INFO(rx_sof_overruns)},
+	{XGBE_STATS2_INFO(rx_mof_overruns)},
+	{XGBE_STATS2_INFO(rx_dma_overruns)},
+};
+
 #define for_each_intf(i, priv) \
 	list_for_each_entry((i), &(priv)->gbe_intf_head, gbe_intf_list)
 
@@ -631,7 +905,10 @@ static void keystone_get_ethtool_stats(struct net_device *ndev,
 
 	gbe_dev = gbe_intf->gbe_dev;
 	spin_lock_bh(&gbe_dev->hw_stats_lock);
-	gbe_update_stats_ver14(gbe_dev, data);
+	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+		gbe_update_stats_ver14(gbe_dev, data);
+	else
+		gbe_update_stats(gbe_dev, data);
 	spin_unlock_bh(&gbe_dev->hw_stats_lock);
 }
 
@@ -742,8 +1019,13 @@ static void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
 
 	if (up) {
 		mac_control = slave->mac_control;
-		if (phy && (phy->speed == SPEED_1000))
+		if (phy && (phy->speed == SPEED_1000)) {
 			mac_control |= MACSL_GIG_MODE;
+			mac_control &= ~MACSL_XGIG_MODE;
+		} else if (phy && (phy->speed == SPEED_10000)) {
+			mac_control |= MACSL_XGIG_MODE;
+			mac_control &= ~MACSL_GIG_MODE;
+		}
 
 		writel(mac_control, GBE_REG_ADDR(slave, emac_regs,
 						 mac_control));
@@ -783,7 +1065,9 @@ static void netcp_ethss_update_link_state(struct gbe_priv *gbe_dev,
 	if (!slave->open)
 		return;
 
-	sgmii_link_state = netcp_sgmii_get_port_link(SGMII_BASE(sp), sp);
+	if (!SLAVE_LINK_IS_XGMII(slave))
+		sgmii_link_state = netcp_sgmii_get_port_link(SGMII_BASE(sp),
+							     sp);
 	phy_link_state = gbe_phy_link_status(slave);
 	link_state = phy_link_state & sgmii_link_state;
 
@@ -792,6 +1076,19 @@ static void netcp_ethss_update_link_state(struct gbe_priv *gbe_dev,
 					      link_state);
 }
 
+static void xgbe_adjust_link(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+
+	gbe_intf = netcp_module_get_intf_data(&xgbe_module, netcp);
+	if (!gbe_intf)
+		return;
+
+	netcp_ethss_update_link_state(gbe_intf->gbe_dev, gbe_intf->slave,
+				      ndev);
+}
+
 static void gbe_adjust_link(struct net_device *ndev)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
@@ -839,9 +1136,19 @@ static int gbe_port_reset(struct gbe_slave *slave)
 static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 			    int max_rx_len)
 {
+	u32 xgmii_mode;
+
 	if (max_rx_len > NETCP_MAX_FRAME_SIZE)
 		max_rx_len = NETCP_MAX_FRAME_SIZE;
 
+	/* Enable correct MII mode at SS level */
+	if ((gbe_dev->ss_version == XGBE_SS_VERSION_10) &&
+	    (slave->link_interface >= XGMII_LINK_MAC_PHY)) {
+		xgmii_mode = readl(GBE_REG_ADDR(gbe_dev, ss_regs, control));
+		xgmii_mode |= (1 << slave->slave_num);
+		writel(xgmii_mode, GBE_REG_ADDR(gbe_dev, ss_regs, control));
+	}
+
 	writel(max_rx_len, GBE_REG_ADDR(slave, emac_regs, rx_maxlen));
 	writel(slave->mac_control, GBE_REG_ADDR(slave, emac_regs, mac_control));
 }
@@ -874,9 +1181,11 @@ static void gbe_sgmii_config(struct gbe_priv *priv, struct gbe_slave *slave)
 	if ((priv->ss_version == GBE_SS_VERSION_14) && (slave->slave_num >= 2))
 		sgmii_port_regs = priv->sgmii_port34_regs;
 
-	netcp_sgmii_reset(sgmii_port_regs, slave->slave_num);
-	netcp_sgmii_config(sgmii_port_regs, slave->slave_num,
-			   slave->link_interface);
+	if (!SLAVE_LINK_IS_XGMII(slave)) {
+		netcp_sgmii_reset(sgmii_port_regs, slave->slave_num);
+		netcp_sgmii_config(sgmii_port_regs, slave->slave_num,
+				   slave->link_interface);
+	}
 }
 
 static int gbe_slave_open(struct gbe_intf *gbe_intf)
@@ -909,6 +1218,9 @@ static int gbe_slave_open(struct gbe_intf *gbe_intf)
 	}
 
 	if (has_phy) {
+		if (priv->ss_version == XGBE_SS_VERSION_10)
+			hndlr = xgbe_adjust_link;
+
 		slave->phy = of_phy_connect(gbe_intf->ndev,
 					    slave->phy_node,
 					    hndlr, 0,
@@ -1233,7 +1545,10 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 	slave->phy_node = of_parse_phandle(node, "phy-handle", 0);
 	slave->port_num = gbe_get_slave_port(gbe_dev, slave->slave_num);
 
-	slave->mac_control = GBE_DEF_1G_MAC_CONTROL;
+	if (slave->link_interface >= XGMII_LINK_MAC_PHY)
+		slave->mac_control = GBE_DEF_10G_MAC_CONTROL;
+	else
+		slave->mac_control = GBE_DEF_1G_MAC_CONTROL;
 
 	/* Emac regs memmap are contiguous but port regs are not */
 	port_reg_num = slave->slave_num;
@@ -1244,6 +1559,8 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 		} else {
 			port_reg_ofs = GBE13_SLAVE_PORT_OFFSET;
 		}
+	} else if (gbe_dev->ss_version == XGBE_SS_VERSION_10) {
+		port_reg_ofs = XGBE10_SLAVE_PORT_OFFSET;
 	} else {
 		dev_err(gbe_dev->dev, "unknown ethss(0x%x)\n",
 			gbe_dev->ss_version);
@@ -1252,6 +1569,8 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 
 	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
 		emac_reg_ofs = GBE13_EMAC_OFFSET;
+	else if (gbe_dev->ss_version == XGBE_SS_VERSION_10)
+		emac_reg_ofs = XGBE10_EMAC_OFFSET;
 
 	slave->port_regs = gbe_dev->ss_regs + port_reg_ofs +
 				(0x30 * port_reg_num);
@@ -1275,10 +1594,22 @@ static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 		GBE_SET_REG_OFS(slave, emac_regs, soft_reset);
 		GBE_SET_REG_OFS(slave, emac_regs, rx_maxlen);
 
-	} else {
-		dev_err(gbe_dev->dev, "unknown ethss(0x%x)\n",
-			gbe_dev->ss_version);
-		return -EINVAL;
+	} else if (gbe_dev->ss_version == XGBE_SS_VERSION_10) {
+		/* Initialize  slave port register offsets */
+		XGBE_SET_REG_OFS(slave, port_regs, port_vlan);
+		XGBE_SET_REG_OFS(slave, port_regs, tx_pri_map);
+		XGBE_SET_REG_OFS(slave, port_regs, sa_lo);
+		XGBE_SET_REG_OFS(slave, port_regs, sa_hi);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_ctl);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_seq_ltype);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_vlan);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_ctl_ltype2);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_ctl2);
+
+		/* Initialize EMAC register offsets */
+		XGBE_SET_REG_OFS(slave, emac_regs, mac_control);
+		XGBE_SET_REG_OFS(slave, emac_regs, soft_reset);
+		XGBE_SET_REG_OFS(slave, emac_regs, rx_maxlen);
 	}
 
 	atomic_set(&slave->link_state, NETCP_LINK_STATE_INVALID);
@@ -1317,7 +1648,8 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 		gbe_port_config(gbe_dev, slave, gbe_dev->rx_packet_max);
 		list_add_tail(&slave->slave_list, &gbe_dev->secondary_slaves);
 		gbe_dev->num_slaves++;
-		if (slave->link_interface == SGMII_LINK_MAC_PHY)
+		if ((slave->link_interface == SGMII_LINK_MAC_PHY) ||
+		    (slave->link_interface == XGMII_LINK_MAC_PHY))
 			mac_phy_link = true;
 
 		slave->open = true;
@@ -1347,7 +1679,8 @@ static void init_secondary_ports(struct gbe_priv *gbe_dev,
 	}
 
 	for_each_sec_slave(slave, gbe_dev) {
-		if (slave->link_interface != SGMII_LINK_MAC_PHY)
+		if ((slave->link_interface != SGMII_LINK_MAC_PHY) &&
+		    (slave->link_interface != XGMII_LINK_MAC_PHY))
 			continue;
 		slave->phy =
 			of_phy_connect(gbe_dev->dummy_ndev,
@@ -1383,6 +1716,85 @@ static void free_secondary_ports(struct gbe_priv *gbe_dev)
 		free_netdev(gbe_dev->dummy_ndev);
 }
 
+static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
+				 struct device_node *node)
+{
+	struct resource res;
+	void __iomem *regs;
+	int ret, i;
+
+	ret = of_address_to_resource(node, 0, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev, "Can't translate of node(%s) address for xgbe subsystem regs\n",
+			node->name);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev, "Failed to map xgbe register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->ss_regs = regs;
+
+	ret = of_address_to_resource(node, XGBE_SERDES_REG_INDEX, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev, "Can't translate of node(%s) address for xgbe serdes regs\n",
+			node->name);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev, "Failed to map xgbe serdes register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->xgbe_serdes_regs = regs;
+
+	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
+					  XGBE10_NUM_STAT_ENTRIES *
+					  (XGBE10_NUM_SLAVES + 1) * sizeof(u64),
+					  GFP_KERNEL);
+	if (!gbe_dev->hw_stats) {
+		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
+		return -ENOMEM;
+	}
+
+	gbe_dev->ss_version = XGBE_SS_VERSION_10;
+	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs +
+					XGBE10_SGMII_MODULE_OFFSET;
+	gbe_dev->switch_regs = gbe_dev->ss_regs + XGBE10_SWITCH_MODULE_OFFSET;
+	gbe_dev->host_port_regs = gbe_dev->ss_regs + XGBE10_HOST_PORT_OFFSET;
+
+	for (i = 0; i < XGBE10_NUM_HW_STATS_MOD; i++)
+		gbe_dev->hw_stats_regs[i] = gbe_dev->ss_regs +
+			XGBE10_HW_STATS_OFFSET + (GBE_HW_STATS_REG_MAP_SZ * i);
+
+	gbe_dev->ale_reg = gbe_dev->ss_regs + XGBE10_ALE_OFFSET;
+	gbe_dev->ale_ports = XGBE10_NUM_ALE_PORTS;
+	gbe_dev->host_port = XGBE10_HOST_PORT_NUM;
+	gbe_dev->ale_entries = XGBE10_NUM_ALE_ENTRIES;
+	gbe_dev->et_stats = xgbe10_et_stats;
+	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
+
+	/* Subsystem registers */
+	XGBE_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
+	XGBE_SET_REG_OFS(gbe_dev, ss_regs, control);
+
+	/* Switch module registers */
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, id_ver);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, control);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, ptype);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, stat_port_en);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, flow_control);
+
+	/* Host port registers */
+	XGBE_SET_REG_OFS(gbe_dev, host_port_regs, port_vlan);
+	XGBE_SET_REG_OFS(gbe_dev, host_port_regs, tx_pri_map);
+	XGBE_SET_REG_OFS(gbe_dev, host_port_regs, rx_maxlen);
+	return 0;
+}
+
 static int get_gbe_resource_version(struct gbe_priv *gbe_dev,
 				    struct device_node *node)
 {
@@ -1513,6 +1925,14 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		ret = set_gbe_ethss14_priv(gbe_dev, node);
 		if (ret)
 			goto quit;
+	} else if (!strcmp(node->name, "xgbe")) {
+		ret = set_xgbe_ethss10_priv(gbe_dev, node);
+		if (ret)
+			goto quit;
+		ret = netcp_xgbe_serdes_init(gbe_dev->xgbe_serdes_regs,
+					     gbe_dev->ss_regs);
+		if (ret)
+			goto quit;
 	} else {
 		dev_err(dev, "unknown GBE node(%s)\n", node->name);
 		ret = -ENODEV;
@@ -1695,6 +2115,23 @@ static struct netcp_module gbe_module = {
 	.ioctl		= gbe_ioctl,
 };
 
+static struct netcp_module xgbe_module = {
+	.name		= XGBE_MODULE_NAME,
+	.owner		= THIS_MODULE,
+	.primary	= true,
+	.probe		= gbe_probe,
+	.open		= gbe_open,
+	.close		= gbe_close,
+	.remove		= gbe_remove,
+	.attach		= gbe_attach,
+	.release	= gbe_release,
+	.add_addr	= gbe_add_addr,
+	.del_addr	= gbe_del_addr,
+	.add_vid	= gbe_add_vid,
+	.del_vid	= gbe_del_vid,
+	.ioctl		= gbe_ioctl,
+};
+
 static int __init keystone_gbe_init(void)
 {
 	int ret;
@@ -1703,6 +2140,10 @@ static int __init keystone_gbe_init(void)
 	if (ret)
 		return ret;
 
+	ret = netcp_register_module(&xgbe_module);
+	if (ret)
+		return ret;
+
 	return 0;
 }
 module_init(keystone_gbe_init);
@@ -1710,5 +2151,6 @@ module_init(keystone_gbe_init);
 static void __exit keystone_gbe_exit(void)
 {
 	netcp_unregister_module(&gbe_module);
+	netcp_unregister_module(&xgbe_module);
 }
 module_exit(keystone_gbe_exit);
diff --git a/drivers/net/ethernet/ti/netcp_xgbepcsr.c b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
new file mode 100644
index 0000000..33571ac
--- /dev/null
+++ b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
@@ -0,0 +1,501 @@
+/*
+ * XGE PCSR module initialisation
+ *
+ * Copyright (C) 2014 Texas Instruments Incorporated
+ * Authors:	Sandeep Nair <sandeep_n@ti.com>
+ *		WingMan Kwok <w-kwok2@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include "netcp.h"
+
+/* XGBE registers */
+#define XGBE_CTRL_OFFSET		0x0c
+#define XGBE_SGMII_1_OFFSET		0x0114
+#define XGBE_SGMII_2_OFFSET		0x0214
+
+/* PCS-R registers */
+#define PCSR_CPU_CTRL_OFFSET		0x1fd0
+#define POR_EN				BIT(29)
+
+#define reg_rmw(addr, value, mask) \
+	writel(((readl(addr) & (~(mask))) | \
+			(value & (mask))), (addr))
+
+/* bit mask of width w at offset s */
+#define MASK_WID_SH(w, s)		(((1 << w) - 1) << s)
+
+/* shift value v to offset s */
+#define VAL_SH(v, s)			(v << s)
+
+#define PHY_A(serdes)			0
+
+struct serdes_cfg {
+	u32 ofs;
+	u32 val;
+	u32 mask;
+};
+
+static struct serdes_cfg cfg_phyb_1p25g_156p25mhz_cmu0[] = {
+	{0x0000, 0x00800002, 0x00ff00ff},
+	{0x0014, 0x00003838, 0x0000ffff},
+	{0x0060, 0x1c44e438, 0xffffffff},
+	{0x0064, 0x00c18400, 0x00ffffff},
+	{0x0068, 0x17078200, 0xffffff00},
+	{0x006c, 0x00000014, 0x000000ff},
+	{0x0078, 0x0000c000, 0x0000ff00},
+	{0x0000, 0x00000003, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_phyb_10p3125g_156p25mhz_cmu1[] = {
+	{0x0c00, 0x00030002, 0x00ff00ff},
+	{0x0c14, 0x00005252, 0x0000ffff},
+	{0x0c28, 0x80000000, 0xff000000},
+	{0x0c2c, 0x000000f6, 0x000000ff},
+	{0x0c3c, 0x04000405, 0xff00ffff},
+	{0x0c40, 0xc0800000, 0xffff0000},
+	{0x0c44, 0x5a202062, 0xffffffff},
+	{0x0c48, 0x40040424, 0xffffffff},
+	{0x0c4c, 0x00004002, 0x0000ffff},
+	{0x0c50, 0x19001c00, 0xff00ff00},
+	{0x0c54, 0x00002100, 0x0000ff00},
+	{0x0c58, 0x00000060, 0x000000ff},
+	{0x0c60, 0x80131e7c, 0xffffffff},
+	{0x0c64, 0x8400cb02, 0xff00ffff},
+	{0x0c68, 0x17078200, 0xffffff00},
+	{0x0c6c, 0x00000016, 0x000000ff},
+	{0x0c74, 0x00000400, 0x0000ff00},
+	{0x0c78, 0x0000c000, 0x0000ff00},
+	{0x0c00, 0x00000003, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_phyb_10p3125g_16bit_lane[] = {
+	{0x0204, 0x00000080, 0x000000ff},
+	{0x0208, 0x0000920d, 0x0000ffff},
+	{0x0204, 0xfc000000, 0xff000000},
+	{0x0208, 0x00009104, 0x0000ffff},
+	{0x0210, 0x1a000000, 0xff000000},
+	{0x0214, 0x00006b58, 0x00ffffff},
+	{0x0218, 0x75800084, 0xffff00ff},
+	{0x022c, 0x00300000, 0x00ff0000},
+	{0x0230, 0x00003800, 0x0000ff00},
+	{0x024c, 0x008f0000, 0x00ff0000},
+	{0x0250, 0x30000000, 0xff000000},
+	{0x0260, 0x00000002, 0x000000ff},
+	{0x0264, 0x00000057, 0x000000ff},
+	{0x0268, 0x00575700, 0x00ffff00},
+	{0x0278, 0xff000000, 0xff000000},
+	{0x0280, 0x00500050, 0x00ff00ff},
+	{0x0284, 0x00001f15, 0x0000ffff},
+	{0x028c, 0x00006f00, 0x0000ff00},
+	{0x0294, 0x00000000, 0xffffff00},
+	{0x0298, 0x00002640, 0xff00ffff},
+	{0x029c, 0x00000003, 0x000000ff},
+	{0x02a4, 0x00000f13, 0x0000ffff},
+	{0x02a8, 0x0001b600, 0x00ffff00},
+	{0x0380, 0x00000030, 0x000000ff},
+	{0x03c0, 0x00000200, 0x0000ff00},
+	{0x03cc, 0x00000018, 0x000000ff},
+	{0x03cc, 0x00000000, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_phyb_10p3125g_comlane[] = {
+	{0x0a00, 0x00000800, 0x0000ff00},
+	{0x0a84, 0x00000000, 0x000000ff},
+	{0x0a8c, 0x00130000, 0x00ff0000},
+	{0x0a90, 0x77a00000, 0xffff0000},
+	{0x0a94, 0x00007777, 0x0000ffff},
+	{0x0b08, 0x000f0000, 0xffff0000},
+	{0x0b0c, 0x000f0000, 0x00ffffff},
+	{0x0b10, 0xbe000000, 0xff000000},
+	{0x0b14, 0x000000ff, 0x000000ff},
+	{0x0b18, 0x00000014, 0x000000ff},
+	{0x0b5c, 0x981b0000, 0xffff0000},
+	{0x0b64, 0x00001100, 0x0000ff00},
+	{0x0b78, 0x00000c00, 0x0000ff00},
+	{0x0abc, 0xff000000, 0xff000000},
+	{0x0ac0, 0x0000008b, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_cm_c1_c2[] = {
+	{0x0208, 0x00000000, 0x00000f00},
+	{0x0208, 0x00000000, 0x0000001f},
+	{0x0204, 0x00000000, 0x00040000},
+	{0x0208, 0x000000a0, 0x000000e0},
+};
+
+static void netcp_xgbe_serdes_cmu_init(void __iomem *serdes_regs)
+{
+	int i;
+
+	/* cmu0 setup */
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_1p25g_156p25mhz_cmu0); i++) {
+		reg_rmw(serdes_regs + cfg_phyb_1p25g_156p25mhz_cmu0[i].ofs,
+			cfg_phyb_1p25g_156p25mhz_cmu0[i].val,
+			cfg_phyb_1p25g_156p25mhz_cmu0[i].mask);
+	}
+
+	/* cmu1 setup */
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_10p3125g_156p25mhz_cmu1); i++) {
+		reg_rmw(serdes_regs + cfg_phyb_10p3125g_156p25mhz_cmu1[i].ofs,
+			cfg_phyb_10p3125g_156p25mhz_cmu1[i].val,
+			cfg_phyb_10p3125g_156p25mhz_cmu1[i].mask);
+	}
+}
+
+/* lane is 0 based */
+static void netcp_xgbe_serdes_lane_config(
+			void __iomem *serdes_regs, int lane)
+{
+	int i;
+
+	/* lane setup */
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_10p3125g_16bit_lane); i++) {
+		reg_rmw(serdes_regs +
+				cfg_phyb_10p3125g_16bit_lane[i].ofs +
+				(0x200 * lane),
+			cfg_phyb_10p3125g_16bit_lane[i].val,
+			cfg_phyb_10p3125g_16bit_lane[i].mask);
+	}
+
+	/* disable auto negotiation*/
+	reg_rmw(serdes_regs + (0x200 * lane) + 0x0380,
+		0x00000000, 0x00000010);
+
+	/* disable link training */
+	reg_rmw(serdes_regs + (0x200 * lane) + 0x03c0,
+		0x00000000, 0x00000200);
+}
+
+static void netcp_xgbe_serdes_com_enable(void __iomem *serdes_regs)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_10p3125g_comlane); i++) {
+		reg_rmw(serdes_regs + cfg_phyb_10p3125g_comlane[i].ofs,
+			cfg_phyb_10p3125g_comlane[i].val,
+			cfg_phyb_10p3125g_comlane[i].mask);
+	}
+}
+
+static void netcp_xgbe_serdes_lane_enable(
+			void __iomem *serdes_regs, int lane)
+{
+	/* Set Lane Control Rate */
+	writel(0xe0e9e038, serdes_regs + 0x1fe0 + (4 * lane));
+}
+
+static void netcp_xgbe_serdes_phyb_rst_clr(void __iomem *serdes_regs)
+{
+	reg_rmw(serdes_regs + 0x0a00, 0x0000001f, 0x000000ff);
+}
+
+static void netcp_xgbe_serdes_pll_disable(void __iomem *serdes_regs)
+{
+	writel(0x88000000, serdes_regs + 0x1ff4);
+}
+
+static void netcp_xgbe_serdes_pll_enable(void __iomem *serdes_regs)
+{
+	netcp_xgbe_serdes_phyb_rst_clr(serdes_regs);
+	writel(0xee000000, serdes_regs + 0x1ff4);
+}
+
+static int netcp_xgbe_wait_pll_locked(void __iomem *sw_regs)
+{
+	unsigned long timeout;
+	int ret = 0;
+	u32 val_1, val_0;
+
+	timeout = jiffies + msecs_to_jiffies(500);
+	do {
+		val_0 = (readl(sw_regs + XGBE_SGMII_1_OFFSET) & BIT(4));
+		val_1 = (readl(sw_regs + XGBE_SGMII_2_OFFSET) & BIT(4));
+
+		if (val_1 && val_0)
+			return 0;
+
+		if (time_after(jiffies, timeout)) {
+			ret = -ETIMEDOUT;
+			break;
+		}
+
+		cpu_relax();
+	} while (true);
+
+	pr_err("XGBE serdes not locked: time out.\n");
+	return ret;
+}
+
+static void netcp_xgbe_serdes_enable_xgmii_port(void __iomem *sw_regs)
+{
+	writel(0x03, sw_regs + XGBE_CTRL_OFFSET);
+}
+
+static u32 netcp_xgbe_serdes_read_tbus_val(void __iomem *serdes_regs)
+{
+	u32 tmp;
+
+	if (PHY_A(serdes_regs)) {
+		tmp  = (readl(serdes_regs + 0x0ec) >> 24) & 0x0ff;
+		tmp |= ((readl(serdes_regs + 0x0fc) >> 16) & 0x00f00);
+	} else {
+		tmp  = (readl(serdes_regs + 0x0f8) >> 16) & 0x0fff;
+	}
+
+	return tmp;
+}
+
+static void netcp_xgbe_serdes_write_tbus_addr(void __iomem *serdes_regs,
+					      int select, int ofs)
+{
+	if (PHY_A(serdes_regs)) {
+		reg_rmw(serdes_regs + 0x0008, ((select << 5) + ofs) << 24,
+			~0x00ffffff);
+		return;
+	}
+
+	/* For 2 lane Phy-B, lane0 is actually lane1 */
+	switch (select) {
+	case 1:
+		select = 2;
+		break;
+	case 2:
+		select = 3;
+		break;
+	default:
+		return;
+	}
+
+	reg_rmw(serdes_regs + 0x00fc, ((select << 8) + ofs) << 16, ~0xf800ffff);
+}
+
+static u32 netcp_xgbe_serdes_read_select_tbus(void __iomem *serdes_regs,
+					      int select, int ofs)
+{
+	/* Set tbus address */
+	netcp_xgbe_serdes_write_tbus_addr(serdes_regs, select, ofs);
+	/* Get TBUS Value */
+	return netcp_xgbe_serdes_read_tbus_val(serdes_regs);
+}
+
+static void netcp_xgbe_serdes_reset_cdr(void __iomem *serdes_regs,
+					void __iomem *sig_detect_reg, int lane)
+{
+	u32 tmp, dlpf, tbus;
+
+	/*Get the DLPF values */
+	tmp = netcp_xgbe_serdes_read_select_tbus(
+			serdes_regs, lane + 1, 5);
+
+	dlpf = tmp >> 2;
+
+	if (dlpf < 400 || dlpf > 700) {
+		reg_rmw(sig_detect_reg, VAL_SH(2, 1), MASK_WID_SH(2, 1));
+		mdelay(1);
+		reg_rmw(sig_detect_reg, VAL_SH(0, 1), MASK_WID_SH(2, 1));
+	} else {
+		tbus = netcp_xgbe_serdes_read_select_tbus(serdes_regs, lane +
+							  1, 0xe);
+
+		pr_debug("XGBE: CDR centered, DLPF: %4d,%d,%d.\n",
+			 tmp >> 2, tmp & 3, (tbus >> 2) & 3);
+	}
+}
+
+/* Call every 100 ms */
+static int netcp_xgbe_check_link_status(void __iomem *serdes_regs,
+					void __iomem *sw_regs, u32 lanes,
+					u32 *current_state, u32 *lane_down)
+{
+	void __iomem *pcsr_base = sw_regs + 0x0600;
+	void __iomem *sig_detect_reg;
+	u32 pcsr_rx_stat, blk_lock, blk_errs;
+	int loss, i, status = 1;
+
+	for (i = 0; i < lanes; i++) {
+		/* Get the Loss bit */
+		loss = readl(serdes_regs + 0x1fc0 + 0x20 + (i * 0x04)) & 0x1;
+
+		/* Get Block Errors and Block Lock bits */
+		pcsr_rx_stat = readl(pcsr_base + 0x0c + (i * 0x80));
+		blk_lock = (pcsr_rx_stat >> 30) & 0x1;
+		blk_errs = (pcsr_rx_stat >> 16) & 0x0ff;
+
+		/* Get Signal Detect Overlay Address */
+		sig_detect_reg = serdes_regs + (i * 0x200) + 0x200 + 0x04;
+
+		/* If Block errors maxed out, attempt recovery! */
+		if (blk_errs == 0x0ff)
+			blk_lock = 0;
+
+		switch (current_state[i]) {
+		case 0:
+			/* if good link lock the signal detect ON! */
+			if (!loss && blk_lock) {
+				pr_debug("XGBE PCSR Linked Lane: %d\n", i);
+				reg_rmw(sig_detect_reg, VAL_SH(3, 1),
+					MASK_WID_SH(2, 1));
+				current_state[i] = 1;
+			} else if (!blk_lock) {
+				/* if no lock, then reset CDR */
+				pr_debug("XGBE PCSR Recover Lane: %d\n", i);
+				netcp_xgbe_serdes_reset_cdr(serdes_regs,
+							    sig_detect_reg, i);
+			}
+			break;
+
+		case 1:
+			if (!blk_lock) {
+				/* Link Lost? */
+				lane_down[i] = 1;
+				current_state[i] = 2;
+			}
+			break;
+
+		case 2:
+			if (blk_lock)
+				/* Nope just noise */
+				current_state[i] = 1;
+			else {
+				/* Lost the block lock, reset CDR if it is
+				 * not centered and go back to sync state
+				 */
+				netcp_xgbe_serdes_reset_cdr(serdes_regs,
+							    sig_detect_reg, i);
+				current_state[i] = 0;
+			}
+			break;
+
+		default:
+			pr_err("XGBE: unknown current_state[%d] %d\n",
+			       i, current_state[i]);
+			break;
+		}
+
+		if (blk_errs > 0) {
+			/* Reset the Error counts! */
+			reg_rmw(pcsr_base + 0x08 + (i * 0x80), VAL_SH(0x19, 0),
+				MASK_WID_SH(8, 0));
+
+			reg_rmw(pcsr_base + 0x08 + (i * 0x80), VAL_SH(0x00, 0),
+				MASK_WID_SH(8, 0));
+		}
+
+		status &= (current_state[i] == 1);
+	}
+
+	return status;
+}
+
+static int netcp_xgbe_serdes_check_lane(void __iomem *serdes_regs,
+					void __iomem *sw_regs)
+{
+	u32 current_state[2] = {0, 0};
+	int retries = 0, link_up;
+	u32 lane_down[2];
+
+	do {
+		lane_down[0] = 0;
+		lane_down[1] = 0;
+
+		link_up = netcp_xgbe_check_link_status(serdes_regs, sw_regs, 2,
+						       current_state,
+						       lane_down);
+
+		/* if we did not get link up then wait 100ms before calling
+		 * it again
+		 */
+		if (link_up)
+			break;
+
+		if (lane_down[0])
+			pr_debug("XGBE: detected link down on lane 0\n");
+
+		if (lane_down[1])
+			pr_debug("XGBE: detected link down on lane 1\n");
+
+		if (++retries > 1) {
+			pr_debug("XGBE: timeout waiting for serdes link up\n");
+			return -ETIMEDOUT;
+		}
+		mdelay(100);
+	} while (!link_up);
+
+	pr_debug("XGBE: PCSR link is up\n");
+	return 0;
+}
+
+static void netcp_xgbe_serdes_setup_cm_c1_c2(void __iomem *serdes_regs,
+					     int lane, int cm, int c1, int c2)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(cfg_cm_c1_c2); i++) {
+		reg_rmw(serdes_regs + cfg_cm_c1_c2[i].ofs + (0x200 * lane),
+			cfg_cm_c1_c2[i].val,
+			cfg_cm_c1_c2[i].mask);
+	}
+}
+
+static void netcp_xgbe_reset_serdes(void __iomem *serdes_regs)
+{
+	/* Toggle the POR_EN bit in CONFIG.CPU_CTRL */
+	/* enable POR_EN bit */
+	reg_rmw(serdes_regs + PCSR_CPU_CTRL_OFFSET, POR_EN, POR_EN);
+	usleep_range(10, 100);
+
+	/* disable POR_EN bit */
+	reg_rmw(serdes_regs + PCSR_CPU_CTRL_OFFSET, 0, POR_EN);
+	usleep_range(10, 100);
+}
+
+static int netcp_xgbe_serdes_config(void __iomem *serdes_regs,
+				    void __iomem *sw_regs)
+{
+	u32 ret, i;
+
+	netcp_xgbe_serdes_pll_disable(serdes_regs);
+	netcp_xgbe_serdes_cmu_init(serdes_regs);
+
+	for (i = 0; i < 2; i++)
+		netcp_xgbe_serdes_lane_config(serdes_regs, i);
+
+	netcp_xgbe_serdes_com_enable(serdes_regs);
+	/* This is EVM + RTM-BOC specific */
+	for (i = 0; i < 2; i++)
+		netcp_xgbe_serdes_setup_cm_c1_c2(serdes_regs, i, 0, 0, 5);
+
+	netcp_xgbe_serdes_pll_enable(serdes_regs);
+	for (i = 0; i < 2; i++)
+		netcp_xgbe_serdes_lane_enable(serdes_regs, i);
+
+	/* SB PLL Status Poll */
+	ret = netcp_xgbe_wait_pll_locked(sw_regs);
+	if (ret)
+		return ret;
+
+	netcp_xgbe_serdes_enable_xgmii_port(sw_regs);
+	netcp_xgbe_serdes_check_lane(serdes_regs, sw_regs);
+	return ret;
+}
+
+int netcp_xgbe_serdes_init(void __iomem *serdes_regs, void __iomem *xgbe_regs)
+{
+	u32 val;
+
+	/* read COMLANE bits 4:0 */
+	val = readl(serdes_regs + 0xa00);
+	if (val & 0x1f) {
+		pr_debug("XGBE: serdes already in operation - reset\n");
+		netcp_xgbe_reset_serdes(serdes_regs);
+	}
+	return netcp_xgbe_serdes_config(serdes_regs, xgbe_regs);
+}
-- 
1.7.9.5
