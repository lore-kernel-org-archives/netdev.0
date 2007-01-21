From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 8/12] forcedeth: rx data path optimization
Date: Sun, 21 Jan 2007 18:10:52 -0500
Message-ID: <45B3F2FC.7060307@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050807070008040905090009"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:6186 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbXAVBFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 20:05:31 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050807070008040905090009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch optimizes the rx data paths and cleans up the code.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

--------------050807070008040905090009
Content-Type: text/plain;
 name="patch-rx-opti-cleanup"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-rx-opti-cleanup"

--- orig/drivers/net/forcedeth.c	2007-01-19 11:08:24.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-19 11:11:04.000000000 -0500
@@ -1317,9 +1317,9 @@
 			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
 			wmb();
 			np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
-			if (np->put_rx.orig++ == np->last_rx.orig)
+			if (unlikely(np->put_rx.orig++ == np->last_rx.orig))
 				np->put_rx.orig = np->first_rx.orig;
-			if (np->put_rx_ctx++ == np->last_rx_ctx)
+			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
 			return 1;
@@ -1349,9 +1349,9 @@
 			np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
 			wmb();
 			np->put_rx.ex->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
-			if (np->put_rx.ex++ == np->last_rx.ex)
+			if (unlikely(np->put_rx.ex++ == np->last_rx.ex))
 				np->put_rx.ex = np->first_rx.ex;
-			if (np->put_rx_ctx++ == np->last_rx_ctx)
+			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
 			return 1;
