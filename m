From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 3/3] r8169: Jumbo Frames maximum size increase
Date: Wed, 16 Feb 2005 18:23:48 -0600
Message-ID: <200502161823.48769.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch increases the maximum MTU from 7200 to 9500.  It will actually 
work much higher than that, but will start to drop packets after a while.

The amount of changes necessary for this small increase is because of the 
unusual behavior of the adapter (which is undocumented in the adapter spec). 
For rx_buf_sz > 8191, the adapter will partition the frames into multiple 
descriptors.  This in itself is not that difficult to handle, however the 
point on which it partitions them varies dependent on the rx_buf_sz.  After a
bit of trial-and-error, I discovered the formula to be 
(tp->rx_buf_sz - 8192) & 0xfff8.  I have tested it upto MTU 16000 and it 
works for all MTUs.  

That being said, there is an obvious performance hit associated with copying 
all of the parts of the skb into a unified skb.  Therefore, I would recommend
against MTUs > 8169 (the point at which the descriptor partitioning begins).

Tested on amd64 (and very lightly tested on x86).

Applies cleanly to linux-2.6.11-rc2-mm2 version of the driver.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- drivers/net/r8169.c.orig 2005-02-16 17:21:07.000000000 -0600
+++ drivers/net/r8169.c 2005-02-16 17:23:46.000000000 -0600
@@ -111,8 +111,9 @@ static int multicast_filter_limit = 32;
 #define RX_DMA_BURST 6 /* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST 6 /* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld  0x3F /* 0x3F means NO early transmit */
+#define LargeSendETT 0x35
 #define RxPacketMaxSize 0x3FE8 /* 16K - 1 - ETH_HLEN - VLAN - CRC... */
-#define SafeMtu  0x1c20 /* ... actually life sucks beyond ~7k */
+#define SafeMtu  0x251C  /* ... actually life sucks beyond ~9500 */
 #define InterFrameGap 0x03 /* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE  256
@@ -404,6 +405,8 @@ struct rtl8169_private {
  unsigned int (*phy_reset_pending)(void __iomem *);
  unsigned int (*link_ok)(void __iomem *);
  struct work_struct task;
+ struct sk_buff *new_skb;
+ u32 desc_part;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -1462,6 +1465,24 @@ static void rtl8169_set_rxbufsize(struct
  unsigned int mtu = dev->mtu;
 
  tp->rx_buf_sz = (mtu > RX_BUF_SIZE) ? mtu + ETH_HLEN + 8 : RX_BUF_SIZE;
+ 
+ /* 
+  * For rx_buf_sz > 8191, the adapter will carve-up the frames into 
+  * multiple descriptors, based on the formula 
+  * (tp->rx_buf_sz - 8192) & 0xfff8.  For MTU 8225, the packets will be 
+  * destributed across 258 rx descriptors (which will stomp on all the 
+  * descriptors in a 64 entry ring).  We are better off overstating 
+  * rx_buf_sz to 9240, so that it will be a maximum of 9 descriptors.
+  *
+  * Also, Nasty problem where if the rx_buf_sz is between 8192 and 8224
+  * the adapter will go crazy and the system will crash.  To workaround 
+  * this issue, the driver is adding additional space to the rx_buf_sz.
+  */
+ if ((tp->rx_buf_sz > 8191) && (tp->rx_buf_sz < 9240))
+  tp->rx_buf_sz = 9240;
+  
+ tp->desc_part = (tp->rx_buf_sz - 8192) & 0xfff8;
+ 
 }
 
 static int rtl8169_open(struct net_device *dev)
@@ -1549,8 +1570,12 @@ rtl8169_hw_start(struct net_device *dev)
 
  RTL_W8(Cfg9346, Cfg9346_Unlock);
  RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
- RTL_W8(EarlyTxThres, EarlyTxThld);
 
+ if (dev->mtu < 7400)
+  RTL_W8(EarlyTxThres, EarlyTxThld);
+ else
+  RTL_W8(EarlyTxThres, LargeSendETT);
+ 
  /* For gigabit rtl8169, MTU + header + CRC + VLAN */
  RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
@@ -1627,7 +1652,8 @@ out:
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
  desc->addr = 0x0badbadbadbadbadull;
- desc->opts1 &= ~cpu_to_le32(DescOwn | RsvdMask);
+ desc->opts1 &= cpu_to_le32(RingEnd);
+ desc->opts2 = 0;
 }
 
 static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
