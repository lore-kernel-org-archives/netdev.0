From: Grant Grundler <grundler@parisc-linux.org>
Subject: [PATCH] [Bug 5839] uli526x partially recognizing interface
Date: Sun, 17 Feb 2008 11:30:23 -0700
Message-ID: <20080217183023.GB4402@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tulip-users@lists.sourceforge.net, netdev@vger.kernel.org,
	kyle@parisc-linux.org, akpm@linux-foundation.org
To: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:33900 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbYBQSan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 13:30:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch fixes:
    http://bugzilla.kernel.org/show_bug.cgi?id=5839

Init sequence needs to poll phy until phy reset is complete. This is the
same problem that I fixed in 2002 in tulip driver.

Thanks to manty@manty.net for testing this patch.
Thanks to Pozsar Balazs <pozsy@uhulinux.hu> for posting/testing
a similar patch before:
    http://lkml.org/lkml/2006/8/21/45

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>


diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index ca2548e..1dd8485 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -484,9 +484,11 @@ static void uli526x_init(struct net_device *dev)
 	struct uli526x_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = db->ioaddr;
 	u8	phy_tmp;
+	u8	timeout;
 	u16	phy_value;
 	u16 phy_reg_reset;
 
+
 	ULI526X_DBUG(0, "uli526x_init()", 0);
 
 	/* Reset M526x MAC controller */
@@ -511,11 +513,19 @@ static void uli526x_init(struct net_device *dev)
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
-	/* Phyxcer capability setting */
+	/* phyxcer capability setting */
 	phy_reg_reset = phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id);
 	phy_reg_reset = (phy_reg_reset | 0x8000);
 	phy_write(db->ioaddr, db->phy_addr, 0, phy_reg_reset, db->chip_id);
+
+	/* See IEEE 802.3-2002.pdf (Section 2, Chapter "22.2.4 Management
+	 * functions") or phy data sheet for details on phy reset
+	 */
 	udelay(500);
+	timeout = 10;
+	while (timeout-- &&
+		phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id) & 0x8000)
+			udelay(100);
 
 	/* Process Phyxcer Media Mode */
 	uli526x_set_phyxcer(db);

