From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 8/8] ethoc: remove division from loops
Date: Thu, 25 Nov 2010 13:30:32 +0100
Message-ID: <1290688232-25142-9-git-send-email-jonas@southpole.se>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38976 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab0KYMag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:36 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calculating the BD entry using a modulus operation isn't optimal, especially
inside the loop.  This patch removes the modulus operations in favour of:

i)  simply checking for wrapping in the case of cur_rx
ii) forcing num_tx to be a power of two and using it to mask out the
    entry from cur_tx

The also prevents possible issues related overflow of the cur_rx and cur_tx
counters.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 93b50d6..b79d7e1 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -412,7 +412,7 @@ static int ethoc_rx(struct net_device *dev, int limit)
 		unsigned int entry;
 		struct ethoc_bd bd;
 
-		entry = priv->num_tx + (priv->cur_rx % priv->num_rx);
+		entry = priv->num_tx + priv->cur_rx;
 		ethoc_read_bd(priv, entry, &bd);
 		if (bd.stat & RX_BD_EMPTY) {
 			ethoc_ack_irq(priv, INT_MASK_RX);
@@ -456,7 +456,8 @@ static int ethoc_rx(struct net_device *dev, int limit)
 		bd.stat &= ~RX_BD_STATS;
 		bd.stat |=  RX_BD_EMPTY;
 		ethoc_write_bd(priv, entry, &bd);
-		priv->cur_rx++;
+		if (++priv->cur_rx == priv->num_rx)
+			priv->cur_rx = 0;
 	}
 
 	return count;
@@ -503,7 +504,7 @@ static int ethoc_tx(struct net_device *dev, int limit)
 	for (count = 0; count < limit; ++count) {
 		unsigned int entry;
 
-		entry = priv->dty_tx % priv->num_tx;
+		entry = priv->dty_tx & (priv->num_tx-1);
 
 		ethoc_read_bd(priv, entry, &bd);
 
@@ -1000,9 +1001,17 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	/* calculate the number of TX/RX buffers, maximum 128 supported */
 	num_bd = min_t(unsigned int,
 		128, (netdev->mem_end - netdev->mem_start + 1) / ETHOC_BUFSIZ);
-	priv->num_tx = max(2, num_bd / 4);
+	if (num_bd < 4) {
+		ret = -ENODEV;
+		goto error;
+	}
+	/* num_tx must be a power of two */
+	priv->num_tx = rounddown_pow_of_two(num_bd >> 1);
 	priv->num_rx = num_bd - priv->num_tx;
 
+	dev_dbg(&pdev->dev, "ethoc: num_tx: %d num_rx: %d\n",
+		priv->num_tx, priv->num_rx);
+
 	priv->vma = devm_kzalloc(&pdev->dev, num_bd*sizeof(void*), GFP_KERNEL);
 	if (!priv->vma) {
 		ret = -ENOMEM;
-- 
1.7.1

