From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] old-tulip 2104x update
Date: Wed, 17 Mar 2004 14:36:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4058A8A1.1010501@pobox.com>
References: <m3wu5nnzch.fsf@defiant.pm.waw.pl> <m3ish3wi6p.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050606010309090506060401"
Cc: Krzysztof Halasa <khc@pm.waw.pl>, lars.vahlenberg@mandator.com,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Rask Ingemann Lambertsen <rask@sygehus.dk>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <m3ish3wi6p.fsf@defiant.pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050606010309090506060401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Here's a patch versus 2.6 upstream, and also the complete driver if 
that's easier.

Anybody wanna give it a test?

And Rask, don't you have some other patches?

	Jeff




--------------050606010309090506060401
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c	Wed Mar 17 14:33:43 2004
+++ b/drivers/net/tulip/de2104x.c	Wed Mar 17 14:33:43 2004
@@ -28,8 +28,8 @@
  */
 
 #define DRV_NAME		"de2104x"
-#define DRV_VERSION		"0.6"
-#define DRV_RELDATE		"Sep 1, 2003"
+#define DRV_VERSION		"0.7"
+#define DRV_RELDATE		"Mar 17, 2004"
 
 #include <linux/config.h>
 #include <linux/module.h>
@@ -303,7 +303,6 @@
 	struct net_device_stats net_stats;
 
 	struct pci_dev		*pdev;
-	u32			macmode;
 
 	u16			setup_frame[DE_SETUP_FRAME_WORDS];
 
@@ -732,7 +731,7 @@
 	struct de_desc *txd;
 	struct de_desc *dummy_txd = NULL;
 
-	macmode = de->macmode & ~(AcceptAllMulticast | AcceptAllPhys);
+	macmode = dr32(MacMode) & ~(AcceptAllMulticast | AcceptAllPhys);
 
 	if (dev->flags & IFF_PROMISC) {	/* Set promiscuous. */
 		macmode |= AcceptAllMulticast | AcceptAllPhys;
@@ -805,10 +804,8 @@
 	dw32(TxPoll, NormalTxPoll);
 
 out:
-	if (macmode != de->macmode) {
-		dw32 (MacMode, macmode);
-		de->macmode = macmode;
-	}
+	if (macmode != dr32(MacMode))
+		dw32(MacMode, macmode);
 }
 
 static void de_set_rx_mode (struct net_device *dev)
@@ -923,6 +920,7 @@
 static void de_set_media (struct de_private *de)
 {
 	unsigned media = de->media_type;
+	u32 macmode = dr32(MacMode);
 
 	if (de_is_running(de))
 		BUG();
@@ -940,9 +938,9 @@
 	mdelay(10);
 
 	if (media == DE_MEDIA_TP_FD)
-		de->macmode |= FullDuplex;
+		macmode |= FullDuplex;
 	else
-		de->macmode &= ~FullDuplex;
+		macmode &= ~FullDuplex;
 	
 	if (netif_msg_link(de)) {
 		printk(KERN_INFO "%s: set link %s\n"
@@ -951,9 +949,11 @@
 		       de->dev->name, media_name[media],
 		       de->dev->name, dr32(MacMode), dr32(SIAStatus),
 		       dr32(CSR13), dr32(CSR14), dr32(CSR15),
-		       de->dev->name, de->macmode, de->media[media].csr13,
+		       de->dev->name, macmode, de->media[media].csr13,
 		       de->media[media].csr14, de->media[media].csr15);
 	}
+	if (macmode != dr32(MacMode))
+		dw32(MacMode, macmode);
 }
 
 static void de_next_media (struct de_private *de, u32 *media,
@@ -1173,18 +1173,18 @@
 	u32 status, tmp;
 
 	/*
-	 * Reset MAC.  Copied from de4x5.c.
+	 * Reset MAC.  de4x5.c and tulip.c examined for "advice"
+	 * in this area.
 	 */
 
-	tmp = dr32 (BusMode);
-	if (tmp == 0xffffffff)
-		return -ENODEV;
-	mdelay (1);
+	if (dr32(BusMode) == 0xffffffff)
+		return -EBUSY;
 
-	dw32 (BusMode, tmp | CmdReset);
+	/* Reset the chip, holding bit 0 set at least 50 PCI cycles. */
+	dw32 (BusMode, CmdReset);
 	mdelay (1);
 
-	dw32 (BusMode, tmp);
+	dw32 (BusMode, de_bus_mode);
 	mdelay (1);
 
 	for (tmp = 0; tmp < 5; tmp++) {
@@ -1235,11 +1235,12 @@
 static int de_init_hw (struct de_private *de)
 {
 	struct net_device *dev = de->dev;
+	u32 macmode;
 	int rc;
 
 	de_adapter_wake(de);
 	
-	de->macmode = dr32(MacMode) & ~MacModeClear;
+	macmode = dr32(MacMode) & ~MacModeClear;
 
 	rc = de_reset_mac(de);
 	if (rc)
@@ -1250,7 +1251,7 @@
 	dw32(RxRingAddr, de->ring_dma);
 	dw32(TxRingAddr, de->ring_dma + (sizeof(struct de_desc) * DE_RX_RING_SIZE));
 
-	dw32(MacMode, RxTx | de->macmode);
+	dw32(MacMode, RxTx | macmode);
 
 	dr32(RxMissed); /* self-clearing */
 
@@ -1501,7 +1502,7 @@
 		break;
 	}
 	
-	if (de->macmode & FullDuplex)
+	if (dr32(MacMode) & FullDuplex)
 		ecmd->duplex = DUPLEX_FULL;
 	else
 		ecmd->duplex = DUPLEX_HALF;

--------------050606010309090506060401
Content-Type: application/x-bzip2;
 name="de2104x.c.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="de2104x.c.bz2"

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
0CMJEppf5Wilkf/xdyRThQkNR+0coA==
--------------050606010309090506060401--
