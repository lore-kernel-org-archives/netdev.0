From: Andy Fleming <afleming@freescale.com>
Subject: [RFC 1/2] phylib: Convert MDIO and PHY Lib drivers to support 10G
Date: Thu, 22 Apr 2010 23:38:16 -0500
Message-ID: <1271997497-6896-2-git-send-email-afleming@freescale.com>
References: <1271997497-6896-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:56145 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab0DWEiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 00:38:20 -0400
In-Reply-To: <1271997497-6896-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10G MDIO is a totally different protocol (clause 45 of 802.3).
Supporting this new protocol requires a couple of changes:

* Add a new parameter to the mdiobus_read functions to specify the
  "device address" inside the PHY.
* Add a phy45_read command which takes advantage of that new parameter
* Add a generic PHY driver for 10G PHYs
* Convert all of the existing drivers to use the new format

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 Documentation/networking/phy.txt          |   13 ++-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |    6 +-
 drivers/net/arm/ixp4xx_eth.c              |    7 +-
 drivers/net/au1000_eth.c                  |    7 +-
 drivers/net/bcm63xx_enet.c                |    4 +-
 drivers/net/bfin_mac.c                    |    7 +-
 drivers/net/cpmac.c                       |    4 +-
 drivers/net/davinci_emac.c                |    5 +-
 drivers/net/dnet.c                        |    7 +-
 drivers/net/ethoc.c                       |    5 +-
 drivers/net/fec.c                         |    7 +-
 drivers/net/fec_mpc52xx_phy.c             |    7 +-
 drivers/net/fs_enet/mii-fec.c             |    6 +-
 drivers/net/fsl_pq_mdio.c                 |   11 +-
 drivers/net/fsl_pq_mdio.h                 |   11 ++-
 drivers/net/greth.c                       |    5 +-
 drivers/net/ll_temac_mdio.c               |    5 +-
 drivers/net/macb.c                        |    7 +-
 drivers/net/mv643xx_eth.c                 |    5 +-
 drivers/net/phy/fixed.c                   |    5 +-
 drivers/net/phy/icplus.c                  |   12 +-
 drivers/net/phy/mdio-bitbang.c            |    5 +-
 drivers/net/phy/mdio-octeon.c             |    5 +-
 drivers/net/phy/mdio_bus.c                |    8 +-
 drivers/net/phy/phy_device.c              |  164 ++++++++++++++++++++++++++---
 drivers/net/s6gmac.c                      |    5 +-
 drivers/net/sb1250-mac.c                  |   14 ++-
 drivers/net/smsc911x.c                    |   19 ++--
 drivers/net/smsc9420.c                    |    9 +-
 drivers/net/stmmac/stmmac_mdio.c          |    9 +-
 drivers/net/tc35815.c                     |    5 +-
 drivers/net/tg3.c                         |    5 +-
 drivers/net/xilinx_emaclite.c             |    9 +-
 include/linux/phy.h                       |   53 ++++++++--
 34 files changed, 329 insertions(+), 127 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 88bb71b..8729cac 100644
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
index 0f881f6..ce9764c 100644
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
 
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 7800d7d..12cf9e7 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -298,7 +298,8 @@ static int ixp4xx_mdio_cmd(struct mii_bus *bus, int phy_id, int location,
 		((__raw_readl(&mdio_regs->mdio_status[1]) & 0xFF) << 8);
 }
 
-static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int location)
+static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int location)
 {
 	unsigned long flags;
 	int ret;
@@ -313,8 +314,8 @@ static int ixp4xx_mdio_read(struct mii_bus *bus, int phy_id, int location)
 	return ret;
 }
 
-static int ixp4xx_mdio_write(struct mii_bus *bus, int phy_id, int location,
-			     u16 val)
+static int ixp4xx_mdio_write(struct mii_bus *bus, int phy_id, int devad,
+			     int location, u16 val)
 {
 	unsigned long flags;
 	int ret;
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7abb2c8..e755d19 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -232,7 +232,8 @@ static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 	*mii_control_reg = mii_control;
 }
 
