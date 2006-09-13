From: bora.sahin@ttnet.net.tr
Subject: [PATCH 6/12] smc911x: Unneeded spinlocks around smc911x_enable
Date: Wed, 13 Sep 2006 21:08:16 +0300
Message-ID: <200609132108.16835.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:23419 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751056AbWIMSe5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:34:57 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


smc911x_enable, which enables irqs as a last task, is called with irqs disabled. 
There is no any other concurrent access at that phase so spinlock protection
is unneeded...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -345,12 +348,10 @@
 	SMC_SET_FIFO_TSL(64);
 	SMC_SET_GPT_CFG(GPT_CFG_TIMER_EN_ | 10000);
 
-	spin_lock_irqsave(&lp->lock, flags);
 	SMC_GET_MAC_CR(cr);
 	cr |= MAC_CR_TXEN_ | MAC_CR_HBDIS_;
 	SMC_SET_MAC_CR(cr);
 	SMC_SET_TX_CFG(TX_CFG_TX_ON_);
-	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Add 2 byte padding to start of packets */
 	SMC_SET_RX_CFG((2<<8) & RX_CFG_RXDOFF_);
@@ -359,9 +360,7 @@
 	if (cr & MAC_CR_RXEN_)
 		DBG(SMC_DEBUG_RX, "%s: Receiver already enabled\n", dev->name);
 
-	spin_lock_irqsave(&lp->lock, flags);
 	SMC_SET_MAC_CR( cr | MAC_CR_RXEN_ );
-	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Interrupt on every received packet */
 	SMC_SET_FIFO_RSA(0x01);
