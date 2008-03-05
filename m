From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 5 Mar 2008 07:39:25 -0500
Message-ID: <20080305123925.GA27691@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:55756 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755278AbYCEMj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 07:39:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note - The #upstream branch of netdev-2.5.git will be getting pushed to
net-2.6.26.git soon.  That's where I've been keeping my for-2.6.26
stuff.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 MAINTAINERS                    |   32 ++++----------------------------
 drivers/net/Kconfig            |    2 +-
 drivers/net/atarilance.c       |    5 ++---
 drivers/net/e100.c             |   29 +++--------------------------
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/mv643xx_eth.c      |    1 +
 drivers/net/pcmcia/axnet_cs.c  |    2 +-
 drivers/net/phy/Kconfig        |    1 +
 drivers/net/phy/davicom.c      |   17 ++++++++++++++---
 drivers/net/s2io.c             |    2 +-
 drivers/net/tulip/de2104x.c    |    3 ++-
 11 files changed, 31 insertions(+), 65 deletions(-)

Adrian Bunk (3):
      fix drivers/net/atarilance.c compilation
      FIXED_PHY must depend on PHYLIB=y
      make s2io.c:init_tti() static

Auke Kok (2):
      e100: Do suspend/shutdown like e1000
      Intel ethernet adapter: Update MAINTAINERS

Emil Tantilov (1):
      ixgbe: fix typo in speed mesage

Komuro (1):
      axnet_cs: change debugging level for "Too much work at interrupt" message.

Martin Michlmayr (1):
      mv643xx_eth: Define module alias for platform device

Ondrej Zary (1):
      de2104x: remove BUG_ON() when changing media type

Thomas Klein (1):
      ehea: Fix missing Kconfig dependency

frederic Rodo (1):
      dm9161: add configuration for MII/RMII

diff --git a/MAINTAINERS b/MAINTAINERS
index 33d99dc..93e0de9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2039,43 +2039,19 @@ M:	kernel@wantstofly.org
 L:	netdev@vger.kernel.org
 S:	Maintained
 
-INTEL PRO/100 ETHERNET SUPPORT
+INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/ixgb/ixgbe)
 P:	Auke Kok
 M:	auke-jan.h.kok@intel.com
 P:	Jesse Brandeburg
 M:	jesse.brandeburg@intel.com
 P:	Jeff Kirsher
 M:	jeffrey.t.kirsher@intel.com
+P:	Bruce Allan
+M:	bruce.w.allan@intel.com
 P:	John Ronciak
 M:	john.ronciak@intel.com
 L:	e1000-devel@lists.sourceforge.net
-W:	http://sourceforge.net/projects/e1000/
-S:	Supported
-
-INTEL PRO/1000 GIGABIT ETHERNET SUPPORT
-P:	Auke Kok
-M:	auke-jan.h.kok@intel.com
-P:	Jesse Brandeburg
-M:	jesse.brandeburg@intel.com
-P:	Jeff Kirsher
-M:	jeffrey.t.kirsher@intel.com
-P:	John Ronciak
-M:	john.ronciak@intel.com
-L:	e1000-devel@lists.sourceforge.net
-W:	http://sourceforge.net/projects/e1000/
-S:	Supported
-
-INTEL PRO/10GbE SUPPORT
-P:	Ayyappan Veeraiyan
-M:	ayyappan.veeraiyan@intel.com
-P:	Auke Kok
-M:	auke-jan.h.kok@intel.com
-P:	Jesse Brandeburg
-M:	jesse.brandeburg@intel.com
-P:	John Ronciak
-M:	john.ronciak@intel.com
-L:	e1000-devel@lists.sourceforge.net
-W:	http://sourceforge.net/projects/e1000/
+W:	http://e1000.sourceforge.net/
 S:	Supported
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a0f0e60..a64bb41 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2519,7 +2519,7 @@ config CHELSIO_T3
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET
+	depends on IBMEBUS && INET && SPARSEMEM
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index b74dbee..13c293b 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -336,8 +336,6 @@ struct lance_addr {
 
 /***************************** Prototypes *****************************/
 
-static int addr_accessible( volatile void *regp, int wordflag, int
-                            writeflag );
 static unsigned long lance_probe1( struct net_device *dev, struct lance_addr
                                    *init_rec );
 static int lance_open( struct net_device *dev );
@@ -406,7 +404,8 @@ struct net_device * __init atarilance_probe(int unit)
 
 /* Derived from hwreg_present() in atari/config.c: */
 
-static int __init addr_accessible( volatile void *regp, int wordflag, int writeflag )
+static noinline int __init addr_accessible(volatile void *regp, int wordflag,
+					   int writeflag)
 {
 	int		ret;
 	long	flags;
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 36ba6dc..cdf3090 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2782,16 +2782,13 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 	}
 }
 
