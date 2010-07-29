From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 1/3] TI DaVinci EMAC : Implement interrupt pacing functionality.
Date: Thu, 29 Jul 2010 18:03:58 +0530
Message-ID: <1280406840-27393-1-git-send-email-srk@ti.com>
Cc: nsekhar@ti.com, anantgole@ti.com, Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:37972 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005Ab0G2MeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 08:34:08 -0400
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by comal.ext.ti.com (8.13.7/8.13.7) with ESMTP id o6TCY5Dj021011
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 07:34:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DaVinci EMAC module includes an interrupt pacing block that can
be programmed to throttle the rate at which interrupts are
generated. This patch implements interrupt pacing logic that can
be controlled through the ethtool interface(only rx_coalesce_usecs
param is honored)

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
 drivers/net/davinci_emac.c |  133 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 131 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 08e82b1..bc1b270 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -298,6 +298,11 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_CTRL_EWCTL		(0x4)
 #define EMAC_CTRL_EWINTTCNT	(0x8)
 
+/* EMAC DM644x control module masks */
+#define EMAC_DM644X_EWINTCNT_MASK	0x1FFFF
+#define EMAC_DM644X_INTMIN_INTVL	0x1
+#define EMAC_DM644X_INTMAX_INTVL	(EMAC_DM644X_EWINTCNT_MASK)
+
 /* EMAC MDIO related */
 /* Mask & Control defines */
 #define MDIO_CONTROL_CLKDIV	(0xFF)
@@ -318,8 +323,20 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define MDIO_CONTROL		(0x04)
 
 /* EMAC DM646X control module registers */
-#define EMAC_DM646X_CMRXINTEN	(0x14)
-#define EMAC_DM646X_CMTXINTEN	(0x18)
+#define EMAC_DM646X_CMINTCTRL	0x0C
+#define EMAC_DM646X_CMRXINTEN	0x14
+#define EMAC_DM646X_CMTXINTEN	0x18
+#define EMAC_DM646X_CMRXINTMAX	0x70
+#define EMAC_DM646X_CMTXINTMAX	0x74
+
+/* EMAC DM646X control module masks */
+#define EMAC_DM646X_INTPACEEN		(0x3 << 16)
+#define EMAC_DM646X_INTPRESCALE_MASK	(0x7FF << 0)
+#define EMAC_DM646X_CMINTMAX_CNT	63
+#define EMAC_DM646X_CMINTMIN_CNT	2
+#define EMAC_DM646X_CMINTMAX_INTVL	(1000 / EMAC_DM646X_CMINTMIN_CNT)
+#define EMAC_DM646X_CMINTMIN_INTVL	((1000 / EMAC_DM646X_CMINTMAX_CNT) + 1)
+
 
 /* EMAC EOI codes for C0 */
 #define EMAC_DM646X_MAC_EOI_C0_RXEN	(0x01)
