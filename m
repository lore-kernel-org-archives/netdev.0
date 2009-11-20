From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH 2.6.32-rc6] drivers/net: ks8851_mll ethernet network driver -resubmit
Date: Thu, 19 Nov 2009 17:34:30 -0800
Message-ID: <C43529A246480145B0A6D0234BDB0F0D02129B@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<shemminger@vyatta.com>, <greg@kroah.com>,
	"Choi, David" <David.Choi@Micrel.Com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o142.mxlogic.net ([208.65.144.65]:40259 "EHLO
	p01c11o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757506AbZKTBtl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 20:49:41 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

This patch is for ks8851 16bit MLL Ethernet network device driver in order to 
fix bugs and to enhance functions. This resubmit removes a printk statement causing
the compile warning in 64bit processors.

>From 	: David J. Choi <david.choi@micrel.com>

Summary of Changes:  

	-Fix to receive multicast packets by setting the corresponding hardware 
	 bit during initialization.
	-Fix to re-enable the interface [by interface up command(ifup)] while the 
	 interface is down.
	-Fix to be able to down the interface by passing the last parameter 
	 correctly to request_irq().
	-Remove to read 4 extra bytes from the receiving queue after reading a 
	 packet, even though it does not cause a predictable issue now.
	-Remove occurrences of transmission done interrupt in order to tx 
	 throughput enhancement.
	-Enable IP checksum for packet receiving by setting the corresponding 
	 hardware bit during initialization.
	-Relocate ks_enable_int()/ks_disable_int() in order not to declare those 
	 functions at the beginning of the file.
	-Rename ks_enable()/_disable() to ks_enable_qmu()/ks_disable_qmu() in 
	 order to give more meaningful names and relocate them not declaire 
	 those functions at the beginning of the file.

Signed-off-by: David J. Choi <david.choi@micrel.com>

---
--- linux-2.6.32-rc6/drivers/net/ks8851_mll.c.orig	2009-11-12 09:57:33.000000000 -0800
+++ linux-2.6.32-rc6/drivers/net/ks8851_mll.c	2009-11-19 17:04:33.000000000 -0800
@@ -568,6 +568,16 @@ static inline void ks_outblk(struct ks_n
 		iowrite16(*wptr++, ks->hw_addr);
 }
 
+static void ks_disable_int(struct ks_net *ks)
+{
+	ks_wrreg16(ks, KS_IER, 0x0000);
+}  /* ks_disable_int */
+
+static void ks_enable_int(struct ks_net *ks)
+{
+	ks_wrreg16(ks, KS_IER, ks->rc_ier);
+}  /* ks_enable_int */
+
 /**
  * ks_tx_fifo_space - return the available hardware buffer size.
  * @ks: The chip information
@@ -681,6 +691,47 @@ static void ks_soft_reset(struct ks_net 
 }
 
 
+void ks_enable_qmu(struct ks_net *ks)
+{
+	u16 w;
+
+	w = ks_rdreg16(ks, KS_TXCR);
+	/* Enables QMU Transmit (TXCR). */
+	ks_wrreg16(ks, KS_TXCR, w | TXCR_TXE);
+
+	/*
+	 * RX Frame Count Threshold Enable and Auto-Dequeue RXQ Frame
+	 * Enable
+	 */
+
+	w = ks_rdreg16(ks, KS_RXQCR);
+	ks_wrreg16(ks, KS_RXQCR, w | RXQCR_RXFCTE);
+
+	/* Enables QMU Receive (RXCR1). */
+	w = ks_rdreg16(ks, KS_RXCR1);
+	ks_wrreg16(ks, KS_RXCR1, w | RXCR1_RXE);
+	ks->enabled = true;
+}  /* ks_enable_qmu */
+
+static void ks_disable_qmu(struct ks_net *ks)
+{
+	u16	w;
+
+	w = ks_rdreg16(ks, KS_TXCR);
+
+	/* Disables QMU Transmit (TXCR). */
+	w  &= ~TXCR_TXE;
+	ks_wrreg16(ks, KS_TXCR, w);
+
+	/* Disables QMU Receive (RXCR1). */
+	w = ks_rdreg16(ks, KS_RXCR1);
+	w &= ~RXCR1_RXE ;
+	ks_wrreg16(ks, KS_RXCR1, w);
+
+	ks->enabled = false;
+
+}  /* ks_disable_qmu */
+
 /**
  * ks_read_qmu - read 1 pkt data from the QMU.
  * @ks: The chip information
@@ -752,7 +803,7 @@ static void ks_rcv(struct ks_net *ks, st
 			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
 			skb_reserve(skb, 2);
 			/* read data block including CRC 4 bytes */
