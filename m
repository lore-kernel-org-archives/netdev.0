From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 3/3] net: mvpp2: do not call txq_done from the Tx path when Tx irqs are used
Date: Mon, 23 Oct 2017 15:24:31 +0200
Message-ID: <20171023132431.5756-3-antoine.tenart@free-electrons.com>
References: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60933 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932184AbdJWNZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 09:25:03 -0400
In-Reply-To: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Tx IRQs are used, txq_bufs_free() can be called from both the Tx
path and from NAPI poll(). This led to CPU stalls as if these two tasks
(Tx and Poll) are scheduled on two CPUs at the same time, DMA unmapping
operations are done on the same txq buffers.

This patch adds a check not to call txq_done() from the Tx path if Tx
interrupts are used as it does not make sense to do so.

Fixes: edc660fa09e2 ("net: mvpp2: replace TX coalescing interrupts with hrtimer")
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 037f26dfe31c..60b4f3d995af 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6499,7 +6499,7 @@ static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Finalize TX processing */
-	if (txq_pcpu->count >= txq->done_pkts_coal)
+	if (!port->has_tx_irqs && txq_pcpu->count >= txq->done_pkts_coal)
 		mvpp2_txq_done(port, txq, txq_pcpu);
 
 	/* Set the timer in case not all frags were processed */
-- 
2.14.2
