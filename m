From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] 2.6.x Re: Tulip 21040 hangs with ifconfig promisc
Date: Wed, 17 Mar 2004 17:29:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3ish3wi6p.fsf@defiant.pm.waw.pl>
References: <m3wu5nnzch.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <m3wu5nnzch.fsf@defiant.pm.waw.pl> (Krzysztof Halasa's message
 of "Sun, 14 Mar 2004 17:54:38 +0100")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

Bug (2.6.x Linux, DE21040 tulip):
> Doing "ifconfig eth0 promisc" kills the ethernet. Interrupts are gone,
> nothing in dmesg. -promisc nor ifconfig down/up doesn't fix it,
> only driver rmmod/insmod does.

The attached patch fixes the problem: de->macmode variable,
meant to shadow MacMode (CSR6) register, was used inconsistently,
causing some updates to this register to be dropped.

2.4 kernel doesn't shadow this register at all, so I removed
shadowing from 2.6 as well.
-- 
Krzysztof Halasa, B*FH

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=de2104x-macmode.patch

--- linux-2.6/drivers/net/tulip/de2104x.c	14 Mar 2004 17:05:37 -0000	1.24
+++ linux-2.6/drivers/net/tulip/de2104x.c	17 Mar 2004 16:14:48 -0000
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

--=-=-=--
