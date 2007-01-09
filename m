From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/12] forcedeth: rx skb recycle
Date: Tue, 09 Jan 2007 13:30:13 -0500
Message-ID: <45A3DF35.6010505@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040608060308070406090805"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:5515 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407AbXAIVXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:48 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040608060308070406090805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes the code that recycled the skb on error. This will 
help in reducing the branches in the main data paths.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040608060308070406090805
Content-Type: text/plain;
 name="patch-remove-recycle-skb"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-remove-recycle-skb"

--- orig/drivers/net/forcedeth.c	2007-01-07 22:31:14.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-07 23:07:19.000000000 -0500
@@ -1330,36 +1330,32 @@
 				break;
 		}
 
-		if (np->put_rx_ctx->skb == NULL) {
-
-			skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
-			if (!skb)
-				return 1;
-
+		skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		if (skb) {
 			skb->dev = dev;
 			np->put_rx_ctx->skb = skb;
+			np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
+							     skb->end-skb->data, PCI_DMA_FROMDEVICE);
+			np->put_rx_ctx->dma_len = skb->end-skb->data;
+			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+				np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
+				wmb();
+				np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+				if (np->put_rx.orig++ == np->last_rx.orig)
+					np->put_rx.orig = np->first_rx.orig;
+			} else {
+				np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
+				np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
+				wmb();
+				np->put_rx.ex->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
+				if (np->put_rx.ex++ == np->last_rx.ex)
+					np->put_rx.ex = np->first_rx.ex;
+			}
+			if (np->put_rx_ctx++ == np->last_rx_ctx)
+				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
-			skb = np->put_rx_ctx->skb;
-		}
-		np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
-					skb->end-skb->data, PCI_DMA_FROMDEVICE);
-		np->put_rx_ctx->dma_len = skb->end-skb->data;
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
-			wmb();
-			np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
-			if (np->put_rx.orig++ == np->last_rx.orig)
-				np->put_rx.orig = np->first_rx.orig;
-		} else {
-			np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
-			np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
-			wmb();
-			np->put_rx.ex->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
-			if (np->put_rx.ex++ == np->last_rx.ex)
-				np->put_rx.ex = np->first_rx.ex;
+			return 1;
 		}
-		if (np->put_rx_ctx++ == np->last_rx_ctx)
-			np->put_rx_ctx = np->first_rx_ctx;
 	}
 	return 0;
 }
@@ -1948,6 +1944,8 @@
 		pci_unmap_single(np->pci_dev, np->get_rx_ctx->dma,
 				np->get_rx_ctx->dma_len,
 				PCI_DMA_FROMDEVICE);
+		skb = np->get_rx_ctx->skb;
+		np->get_rx_ctx->skb = NULL;
 
 		{
 			int j;
@@ -1955,39 +1953,46 @@
 			for (j=0; j<64; j++) {
 				if ((j%16) == 0)
 					dprintk("\n%03x:", j);
-				dprintk(" %02x", ((unsigned char*)np->get_rx_ctx->skb->data)[j]);
+				dprintk(" %02x", ((unsigned char*)skb->data)[j]);
 			}
 			dprintk("\n");
 		}
 		/* look at what we actually got: */
 		if (np->desc_ver == DESC_VER_1) {
-			if (!(flags & NV_RX_DESCRIPTORVALID))
+			if (!(flags & NV_RX_DESCRIPTORVALID)) {
+				dev_kfree_skb(skb);
 				goto next_pkt;
+			}
 
 			if (flags & NV_RX_ERROR) {
 				if (flags & NV_RX_MISSEDFRAME) {
 					np->stats.rx_missed_errors++;
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & NV_RX_CRCERR) {
 					np->stats.rx_crc_errors++;
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & NV_RX_OVERFLOW) {
 					np->stats.rx_over_errors++;
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & NV_RX_ERROR4) {
-					len = nv_getlen(dev, np->get_rx_ctx->skb->data, len);
+					len = nv_getlen(dev, skb->data, len);
 					if (len < 0) {
 						np->stats.rx_errors++;
+						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
 				}
@@ -1999,28 +2004,34 @@
 				}
 			}
 		} else {
-			if (!(flags & NV_RX2_DESCRIPTORVALID))
+			if (!(flags & NV_RX2_DESCRIPTORVALID)) {
+				dev_kfree_skb(skb);
 				goto next_pkt;
+			}
 
 			if (flags & NV_RX2_ERROR) {
 				if (flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & NV_RX2_CRCERR) {
 					np->stats.rx_crc_errors++;
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & NV_RX2_OVERFLOW) {
 					np->stats.rx_over_errors++;
 					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 				if (flags & NV_RX2_ERROR4) {
-					len = nv_getlen(dev, np->get_rx_ctx->skb->data, len);
+					len = nv_getlen(dev, skb->data, len);
 					if (len < 0) {
 						np->stats.rx_errors++;
+						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
 				}
@@ -2037,16 +2048,13 @@
 				    flags == NV_RX2_CHECKSUMOK2 ||
 				    flags == NV_RX2_CHECKSUMOK3) {
 					dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
-					np->get_rx_ctx->skb->ip_summed = CHECKSUM_UNNECESSARY;
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
 				} else {
 					dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
 				}
 			}
 		}
 		/* got a valid packet - forward it to the network core */
-		skb = np->get_rx_ctx->skb;
-		np->get_rx_ctx->skb = NULL;
-
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, dev);
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",

--------------040608060308070406090805--
