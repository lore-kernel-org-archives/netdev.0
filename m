From: Anton Blanchard <anton@samba.org>
Subject: Re: Allow IP header alignment to be overriden
Date: Wed, 16 Jun 2004 09:34:23 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615233423.GC3228@krispykreme>
References: <20040611012727.GA27672@krispykreme> <20040610223549.5e9ad025.davem@redhat.com> <1086939562.3657.10.camel@sfeldma-mobl2.dsl-verizon.net> <20040611142336.GE27672@krispykreme> <20040612111218.783f587d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@pobox.com, netdev@oss.sgi.com, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, leonid.grossman@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040612111218.783f587d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> Yes.  Please add a paragraph to that comment explaining what "unaligned
> CPU cost" really means, ie. that the IP/TCP header members are going to
> be accessed with alignment less than the types might require on a given
> architecture.
> 
> Then I'll apply this and we can start beating up the drivers.

How does this look? The s2io, ixgb and e1000 drivers are converted.

Anton

===== include/linux/skbuff.h 1.43 vs edited =====
--- 1.43/include/linux/skbuff.h	Mon May 31 05:09:46 2004
+++ edited/include/linux/skbuff.h	Wed Jun 16 08:13:57 2004
@@ -816,6 +816,30 @@
 	skb->tail += len;
 }
 
+/*
+ * CPUs often take a performance hit when accessing unaligned memory
+ * locations. The actual performance hit varies, it can be small if the
+ * hardware handles it or large if we have to take an exception and fix it
+ * in software.
+ *
+ * Since an ethernet header is 14 bytes network drivers often end up with
+ * the IP header at an unaligned offset. The IP header can be aligned by
+ * shifting the start of the packet by 2 bytes. Drivers should do this
+ * with:
+ *
+ * skb_reserve(NET_IP_ALIGN);
+ *
+ * The downside to this alignment of the IP header is that the DMA is now
+ * unaligned. On some architectures the cost of an unaligned DMA is high
+ * and this cost outweighs the gains made by aligning the IP header.
+ * 
+ * Since this trade off varies between architectures, we allow NET_IP_ALIGN
+ * to be overridden.
+ */
+#ifndef NET_IP_ALIGN
+#define NET_IP_ALIGN	2
+#endif
+
 extern int ___pskb_trim(struct sk_buff *skb, unsigned int len, int realloc);
 
 static inline void __skb_trim(struct sk_buff *skb, unsigned int lenj
===== include/asm-ppc64/system.h 1.28 vs edited =====
--- 1.28/include/asm-ppc64/system.h	Fri May 21 17:50:12 2004
+++ edited/include/asm-ppc64/system.h	Wed Jun 16 08:15:28 2004
@@ -277,5 +277,14 @@
 				    (unsigned long)_n_, sizeof(*(ptr))); \
   })
 
+/*
+ * We handle most unaligned accesses in hardware. On the other hand 
+ * unaligned DMA can be very expensive on some ppc64 IO chips (it does
+ * powers of 2 writes until it reaches sufficient alignment).
+ *
+ * Based on this we disable the IP header alignment in network drivers.
+ */
+#define NET_IP_ALIGN   0
+
 #endif /* __KERNEL__ */
 #endif
===== drivers/net/s2io.c 1.5 vs edited =====
--- 1.5/drivers/net/s2io.c	Fri Jun  4 12:00:15 2004
+++ edited/drivers/net/s2io.c	Wed Jun 16 08:18:15 2004
@@ -1425,13 +1425,13 @@
 			goto end;
 		}
 
-		skb = dev_alloc_skb(size + HEADER_ALIGN_LAYER_3);
+		skb = dev_alloc_skb(size + NET_IP_ALIGN);
 		if (!skb) {
 			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
 			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
 			return -ENOMEM;
 		}
