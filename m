From: <shh.xie@gmail.com>
Subject: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Fri, 14 Aug 2015 12:23:40 +0800
Message-ID: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0084.outbound.protection.outlook.com ([207.46.100.84]:55664
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752070AbbHNE3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 00:29:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Currently, if phy state is PHY_RUNNING, we always register a CHANGE
when phy works in polling or interrupt ignored, this will make the
adjust_link being called even the phy link did Not changed.

checking the phy link to make sure the link did changed before we
register a CHANGE, if link did not changed, we do nothing.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/phy.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 84b1fba..d972851 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -814,6 +814,7 @@ void phy_state_machine(struct work_struct *work)
 	bool needs_aneg = false, do_suspend = false;
 	enum phy_state old_state;
 	int err = 0;
+	int old_link;
 
 	mutex_lock(&phydev->lock);
 
@@ -899,11 +900,18 @@ void phy_state_machine(struct work_struct *work)
 		phydev->adjust_link(phydev->attached_dev);
 		break;
 	case PHY_RUNNING:
-		/* Only register a CHANGE if we are
-		 * polling or ignoring interrupts
+		/* Only register a CHANGE if we are polling or ignoring
+		 * interrupts and link changed since latest checking.
 		 */
-		if (!phy_interrupt_is_valid(phydev))
-			phydev->state = PHY_CHANGELINK;
+		if (!phy_interrupt_is_valid(phydev)) {
+			old_link = phydev->link;
+			err = phy_read_status(phydev);
+			if (err)
+				break;
+
+			if (old_link != phydev->link)
+				phydev->state = PHY_CHANGELINK;
+		}
 		break;
 	case PHY_CHANGELINK:
 		err = phy_read_status(phydev);
-- 
2.1.0.27.g96db324
