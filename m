From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.25-rc9] net drivers: fix platform driver hotplug/coldplug
Date: Sun, 13 Apr 2008 23:37:46 -0700
Message-ID: <200804132337.46404.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, kay.sievers@vrfy.org
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp122.sbc.mail.sp1.yahoo.com ([69.147.64.95]:24305 "HELO
	smtp122.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753338AbYDNGhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:37:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kay Sievers <kay.sievers@vrfy.org>

Since 43cc71eed1250755986da4c0f9898f9a635cb3bf, the platform modalias
is prefixed with "platform:". Add MODULE_ALIAS() to the hotpluggable
network platform drivers, to re-enable auto loading.

NOTE: didn't change drivers/net/fs_enet/fs_enet-main.c "old binding"
support.  That looks problematic in the first place (it even uses the
ancient "struct device_driver" binding scheme for platform_bus!) and
I suspect it will vanish soonish when arch/powerpc rules the world.
Also, drivers/net/ne.c would have needed more thought to sort out.

[ dbrownell@users.sourceforge.net: more drivers, registration fixes ]
Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/arm/at91_ether.c  |    1 +
 drivers/net/arm/ep93xx_eth.c  |    2 ++
 drivers/net/ax88796.c         |    1 +
 drivers/net/bfin_mac.c        |    7 +++++--
 drivers/net/cpmac.c           |    2 ++
 drivers/net/dm9000.c          |    1 +
 drivers/net/gianfar.c         |    4 ++++
 drivers/net/irda/ali-ircc.c   |    2 ++
 drivers/net/irda/pxaficp_ir.c |    2 ++
 drivers/net/irda/sa1100_ir.c  |    2 ++
 drivers/net/jazzsonic.c       |    2 ++
 drivers/net/macb.c            |    2 ++
 drivers/net/meth.c            |    2 ++
 drivers/net/mv643xx_eth.c     |    5 ++++-
 drivers/net/netx-eth.c        |    2 +-
 drivers/net/sgiseeq.c         |    2 ++
 drivers/net/smc911x.c         |    2 ++
 drivers/net/smc91x.c          |    2 ++
 drivers/net/sni_82596.c       |    2 ++
 drivers/net/tsi108_eth.c      |    2 ++
 20 files changed, 43 insertions(+), 4 deletions(-)

--- g26.orig/drivers/net/arm/at91_ether.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/arm/at91_ether.c	2008-04-13 20:22:18.000000000 -0700
@@ -1246,3 +1246,4 @@ module_exit(at91ether_exit)
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AT91RM9200 EMAC Ethernet driver");
 MODULE_AUTHOR("Andrew Victor");
+MODULE_ALIAS("platform:" DRV_NAME);
--- g26.orig/drivers/net/arm/ep93xx_eth.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/arm/ep93xx_eth.c	2008-04-13 20:22:25.000000000 -0700
@@ -897,6 +897,7 @@ static struct platform_driver ep93xx_eth
 	.remove		= ep93xx_eth_remove,
 	.driver		= {
 		.name	= "ep93xx-eth",
+		.owner	= THIS_MODULE,
 	},
 };
 
@@ -914,3 +915,4 @@ static void __exit ep93xx_eth_cleanup_mo
 module_init(ep93xx_eth_init_module);
 module_exit(ep93xx_eth_cleanup_module);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:ep93xx-eth");
--- g26.orig/drivers/net/ax88796.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/ax88796.c	2008-04-13 20:13:04.000000000 -0700
@@ -1005,3 +1005,4 @@ module_exit(axdrv_exit);
 MODULE_DESCRIPTION("AX88796 10/100 Ethernet platform driver");
 MODULE_AUTHOR("Ben Dooks, <ben@simtec.co.uk>");
 MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:ax88796");
--- g26.orig/drivers/net/bfin_mac.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/bfin_mac.c	2008-04-13 20:23:42.000000000 -0700
@@ -47,6 +47,7 @@
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION(DRV_DESC);
+MODULE_ALIAS("platform:bfin_mac");
 
 #if defined(CONFIG_BFIN_MAC_USE_L1)
 # define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
@@ -1089,8 +1090,9 @@ static struct platform_driver bfin_mac_d
 	.resume = bfin_mac_resume,
 	.suspend = bfin_mac_suspend,
 	.driver = {
-		   .name = DRV_NAME,
-		   },
+		.name = DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
 };
 
 static int __init bfin_mac_init(void)
@@ -1106,3 +1108,4 @@ static void __exit bfin_mac_cleanup(void
 }
 
 module_exit(bfin_mac_cleanup);
+
--- g26.orig/drivers/net/cpmac.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/cpmac.c	2008-04-13 20:24:24.000000000 -0700
@@ -42,6 +42,7 @@
 MODULE_AUTHOR("Eugene Konev <ejka@imfi.kspu.ru>");
 MODULE_DESCRIPTION("TI AR7 ethernet driver (CPMAC)");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:cpmac");
 
 static int debug_level = 8;
 static int dumb_switch;
