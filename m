From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2 1/3] phylib: Convert MDIO and PHY Lib drivers to support 10G
Date: Tue, 11 Oct 2011 20:20:20 -0500
Message-ID: <1318382422-2133-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:46649
	"EHLO AM1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750858Ab1JLBU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 21:20:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10G MDIO is a totally different protocol (clause 45 of 802.3).
Supporting this new protocol requires a couple of changes:

* Add a new parameter to the mdiobus_read functions to specify the
  "device address" inside the PHY.
* Add a phy45_read/write function which takes advantage of that
  new parameter
* Convert all of the existing drivers to use the new format

I created a new clause-45-specific read/write functions because:
1) phy_read and phy_write are highly overloaded functions, and
   finding every instance which is actually the PHY Lib version
   was quite difficult
2) Most code which invokes phy_read/phy_write inside PHY Lib is
   Clause-22-specific. None of the phy_read/phy_write invocations
   were useable on 10G PHYs

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 Documentation/networking/phy.txt                  |   15 +++--
 arch/powerpc/platforms/pasemi/gpio_mdio.c         |    6 +-
 drivers/net/ethernet/adi/bfin_mac.c               |    7 +-
 drivers/net/ethernet/aeroflex/greth.c             |    5 +-
 drivers/net/ethernet/amd/au1000_eth.c             |    7 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c      |    4 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c        |    7 +-
 drivers/net/ethernet/broadcom/tg3.c               |    5 +-
 drivers/net/ethernet/cadence/macb.c               |    7 +-
 drivers/net/ethernet/dnet.c                       |    7 +-
 drivers/net/ethernet/ethoc.c                      |    5 +-
 drivers/net/ethernet/faraday/ftgmac100.c          |    5 +-
 drivers/net/ethernet/freescale/fec.c              |    7 +-
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c  |    7 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c  |    6 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c      |   13 ++--
 drivers/net/ethernet/freescale/fsl_pq_mdio.h      |   11 ++-
 drivers/net/ethernet/lantiq_etop.c                |    5 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c        |    5 +-
 drivers/net/ethernet/marvell/pxa168_eth.c         |    7 +-
 drivers/net/ethernet/rdc/r6040.c                  |    5 +-
 drivers/net/ethernet/s6gmac.c                     |    5 +-
 drivers/net/ethernet/smsc/smsc911x.c              |   22 ++++---
 drivers/net/ethernet/smsc/smsc9420.c              |   10 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    9 ++-
 drivers/net/ethernet/ti/cpmac.c                   |    4 +-
 drivers/net/ethernet/ti/davinci_mdio.c            |    5 +-
 drivers/net/ethernet/toshiba/tc35815.c            |    5 +-
 drivers/net/ethernet/xilinx/ll_temac_mdio.c       |    5 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |    9 ++-
 drivers/net/ethernet/xscale/ixp4xx_eth.c          |    7 +-
 drivers/net/phy/fixed.c                           |    5 +-
 drivers/net/phy/icplus.c                          |   17 +++--
 drivers/net/phy/mdio-bitbang.c                    |    5 +-
 drivers/net/phy/mdio-octeon.c                     |    5 +-
 drivers/net/phy/mdio_bus.c                        |    8 +-
 drivers/net/phy/phy.c                             |    5 +-
 drivers/net/phy/phy_device.c                      |   64 +++++++++++++------
 include/linux/phy.h                               |   70 ++++++++++++++++++---
 net/dsa/slave.c                                   |    5 +-
 40 files changed, 270 insertions(+), 141 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 9eb1ba5..cf10707 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -40,13 +40,14 @@ The MDIO bus
 
  1) read and write functions must be implemented.  Their prototypes are:
 
-     int write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
-     int read(struct mii_bus *bus, int mii_id, int regnum);
-
-   mii_id is the address on the bus for the PHY, and regnum is the register
-   number.  These functions are guaranteed not to be called from interrupt
-   time, so it is safe for them to block, waiting for an interrupt to signal
-   the operation is complete
+     int write(struct mii_bus *bus, int addr, int devad, u16 regnum,
+		u16 value);
+     int read(struct mii_bus *bus, int addr, int devad, u16 regnum);
+
+   addr is the address on the bus for the PHY, devad is the address of the
+   internal device, and regnum is the register number.  These functions are
+   guaranteed not to be called from interrupt time, so it is safe for them
+   to block, waiting for an interrupt to signal the operation is complete
  
  2) A reset function is necessary.  This is used to return the bus to an
    initialized state.
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 9886296..a7256b9 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -124,7 +124,8 @@ static void bitbang_pre(struct mii_bus *bus, int read, u8 addr, u8 reg)
 	}
 }
 
-static int gpio_mdio_read(struct mii_bus *bus, int phy_id, int location)
+static int gpio_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int location)
 {
 	u16 rdreg;
 	int ret, i;
@@ -163,7 +164,8 @@ static int gpio_mdio_read(struct mii_bus *bus, int phy_id, int location)
 	return ret;
 }
 
-static int gpio_mdio_write(struct mii_bus *bus, int phy_id, int location, u16 val)
+static int gpio_mdio_write(struct mii_bus *bus, int phy_id, int devad,
+				int location, u16 val)
 {
 	int i;
 
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index b6d69c9..7e343b4 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -267,7 +267,8 @@ static int bfin_mdio_poll(void)
 }
 
 /* Read an off-chip register in a PHY through the MDC/MDIO port */
-static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum)
 {
 	int ret;
 
@@ -288,8 +289,8 @@ static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 }
 
 /* Write an off-chip register in a PHY through the MDC/MDIO port */
