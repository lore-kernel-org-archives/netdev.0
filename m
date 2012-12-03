From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT PATCH] 8139cp: properly support change of MTU values [v2]
Date: Mon, 3 Dec 2012 21:46:08 +0100
Message-ID: <20121203204608.GA9815@electric-eye.fr.zoreil.com>
References: <1354551573-23721-1-git-send-email-jogreene@redhat.com> <20121203.135200.1242505353532930826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dwmw2@infradead.org
To: jogreene@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39934 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511Ab2LCVLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 16:11:11 -0500
Content-Disposition: inline
In-Reply-To: <20121203.135200.1242505353532930826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> I've applied this to net-next, if it triggers any problems we have
> some time to work it out before 3.8 is released.

I have bounced the messages to David Woodhouse since he authored the
last 8139cp changes in net-next and owns the hardware to notice
regressions.

My message of two days ago was wrong : it is not possible for the irq
handler to process a Tx event after the rings have been freed. Things
still look racy wrt netpoll though.

Any objection against the patch below ?

(I did not gotoize the dev == NULL test: it is really unlikely and
should go away).

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 0da3f5e..57cd542 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -577,28 +577,30 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct cp_private *cp;
+	int handled = 0;
 	u16 status;
 
 	if (unlikely(dev == NULL))
 		return IRQ_NONE;
 	cp = netdev_priv(dev);
 
+	spin_lock(&cp->lock);
+
 	status = cpr16(IntrStatus);
 	if (!status || (status == 0xFFFF))
-		return IRQ_NONE;
+		goto out_unlock;
+
+	handled = 1;
 
 	netif_dbg(cp, intr, dev, "intr, status %04x cmd %02x cpcmd %04x\n",
 		  status, cpr8(Cmd), cpr16(CpCmd));
 
 	cpw16(IntrStatus, status & ~cp_rx_intr_mask);
 
-	spin_lock(&cp->lock);
-
 	/* close possible race's with dev_close */
 	if (unlikely(!netif_running(dev))) {
 		cpw16(IntrMask, 0);
-		spin_unlock(&cp->lock);
-		return IRQ_HANDLED;
+		goto out_unlock;
 	}
 
 	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr))
@@ -612,8 +614,6 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 	if (status & LinkChg)
 		mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
 
-	spin_unlock(&cp->lock);
-
 	if (status & PciErr) {
 		u16 pci_status;
 
@@ -625,7 +625,10 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 		/* TODO: reset hardware */
 	}
 
-	return IRQ_HANDLED;
+out_unlock:
+	spin_unlock(&cp->lock);
+
+	return IRQ_RETVAL(handled);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
