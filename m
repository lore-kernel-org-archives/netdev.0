From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: sxgbe: fix error paths in sxgbe_platform_probe()
Date: Sat, 26 Mar 2016 22:24:09 +0100
Message-ID: <1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
References: <877fgue1mx.fsf@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877fgue1mx.fsf@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to use post-decrement to ensure that irq_dispose_mapping is
also called on priv->rxq[0]->irq_no; moreover, if one of the above for
loops failed already at i==0 (so we reach one of these labels with
that value of i), we'll enter an essentially infinite loop of
out-of-bounds accesses.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
David, can you take this directly? Of the three samsung people listed
by get_maintainer.pl, one address bounces and another informed me
privately that he's not actually a maintainer of this anymore.

 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
index b02eed12bfc5..73427e29df2a 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
@@ -155,11 +155,11 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
 	return 0;
 
 err_rx_irq_unmap:
-	while (--i)
+	while (i--)
 		irq_dispose_mapping(priv->rxq[i]->irq_no);
 	i = SXGBE_TX_QUEUES;
 err_tx_irq_unmap:
-	while (--i)
+	while (i--)
 		irq_dispose_mapping(priv->txq[i]->irq_no);
 	irq_dispose_mapping(priv->irq);
 err_drv_remove:
-- 
2.1.4