-static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
-			      u16 value)
+static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum, u16 value)
 {
 	int ret;
 
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 6715bf5..faab1cc 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1176,7 +1176,7 @@ static inline int wait_for_mdio(struct greth_private *greth)
 	return 1;
 }
 
-static int greth_mdio_read(struct mii_bus *bus, int phy, int reg)
+static int greth_mdio_read(struct mii_bus *bus, int phy, int devad, int reg)
 {
 	struct greth_private *greth = bus->priv;
 	int data;
@@ -1198,7 +1198,8 @@ static int greth_mdio_read(struct mii_bus *bus, int phy, int reg)
 	}
 }
 
-static int greth_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
+static int greth_mdio_write(struct mii_bus *bus, int phy, int devad, int reg,
+				u16 val)
 {
 	struct greth_private *greth = bus->priv;
 
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8238667..9e879c2 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -224,7 +224,8 @@ static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 	writel(mii_control, mii_control_reg);
 }
 
-static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum)
 {
 	/* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
 	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus)
@@ -239,8 +240,8 @@ static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 	return au1000_mdio_read(dev, phy_addr, regnum);
 }
 
-static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
-				u16 value)
+static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum, u16 value)
 {
 	struct net_device *const dev = bus->priv;
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a11a8ad..016bda7 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -139,7 +139,7 @@ static int bcm_enet_mdio_write(struct bcm_enet_priv *priv, int mii_id,
 /*
  * MII read callback from phylib
  */
-static int bcm_enet_mdio_read_phylib(struct mii_bus *bus, int mii_id,
+static int bcm_enet_mdio_read_phylib(struct mii_bus *bus, int mii_id, int devad,
 				     int regnum)
 {
 	return bcm_enet_mdio_read(bus->priv, mii_id, regnum);
@@ -149,7 +149,7 @@ static int bcm_enet_mdio_read_phylib(struct mii_bus *bus, int mii_id,
  * MII write callback from phylib
  */
 static int bcm_enet_mdio_write_phylib(struct mii_bus *bus, int mii_id,
-				      int regnum, u16 value)
+				      int devad, int regnum, u16 value)
 {
 	return bcm_enet_mdio_write(bus->priv, mii_id, regnum, value);
 }
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 0a1d7f2..7d0c64e 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -435,7 +435,8 @@ static void sbmac_mii_senddata(void __iomem *sbm_mdio, unsigned int data,
  *  	   value read, or 0xffff if an error occurred.
  ********************************************************************* */
 
-static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx)
 {
 	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
 	void __iomem *sbm_mdio = sc->sbm_mdio;
@@ -528,8 +529,8 @@ static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
  *  	   0 for success
  ********************************************************************* */
 
-static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 regval)
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx, u16 regval)
 {
 	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
 	void __iomem *sbm_mdio = sc->sbm_mdio;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index fe712f9..5f4007e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1168,7 +1168,7 @@ static int tg3_bmcr_reset(struct tg3 *tp)
 	return 0;
 }
 
-static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
+static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int devad, int reg)
 {
 	struct tg3 *tp = bp->priv;
 	u32 val;
@@ -1183,7 +1183,8 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
 	return val;
 }
 
-static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
+static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int devad, int reg,
+			u16 val)
 {
 	struct tg3 *tp = bp->priv;
 	u32 ret = 0;
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a437b46..9479b2a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -89,7 +89,8 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	}
 }
 
-static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int macb_mdio_read(struct mii_bus *bus, int mii_id, int devad,
+			int regnum)
 {
 	struct macb *bp = bus->priv;
 	int value;
@@ -109,8 +110,8 @@ static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return value;
 }
 
-static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
+static int macb_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+			int regnum, u16 value)
 {
 	struct macb *bp = bus->priv;
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index c1063d1..70e8347 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -100,7 +100,8 @@ static void __devinit dnet_get_hwaddr(struct dnet *bp)
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 }
 
-static int dnet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int dnet_mdio_read(struct mii_bus *bus, int mii_id, int devad,
+			int regnum)
 {
 	struct dnet *bp = bus->priv;
 	u16 value;
@@ -132,8 +133,8 @@ static int dnet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return value;
 }
 
-static int dnet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
+static int dnet_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+			int regnum, u16 value)
 {
 	struct dnet *bp = bus->priv;
 	u16 tmp;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index bdb348a..700e7db 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -611,7 +611,7 @@ static int ethoc_poll(struct napi_struct *napi, int budget)
 	return rx_work_done;
 }
 
-static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
+static int ethoc_mdio_read(struct mii_bus *bus, int phy, int devad, int reg)
 {
 	struct ethoc *priv = bus->priv;
 	int i;
@@ -633,7 +633,8 @@ static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 	return -EBUSY;
 }
 
-static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
+static int ethoc_mdio_write(struct mii_bus *bus, int phy, int devad, int reg,
+				u16 val)
 {
 	struct ethoc *priv = bus->priv;
 	int i;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 54709af..c38fa69 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -865,7 +865,8 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 /******************************************************************************
  * struct mii_bus functions
  *****************************************************************************/
-static int ftgmac100_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int ftgmac100_mdiobus_read(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum)
 {
 	struct net_device *netdev = bus->priv;
 	struct ftgmac100 *priv = netdev_priv(netdev);
@@ -901,7 +902,7 @@ static int ftgmac100_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 }
 
 static int ftgmac100_mdiobus_write(struct mii_bus *bus, int phy_addr,
-				   int regnum, u16 value)
+				   int devad, int regnum, u16 value)
 {
 	struct net_device *netdev = bus->priv;
 	struct ftgmac100 *priv = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 1124ce0..162f367 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -886,7 +886,8 @@ spin_unlock:
 		phy_print_status(phy_dev);
 }
 
