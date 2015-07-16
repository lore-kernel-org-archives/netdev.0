From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] ravb: fix race updating TCCR
Date: Fri, 17 Jul 2015 00:28:38 +0300
Message-ID: <6587398.M5V25fvqHl@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCCR.TSRQn bit may get clearead after TCCR gets read, so that TCCR write
would get skipped. We don't need to check this bit before setting.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against Dave Miller's 'net.git' repo plus the patch I sent on
Tuesday.

 drivers/net/ethernet/renesas/ravb_main.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -1275,7 +1275,6 @@ static netdev_tx_t ravb_start_xmit(struc
 	u32 dma_addr;
 	void *buffer;
 	u32 entry;
-	u32 tccr;
 
 	spin_lock_irqsave(&priv->lock, flags);
 	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q]) {
@@ -1324,9 +1323,7 @@ static netdev_tx_t ravb_start_xmit(struc
 	dma_wmb();
 	desc->die_dt = DT_FSINGLE;
 
-	tccr = ravb_read(ndev, TCCR);
-	if (!(tccr & (TCCR_TSRQ0 << q)))
-		ravb_write(ndev, tccr | (TCCR_TSRQ0 << q), TCCR);
+	ravb_write(ndev, ravb_read(ndev, TCCR) | (TCCR_TSRQ0 << q), TCCR);
 
 	priv->cur_tx[q]++;
 	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q] &&