-static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum)
 {
 	/* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
 	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus) */
@@ -243,8 +244,8 @@ static int au1000_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 	return au1000_mdio_read(dev, phy_addr, regnum);
 }
 
-static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
-				u16 value)
+static int au1000_mdiobus_write(struct mii_bus *bus, int phy_addr, int devad,
+				int regnum, u16 value)
 {
 	struct net_device *const dev = bus->priv;
 
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 9a8bdea..510bc04 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -139,7 +139,7 @@ static int bcm_enet_mdio_write(struct bcm_enet_priv *priv, int mii_id,
  * MII read callback from phylib
  */
 static int bcm_enet_mdio_read_phylib(struct mii_bus *bus, int mii_id,
-				     int regnum)
+				     int devad, int regnum)
 {
 	return bcm_enet_mdio_read(bus->priv, mii_id, regnum);
 }
@@ -148,7 +148,7 @@ static int bcm_enet_mdio_read_phylib(struct mii_bus *bus, int mii_id,
  * MII write callback from phylib
  */
 static int bcm_enet_mdio_write_phylib(struct mii_bus *bus, int mii_id,
-				      int regnum, u16 value)
+				      int devad, int regnum, u16 value)
 {
 	return bcm_enet_mdio_write(bus->priv, mii_id, regnum, value);
 }
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c488cea..a57a7e3 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -270,7 +270,8 @@ static void bfin_mdio_poll(void)
 }
 
 /* Read an off-chip register in a PHY through the MDC/MDIO port */
-static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, 
+				int devad, int regnum)
 {
 	bfin_mdio_poll();
 
@@ -285,8 +286,8 @@ static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 }
 
 /* Write an off-chip register in a PHY through the MDC/MDIO port */
-static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
-			      u16 value)
+static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int devad,
+			      int regnum, u16 value)
 {
 	bfin_mdio_poll();
 
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index bdfff78..5f9db1a 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -271,7 +271,7 @@ static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
 	printk("\n");
 }
 
-static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int devad, int reg)
 {
 	u32 val;
 
@@ -285,7 +285,7 @@ static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 }
 
 static int cpmac_mdio_write(struct mii_bus *bus, int phy_id,
-			    int reg, u16 val)
+			    int devad, int reg, u16 val)
 {
 	while (cpmac_read(bus->priv, CPMAC_MDIO_ACCESS(0)) & MDIO_BUSY)
 		cpu_relax();
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 1f9df5c..9dea3c7 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2241,7 +2241,8 @@ void emac_poll_controller(struct net_device *ndev)
 		while ((emac_mdio_read((MDIO_USERACCESS(0))) &\
 			MDIO_USERACCESS_GO) != 0)
 
-static int emac_mii_read(struct mii_bus *bus, int phy_id, int phy_reg)
+static int emac_mii_read(struct mii_bus *bus, int phy_id, int devad,
+			int phy_reg)
 {
 	unsigned int phy_data = 0;
 	unsigned int phy_control;
@@ -2264,7 +2265,7 @@ static int emac_mii_read(struct mii_bus *bus, int phy_id, int phy_reg)
 }
 
 static int emac_mii_write(struct mii_bus *bus, int phy_id,
-			  int phy_reg, u16 phy_data)
+			  int devad, int phy_reg, u16 phy_data)
 {
 
 	unsigned int control;
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index d51a83e..a5227c8 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -99,7 +99,8 @@ static void __devinit dnet_get_hwaddr(struct dnet *bp)
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 }
 
-static int dnet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int dnet_mdio_read(struct mii_bus *bus, int mii_id, int devad,
+			int regnum)
 {
 	struct dnet *bp = bus->priv;
 	u16 value;
@@ -131,8 +132,8 @@ static int dnet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return value;
 }
 
