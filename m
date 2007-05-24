From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 24 May 2007 18:30:01 -0400
Message-ID: <20070524223001.GA6359@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:55423 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593AbXEXWaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 18:30:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 arch/mips/sgi-ip32/Makefile             |    2 +-
 arch/mips/sgi-ip32/ip32-platform.c      |   20 +++++++++
 drivers/net/Kconfig                     |    2 +-
 drivers/net/chelsio/suni1x10gexp_regs.h |    2 +-
 drivers/net/forcedeth.c                 |    2 +-
 drivers/net/meth.c                      |   68 ++++++++++++++++++++----------
 drivers/net/phy/fixed.c                 |    4 ++
 drivers/net/spider_net.c                |    6 +-
 drivers/net/ucc_geth.c                  |    3 -
 drivers/net/ucc_geth_mii.c              |    2 -
 drivers/net/usb/asix.c                  |    4 ++
 drivers/net/wireless/libertas/decl.h    |    2 +-
 drivers/net/wireless/libertas/fw.c      |   14 ++++--
 drivers/net/wireless/libertas/rx.c      |   24 ++---------
 14 files changed, 95 insertions(+), 60 deletions(-)
 create mode 100644 arch/mips/sgi-ip32/ip32-platform.c

Ayaz Abdulla (1):
      forcedeth: fix cpu irq mask

David Hollis (1):
      asix.c - Add Belkin F5D5055 ids

Denver Gingerich (1):
      fix compiler warning in fixed.c

Eugene Teo (2):
      drivers/net/wireless/libertas/fw.c: fix use-before-check
      drivers/net/wireless/libertas/rx.c: fix use-after-free

Florin Malita (2):
      libertas: skb dereferenced after netif_rx
      spidernet: skb used after netif_receive_skb

Li Yang (2):
      ucc_geth: Fix MODULE_DEVICE_TABLE() duplication
      ucc_geth:trivial fix

Mariusz Kozlowski (1):
      chelsio parenthesis fix

Ralf Baechle (1):
      meth driver renovation

Yoichi Yuasa (1):
      remove unnecessary dependency on VIA velocity config

diff --git a/arch/mips/sgi-ip32/Makefile b/arch/mips/sgi-ip32/Makefile
index 7e14167..60f0227 100644
--- a/arch/mips/sgi-ip32/Makefile
+++ b/arch/mips/sgi-ip32/Makefile
@@ -3,5 +3,5 @@
 # under Linux.
 #
 
-obj-y	+= ip32-berr.o ip32-irq.o ip32-setup.o ip32-reset.o \
+obj-y	+= ip32-berr.o ip32-irq.o ip32-platform.o ip32-setup.o ip32-reset.o \
 	   crime.o ip32-memory.o
diff --git a/arch/mips/sgi-ip32/ip32-platform.c b/arch/mips/sgi-ip32/ip32-platform.c
new file mode 100644
index 0000000..120b159
--- /dev/null
+++ b/arch/mips/sgi-ip32/ip32-platform.c
@@ -0,0 +1,20 @@
+#include <linux/init.h>
+#include <linux/platform_device.h>
+
+static __init int meth_devinit(void)
+{
+	struct platform_device *pd;
+	int ret;
+
+	pd = platform_device_alloc("meth", -1);
+	if (!pd)
+		return -ENOMEM;
+
+	ret = platform_device_add(pd);
+	if (ret)
+		platform_device_put(pd);
+
+	return ret;
+}
+
+device_initcall(meth_devinit);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c5baa19..30fd479 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2218,7 +2218,7 @@ config SK98LIN
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
-	depends on NET_PCI && PCI
+	depends on PCI
 	select CRC32
 	select CRC_CCITT
 	select MII
diff --git a/drivers/net/chelsio/suni1x10gexp_regs.h b/drivers/net/chelsio/suni1x10gexp_regs.h
index 269d097..d0f87d8 100644
--- a/drivers/net/chelsio/suni1x10gexp_regs.h
+++ b/drivers/net/chelsio/suni1x10gexp_regs.h
@@ -105,7 +105,7 @@
 #define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_LOW(filterId) (0x204A + mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId))
 #define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_MID(filterId) (0x204B + mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId))
 #define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_HIGH(filterId)(0x204C + mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId))