-		skb_reserve(skb, HEADER_ALIGN_LAYER_3);
+		skb_reserve(skb, NET_IP_ALIGN);
 		memset(rxdp, 0, sizeof(RxD_t));
 		rxdp->Buffer0_ptr = pci_map_single
 		    (nic->pdev, skb->data, size, PCI_DMA_FROMDEVICE);
===== drivers/net/s2io.h 1.4 vs edited =====
--- 1.4/drivers/net/s2io.h	Mon May 31 17:46:35 2004
+++ edited/drivers/net/s2io.h	Wed Jun 16 08:17:23 2004
@@ -411,7 +411,6 @@
 #define HEADER_802_2_SIZE              3
 #define HEADER_SNAP_SIZE               5
 #define HEADER_VLAN_SIZE               4
-#define HEADER_ALIGN_LAYER_3           2
 
 #define MIN_MTU                       46
 #define MAX_PYLD                    1500
===== drivers/net/e1000/e1000_ethtool.c 1.45 vs edited =====
--- 1.45/drivers/net/e1000/e1000_ethtool.c	Fri May 28 06:59:25 2004
+++ edited/drivers/net/e1000/e1000_ethtool.c	Wed Jun 16 08:34:38 2004
@@ -1004,11 +1004,12 @@
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
 		struct sk_buff *skb;
 
-		if(!(skb = alloc_skb(E1000_RXBUFFER_2048 + 2, GFP_KERNEL))) {
+		if(!(skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN,
+				     GFP_KERNEL))) {
 			ret_val = 6;
 			goto err_nomem;
 		}
-		skb_reserve(skb, 2);
+		skb_reserve(skb, NET_IP_ALIGN);
 		rxdr->buffer_info[i].skb = skb;
 		rxdr->buffer_info[i].length = E1000_RXBUFFER_2048;
 		rxdr->buffer_info[i].dma =
===== drivers/net/e1000/e1000_main.c 1.118 vs edited =====
--- 1.118/drivers/net/e1000/e1000_main.c	Fri Jun  4 10:59:04 2004
+++ edited/drivers/net/e1000/e1000_main.c	Wed Jun 16 08:36:58 2004
@@ -2367,7 +2367,6 @@
 	struct e1000_rx_desc *rx_desc;
 	struct e1000_buffer *buffer_info;
 	struct sk_buff *skb;
-	int reserve_len = 2;
 	unsigned int i;
 
 	i = rx_ring->next_to_use;
@@ -2376,7 +2375,7 @@
 	while(!buffer_info->skb) {
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 
-		skb = dev_alloc_skb(adapter->rx_buffer_len + reserve_len);
+		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
 
 		if(!skb) {
 			/* Better luck next round */
@@ -2387,7 +2386,7 @@
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
-		skb_reserve(skb, reserve_len);
+		skb_reserve(skb, NET_IP_ALIGN);
 
 		skb->dev = netdev;
 
===== drivers/net/ixgb/ixgb_main.c 1.13 vs edited =====
--- 1.13/drivers/net/ixgb/ixgb_main.c	Tue Jun  1 10:01:23 2004
+++ edited/drivers/net/ixgb/ixgb_main.c	Wed Jun 16 08:23:28 2004
@@ -1876,7 +1876,6 @@
 	struct ixgb_rx_desc *rx_desc;
 	struct ixgb_buffer *buffer_info;
 	struct sk_buff *skb;
-	int reserve_len = 2;
 	unsigned int i;
 	int num_group_tail_writes;
 	long cleancount;
@@ -1895,7 +1894,7 @@
 	while (--cleancount > 0) {
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 
-		skb = dev_alloc_skb(adapter->rx_buffer_len + reserve_len);
+		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
 			/* Better luck next round */
@@ -1906,7 +1905,7 @@
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed
 		 */
-		skb_reserve(skb, reserve_len);
+		skb_reserve(skb, NET_IP_ALIGN);
 
 		skb->dev = netdev;
 