@@ -1105,6 +1106,7 @@ static int __devexit cpmac_remove(struct
 
 static struct platform_driver cpmac_driver = {
 	.driver.name = "cpmac",
+	.driver.owner = THIS_MODULE,
 	.probe = cpmac_probe,
 	.remove = __devexit_p(cpmac_remove),
 };
--- g26.orig/drivers/net/dm9000.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/dm9000.c	2008-04-13 20:13:04.000000000 -0700
@@ -1418,3 +1418,4 @@ module_exit(dm9000_cleanup);
 MODULE_AUTHOR("Sascha Hauer, Ben Dooks");
 MODULE_DESCRIPTION("Davicom DM9000 network driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:dm9000");
--- g26.orig/drivers/net/gianfar.c	2008-04-13 20:14:50.000000000 -0700
+++ g26/drivers/net/gianfar.c	2008-04-13 20:35:51.000000000 -0700
@@ -1975,12 +1975,16 @@ static irqreturn_t gfar_error(int irq, v
 	return IRQ_HANDLED;
 }
 
+/* work with hotplug and coldplug */
+MODULE_ALIAS("platform:fsl-gianfar");
+
 /* Structure for a device driver */
 static struct platform_driver gfar_driver = {
 	.probe = gfar_probe,
 	.remove = gfar_remove,
 	.driver	= {
 		.name = "fsl-gianfar",
+		.owner = THIS_MODULE,
 	},
 };
 
--- g26.orig/drivers/net/irda/ali-ircc.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/irda/ali-ircc.c	2008-04-13 22:00:30.000000000 -0700
@@ -60,6 +60,7 @@ static struct platform_driver ali_ircc_d
 	.resume		= ali_ircc_resume,
 	.driver		= {
 		.name	= ALI_IRCC_DRIVER_NAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
@@ -2256,6 +2257,7 @@ static void FIR2SIR(int iobase)
 MODULE_AUTHOR("Benjamin Kong <benjamin_kong@ali.com.tw>");
 MODULE_DESCRIPTION("ALi FIR Controller Driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:" ALI_IRCC_DRIVER_NAME);
 
 
 module_param_array(io, int, NULL, 0);
--- g26.orig/drivers/net/irda/pxaficp_ir.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/irda/pxaficp_ir.c	2008-04-13 20:40:57.000000000 -0700
@@ -897,6 +897,7 @@ static int pxa_irda_remove(struct platfo
 static struct platform_driver pxa_ir_driver = {
 	.driver         = {
 		.name   = "pxa2xx-ir",
+		.owner	= THIS_MODULE,
 	},
 	.probe		= pxa_irda_probe,
 	.remove		= pxa_irda_remove,
@@ -918,3 +919,4 @@ module_init(pxa_irda_init);
 module_exit(pxa_irda_exit);
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:pxa2xx-ir");
--- g26.orig/drivers/net/irda/sa1100_ir.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/irda/sa1100_ir.c	2008-04-13 20:41:13.000000000 -0700
@@ -1008,6 +1008,7 @@ static struct platform_driver sa1100ir_d
 	.resume		= sa1100_irda_resume,
 	.driver		= {
 		.name	= "sa11x0-ir",
+		.owner	= THIS_MODULE,
 	},
 };
 
@@ -1041,3 +1042,4 @@ MODULE_LICENSE("GPL");
 MODULE_PARM_DESC(power_level, "IrDA power level, 1 (low) to 3 (high)");
 MODULE_PARM_DESC(tx_lpm, "Enable transmitter low power (1.6us) mode");
 MODULE_PARM_DESC(max_rate, "Maximum baud rate (4000000, 115200, 57600, 38400, 19200, 9600)");
+MODULE_ALIAS("platform:sa11x0-ir");
--- g26.orig/drivers/net/jazzsonic.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/jazzsonic.c	2008-04-13 22:00:50.000000000 -0700
@@ -249,6 +249,7 @@ out:
 MODULE_DESCRIPTION("Jazz SONIC ethernet driver");
 module_param(sonic_debug, int, 0);
 MODULE_PARM_DESC(sonic_debug, "jazzsonic debug level (1-4)");
+MODULE_ALIAS("platform:jazzsonic");
 
 #include "sonic.c"
 
@@ -271,6 +272,7 @@ static struct platform_driver jazz_sonic
 	.remove	= __devexit_p(jazz_sonic_device_remove),
 	.driver	= {
 		.name	= jazz_sonic_string,
+		.owner	= THIS_MODULE,
 	},
 };
 
--- g26.orig/drivers/net/macb.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/macb.c	2008-04-13 22:01:03.000000000 -0700
@@ -1279,6 +1279,7 @@ static struct platform_driver macb_drive
 	.remove		= __exit_p(macb_remove),
 	.driver		= {
 		.name		= "macb",
+		.owner	= THIS_MODULE,
 	},
 };
 
@@ -1298,3 +1299,4 @@ module_exit(macb_exit);
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Atmel MACB Ethernet driver");
 MODULE_AUTHOR("Haavard Skinnemoen <hskinnemoen@atmel.com>");
+MODULE_ALIAS("platform:macb");
--- g26.orig/drivers/net/meth.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/meth.c	2008-04-13 22:02:03.000000000 -0700
@@ -830,6 +830,7 @@ static struct platform_driver meth_drive
 	.remove	= __devexit_p(meth_remove),
 	.driver = {
 		.name	= "meth",
+		.owner	= THIS_MODULE,
 	}
 };
 
