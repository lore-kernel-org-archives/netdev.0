From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c523: use netstats in net_device structure
Date: Tue, 29 Apr 2008 11:58:42 +0300
Message-ID: <4816E342.5070600@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030200090906090101030604"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42863 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754538AbYD2I7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 04:59:21 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqlgE-0002Li-UZ
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 08:59:18 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 08:59:18 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 08:59:18 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030200090906090101030604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------030200090906090101030604
Content-Type: text/x-patch;
 name="3c523_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c523_netstats.patch"

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 239fc42..dc6e474 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -202,7 +202,6 @@ static void elmc_xmt_int(struct net_device *dev);
 static void elmc_rnr_int(struct net_device *dev);
 
 struct priv {
-	struct net_device_stats stats;
 	unsigned long base;
 	char *memtop;
 	unsigned long mapped_start;		/* Start of ioremap */
@@ -989,18 +988,18 @@ static void elmc_rcv_int(struct net_device *dev)
 					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
 					dev->last_rx = jiffies;
-					p->stats.rx_packets++;
-					p->stats.rx_bytes += totlen;
+					dev->stats.rx_packets++;
+					dev->stats.rx_bytes += totlen;
 				} else {
-					p->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 				}
 			} else {
 				printk(KERN_WARNING "%s: received oversized frame.\n", dev->name);
-				p->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		} else {	/* frame !(ok), only with 'save-bad-frames' */
 			printk(KERN_WARNING "%s: oops! rfd-error-status: %04x\n", dev->name, status);
-			p->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 		p->rfd_top->status = 0;
 		p->rfd_top->last = RFD_SUSP;
@@ -1018,7 +1017,7 @@ static void elmc_rnr_int(struct net_device *dev)
 {
 	struct priv *p = (struct priv *) dev->priv;
 
-	p->stats.rx_errors++;
+	dev->stats.rx_errors++;
 
 	WAIT_4_SCB_CMD();	/* wait for the last cmd */
 	p->scb->cmd = RUC_ABORT;	/* usually the RU is in the 'no resource'-state .. abort it now. */
@@ -1046,24 +1045,24 @@ static void elmc_xmt_int(struct net_device *dev)
 		printk(KERN_WARNING "%s: strange .. xmit-int without a 'COMPLETE'\n", dev->name);
 	}
 	if (status & STAT_OK) {
-		p->stats.tx_packets++;
-		p->stats.collisions += (status & TCMD_MAXCOLLMASK);
+		dev->stats.tx_packets++;
+		dev->stats.collisions += (status & TCMD_MAXCOLLMASK);
 	} else {
-		p->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		if (status & TCMD_LATECOLL) {
 			printk(KERN_WARNING "%s: late collision detected.\n", dev->name);
-			p->stats.collisions++;
+			dev->stats.collisions++;
 		} else if (status & TCMD_NOCARRIER) {
-			p->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 			printk(KERN_WARNING "%s: no carrier detected.\n", dev->name);
 		} else if (status & TCMD_LOSTCTS) {
 			printk(KERN_WARNING "%s: loss of CTS detected.\n", dev->name);
 		} else if (status & TCMD_UNDERRUN) {
-			p->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			printk(KERN_WARNING "%s: DMA underrun detected.\n", dev->name);
 		} else if (status & TCMD_MAXCOLL) {
 			printk(KERN_WARNING "%s: Max. collisions exceeded.\n", dev->name);
-			p->stats.collisions += 16;
+			dev->stats.collisions += 16;
 		}
 	}
 
@@ -1215,12 +1214,12 @@ static struct net_device_stats *elmc_get_stats(struct net_device *dev)
 	ovrn = p->scb->ovrn_errs;
 	p->scb->ovrn_errs -= ovrn;
 
-	p->stats.rx_crc_errors += crc;
-	p->stats.rx_fifo_errors += ovrn;
-	p->stats.rx_frame_errors += aln;
-	p->stats.rx_dropped += rsc;
+	dev->stats.rx_crc_errors += crc;
+	dev->stats.rx_fifo_errors += ovrn;
+	dev->stats.rx_frame_errors += aln;
+	dev->stats.rx_dropped += rsc;
 
-	return &p->stats;
+	return &dev->stats;
 }
 
 /********************************************************

--------------030200090906090101030604--

