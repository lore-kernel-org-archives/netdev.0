From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH,CFT] forcedeth: Remove superflous rx engine stop/start cycles.
Date: Sun, 18 Sep 2005 16:37:12 +0200
Message-ID: <432D7B98.8050307@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050404040603000109000702"
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050404040603000109000702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

Ayaz noticed that forcedeth stops and restarts the rx engine every 3 
seconds (link timeout). The attached patch fixes that.
It also contains a larger whitespace cleanup: I've replaced a few spaces 
in the comments with tabs.

Please test it.

--
    Manfred

--------------050404040603000109000702
Content-Type: text/plain;
 name="patch-forcedeth-045-start_stop_rx"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-045-start_stop_rx"

--- 2.6/drivers/net/forcedeth.c	2005-09-18 16:21:44.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-09-18 16:22:42.000000000 +0200
@@ -80,7 +80,7 @@
  *			   into nv_close, otherwise reenabling for wol can
  *			   cause DMA to kfree'd memory.
  *	0.31: 14 Nov 2004: ethtool support for getting/setting link
- *	                   capabilities.
+ *			   capabilities.
  *	0.32: 16 Apr 2005: RX_ERROR4 handling added.
  *	0.33: 16 May 2005: Support for MCP51 added.
  *	0.34: 18 Jun 2005: Add DEV_NEED_LINKTIMER to all nForce nics.
@@ -89,14 +89,15 @@
  *	0.37: 10 Jul 2005: Additional ethtool support, cleanup of pci id list
  *	0.38: 16 Jul 2005: tx irq rewrite: Use global flags instead of
  *			   per-packet flags.
- *      0.39: 18 Jul 2005: Add 64bit descriptor support.
- *      0.40: 19 Jul 2005: Add support for mac address change.
- *      0.41: 30 Jul 2005: Write back original MAC in nv_close instead
+ *	0.39: 18 Jul 2005: Add 64bit descriptor support.
+ *	0.40: 19 Jul 2005: Add support for mac address change.
+ *	0.41: 30 Jul 2005: Write back original MAC in nv_close instead
  *			   of nv_remove
- *      0.42: 06 Aug 2005: Fix lack of link speed initialization
+ *	0.42: 06 Aug 2005: Fix lack of link speed initialization
  *			   in the second (and later) nv_open call
- *      0.43: 10 Aug 2005: Add support for tx checksum.
- *      0.44: 20 Aug 2005: Add support for scatter gather and segmentation.
+ *	0.43: 10 Aug 2005: Add support for tx checksum.
+ *	0.44: 20 Aug 2005: Add support for scatter gather and segmentation.
+ *	0.45: 18 Sep 2005: Remove nv_stop/start_rx from every link check
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -108,7 +109,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.44"
+#define FORCEDETH_VERSION		"0.45"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -1613,6 +1614,17 @@
 	spin_unlock_irq(&np->lock);
 }
 
+/**
+ * nv_update_linkspeed: Setup the MAC according to the link partner
+ * @dev: Network device to be configured
+ *
+ * The function queries the PHY and checks if there is a link partner.
+ * If yes, then it sets up the MAC accordingly. Otherwise, the MAC is
+ * set to 10 MBit HD.
+ *
+ * The function returns 0 if there is no link partner and 1 if there is
+ * a good link partner.
+ */
 static int nv_update_linkspeed(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
@@ -1752,13 +1764,11 @@
 static void nv_linkchange(struct net_device *dev)
 {
 	if (nv_update_linkspeed(dev)) {
-		if (netif_carrier_ok(dev)) {
-			nv_stop_rx(dev);
-		} else {
+		if (!netif_carrier_ok(dev)) {
 			netif_carrier_on(dev);
 			printk(KERN_INFO "%s: link up.\n", dev->name);
+			nv_start_rx(dev);
 		}
-		nv_start_rx(dev);
 	} else {
 		if (netif_carrier_ok(dev)) {
 			netif_carrier_off(dev);

--------------050404040603000109000702--
