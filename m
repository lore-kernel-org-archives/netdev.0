From: Anton Blanchard <anton@samba.org>
Subject: Use NET_IP_ALIGN in acenic
Date: Sun, 25 Jul 2004 03:43:48 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724174348.GL4556@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jes@trained-monkey.org, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Use NET_IP_ALIGN in acenic driver. Also remove the 16 byte padding,
caches can be anywhere from 16 to 256 bytes and the skb should be
cacheline aligned already.

Signed-off-by: Anton Blanchard <anton@samba.org>

===== drivers/net/acenic.c 1.50 vs edited =====
--- 1.50/drivers/net/acenic.c	Thu Jul 15 05:12:55 2004
+++ edited/drivers/net/acenic.c	Mon Jul 19 12:03:55 2004
@@ -369,9 +369,9 @@
  */
 #define ACE_MINI_SIZE		100
 
-#define ACE_MINI_BUFSIZE	(ACE_MINI_SIZE + 2 + 16)
-#define ACE_STD_BUFSIZE		(ACE_STD_MTU + ETH_HLEN + 2+4+16)
-#define ACE_JUMBO_BUFSIZE	(ACE_JUMBO_MTU + ETH_HLEN + 2+4+16)
+#define ACE_MINI_BUFSIZE	ACE_MINI_SIZE
+#define ACE_STD_BUFSIZE		(ACE_STD_MTU + ETH_HLEN + 4)
+#define ACE_JUMBO_BUFSIZE	(ACE_JUMBO_MTU + ETH_HLEN + 4)
 
 /*
  * There seems to be a magic difference in the effect between 995 and 996
@@ -678,7 +678,7 @@
 			ringp = &ap->skb->rx_std_skbuff[i];
 			mapping = pci_unmap_addr(ringp, mapping);
 			pci_unmap_page(ap->pdev, mapping,
-				       ACE_STD_BUFSIZE - (2 + 16),
+				       ACE_STD_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 
 			ap->rx_std_ring[i].size = 0;
@@ -698,7 +698,7 @@
 				ringp = &ap->skb->rx_mini_skbuff[i];
 				mapping = pci_unmap_addr(ringp,mapping);
 				pci_unmap_page(ap->pdev, mapping,
-					       ACE_MINI_BUFSIZE - (2 + 16),
+					       ACE_MINI_BUFSIZE,
 					       PCI_DMA_FROMDEVICE);
 
 				ap->rx_mini_ring[i].size = 0;
@@ -717,7 +717,7 @@
 			ringp = &ap->skb->rx_jumbo_skbuff[i];
 			mapping = pci_unmap_addr(ringp, mapping);
 			pci_unmap_page(ap->pdev, mapping,
-				       ACE_JUMBO_BUFSIZE - (2 + 16),
+				       ACE_JUMBO_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 
 			ap->rx_jumbo_ring[i].size = 0;
@@ -1257,7 +1257,7 @@
 	set_aceaddr(&info->stats2_ptr, (dma_addr_t) tmp_ptr);
 
 	set_aceaddr(&info->rx_std_ctrl.rngptr, ap->rx_ring_base_dma);
-	info->rx_std_ctrl.max_len = ACE_STD_MTU + ETH_HLEN + 4;
+	info->rx_std_ctrl.max_len = ACE_STD_BUFSIZE;
 	info->rx_std_ctrl.flags =
 	  RCB_FLG_TCP_UDP_SUM | RCB_FLG_NO_PSEUDO_HDR | ACE_RCB_VLAN_FLAG;
 
@@ -1700,17 +1700,14 @@
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_STD_BUFSIZE, GFP_ATOMIC);
+		skb = alloc_skb(ACE_STD_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
 		if (!skb)
 			break;
 
-		/*
-		 * Make sure IP header starts on a fresh cache line.
-		 */
-		skb_reserve(skb, 2 + 16);
+		skb_reserve(skb, NET_IP_ALIGN);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
-				       ACE_STD_BUFSIZE - (2 + 16),
+				       ACE_STD_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 		ap->skb->rx_std_skbuff[idx].skb = skb;
 		pci_unmap_addr_set(&ap->skb->rx_std_skbuff[idx],
@@ -1718,7 +1715,7 @@
 
 		rd = &ap->rx_std_ring[idx];
 		set_aceaddr(&rd->addr, mapping);
-		rd->size = ACE_STD_MTU + ETH_HLEN + 4;
+		rd->size = ACE_STD_BUFSIZE;
 		rd->idx = idx;
 		idx = (idx + 1) % RX_STD_RING_ENTRIES;
 	}
