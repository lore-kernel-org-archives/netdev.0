From: Wade Farnsworth <wfarnsworth@mvista.com>
Subject: [PATCH] phylib: fixes for PHY_RESUMING state changes
Date: Wed, 01 Jul 2009 16:00:34 -0700
Message-ID: <1246489234.26353.60.camel@rhino>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:53316 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbZGAW77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 18:59:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY_HALTED state disables phydev->link, but the link will not be
updated upon entering PHY_RESUMING.  Add a call to phy_read_status() to
update the link before entering PHY_RUNNING.  If the link is not up at
this point, enter the PHY_NOLINK state instead.

Also, when transitioning from PHY_RESUMING to PHY_RUNNING, calls to
netif_carrier_on() and phydev->adjust_link() are missing.  Add the calls
similar to the other transitions to PHY_RUNNING.

Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>
---
 drivers/net/phy/phy.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3ff1f42..4c49a21 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -919,13 +919,32 @@ static void phy_state_machine(struct work_struct *work)
 				 * Otherwise, it's 0, and we're
 				 * still waiting for AN */
 				if (err > 0) {
-					phydev->state = PHY_RUNNING;
+					err = phy_read_status(phydev);
+					if (err)
+						break;
+
+					if (phydev->link) {
+						phydev->state = PHY_RUNNING;
+						netif_carrier_on(phydev->attached_dev);
+					} else
+						phydev->state = PHY_NOLINK;
+					phydev->adjust_link(phydev->attached_dev);
 				} else {
 					phydev->state = PHY_AN;
 					phydev->link_timeout = PHY_AN_TIMEOUT;
 				}
-			} else
-				phydev->state = PHY_RUNNING;
+			} else {
+				err = phy_read_status(phydev);
+				if (err)
+					break;
+
+				if (phydev->link) {
+					phydev->state = PHY_RUNNING;
+					netif_carrier_on(phydev->attached_dev);
+				} else
+					phydev->state = PHY_NOLINK;
+				phydev->adjust_link(phydev->attached_dev);
+			}
 			break;
 	}
 