-static int dnet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
+static int dnet_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+			int regnum, u16 value)
 {
 	struct dnet *bp = bus->priv;
 	u16 tmp;
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6bd03c8..d87da8f 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -564,7 +564,7 @@ static int ethoc_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
+static int ethoc_mdio_read(struct mii_bus *bus, int phy, int devad, int reg)
 {
 	unsigned long timeout = jiffies + ETHOC_MII_TIMEOUT;
 	struct ethoc *priv = bus->priv;
@@ -587,7 +587,8 @@ static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
 	return -EBUSY;
 }
 
-static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
+static int ethoc_mdio_write(struct mii_bus *bus, int phy, int devad,
+				int reg, u16 val)
 {
 	unsigned long timeout = jiffies + ETHOC_MII_TIMEOUT;
 	struct ethoc *priv = bus->priv;
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 2b1651a..cb09e7c 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -611,7 +611,8 @@ spin_unlock:
 /*
  * NOTE: a MII transaction is during around 25 us, so polling it...
  */
-static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int devad,
+				int regnum)
 {
 	struct fec_enet_private *fep = bus->priv;
 	int timeout = FEC_MII_TIMEOUT;
@@ -640,8 +641,8 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
 }
 
-static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
+static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+				int regnum, u16 value)
 {
 	struct fec_enet_private *fep = bus->priv;
 	int timeout = FEC_MII_TIMEOUT;
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index 7658a08..af52b5a 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -50,13 +50,14 @@ static int mpc52xx_fec_mdio_transfer(struct mii_bus *bus, int phy_id,
 		in_be32(&priv->regs->mii_data) & FEC_MII_DATA_DATAMSK : 0;
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
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 5944b65..2d02356 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
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
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d5160ed..e19a660 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -61,7 +61,7 @@ struct fsl_pq_mdio_priv {
  * controlling the external PHYs, for example.
  */
 int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
-		int regnum, u16 value)
+			int regnum, u16 value)
 {
 	/* Set the PHY address and the register address we want to write */
 	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
@@ -86,8 +86,8 @@ int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
  * and are always tied to the local mdio pins, which may not be the
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
-int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
-		int mii_id, int regnum)
+int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id,
+			int regnum)
 {
 	u16 value;
 
@@ -119,7 +119,8 @@ static struct fsl_pq_mdio __iomem *fsl_pq_mdio_get_regs(struct mii_bus *bus)
  * Write value to the PHY at mii_id at register regnum,
  * on the bus, waiting until the write is done before returning.
  */
-int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int devad, int regnum,
+			u16 value)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
@@ -131,7 +132,7 @@ int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
  * Read the bus for PHY at addr mii_id, register regnum, and
  * return the value.  Clears miimcom first.
  */
-int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int devad, int regnum)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
diff --git a/drivers/net/fsl_pq_mdio.h b/drivers/net/fsl_pq_mdio.h
index 1f7d865..48328eb 100644
--- a/drivers/net/fsl_pq_mdio.h
+++ b/drivers/net/fsl_pq_mdio.h
@@ -41,11 +41,14 @@ struct fsl_pq_mdio {
 	u8 res4[2728];
 } __attribute__ ((packed));
 
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
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index fd491e4..230ad75 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1169,7 +1169,7 @@ static inline int wait_for_mdio(struct greth_private *greth)
 	return 1;
 }
 
-static int greth_mdio_read(struct mii_bus *bus, int phy, int reg)
+static int greth_mdio_read(struct mii_bus *bus, int phy, int devad, int reg)
 {
 	struct greth_private *greth = bus->priv;
 	int data;
@@ -1191,7 +1191,8 @@ static int greth_mdio_read(struct mii_bus *bus, int phy, int reg)
 	}
 }
 
-static int greth_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
+static int greth_mdio_write(struct mii_bus *bus, int phy, int devad, int reg,
+				u16 val)
 {
 	struct greth_private *greth = bus->priv;
 
diff --git a/drivers/net/ll_temac_mdio.c b/drivers/net/ll_temac_mdio.c
index 5ae28c9..c02d5a5 100644
--- a/drivers/net/ll_temac_mdio.c
+++ b/drivers/net/ll_temac_mdio.c
@@ -18,7 +18,7 @@
 /* ---------------------------------------------------------------------
  * MDIO Bus functions
  */
-static int temac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int temac_mdio_read(struct mii_bus *bus, int phy_id, int devad, int reg)
 {
 	struct temac_local *lp = bus->priv;
 	u32 rc;
@@ -37,7 +37,8 @@ static int temac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	return rc;
 }
 
-static int temac_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
+static int temac_mdio_write(struct mii_bus *bus, int phy_id, int devad, int reg,
+				u16 val)
 {
 	struct temac_local *lp = bus->priv;
 
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index cf7debc..c9b5cb4 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -88,7 +88,8 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	}
 }
 
