From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 1/7] net: netcp: ethss: fix error in calling sgmii api with incorrect offset
Date: Wed, 23 Sep 2015 13:37:05 -0400
Message-ID: <1443029831-22035-2-git-send-email-m-karicheri2@ti.com>
References: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nsekhar@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>,
	<gregkh@linuxfoundation.org>, <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1443029831-22035-1-git-send-email-m-karicheri2@ti.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

On K2HK, sgmii module registers of slave 0 and 1 are mem
mapped to one contiguous block, while those of slave 2
and 3 are mapped to another contiguous block.  However,
on K2E and K2L, sgmii module registers of all slaves are
mem mapped to one contiguous block.  SGMII APIs expect
slave 0 sgmii base when API is invoked for slave 0 and 1,
and slave 2 sgmii base when invoked for other slaves.
Before this patch, slave 0 sgmii base is always passed to
sgmii API for K2E regardless which slave is the API invoked
for.  This patch fixes the problem.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 47 +++++++++++++++--------------------
 1 file changed, 20 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 6f16d6a..6bff8d8 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -77,6 +77,7 @@
 #define GBENU_ALE_OFFSET		0x1e000
 #define GBENU_HOST_PORT_NUM		0
 #define GBENU_NUM_ALE_ENTRIES		1024
+#define GBENU_SGMII_MODULE_SIZE		0x100
 
 /* 10G Ethernet SS defines */
 #define XGBE_MODULE_NAME		"netcp-xgbe"
@@ -149,8 +150,8 @@
 #define XGBE_STATS2_MODULE			2
 
 /* s: 0-based slave_port */
-#define SGMII_BASE(s) \
-	(((s) < 2) ? gbe_dev->sgmii_port_regs : gbe_dev->sgmii_port34_regs)
+#define SGMII_BASE(d, s) \
+	(((s) < 2) ? (d)->sgmii_port_regs : (d)->sgmii_port34_regs)
 
 #define GBE_TX_QUEUE				648
 #define	GBE_TXHOOK_ORDER			0
@@ -1997,13 +1998,8 @@ static void netcp_ethss_update_link_state(struct gbe_priv *gbe_dev,
 		return;
 
 	if (!SLAVE_LINK_IS_XGMII(slave)) {
-		if (gbe_dev->ss_version == GBE_SS_VERSION_14)
-			sgmii_link_state =
-				netcp_sgmii_get_port_link(SGMII_BASE(sp), sp);
-		else
-			sgmii_link_state =
-				netcp_sgmii_get_port_link(
-						gbe_dev->sgmii_port_regs, sp);
+		sgmii_link_state =
+			netcp_sgmii_get_port_link(SGMII_BASE(gbe_dev, sp), sp);
 	}
 
 	phy_link_state = gbe_phy_link_status(slave);
@@ -2100,17 +2096,11 @@ static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
 static void gbe_sgmii_rtreset(struct gbe_priv *priv,
 			      struct gbe_slave *slave, bool set)
 {
-	void __iomem *sgmii_port_regs;
-
 	if (SLAVE_LINK_IS_XGMII(slave))
 		return;
 
-	if ((priv->ss_version == GBE_SS_VERSION_14) && (slave->slave_num >= 2))
-		sgmii_port_regs = priv->sgmii_port34_regs;
-	else
-		sgmii_port_regs = priv->sgmii_port_regs;
-
-	netcp_sgmii_rtreset(sgmii_port_regs, slave->slave_num, set);
+	netcp_sgmii_rtreset(SGMII_BASE(priv, slave->slave_num),
+			    slave->slave_num, set);
 }
 
 static void gbe_slave_stop(struct gbe_intf *intf)
@@ -2136,17 +2126,12 @@ static void gbe_slave_stop(struct gbe_intf *intf)
 
 static void gbe_sgmii_config(struct gbe_priv *priv, struct gbe_slave *slave)
 {
-	void __iomem *sgmii_port_regs;
-
-	sgmii_port_regs = priv->sgmii_port_regs;
-	if ((priv->ss_version == GBE_SS_VERSION_14) && (slave->slave_num >= 2))
-		sgmii_port_regs = priv->sgmii_port34_regs;
+	if (SLAVE_LINK_IS_XGMII(slave))
+		return;
 
-	if (!SLAVE_LINK_IS_XGMII(slave)) {
-		netcp_sgmii_reset(sgmii_port_regs, slave->slave_num);
-		netcp_sgmii_config(sgmii_port_regs, slave->slave_num,
-				   slave->link_interface);
-	}
+	netcp_sgmii_reset(SGMII_BASE(priv, slave->slave_num), slave->slave_num);
+	netcp_sgmii_config(SGMII_BASE(priv, slave->slave_num), slave->slave_num,
+			   slave->link_interface);
 }
 
 static int gbe_slave_open(struct gbe_intf *gbe_intf)
@@ -2997,6 +2982,14 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->switch_regs = regs;
 
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBENU_SGMII_MODULE_OFFSET;
+
+	/* Although sgmii modules are mem mapped to one contiguous
+	 * region on GBENU devices, setting sgmii_port34_regs allows
+	 * consistent code when accessing sgmii api
+	 */
+	gbe_dev->sgmii_port34_regs = gbe_dev->sgmii_port_regs +
+				     (2 * GBENU_SGMII_MODULE_SIZE);
+
 	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBENU_HOST_PORT_OFFSET;
 
 	for (i = 0; i < (gbe_dev->max_num_ports); i++)
-- 
1.9.1
