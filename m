From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 2/3] r8169: code clean-up
Date: Wed, 16 Feb 2005 18:23:43 -0600
Message-ID: <200502161823.43562.jdmason@us.ibm.com>
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

This patch removes netif_poll_disable if NAPI is not enabled (otherwise 
adapter will hang while changing MTUs).  This patch also fixes a possible skb
alignment overrun, and fixes the rx skb allocation error logging. It also 
removes an unnecessary define, adds a link down notification, and cleans up 
some comments. 

It is all pretty trivial, but let me know if this is too much for one patch.

Tested on amd64 (and very lightly tested on x86).

Applies cleanly to linux-2.6.11-rc2-mm2 version of the driver.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- drivers/net/r8169.c.orig 2005-02-16 17:16:19.000000000 -0600
+++ drivers/net/r8169.c 2005-02-16 17:17:40.000000000 -0600
@@ -84,10 +84,12 @@ VERSION 1.6LK <2004/04/14>
 #define rtl8169_rx_skb   netif_receive_skb
 #define rtl8169_rx_hwaccel_skb  vlan_hwaccel_rx
 #define rtl8169_rx_quota(count, quota) min(count, quota)
+#define netif_poll_disable(dev)  netif_poll_disable(dev)
 #else
 #define rtl8169_rx_skb   netif_rx
 #define rtl8169_rx_hwaccel_skb  vlan_hwaccel_receive_skb
 #define rtl8169_rx_quota(count, quota) count
+#define netif_poll_disable(dev)
 #endif
 
 /* media options */
@@ -102,11 +104,9 @@ static int max_interrupt_work = 20;
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
 
-/* MAC address length*/
+/* MAC address length */
 #define MAC_ADDR_LEN 6
 
-#define TX_FIFO_THRESH 256 /* In bytes */
-
 #define RX_FIFO_THRESH 7 /* 7 means NO threshold, Rx buffer level before first PCI xfer.  */
 #define RX_DMA_BURST 6 /* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST 6 /* Maximum PCI burst, '6' is 1024 */
@@ -521,8 +521,10 @@ static void rtl8169_check_link_status(st
  if (tp->link_ok(ioaddr)) {
   netif_carrier_on(dev);
   printk(KERN_INFO PFX "%s: link up\n", dev->name);
- } else
+ } else {
   netif_carrier_off(dev);
+  printk(KERN_INFO PFX "%s: link down\n", dev->name);
+ } 
  spin_unlock_irqrestore(&tp->lock, flags);
 }
 
@@ -1549,10 +1551,10 @@ rtl8169_hw_start(struct net_device *dev)
  RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
  RTL_W8(EarlyTxThres, EarlyTxThld);
 
- // For gigabit rtl8169, MTU + header + CRC + VLAN
+ /* For gigabit rtl8169, MTU + header + CRC + VLAN */
  RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
- // Set Rx Config register
+ /* Set Rx Config register */
  i = rtl8169_rx_config |
   (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
  RTL_W32(RxConfig, i);
@@ -1659,11 +1661,11 @@ static int rtl8169_alloc_rx_skb(struct p
  dma_addr_t mapping;
  int ret = 0;
 
- skb = dev_alloc_skb(rx_buf_sz);
+ skb = dev_alloc_skb(rx_buf_sz + NET_IP_ALIGN);
  if (!skb)
   goto err_out;
 
- skb_reserve(skb, 2);
+ skb_reserve(skb, NET_IP_ALIGN);
  *sk_buff = skb;
 
  mapping = pci_map_single(pdev, skb->tail, rx_buf_sz,
@@ -2189,7 +2191,7 @@ rtl8169_rx_interrupt(struct net_device *
  tp->cur_rx = cur_rx;
 
  delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
- if (delta < 0) {
+ if (delta < 1 && count) {
   printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
   delta = 0;
  }
