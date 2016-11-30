From: Neill Whillans <neill.whillans@codethink.co.uk>
Subject: [PATCH 2/2] net: ethernet: altera_tse: add support for SGMII PCS
Date: Wed, 30 Nov 2016 13:41:05 +0000
Message-ID: <f5e74eafa8ebc70bcab1ef7982c5d027c3e1b4c4.1480497966.git.neill.whillans@codethink.co.uk>
References: <cover.1480497966.git.neill.whillans@codethink.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@lists.codethink.co.uk,
        nios2-dev@lists.rocketboards.org, vbridger@opensource.altera.com,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap0.codethink.co.uk ([185.43.218.159]:43535 "EHLO
        imap0.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757575AbcK3OOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:14:05 -0500
In-Reply-To: <cover.1480497966.git.neill.whillans@codethink.co.uk>
In-Reply-To: <cover.1480497966.git.neill.whillans@codethink.co.uk>
References: <cover.1480497966.git.neill.whillans@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the (optional) SGMII PCS functionality of the Altera
TSE MAC. If the phy-mode is set to 'sgmii' then we attempt to discover
and initialise the PCS so that the MAC can communicate to the PHY.

The PCS IP block provides a scratch register for testing presence of
the PCS, which is mapped into one of the two MDIO spaces present in
the MAC's register space.  Once we have determined that the scratch
register is functioning, we attempt to initialise the PCS to
auto-negotiate an SGMII link with the PHY. There is no need to monitor
or manage the SGMII link beyond this, since the normal PHY MDIO will
then be used to monitor the media layer.

The Altera TSE MAC has only one way in which it can be configured with an
SGMII PCS, and as such, this patch only looks to the phy-mode to select
whether or not to attempt to initialise the PCS registers.  During
initialisation, we report the PCS's equivalent of a PHY ID register.
This can be parameterised during the IP instantiation and is often left
as '0x00000000' which is not an error.

Signed-off-by: Neill Whillans <neill.whillans@codethink.co.uk>
Reviewed-by: Daniel Silverstone <daniel.silverstone@codethink.co.uk>
---
 drivers/net/ethernet/altera/altera_tse.h      | 11 ++++
 drivers/net/ethernet/altera/altera_tse_main.c | 91 +++++++++++++++++++++++++++
 2 files changed, 102 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index e005200..446e778 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -120,6 +120,17 @@
 #define MAC_CMDCFG_DISABLE_READ_TIMEOUT_GET(v)	GET_BIT_VALUE(v, 27)
 #define MAC_CMDCFG_CNT_RESET_GET(v)		GET_BIT_VALUE(v, 31)
 
+/* SGMII PCS register addresses
+ */
+#define SGMII_PCS_SCRATCH	0x10
+#define SGMII_PCS_REV		0x11
+#define SGMII_PCS_LINK_TIMER_0	0x12
+#define SGMII_PCS_LINK_TIMER_1	0x13
+#define SGMII_PCS_IF_MODE	0x14
+#define SGMII_PCS_DIS_READ_TO	0x15
+#define SGMII_PCS_READ_TO	0x16
+#define SGMII_PCS_SW_RESET_TIMEOUT 100 /* usecs */
+
 /* MDIO registers within MAC register Space
  */
 struct altera_tse_mdio {
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index bda31f3..afecdd1 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -37,6 +37,7 @@
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/mii.h>
 #include <linux/netdevice.h>
 #include <linux/of_device.h>
 #include <linux/of_mdio.h>
@@ -96,6 +97,27 @@ static inline u32 tse_tx_avail(struct altera_tse_private *priv)
 	return priv->tx_cons + priv->tx_ring_size - priv->tx_prod - 1;
 }
 
+/* PCS Register read/write functions
+ */
+static u16 sgmii_pcs_read(struct altera_tse_private *priv, int regnum)
+{
+	return csrrd32(priv->mac_dev,
+		       tse_csroffs(mdio_phy0) + regnum * 4) & 0xffff;
+}
+
+static void sgmii_pcs_write(struct altera_tse_private *priv, int regnum,
+				u16 value)
+{
+	csrwr32(value, priv->mac_dev, tse_csroffs(mdio_phy0) + regnum * 4);
+}
+
+/* Check PCS scratch memory */
+static int sgmii_pcs_scratch_test(struct altera_tse_private *priv, u16 value)
+{
+	sgmii_pcs_write(priv, SGMII_PCS_SCRATCH, value);
+	return (sgmii_pcs_read(priv, SGMII_PCS_SCRATCH) == value);
+}
+
 /* MDIO specific functions
  */
 static int altera_tse_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
@@ -1092,6 +1114,66 @@ static void tse_set_rx_mode(struct net_device *dev)
 	spin_unlock(&priv->mac_cfg_lock);
 }
 
