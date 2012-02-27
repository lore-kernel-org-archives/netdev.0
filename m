From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: Re: [PATCH, RFC] skge: Fix race in tx path
Date: Mon, 27 Feb 2012 19:18:58 +0000
Message-ID: <3669580.gQc5FCr96Z@asus>
References: <4142816.cJc9u7kBPI@asus> <20120226202710.GA23874@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay01ant.iops.be ([212.53.4.34]:47708 "EHLO
	relay01ant.iops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378Ab2B0TTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 14:19:04 -0500
In-Reply-To: <20120226202710.GA23874@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> With this change it seems possible for skge_tx_done to unmap a buffer
> before it is sent when the requests for skge_xmit_frame are close enough.

Thanks for the feedback. Does the patch below look better ? 

---
 drivers/net/ethernet/marvell/skge.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 33947ac..55723b5 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2800,15 +2800,15 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 
 	netdev_sent_queue(dev, skb->len);
 
+	skge->tx_ring.to_use = e->next;
+	smp_wmb();
+
 	skge_write8(hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_START);
 
 	netif_printk(skge, tx_queued, KERN_DEBUG, skge->netdev,
 		     "tx queued, slot %td, len %d\n",
 		     e - skge->tx_ring.start, skb->len);
 
-	skge->tx_ring.to_use = e->next;
-	smp_wmb();
-
 	if (skge_avail(&skge->tx_ring) <= TX_LOW_WATER) {
 		netdev_dbg(dev, "transmit queue full\n");
 		netif_stop_queue(dev);
-- 
1.7.3.4