-			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len + 4);
+			ks_read_qmu(ks, (u16 *)skb->data, frame_hdr->len);
 			skb_put(skb, frame_hdr->len);
 			skb->dev = netdev;
 			skb->protocol = eth_type_trans(skb, netdev);
@@ -861,7 +912,7 @@ static int ks_net_open(struct net_device
 		ks_dbg(ks, "%s - entry\n", __func__);
 
 	/* reset the HW */
-	err = request_irq(ks->irq, ks_irq, KS_INT_FLAGS, DRV_NAME, ks);
+	err = request_irq(ks->irq, ks_irq, KS_INT_FLAGS, DRV_NAME, netdev);
 
 	if (err) {
 		printk(KERN_ERR "Failed to request IRQ: %d: %d\n",
@@ -869,6 +920,15 @@ static int ks_net_open(struct net_device
 		return err;
 	}
 
+	/* wake up powermode to normal mode */
+	ks_set_powermode(ks, PMECR_PM_NORMAL);
+	mdelay(1);	/* wait for normal mode to take effect */
+
+	ks_wrreg16(ks, KS_ISR, 0xffff);
+	ks_enable_int(ks);
+	ks_enable_qmu(ks);
+	netif_start_queue(ks->netdev);
+
 	if (netif_msg_ifup(ks))
 		ks_dbg(ks, "network device %s up\n", netdev->name);
 
@@ -892,19 +952,14 @@ static int ks_net_stop(struct net_device
 
 	netif_stop_queue(netdev);
 
-	kfree(ks->frame_head_info);
-
 	mutex_lock(&ks->lock);
 
 	/* turn off the IRQs and ack any outstanding */
 	ks_wrreg16(ks, KS_IER, 0x0000);
 	ks_wrreg16(ks, KS_ISR, 0xffff);
 
-	/* shutdown RX process */
-	ks_wrreg16(ks, KS_RXCR1, 0x0000);
-
-	/* shutdown TX process */
-	ks_wrreg16(ks, KS_TXCR, 0x0000);
+	/* shutdown RX/TX QMU */
+	ks_disable_qmu(ks);
 
 	/* set powermode to soft power down to save power */
 	ks_set_powermode(ks, PMECR_PM_SOFTDOWN);
@@ -929,17 +984,8 @@ static int ks_net_stop(struct net_device
  */
 static void ks_write_qmu(struct ks_net *ks, u8 *pdata, u16 len)
 {
-	unsigned fid = ks->fid;
-
-	fid = ks->fid;
-	ks->fid = (ks->fid + 1) & TXFR_TXFID_MASK;
-
-	/* reduce the tx interrupt occurrances. */
-	if (!fid)
-		fid |= TXFR_TXIC;       /* irq on completion */
-
 	/* start header at txb[0] to align txw entries */
-	ks->txh.txw[0] = cpu_to_le16(fid);
+	ks->txh.txw[0] = 0;
 	ks->txh.txw[1] = cpu_to_le16(len);
 
 	/* 1. set sudo-DMA mode */
@@ -957,16 +1003,6 @@ static void ks_write_qmu(struct ks_net *
 		;
 }
 
-static void ks_disable_int(struct ks_net *ks)
-{
-	ks_wrreg16(ks, KS_IER, 0x0000);
-}  /* ks_disable_int */
-
-static void ks_enable_int(struct ks_net *ks)
-{
-	ks_wrreg16(ks, KS_IER, ks->rc_ier);
-}  /* ks_enable_int */
-
 /**
  * ks_start_xmit - transmit packet
  * @skb		: The buffer to transmit
@@ -1410,25 +1446,6 @@ static int ks_read_selftest(struct ks_ne
 	return ret;
 }
 
-static void ks_disable(struct ks_net *ks)
-{
-	u16	w;
-
-	w = ks_rdreg16(ks, KS_TXCR);
-
-	/* Disables QMU Transmit (TXCR). */
-	w  &= ~TXCR_TXE;
-	ks_wrreg16(ks, KS_TXCR, w);
-
-	/* Disables QMU Receive (RXCR1). */
-	w = ks_rdreg16(ks, KS_RXCR1);
-	w &= ~RXCR1_RXE ;
-	ks_wrreg16(ks, KS_RXCR1, w);
-
-	ks->enabled = false;
-
-}  /* ks_disable */
-
 static void ks_setup(struct ks_net *ks)
 {
 	u16	w;
@@ -1463,7 +1480,7 @@ static void ks_setup(struct ks_net *ks)
 	w = TXCR_TXFCE | TXCR_TXPE | TXCR_TXCRC | TXCR_TCGIP;
 	ks_wrreg16(ks, KS_TXCR, w);
 
-	w = RXCR1_RXFCE | RXCR1_RXBE | RXCR1_RXUE;
+	w = RXCR1_RXFCE | RXCR1_RXBE | RXCR1_RXUE | RXCR1_RXME | RXCR1_RXIPFCC;
 
 	if (ks->promiscuous)         /* bPromiscuous */
 		w |= (RXCR1_RXAE | RXCR1_RXINVF);
@@ -1486,28 +1503,6 @@ static void ks_setup_int(struct ks_net *
 	ks->rc_ier = (IRQ_LCI | IRQ_TXI | IRQ_RXI);
 }  /* ks_setup_int */
 
-void ks_enable(struct ks_net *ks)
-{
-	u16 w;
-
-	w = ks_rdreg16(ks, KS_TXCR);
-	/* Enables QMU Transmit (TXCR). */
-	ks_wrreg16(ks, KS_TXCR, w | TXCR_TXE);
-
-	/*
-	 * RX Frame Count Threshold Enable and Auto-Dequeue RXQ Frame
-	 * Enable
-	 */
-
-	w = ks_rdreg16(ks, KS_RXQCR);
-	ks_wrreg16(ks, KS_RXQCR, w | RXQCR_RXFCTE);
-
-	/* Enables QMU Receive (RXCR1). */
-	w = ks_rdreg16(ks, KS_RXCR1);
-	ks_wrreg16(ks, KS_RXCR1, w | RXCR1_RXE);
-	ks->enabled = true;
-}  /* ks_enable */
-
 static int ks_hw_init(struct ks_net *ks)
 {
 #define	MHEADER_SIZE	(sizeof(struct type_frame_head) * MAX_RECV_FRAMES)
@@ -1612,11 +1607,9 @@ static int __devinit ks8851_probe(struct
 
 	ks_soft_reset(ks, GRR_GSR);
 	ks_hw_init(ks);
-	ks_disable(ks);
+	ks_disable_qmu(ks);
 	ks_setup(ks);
 	ks_setup_int(ks);
-	ks_enable_int(ks);
-	ks_enable(ks);
 	memcpy(netdev->dev_addr, ks->mac_addr, 6);
 
 	data = ks_rdreg16(ks, KS_OBCR);
@@ -1658,6 +1651,7 @@ static int __devexit ks8851_remove(struc
 	struct ks_net *ks = netdev_priv(netdev);
 	struct resource *iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 
+	kfree(ks->frame_head_info);
 	unregister_netdev(netdev);
 	iounmap(ks->hw_addr);
 	free_netdev(netdev);
--
