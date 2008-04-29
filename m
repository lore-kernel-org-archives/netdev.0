From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] acenic: use netstats in net_device structure
Date: Wed, 30 Apr 2008 02:03:55 +0300
Message-ID: <4817A95B.9050609@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030709010504070303050607"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55305 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbYD2XEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 19:04:12 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jqyrn-0003XO-2k
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 23:04:07 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 23:04:07 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 23:04:07 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030709010504070303050607
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
No need to memset it to 0, because it is allocated by kzalloc.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>




--------------030709010504070303050607
Content-Type: text/x-patch;
 name="acenic_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="acenic_netstats.patch"

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 6c19265..e4483de 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -1457,11 +1457,6 @@ static int __devinit ace_init(struct net_device *dev)
 	ace_set_txprd(regs, ap, 0);
 	writel(0, &regs->RxRetCsm);
 
-	/*
-	 * Zero the stats before starting the interface
-	 */
-	memset(&ap->stats, 0, sizeof(ap->stats));
-
        /*
 	* Enable DMA engine now.
 	* If we do this sooner, Mckinley box pukes.
@@ -2041,8 +2036,8 @@ static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 			netif_rx(skb);
 
 		dev->last_rx = jiffies;
-		ap->stats.rx_packets++;
-		ap->stats.rx_bytes += retdesc->size;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += retdesc->size;
 
 		idx = (idx + 1) % RX_RETURN_RING_ENTRIES;
 	}
@@ -2090,8 +2085,8 @@ static inline void ace_tx_int(struct net_device *dev,
 		}
 
 		if (skb) {
-			ap->stats.tx_packets++;
-			ap->stats.tx_bytes += skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += skb->len;
 			dev_kfree_skb_irq(skb);
 			info->skb = NULL;
 		}
@@ -2863,11 +2858,11 @@ static struct net_device_stats *ace_get_stats(struct net_device *dev)
 	struct ace_mac_stats __iomem *mac_stats =
 		(struct ace_mac_stats __iomem *)ap->regs->Stats;
 
-	ap->stats.rx_missed_errors = readl(&mac_stats->drop_space);
-	ap->stats.multicast = readl(&mac_stats->kept_mc);
-	ap->stats.collisions = readl(&mac_stats->coll);
+	dev->stats.rx_missed_errors = readl(&mac_stats->drop_space);
+	dev->stats.multicast = readl(&mac_stats->kept_mc);
+	dev->stats.collisions = readl(&mac_stats->coll);
 
-	return &ap->stats;
+	return &dev->stats;
 }
 
 
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 60ed183..4487f32 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -693,7 +693,6 @@ struct ace_private
 				__attribute__ ((aligned (SMP_CACHE_BYTES)));
 	u32			last_tx, last_std_rx, last_mini_rx;
 #endif
-	struct net_device_stats stats;
 	int			pci_using_dac;
 };
 

--------------030709010504070303050607--

