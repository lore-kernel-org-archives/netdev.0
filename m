From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 null pointer dereference
Date: Sun, 1 Apr 2007 12:00:00 +0200
Message-ID: <20070401100000.GA23965@electric-eye.fr.zoreil.com>
References: <20070331195046.1fdda7c2@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49918 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751527AbXDAKAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Apr 2007 06:00:37 -0400
Content-Disposition: inline
In-Reply-To: <20070331195046.1fdda7c2@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn <jacliburn@bellsouth.net> :
> Francois,
> 
> I get this on 2.6.21-rc5 and earlier kernels going back to at least
> 2.6.20-git14, both i386 and x86_64, dual-core AM2 and LGA775
> motherboards, using two different RTL8169 PCI add-in cards.  Has anyone
> else reported it?

No. It does not look like a post 2.6.20 r8169 regresssion. Can you publish
the output of an 'objdump -S r8169.ko' someplace and test the patch below
against 2.6.21-rc5

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 521b5f0..2ecf8e9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1751,16 +1751,10 @@ static int rtl8169_open(struct net_devic
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
-	int retval;
+	int retval = -ENOMEM;
 
-	rtl8169_set_rxbufsize(tp, dev);
 
-	retval =
-	    request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED, dev->name, dev);
-	if (retval < 0)
-		goto out;
-
-	retval = -ENOMEM;
+	rtl8169_set_rxbufsize(tp, dev);
 
 	/*
 	 * Rx and Tx desscriptors needs 256 bytes alignment.
@@ -1769,19 +1763,24 @@ static int rtl8169_open(struct net_devic
 	tp->TxDescArray = pci_alloc_consistent(pdev, R8169_TX_RING_BYTES,
 					       &tp->TxPhyAddr);
 	if (!tp->TxDescArray)
-		goto err_free_irq;
+		goto out;
 
 	tp->RxDescArray = pci_alloc_consistent(pdev, R8169_RX_RING_BYTES,
 					       &tp->RxPhyAddr);
 	if (!tp->RxDescArray)
-		goto err_free_tx;
+		goto err_free_tx_0;
 
 	retval = rtl8169_init_ring(dev);
 	if (retval < 0)
-		goto err_free_rx;
+		goto err_free_rx_1;
 
 	INIT_DELAYED_WORK(&tp->task, NULL);
 
+	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
+			     dev->name, dev);
+	if (retval < 0)
+		goto err_release_ring_2;
+
 	rtl8169_hw_start(dev);
 
 	rtl8169_request_timer(dev);
@@ -1790,14 +1789,14 @@ static int rtl8169_open(struct net_devic
 out:
 	return retval;
 
-err_free_rx:
+err_release_ring_2:
+	rtl8169_rx_clear(tp);
+err_free_rx_1:
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
-err_free_tx:
+err_free_tx_0:
 	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			    tp->TxPhyAddr);
-err_free_irq:
-	free_irq(dev->irq, dev);
 	goto out;
 }
 
