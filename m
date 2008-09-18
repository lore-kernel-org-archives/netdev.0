From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] mv643xx_eth: convert to phylib
Date: Thu, 18 Sep 2008 14:44:28 +0200
Message-ID: <20080918124428.GB9157@xi.wantstofly.org>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org> <1220448012-20347-4-git-send-email-buytenh@wantstofly.org> <A8E7D979-2540-456E-818C-A419D7BE4166@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:40916 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbYIRMo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 08:44:29 -0400
Content-Disposition: inline
In-Reply-To: <A8E7D979-2540-456E-818C-A419D7BE4166@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 06:55:18PM -0500, Andy Fleming wrote:

> >@@ -1338,7 +1327,7 @@ static int mv643xx_eth_nway_reset(struct  
> >net_device *dev)
> >{
> >	struct mv643xx_eth_private *mp = netdev_priv(dev);
> >
> >-	return mii_nway_restart(&mp->mii);
> >+	return phy_nway_restart(mp->phy);
> 
> As mentioned in patch #2, I think you can use genphy_restart_aneg(),  
> here.

Right, that looks like that'll work.


> >static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
> >@@ -1350,7 +1339,7 @@ static u32 mv643xx_eth_get_link(struct  
> >net_device *dev)
> >{
> >	struct mv643xx_eth_private *mp = netdev_priv(dev);
> >
> >-	return mii_link_ok(&mp->mii);
> >+	return phy_link_ok(mp->phy);
> 
> You can just return phydev->link, unless you don't think phydev->link  
> will be up-to-date.  If so, I recommend using genphy_update_link().   
> I'm curious: you say the controller handles all the link management.   
> Is it possible to read that information out?  Since you are doing the  
> "do it yourself" method, it would simplify and speed up certain  
> options if you just did:
> 
> phydev->link = readl(somereg) & LINK_STATUS ? 1 : 0
> 
> You could do that whenever the controller tells you the link is down.

Yes, e.g. this works:

	static u32 mv643xx_eth_get_link(struct net_device *dev)
	{
		struct mv643xx_eth_private *mp = netdev_priv(dev);

		return !!(rdl(mp, PORT_STATUS(mp->port_num)) & LINK_UP);
	}

I wonder if I need to update ->link at all, considering that I don't
use it, and I don't call any phylib functionality that uses it.


> >+static void phy_init(struct mv643xx_eth_private *mp, int speed, int  
> >duplex)
> >{
> >	struct ethtool_cmd cmd;
> >-	int err;
> >
> >-	err = phy_detect(mp);
> >-	if (err) {
> >-		dev_printk(KERN_INFO, &mp->dev->dev,
> >-			   "no PHY detected at addr %d\n", mp->phy_addr);
> >-		return err;
> >-	}
> >	phy_reset(mp);
> >
> >-	mp->mii.phy_id = mp->phy_addr;
> >-	mp->mii.phy_id_mask = 0x3f;
> >-	mp->mii.reg_num_mask = 0x1f;
> >-	mp->mii.dev = mp->dev;
> >-	mp->mii.mdio_read = mv643xx_eth_mdio_read;
> >-	mp->mii.mdio_write = mv643xx_eth_mdio_write;
> >-
> >-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
> >+	phy_attach(mp->dev, mp->phy->dev.bus_id, 0, 0);
> >
> >	memset(&cmd, 0, sizeof(cmd));
> >
> >	cmd.port = PORT_MII;
> >	cmd.transceiver = XCVR_INTERNAL;
> >-	cmd.phy_address = mp->phy_addr;
> >-	if (pd->speed == 0) {
> >+	cmd.phy_address = mp->phy->addr;
> >+	if (speed == 0) {
> >		cmd.autoneg = AUTONEG_ENABLE;
> >		cmd.speed = SPEED_100;
> >		cmd.advertising = ADVERTISED_10baseT_Half  |
> >				  ADVERTISED_10baseT_Full  |
> >				  ADVERTISED_100baseT_Half |
> >				  ADVERTISED_100baseT_Full;
> >-		if (mp->mii.supports_gmii)
> >+		if (phy_check_gmii_support(mp->phy))
> >			cmd.advertising |= ADVERTISED_1000baseT_Full;
> >	} else {
> >		cmd.autoneg = AUTONEG_DISABLE;
> >-		cmd.speed = pd->speed;
> >-		cmd.duplex = pd->duplex;
> >+		cmd.speed = speed;
> >+		cmd.duplex = duplex;
> >	}
> >
> >	mv643xx_eth_set_settings(mp->dev, &cmd);
> 
> This is a somewhat roundabout way to configure the PHY.   
> The ..._sset() function was intended to provide support for userspace  
> configuration of the PHY via the same interface ethtool uses.  There  
> are more direct ways to configure the PHY when you have a pointer to a  
> struct phy_device.

ACK.  I was just doing the same thing as the old code did -- which I
inherited from somewhere else.


> Look at the code for phy_ethtool_sset(), and replicate what it does.   
> That way you don't need to set up the struct ethtool_cmd.  The  
> definitions for the fields are identical, so it should just mean  
> replacing all the cmd.foo = bar lines with mp->phy->foo = bar.
> 
> And, actually, I believe you can reduce this even more, since you are  
> just doing the generic initialization from what I can tell.  You can  
> just set mp->phy->supported and ->advertising to be what your  
> controller supports (masked with what the connected PHY supports), and  
> then invoke phy_start_aneg(mp->phy);  phylib will configure the PHY  
> properly, and then return control to you.

I'll make this function:

	static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
	{
		struct phy_device *phy = mp->phy;

		phy_reset(mp);

		phy_attach(mp->dev, phy->dev.bus_id, 0, PHY_INTERFACE_MODE_GMII);

		phy->state = PHY_HALTED;

		if (speed == 0) {
			phy->autoneg = AUTONEG_ENABLE;
			phy->speed = 0;
			phy->duplex = 0;
			phy->advertising = phy->supported | ADVERTISED_Autoneg;
		} else {
			phy->autoneg = AUTONEG_DISABLE;
			phy->advertising = 0;
			phy->speed = speed;
			phy->duplex = duplex;
		}
		phy_start_aneg(phy);
	}

OK?  (PHY_HALTED because that seems to be the way to stop the state
machine from running at all.  Or should I call phy_stop() once?)


> You will, however, need to  
> figure out how best to read out the status for the PHY, and how to  
> know when autonegotiation is done.  I'm assuming that your controller  
> tracks that information, and that you can manually pull that  
> information from local register space (rather than the SMI bus).

I don't really need to access it all during normal operation -- the
controller just reads the link up/down and speed and duplex bits from
the PHY automatically and then configures itself accordingly.  The
only time I need to access this information is when someone asks for
it via ethtool (or if I want to print a link status message).  I.e. I
don't need any state machine, be it phylib's or my own.



New patch:


commit 61c35c0299272a4f8d8fb8d3dd59a9742fb34f35
Author: Lennert Buytenhek <buytenh@wantstofly.org>
Date:   Tue Aug 26 13:34:19 2008 +0200

    mv643xx_eth: convert to phylib
    
    Switch mv643xx_eth from using drivers/net/mii.c to using phylib.
    
    Since the mv643xx_eth hardware does all the link state handling and
    PHY polling, the driver will use phylib in the "Doing it all yourself"
    mode described in the phylib documentation.
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4a11296..d85d760 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2262,7 +2262,7 @@ config UGETH_TX_ON_DEMAND
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
-	select MII
+	select PHYLIB
 	help
 	  This driver supports the gigabit ethernet MACs in the
 	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d32d874..ee19975 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -48,7 +48,7 @@
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
-#include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/mv643xx_eth.h>
 #include <asm/io.h>
 #include <asm/types.h>
@@ -248,9 +248,9 @@ struct mv643xx_eth_shared_private {
 	struct mv643xx_eth_shared_private *smi;
 
 	/*
-	 * Protects access to SMI_REG, which is shared between ports.
+	 * Provides access to local SMI interface.
 	 */
-	struct mutex phy_lock;
+	struct mii_bus smi_bus;
 
 	/*
 	 * If we have access to the error interrupt pin (which is
@@ -354,11 +354,10 @@ struct mv643xx_eth_private {
 
 	struct net_device *dev;
 
-	int phy_addr;
+	struct phy_device *phy;
 
 	struct mib_counters mib_counters;
 	struct work_struct tx_timeout_task;
-	struct mii_if_info mii;
 
 	struct napi_struct napi;
 	u8 work_link;
@@ -1077,62 +1076,50 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 	return 0;
 }
 
-static int smi_reg_read(struct mv643xx_eth_private *mp,
-			unsigned int addr, unsigned int reg)
+static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
 {
-	struct mv643xx_eth_shared_private *msp = mp->shared->smi;
+	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
 	int ret;
 
-	mutex_lock(&msp->phy_lock);
-
 	if (smi_wait_ready(msp)) {
-		printk("%s: SMI bus busy timeout\n", mp->dev->name);
-		ret = -ETIMEDOUT;
-		goto out;
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
 	if (smi_wait_ready(msp)) {
-		printk("%s: SMI bus busy timeout\n", mp->dev->name);
-		ret = -ETIMEDOUT;
-		goto out;
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
 	}
 
 	ret = readl(smi_reg);
 	if (!(ret & SMI_READ_VALID)) {
-		printk("%s: SMI bus read not valid\n", mp->dev->name);
-		ret = -ENODEV;
-		goto out;
+		printk("mv643xx_eth: SMI bus read not valid\n");
+		return -ENODEV;
 	}
 
-	ret &= 0xffff;
-
-out:
-	mutex_unlock(&msp->phy_lock);
-
-	return ret;
+	return ret & 0xffff;
 }
 
-static int smi_reg_write(struct mv643xx_eth_private *mp, unsigned int addr,
-			 unsigned int reg, unsigned int value)
+static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 {
-	struct mv643xx_eth_shared_private *msp = mp->shared->smi;
+	struct mv643xx_eth_shared_private *msp = bus->priv;
 	void __iomem *smi_reg = msp->base + SMI_REG;
 
-	mutex_lock(&msp->phy_lock);
-
 	if (smi_wait_ready(msp)) {
-		printk("%s: SMI bus busy timeout\n", mp->dev->name);
-		mutex_unlock(&msp->phy_lock);
+		printk("mv643xx_eth: SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_WRITE | (reg << 21) |
-		(addr << 16) | (value & 0xffff), smi_reg);
+		(addr << 16) | (val & 0xffff), smi_reg);
 
-	mutex_unlock(&msp->phy_lock);
+	if (smi_wait_ready(msp)) {
+		printk("mv643xx_eth: SMI bus busy timeout\n");
+		return -ETIMEDOUT;
+	}
 
 	return 0;
 }
@@ -1277,7 +1264,9 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
 
-	err = mii_ethtool_gset(&mp->mii, cmd);
+	err = phy_read_status(mp->phy);
+	if (err == 0)
+		err = phy_ethtool_gset(mp->phy, cmd);
 
 	/*
 	 * The MAC does not support 1000baseT_Half.
@@ -1331,7 +1320,7 @@ static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *
 	 */
 	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	return mii_ethtool_sset(&mp->mii, cmd);
+	return phy_ethtool_sset(mp->phy, cmd);
 }
 
 static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -1353,7 +1342,7 @@ static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	return mii_nway_restart(&mp->mii);
+	return genphy_restart_aneg(mp->phy);
 }
 
 static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
@@ -1365,12 +1354,7 @@ static u32 mv643xx_eth_get_link(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	return mii_link_ok(&mp->mii);
-}
-
-static u32 mv643xx_eth_get_link_phyless(struct net_device *dev)
-{
-	return 1;
+	return !!(rdl(mp, PORT_STATUS(mp->port_num)) & LINK_UP);
 }
 
 static void mv643xx_eth_get_strings(struct net_device *dev,
@@ -1438,7 +1422,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops_phyless = {
 	.set_settings		= mv643xx_eth_set_settings_phyless,
 	.get_drvinfo		= mv643xx_eth_get_drvinfo,
 	.nway_reset		= mv643xx_eth_nway_reset_phyless,
-	.get_link		= mv643xx_eth_get_link_phyless,
+	.get_link		= mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
@@ -1931,16 +1915,16 @@ static void phy_reset(struct mv643xx_eth_private *mp)
 {
 	int data;
 
-	data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+	data = phy_read(mp->phy, MII_BMCR);
 	if (data < 0)
 		return;
 
 	data |= BMCR_RESET;
-	if (smi_reg_write(mp, mp->phy_addr, MII_BMCR, data) < 0)
+	if (phy_write(mp->phy, MII_BMCR, data) < 0)
 		return;
 
 	do {
-		data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+		data = phy_read(mp->phy, MII_BMCR);
 	} while (data >= 0 && data & BMCR_RESET);
 }
 
@@ -1952,7 +1936,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Perform PHY reset, if there is a PHY.
 	 */
-	if (mp->phy_addr != -1) {
+	if (mp->phy != NULL) {
 		struct ethtool_cmd cmd;
 
 		mv643xx_eth_get_settings(mp->dev, &cmd);
@@ -1969,7 +1953,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
 	pscr |= DO_NOT_FORCE_LINK_FAIL;
-	if (mp->phy_addr == -1)
+	if (mp->phy == NULL)
 		pscr |= FORCE_LINK_PASS;
 	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
@@ -2175,8 +2159,8 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	if (mp->phy_addr != -1)
-		return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+	if (mp->phy != NULL)
+		return phy_mii_ioctl(mp->phy, if_mii(ifr), cmd);
 
 	return -EOPNOTSUPP;
 }
@@ -2246,18 +2230,6 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 }
 #endif
 
-static int mv643xx_eth_mdio_read(struct net_device *dev, int addr, int reg)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	return smi_reg_read(mp, addr, reg);
-}
-
-static void mv643xx_eth_mdio_write(struct net_device *dev, int addr, int reg, int val)
-{
-	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	smi_reg_write(mp, addr, reg, val);
-}
-
 
 /* platform glue ************************************************************/
 static void
@@ -2352,11 +2324,23 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
-	msp->smi = msp;
-	if (pd != NULL && pd->shared_smi != NULL)
+	/*
+	 * Set up and register SMI bus.
+	 */
+	if (pd == NULL || pd->shared_smi == NULL) {
+		msp->smi_bus.priv = msp;
+		msp->smi_bus.name = "mv643xx_eth smi";
+		msp->smi_bus.read = smi_bus_read;
+		msp->smi_bus.write = smi_bus_write,
+		snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
+		msp->smi_bus.dev = &pdev->dev;
+		msp->smi_bus.phy_mask = 0xffffffff;
+		if (mdiobus_register(&msp->smi_bus) < 0)
+			goto out_unmap;
+		msp->smi = msp;
+	} else {
 		msp->smi = platform_get_drvdata(pd->shared_smi);
-
-	mutex_init(&msp->phy_lock);
+	}
 
 	msp->err_interrupt = NO_IRQ;
 	init_waitqueue_head(&msp->smi_busy_wait);
@@ -2392,6 +2376,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	return 0;
 
+out_unmap:
+	iounmap(msp->base);
 out_free:
 	kfree(msp);
 out:
@@ -2401,7 +2387,10 @@ out:
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
 
+	if (pd == NULL || pd->shared_smi == NULL)
+		mdiobus_unregister(&msp->smi_bus);
 	if (msp->err_interrupt != NO_IRQ)
 		free_irq(msp->err_interrupt, msp);
 	iounmap(msp->base);
@@ -2449,17 +2438,6 @@ static void set_params(struct mv643xx_eth_private *mp,
 	else
 		uc_addr_get(mp, dev->dev_addr);
 
-	if (pd->phy_addr == MV643XX_ETH_PHY_NONE) {
-		mp->phy_addr = -1;
-	} else {
-		if (pd->phy_addr != MV643XX_ETH_PHY_ADDR_DEFAULT) {
-			mp->phy_addr = pd->phy_addr & 0x3f;
-			phy_addr_set(mp, mp->phy_addr);
-		} else {
-			mp->phy_addr = phy_addr_get(mp);
-		}
-	}
-
 	mp->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	if (pd->rx_queue_size)
 		mp->default_rx_ring_size = pd->rx_queue_size;
@@ -2477,76 +2455,62 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->txq_count = pd->tx_queue_count ? : 1;
 }
 
-static int phy_detect(struct mv643xx_eth_private *mp)
+static struct phy_device *phy_scan(struct mv643xx_eth_private *mp,
+				   int phy_addr)
 {
-	int data;
-	int data2;
-
-	data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
-	if (data < 0)
-		return -ENODEV;
+	struct mii_bus *bus = &mp->shared->smi->smi_bus;
+	struct phy_device *phydev;
+	int start;
+	int num;
+	int i;
 
-	if (smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE) < 0)
-		return -ENODEV;
+	if (phy_addr == MV643XX_ETH_PHY_ADDR_DEFAULT) {
+		start = phy_addr_get(mp) & 0x1f;
+		num = 32;
+	} else {
+		start = phy_addr & 0x1f;
+		num = 1;
+	}
 
-	data2 = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
-	if (data2 < 0)
-		return -ENODEV;
+	phydev = NULL;
+	for (i = 0; i < num; i++) {
+		int addr = (start + i) & 0x1f;
 
-	if (((data ^ data2) & BMCR_ANENABLE) == 0)
-		return -ENODEV;
+		if (bus->phy_map[addr] == NULL)
+			mdiobus_scan(bus, addr);
 
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
+		if (phydev == NULL) {
+			phydev = bus->phy_map[addr];
+			if (phydev != NULL)
+				phy_addr_set(mp, addr);
+		}
+	}
 
-	return 0;
+	return phydev;
 }
 
-static int phy_init(struct mv643xx_eth_private *mp,
-		    struct mv643xx_eth_platform_data *pd)
+static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
-	struct ethtool_cmd cmd;
-	int err;
+	struct phy_device *phy = mp->phy;
 
-	err = phy_detect(mp);
-	if (err) {
-		dev_printk(KERN_INFO, &mp->dev->dev,
-			   "no PHY detected at addr %d\n", mp->phy_addr);
-		return err;
-	}
 	phy_reset(mp);
 
-	mp->mii.phy_id = mp->phy_addr;
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
-	mp->mii.dev = mp->dev;
-	mp->mii.mdio_read = mv643xx_eth_mdio_read;
-	mp->mii.mdio_write = mv643xx_eth_mdio_write;
-
-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
-
-	memset(&cmd, 0, sizeof(cmd));
-
-	cmd.port = PORT_MII;
-	cmd.transceiver = XCVR_INTERNAL;
-	cmd.phy_address = mp->phy_addr;
-	if (pd->speed == 0) {
-		cmd.autoneg = AUTONEG_ENABLE;
-		cmd.speed = SPEED_100;
-		cmd.advertising = ADVERTISED_10baseT_Half  |
-				  ADVERTISED_10baseT_Full  |
-				  ADVERTISED_100baseT_Half |
-				  ADVERTISED_100baseT_Full;
-		if (mp->mii.supports_gmii)
-			cmd.advertising |= ADVERTISED_1000baseT_Full;
-	} else {
-		cmd.autoneg = AUTONEG_DISABLE;
-		cmd.speed = pd->speed;
-		cmd.duplex = pd->duplex;
-	}
+	phy_attach(mp->dev, phy->dev.bus_id, 0, PHY_INTERFACE_MODE_GMII);
 
-	mv643xx_eth_set_settings(mp->dev, &cmd);
+	phy->state = PHY_HALTED;
 
-	return 0;
+	if (speed == 0) {
+		phy->autoneg = AUTONEG_ENABLE;
+		phy->speed = 0;
+		phy->duplex = 0;
+		phy->advertising = phy->supported | ADVERTISED_Autoneg;
+	} else {
+		phy->autoneg = AUTONEG_DISABLE;
+		phy->advertising = 0;
+		phy->speed = speed;
+		phy->duplex = duplex;
+	}
+	phy_start_aneg(phy);
 }
 
 static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
@@ -2560,7 +2524,7 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 	}
 
 	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
-	if (mp->phy_addr == -1) {
+	if (mp->phy == NULL) {
 		pscr |= DISABLE_AUTO_NEG_SPEED_GMII;
 		if (speed == SPEED_1000)
 			pscr |= SET_GMII_SPEED_TO_1000;
@@ -2614,20 +2578,20 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	set_params(mp, pd);
 	dev->real_num_tx_queues = mp->txq_count;
 
-	mib_counters_clear(mp);
-	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
-
-	if (mp->phy_addr != -1) {
-		err = phy_init(mp, pd);
-		if (err)
-			goto out;
+	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
+		mp->phy = phy_scan(mp, pd->phy_addr);
 
+	if (mp->phy != NULL) {
+		phy_init(mp, pd->speed, pd->duplex);
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 	} else {
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
 	}
+
 	init_pscr(mp, pd->speed, pd->duplex);
 
+	mib_counters_clear(mp);
+	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
 	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 128);
 
 	init_timer(&mp->rx_oom);
@@ -2685,6 +2649,8 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
 
 	unregister_netdev(mp->dev);
+	if (mp->phy != NULL)
+		phy_detach(mp->phy);
 	flush_scheduled_work();
 	free_netdev(mp->dev);
 
--