-static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int macb_mdio_read(struct mii_bus *bus, int mii_id, int devad,
+				int regnum)
 {
 	struct macb *bp = bus->priv;
 	int value;
@@ -108,8 +109,8 @@ static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return value;
 }
 
-static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
+static int macb_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+				int regnum, u16 value)
 {
 	struct macb *bp = bus->priv;
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4ee9d04..0c3280f 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1112,7 +1112,7 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 	return 0;
 }
 
-static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
+static int smi_bus_read(struct mii_bus *bus, int addr, int devad, int reg)
 {
 	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
@@ -1139,7 +1139,8 @@ static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
 	return ret & 0xffff;
 }
 
-static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
+static int smi_bus_write(struct mii_bus *bus, int addr, int devad, int reg,
+			u16 val)
 {
 	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
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
index 439adaf..71ddc27 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -42,36 +42,36 @@ static int ip175c_config_init(struct phy_device *phydev)
 	if (full_reset_performed == 0) {
 
 		/* master reset */
-		err = phydev->bus->write(phydev->bus, 30, 0, 0x175c);
+		err = phydev->bus->write(phydev->bus, 30, 0, 0, 0x175c);
 		if (err < 0)
 			return err;
 
 		/* ensure no bus delays overlap reset period */
-		err = phydev->bus->read(phydev->bus, 30, 0);
+		err = phydev->bus->read(phydev->bus, 30, 0, 0);
 
 		/* data sheet specifies reset period is 2 msec */
 		mdelay(2);
 
 		/* enable IP175C mode */
-		err = phydev->bus->write(phydev->bus, 29, 31, 0x175c);
+		err = phydev->bus->write(phydev->bus, 29, 0, 31, 0x175c);
 		if (err < 0)
 			return err;
 
 		/* Set MII0 speed and duplex (in PHY mode) */
-		err = phydev->bus->write(phydev->bus, 29, 22, 0x420);
+		err = phydev->bus->write(phydev->bus, 29, 0, 22, 0x420);
 		if (err < 0)
 			return err;
 
 		/* reset switch ports */
 		for (i = 0; i < 5; i++) {
-			err = phydev->bus->write(phydev->bus, i,
+			err = phydev->bus->write(phydev->bus, i, 0,
 						 MII_BMCR, BMCR_RESET);
 			if (err < 0)
 				return err;
 		}
 
 		for (i = 0; i < 5; i++)
-			err = phydev->bus->read(phydev->bus, i, MII_BMCR);
+			err = phydev->bus->read(phydev->bus, i, 0, MII_BMCR);
 
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
index a872aea..2bb2f7f 100644
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
index 6a6b819..5c7df03 100644
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
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1a99bb2..c061e99 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -6,7 +6,7 @@
  *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004-2006, 2008-2009 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -29,6 +29,7 @@
 #include <linux/module.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/mdio.h>
 #include <linux/phy.h>
 
 #include <asm/io.h>
@@ -51,6 +52,7 @@ static void phy_device_release(struct device *dev)
 }
 
 static struct phy_driver genphy_driver;
+static struct phy_driver gen10g_driver;
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
@@ -207,23 +209,29 @@ EXPORT_SYMBOL(phy_device_create);
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 {
 	int phy_reg;
+	int i;
 
-	/* Grab the bits from PHYIR1, and put them
-	 * in the upper half */
-	phy_reg = bus->read(bus, addr, MII_PHYSID1);
+	for (i = 1; i < 5; i++) {
+		/* Grab the bits from PHYIR1, and put them
+		 * in the upper half */
+		phy_reg = bus->read(bus, addr, i, MII_PHYSID1);
 
-	if (phy_reg < 0)
-		return -EIO;
+		if (phy_reg < 0)
+			return -EIO;
 
-	*phy_id = (phy_reg & 0xffff) << 16;
+		*phy_id = (phy_reg & 0xffff) << 16;
 
-	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = bus->read(bus, addr, MII_PHYSID2);
+		/* Grab the bits from PHYIR2, and put them in the lower half */
+		phy_reg = bus->read(bus, addr, i, MII_PHYSID2);
 
-	if (phy_reg < 0)
-		return -EIO;
+		if (phy_reg < 0)
+			return -EIO;
 
-	*phy_id |= (phy_reg & 0xffff);
+		*phy_id |= (phy_reg & 0xffff);
+
+		if (*phy_id != 0xffffffff)
+			break;
+	}
 
 	return 0;
 }
@@ -430,8 +438,8 @@ int phy_init_hw(struct phy_device *phydev)
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
@@ -444,7 +452,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	 * exist, and we should use the genphy driver. */
 	if (NULL == d->driver) {
 		int err;
-		d->driver = &genphy_driver.driver;
+		if (interface == PHY_INTERFACE_MODE_XGMII)
+			d->driver = &gen10g_driver.driver;
+		else
+			d->driver = &genphy_driver.driver;
 
 		err = d->driver->probe(d);
 		if (err >= 0)
@@ -521,6 +532,8 @@ void phy_detach(struct phy_device *phydev)
 	 * real driver could be loaded */
 	if (phydev->dev.driver == &genphy_driver.driver)
 		device_release_driver(&phydev->dev);
+	else if (phydev->dev.driver == &gen10g_driver.driver)
+		device_release_driver(&phydev->dev);
 }
 EXPORT_SYMBOL(phy_detach);
 
@@ -603,6 +616,12 @@ int genphy_config_advert(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_config_advert);
 
+int gen10g_config_advert(struct phy_device *dev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_config_advert);
+
 /**
  * genphy_setup_forced - configures/forces speed/duplex from @phydev
  * @phydev: target phy_device struct
@@ -631,6 +650,10 @@ int genphy_setup_forced(struct phy_device *phydev)
 	return err;
 }
 
+int gen10g_setup_forced(struct phy_device *phydev)
+{
+	return 0;
+}
 
 /**
  * genphy_restart_aneg - Enable and Restart Autonegotiation
@@ -656,6 +679,12 @@ int genphy_restart_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
+int gen10g_restart_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_restart_aneg);
+
 
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
@@ -698,6 +727,12 @@ int genphy_config_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
+int gen10g_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_config_aneg);
+
 /**
  * genphy_update_link - update link status in @phydev
  * @phydev: target phy_device struct
@@ -827,6 +862,33 @@ int genphy_read_status(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_read_status);
 
+int gen10g_read_status(struct phy_device *phydev)
+{
+	int devad, reg;
+	u32 mmd_mask = phydev->mmds;
+
+	phydev->link = 1;
+
+	/* For now just lie and say it's 10G all the time */
+	phydev->speed = 10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	for (devad = 0; mmd_mask; devad++, mmd_mask = mmd_mask >> 1) {
+		if (!mmd_mask & 1)
+			continue;
+
+		/* Read twice because link state is latched and a
+		 * read moves the current state into the register */
+		phy45_read(phydev, devad, MDIO_STAT1);
+		reg = phy45_read(phydev, devad, MDIO_STAT1);
+		if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
+			phydev->link = 0;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_read_status);
+
 static int genphy_config_init(struct phy_device *phydev)
 {
 	int val;
@@ -873,6 +935,36 @@ static int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+
+/* Replicate mdio45_probe */
+int gen10g_config_init(struct phy_device *phydev)
+{
+	int mmd, stat2, devs1, devs2;
+
+	phydev->supported = phydev->advertising = SUPPORTED_10000baseT_Full;
+
+	/* Assume PHY must have at least one of PMA/PMD, WIS, PCS, PHY
+	 * XS or DTE XS; give up if none is present. */
+	for (mmd = 1; mmd <= 5; mmd++) {
+		/* Is this MMD present? */
+		stat2 = phy45_read(phydev, mmd, MDIO_STAT2);
+		if (stat2 < 0 ||
+			(stat2 & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL)
+			continue;
+
+		/* It should tell us about all the other MMDs */
+		devs1 = phy45_read(phydev, mmd, MDIO_DEVS1);
+		devs2 = phy45_read(phydev, mmd, MDIO_DEVS2);
+		if (devs1 < 0 || devs2 < 0)
+			continue;
+
+		phydev->mmds = devs1 | (devs2 << 16);
+		return 0;
+	}
+
+	return -ENODEV;
+}
+
 int genphy_suspend(struct phy_device *phydev)
 {
 	int value;
@@ -888,6 +980,12 @@ int genphy_suspend(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_suspend);
 
+int gen10g_suspend(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_suspend);
+
 int genphy_resume(struct phy_device *phydev)
 {
 	int value;
@@ -903,6 +1001,13 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
+int gen10g_resume(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_resume);
+
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
@@ -1013,7 +1118,20 @@ static struct phy_driver genphy_driver = {
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-	.driver		= {.owner= THIS_MODULE, },
+	.driver		= {.owner = THIS_MODULE, },
+};
+
+static struct phy_driver gen10g_driver = {
+	.phy_id		= 0xffffffff,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Generic 10G PHY",
+	.config_init	= gen10g_config_init,
+	.features	= 0,
+	.config_aneg	= gen10g_config_aneg,
+	.read_status	= gen10g_read_status,
+	.suspend	= gen10g_suspend,
+	.resume		= gen10g_resume,
+	.driver		= {.owner = THIS_MODULE, },
 };
 
 static int __init phy_init(void)
@@ -1026,13 +1144,25 @@ static int __init phy_init(void)
 
 	rc = phy_driver_register(&genphy_driver);
 	if (rc)
-		mdio_bus_exit();
+		goto genphy_register_failed;
+
+	rc = phy_driver_register(&gen10g_driver);
+	if (rc)
+		goto gen10g_register_failed;
+
+	return rc;
+
+gen10g_register_failed:
+	phy_driver_unregister(&genphy_driver);
+genphy_register_failed:
+	mdio_bus_exit();
 
 	return rc;
 }
 
 static void __exit phy_exit(void)
 {
+	phy_driver_unregister(&gen10g_driver);
 	phy_driver_unregister(&genphy_driver);
 	mdio_bus_exit();
 }
diff --git a/drivers/net/s6gmac.c b/drivers/net/s6gmac.c
index 6b12524..8721665 100644
--- a/drivers/net/s6gmac.c
+++ b/drivers/net/s6gmac.c
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
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 3320317..3075a65 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -339,9 +339,10 @@ static int sbmac_mii_probe(struct net_device *dev);
 static void sbmac_mii_sync(void __iomem *sbm_mdio);
 static void sbmac_mii_senddata(void __iomem *sbm_mdio, unsigned int data,
 			       int bitcnt);
-static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx);
-static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 val);
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx);
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx, u16 val);
 
 
 /**********************************************************************
@@ -452,7 +453,8 @@ static void sbmac_mii_senddata(void __iomem *sbm_mdio, unsigned int data,
  *  	   value read, or 0xffff if an error occurred.
  ********************************************************************* */
 
-static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx)
 {
 	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
 	void __iomem *sbm_mdio = sc->sbm_mdio;
@@ -545,8 +547,8 @@ static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
  *  	   0 for success
  ********************************************************************* */
 
-static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 regval)
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx, u16 regval)
 {
 	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
 	void __iomem *sbm_mdio = sc->sbm_mdio;
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 746fb91..a174512 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -302,7 +302,8 @@ static void smsc911x_mac_write(struct smsc911x_data *pdata,
 }
 
 /* Get a phy register */
-static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+				int regidx)
 {
 	struct smsc911x_data *pdata = (struct smsc911x_data *)bus->priv;
 	unsigned long flags;
@@ -339,8 +340,8 @@ out:
 }
 
 /* Set a phy register */
