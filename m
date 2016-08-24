From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 2/3] net: fs_enet: don't unmap DMA when packet len is below
 copybreak
Date: Wed, 24 Aug 2016 12:36:42 +0200 (CEST)
Message-ID: <552651c13fd992acb2d044a356a88e1c78974bef.1472033140.git.christophe.leroy@c-s.fr>
References: <cover.1472033140.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:15503 "EHLO pegase1.c-s.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753012AbcHXKjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 06:39:09 -0400
In-Reply-To: <cover.1472033140.git.christophe.leroy@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the length of the packet is below the defined copybreak limit,
the received packet is copied into a newly allocated skb in order
to reuse the skb. This is only interesting if it allow us to avoid
a new DMA mapping. We shall therefore not DMA unmap and remap the
skb->data. Instead, we invalidate the cache
with dma_sync_single_for_cpu() once the received data has been
copied into the new skb.

The following measures have been obtained on a mpc885 running at 132Mhz.
Measurement is done using the timebase with packets sent to the target
with 'ping -s 1' (packet len is 60):
* Without this patch: 182 TB ticks
* With this patch: 143 TB ticks

As a comparison, if we set the copybreak limit to 0, then we get
148 TB ticks. It means that without this patch, duration is even
worse when copying received data to a new skb instead of
allocating a new skb for next packet to be received

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 36 ++++++++++++----------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 7cd3ef9..addcae6 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -221,21 +221,10 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 			if (sc & BD_ENET_RX_OV)
 				fep->stats.rx_crc_errors++;
 
-			skb = fep->rx_skbuff[curidx];
-
-			dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
-				L1_CACHE_ALIGN(PKT_MAXBUF_SIZE),
-				DMA_FROM_DEVICE);
-
-			skbn = skb;
-
+			skbn = fep->rx_skbuff[curidx];
 		} else {
 			skb = fep->rx_skbuff[curidx];
 
-			dma_unmap_single(fep->dev, CBDR_BUFADDR(bdp),
-				L1_CACHE_ALIGN(PKT_MAXBUF_SIZE),
-				DMA_FROM_DEVICE);
-
 			/*
 			 * Process the incoming frame.
 			 */
@@ -251,12 +240,30 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 					skb_copy_from_linear_data(skb,
 						      skbn->data, pkt_len);
 					swap(skb, skbn);
+					dma_sync_single_for_cpu(fep->dev,
+						CBDR_BUFADDR(bdp),
+						L1_CACHE_ALIGN(pkt_len),
+						DMA_FROM_DEVICE);
 				}
 			} else {
 				skbn = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 
-				if (skbn)
+				if (skbn) {
+					dma_addr_t dma;
+
 					skb_align(skbn, ENET_RX_ALIGN);
+
+					dma_unmap_single(fep->dev,
+						CBDR_BUFADDR(bdp),
+						L1_CACHE_ALIGN(PKT_MAXBUF_SIZE),
+						DMA_FROM_DEVICE);
+
+					dma = dma_map_single(fep->dev,
+						skbn->data,
+						L1_CACHE_ALIGN(PKT_MAXBUF_SIZE),
+						DMA_FROM_DEVICE);
+					CBDW_BUFADDR(bdp, dma);
+				}
 			}
 
 			if (skbn != NULL) {
@@ -271,9 +278,6 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 		}
 
 		fep->rx_skbuff[curidx] = skbn;
-		CBDW_BUFADDR(bdp, dma_map_single(fep->dev, skbn->data,
-			     L1_CACHE_ALIGN(PKT_MAXBUF_SIZE),
-			     DMA_FROM_DEVICE));
 		CBDW_DATLEN(bdp, 0);
 		CBDW_SC(bdp, (sc & ~BD_ENET_RX_STATS) | BD_ENET_RX_EMPTY);
 
-- 
2.1.0
