From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH] r8169: Large Send clean-up and slight MTU range increase
Date: Tue, 11 Jan 2005 18:22:55 -0600
Message-ID: <200501111822.56019.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Increase of the "safe" Large Send MTU from 7200 to 7808.  This required 
modification of the value of the Early Tx Threshold register from 0x3F to 
0x35.  The value of 0x35 was determined through the "trial and error" method,
and is necessary for all MTUs > 7400.

Also, ignoring the RxRWT error (Receive Watchdog Timer Expired) as it is not 
valid if Large Send is enabled (though it only seems to log this error if the
packet is > 7808 and not > 4096 as the documentation suggest).  I can find
no way of disabling that error.

The other changes are self-explanatory.

Tested on AMD64.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
---


--- drivers/net/r8169.c.orig 2005-01-11 17:05:58.000000000 -0600
+++ drivers/net/r8169.c 2005-01-11 17:27:45.000000000 -0600
@@ -105,14 +105,13 @@ static int multicast_filter_limit = 32;
 /* MAC address length*/
 #define MAC_ADDR_LEN 6
 
-#define TX_FIFO_THRESH 256 /* In bytes */
-
 #define RX_FIFO_THRESH 7 /* 7 means NO threshold, Rx buffer level before first PCI xfer.  */
 #define RX_DMA_BURST 6 /* Maximum PCI burst, '6' is 1024 */
 #define TX_DMA_BURST 6 /* Maximum PCI burst, '6' is 1024 */
 #define EarlyTxThld  0x3F /* 0x3F means NO early transmit */
+#define LargeSendETT  0x35
 #define RxPacketMaxSize 0x3FE8 /* 16K - 1 - ETH_HLEN - VLAN - CRC... */
-#define SafeMtu  0x1c20 /* ... actually life sucks beyond ~7k */
+#define SafeMtu  0x1E80 /* Packets > 7808 get broken into 2 desc */
 #define InterFrameGap 0x03 /* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE  256
@@ -1545,12 +1544,17 @@ rtl8169_hw_start(struct net_device *dev)
 
  RTL_W8(Cfg9346, Cfg9346_Unlock);
  RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
- RTL_W8(EarlyTxThres, EarlyTxThld);
 
- // For gigabit rtl8169, MTU + header + CRC + VLAN
+ /* The default EarlyTxThres setting does not work for MTUs > 7400 */
+ if (dev->mtu < 7400)
+  RTL_W8(EarlyTxThres, EarlyTxThld);
+ else
+  RTL_W8(EarlyTxThres, LargeSendETT);
+ 
+ /* For gigabit rtl8169, MTU + header + CRC + VLAN */
  RTL_W16(RxMaxSize, tp->rx_buf_sz);
 
- // Set Rx Config register
+ /* Set Rx Config register */
  i = rtl8169_rx_config |
   (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
  RTL_W32(RxConfig, i);
@@ -2138,8 +2142,9 @@ rtl8169_rx_interrupt(struct net_device *
 
   if (status & DescOwn)
    break;
-  if (status & RxRES) {
-   printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
+  
+  if (status & RxRES && !(status & RxRWT)) {
+   printk(KERN_INFO "%s: Rx ERROR  %x!!!\n", dev->name, status);
    tp->stats.rx_errors++;
    if (status & (RxRWT | RxRUNT))
     tp->stats.rx_length_errors++;
@@ -2148,7 +2153,7 @@ rtl8169_rx_interrupt(struct net_device *
   } else {
    struct RxDesc *desc = tp->RxDescArray + entry;
    struct sk_buff *skb = tp->Rx_skbuff[entry];
-   int pkt_size = (status & 0x00001FFF) - 4;
+   int pkt_size = (status & 0x00003FFF) - 4;
    void (*pci_action)(struct pci_dev *, dma_addr_t,
     size_t, int) = pci_dma_sync_single_for_device;
 
@@ -2187,7 +2192,7 @@ rtl8169_rx_interrupt(struct net_device *
  tp->cur_rx = cur_rx;
 
  delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
- if (delta < 0) {
+ if (delta < 1) {
   printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
   delta = 0;
  }
