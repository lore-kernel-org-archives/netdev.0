From: Bart Van Assche <bvanassche@acm.org>
Subject: [PATCH, RFC] skge: Fix race in tx path
Date: Fri, 24 Feb 2012 19:33:39 +0000
Message-ID: <4142816.cJc9u7kBPI@asus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay01ant.iops.be ([212.53.4.34]:48523 "EHLO
	relay01ant.iops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141Ab2BXTkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 14:40:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that tx_ring.to_use is updated before skge_tx_done() reads it.

Fixes the following BUG on my setup:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000525
IP: [<ffffffff8130c95e>] net_rx_action+0x9e/0x290
Call Trace:
 [<ffffffff8104cfb1>] ? __do_softirq+0x81/0x250
 [<ffffffff8104cffd>] __do_softirq+0xcd/0x250
 [<ffffffff8104d297>] run_ksoftirqd+0x117/0x1e0
 [<ffffffff8104d180>] ? __do_softirq+0x250/0x250
 [<ffffffff81069786>] kthread+0x96/0xa0
 [<ffffffff813e8534>] kernel_thread_helper+0x4/0x10
 [<ffffffff813de75d>] ? retint_restore_args+0xe/0xe
 [<ffffffff810696f0>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff813e8530>] ? gs_change+0xb/0xb

Signed-off-by: Bart Van Assche <bvanassche@acm.org>
Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: Jeff Garzik <jeff@garzik.org>
---
Note: I'm posting this patch as an RFC since I'm not a network driver expert.

 drivers/net/ethernet/marvell/skge.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index dea0cb4..2d805b9 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2793,7 +2793,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 		tf->control |= BMU_EOF | BMU_IRQ_EOF;
 	}
 	/* Make sure all the descriptors written */
-	wmb();
+	skge->tx_ring.to_use = e->next;
+	smp_wmb();
 	td->control = BMU_OWN | BMU_SW | BMU_STF | control | len;
 	wmb();
 
@@ -2803,9 +2804,6 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
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
