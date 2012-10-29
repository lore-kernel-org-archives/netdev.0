From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 05/10] cpsw: support both silicon versions
Date: Mon, 29 Oct 2012 19:45:15 +0100
Message-ID: <7b4847b9e4ff65a26f9291276b85a583d51addd4.1351535539.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44513 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760512Ab2J2Spp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:45:45 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2256783eek.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 11:45:44 -0700 (PDT)
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the cpsw driver to operate correctly with both the
dm814x and the am335x versions of the switch hardware.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt |    8 +-
 drivers/net/ethernet/ti/cpsw.c                 |  106 ++++++++++++++++++++----
 2 files changed, 94 insertions(+), 20 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index dcaabe9..3af47b7 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -59,14 +59,14 @@ Examples:
 		mac_control = <0x20>;
 		slaves = <2>;
 		cpsw_emac0: slave@0 {
-			slave_reg_ofs = <0x208>;
+			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
 			phy_id = "davinci_mdio.16:00";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
-			slave_reg_ofs = <0x308>;
+			slave_reg_ofs = <0x300>;
 			sliver_reg_ofs = <0xdc0>;
 			phy_id = "davinci_mdio.16:01";
 			/* Filled in by U-Boot */
@@ -93,14 +93,14 @@ Examples:
 		mac_control = <0x20>;
 		slaves = <2>;
 		cpsw_emac0: slave@0 {
-			slave_reg_ofs = <0x208>;
+			slave_reg_ofs = <0x200>;
 			sliver_reg_ofs = <0xd80>;
 			phy_id = "davinci_mdio.16:00";
 			/* Filled in by U-Boot */
 			mac-address = [ 00 00 00 00 00 00 ];
 		};
 		cpsw_emac1: slave@1 {
-			slave_reg_ofs = <0x308>;
+			slave_reg_ofs = <0x300>;
 			sliver_reg_ofs = <0xdc0>;
 			phy_id = "davinci_mdio.16:01";
 			/* Filled in by U-Boot */
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5c427cf..588f5c3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -160,18 +160,74 @@ struct cpsw_ss_regs {
 	u32	dlr_ltype;
 };
 
-struct cpsw_slave_regs {
-	u32	max_blks;
-	u32	blk_cnt;
-	u32	flow_thresh;
-	u32	port_vlan;
-	u32	tx_pri_map;
-	u32	ts_ctl;
-	u32	ts_seq_ltype;
-	u32	ts_vlan;
-	u32	sa_lo;
-	u32	sa_hi;
-};
+/* CPSW_PORT_V1 */
+#define CPSW1_MAX_BLKS      0x00 /* Maximum FIFO Blocks */
+#define CPSW1_BLK_CNT       0x04 /* FIFO Block Usage Count (Read Only) */
+#define CPSW1_TX_IN_CTL     0x08 /* Transmit FIFO Control */
+#define CPSW1_PORT_VLAN     0x0c /* VLAN Register */
+#define CPSW1_TX_PRI_MAP    0x10 /* Tx Header Priority to Switch Pri Mapping */
+#define CPSW1_TS_CTL        0x14 /* Time Sync Control */
+#define CPSW1_TS_SEQ_LTYPE  0x18 /* Time Sync Sequence ID Offset and Msg Type */
+#define CPSW1_TS_VLAN       0x1c /* Time Sync VLAN1 and VLAN2 */
+
+/* CPSW_PORT_V2 */
+#define CPSW2_CONTROL       0x00 /* Control Register */
+#define CPSW2_MAX_BLKS      0x08 /* Maximum FIFO Blocks */
+#define CPSW2_BLK_CNT       0x0c /* FIFO Block Usage Count (Read Only) */
+#define CPSW2_TX_IN_CTL     0x10 /* Transmit FIFO Control */
+#define CPSW2_PORT_VLAN     0x14 /* VLAN Register */
+#define CPSW2_TX_PRI_MAP    0x18 /* Tx Header Priority to Switch Pri Mapping */
+#define CPSW2_TS_SEQ_MTYPE  0x1c /* Time Sync Sequence ID Offset and Msg Type */
+
+/* CPSW_PORT_V1 and V2 */
+#define SA_LO               0x20 /* CPGMAC_SL Source Address Low */
+#define SA_HI               0x24 /* CPGMAC_SL Source Address High */
+#define SEND_PERCENT        0x28 /* Transmit Queue Send Percentages */
+
+/* CPSW_PORT_V2 only */
+#define RX_DSCP_PRI_MAP0    0x30 /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP1    0x34 /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP2    0x38 /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP3    0x3c /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP4    0x40 /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP5    0x44 /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP6    0x48 /* Rx DSCP Priority to Rx Packet Mapping */
+#define RX_DSCP_PRI_MAP7    0x4c /* Rx DSCP Priority to Rx Packet Mapping */
+
+/* Bit definitions for the CPSW2_CONTROL register */
+#define PASS_PRI_TAGGED     (1<<24) /* Pass Priority Tagged */
+#define VLAN_LTYPE2_EN      (1<<21) /* VLAN LTYPE 2 enable */
+#define VLAN_LTYPE1_EN      (1<<20) /* VLAN LTYPE 1 enable */
+#define DSCP_PRI_EN         (1<<16) /* DSCP Priority Enable */
+#define TS_320              (1<<14) /* Time Sync Dest Port 320 enable */
+#define TS_319              (1<<13) /* Time Sync Dest Port 319 enable */
+#define TS_132              (1<<12) /* Time Sync Dest IP Addr 132 enable */
+#define TS_131              (1<<11) /* Time Sync Dest IP Addr 131 enable */
+#define TS_130              (1<<10) /* Time Sync Dest IP Addr 130 enable */
+#define TS_129              (1<<9)  /* Time Sync Dest IP Addr 129 enable */
+#define TS_BIT8             (1<<8)  /* ts_ttl_nonzero? */
+#define TS_ANNEX_D_EN       (1<<4)  /* Time Sync Annex D enable */
+#define TS_LTYPE2_EN        (1<<3)  /* Time Sync LTYPE 2 enable */
+#define TS_LTYPE1_EN        (1<<2)  /* Time Sync LTYPE 1 enable */
+#define TS_TX_EN            (1<<1)  /* Time Sync Transmit Enable */
+#define TS_RX_EN            (1<<0)  /* Time Sync Receive Enable */
+
+#define CTRL_TS_BITS \
+	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 | TS_BIT8 | \
+	 TS_ANNEX_D_EN | TS_LTYPE1_EN)
+
+#define CTRL_ALL_TS_MASK (CTRL_TS_BITS | TS_TX_EN | TS_RX_EN)
+#define CTRL_TX_TS_BITS  (CTRL_TS_BITS | TS_TX_EN)
+#define CTRL_RX_TS_BITS  (CTRL_TS_BITS | TS_RX_EN)
+
+/* Bit definitions for the CPSW2_TS_SEQ_MTYPE register */
+#define TS_SEQ_ID_OFFSET_SHIFT   (16)    /* Time Sync Sequence ID Offset */
+#define TS_SEQ_ID_OFFSET_MASK    (0x3f)
+#define TS_MSG_TYPE_EN_SHIFT     (0)     /* Time Sync Message Type Enable */
+#define TS_MSG_TYPE_EN_MASK      (0xffff)
+
+/* The PTP event messages - Sync, Delay_Req, Pdelay_Req, and Pdelay_Resp. */
+#define EVENT_MSG_BITS ((1<<0) | (1<<1) | (1<<2) | (1<<3))
 
 struct cpsw_host_regs {
 	u32	max_blks;
@@ -197,7 +253,7 @@ struct cpsw_sliver_regs {
 };
 
 struct cpsw_slave {
-	struct cpsw_slave_regs __iomem	*regs;
+	void __iomem			*regs;
 	struct cpsw_sliver_regs __iomem	*sliver;
 	int				slave_num;
 	u32				mac_control;
@@ -205,6 +261,16 @@ struct cpsw_slave {
 	struct phy_device		*phy;
 };
 
+static inline u32 slave_read(struct cpsw_slave *slave, u32 offset)
+{
+	return __raw_readl(slave->regs + offset);
+}
+
+static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
+{
+	__raw_writel(val, slave->regs + offset);
+}
+
 struct cpsw_priv {
 	spinlock_t			lock;
 	struct platform_device		*pdev;
@@ -396,8 +462,8 @@ static inline void soft_reset(const char *module, void __iomem *reg)
 static void cpsw_set_slave_mac(struct cpsw_slave *slave,
 			       struct cpsw_priv *priv)
 {
-	__raw_writel(mac_hi(priv->mac_addr), &slave->regs->sa_hi);
-	__raw_writel(mac_lo(priv->mac_addr), &slave->regs->sa_lo);
+	slave_write(slave, mac_hi(priv->mac_addr), SA_HI);
+	slave_write(slave, mac_lo(priv->mac_addr), SA_LO);
 }
 
 static void _cpsw_adjust_link(struct cpsw_slave *slave,
@@ -483,7 +549,15 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 	/* setup priority mapping */
 	__raw_writel(RX_PRIORITY_MAPPING, &slave->sliver->rx_pri_map);
-	__raw_writel(TX_PRIORITY_MAPPING, &slave->regs->tx_pri_map);
+
+	switch (priv->version) {
+	case CPSW_VERSION_1:
+		slave_write(slave, TX_PRIORITY_MAPPING, CPSW1_TX_PRI_MAP);
+		break;
+	case CPSW_VERSION_2:
+		slave_write(slave, TX_PRIORITY_MAPPING, CPSW2_TX_PRI_MAP);
+		break;
+	}
 
 	/* setup max packet size, and mac address */
 	__raw_writel(priv->rx_packet_max, &slave->sliver->rx_maxlen);
-- 
1.7.2.5