-static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int devad,
+				int regnum)
 {
 	struct fec_enet_private *fep = bus->priv;
 	unsigned long time_left;
@@ -912,8 +913,8 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
 }
 
-static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
+static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+			int regnum, u16 value)
 {
 	struct fec_enet_private *fep = bus->priv;
 	unsigned long time_left;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
index 360a578..81a3fff 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
@@ -49,13 +49,14 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
 		in_be32(&fec->mii_data) & FEC_MII_DATA_DATAMSK : 0;
 }
 
-static int mpc52xx_fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int mpc52xx_fec_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int reg)
 {
 	return mpc52xx_fec_mdio_transfer(bus, phy_id, reg, FEC_MII_READ_FRAME);
 }
 
-static int mpc52xx_fec_mdio_write(struct mii_bus *bus, int phy_id, int reg,
-		u16 data)
+static int mpc52xx_fec_mdio_write(struct mii_bus *bus, int phy_id, int devad,
+				int reg, u16 data)
 {
 	return mpc52xx_fec_mdio_transfer(bus, phy_id, reg,
 		data | FEC_MII_WRITE_FRAME);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index e0e9d6c..b4ae560 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -49,7 +49,8 @@
 
 #define FEC_MII_LOOPS	10000
 
-static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
+static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int devad,
+				int location)
 {
 	struct fec_info* fec = bus->priv;
 	struct fec __iomem *fecp = fec->fecp;
@@ -72,7 +73,8 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int location)
 	return ret;
 }
 
-static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
+static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int devad,
+				int location, u16 val)
 {
 	struct fec_info* fec = bus->priv;
 	struct fec __iomem *fecp = fec->fecp;
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 52f4e8a..94b9e17 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -62,7 +62,7 @@ struct fsl_pq_mdio_priv {
  * controlling the external PHYs, for example.
  */
 int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
-		int regnum, u16 value)
+			int regnum, u16 value)
 {
 	/* Set the PHY address and the register address we want to write */
 	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
@@ -87,8 +87,8 @@ int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
  * and are always tied to the local mdio pins, which may not be the
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
-int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
-		int mii_id, int regnum)
+int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id,
+			int regnum)
 {
 	u16 value;
 
@@ -120,7 +120,8 @@ static struct fsl_pq_mdio __iomem *fsl_pq_mdio_get_regs(struct mii_bus *bus)
  * Write value to the PHY at mii_id at register regnum,
  * on the bus, waiting until the write is done before returning.
  */
-int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int devad, int regnum,
+			u16 value)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
@@ -132,7 +133,7 @@ int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
  * Read the bus for PHY at addr mii_id, register regnum, and
  * return the value.  Clears miimcom first.
  */
-int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int devad, int regnum)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
@@ -191,7 +192,7 @@ static int fsl_pq_mdio_find_free(struct mii_bus *new_bus)
 	for (i = PHY_MAX_ADDR; i > 0; i--) {
 		u32 phy_id;
 
-		if (get_phy_id(new_bus, i, &phy_id))
+		if (get_phy_id(new_bus, i, MDIO_DEVAD_NONE, &phy_id))
 			return -1;
 
 		if (phy_id == 0xffffffff)
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.h b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
index bd17a2a..4b5254c 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.h
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
@@ -41,11 +41,14 @@ struct fsl_pq_mdio {
 	u8 res4[2728];
 } __packed;
 
-int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
-int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+
+int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int devad, int regnum);
+int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int devad, int regnum,
+			u16 value);
 int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
-			  int regnum, u16 value);
-int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id, int regnum);
+			int regnum, u16 value);
+int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id,
+			int regnum);
 int __init fsl_pq_mdio_init(void);
 void fsl_pq_mdio_exit(void);
 void fsl_pq_mdio_bus_name(char *name, struct device_node *np);
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 6bb2b95..b5ae9d2 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -337,7 +337,8 @@ static const struct ethtool_ops ltq_etop_ethtool_ops = {
 };
 
 static int
-ltq_etop_mdio_wr(struct mii_bus *bus, int phy_addr, int phy_reg, u16 phy_data)
+ltq_etop_mdio_wr(struct mii_bus *bus, int phy_addr, int devad, int phy_reg,
+		u16 phy_data)
 {
 	u32 val = MDIO_REQUEST |
 		((phy_addr & MDIO_ADDR_MASK) << MDIO_ADDR_OFFSET) |
@@ -351,7 +352,7 @@ ltq_etop_mdio_wr(struct mii_bus *bus, int phy_addr, int phy_reg, u16 phy_data)
 }
 
 static int
-ltq_etop_mdio_rd(struct mii_bus *bus, int phy_addr, int phy_reg)
+ltq_etop_mdio_rd(struct mii_bus *bus, int phy_addr, int devad, int phy_reg)
 {
 	u32 val = MDIO_REQUEST | MDIO_READ |
 		((phy_addr & MDIO_ADDR_MASK) << MDIO_ADDR_OFFSET) |
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index f6821aa..87b8038 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1119,7 +1119,7 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 	return 0;
 }
 
-static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
+static int smi_bus_read(struct mii_bus *bus, int addr, int devad, int reg)
 {
 	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
@@ -1146,7 +1146,8 @@ static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
 	return ret & 0xffff;
 }
 
