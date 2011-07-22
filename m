From: Daniel Morsing <daniel.morsing@gmail.com>
Subject: [PATCH] dm9000: Make the driver follow the IRQF_SHARED contract
Date: Fri, 22 Jul 2011 19:52:42 +0200
Message-ID: <1311357162-16200-1-git-send-email-daniel.morsing@gmail.com>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Morsing <daniel.morsing@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dm9000 driver requests a shared interrupt but doesn't return
IRQ_NONE when the device didn't generate the interrupt. This could lead
to the other devices sharing the irq never getting an interrupt. This
patch makes the routine return IRQ_NONE for the path where no work was
done.

Signed-off-by: Daniel Morsing <daniel.morsing@gmail.com>
Cc: stable@kernel.org
---
 drivers/net/dm9000.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index ee597e6..d9a20c9 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1042,6 +1042,7 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 	int int_status;
 	unsigned long flags;
 	u8 reg_save;
+	irqreturn_t ret = IRQ_NONE;
 
 	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
@@ -1064,17 +1065,22 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 		dev_dbg(db->dev, "interrupt status %02x\n", int_status);
 
 	/* Received the coming packet */
-	if (int_status & ISR_PRS)
+	if (int_status & ISR_PRS) {
 		dm9000_rx(dev);
+		ret = IRQ_HANDLED;
+	}
 
 	/* Trnasmit Interrupt check */
-	if (int_status & ISR_PTS)
+	if (int_status & ISR_PTS) {
 		dm9000_tx_done(dev, db);
+		ret = IRQ_HANDLED;
+	}
 
 	if (db->type != TYPE_DM9000E) {
 		if (int_status & ISR_LNKCHNG) {
 			/* fire a link-change request */
 			schedule_delayed_work(&db->phy_poll, 1);
+			ret = IRQ_HANDLED;
 		}
 	}
 
@@ -1086,7 +1092,7 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 
 	spin_unlock_irqrestore(&db->lock, flags);
 
-	return IRQ_HANDLED;
+	return ret;
 }
 
 static irqreturn_t dm9000_wol_interrupt(int irq, void *dev_id)
-- 
1.7.4.4