-#define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID(filterId)      (0x2062 + mSUNI1x10GEXP_MAC_VID_FILTER_OFFSET(filterId)
+#define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID(filterId)      (0x2062 + mSUNI1x10GEXP_MAC_VID_FILTER_OFFSET(filterId))
 #define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_0_LOW                     0x204A
 #define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_0_MID                     0x204B
 #define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_0_HIGH                    0x204C
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 7a01802..4154fd0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -195,7 +195,7 @@ enum {
 #define NVREG_IRQ_TX_FORCED		0x0100
 #define NVREG_IRQ_RECOVER_ERROR		0x8000
 #define NVREG_IRQMASK_THROUGHPUT	0x00df
-#define NVREG_IRQMASK_CPU		0x0040
+#define NVREG_IRQMASK_CPU		0x0060
 #define NVREG_IRQ_TX_ALL		(NVREG_IRQ_TX_ERR|NVREG_IRQ_TX_OK|NVREG_IRQ_TX_FORCED)
 #define NVREG_IRQ_RX_ALL		(NVREG_IRQ_RX_ERROR|NVREG_IRQ_RX|NVREG_IRQ_RX_NOBUF|NVREG_IRQ_RX_FORCED)
 #define NVREG_IRQ_OTHER			(NVREG_IRQ_TIMER|NVREG_IRQ_LINK|NVREG_IRQ_RECOVER_ERROR)
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 0343ea1..92b403b 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -8,15 +8,16 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  */
-#include <linux/module.h>
-#include <linux/init.h>
-
-#include <linux/kernel.h> /* printk() */
 #include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
 #include <linux/slab.h>
-#include <linux/errno.h>  /* error codes */
-#include <linux/types.h>  /* size_t */
-#include <linux/interrupt.h> /* mark_bh */
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
 
 #include <linux/in.h>
 #include <linux/in6.h>
@@ -33,7 +34,6 @@
 
 #include <asm/io.h>
 #include <asm/scatterlist.h>
-#include <linux/dma-mapping.h>
 
 #include "meth.h"
 
@@ -51,8 +51,6 @@
 
 
 static const char *meth_str="SGI O2 Fast Ethernet";
-MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
-MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
 
 #define HAVE_TX_TIMEOUT
 /* The maximum time waited (in jiffies) before assuming a Tx failed. (400ms) */
@@ -784,15 +782,15 @@ static struct net_device_stats *meth_stats(struct net_device *dev)
 /*
  * The init function.
  */
-static struct net_device *meth_init(void)
+static int __init meth_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct meth_private *priv;
-	int ret;
+	int err;
 
 	dev = alloc_etherdev(sizeof(struct meth_private));
 	if (!dev)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	dev->open            = meth_open;
 	dev->stop            = meth_release;
@@ -808,11 +806,12 @@ static struct net_device *meth_init(void)
 
 	priv = netdev_priv(dev);
 	spin_lock_init(&priv->meth_lock);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	ret = register_netdev(dev);
-	if (ret) {
+	err = register_netdev(dev);
+	if (err) {
 		free_netdev(dev);
-		return ERR_PTR(ret);
+		return err;
 	}
 
 	printk(KERN_INFO "%s: SGI MACE Ethernet rev. %d\n",
@@ -820,21 +819,44 @@ static struct net_device *meth_init(void)
 	return 0;
 }
 
-static struct net_device *meth_dev;
+static int __exit meth_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	unregister_netdev(dev);
+	free_netdev(dev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver meth_driver = {
+	.probe	= meth_probe,
+	.remove	= __devexit_p(meth_remove),
+	.driver = {
+		.name	= "meth",
+	}
+};
 
 static int __init meth_init_module(void)
 {
-	meth_dev = meth_init();
-	if (IS_ERR(meth_dev))
-		return PTR_ERR(meth_dev);
-	return 0;
+	int err;
+
+	err = platform_driver_register(&meth_driver);
+	if (err)
+		printk(KERN_ERR "Driver registration failed\n");
+
+	return err;
 }
 
 static void __exit meth_exit_module(void)
 {
-	unregister_netdev(meth_dev);
-	free_netdev(meth_dev);
+	platform_driver_unregister(&meth_driver);
 }
 
 module_init(meth_init_module);
 module_exit(meth_exit_module);
+
+MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
+MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 68c99b4..bb96691 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -89,6 +89,7 @@ EXPORT_SYMBOL(fixed_mdio_set_link_update);
 /*-----------------------------------------------------------------------------
  *  This is used for updating internal mii regs from the status
  *-----------------------------------------------------------------------------*/
+#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX)
 static int fixed_mdio_update_regs(struct fixed_info *fixed)
 {
 	u16 *regs = fixed->regs;
@@ -165,6 +166,7 @@ static int fixed_mii_reset(struct mii_bus *bus)
 	/*nothing here - no way/need to reset it*/
 	return 0;
 }
+#endif
 
 static int fixed_config_aneg(struct phy_device *phydev)
 {
@@ -194,6 +196,7 @@ static struct phy_driver fixed_mdio_driver = {
  * number is used to create multiple fixed PHYs, so that several devices can
  * utilize them simultaneously.
  *-----------------------------------------------------------------------------*/
+#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX)
 static int fixed_mdio_register_device(int number, int speed, int duplex)
 {
 	struct mii_bus *new_bus;
@@ -301,6 +304,7 @@ device_create_fail:
 
 	return err;
 }
+#endif
 
 
 MODULE_DESCRIPTION("Fixed PHY device & driver for PAL");
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index c3964c3..ef84d7c 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1014,12 +1014,12 @@ spider_net_pass_skb_up(struct spider_net_descr *descr,
 		 */
 	}
 
-	/* pass skb up to stack */
-	netif_receive_skb(skb);
-
 	/* update netdevice statistics */
 	card->netdev_stats.rx_packets++;
 	card->netdev_stats.rx_bytes += skb->len;
+
+	/* pass skb up to stack */
+	netif_receive_skb(skb);
 }
 
 #ifdef DEBUG
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index c2ccbd0..18b731b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -23,11 +23,8 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/fsl_devices.h>
-#include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/workqueue.h>
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index f96966d..7bcb82f 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -260,8 +260,6 @@ static struct of_device_id uec_mdio_match[] = {
 	{},
 };
 
-MODULE_DEVICE_TABLE(of, uec_mdio_match);
-
 static struct of_platform_driver uec_mdio_driver = {
 	.name	= DRV_NAME,
 	.probe	= uec_mdio_probe,
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index d5ef97b..6d95cac 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1458,6 +1458,10 @@ static const struct usb_device_id	products [] = {
 	// IO-DATA ETG-US2
 	USB_DEVICE (0x04bb, 0x0930),
 	.driver_info = (unsigned long) &ax88178_info,
+}, {
+	// Belkin F5D5055
+	USB_DEVICE(0x050d, 0x5055),
+	.driver_info = (unsigned long) &ax88178_info,
 },
 	{ },		// END
 };
diff --git a/drivers/net/wireless/libertas/decl.h b/drivers/net/wireless/libertas/decl.h
index 606bdd0..dfe2764 100644
--- a/drivers/net/wireless/libertas/decl.h
+++ b/drivers/net/wireless/libertas/decl.h
@@ -46,7 +46,7 @@ u32 libertas_index_to_data_rate(u8 index);
 u8 libertas_data_rate_to_index(u32 rate);
 void libertas_get_fwversion(wlan_adapter * adapter, char *fwversion, int maxlen);
 
-int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb);
+void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb);
 
 /** The proc fs interface */
 int libertas_process_rx_command(wlan_private * priv);
diff --git a/drivers/net/wireless/libertas/fw.c b/drivers/net/wireless/libertas/fw.c
index 441123c..5c63c9b 100644
--- a/drivers/net/wireless/libertas/fw.c
+++ b/drivers/net/wireless/libertas/fw.c
@@ -333,18 +333,22 @@ static void command_timer_fn(unsigned long data)
 	unsigned long flags;
 
 	ptempnode = adapter->cur_cmd;
+	if (ptempnode == NULL) {
+		lbs_pr_debug(1, "PTempnode Empty\n");
+		return;
+	}
+
 	cmd = (struct cmd_ds_command *)ptempnode->bufvirtualaddr;
+	if (!cmd) {
+		lbs_pr_debug(1, "cmd is NULL\n");
+		return;
+	}
 
 	lbs_pr_info("command_timer_fn fired (%x)\n", cmd->command);
 
 	if (!adapter->fw_ready)
 		return;
 
-	if (ptempnode == NULL) {
-		lbs_pr_debug(1, "PTempnode Empty\n");
-		return;
-	}
-
 	spin_lock_irqsave(&adapter->driver_lock, flags);
 	adapter->cur_cmd = NULL;
 	spin_unlock_irqrestore(&adapter->driver_lock, flags);
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index d17924f..96619a3 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -136,7 +136,7 @@ static void wlan_compute_rssi(wlan_private * priv, struct rxpd *p_rx_pd)
 	LEAVE();
 }
 
-int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
+void libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 {
 	lbs_pr_debug(1, "skb->data=%p\n", skb->data);
 
@@ -148,8 +148,6 @@ int libertas_upload_rx_packet(wlan_private * priv, struct sk_buff *skb)
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx(skb);
-
-	return 0;
 }
 
 /**
@@ -269,15 +267,11 @@ int libertas_process_rxed_packet(wlan_private * priv, struct sk_buff *skb)
 	wlan_compute_rssi(priv, p_rx_pd);
 
 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
-	if (libertas_upload_rx_packet(priv, skb)) {
-		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet"
-		       " returns failure\n");
-		ret = -1;
-		goto done;
-	}
 	priv->stats.rx_bytes += skb->len;
 	priv->stats.rx_packets++;
 
+	libertas_upload_rx_packet(priv, skb);
+
 	ret = 0;
 done:
 	LEAVE();
@@ -438,22 +432,14 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 	wlan_compute_rssi(priv, prxpd);
 
 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
-
-	if (libertas_upload_rx_packet(priv, skb)) {
-		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet "
-			"returns failure\n");
-		ret = -1;
-		goto done;
-	}
-
 	priv->stats.rx_bytes += skb->len;
 	priv->stats.rx_packets++;
 
+	libertas_upload_rx_packet(priv, skb);
+
 	ret = 0;
 done:
 	LEAVE();
 
-	skb->protocol = __constant_htons(0x0019);	/* ETH_P_80211_RAW */
-
 	return (ret);
 }
