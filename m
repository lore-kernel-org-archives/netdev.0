From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/4] tg3: Fix link check in tg3_adjust_link
Date: Wed, 22 Feb 2012 14:35:18 -0800
Message-ID: <1329950121-18577-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1672 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224Ab2BVWgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 17:36:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3 driver tried to detect link changes by comparing the tg3 local
active_speed member with SPEED_UNKNOWN (or formerly SPEED_INVALID).
This check is not correct, since phylib will never set its speed member
to either of these two values.  The code only appeared to work because
tg3 initializes active_speed to SPEED_INVALID during tg3_init_one.  This
patch introduces a new "old_link" tg3 member and then compares the
phy_device's link member against it to detect link state changes.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ++++--
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d604664..c56523e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1819,13 +1819,13 @@ static void tg3_adjust_link(struct net_device *dev)
 		      (6 << TX_LENGTHS_IPG_SHIFT) |
 		      (32 << TX_LENGTHS_SLOT_TIME_SHIFT)));
 
-	if ((phydev->link && tp->link_config.active_speed == SPEED_UNKNOWN) ||
-	    (!phydev->link && tp->link_config.active_speed != SPEED_UNKNOWN) ||
+	if (phydev->link != tp->old_link ||
 	    phydev->speed != tp->link_config.active_speed ||
 	    phydev->duplex != tp->link_config.active_duplex ||
 	    oldflowctrl != tp->link_config.active_flowctrl)
 		linkmesg = 1;
 
+	tp->old_link = phydev->link;
 	tp->link_config.active_speed = phydev->speed;
 	tp->link_config.active_duplex = phydev->duplex;
 
@@ -13352,6 +13352,8 @@ static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
 	tp->link_config.autoneg = AUTONEG_ENABLE;
 	tp->link_config.active_speed = SPEED_UNKNOWN;
 	tp->link_config.active_duplex = DUPLEX_UNKNOWN;
+
+	tp->old_link = -1;
 }
 
 static int __devinit tg3_phy_probe(struct tg3 *tp)
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 22cbe74..66bcfca 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3064,6 +3064,7 @@ struct tg3 {
 
 	struct mii_bus			*mdio_bus;
 	int				mdio_irq[PHY_MAX_ADDR];
+	int				old_link;
 
 	u8				phy_addr;
 
-- 
1.7.3.4