@@ -2046,24 +2046,17 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	u32 vlanflags = 0;
-	int count;
-
-	for (count = 0; count < limit; ++count) {
-		struct sk_buff *skb;
-		int len;
-
-		if (np->get_rx.orig == np->put_rx.orig)
-			break;	/* we scanned the whole ring - do not continue */
-		flags = le32_to_cpu(np->get_rx.orig->flaglen);
-		len = nv_descr_getlength(np->get_rx.orig, np->desc_ver);
+	u32 rx_processed_cnt = 0;
+	struct sk_buff *skb;
+	int len;
+
+	while((np->get_rx.orig != np->put_rx.orig) &&
+	      !((flags = le32_to_cpu(np->get_rx.orig->flaglen)) & NV_RX_AVAIL) &&
+		(rx_processed_cnt++ < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_rx_process: flags 0x%x.\n",
 					dev->name, flags);
 
-		if (flags & NV_RX_AVAIL)
-			break;	/* still owned by hardware, */
-
 		/*
 		 * the packet is for us - immediately tear down the pci mapping.
 		 * TODO: check if a prefetch of the first cacheline improves
@@ -2087,99 +2080,80 @@
 		}
 		/* look at what we actually got: */
 		if (np->desc_ver == DESC_VER_1) {
-			if (!(flags & NV_RX_DESCRIPTORVALID)) {
-				dev_kfree_skb(skb);
-				goto next_pkt;
-			}
-
-			if (flags & NV_RX_ERROR) {
-				if (flags & NV_RX_MISSEDFRAME) {
-					np->stats.rx_missed_errors++;
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & NV_RX_CRCERR) {
-					np->stats.rx_crc_errors++;
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & NV_RX_OVERFLOW) {
-					np->stats.rx_over_errors++;
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & NV_RX_ERROR4) {
-					len = nv_getlen(dev, skb->data, len);
-					if (len < 0) {
+			if (likely(flags & NV_RX_DESCRIPTORVALID)) {
+				len = flags & LEN_MASK_V1;
+				if (unlikely(flags & NV_RX_ERROR)) {
+					if (flags & NV_RX_ERROR4) {
+						len = nv_getlen(dev, skb->data, len);
+						if (len < 0) {
+							np->stats.rx_errors++;
+							dev_kfree_skb(skb);
+							goto next_pkt;
+						}
+					}
+					/* framing errors are soft errors */
+					else if (flags & NV_RX_FRAMINGERR) {
+						if (flags & NV_RX_SUBSTRACT1) {
+							len--;
+						}
+					}
+					/* the rest are hard errors */
+					else {
+						if (flags & NV_RX_MISSEDFRAME)
+							np->stats.rx_missed_errors++;
+						if (flags & NV_RX_CRCERR)
+							np->stats.rx_crc_errors++;
+						if (flags & NV_RX_OVERFLOW)
+							np->stats.rx_over_errors++;
 						np->stats.rx_errors++;
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
 				}
-				/* framing errors are soft errors. */
-				if (flags & NV_RX_FRAMINGERR) {
-					if (flags & NV_RX_SUBSTRACT1) {
-						len--;
-					}
-				}
-			}
-		} else {
-			if (!(flags & NV_RX2_DESCRIPTORVALID)) {
+			} else {
 				dev_kfree_skb(skb);
 				goto next_pkt;
 			}
-
-			if (flags & NV_RX2_ERROR) {
-				if (flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & NV_RX2_CRCERR) {
-					np->stats.rx_crc_errors++;
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & NV_RX2_OVERFLOW) {
-					np->stats.rx_over_errors++;
-					np->stats.rx_errors++;
-					dev_kfree_skb(skb);
-					goto next_pkt;
-				}
-				if (flags & NV_RX2_ERROR4) {
-					len = nv_getlen(dev, skb->data, len);
-					if (len < 0) {
+		} else {
+			if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
+				len = flags & LEN_MASK_V2;
+				if (unlikely(flags & NV_RX2_ERROR)) {
+					if (flags & NV_RX2_ERROR4) {
+						len = nv_getlen(dev, skb->data, len);
+						if (len < 0) {
+							np->stats.rx_errors++;
+							dev_kfree_skb(skb);
+							goto next_pkt;
+						}
+					}
+					/* framing errors are soft errors */
+					else if (flags & NV_RX2_FRAMINGERR) {
+						if (flags & NV_RX2_SUBSTRACT1) {
+							len--;
+						}
+					}
+					/* the rest are hard errors */
+					else {
+						if (flags & NV_RX2_CRCERR)
+							np->stats.rx_crc_errors++;
+						if (flags & NV_RX2_OVERFLOW)
+							np->stats.rx_over_errors++;
 						np->stats.rx_errors++;
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
 				}
-				/* framing errors are soft errors */
-				if (flags & NV_RX2_FRAMINGERR) {
-					if (flags & NV_RX2_SUBSTRACT1) {
-						len--;
-					}
-				}
-			}
-			if (np->rx_csum) {
-				flags &= NV_RX2_CHECKSUMMASK;
-				if (flags == NV_RX2_CHECKSUMOK1 ||
-				    flags == NV_RX2_CHECKSUMOK2 ||
-				    flags == NV_RX2_CHECKSUMOK3) {
-					dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
+				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
 				} else {
-					dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
+					if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
+					    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
+						skb->ip_summed = CHECKSUM_UNNECESSARY;
+					}
 				}
+			} else {
+				dev_kfree_skb(skb);
+				goto next_pkt;
 			}
 		}
 		/* got a valid packet - forward it to the network core */
@@ -2188,29 +2162,21 @@
 		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
 					dev->name, len, skb->protocol);
 #ifdef CONFIG_FORCEDETH_NAPI
-		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
-			vlan_hwaccel_receive_skb(skb, np->vlangrp,
-						 vlanflags & NV_RX3_VLAN_TAG_MASK);
-		else
-			netif_receive_skb(skb);
+		netif_receive_skb(skb);
 #else
-		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
-			vlan_hwaccel_rx(skb, np->vlangrp,
-					vlanflags & NV_RX3_VLAN_TAG_MASK);
-		else
-			netif_rx(skb);
+		netif_rx(skb);
 #endif
 		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
 next_pkt:
-		if (np->get_rx.orig++ == np->last_rx.orig)
+		if (unlikely(np->get_rx.orig++ == np->last_rx.orig))
 			np->get_rx.orig = np->first_rx.orig;
-		if (np->get_rx_ctx++ == np->last_rx_ctx)
+		if (unlikely(np->get_rx_ctx++ == np->last_rx_ctx))
 			np->get_rx_ctx = np->first_rx_ctx;
 	}
 
-	return count;
+	return rx_processed_cnt;
 }
 
 static int nv_rx_process_optimized(struct net_device *dev, int limit)
@@ -2218,24 +2184,17 @@
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	u32 vlanflags = 0;
-	int count;
-
-	for (count = 0; count < limit; ++count) {
-		struct sk_buff *skb;
-		int len;
-
-		if (np->get_rx.ex == np->put_rx.ex)
-			break;	/* we scanned the whole ring - do not continue */
-		flags = le32_to_cpu(np->get_rx.ex->flaglen);
-		len = nv_descr_getlength_ex(np->get_rx.ex, np->desc_ver);
-		vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
+	u32 rx_processed_cnt = 0;
+	struct sk_buff *skb;
+	int len;
+
+	while((np->get_rx.ex != np->put_rx.ex) &&
+	      !((flags = le32_to_cpu(np->get_rx.ex->flaglen)) & NV_RX2_AVAIL) &&
+	      (rx_processed_cnt++ < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: flags 0x%x.\n",
 					dev->name, flags);
 
-		if (flags & NV_RX_AVAIL)
-			break;	/* still owned by hardware, */
-
 		/*
 		 * the packet is for us - immediately tear down the pci mapping.
 		 * TODO: check if a prefetch of the first cacheline improves
@@ -2258,84 +2217,91 @@
 			dprintk("\n");
 		}
 		/* look at what we actually got: */
-		if (!(flags & NV_RX2_DESCRIPTORVALID)) {
-			dev_kfree_skb(skb);
-			goto next_pkt;
-		}
-
-		if (flags & NV_RX2_ERROR) {
-			if (flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
-				np->stats.rx_errors++;
-				dev_kfree_skb(skb);
-				goto next_pkt;
-			}
-			if (flags & NV_RX2_CRCERR) {
-				np->stats.rx_crc_errors++;
-				np->stats.rx_errors++;
-				dev_kfree_skb(skb);
-				goto next_pkt;
-			}
-			if (flags & NV_RX2_OVERFLOW) {
-				np->stats.rx_over_errors++;
-				np->stats.rx_errors++;
-				dev_kfree_skb(skb);
-				goto next_pkt;
-			}
-			if (flags & NV_RX2_ERROR4) {
-				len = nv_getlen(dev, skb->data, len);
-				if (len < 0) {
+		if (likely(flags & NV_RX2_DESCRIPTORVALID)) {
+			len = flags & LEN_MASK_V2;
+			if (unlikely(flags & NV_RX2_ERROR)) {
+				if (flags & NV_RX2_ERROR4) {
+					len = nv_getlen(dev, skb->data, len);
+					if (len < 0) {
+						np->stats.rx_errors++;
+						dev_kfree_skb(skb);
+						goto next_pkt;
+					}
+				}
+				/* framing errors are soft errors */
+				else if (flags & NV_RX2_FRAMINGERR) {
+					if (flags & NV_RX2_SUBSTRACT1) {
+						len--;
+					}
+				}
+				/* the rest are hard errors */
+				else {
+					if (flags & NV_RX2_CRCERR)
+						np->stats.rx_crc_errors++;
+					if (flags & NV_RX2_OVERFLOW)
+						np->stats.rx_over_errors++;
 					np->stats.rx_errors++;
 					dev_kfree_skb(skb);
 					goto next_pkt;
 				}
 			}
-			/* framing errors are soft errors */
-			if (flags & NV_RX2_FRAMINGERR) {
-				if (flags & NV_RX2_SUBSTRACT1) {
-					len--;
-				}
-			}
-		}
-		if (np->rx_csum) {
-			flags &= NV_RX2_CHECKSUMMASK;
-			if (flags == NV_RX2_CHECKSUMOK1 ||
-			    flags == NV_RX2_CHECKSUMOK2 ||
-			    flags == NV_RX2_CHECKSUMOK3) {
-				dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
+
+			if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
-				dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
+				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
+				    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				}
 			}
-		}
-		/* got a valid packet - forward it to the network core */
-		skb_put(skb, len);
-		skb->protocol = eth_type_trans(skb, dev);
-		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
-					dev->name, len, skb->protocol);
+
+			/* got a valid packet - forward it to the network core */
+			skb_put(skb, len);
+			skb->protocol = eth_type_trans(skb, dev);
+			prefetch(skb->data);
+
+			dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: %d bytes, proto %d accepted.\n",
+				dev->name, len, skb->protocol);
+
+			if (likely(!np->vlangrp)) {
 #ifdef CONFIG_FORCEDETH_NAPI
-		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
-			vlan_hwaccel_receive_skb(skb, np->vlangrp,
-						 vlanflags & NV_RX3_VLAN_TAG_MASK);
-		else
-			netif_receive_skb(skb);
+				netif_receive_skb(skb);
 #else
-		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
-			vlan_hwaccel_rx(skb, np->vlangrp,
-					vlanflags & NV_RX3_VLAN_TAG_MASK);
-		else
-			netif_rx(skb);
+				netif_rx(skb);
 #endif
-		dev->last_rx = jiffies;
-		np->stats.rx_packets++;
-		np->stats.rx_bytes += len;
+			} else {
+				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
+				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
+#ifdef CONFIG_FORCEDETH_NAPI
+					vlan_hwaccel_receive_skb(skb, np->vlangrp,
+								 vlanflags & NV_RX3_VLAN_TAG_MASK);
+#else
+					vlan_hwaccel_rx(skb, np->vlangrp,
+							vlanflags & NV_RX3_VLAN_TAG_MASK);
+#endif
+				} else {
+#ifdef CONFIG_FORCEDETH_NAPI
+					netif_receive_skb(skb);
+#else
+					netif_rx(skb);
+#endif
+				}
+			}
+
+			dev->last_rx = jiffies;
+			np->stats.rx_packets++;
+			np->stats.rx_bytes += len;
+		} else {
+			dev_kfree_skb(skb);
+		}
 next_pkt:
-		if (np->get_rx.ex++ == np->last_rx.ex)
+		if (unlikely(np->get_rx.ex++ == np->last_rx.ex))
 			np->get_rx.ex = np->first_rx.ex;
-		if (np->get_rx_ctx++ == np->last_rx_ctx)
+		if (unlikely(np->get_rx_ctx++ == np->last_rx_ctx))
 			np->get_rx_ctx = np->first_rx_ctx;
 	}
 
-	return count;
+	return rx_processed_cnt;
 }
 
 static void set_bufsize(struct net_device *dev)

--------------050807070008040905090009--
