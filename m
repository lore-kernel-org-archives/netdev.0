From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: [EXPERIMENTAL PATCH] 2.6 de2104x.c jumbo frames
Date: Tue, 9 Dec 2003 15:39:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209153922.C1345@sygehus.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Attached is a patch which enables jumbo frames on de2104x based boards. It
makes it possible to set an MTU of up to 2025 bytes. However, testing against
an NE3200 board using 10base-2 shows assorted problems when going above 2018
bytes (for frames without VLAN tags). The problems show up as framing
errors, bad CRCs and such (in both directions).

The patch is against 2.6.0-test10 with 2.6.0-test9-bk24-netdrvr-exp1 on top
of it.

-- 
Regards,
Rask Ingemann Lambertsen

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="de2104x-mtu.patch"

--- linux-2.6.0-test8/drivers/net/tulip/de2104x.c-orig	Tue Oct 21 12:34:44 2003
+++ linux-2.6.0-test8/drivers/net/tulip/de2104x.c	Thu Nov 27 01:35:13 2003
@@ -19,7 +19,6 @@
 	  like dl2k.c/sundance.c
 	* Constants (module parms?) for Rx work limit
 	* Complete reset on PciErr
-	* Jumbo frames / dev->change_mtu
 	* Adjust Rx FIFO threshold and Max Rx DMA burst on Rx FIFO error
 	* Adjust Tx FIFO threshold and Max Tx DMA burst on Tx FIFO error
 	* Implement Tx software interrupt mitigation via
@@ -36,6 +35,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
@@ -67,11 +67,13 @@
 MODULE_PARM (debug, "i");
 MODULE_PARM_DESC (debug, "de2104x bitmapped message enable number");
 
+#define PKT_BUF_SZ_MAX		2047	/* Maximum Rx buffer size. */
+
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
         || defined(__sparc_) || defined(__ia64__) \
         || defined(__sh__) || defined(__mips__)
-static int rx_copybreak = 1518;
+static int rx_copybreak = PKT_BUF_SZ_MAX;
 #else
 static int rx_copybreak = 100;
 #endif
@@ -403,7 +410,7 @@
 	int rc;
 
 	while (rx_work--) {
-		u32 status, len;
+		u32 status, len, status_hacked;
 		dma_addr_t mapping;
 		struct sk_buff *skb, *copy_skb;
 		unsigned copying_skb, buflen;
@@ -424,7 +431,13 @@
 			goto rx_next;
 		}
 
-		if (unlikely((status & 0x38008300) != 0x0300)) {
+		/* Ugly Jumbo frame hack. Remove error flag on long frames. */
+		if ((status & (RxErrLong | RxErrCRC | RxErrFIFO | RxErrRunt | RxErrFrame)) == RxErrLong)
+			status_hacked = status & ~(RxError | RxErrLong);
+		else
+			status_hacked = status;
+
+		if (unlikely((status_hacked & 0x38008300) != 0x0300)) {
 			de_rx_err_acct(de, rx_tail, status, len);
 			goto rx_next;
 		}
@@ -1372,6 +1390,8 @@
 		printk(KERN_DEBUG "%s: enabling interface\n", dev->name);
 
 	de->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
+	if (de->rx_buf_sz > PKT_BUF_SZ_MAX)
+		de->rx_buf_sz = PKT_BUF_SZ_MAX;
 
 	rc = de_alloc_rings(de);
 	if (rc) {
@@ -1464,6 +1482,18 @@
 	netif_wake_queue(dev);
 }
 
+static int de_change_mtu (struct net_device *dev, int mtu)
+{
+	if (netif_running (dev))
+		return (-EBUSY);
+
+	if (mtu < 0 || mtu > PKT_BUF_SZ_MAX - VLAN_ETH_HLEN - 4)
+		return (-EINVAL);
+
+	dev->mtu = mtu;
+	return (0);
+}
+
 static void __de_get_regs(struct de_private *de, u8 *buf)
 {
 	int i;
@@ -1964,6 +1994,7 @@
 	dev->ethtool_ops = &de_ethtool_ops;
 	dev->tx_timeout = de_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+	dev->change_mtu = de_change_mtu;
 
 	dev->irq = pdev->irq;
 

--uAKRQypu60I7Lcqm--