-static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 val)
+static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+			int regidx, u16 val)
 {
 	struct smsc911x_data *pdata = (struct smsc911x_data *)bus->priv;
 	unsigned long flags;
@@ -570,11 +571,10 @@ static int smsc911x_phy_reset(struct smsc911x_data *pdata)
 	BUG_ON(!phy_dev->bus);
 
 	SMSC_TRACE(HW, "Performing PHY BCR Reset");
-	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, BMCR_RESET);
+	phy_write(phy_dev, MII_BMCR, BMCR_RESET);
 	do {
 		msleep(1);
-		temp = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
-			MII_BMCR);
+		temp = phy_read(phy_dev, MII_BMCR);
 	} while ((i--) && (temp & BMCR_RESET));
 
 	if (temp & BMCR_RESET) {
@@ -622,8 +622,7 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 
 	for (i = 0; i < 10; i++) {
 		/* Set PHY to 10/FD, no ANEG, and loopback mode */
-		smsc911x_mii_write(phy_dev->bus, phy_dev->addr,	MII_BMCR,
-			BMCR_LOOPBACK | BMCR_FULLDPLX);
+		phy_write(phy_dev, MII_BMCR, BMCR_LOOPBACK | BMCR_FULLDPLX);
 
 		/* Enable MAC tx/rx, FD */
 		spin_lock_irqsave(&pdata->mac_lock, flags);
@@ -651,7 +650,7 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 	spin_unlock_irqrestore(&pdata->mac_lock, flags);
 
 	/* Cancel PHY loopback mode */
-	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, 0);
+	phy_write(phy_dev, MII_BMCR, 0);
 
 	smsc911x_reg_write(pdata, TX_CFG, 0);
 	smsc911x_reg_write(pdata, RX_CFG, 0);
@@ -1616,7 +1615,7 @@ smsc911x_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 	}
 
 	for (i = 0; i <= 31; i++)