@@ -1644,7 +1670,9 @@ static void rtl8169_free_rx_skb(struct r
 
 static inline void rtl8169_return_to_asic(struct RxDesc *desc, int rx_buf_sz)
 {
+ desc->opts1 &= cpu_to_le32(RingEnd);
  desc->opts1 |= cpu_to_le32(DescOwn + rx_buf_sz);
+ desc->opts2 = 0;   
 }
 
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping,
@@ -1652,6 +1680,7 @@ static inline void rtl8169_give_to_asic(
 {
  desc->addr = cpu_to_le64(mapping);
  desc->opts1 |= cpu_to_le32(DescOwn + rx_buf_sz);
+ desc->opts2 = 0;   
 }
 
 static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
@@ -2098,24 +2127,52 @@ static inline void rtl8169_rx_csum(struc
   skb->ip_summed = CHECKSUM_NONE;
 }
 
-static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-          struct RxDesc *desc, int rx_buf_sz)
+static inline int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
+    struct RxDesc *desc, struct rtl8169_private *tp)
 {
- int ret = -1;
-
- if (pkt_size < rx_copybreak) {
-  struct sk_buff *skb;
+ u32 status = le32_to_cpu(desc->opts1);
+ 
+ if ((pkt_size > rx_copybreak) && 
+   ((status & FirstFrag) && (status & LastFrag)))
+  return -1;
 
-  skb = dev_alloc_skb(pkt_size + 2);
+ if (status & FirstFrag) {
+  struct sk_buff *skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
   if (skb) {
-   skb_reserve(skb, 2);
-   eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
-   *sk_buff = skb;
-   rtl8169_return_to_asic(desc, rx_buf_sz);
-   ret = 0;
+   skb_reserve(skb, NET_IP_ALIGN);
+   if (pkt_size > rx_copybreak) {
+    memcpy(skb->data, sk_buff[0]->tail, 
+      tp->desc_part);
+    skb_put(skb, tp->desc_part);
+   } else {
+    memcpy(skb->data, sk_buff[0]->tail, pkt_size);
+    skb_put(skb, pkt_size);
+   }
+  } else 
+   printk(KERN_INFO "no rx skb allocated\n");
+  
+  tp->new_skb = skb;
+ }
+
+ if (!(status & FirstFrag) && !(status & LastFrag) && tp->new_skb) {
+  memcpy(tp->new_skb->tail, sk_buff[0]->tail, tp->desc_part);
+  skb_put(tp->new_skb, tp->desc_part);
+ }
+ 
+ if (status & LastFrag) {
+  if (pkt_size > rx_copybreak && tp->new_skb) {
+   memcpy(tp->new_skb->tail, sk_buff[0]->tail,
+     pkt_size - tp->new_skb->len);
+   
+   skb_put(tp->new_skb, pkt_size - tp->new_skb->len);
   }
+  
+  *sk_buff = tp->new_skb;
  }
- return ret;
+
+ rtl8169_return_to_asic(desc, tp->rx_buf_sz);
+
+ return 0;
 }
 
 static int
@@ -2142,8 +2199,15 @@ rtl8169_rx_interrupt(struct net_device *
 
   if (status & DescOwn)
    break;
-  if (status & RxRES) {
-   printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
+
+  /* 
+   * RxRWT is acceptable if Jumbo Frames are enabled.  
+   * Unfortunately, there is no way of disabling this error in 
+   * that case.
+   */
+  if (status & RxRES && !(status & RxRWT)) {
+   printk(KERN_INFO "%s: Rx ERROR %x\n", dev->name, 
+     status);
    tp->stats.rx_errors++;
    if (status & (RxRWT | RxRUNT))
     tp->stats.rx_length_errors++;
@@ -2152,37 +2216,38 @@ rtl8169_rx_interrupt(struct net_device *
   } else {
    struct RxDesc *desc = tp->RxDescArray + entry;
    struct sk_buff *skb = tp->Rx_skbuff[entry];
-   int pkt_size = (status & 0x00001FFF) - 4;
+   int pkt_size = (status & 0x00003FFF) - 4;
    void (*pci_action)(struct pci_dev *, dma_addr_t,
     size_t, int) = pci_dma_sync_single_for_device;
 
-   rtl8169_rx_csum(skb, desc);
-   
    pci_dma_sync_single_for_cpu(tp->pci_dev,
     le64_to_cpu(desc->addr), tp->rx_buf_sz,
     PCI_DMA_FROMDEVICE);
-
-   if (rtl8169_try_rx_copy(&skb, pkt_size, desc,
-      tp->rx_buf_sz)) {
+   
+   rtl8169_rx_csum(skb, desc);
+ 
+   if (rtl8169_rx_copy(&skb, pkt_size, desc, tp)) {
     pci_action = pci_unmap_single;
     tp->Rx_skbuff[entry] = NULL;
+    skb_put(skb, pkt_size);
    }
 
    pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
        tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-   skb->dev = dev;
-   skb_put(skb, pkt_size);
-   skb->protocol = eth_type_trans(skb, dev);
-
-   if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
-    rtl8169_rx_skb(skb);
-
-   dev->last_rx = jiffies;
-   tp->stats.rx_bytes += pkt_size;
-   tp->stats.rx_packets++;
+   if (skb && (status & LastFrag)) {
+    skb->dev = dev;
+    skb->protocol = eth_type_trans(skb, dev);
+
+    if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
+     rtl8169_rx_skb(skb);
+
+    dev->last_rx = jiffies;
+    tp->stats.rx_bytes += pkt_size;
+    tp->stats.rx_packets++;
+   }
   }
-  
+
   cur_rx++; 
   rx_left--;
  }
