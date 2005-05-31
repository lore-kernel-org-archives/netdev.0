From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Tue, 31 May 2005 10:59:39 -0700
Message-ID: <20050531105939.7486e071@dxpl.pdx.osdl.net>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Here are some patches:
	* allow phy's to be modules 
	* use driver owner for ref count
	* make local functions static where ever possible
	* get rid of bus read may sleep implication in comment.
	  since you are holding phy spin lock it better not!!

Untested since I don't have sungem, but am thinking about this for skge
driver.

Index: skge-phy/drivers/net/phy/davicom.c
===================================================================
--- skge-phy.orig/drivers/net/phy/davicom.c
+++ skge-phy/drivers/net/phy/davicom.c
@@ -60,13 +60,17 @@
 #define MII_DM9161_10BTCSR	0x12
 #define MII_DM9161_10BTCSR_INIT	0x7800
 
+MODULE_DESCRIPTION("Davicom PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
+
 struct dm9161_private {
 	struct timer_list timer;
 	int resetdone;
 };
 
 #define DM9161_DELAY 1
-int dm9161_config_intr(struct phy_device *phydev)
+static int dm9161_config_intr(struct phy_device *phydev)
 {
 	int temp;
 
@@ -226,6 +230,7 @@ static struct phy_driver dm9161_driver =
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
 	.remove		= dm9161_remove,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
 static struct phy_driver dm9131_driver = {
@@ -238,38 +243,33 @@ static struct phy_driver dm9131_driver =
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
-int __init dm9161_init(void)
+static int __init davicom_init(void)
 {
-	int retval;
+	int ret;
 
-	retval = phy_driver_register(&dm9161_driver);
+	ret = phy_driver_register(&dm9161_driver);
+	if (ret)
+		goto err1;
 
-	return retval;
-}
+	ret = phy_driver_register(&dm9131_driver);
+	if (ret)
+		goto err2;
+	return 0;
 
-static void __exit dm9161_exit(void)
-{
+ err2:	
 	phy_driver_unregister(&dm9161_driver);
+ err1:
+	return ret;
 }
 
-module_init(dm9161_init);
-module_exit(dm9161_exit);
-
-int __init dm9131_init(void)
-{
-	int retval;
-
-	retval = phy_driver_register(&dm9131_driver);
-
-	return retval;
-}
-
-static void __exit dm9131_exit(void)
+static void __exit davicom_exit(void)
 {
+	phy_driver_unregister(&dm9161_driver);
 	phy_driver_unregister(&dm9131_driver);
 }
 
-module_init(dm9131_init);
-module_exit(dm9131_exit);
+module_init(davicom_init);
+module_exit(davicom_exit);
Index: skge-phy/drivers/net/phy/marvell.c
===================================================================
--- skge-phy.orig/drivers/net/phy/marvell.c
+++ skge-phy/drivers/net/phy/marvell.c
@@ -45,6 +45,10 @@
 #define MII_M1011_IMASK_INIT		0x6400
 #define MII_M1011_IMASK_CLEAR		0x0000
 
+MODULE_DESCRIPTION("Marvell PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
+
 static int marvell_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -119,15 +123,12 @@ static struct phy_driver m88e1101_driver
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &marvell_ack_interrupt,
 	.config_intr	= &marvell_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
-int __init marvell_init(void)
+static int __init marvell_init(void)
 {
-	int retval;
-
-	retval = phy_driver_register(&m88e1101_driver);
-
-	return retval;
+	return phy_driver_register(&m88e1101_driver);
 }
 
 static void __exit marvell_exit(void)
Index: skge-phy/drivers/net/phy/lxt.c
===================================================================
--- skge-phy.orig/drivers/net/phy/lxt.c
+++ skge-phy/drivers/net/phy/lxt.c
@@ -58,6 +58,10 @@
 #define MII_LXT971_ISR		19  /* Interrupt Status Register */
 
 
+MODULE_DESCRIPTION("Intel LXT PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
+
 static int lxt970_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -130,6 +134,7 @@ static struct phy_driver lxt970_driver =
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt970_ack_interrupt,
 	.config_intr	= lxt970_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
 static struct phy_driver lxt971_driver = {
@@ -142,38 +147,33 @@ static struct phy_driver lxt971_driver =
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= lxt971_ack_interrupt,
 	.config_intr	= lxt971_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
-int __init lxt970_init(void)
+static int __init lxt_init(void)
 {
-	int retval;
+	int ret;
 
-	retval = phy_driver_register(&lxt970_driver);
+	ret = phy_driver_register(&lxt970_driver);
+	if (ret)
+		goto err1;
 
-	return retval;
-}
+	ret = phy_driver_register(&lxt971_driver);
+	if (ret)
+		goto err2;
+	return 0;
 
-static void __exit lxt970_exit(void)
-{
+ err2:	
 	phy_driver_unregister(&lxt970_driver);
+ err1:
+	return ret;
 }
 
-module_init(lxt970_init);
-module_exit(lxt970_exit);
-
-int __init lxt971_init(void)
-{
-	int retval;
-
-	retval = phy_driver_register(&lxt971_driver);
-
-	return retval;
-}
-
-static void __exit lxt971_exit(void)
+static void __exit lxt_exit(void)
 {
+	phy_driver_unregister(&lxt970_driver);
 	phy_driver_unregister(&lxt971_driver);
 }
 
-module_init(lxt971_init);
-module_exit(lxt971_exit);
+module_init(lxt_init);
+module_exit(lxt_exit);
Index: skge-phy/drivers/net/phy/qsemi.c
===================================================================
--- skge-phy.orig/drivers/net/phy/qsemi.c
+++ skge-phy/drivers/net/phy/qsemi.c
@@ -59,9 +59,12 @@
 #define QS6612_PCR_MLT3_DIS	0x0002
 #define QS6612_PCR_SCRM_DESCRM	0x0001
 
+MODULE_DESCRIPTION("Quality Semiconductor PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
 
 /* Returns 0, unless there's a write error */
-int qs6612_probe(struct phy_device *phydev)
+static int qs6612_probe(struct phy_device *phydev)
 {
 	/* The PHY powers up isolated on the RPX,
 	 * so send a command to allow operation.
@@ -77,7 +80,7 @@ int qs6612_probe(struct phy_device *phyd
 	return phy_write(phydev, MII_QS6612_PCR, 0x0dc0);
 }
 
-int qs6612_ack_interrupt(struct phy_device *phydev)
+static int qs6612_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
 
@@ -99,7 +102,7 @@ int qs6612_ack_interrupt(struct phy_devi
 	return 0;
 }
 
-int qs6612_config_intr(struct phy_device *phydev)
+static int qs6612_config_intr(struct phy_device *phydev)
 {
 	int err;
 	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
@@ -123,15 +126,12 @@ static struct phy_driver qs6612_driver =
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= qs6612_ack_interrupt,
 	.config_intr	= qs6612_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
-int __init qs6612_init(void)
+static int __init qs6612_init(void)
 {
-	int retval;
-
-	retval = phy_driver_register(&qs6612_driver);
-
-	return retval;
+	return phy_driver_register(&qs6612_driver);
 }
 
 static void __exit qs6612_exit(void)
Index: skge-phy/drivers/net/phy/phy_device.c
===================================================================
--- skge-phy.orig/drivers/net/phy/phy_device.c
+++ skge-phy/drivers/net/phy/phy_device.c
@@ -370,7 +370,7 @@ int genphy_config_advert(struct phy_devi
 
 	return adv;
 }
-
+EXPORT_SYMBOL(genphy_config_advert);
 
 /* genphy_setup_forced
  *
@@ -443,7 +443,7 @@ int genphy_config_aneg(struct phy_device
 
 	return err;
 }
-
+EXPORT_SYMBOL(genphy_config_aneg);
 
 /* genphy_update_link
  *
@@ -567,7 +567,7 @@ int genphy_read_status(struct phy_device
 
 	return 0;
 }
-
+EXPORT_SYMBOL(genphy_read_status);
 
 static int genphy_probe(struct phy_device *phydev)
 {
@@ -624,7 +624,7 @@ static int genphy_probe(struct phy_devic
  *   set the state to READY (the driver's probe function should
  *   set it to STARTING if needed).
  */
-int phy_probe(struct device *dev)
+static int phy_probe(struct device *dev)
 {
 	struct phy_device *phydev;
 	struct phy_driver *phydrv;
@@ -662,7 +662,7 @@ int phy_probe(struct device *dev)
 	return err;
 }
 
-int phy_remove(struct device *dev)
+static int phy_remove(struct device *dev)
 {
 	struct phy_device *phydev;
 
@@ -701,13 +701,15 @@ int phy_driver_register(struct phy_drive
 
 	return retval;
 }
+EXPORT_SYMBOL(phy_driver_register);
 
 void phy_driver_unregister(struct phy_driver *drv)
 {
 	driver_unregister(&drv->driver);
 }
+EXPORT_SYMBOL(phy_driver_unregister);
 
-struct phy_driver genphy_driver = {
+static struct phy_driver genphy_driver = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
@@ -715,15 +717,13 @@ struct phy_driver genphy_driver = {
 	.features	= 0,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.driver	=	{.owner	= THIS_MODULE, },
 };
 
 static int __init genphy_init(void)
 {
-	int retval;
-
-	retval = phy_driver_register(&genphy_driver);
+	return phy_driver_register(&genphy_driver);
 
-	return retval;
 }
 
 static void __exit genphy_exit(void)
Index: skge-phy/drivers/net/phy/mdio_bus.c
===================================================================
--- skge-phy.orig/drivers/net/phy/mdio_bus.c
+++ skge-phy/drivers/net/phy/mdio_bus.c
@@ -124,7 +124,7 @@ EXPORT_SYMBOL(unregister_mdiobus);
  * description: Given a PHY device, and a PHY driver, return 1 if
  *   the driver supports the device.  Otherwise, return 0
  */
-int mdio_bus_match(struct device *dev, struct device_driver *drv)
+static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 {
 	struct phy_device *phydev = to_phy_device(dev);
 	struct phy_driver *phydrv = to_phy_driver(drv);
@@ -170,7 +170,7 @@ struct bus_type mdio_bus_type = {
 	.resume	= mdio_bus_resume,
 };
 
-int __init mdio_bus_init(void)
+static int __init mdio_bus_init(void)
 {
 	return bus_register(&mdio_bus_type);
 }
Index: skge-phy/drivers/net/phy/cicada.c
===================================================================
--- skge-phy.orig/drivers/net/phy/cicada.c
+++ skge-phy/drivers/net/phy/cicada.c
@@ -65,6 +65,9 @@
 #define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
 #define MII_CIS8201_AUXCONSTAT_100     0x0008
 
+MODULE_DESCRIPTION("Cicadia PHY driver");
+MODULE_AUTHOR("Andy Fleming");
+MODULE_LICENSE("GPL");
 
 static int cis820x_probe(struct phy_device *phydev)
 {
@@ -104,9 +107,9 @@ static int cis820x_config_intr(struct ph
 
 /* Cicada 820x */
 static struct phy_driver cis8204_driver = {
-	0x000fc440,
-	"Cicada Cis8204",
-	0x000fffc0,
+	.phy_id		= 0x000fc440,
+	.name		= "Cicada Cis8204",
+	.phy_id_mask	= 0x000fffc0,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.probe		= &cis820x_probe,
@@ -114,15 +117,12 @@ static struct phy_driver cis8204_driver 
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &cis820x_ack_interrupt,
 	.config_intr	= &cis820x_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
 };
 
-int __init cis8204_init(void)
+static int __init cis8204_init(void)
 {
-	int retval;
-
-	retval = phy_driver_register(&cis8204_driver);
-
-	return retval;
+	return phy_driver_register(&cis8204_driver);
 }
 
 static void __exit cis8204_exit(void)
Index: skge-phy/drivers/net/phy/phy.c
===================================================================
--- skge-phy.orig/drivers/net/phy/phy.c
+++ skge-phy/drivers/net/phy/phy.c
@@ -42,10 +42,7 @@
 int phy_read(struct phy_device *phydev, u16 regnum);
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
 
-/* Convenience functions for reading a given PHY register.
- * This MUST NOT be called from interrupt context,
- * because the bus read function may sleep
- * or generally lock up. */
+/* Convenience functions for reading a given PHY register. */
 int phy_read(struct phy_device *phydev, u16 regnum)
 {
 	int retval;
@@ -57,6 +54,7 @@ int phy_read(struct phy_device *phydev, 
 
 	return retval;
 }
+EXPORT_SYMBOL(phy_read);
 
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
 {
@@ -69,6 +67,7 @@ int phy_write(struct phy_device *phydev,
 
 	return err;
 }
+EXPORT_SYMBOL(phy_write);
 
 
 int phy_clear_interrupt(struct phy_device *phydev)
@@ -236,7 +235,7 @@ static inline int phy_find_valid(int idx
  *   duplexes.  Drop down by one in this order:  1000/FULL,
  *   1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF
  */
-void phy_sanitize_settings(struct phy_device *phydev)
+static void phy_sanitize_settings(struct phy_device *phydev)
 {
 	u32 features = phydev->supported;
 	int idx;
@@ -260,7 +259,7 @@ void phy_sanitize_settings(struct phy_de
  *   1000/FULL, 1000/HALF, 100/FULL, 100/HALF,
  *   10/FULL, 10/HALF.  The function bottoms out at 10/HALF.
  */
-void phy_force_reduction(struct phy_device *phydev)
+static void phy_force_reduction(struct phy_device *phydev)
 {
 	int idx;
 
@@ -323,7 +322,7 @@ static irqreturn_t phy_interrupt(int irq
  *   Otherwise, we enable the interrupts in the PHY.
  *   Returns 0 on success.
  */
-int phy_start_interrupts(struct phy_device *phydev)
+static int phy_start_interrupts(struct phy_device *phydev)
 {
 	int err = 0;
