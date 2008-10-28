From: Nate Case <ncase@xes-inc.com>
Subject: [PATCH] gianfar: Omit TBI auto-negotiation based on device tree
Date: Tue, 28 Oct 2008 17:53:02 -0500
Message-ID: <1225234382-23050-1-git-send-email-ncase@xes-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Andy Fleming <afleming@freescale.com>,
	Nate Case <ncase@xes-inc.com>, netdev@vger.kernel.org
To: Kumar Gala <kumar.gala@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Some SGMII PHYs don't auto-negotiate correctly with the TBI+SerDes
interface on the mpc85xx processors.  Check for the "sgmii-aneg-disable"
device tree flag and skip enabling auto-negotiation on the TBI
side if present.  Full duplex 1000 Mbit/s will be assumed for the
SGMII link to the PHY (note that this does not affect the link speed
on the external side of the external PHY).

Signed-off-by: Nate Case <ncase@xes-inc.com>
---
I'm submitting this to linuxppc-dev and netdev, though I'm not sure
which tree it should go through.  It touches network driver code
and some Freescale arch code, all of which is maintained by Kumar.

 Documentation/powerpc/dts-bindings/fsl/tsec.txt |    3 +++
 arch/powerpc/sysdev/fsl_soc.c                   |    4 ++++
 drivers/net/gianfar.c                           |   21 +++++++++++++++++++--
 drivers/net/gianfar.h                           |    3 ++-
 include/linux/fsl_devices.h                     |    1 +
 5 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
index cf55fa4..ad0633c 100644
--- a/Documentation/powerpc/dts-bindings/fsl/tsec.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
@@ -48,6 +48,9 @@ Properties:
     hardware.
   - fsl,magic-packet : If present, indicates that the hardware supports
     waking up via magic packet.
+  - sgmii-aneg-disable : If present, indicates that the device's SGMII
+    auto-negotiation should be disabled.  This may be necessary on boards
+    with PHYs that are unable to auto-negotiate with the MAC.
 
 Example:
 	ethernet@24000 {
diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 01b884b..5321aa4 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -355,6 +355,10 @@ static int __init gfar_of_init(void)
 		if (of_get_property(np, "fsl,magic-packet", NULL))
 			gfar_data.device_flags |= FSL_GIANFAR_DEV_HAS_MAGIC_PACKET;
 
+		if (of_get_property(np, "sgmii-aneg-disable", NULL))
+			gfar_data.board_flags |=
+				FSL_GIANFAR_BRD_SGMII_ANEG_DIS;
+
 		ph = of_get_property(np, "phy-handle", NULL);
 		if (ph == NULL) {
 			u32 *fixed_link;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 64b2011..0a1c22f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -335,6 +335,15 @@ static int gfar_probe(struct platform_device *pdev)
 	if (dev->features & NETIF_F_IP_CSUM)
 		dev->hard_header_len += GMAC_FCB_LEN;
 
+	/*
+	 * Some SGMII PHYs don't auto-negotiate correctly with the
+	 * TBI+SerDes interface.
+	 */
+	if (priv->einfo->board_flags & FSL_GIANFAR_BRD_SGMII_ANEG_DIS)
+		priv->tbi_aneg_enable = 0;
+	else
+		priv->tbi_aneg_enable = 1;
+
 	priv->rx_buffer_size = DEFAULT_RX_BUFFER_SIZE;
 	priv->tx_ring_size = DEFAULT_TX_RING_SIZE;
 	priv->rx_ring_size = DEFAULT_RX_RING_SIZE;
@@ -586,6 +595,7 @@ static void gfar_configure_serdes(struct net_device *dev)
 	struct gfar_mii __iomem *regs =
 			(void __iomem *)&priv->regs->gfar_mii_regs;
 	int tbipa = gfar_read(&priv->regs->tbipa);
+	u16 bmcr_val;
 
 	/* Single clk mode, mii mode off(for serdes communication) */
 	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
@@ -594,8 +604,15 @@ static void gfar_configure_serdes(struct net_device *dev)
 			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
 			ADVERTISE_1000XPSE_ASYM);
 
-	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
-			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
+	if (priv->tbi_aneg_enable)
+		/* ANEG enable, restart ANEG, full duplex mode, speed[1] set */
+		bmcr_val = BMCR_ANENABLE | BMCR_ANRESTART | BMCR_FULLDPLX |
+			   BMCR_SPEED1000;
+	else
+		/* ANEG disabled, full duplex, speed[1] set */
+		bmcr_val = BMCR_FULLDPLX | BMCR_SPEED1000;
+
+	gfar_local_mdio_write(regs, tbipa, MII_BMCR, bmcr_val);
 }
 
 static void init_registers(struct net_device *dev)
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index f46e9b6..aa485da 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -737,7 +737,8 @@ struct gfar_private {
 		rx_csum_enable:1,
 		extended_hash:1,
 		bd_stash_en:1,
-		wol_en:1; /* Wake-on-LAN enabled */
+		wol_en:1, /* Wake-on-LAN enabled */
+		tbi_aneg_enable:1;
 	unsigned short padding;
 
 	unsigned int interruptTransmit;
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 4e625e0..f516dbc 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -74,6 +74,7 @@ struct gianfar_mdio_data {
 /* Flags in gianfar_platform_data */
 #define FSL_GIANFAR_BRD_HAS_PHY_INTR	0x00000001 /* set or use a timer */
 #define FSL_GIANFAR_BRD_IS_REDUCED	0x00000002 /* Set if RGMII, RMII */
+#define FSL_GIANFAR_BRD_SGMII_ANEG_DIS	0x00000004 /* SGMII PHY w/o ANEG */
 
 struct fsl_i2c_platform_data {
 	/* device specific information */
-- 
1.6.0.2
