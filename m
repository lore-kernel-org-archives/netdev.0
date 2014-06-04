From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 2/6] dm9000: clean up reset code
Date: Wed,  4 Jun 2014 17:28:45 -0500
Message-ID: <f6061a47b182be8ec6cf181d366f89e9072bc98f.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:41870 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751685AbaFDWh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:56 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 40B394B9
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:14 -0400 (EDT)
In-Reply-To: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
In-Reply-To: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Change a hard-coded 0x3 to NCR_RST | NCR_MAC_LBK in dm9000_reset

* Every single place where dm9000_init_dm9000 was ran, a dm9000_reset
  was called immediately before-hand.  Bring dm9000_reset into
  dm9000_init_dm9000.

* The following commit updated the dm9000_probe reset routine to use NCR_RST
  | NCR_MAC_LBK:

    6741f40 DM9000B: driver initialization upgrade

  and a later commit added a bug-fix to always reset the chip twice:

    09ee9f8 dm9000: Implement full reset of DM9000 network device

  Unfortunately, since the changes in 6741f40 were made by replacing the
  dm9000_probe dm9000_reset with the adjusted iow(), the changes in
  09ee9f8 were not incorporated into the dm9000_probe reset.
  Furthermore, it bypassed the requisite reset-delay causing some boards
  to get at least one "read wrong id ..." dev_err message during
  dm9000_probe.

Signed-off-by: Andrew Ruder <andrew.ruder@elecsyscorp.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 9d44c3f..e6b1bc3 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -187,13 +187,13 @@ dm9000_reset(board_info_t *db)
 	 * The essential point is that we have to do a double reset, and the
 	 * instruction is to set LBK into MAC internal loopback mode.
 	 */
-	iow(db, DM9000_NCR, 0x03);
+	iow(db, DM9000_NCR, NCR_RST | NCR_MAC_LBK);
 	udelay(100); /* Application note says at least 20 us */
 	if (ior(db, DM9000_NCR) & 1)
 		dev_err(db->dev, "dm9000 did not respond to first reset\n");
 
 	iow(db, DM9000_NCR, 0);
-	iow(db, DM9000_NCR, 0x03);
+	iow(db, DM9000_NCR, NCR_RST | NCR_MAC_LBK);
 	udelay(100);
 	if (ior(db, DM9000_NCR) & 1)
 		dev_err(db->dev, "dm9000 did not respond to second reset\n");
@@ -894,6 +894,8 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
+	dm9000_reset(db);
+
 	/* I/O mode */
 	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
 
@@ -962,7 +964,6 @@ static void dm9000_timeout(struct net_device *dev)
 	reg_save = readb(db->io_addr);
 
 	netif_stop_queue(dev);
-	dm9000_reset(db);
 	dm9000_init_dm9000(dev);
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -1304,7 +1305,6 @@ dm9000_open(struct net_device *dev)
 	mdelay(1); /* delay needs by DM9000B */
 
 	/* Initialize DM9000 board */
-	dm9000_reset(db);
 	dm9000_init_dm9000(dev);
 
 	if (request_irq(dev->irq, dm9000_interrupt, irqflags, dev->name, dev))
@@ -1550,12 +1550,7 @@ dm9000_probe(struct platform_device *pdev)
 	db->flags |= DM9000_PLATF_SIMPLE_PHY;
 #endif
 
-	/* Fixing bug on dm9000_probe, takeover dm9000_reset(db),
-	 * Need 'NCR_MAC_LBK' bit to indeed stable our DM9000 fifo
-	 * while probe stage.
-	 */
-
-	iow(db, DM9000_NCR, NCR_MAC_LBK | NCR_RST);
+	dm9000_reset(db);
 
 	/* try multiple times, DM9000 sometimes gets the read wrong */
 	for (i = 0; i < 8; i++) {
@@ -1698,7 +1693,6 @@ dm9000_drv_resume(struct device *dev)
 			/* reset if we were not in wake mode to ensure if
 			 * the device was powered off it is in a known state */
 			if (!db->wake_state) {
-				dm9000_reset(db);
 				dm9000_init_dm9000(ndev);
 			}
 
-- 
1.9.0.rc3.12.gbc97e2d
