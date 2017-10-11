From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: dsa: bcm_sf2: Turn on ACB at the switch level
Date: Wed, 11 Oct 2017 10:57:51 -0700
Message-ID: <20171011175752.22030-5-f.fainelli@gmail.com>
References: <20171011175752.22030-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34352 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757692AbdJKR7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:59:40 -0400
Received: by mail-qt0-f194.google.com with SMTP id y45so3423556qty.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:59:40 -0700 (PDT)
In-Reply-To: <20171011175752.22030-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn on the out of band Advanced Congestion Buffering (ACB) mechanism at
the switch level now that we have properly established the queue mapping
between the switch egress queues and the SYSTEMPORT egress queues. This
allows the switch to correctly backpressure the host system when one of
its queue drops below the configured thresholds.

This is also helping achieve so called "lossless" behavior by adapting
the TX interrupt pacing to the actual speed and capacity of the switch
port.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 30 ++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2_regs.h | 23 +++++++++++++++++++++++
 2 files changed, 53 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 7aecc98d0a18..32025b990437 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -205,6 +205,19 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	if (port == priv->moca_port)
 		bcm_sf2_port_intr_enable(priv, port);
 
+	/* Set per-queue pause threshold to 32 */
+	core_writel(priv, 32, CORE_TXQ_THD_PAUSE_QN_PORT(port));
+
+	/* Set ACB threshold to 24 */
+	for (i = 0; i < SF2_NUM_EGRESS_QUEUES; i++) {
+		reg = acb_readl(priv, ACB_QUEUE_CFG(port *
+						    SF2_NUM_EGRESS_QUEUES + i));
+		reg &= ~XOFF_THRESHOLD_MASK;
+		reg |= 24;
+		acb_writel(priv, reg, ACB_QUEUE_CFG(port *
+						    SF2_NUM_EGRESS_QUEUES + i));
+	}
+
 	return b53_enable_port(ds, port, phy);
 }
 
@@ -613,6 +626,20 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		status->pause = 1;
 }
 
+static void bcm_sf2_enable_acb(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
+	u32 reg;
+
+	/* Enable ACB globally */
+	reg = acb_readl(priv, ACB_CONTROL);
+	reg |= (ACB_FLUSH_MASK << ACB_FLUSH_SHIFT);
+	acb_writel(priv, reg, ACB_CONTROL);
+	reg &= ~(ACB_FLUSH_MASK << ACB_FLUSH_SHIFT);
+	reg |= ACB_EN | ACB_ALGORITHM;
+	acb_writel(priv, reg, ACB_CONTROL);
+}
+
 static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
@@ -655,6 +682,8 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 			bcm_sf2_imp_setup(ds, port);
 	}
 
+	bcm_sf2_enable_acb(ds);
+
 	return 0;
 }
 
@@ -766,6 +795,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	}
 
 	bcm_sf2_sw_configure_vlan(ds);
+	bcm_sf2_enable_acb(ds);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index d8b8074a47b9..d1596dfca323 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -115,6 +115,24 @@ enum bcm_sf2_reg_offs {
 #define P7_IRQ_OFF			0
 #define P_IRQ_OFF(x)			((6 - (x)) * P_NUM_IRQ)
 
+/* Register set relative to 'ACB' */
+#define ACB_CONTROL			0x00
+#define  ACB_EN				(1 << 0)
+#define  ACB_ALGORITHM			(1 << 1)
+#define  ACB_FLUSH_SHIFT		2
+#define  ACB_FLUSH_MASK			0x3
+
+#define ACB_QUEUE_0_CFG			0x08
+#define  XOFF_THRESHOLD_MASK		0x7ff
+#define  XON_EN				(1 << 11)
+#define  TOTAL_XOFF_THRESHOLD_SHIFT	12
+#define  TOTAL_XOFF_THRESHOLD_MASK	0x7ff
+#define  TOTAL_XOFF_EN			(1 << 23)
+#define  TOTAL_XON_EN			(1 << 24)
+#define  PKTLEN_SHIFT			25
+#define  PKTLEN_MASK			0x3f
+#define ACB_QUEUE_CFG(x)		(ACB_QUEUE_0_CFG + ((x) * 0x4))
+
 /* Register set relative to 'CORE' */
 #define CORE_G_PCTL_PORT0		0x00000
 #define CORE_G_PCTL_PORT(x)		(CORE_G_PCTL_PORT0 + (x * 0x4))
@@ -237,6 +255,11 @@ enum bcm_sf2_reg_offs {
 #define CORE_PORT_VLAN_CTL_PORT(x)	(0xc400 + ((x) * 0x8))
 #define  PORT_VLAN_CTRL_MASK		0x1ff
 
+#define CORE_TXQ_THD_PAUSE_QN_PORT_0	0x2c80
+#define  TXQ_PAUSE_THD_MASK		0x7ff
+#define CORE_TXQ_THD_PAUSE_QN_PORT(x)	(CORE_TXQ_THD_PAUSE_QN_PORT_0 + \
+					(x) * 0x8)
+
 #define CORE_DEFAULT_1Q_TAG_P(x)	(0xd040 + ((x) * 8))
 #define  CFI_SHIFT			12
 #define  PRI_SHIFT			13
-- 
2.9.3