-static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
+static int smi_bus_write(struct mii_bus *bus, int addr, int devad, int reg,
+			u16 val)
 {
 	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index d17d062..84a4a36 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1302,7 +1302,8 @@ static int smi_wait_ready(struct pxa168_eth_private *pep)
 	return 0;
 }
 
-static int pxa168_smi_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int pxa168_smi_read(struct mii_bus *bus, int phy_addr, int devad,
+			   int regnum)
 {
 	struct pxa168_eth_private *pep = bus->priv;
 	int i = 0;
@@ -1326,8 +1327,8 @@ static int pxa168_smi_read(struct mii_bus *bus, int phy_addr, int regnum)
 	return val & 0xffff;
 }
 
-static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
-			    u16 value)
+static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int devad,
+			    int regnum, u16 value)
 {
 	struct pxa168_eth_private *pep = bus->priv;
 
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 1fc01ca..3ec419f 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -243,7 +243,8 @@ static void r6040_phy_write(void __iomem *ioaddr,
 	}
 }
 
-static int r6040_mdiobus_read(struct mii_bus *bus, int phy_addr, int reg)
+static int r6040_mdiobus_read(struct mii_bus *bus, int phy_addr, int devad,
+				int reg)
 {
 	struct net_device *dev = bus->priv;
 	struct r6040_private *lp = netdev_priv(dev);
@@ -253,7 +254,7 @@ static int r6040_mdiobus_read(struct mii_bus *bus, int phy_addr, int reg)
 }
 
 static int r6040_mdiobus_write(struct mii_bus *bus, int phy_addr,
-						int reg, u16 value)
+			int devad, int reg, u16 value)
 {
 	struct net_device *dev = bus->priv;
 	struct r6040_private *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index a7ff8ea..7430211 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -661,7 +661,7 @@ static int s6mii_busy(struct s6gmac *pd, int tmo)
 	return 0;
 }
 
-static int s6mii_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int s6mii_read(struct mii_bus *bus, int phy_addr, int devad, int regnum)
 {
 	struct s6gmac *pd = bus->priv;
 	s6mii_enable(pd);
@@ -677,7 +677,8 @@ static int s6mii_read(struct mii_bus *bus, int phy_addr, int regnum)
 	return (u16)readl(pd->reg + S6_GMAC_MACMIISTAT);
 }
 
-static int s6mii_write(struct mii_bus *bus, int phy_addr, int regnum, u16 value)
+static int s6mii_write(struct mii_bus *bus, int phy_addr, int devad,
+			int regnum, u16 value)
 {
 	struct s6gmac *pd = bus->priv;
 	s6mii_enable(pd);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index a3aa4c0..87ee880 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -441,7 +441,8 @@ static void smsc911x_mac_write(struct smsc911x_data *pdata,
 }
 
 /* Get a phy register */
-static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+				int regidx)
 {
 	struct smsc911x_data *pdata = (struct smsc911x_data *)bus->priv;
 	unsigned long flags;
@@ -477,8 +478,8 @@ out:
 }
 
 /* Set a phy register */
-static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 val)
+static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx, u16 val)
 {
 	struct smsc911x_data *pdata = (struct smsc911x_data *)bus->priv;
 	unsigned long flags;
@@ -709,11 +710,12 @@ static int smsc911x_phy_reset(struct smsc911x_data *pdata)
 	BUG_ON(!phy_dev->bus);
 
 	SMSC_TRACE(pdata, hw, "Performing PHY BCR Reset");
-	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, BMCR_RESET);
+	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MDIO_DEVAD_NONE,
+				MII_BMCR, BMCR_RESET);
 	do {
 		msleep(1);
 		temp = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
-			MII_BMCR);
+			MDIO_DEVAD_NONE, MII_BMCR);
 	} while ((i--) && (temp & BMCR_RESET));
 
 	if (temp & BMCR_RESET) {
@@ -761,8 +763,8 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 
 	for (i = 0; i < 10; i++) {
 		/* Set PHY to 10/FD, no ANEG, and loopback mode */
-		smsc911x_mii_write(phy_dev->bus, phy_dev->addr,	MII_BMCR,
-			BMCR_LOOPBACK | BMCR_FULLDPLX);
+		smsc911x_mii_write(phy_dev->bus, phy_dev->addr,	MDIO_DEVAD_NONE,
+			MII_BMCR, BMCR_LOOPBACK | BMCR_FULLDPLX);
 
 		/* Enable MAC tx/rx, FD */
 		spin_lock_irqsave(&pdata->mac_lock, flags);
@@ -790,7 +792,8 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 	spin_unlock_irqrestore(&pdata->mac_lock, flags);
 
 	/* Cancel PHY loopback mode */
-	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, 0);
+	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MDIO_DEVAD_NONE,
+			MII_BMCR, 0);
 
 	smsc911x_reg_write(pdata, TX_CFG, 0);
 	smsc911x_reg_write(pdata, RX_CFG, 0);
@@ -1759,7 +1762,8 @@ smsc911x_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 	}
 
 	for (i = 0; i <= 31; i++)
-		data[j++] = smsc911x_mii_read(phy_dev->bus, phy_dev->addr, i);
+		data[j++] = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
+					MDIO_DEVAD_NONE, i);
 }
 
 static void smsc911x_eeprom_enable_access(struct smsc911x_data *pdata)
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 4f15680..3a08ef0 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -128,7 +128,8 @@ static inline void smsc9420_pci_flush_write(struct smsc9420_pdata *pd)
 	smsc9420_reg_read(pd, ID_REV);
 }
 