-		data[j++] = smsc911x_mii_read(phy_dev->bus, phy_dev->addr, i);
+		data[j++] = phy_read(phy_dev, i);
 }
 
 static void smsc911x_eeprom_enable_access(struct smsc911x_data *pdata)
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index ada05c4..e9a898b 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -127,7 +127,8 @@ static inline void smsc9420_pci_flush_write(struct smsc9420_pdata *pd)
 	smsc9420_reg_read(pd, ID_REV);
 }
 
-static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
+static int smsc9420_mii_read(struct mii_bus *bus, int phyaddr, int devad,
+				int regidx)
 {
 	struct smsc9420_pdata *pd = (struct smsc9420_pdata *)bus->priv;
 	unsigned long flags;
@@ -164,8 +165,8 @@ out:
 	return reg;
 }
 
-static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
-			   u16 val)
+static int smsc9420_mii_write(struct mii_bus *bus, int phyaddr, int devad,
+				int regidx, u16 val)
 {
 	struct smsc9420_pdata *pd = (struct smsc9420_pdata *)bus->priv;
 	unsigned long flags;
@@ -328,7 +329,7 @@ smsc9420_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 		return;
 
 	for (i = 0; i <= 31; i++)
-		data[j++] = smsc9420_mii_read(phy_dev->bus, phy_dev->addr, i);
+		data[j++] = phy_read(phy_dev, i);
 }
 
 static void smsc9420_eeprom_enable_access(struct smsc9420_pdata *pd)
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 40b2c79..dd0a89a 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -37,13 +37,15 @@
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
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 36149dd..efaebc3 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -500,7 +500,7 @@ static void	panic_queues(struct net_device *dev);
 
 static void tc35815_restart_work(struct work_struct *work);
 
