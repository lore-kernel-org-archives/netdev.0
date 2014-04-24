From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH] net phy: Check for aneg completion before setting state to
 PHY_RUNNING
Date: Thu, 24 Apr 2014 08:22:47 +0530
Message-ID: <53587C7F.2000808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:37467 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbaDXCww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 22:52:52 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so1435963pab.11
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 19:52:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_state_machine should check whether auto-negotiatin is completed
before changing phydev->state from PHY_NOLINK to PHY_RUNNING. If
auto-negotiation is not completed phydev->state should be set to
PHY_AN.

Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
---
 drivers/net/phy/phy.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1b6d09a..a972056 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -765,6 +765,17 @@ void phy_state_machine(struct work_struct *work)
 			break;
 
 		if (phydev->link) {
+			if (AUTONEG_ENABLE == phydev->autoneg) {
+				err = phy_aneg_done(phydev);
+				if (err < 0)
+					break;
+
+				if (!err) {
+					phydev->state = PHY_AN;
+					phydev->link_timeout = PHY_AN_TIMEOUT;
+					break;
+				}
+			}
 			phydev->state = PHY_RUNNING;
 			netif_carrier_on(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
-- 
1.8.2.1
