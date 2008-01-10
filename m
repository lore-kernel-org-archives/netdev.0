From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/4] ipg: balance locking in irq handler
Date: Fri, 11 Jan 2008 00:35:52 +0100
Message-ID: <20080110233552.GB13315@electric-eye.fr.zoreil.com>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, jeff@garzik.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38156 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbYAJXtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:49:47 -0500
Content-Disposition: inline
In-Reply-To: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spotted-by: <linux@horizon.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ipg.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..cd1650e 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1630,6 +1630,8 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 #ifdef JUMBO_FRAME
 	ipg_nic_rxrestore(dev);
 #endif
+	spin_lock(&sp->lock);
+
 	/* Get interrupt source information, and acknowledge
 	 * some (i.e. TxDMAComplete, RxDMAComplete, RxEarly,
 	 * IntRequested, MacControlFrame, LinkEvent) interrupts
@@ -1647,9 +1649,7 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 	handled = 1;
 
 	if (unlikely(!netif_running(dev)))
-		goto out;
-
-	spin_lock(&sp->lock);
+		goto out_unlock;
 
 	/* If RFDListEnd interrupt, restore all used RFDs. */
 	if (status & IPG_IS_RFD_LIST_END) {
@@ -1733,9 +1733,9 @@ out_enable:
 	ipg_w16(IPG_IE_TX_DMA_COMPLETE | IPG_IE_RX_DMA_COMPLETE |
 		IPG_IE_HOST_ERROR | IPG_IE_INT_REQUESTED | IPG_IE_TX_COMPLETE |
 		IPG_IE_LINK_EVENT | IPG_IE_UPDATE_STATS, INT_ENABLE);
-
+out_unlock:
 	spin_unlock(&sp->lock);
-out:
+
 	return IRQ_RETVAL(handled);
 }
 
-- 
1.5.3.3