+/* Initialise (if necessary) the SGMII PCS component
+ */
+static int init_sgmii_pcs(struct net_device *dev)
+{
+	struct altera_tse_private *priv = netdev_priv(dev);
+	int n;
+	unsigned int tmp_reg = 0;
+
+	if (priv->phy_iface != PHY_INTERFACE_MODE_SGMII)
+		return 0; /* Nothing to do, not in SGMII mode */
+
+	/* The TSE SGMII PCS block looks a little like a PHY, it is
+	 * mapped into the zeroth MDIO space of the MAC and it has
+	 * ID registers like a PHY would.  Sadly this is often
+	 * configured to zeroes, so don't be surprised if it does
+	 * show 0x00000000.
+	 */
+
+	if (sgmii_pcs_scratch_test(priv, 0x0000) &&
+		sgmii_pcs_scratch_test(priv, 0xffff) &&
+		sgmii_pcs_scratch_test(priv, 0xa5a5) &&
+		sgmii_pcs_scratch_test(priv, 0x5a5a)) {
+		netdev_info(dev, "PCS PHY ID: 0x%04x%04x\n",
+				sgmii_pcs_read(priv, MII_PHYSID1),
+				sgmii_pcs_read(priv, MII_PHYSID2));
+	} else {
+		netdev_err(dev, "SGMII PCS Scratch memory test failed.\n");
+		return -ENOMEM;
+	}
+
+	/* Starting on page 5-29 of the MegaCore Function User Guide
+	 * Set SGMII Link timer to 1.6ms
+	 */
+	sgmii_pcs_write(priv, SGMII_PCS_LINK_TIMER_0, 0x0D40);
+	sgmii_pcs_write(priv, SGMII_PCS_LINK_TIMER_1, 0x03);
+
+	/* Enable SGMII Interface and Enable SGMII Auto Negotiation */
+	sgmii_pcs_write(priv, SGMII_PCS_IF_MODE, 0x3);
+
+	/* Enable Autonegotiation */
+	tmp_reg = sgmii_pcs_read(priv, MII_BMCR);
+	tmp_reg |= (BMCR_SPEED1000 | BMCR_FULLDPLX | BMCR_ANENABLE);
+	sgmii_pcs_write(priv, MII_BMCR, tmp_reg);
+
+	/* Reset PCS block */
+	tmp_reg |= BMCR_RESET;
+	sgmii_pcs_write(priv, MII_BMCR, tmp_reg);
+	for (n = 0; n < SGMII_PCS_SW_RESET_TIMEOUT; n++) {
+		if (!(sgmii_pcs_read(priv, MII_BMCR) & BMCR_RESET)) {
+			netdev_info(dev, "SGMII PCS block initialised OK\n");
+			return 0;
+		}
+		udelay(1);
+	}
+
+	/* We failed to reset the block, return a timeout */
+	netdev_err(dev, "SGMII PCS block reset failed.\n");
+	return -ETIMEDOUT;
+}
+
 /* Open and initialize the interface
  */
 static int tse_open(struct net_device *dev)
@@ -1116,6 +1198,15 @@ static int tse_open(struct net_device *dev)
 		netdev_warn(dev, "TSE revision %x\n", priv->revision);
 
 	spin_lock(&priv->mac_cfg_lock);
+	/* no-op if MAC not operating in SGMII mode*/
+	ret = init_sgmii_pcs(dev);
+	if (ret) {
+		netdev_err(dev,
+			   "Cannot init the SGMII PCS (error: %d)\n", ret);
+		spin_unlock(&priv->mac_cfg_lock);
+		goto phy_error;
+	}
+
 	ret = reset_mac(priv);
 	/* Note that reset_mac will fail if the clocks are gated by the PHY
 	 * due to the PHY being put into isolation or power down mode.
-- 
2.1.4
