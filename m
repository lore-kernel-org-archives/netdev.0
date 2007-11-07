From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 2/2] pasemi_mac: Fix CRC checks
Date: Tue, 6 Nov 2007 22:21:38 -0600
Message-ID: <20071107042138.GE22637@lixom.net>
References: <20071107042001.GC22637@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56854 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754843AbXKGEMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 23:12:19 -0500
Content-Disposition: inline
In-Reply-To: <20071107042001.GC22637@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure we don't feed packets with bad CRC up the network stack,
and discount the packet length as reported from the MAC for the CRC
field.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -580,6 +580,16 @@ static int pasemi_mac_clean_rx(struct pa
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
+		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
+
+		if (macrx & XCT_MACRX_CRC) {
+			/* CRC error flagged */
+			mac->netdev->stats.rx_errors++;
+			mac->netdev->stats.rx_crc_errors++;
+			dev_kfree_skb_irq(skb);
+			goto next;
+		}
+
 		if (len < 256) {
 			struct sk_buff *new_skb;
 
@@ -595,11 +605,10 @@ static int pasemi_mac_clean_rx(struct pa
 		} else
 			info->skb = NULL;
 
-		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
-
 		info->dma = 0;
 
-		skb_put(skb, len);
+		/* Don't include CRC */
+		skb_put(skb, len-4);
 
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -614,6 +623,7 @@ static int pasemi_mac_clean_rx(struct pa
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
 
+next:
 		RX_RING(mac, n) = 0;
 		RX_RING(mac, n+1) = 0;
 