@@ -855,3 +856,4 @@ module_exit(meth_exit_module);
 MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
 MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:meth");
--- g26.orig/drivers/net/mv643xx_eth.c	2008-04-13 20:14:51.000000000 -0700
+++ g26/drivers/net/mv643xx_eth.c	2008-04-13 22:04:31.000000000 -0700
@@ -2049,6 +2049,7 @@ static struct platform_driver mv643xx_et
 	.shutdown = mv643xx_eth_shutdown,
 	.driver = {
 		.name = MV643XX_ETH_NAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
@@ -2057,6 +2058,7 @@ static struct platform_driver mv643xx_et
 	.remove = mv643xx_eth_shared_remove,
 	.driver = {
 		.name = MV643XX_ETH_SHARED_NAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
@@ -2104,7 +2106,8 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
 		" and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
-MODULE_ALIAS("platform:mv643xx_eth");
+MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
+MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
 
 /*
  * The second part is the low level driver of the gigE ethernet ports.
--- g26.orig/drivers/net/netx-eth.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/netx-eth.c	2008-04-13 22:11:36.000000000 -0700
@@ -502,4 +502,4 @@ module_exit(netx_eth_cleanup);
 
 MODULE_AUTHOR("Sascha Hauer, Pengutronix");
 MODULE_LICENSE("GPL");
-
+MODULE_ALIAS("platform:" CARDNAME);
--- g26.orig/drivers/net/sgiseeq.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/sgiseeq.c	2008-04-13 22:13:05.000000000 -0700
@@ -826,6 +826,7 @@ static struct platform_driver sgiseeq_dr
 	.remove	= __devexit_p(sgiseeq_remove),
 	.driver = {
 		.name	= "sgiseeq"
+		.owner	= THIS_MODULE,
 	}
 };
 
@@ -850,3 +851,4 @@ module_exit(sgiseeq_module_exit);
 MODULE_DESCRIPTION("SGI Seeq 8003 driver");
 MODULE_AUTHOR("Linux/MIPS Mailing List <linux-mips@linux-mips.org>");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:sgiseeq");
--- g26.orig/drivers/net/smc911x.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/smc911x.c	2008-04-13 22:13:31.000000000 -0700
@@ -92,6 +92,7 @@ module_param(tx_fifo_kb, int, 0400);
 MODULE_PARM_DESC(tx_fifo_kb,"transmit FIFO size in KB (1<x<15)(default=8)");
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:smc911x");
 
 /*
  * The internal workings of the driver.  If you are changing anything
@@ -2262,6 +2263,7 @@ static struct platform_driver smc911x_dr
 	.resume	 = smc911x_drv_resume,
 	.driver	 = {
 		.name	 = CARDNAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
--- g26.orig/drivers/net/smc91x.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/smc91x.c	2008-04-13 22:13:57.000000000 -0700
@@ -132,6 +132,7 @@ module_param(watchdog, int, 0400);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:smc91x");
 
 /*
  * The internal workings of the driver.  If you are changing anything
@@ -2281,6 +2282,7 @@ static struct platform_driver smc_driver
 	.resume		= smc_drv_resume,
 	.driver		= {
 		.name	= CARDNAME,
+		.owner	= THIS_MODULE,
 	},
 };
 
--- g26.orig/drivers/net/sni_82596.c	2008-04-13 20:12:16.000000000 -0700
+++ g26/drivers/net/sni_82596.c	2008-04-13 22:16:59.000000000 -0700
@@ -44,6 +44,7 @@ static const char sni_82596_string[] = "
 MODULE_AUTHOR("Thomas Bogendoerfer");
 MODULE_DESCRIPTION("i82596 driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:snirm_82596");
 module_param(i596_debug, int, 0);
 MODULE_PARM_DESC(i596_debug, "82596 debug mask");
 
@@ -166,6 +167,7 @@ static struct platform_driver sni_82596_
 	.remove	= __devexit_p(sni_82596_driver_remove),
 	.driver	= {
 		.name	= sni_82596_string,
+		.owner	= THIS_MODULE,
 	},
 };
 
--- g26.orig/drivers/net/tsi108_eth.c	2008-04-13 20:12:17.000000000 -0700
+++ g26/drivers/net/tsi108_eth.c	2008-04-13 22:42:31.000000000 -0700
@@ -162,6 +162,7 @@ static struct platform_driver tsi_eth_dr
 	.remove = tsi108_ether_remove,
 	.driver	= {
 		.name = "tsi-ethernet",
+		.owner = THIS_MODULE,
 	},
 };
 
@@ -1729,3 +1730,4 @@ module_exit(tsi108_ether_exit);
 MODULE_AUTHOR("Tundra Semiconductor Corporation");
 MODULE_DESCRIPTION("Tsi108 Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:tsi-ethernet");
