From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - panic and a fix
Date: Sat, 11 Sep 2004 14:19:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911121952.GA3134@electric-eye.fr.zoreil.com>
References: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au> <20040908190603.GA19634@electric-eye.fr.zoreil.com> <200409100008.06541.sriharivijayaraghavan@yahoo.com.au> <200409111147.24064.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Content-Disposition: inline
In-Reply-To: <200409111147.24064.sriharivijayaraghavan@yahoo.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au> :
[...]
> The bad news is that I see no "Assertion failed!" messages from the kernel. 
> Here is the complete kernel BUG and subsequent panic messages:
[oops]

R12 is confusing me.

Can you do two more subsequent tests with the patch attached ?
They apply against vanilla 2.6.9-rc1-bk{11/17}.

I assume the oops happen immediately and you can not even tell if a few
packets were transmitted/received, right ?

I'll welcome the objdump -S of both r8169.o modules as well as the section
of the vmlinux file where skb_over_panic() appears.

--
Ueimor

--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dbg-a.patch"

--- linux-2.6.9-rc1-bk17.orig/drivers/net/r8169.c	2004-09-10 21:57:57.000000000 +0200
+++ linux-2.6.9-rc1-bk17/drivers/net/r8169.c	2004-09-11 14:05:17.000000000 +0200
@@ -1308,7 +1308,7 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	RTL_W16(RxMaxSize, RX_BUF_SIZE);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1681,7 +1681,7 @@ rtl8169_rx_interrupt(struct net_device *
 		} else {
 			struct RxDesc *desc = tp->RxDescArray + entry;
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
-			int pkt_size = (status & 0x00001FFF) - 4;
+			int pkt_size = (status & 0x00003FFF) - 4;
 			void (*pci_action)(struct pci_dev *, dma_addr_t,
 				size_t, int) = pci_dma_sync_single_for_device;
 
@@ -1698,6 +1698,7 @@ rtl8169_rx_interrupt(struct net_device *
 			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
 				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 
+			BUG_ON(pkt_size > (RX_BUF_SIZE - 4));
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			rtl8169_rx_skb(skb);

--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dbg-b.patch"

--- linux-2.6.9-rc1-bk17.orig/drivers/net/r8169.c	2004-09-10 21:57:57.000000000 +0200
+++ linux-2.6.9-rc1-bk17/drivers/net/r8169.c	2004-09-11 14:06:33.000000000 +0200
@@ -984,9 +984,10 @@ rtl8169_init_board(struct pci_dev *pdev,
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		tp->cp_cmd |= PCIDAC;
-	else {
+		dev->features |= NETIF_F_HIGHDMA;
+	} else {
 		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc < 0) {
 			printk(KERN_ERR PFX "DMA configuration failed.\n");
@@ -1308,7 +1309,7 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W8(EarlyTxThres, EarlyTxThld);
 
 	// For gigabit rtl8169
-	RTL_W16(RxMaxSize, RxPacketMaxSize);
+	RTL_W16(RxMaxSize, RX_BUF_SIZE);
 
 	// Set Rx Config register
 	i = rtl8169_rx_config |
@@ -1681,7 +1682,7 @@ rtl8169_rx_interrupt(struct net_device *
 		} else {
 			struct RxDesc *desc = tp->RxDescArray + entry;
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
-			int pkt_size = (status & 0x00001FFF) - 4;
+			int pkt_size = (status & 0x00003FFF) - 4;
 			void (*pci_action)(struct pci_dev *, dma_addr_t,
 				size_t, int) = pci_dma_sync_single_for_device;
 
@@ -1698,6 +1699,7 @@ rtl8169_rx_interrupt(struct net_device *
 			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
 				   RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 
+			BUG_ON(pkt_size > (RX_BUF_SIZE - 4));
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 			rtl8169_rx_skb(skb);

--mYCpIKhGyMATD0i+--
