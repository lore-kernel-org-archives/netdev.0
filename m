From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: [PATCH 3/4] dm9000: Implement full reset of DM9000 network device
Date: Wed, 16 Oct 2013 11:41:33 +0300
Message-ID: <1381912894-4780-4-git-send-email-nikita@compulab.co.il>
References: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Cc: Michael Abbott <michael.abbott@diamond.ac.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:50363 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760022Ab3JPImK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:42:10 -0400
In-Reply-To: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Abbott <michael.abbott@diamond.ac.uk>

A Davicom application note for the DM9000 network device recommends
performing software reset twice to correctly initialise the device.
Without this reset some devices fail to initialise correctly on
system startup.

Cc: David S. Miller <davem@davemloft.net>
Cc: Jingoo Han <jg1.han@samsung.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Michael Abbott <michael.abbott@diamond.ac.uk>
---
 drivers/net/ethernet/davicom/dm9000.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 3f650ce..a179f81 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -158,18 +158,6 @@ static inline board_info_t *to_dm9000_board(struct net_device *dev)
 
 /* DM9000 network board routine ---------------------------- */
 
-static void
-dm9000_reset(board_info_t * db)
-{
-	dev_dbg(db->dev, "resetting device\n");
-
-	/* RESET device */
-	writeb(DM9000_NCR, db->io_addr);
-	udelay(200);
-	writeb(NCR_RST, db->io_data);
-	udelay(200);
-}
-
 /*
  *   Read a byte from I/O port
  */
@@ -191,6 +179,27 @@ iow(board_info_t * db, int reg, int value)
 	writeb(value, db->io_data);
 }
 
+static void
+dm9000_reset(board_info_t *db)
+{
+	dev_dbg(db->dev, "resetting device\n");
+
+	/* Reset DM9000, see DM9000 Application Notes V1.22 Jun 11, 2004 page 29
+	 * The essential point is that we have to do a double reset, and the
+	 * instruction is to set LBK into MAC internal loopback mode.
+	 */
+	iow(db, DM9000_NCR, 0x03);
+	udelay(100); /* Application note says at least 20 us */
+	if (ior(db, DM9000_NCR) & 1)
+		dev_err(db->dev, "dm9000 did not respond to first reset\n");
+
+	iow(db, DM9000_NCR, 0);
+	iow(db, DM9000_NCR, 0x03);
+	udelay(100);
+	if (ior(db, DM9000_NCR) & 1)
+		dev_err(db->dev, "dm9000 did not respond to second reset\n");
+}
+
 /* routines for sending block to chip */
 
 static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
-- 
1.8.1.2