-static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+				int regidx)
 {
 	struct smsc9420_pdata *pd = (struct smsc9420_pdata *)bus->priv;
 	unsigned long flags;
@@ -165,8 +166,8 @@ out:
 	return reg;
 }
 
-static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 val)
+static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx, u16 val)
 {
 	struct smsc9420_pdata *pd = (struct smsc9420_pdata *)bus->priv;
 	unsigned long flags;
@@ -329,7 +330,8 @@ smsc9420_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 		return;
 
 	for (i = 0; i <= 31; i++)
-		data[j++] = smsc9420_mii_read(phy_dev->bus, phy_dev->addr, i);
+		data[j++] = smsc9420_mii_read(phy_dev->bus, phy_dev->addr,
+				MDIO_DEVAD_NONE, i);
 }
 
 static void smsc9420_eeprom_enable_access(struct smsc9420_pdata *pd)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 9c3b9d5..36cdb1b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -38,13 +38,15 @@
  * stmmac_mdio_read
  * @bus: points to the mii_bus structure
  * @phyaddr: MII addr reg bits 15-11
+ * @devad: unused
  * @phyreg: MII addr reg bits 10-6
  * Description: it reads data from the MII register from within the phy device.
  * For the 7111 GMAC, we must set the bit 0 in the MII address register while
  * accessing the PHY registers.
  * Fortunately, it seems this has no drawback for the 7109 MAC.
  */
-static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
+static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int devad,
+				int phyreg)
 {
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
@@ -70,12 +72,13 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
  * stmmac_mdio_write
  * @bus: points to the mii_bus structure
  * @phyaddr: MII addr reg bits 15-11
+ * @devad: unused
  * @phyreg: MII addr reg bits 10-6
  * @phydata: phy data
  * Description: it writes the data into the MII register from within the device.
  */
-static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
-			     u16 phydata)
+static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int devad,
+				int phyreg, u16 phydata)
 {
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index aaac0c7..c89eac5 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -272,7 +272,7 @@ static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
 	printk("\n");
 }
 
-static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int devad, int reg)
 {
 	u32 val;
 
@@ -285,7 +285,7 @@ static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	return MDIO_DATA(val);
 }
 
-static int cpmac_mdio_write(struct mii_bus *bus, int phy_id,
+static int cpmac_mdio_write(struct mii_bus *bus, int phy_id, int devad,
 			    int reg, u16 val)
 {
 	while (cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0)) & MDIO_BUSY)
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 7615040..92ed777 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -199,7 +199,8 @@ static inline int wait_for_idle(struct davinci_mdio_data *data)
 	return -ETIMEDOUT;
 }
 
-static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
+static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int phy_reg)
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 reg;
@@ -244,7 +245,7 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 }
 
 static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
-			      int phy_reg, u16 phy_data)
+			      int devad, int phy_reg, u16 phy_data)
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 reg;
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..2b166f7 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -501,7 +501,7 @@ static void	panic_queues(struct net_device *dev);
 
 static void tc35815_restart_work(struct work_struct *work);
 
-static int tc_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int tc_mdio_read(struct mii_bus *bus, int mii_id, int devad, int regnum)
 {
 	struct net_device *dev = bus->priv;
 	struct tc35815_regs __iomem *tr =
@@ -518,7 +518,8 @@ static int tc_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return tc_readl(&tr->MD_Data) & 0xffff;
 }
 
-static int tc_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 val)
+static int tc_mdio_write(struct mii_bus *bus, int mii_id, int devad, int regnum,
+			u16 val)
 {
 	struct net_device *dev = bus->priv;
 	struct tc35815_regs __iomem *tr =
diff --git a/drivers/net/ethernet/xilinx/ll_temac_mdio.c b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
index 8cf9d4f..a9ddc90 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_mdio.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
@@ -19,7 +19,7 @@
 /* ---------------------------------------------------------------------
  * MDIO Bus functions
  */
-static int temac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int temac_mdio_read(struct mii_bus *bus, int phy_id, int devad, int reg)
 {
 	struct temac_local *lp = bus->priv;
 	u32 rc;
@@ -38,7 +38,8 @@ static int temac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	return rc;
 }
 
-static int temac_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
+static int temac_mdio_write(struct mii_bus *bus, int phy_id, int devad, int reg,
+				u16 val)
 {
 	struct temac_local *lp = bus->priv;
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 8018d7d..36a5b1b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -741,6 +741,7 @@ static int xemaclite_mdio_wait(struct net_local *lp)
  * xemaclite_mdio_read - Read from a given MII management register
  * @bus:	the mii_bus struct
  * @phy_id:	the phy address
+ * @devad:	unused
  * @reg:	register number to read from
  *
  * This function waits till the device is ready to accept a new MDIO
@@ -749,7 +750,8 @@ static int xemaclite_mdio_wait(struct net_local *lp)
  *
  * Return:	Value read from the MII management register
  */
-static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int reg)
 {
 	struct net_local *lp = bus->priv;
 	u32 ctrl_reg;
@@ -785,14 +787,15 @@ static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
  * xemaclite_mdio_write - Write to a given MII management register
  * @bus:	the mii_bus struct
  * @phy_id:	the phy address
+ * @devad:	unused
  * @reg:	register number to write to
  * @val:	value to write to the register number specified by reg
  *
  * This function waits till the device is ready to accept a new MDIO
  * request and then writes the val to the MDIO Write Data register.
  */
-static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
-				u16 val)
+static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int devad,
+				int reg, u16 val)
 {
 	struct net_local *lp = bus->priv;
 	u32 ctrl_reg;
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index ec96d91..2f5d9cb 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -473,7 +473,8 @@ static int ixp4xx_mdio_cmd(struct mii_bus *bus, int phy_id, int location,
 		((__raw_readl(&mdio_regs->mdio_status[1]) & 0xFF) << 8);
 }
 
-static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int location)
+static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+			    int location)
 {
 	unsigned long flags;
 	int ret;
@@ -488,8 +489,8 @@ static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int location)
 	return ret;
 }
 
