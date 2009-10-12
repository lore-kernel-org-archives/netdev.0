From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 3/3] sky2: Hold phy lock when accessing phy registers
Date: Mon, 12 Oct 2009 23:06:48 +0900
Message-ID: <4AD337F8.80208@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:38093 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153AbZJLOIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 10:08:10 -0400
Received: by pxi9 with SMTP id 9so8607436pxi.4
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 07:07:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy lock should be held around gm_phy_read.

This is probably another theoretical problem, however
 we should do this for consistency purposes.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 67c8478..0e1a4bc 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -830,6 +830,7 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0 && port == 1) {
 		/* WA DEV_472 -- looks like crossed wires on port 2 */
 		/* clear GMAC 1 Control reset */
+		spin_lock_bh(&sky2->phy_lock);
 		sky2_write8(hw, SK_REG(0, GMAC_CTRL), GMC_RST_CLR);
 		do {
 			sky2_write8(hw, SK_REG(1, GMAC_CTRL), GMC_RST_SET);
@@ -837,6 +838,7 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 		} while (gm_phy_read(hw, 1, PHY_MARV_ID0) != PHY_MARV_ID0_VAL ||
 			 gm_phy_read(hw, 1, PHY_MARV_ID1) != PHY_MARV_ID1_Y2 ||
 			 gm_phy_read(hw, 1, PHY_MARV_INT_MASK) != 0);
+		spin_unlock_bh(&sky2->phy_lock);
 	}
 
 	sky2_read16(hw, SK_REG(port, GMAC_IRQ_SRC));
-- 
1.5.6.5

