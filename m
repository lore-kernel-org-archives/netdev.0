From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 3/6] dm9000: clean up edge-triggered irq compatibility
Date: Wed,  4 Jun 2014 17:28:46 -0500
Message-ID: <2f4a1c28e0bf9c8d4443cce345bbf79274851384.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:37743 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751569AbaFDWh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:56 -0400
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 24E414BA
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:15 -0400 (EDT)
In-Reply-To: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
In-Reply-To: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DM9000 uses level-triggered interrupts.  Some systems (PXA270) only
support edge-triggered interrupts on GPIOs.  Some changes are necessary
to ensure that interrupts are not triggered while the GPIO interrupt is
masked or we will miss the interrupt forever.

* Make some helper functions called dm9000_mask_interrupts() and
  dm9000_unmask_interrupts() for readability.

* dm9000_init_dm9000(): ensure that this function always leaves interrupts
  masked regardless of the state when it entered the function.  This is
  primarily to support the situation in dm9000_open where the logic used
  to go:

    dm9000_open()
        dm9000_init_dm9000()
            unmask interrupts
        request_irq()

  If an interrupt occurred between unmasking the interrupt and
  requesting the irq, it would be missed forever as the edge event would
  never be seen by the GPIO hardware in the PXA270.  This allows us to
  change the logic to:

    dm9000_open()
        dm9000_init_dm9000()
            dm9000_mask_interrupts()
        request_irq()
        dm9000_unmask_interrupts()

* dm9000_timeout(), dm9000_drv_resume(): Add the missing
  dm9000_unmask_interrupts() now required by the change above.

* dm9000_shutdown(): Use mask helper function

* dm9000_interrupt(): Use mask/unmask helper functions

Signed-off-by: Andrew Ruder <andrew.ruder@elecsyscorp.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index e6b1bc3..c508a33 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -882,6 +882,18 @@ dm9000_hash_table(struct net_device *dev)
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
+static void
+dm9000_mask_interrupts(board_info_t *db)
+{
+	iow(db, DM9000_IMR, IMR_PAR);
+}
+
+static void
+dm9000_unmask_interrupts(board_info_t *db)
+{
+	iow(db, DM9000_IMR, db->imr_all);
+}
+
 /*
  * Initialize dm9000 board
  */
@@ -895,6 +907,7 @@ dm9000_init_dm9000(struct net_device *dev)
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
 	dm9000_reset(db);
+	dm9000_mask_interrupts(db);
 
 	/* I/O mode */
 	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
@@ -943,9 +956,6 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	db->imr_all = imr;
 
-	/* Enable TX/RX interrupt mask */
-	iow(db, DM9000_IMR, imr);
-
 	/* Init Driver variable */
 	db->tx_pkt_cnt = 0;
 	db->queue_pkt_len = 0;
@@ -965,6 +975,7 @@ static void dm9000_timeout(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	dm9000_init_dm9000(dev);
+	dm9000_unmask_interrupts(db);
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies; /* prevent tx timeout */
 	netif_wake_queue(dev);
@@ -1194,9 +1205,7 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 	/* Save previous register address */
 	reg_save = readb(db->io_addr);
 
-	/* Disable all interrupts */
-	iow(db, DM9000_IMR, IMR_PAR);
-
+	dm9000_mask_interrupts(db);
 	/* Got DM9000 interrupt status */
 	int_status = ior(db, DM9000_ISR);	/* Got ISR */
 	iow(db, DM9000_ISR, int_status);	/* Clear ISR status */
@@ -1219,9 +1228,7 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 		}
 	}
 
-	/* Re-enable interrupt mask */
-	iow(db, DM9000_IMR, db->imr_all);
-
+	dm9000_unmask_interrupts(db);
 	/* Restore previous register address */
 	writeb(reg_save, db->io_addr);
 
@@ -1309,6 +1316,10 @@ dm9000_open(struct net_device *dev)
 
 	if (request_irq(dev->irq, dm9000_interrupt, irqflags, dev->name, dev))
 		return -EAGAIN;
+	/* Now that we have an interrupt handler hooked up we can unmask
+	 * our interrupts
+	 */
+	dm9000_unmask_interrupts(db);
 
 	/* Init driver variable */
 	db->dbug_cnt = 0;
@@ -1329,7 +1340,7 @@ dm9000_shutdown(struct net_device *dev)
 	/* RESET device */
 	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
 	iow(db, DM9000_GPR, 0x01);	/* Power-Down PHY */
-	iow(db, DM9000_IMR, IMR_PAR);	/* Disable all interrupt */
+	dm9000_mask_interrupts(db);
 	iow(db, DM9000_RCR, 0x00);	/* Disable RX */
 }
 
@@ -1694,6 +1705,7 @@ dm9000_drv_resume(struct device *dev)
 			 * the device was powered off it is in a known state */
 			if (!db->wake_state) {
 				dm9000_init_dm9000(ndev);
+				dm9000_unmask_interrupts(db);
 			}
 
 			netif_device_attach(ndev);
-- 
1.9.0.rc3.12.gbc97e2d