@@ -1766,17 +1763,14 @@
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_MINI_BUFSIZE, GFP_ATOMIC);
+		skb = alloc_skb(ACE_MINI_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
 		if (!skb)
 			break;
 
-		/*
-		 * Make sure the IP header ends up on a fresh cache line
-		 */
-		skb_reserve(skb, 2 + 16);
+		skb_reserve(skb, NET_IP_ALIGN);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
-				       ACE_MINI_BUFSIZE - (2 + 16),
+				       ACE_MINI_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 		ap->skb->rx_mini_skbuff[idx].skb = skb;
 		pci_unmap_addr_set(&ap->skb->rx_mini_skbuff[idx],
@@ -1784,7 +1778,7 @@
 
 		rd = &ap->rx_mini_ring[idx];
 		set_aceaddr(&rd->addr, mapping);
-		rd->size = ACE_MINI_SIZE;
+		rd->size = ACE_MINI_BUFSIZE;
 		rd->idx = idx;
 		idx = (idx + 1) % RX_MINI_RING_ENTRIES;
 	}
@@ -1827,17 +1821,14 @@
 		struct rx_desc *rd;
 		dma_addr_t mapping;
 
-		skb = alloc_skb(ACE_JUMBO_BUFSIZE, GFP_ATOMIC);
+		skb = alloc_skb(ACE_JUMBO_BUFSIZE + NET_IP_ALIGN, GFP_ATOMIC);
 		if (!skb)
 			break;
 
-		/*
-		 * Make sure the IP header ends up on a fresh cache line
-		 */
-		skb_reserve(skb, 2 + 16);
+		skb_reserve(skb, NET_IP_ALIGN);
 		mapping = pci_map_page(ap->pdev, virt_to_page(skb->data),
 				       offset_in_page(skb->data),
-				       ACE_JUMBO_BUFSIZE - (2 + 16),
+				       ACE_JUMBO_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 		ap->skb->rx_jumbo_skbuff[idx].skb = skb;
 		pci_unmap_addr_set(&ap->skb->rx_jumbo_skbuff[idx],
@@ -1845,7 +1836,7 @@
 
 		rd = &ap->rx_jumbo_ring[idx];
 		set_aceaddr(&rd->addr, mapping);
-		rd->size = ACE_JUMBO_MTU + ETH_HLEN + 4;
+		rd->size = ACE_JUMBO_BUFSIZE;
 		rd->idx = idx;
 		idx = (idx + 1) % RX_JUMBO_RING_ENTRIES;
 	}
@@ -2027,19 +2018,19 @@
 			 */
 		case 0:
 			rip = &ap->skb->rx_std_skbuff[skbidx];
-			mapsize = ACE_STD_BUFSIZE - (2 + 16);
+			mapsize = ACE_STD_BUFSIZE;
 			rxdesc = &ap->rx_std_ring[skbidx];
 			std_count++;
 			break;
 		case BD_FLG_JUMBO:
 			rip = &ap->skb->rx_jumbo_skbuff[skbidx];
-			mapsize = ACE_JUMBO_BUFSIZE - (2 + 16);
+			mapsize = ACE_JUMBO_BUFSIZE;
 			rxdesc = &ap->rx_jumbo_ring[skbidx];
 			atomic_dec(&ap->cur_jumbo_bufs);
 			break;
 		case BD_FLG_MINI:
 			rip = &ap->skb->rx_mini_skbuff[skbidx];
-			mapsize = ACE_MINI_BUFSIZE - (2 + 16);
+			mapsize = ACE_MINI_BUFSIZE;
 			rxdesc = &ap->rx_mini_ring[skbidx];
 			mini_count++; 
 			break;