-#ifdef CONFIG_PM
 static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
 	if (netif_running(netdev))
-		napi_disable(&nic->napi);
-	del_timer_sync(&nic->watchdog);
-	netif_carrier_off(nic->netdev);
+		e100_down(nic);
 	netif_device_detach(netdev);
 
 	pci_save_state(pdev);
@@ -2804,14 +2801,13 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	free_irq(pdev->irq, netdev);
-
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2832,26 +2828,7 @@ static int e100_resume(struct pci_dev *pdev)
 
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct nic *nic = netdev_priv(netdev);
-
-	if (netif_running(netdev))
-		napi_disable(&nic->napi);
-	del_timer_sync(&nic->watchdog);
-	netif_carrier_off(nic->netdev);
-
-	if ((nic->flags & wol_magic) | e100_asf(nic)) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
-	}
-
-	free_irq(pdev->irq, netdev);
-
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	e100_suspend(pdev, PMSG_SUSPEND);
 }
 
 /* ------------------ PCI Error Recovery infrastructure  -------------- */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 23d0a4a..c2095ce 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2133,7 +2133,7 @@ static void ixgbe_watchdog(unsigned long data)
 				(link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
 				 "10 Gbps" :
 				 (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-				  "1 Gpbs" : "unknown speed")),
+				  "1 Gbps" : "unknown speed")),
 				((FLOW_RX && FLOW_TX) ? "RX/TX" :
 				 (FLOW_RX ? "RX" :
 				 (FLOW_TX ? "TX" : "None"))));
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b528ce7..771139e 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2104,6 +2104,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
 		" and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
+MODULE_ALIAS("platform:mv643xx_eth");
 
 /*
  * The second part is the low level driver of the gigE ethernet ports.
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index e8a63e4..ce95c5d 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1268,7 +1268,7 @@ static irqreturn_t ax_interrupt(int irq, void *dev_id)
 		}
 	}
     
-	if (interrupts && ei_debug) 
+	if (interrupts && ei_debug > 3) 
 	{
 		handled = 1;
 		if (nr_serviced >= MAX_SERVICE) 
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index f4ca059..3ac8529 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -67,6 +67,7 @@ config REALTEK_PHY
 
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
+	depends on PHYLIB=y
 	---help---
 	  Adds the platform "fixed" MDIO Bus to cover the boards that use
 	  PHYs that are not connected to the real MDIO bus.
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 7ed632d..d926168 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -37,6 +37,7 @@
 
 #define MII_DM9161_SCR		0x10
 #define MII_DM9161_SCR_INIT	0x0610
+#define MII_DM9161_SCR_RMII	0x0100
 
 /* DM9161 Interrupt Register */
 #define MII_DM9161_INTR	0x15
@@ -103,7 +104,7 @@ static int dm9161_config_aneg(struct phy_device *phydev)
 
 static int dm9161_config_init(struct phy_device *phydev)
 {
-	int err;
+	int err, temp;
 
 	/* Isolate the PHY */
 	err = phy_write(phydev, MII_BMCR, BMCR_ISOLATE);
@@ -111,9 +112,19 @@ static int dm9161_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	/* Do not bypass the scrambler/descrambler */
-	err = phy_write(phydev, MII_DM9161_SCR, MII_DM9161_SCR_INIT);
+	switch (phydev->interface) {
+	case PHY_INTERFACE_MODE_MII:
+		temp = MII_DM9161_SCR_INIT;
+		break;
+	case PHY_INTERFACE_MODE_RMII:
+		temp =  MII_DM9161_SCR_INIT | MII_DM9161_SCR_RMII;
+		break;
+	default:
+		return -EINVAL;
+	}
 
+	/* Do not bypass the scrambler/descrambler */
+	err = phy_write(phydev, MII_DM9161_SCR, temp);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6179a0a..c72787a 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1088,7 +1088,7 @@ static int s2io_print_pci_mode(struct s2io_nic *nic)
  *  '-1' on failure
  */
 
-int init_tti(struct s2io_nic *nic, int link)
+static int init_tti(struct s2io_nic *nic, int link)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 77d9dd7..567c627 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -910,7 +910,8 @@ static void de_set_media (struct de_private *de)
 	unsigned media = de->media_type;
 	u32 macmode = dr32(MacMode);
 
-	BUG_ON(de_is_running(de));
+	if (de_is_running(de))
+		printk(KERN_WARNING "%s: chip is running while changing media!\n", de->dev->name);
 
 	if (de->de21040)
 		dw32(CSR11, FULL_DUPLEX_MAGIC);