-static int ixp4xx_mdio_write(struct mii_bus *bus, int phy_id, int location,
-			     u16 val)
+static int ixp4xx_mdio_write(struct mii_bus *bus, int phy_id, int devad,
+			     int location, u16 val)
 {
 	unsigned long flags;
 	int ret;
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 1fa4d73..31f621e 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -115,7 +115,8 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	return 0;
 }
 
-static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
+static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int reg_num)
 {
 	struct fixed_mdio_bus *fmb = bus->priv;
 	struct fixed_phy *fp;
@@ -139,7 +140,7 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
 }
 
 static int fixed_mdio_write(struct mii_bus *bus, int phy_id, int reg_num,
-			    u16 val)
+			    int devad, u16 val)
 {
 	return 0;
 }
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index d66bd8d..5228d9c 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -49,36 +49,41 @@ static int ip175c_config_init(struct phy_device *phydev)
 	if (full_reset_performed == 0) {
 
 		/* master reset */
-		err = mdiobus_write(phydev->bus, 30, 0, 0x175c);
+		err = mdiobus_write(phydev->bus, 30, MDIO_DEVAD_NONE, 0,
+						0x175c);
 		if (err < 0)
 			return err;
 
 		/* ensure no bus delays overlap reset period */
-		err = mdiobus_read(phydev->bus, 30, 0);
+		err = mdiobus_read(phydev->bus, 30, MDIO_DEVAD_NONE, 0);
 
 		/* data sheet specifies reset period is 2 msec */
 		mdelay(2);
 
 		/* enable IP175C mode */
-		err = mdiobus_write(phydev->bus, 29, 31, 0x175c);
+		err = mdiobus_write(phydev->bus, 29, MDIO_DEVAD_NONE, 31,
+						0x175c);
 		if (err < 0)
 			return err;
 
 		/* Set MII0 speed and duplex (in PHY mode) */
-		err = mdiobus_write(phydev->bus, 29, 22, 0x420);
+		err = mdiobus_write(phydev->bus, 29, MDIO_DEVAD_NONE, 22,
+						0x420);
 		if (err < 0)
 			return err;
 
 		/* reset switch ports */
 		for (i = 0; i < 5; i++) {
 			err = mdiobus_write(phydev->bus, i,
-					    MII_BMCR, BMCR_RESET);
+						 MDIO_DEVAD_NONE,
+						 MII_BMCR, BMCR_RESET);
 			if (err < 0)
 				return err;
 		}
 
 		for (i = 0; i < 5; i++)
-			err = mdiobus_read(phydev->bus, i, MII_BMCR);
+			err = mdiobus_read(phydev->bus, i, MDIO_DEVAD_NONE,
+						MII_BMCR);
 
 		mdelay(2);
 
diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 6539189..2f6f02e 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -152,7 +152,7 @@ static int mdiobb_cmd_addr(struct mdiobb_ctrl *ctrl, int phy, u32 addr)
 	return dev_addr;
 }
 
-static int mdiobb_read(struct mii_bus *bus, int phy, int reg)
+static int mdiobb_read(struct mii_bus *bus, int phy, int devad, int reg)
 {
 	struct mdiobb_ctrl *ctrl = bus->priv;
 	int ret, i;
@@ -181,7 +181,8 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int reg)
 	return ret;
 }
 
-static int mdiobb_write(struct mii_bus *bus, int phy, int reg, u16 val)
+static int mdiobb_write(struct mii_bus *bus, int phy, int devad, int reg,
+			u16 val)
 {
 	struct mdiobb_ctrl *ctrl = bus->priv;
 
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index bd12ba9..356973d 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -24,7 +24,8 @@ struct octeon_mdiobus {
 	int phy_irq[PHY_MAX_ADDR];
 };
 
-static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int regnum)
+static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int devad,
+				int regnum)
 {
 	struct octeon_mdiobus *p = bus->priv;
 	union cvmx_smix_cmd smi_cmd;
@@ -52,7 +53,7 @@ static int octeon_mdiobus_read(struct mii_bus *bus, int phy_id, int regnum)
 		return -EIO;
 }
 
-static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
+static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id, int devad
 				int regnum, u16 val)
 {
 	struct octeon_mdiobus *p = bus->priv;
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6c58da2..a6fa970 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -208,14 +208,14 @@ EXPORT_SYMBOL(mdiobus_scan);
  * because the bus read/write functions may wait for an interrupt
  * to conclude the operation.
  */
-int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
+int mdiobus_read(struct mii_bus *bus, int addr, int devad, u16 regnum)
 {
 	int retval;
 
 	BUG_ON(in_interrupt());
 
 	mutex_lock(&bus->mdio_lock);
-	retval = bus->read(bus, addr, regnum);
+	retval = bus->read(bus, addr, devad, regnum);
 	mutex_unlock(&bus->mdio_lock);
 
 	return retval;
@@ -233,14 +233,14 @@ EXPORT_SYMBOL(mdiobus_read);
  * because the bus read/write functions may wait for an interrupt
  * to conclude the operation.
  */
-int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val)
+int mdiobus_write(struct mii_bus *bus, int addr, int devad, u16 regnum, u16 val)
 {
 	int err;
 
 	BUG_ON(in_interrupt());
 
 	mutex_lock(&bus->mdio_lock);
-	err = bus->write(bus, addr, regnum, val);
+	err = bus->write(bus, addr, devad, regnum, val);
 	mutex_unlock(&bus->mdio_lock);
 
 	return err;
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3cbda08..00f5cfe 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -322,7 +322,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
 
 	case SIOCGMIIREG:
 		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
-						 mii_data->reg_num);
+						MDIO_DEVAD_NONE,
+						mii_data->reg_num);
 		break;
 
 	case SIOCSMIIREG:
