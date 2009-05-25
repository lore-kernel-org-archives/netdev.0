From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: [PATCH 2/5] net: sh_eth: fix TX/RX descriptor not set physical memory
Date: Mon, 25 May 2009 18:53:20 +0900
Message-ID: <4A1A6A90.10909@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.renesas.com ([202.234.163.13]:45888 "EHLO
	mail01.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753013AbZEYJxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 05:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the probrem that TX/RX descirptor not set physical memory.

Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/sh_eth.c |   35 ++++++++++++-----------------------
 1 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index a742297..eb76835 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -263,26 +263,20 @@ static void sh_eth_ring_format(struct net_device *ndev)
 #endif
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
-		rxdesc->addr = (u32)skb->data & ~0x3UL;
+		rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
 		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);

 		/* The size of the buffer is 16 byte boundary. */
-		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 		/* Rx descriptor address set */
 		if (i == 0) {
-			ctrl_outl((u32)rxdesc, ioaddr + RDLAR);
+			ctrl_outl(mdp->rx_desc_dma, ioaddr + RDLAR);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			ctrl_outl((u32)rxdesc, ioaddr + RDFAR);
+			ctrl_outl(mdp->rx_desc_dma, ioaddr + RDFAR);
 #endif
 		}
 	}

-	/* Rx descriptor address set */
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	ctrl_outl((u32)rxdesc, ioaddr + RDFXR);
-	ctrl_outl(0x1, ioaddr + RDFFR);
-#endif
-
 	mdp->dirty_rx = (u32) (i - RX_RING_SIZE);

 	/* Mark the last entry as wrapping the ring. */
@@ -298,19 +292,13 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		txdesc->buffer_length = 0;
 		if (i == 0) {
 			/* Tx descriptor address set */
-			ctrl_outl((u32)txdesc, ioaddr + TDLAR);
+			ctrl_outl(mdp->tx_desc_dma, ioaddr + TDLAR);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			ctrl_outl((u32)txdesc, ioaddr + TDFAR);
+			ctrl_outl(mdp->tx_desc_dma, ioaddr + TDFAR);
 #endif
 		}
 	}

-	/* Tx descriptor address set */
-#if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	ctrl_outl((u32)txdesc, ioaddr + TDFXR);
-	ctrl_outl(0x1, ioaddr + TDFFR);
-#endif
-
 	txdesc->status |= cpu_to_edmac(mdp, TD_TDLE);
 }

@@ -536,7 +524,8 @@ static int sh_eth_rx(struct net_device *ndev)
 			if (desc_status & RD_RFS10)
 				mdp->stats.rx_over_errors++;
 		} else {
-			swaps((char *)(rxdesc->addr & ~0x3), pkt_len + 2);
+			swaps(phys_to_virt(ALIGN(rxdesc->addr, 4)),
+				pkt_len + 2);
 			skb = mdp->rx_skbuff[entry];
 			mdp->rx_skbuff[entry] = NULL;
 			skb_put(skb, pkt_len);
@@ -554,7 +543,7 @@ static int sh_eth_rx(struct net_device *ndev)
 		entry = mdp->dirty_rx % RX_RING_SIZE;
 		rxdesc = &mdp->rx_ring[entry];
 		/* The size of the buffer is 16 byte boundary. */
-		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);

 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = dev_alloc_skb(mdp->rx_buf_sz);
@@ -573,7 +562,7 @@ static int sh_eth_rx(struct net_device *ndev)
 			skb_reserve(skb, RX_OFFSET);
 #endif
 			skb->ip_summed = CHECKSUM_NONE;
-			rxdesc->addr = (u32)skb->data & ~0x3UL;
+			rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
 		}
 		if (entry >= RX_RING_SIZE - 1)
 			rxdesc->status |=
@@ -959,9 +948,9 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	entry = mdp->cur_tx % TX_RING_SIZE;
 	mdp->tx_skbuff[entry] = skb;
 	txdesc = &mdp->tx_ring[entry];
-	txdesc->addr = (u32)(skb->data);
+	txdesc->addr = virt_to_phys(skb->data);
 	/* soft swap. */
-	swaps((char *)(txdesc->addr & ~0x3), skb->len + 2);
+	swaps(phys_to_virt(ALIGN(txdesc->addr, 4)), skb->len + 2);
 	/* write back */
 	__flush_purge_region(skb->data, skb->len);
 	if (skb->len < ETHERSMALL)
-- 
1.5.5