-static int tc_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int tc_mdio_read(struct mii_bus *bus, int mii_id, int devad, int regnum)
 {
 	struct net_device *dev = bus->priv;
 	struct tc35815_regs __iomem *tr =
@@ -517,7 +517,8 @@ static int tc_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	return tc_readl(&tr->MD_Data) & 0xffff;
 }
 
-static int tc_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 val)
+static int tc_mdio_write(struct mii_bus *bus, int mii_id, int devad,
+			int regnum, u16 val)
 {
 	struct net_device *dev = bus->priv;
 	struct tc35815_regs __iomem *tr =
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0fea685..75eb85c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -936,7 +936,7 @@ static int tg3_bmcr_reset(struct tg3 *tp)
 	return 0;
 }
 
-static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
+static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int devad, int reg)
 {
 	struct tg3 *tp = bp->priv;
 	u32 val;
@@ -951,7 +951,8 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
 	return val;
 }
 
-static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int reg, u16 val)
+static int tg3_mdio_write(struct mii_bus *bp, int mii_id, int devad,
+			int reg, u16 val)
 {
 	struct tg3 *tp = bp->priv;
 	u32 ret = 0;
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index e9381fe..d5178c6 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -738,6 +738,7 @@ static int xemaclite_mdio_wait(struct net_local *lp)
  * xemaclite_mdio_read - Read from a given MII management register
  * @bus:	the mii_bus struct
  * @phy_id:	the phy address
+ * @devad:	unused
  * @reg:	register number to read from
  *
  * This function waits till the device is ready to accept a new MDIO
@@ -746,7 +747,8 @@ static int xemaclite_mdio_wait(struct net_local *lp)
  *
  * Return:	Value read from the MII management register
  */
-static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int devad,
+				int reg)
 {
 	struct net_local *lp = bus->priv;
 	u32 ctrl_reg;
@@ -782,14 +784,15 @@ static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
  * xemaclite_mdio_write - Write to a given MII management register
  * @bus:	the mii_bus struct
  * @phy_id:	the phy address
+ * @devad:	unused
  * @reg:	register number to write to
  * @val:	value to write to the register number specified by reg
  *
  * This fucntion waits till the device is ready to accept a new MDIO
  * request and then writes the val to the MDIO Write Data register.
  */
-static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
-				u16 val)
+static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int devad,
+				int reg, u16 val)
 {
 	struct net_local *lp = bus->priv;
 	u32 ctrl_reg;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 987e111..64448ee 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -6,7 +6,7 @@
  *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004-2009 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -62,7 +62,8 @@ typedef enum {
 	PHY_INTERFACE_MODE_RGMII_ID,
 	PHY_INTERFACE_MODE_RGMII_RXID,
 	PHY_INTERFACE_MODE_RGMII_TXID,
-	PHY_INTERFACE_MODE_RTBI
+	PHY_INTERFACE_MODE_RTBI,
+	PHY_INTERFACE_MODE_XGMII
 } phy_interface_t;
 
 
@@ -94,8 +95,10 @@ struct mii_bus {
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
@@ -132,8 +135,9 @@ int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr);
-int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);
-int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);
+int mdiobus_read(struct mii_bus *bus, int addr, int devad, u16 regnum);
+int mdiobus_write(struct mii_bus *bus, int addr, int devad,
+			u16 regnum, u16 val);
 
 
 #define PHY_INTERRUPT_DISABLED	0x0
@@ -303,6 +307,7 @@ struct phy_device {
 	/* See mii.h for more info */
 	u32 supported;
 	u32 advertising;
+	u32 mmds;
 
 	int autoneg;
 
@@ -429,7 +434,22 @@ struct phy_fixup {
  */
 static inline int phy_read(struct phy_device *phydev, u32 regnum)
 {
-	return mdiobus_read(phydev->bus, phydev->addr, regnum);
+	return mdiobus_read(phydev->bus, phydev->addr, 0, regnum);
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
@@ -444,7 +464,24 @@ static inline int phy_read(struct phy_device *phydev, u32 regnum)
  */
 static inline int phy_write(struct phy_device *phydev, u32 regnum, u16 val)
 {
-	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
+	return mdiobus_write(phydev->bus, phydev->addr, 0, regnum, val);
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
 
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
-- 
1.6.5.2.g6ff9a

