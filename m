From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - panic and a fix
Date: Wed, 8 Sep 2004 21:06:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908190603.GA19634@electric-eye.fr.zoreil.com>
References: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Content-Disposition: inline
In-Reply-To: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au> :
> As of 2.6.9-rc1-bk11, r8169 does not work on my Athlon 64 machine. It results 
> in a panic :-(.
[skb_over_panic]

Can you:
- make drivers/net/r8169.s and send me the r8169.s file
- objdump -S drivers/net/r8169.o and send me output
- Re-apply the patch which test size(dma_arrd_t), apply the patch below
  and report the (possibly oopsy) result ?


--- drivers/net/r8169.c	2004-09-08 20:15:01.000000000 +0200
+++ dirvers/net/r8169.c	2004-09-08 20:49:58.000000000 +0200
@@ -52,6 +52,7 @@ VERSION 1.2	<2002/11/30>
 #define MODULENAME "r8169"
 #define RTL8169_DRIVER_NAME   MODULENAME " Gigabit Ethernet driver " RTL8169_VERSION
 #define PFX MODULENAME ": "
+#define RTL8169_DEBUG
 
 #ifdef RTL8169_DEBUG
 #define assert(expr) \
@@ -1308,7 +1309,7 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	RTL_W16(RxMaxSize, RX_BUF_SIZE);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1698,6 +1699,7 @@ rtl8169_rx_interrupt(struct net_device *
 			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
 				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 
+			assert(pkt_size <= RX_BUF_SIZE);
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			rtl8169_rx_skb(skb);