@@ -468,6 +485,8 @@ struct emac_priv {
 	u32 duplex; /* Link duplex: 0=Half, 1=Full */
 	u32 rx_buf_size;
 	u32 isr_count;
+	u32 coal_intvl;
+	u32 bus_freq_mhz;
 	u8 rmii_en;
 	u8 version;
 	struct net_device_stats net_dev_stats;
@@ -692,6 +711,103 @@ static int emac_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 }
 
 /**
+ * emac_get_coalesce : Get interrupt coalesce settings for this device
+ * @ndev : The DaVinci EMAC network adapter
+ * @coal : ethtool coalesce settings structure
+ *
+ * Fetch the current interrupt coalesce settings
+ *
+ */
+static int emac_get_coalesce(struct net_device *ndev,
+				struct ethtool_coalesce *coal)
+{
+	struct emac_priv *priv = netdev_priv(ndev);
+
+	coal->rx_coalesce_usecs = priv->coal_intvl;
+	return 0;
+
+}
+
+/**
+ * emac_set_coalesce : Set interrupt coalesce settings for this device
+ * @ndev : The DaVinci EMAC network adapter
+ * @coal : ethtool coalesce settings structure
+ *
+ * Set interrupt coalesce parameters
+ *
+ */
+static int emac_set_coalesce(struct net_device *ndev,
+				struct ethtool_coalesce *coal)
+{
+	struct emac_priv *priv = netdev_priv(ndev);
+	u32 int_ctrl, num_interrupts = 0;
+	u32 prescale = 0, addnl_dvdr = 1, coal_intvl = 0;
+
+	if (!coal->rx_coalesce_usecs)
+		return -EINVAL;
+
+	coal_intvl = coal->rx_coalesce_usecs;
+
+	switch (priv->version) {
+	case EMAC_VERSION_2:
+		int_ctrl =  emac_ctrl_read(EMAC_DM646X_CMINTCTRL);
+		prescale = priv->bus_freq_mhz * 4;
+
+		if (coal_intvl < EMAC_DM646X_CMINTMIN_INTVL)
+			coal_intvl = EMAC_DM646X_CMINTMIN_INTVL;
+
+		if (coal_intvl > EMAC_DM646X_CMINTMAX_INTVL) {
+			/*
+			 * Interrupt pacer works with 4us Pulse, we can
+			 * throttle further by dilating the 4us pulse.
+			 */
+			addnl_dvdr = EMAC_DM646X_INTPRESCALE_MASK / prescale;
+
+			if (addnl_dvdr > 1) {
+				prescale *= addnl_dvdr;
+				if (coal_intvl > (EMAC_DM646X_CMINTMAX_INTVL
+							* addnl_dvdr))
+					coal_intvl = (EMAC_DM646X_CMINTMAX_INTVL
+							* addnl_dvdr);
+			} else {
+				addnl_dvdr = 1;
+				coal_intvl = EMAC_DM646X_CMINTMAX_INTVL;
+			}
+		}
+
+		num_interrupts = (1000 * addnl_dvdr) / coal_intvl;
+
+		int_ctrl |= EMAC_DM646X_INTPACEEN;
+		int_ctrl &= (~EMAC_DM646X_INTPRESCALE_MASK);
+		int_ctrl |= (prescale & EMAC_DM646X_INTPRESCALE_MASK);
+		emac_ctrl_write(EMAC_DM646X_CMINTCTRL, int_ctrl);
+
+		emac_ctrl_write(EMAC_DM646X_CMRXINTMAX, num_interrupts);
+		emac_ctrl_write(EMAC_DM646X_CMTXINTMAX, num_interrupts);
+
+		break;
+	default:
+		int_ctrl = emac_ctrl_read(EMAC_CTRL_EWINTTCNT);
+		int_ctrl &= (~EMAC_DM644X_EWINTCNT_MASK);
+		prescale = coal_intvl * priv->bus_freq_mhz;
+		if (prescale > EMAC_DM644X_EWINTCNT_MASK) {
+			prescale = EMAC_DM644X_EWINTCNT_MASK;
+			coal_intvl = prescale / priv->bus_freq_mhz;
+		}
+		emac_ctrl_write(EMAC_CTRL_EWINTTCNT, (int_ctrl | prescale));
+
+		break;
+	}
+
+	printk(KERN_INFO"Set coalesce to %d usecs.\n", coal_intvl);
+	priv->coal_intvl = coal_intvl;
+
+	return 0;
+
+}
+
+
+/**
  * ethtool_ops: DaVinci EMAC Ethtool structure
  *
  * Ethtool support for EMAC adapter
@@ -702,6 +818,8 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_settings = emac_get_settings,
 	.set_settings = emac_set_settings,
 	.get_link = ethtool_op_get_link,
+	.get_coalesce = emac_get_coalesce,
+	.set_coalesce =  emac_set_coalesce,
 };
 
 /**
@@ -2437,6 +2555,14 @@ static int emac_dev_open(struct net_device *ndev)
 	/* Start/Enable EMAC hardware */
 	emac_hw_enable(priv);
 
+	/* Enable Interrupt pacing if configured */
+	if (priv->coal_intvl != 0) {
+		struct ethtool_coalesce coal;
+
+		coal.rx_coalesce_usecs = (priv->coal_intvl << 4);
+		emac_set_coalesce(ndev, &coal);
+	}
+
 	/* find the first phy */
 	priv->phydev = NULL;
 	if (priv->phy_mask) {
@@ -2677,6 +2803,9 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->int_enable = pdata->interrupt_enable;
 	priv->int_disable = pdata->interrupt_disable;
 
+	priv->coal_intvl = 0;
+	priv->bus_freq_mhz = (u32)(emac_bus_frequency / 1000000);
+
 	emac_dev = &ndev->dev;
 	/* Get EMAC platform data */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.6.2.4