@@ -354,7 +355,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		}
 
 		mdiobus_write(phydev->bus, mii_data->phy_id,
-			      mii_data->reg_num, val);
+				MDIO_DEVAD_NONE, mii_data->reg_num, val);
 
 		if (mii_data->reg_num == MII_BMCR &&
 		    val & BMCR_RESET &&
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 83a5a5a..22281d4 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -4,9 +4,11 @@
  * Framework for finding and configuring PHYs.
  * Also contains generic PHY driver
  *
+ * 10G PHY Driver support mostly appropriated from drivers/net/mdio.c
+ *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004-2006, 2008-2011 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -29,6 +31,7 @@
 #include <linux/module.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/mdio.h>
 #include <linux/phy.h>
 
 #include <asm/io.h>
@@ -207,13 +210,13 @@ static struct phy_device* phy_device_create(struct mii_bus *bus,
  * Description: Reads the ID registers of the PHY at @addr on the
  *   @bus, stores it in @phy_id and returns zero on success.
  */
-int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
+int get_phy_id(struct mii_bus *bus, int addr, int devad, u32 *phy_id)
 {
 	int phy_reg;
 
 	/* Grab the bits from PHYIR1, and put them
 	 * in the upper half */
-	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
+	phy_reg = mdiobus_read(bus, addr, devad, MII_PHYSID1);
 
 	if (phy_reg < 0)
 		return -EIO;
@@ -221,7 +224,7 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 	*phy_id = (phy_reg & 0xffff) << 16;
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = mdiobus_read(bus, addr, MII_PHYSID2);
+	phy_reg = mdiobus_read(bus, addr, devad, MII_PHYSID2);
 
 	if (phy_reg < 0)
 		return -EIO;
@@ -242,21 +245,31 @@ EXPORT_SYMBOL(get_phy_id);
  */
 struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 {
-	struct phy_device *dev = NULL;
-	u32 phy_id;
+	u32 phy_id = 0x1fffffff;
+	int i;
 	int r;
 
-	r = get_phy_id(bus, addr, &phy_id);
+	/* Try Standard (ie Clause 22) access */
+	r = get_phy_id(bus, addr, MDIO_DEVAD_NONE, &phy_id);
 	if (r)
 		return ERR_PTR(r);
 
-	/* If the phy_id is mostly Fs, there is no device there */
-	if ((phy_id & 0x1fffffff) == 0x1fffffff)
-		return NULL;
+	/* If the PHY ID is mostly f's, we didn't find anything */
+	if ((phy_id & 0x1fffffff) != 0x1fffffff)
+		return phy_device_create(bus, addr, phy_id);
 
-	dev = phy_device_create(bus, addr, phy_id);
+	/* Otherwise we have to try Clause 45 */
+	for (i = 1; i < 5; i++) {
+		r = get_phy_id(bus, addr, i, &phy_id);
+		if (r)
+			return ERR_PTR(r);
 
-	return dev;
+		/* If the phy_id is mostly Fs, there is no device there */
+		if ((phy_id & 0x1fffffff) != 0x1fffffff)
+			break;
+	}
+
+	return phy_device_create(bus, addr, phy_id);
 }
 EXPORT_SYMBOL(get_phy_device);
 
@@ -424,6 +437,11 @@ int phy_init_hw(struct phy_device *phydev)
 	return phydev->drv->config_init(phydev);
 }
 
+static struct phy_driver *generic_for_interface(phy_interface_t interface)
+{
+	return &genphy_driver;
+}
+
 /**
  * phy_attach_direct - attach a network device to a given PHY device pointer
  * @dev: network device to attach
@@ -433,8 +451,8 @@ int phy_init_hw(struct phy_device *phydev)
  *
  * Description: Called by drivers to attach to a particular PHY
  *     device. The phy_device is found, and properly hooked up
- *     to the phy_driver.  If no driver is attached, then the
- *     genphy_driver is used.  The phy_device is given a ptr to
+ *     to the phy_driver.  If no driver is attached, then a
+ *     generic driver is used.  The phy_device is given a ptr to
  *     the attaching device, and given a callback for link status
  *     change.  The phy_device is returned to the attaching driver.
  */
@@ -447,7 +465,9 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver. */
 	if (NULL == d->driver) {
-		d->driver = &genphy_driver.driver;
+		int err;
+
+		d->driver = generic_for_interface(interface);
 
 		err = d->driver->probe(d);
 		if (err >= 0)
@@ -529,7 +549,7 @@ void phy_detach(struct phy_device *phydev)
 	 * was using the generic driver), we unbind the device
 	 * from the generic driver so that there's a chance a
 	 * real driver could be loaded */
-	if (phydev->dev.driver == &genphy_driver.driver)
+	if (phydev->dev.driver == generic_for_interface(phydev->interface))
 		device_release_driver(&phydev->dev);
 }
 EXPORT_SYMBOL(phy_detach);
@@ -640,7 +660,6 @@ static int genphy_setup_forced(struct phy_device *phydev)
 	return err;
 }
 
