From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] e100: fix typo in MDI/MDI-X eeprom check in e100_phy_init
Date: Fri, 14 Nov 2014 10:59:30 -0500
Message-ID: <1415980770-5467-1-git-send-email-linville@tuxdriver.com>
Cc: Dave Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Malli Chilakala <mallikarjuna.chilakala@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58530 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965288AbaKNQAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 11:00:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although it doesn't explicitly say so, commit 60ffa478759f39a2 ("e100:
Fix MDIO/MDIO-X") appears to be intended to revert the earlier commit
648951451e6d2d53 ("e100: fixed e100 MDI/MDI-X issues").  However,
careful examination reveals that the attempted revert actually
_inverted_ the test for eeprom_mdix_enabled.  That is bound to program
a few PHYs incorrectly...

https://bugzilla.redhat.com/show_bug.cgi?id=1156417

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Malli Chilakala <mallikarjuna.chilakala@intel.com>
---
Wow, an 8 year old bug in e100 -- woohoo!! :-)

This was causing some serious flakiness for a large cash register
deployment in Europe.  Testing with this one-line (really,
one-character) patch seems to have resolved the issue.

 drivers/net/ethernet/intel/e100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 781065eb5431..e9c3a87e5b11 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1543,7 +1543,7 @@ static int e100_phy_init(struct nic *nic)
 		mdio_write(netdev, nic->mii.phy_id, MII_BMCR, bmcr);
 	} else if ((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
 	   (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) &&
-		!(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
+		(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
 		/* enable/disable MDI/MDI-X auto-switching. */
 		mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
 				nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
-- 
1.9.3
