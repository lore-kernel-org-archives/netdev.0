From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/4] net: dsa: bcm_sf2: Configure traffic classes to queue mapping
Date: Sat, 28 Jan 2017 19:13:23 -0800
Message-ID: <20170129031325.21911-3-f.fainelli@gmail.com>
References: <20170129031325.21911-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, cphealy@gmail.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36541 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750856AbdA2DkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 22:40:20 -0500
Received: by mail-oi0-f66.google.com with SMTP id u143so23450092oif.3
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 19:39:46 -0800 (PST)
In-Reply-To: <20170129031325.21911-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, all traffic goes to queue 0, re-configure the traffic
classes to quality of service mapping such that priority X maps to queue
X, where X is from 0 through 7.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 9 +++++++++
 drivers/net/dsa/bcm_sf2_regs.h | 4 ++++
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8eecfd227e06..637072da3acf 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -229,6 +229,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	s8 cpu_port = ds->dst[ds->index].cpu_port;
+	unsigned int i;
 	u32 reg;
 
 	/* Clear the memory power down */
@@ -240,6 +241,14 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	if (priv->brcm_tag_mask & BIT(port))
 		bcm_sf2_brcm_hdr_setup(priv, port);
 
+	/* Configure Traffic Class to QoS mapping, allow each priority to map
+	 * to a different queue number
+	 */
+	reg = core_readl(priv, CORE_PORT_TC2_QOS_MAP_PORT(port));
+	for (i = 0; i < 8; i++)
+		reg |= i << (PRT_TO_QID_SHIFT * i);
+	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
+
 	/* Clear the Rx and Tx disable bits and set to no spanning tree */
 	core_writel(priv, 0, CORE_G_PCTL_PORT(port));
 
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 3b33b8010cc8..6b63c00928ba 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -238,6 +238,10 @@ enum bcm_sf2_reg_offs {
 #define  P_TXQ_PSM_VDD(x)		(P_TXQ_PSM_VDD_MASK << \
 					((x) * P_TXQ_PSM_VDD_SHIFT))
 
+#define CORE_PORT_TC2_QOS_MAP_PORT(x)	(0xc1c0 + ((x) * 0x10))
+#define  PRT_TO_QID_MASK		0x3
+#define  PRT_TO_QID_SHIFT		3
+
 #define CORE_PORT_VLAN_CTL_PORT(x)	(0xc400 + ((x) * 0x8))
 #define  PORT_VLAN_CTRL_MASK		0x1ff
 
-- 
2.9.3
