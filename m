From: Anton Blanchard <anton@samba.org>
Subject: Allow IP header alignment to be overriden
Date: Fri, 11 Jun 2004 11:27:27 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040611012727.GA27672@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

The networking layer currently aligns IP headers in rx packets. It does
this via skb_reserve(,2).

On some architectures (like ppc64) we handle most unaligned accesses in
hardware. This means we gain little from this header alignment. However
forcing this alignment means we attempt to DMA from an unaligned
address.

In the lab we see DMAs beginning at 2 bytes into the page. On some of
our chips we have to do power of 2 writes of increasing size until we
hit a reasonable alignment. It was noticeable on gigabit and now with
10Gbit appearing its becoming a real problem.

Id be surprised if other architectures arent seeing similar issues, with
bridges that disconnect at power of two boundaries.

The following patch creates skb_align and allows an architecture to
override it. Thoughts?

Anton

===== drivers/net/acenic.c 1.44 vs edited =====
--- 1.44/drivers/net/acenic.c	Tue Apr  6 18:01:26 2004
+++ edited/drivers/net/acenic.c	Fri Jun 11 08:09:27 2004
@@ -1695,7 +1695,7 @@
 		/*
 		 * Make sure IP header starts on a fresh cache line.
 		 */
-		skb_reserve(skb, 2 + 16);
+		skb_align(skb, 2 + 16);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
 				       ACE_STD_BUFSIZE - (2 + 16),
@@ -1761,7 +1761,7 @@
 		/*
 		 * Make sure the IP header ends up on a fresh cache line
 		 */
-		skb_reserve(skb, 2 + 16);
+		skb_align(skb, 2 + 16);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
 				       ACE_MINI_BUFSIZE - (2 + 16),
@@ -1822,7 +1822,7 @@
 		/*
 		 * Make sure the IP header ends up on a fresh cache line
 		 */
-		skb_reserve(skb, 2 + 16);
+		skb_align(skb, 2 + 16);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
 				       ACE_JUMBO_BUFSIZE - (2 + 16),
===== drivers/net/e100.c 1.15 vs edited =====
--- 1.15/drivers/net/e100.c	Sat Jun  5 01:49:59 2004
+++ edited/drivers/net/e100.c	Fri Jun 11 08:00:49 2004
@@ -1395,7 +1395,7 @@
 
 	/* Align, init, and map the RFD. */
 	rx->skb->dev = nic->netdev;
-	skb_reserve(rx->skb, rx_offset);
+	skb_align(rx->skb, rx_offset);
 	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
 		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
===== drivers/net/s2io.c 1.5 vs edited =====
--- 1.5/drivers/net/s2io.c	Fri Jun  4 12:00:15 2004
+++ edited/drivers/net/s2io.c	Fri Jun 11 08:06:52 2004
@@ -1431,7 +1431,7 @@
 			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
 			return -ENOMEM;
 		}
-		skb_reserve(skb, HEADER_ALIGN_LAYER_3);
+		skb_align(skb, HEADER_ALIGN_LAYER_3);
 		memset(rxdp, 0, sizeof(RxD_t));
 		rxdp->Buffer0_ptr = pci_map_single
 		    (nic->pdev, skb->data, size, PCI_DMA_FROMDEVICE);
===== drivers/net/tg3.c 1.180 vs edited =====
--- 1.180/drivers/net/tg3.c	Sat Jun  5 01:49:59 2004
+++ edited/drivers/net/tg3.c	Fri Jun 11 08:07:28 2004
@@ -2472,7 +2472,7 @@
 				goto drop_it_no_recycle;
 
 			copy_skb->dev = tp->dev;
-			skb_reserve(copy_skb, 2);
+			skb_align(copy_skb, 2);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 			memcpy(copy_skb->data, skb->data, len);
===== drivers/net/e1000/e1000_ethtool.c 1.45 vs edited =====
--- 1.45/drivers/net/e1000/e1000_ethtool.c	Fri May 28 06:59:25 2004
+++ edited/drivers/net/e1000/e1000_ethtool.c	Fri Jun 11 08:10:26 2004
@@ -1008,7 +1008,7 @@
 			ret_val = 6;
 			goto err_nomem;
 		}
-		skb_reserve(skb, 2);
+		skb_align(skb, 2);
 		rxdr->buffer_info[i].skb = skb;
 		rxdr->buffer_info[i].length = E1000_RXBUFFER_2048;
 		rxdr->buffer_info[i].dma =
===== drivers/net/e1000/e1000_main.c 1.118 vs edited =====
--- 1.118/drivers/net/e1000/e1000_main.c	Fri Jun  4 10:59:04 2004
+++ edited/drivers/net/e1000/e1000_main.c	Fri Jun 11 08:05:39 2004
@@ -2387,7 +2387,7 @@
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
-		skb_reserve(skb, reserve_len);
+		skb_align(skb, reserve_len);
 
 		skb->dev = netdev;
 
===== drivers/net/ixgb/ixgb_main.c 1.13 vs edited =====
--- 1.13/drivers/net/ixgb/ixgb_main.c	Tue Jun  1 10:01:23 2004
+++ edited/drivers/net/ixgb/ixgb_main.c	Fri Jun 11 08:41:13 2004
@@ -1906,7 +1906,7 @@
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
-		skb_reserve(skb, reserve_len);
+		skb_align(skb, reserve_len);
 
 		skb->dev = netdev;
 
===== include/asm-ppc64/system.h 1.28 vs edited =====
--- 1.28/include/asm-ppc64/system.h	Fri May 21 17:50:12 2004
+++ edited/include/asm-ppc64/system.h	Fri Jun 11 08:39:11 2004
@@ -277,5 +277,15 @@
 				    (unsigned long)_n_, sizeof(*(ptr))); \
   })
 
+/*
+ * We handle most unaligned accesses in hardware. On the other hand 
+ * unaligned DMA can be very expensive on some ppc64 IO chips (it does
+ * powers of 2 writes until it reaches sufficient alignment.
+ *
+ * Based on this we disable the IP header alignment in network drivers.
+ */
+#define ARCH_HAS_SKB_ALIGN
+#define skb_align(SKB, LEN)     do { } while (0)
+
 #endif /* __KERNEL__ */
 #endif
===== include/linux/skbuff.h 1.43 vs edited =====
--- 1.43/include/linux/skbuff.h	Mon May 31 05:09:46 2004
+++ edited/include/linux/skbuff.h	Fri Jun 11 08:27:42 2004
@@ -816,6 +816,20 @@
 	skb->tail += len;
 }
 
+/**
+ *	skb_align - align a buffer
+ *	@skb: buffer to alter
+ *	@len: bytes required to align
+ *
+ * 	Shift a buffer by len bytes for the purposes of alignment. On
+ * 	some architectures that handle unaligned accesses in hardware
+ * 	the effects of unaligned DMA is more costly so we allow it to
+ * 	be overridden. This is only allowed for an empty buffer.
+ */
+#ifndef ARCH_HAS_SKB_ALIGN
+#define skb_align(SKB, LEN)	skb_reserve((SKB), (LEN))
+#endif
+
 extern int ___pskb_trim(struct sk_buff *skb, unsigned int len, int realloc);
 
 static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