-
 /**
  * genphy_restart_aneg - Enable and Restart Autonegotiation
  * @phydev: target phy_device struct
@@ -665,7 +684,6 @@ int genphy_restart_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
-
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
  * @phydev: target phy_device struct
@@ -882,6 +900,7 @@ static int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+
 int genphy_suspend(struct phy_device *phydev)
 {
 	int value;
@@ -1022,7 +1041,7 @@ static struct phy_driver genphy_driver = {
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= {.owner= THIS_MODULE, },
+	.driver		= {.owner = THIS_MODULE, },
 };
 
 static int __init phy_init(void)
@@ -1035,7 +1054,12 @@ static int __init phy_init(void)
 
 	rc = phy_driver_register(&genphy_driver);
 	if (rc)
-		mdio_bus_exit();
+		goto genphy_register_failed;
+
+	return rc;
+
+genphy_register_failed:
+	mdio_bus_exit();
 
 	return rc;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 54fc413..ae1fdd8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -6,7 +6,7 @@
  *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004, 2009-2011 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -22,6 +22,7 @@
 #include <linux/device.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/mdio.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
@@ -65,6 +66,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_RGMII_TXID,
 	PHY_INTERFACE_MODE_RTBI,
 	PHY_INTERFACE_MODE_SMII,
+	PHY_INTERFACE_MODE_XGMII
 } phy_interface_t;
 
 
@@ -96,8 +98,10 @@ struct mii_bus {
 	const char *name;
 	char id[MII_BUS_ID_SIZE];
 	void *priv;
-	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
-	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
+	int (*read)(struct mii_bus *bus, int port_addr, int dev_addr,
+			int regnum);
+	int (*write)(struct mii_bus *bus, int port_addr, int dev_addr,
+			int regnum, u16 val);
 	int (*reset)(struct mii_bus *bus);
 
 	/*
@@ -134,8 +138,9 @@ int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
-int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
-int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
+int mdiobus_read(struct mii_bus *bus, int addr, int devad, u16 regnum);
+int mdiobus_write(struct mii_bus *bus, int addr, int devad,
+			u16 regnum, u16 val);
 
 
 #define PHY_INTERRUPT_DISABLED	0x0
@@ -307,6 +312,7 @@ struct phy_device {
 	/* See mii.h for more info */
 	u32 supported;
 	u32 advertising;
+	u32 mmds;
 
 	int autoneg;
 
@@ -443,6 +449,21 @@ struct phy_fixup {
 };
 
 /**
+ * is_10g_interface - Distinguishes 10G from 10/100/1000
+ * @interface: PHY interface type
+ *
+ * Returns true if the passed interface is capable of 10G,
+ * and therefore indicates the need for Clause-45-style
+ * MDIO transactions.
+ *
+ * For now, XGMII is the only 10G interface
+ */
+static inline bool is_10g_interface(phy_interface_t interface)
+{
+	return interface == PHY_INTERFACE_MODE_XGMII;
+}
+
+/**
  * phy_read - Convenience function for reading a given PHY register
  * @phydev: the phy_device struct
  * @regnum: register number to read
@@ -453,7 +474,22 @@ struct phy_fixup {
  */
 static inline int phy_read(struct phy_device *phydev, u32 regnum)
 {
-	return mdiobus_read(phydev->bus, phydev->addr, regnum);
+	return mdiobus_read(phydev->bus, phydev->addr, MDIO_DEVAD_NONE, regnum);
+}
+
+/**
+ * phy45_read - Convenience function for reading a given port/dev/reg address
+ * @phydev: The phy_device struct
+ * @devad: The device address to read
+ * @regnum: The register number to read
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+static inline int phy45_read(struct phy_device *phydev, int devad, u16 regnum)
+{
+	return mdiobus_read(phydev->bus, phydev->addr, devad, regnum);
 }
 
 /**
@@ -468,10 +504,28 @@ static inline int phy_read(struct phy_device *phydev, u32 regnum)
  */
 static inline int phy_write(struct phy_device *phydev, u32 regnum, u16 val)
 {
-	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
+	return mdiobus_write(phydev->bus, phydev->addr, MDIO_DEVAD_NONE, regnum,
+				val);
+}
+
+/**
+ * phy45_write - Convenience function for writing a given port/dev/reg
+ * @phydev: the phy_device struct
+ * @devad: the device addr
+ * @regnum: register number to write
+ * @val: value to write to @regnum
+ *
+ * NOTE: MUST NOT be called from interrupt context,
+ * because the bus read/write functions may wait for an interrupt
+ * to conclude the operation.
+ */
+static inline int phy45_write(struct phy_device *phydev, u16 regnum,
+				int devad, u16 val)
+{
+	return mdiobus_write(phydev->bus, phydev->addr, devad, regnum, val);
 }
 
-int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
+int get_phy_id(struct mii_bus *bus, int addr, int devad, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_device_register(struct phy_device *phy);
 int phy_init_hw(struct phy_device *phydev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 56cf9b8..8bcb864 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -15,7 +15,7 @@
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
-static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
+static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int devad, int reg)
 {
 	struct dsa_switch *ds = bus->priv;
 
@@ -25,7 +25,8 @@ static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 	return 0xffff;
 }
 
-static int dsa_slave_phy_write(struct mii_bus *bus, int addr, int reg, u16 val)
+static int dsa_slave_phy_write(struct mii_bus *bus, int addr, int devad,
+				int reg, u16 val)
 {
 	struct dsa_switch *ds = bus->priv;
 
-- 
1.7.3.4
