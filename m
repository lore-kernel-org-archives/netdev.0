From: Tim Beale <tim.beale@alliedtelesis.co.nz>
Subject: [PATCH] net: phy: Make sure phy_start() always re-enables the phy interrupts
Date: Mon, 18 May 2015 15:38:38 +1200
Message-ID: <1431920318-7157-1-git-send-email-tim.beale@alliedtelesis.co.nz>
References: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Cc: netdev@vger.kernel.org, Tim Beale <tim.beale@alliedtelesis.co.nz>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:48312 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbbERDiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:38:54 -0400
In-Reply-To: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an alternative way of fixing:
 commit db9683fb412d ("net: phy: Make sure PHY_RESUMING state change
                      is always processed")

When the PHY state transitions from PHY_HALTED to PHY_RESUMING, there are
two things we need to do:
1). Re-enable interrupts (and power up the physical link, if powered down)
2). Update the PHY state and net-device based on the link status.

There's no strict reason why #1 has to be done from within the main
phy_state_machine() function. There is a risk that other changes to the
PHY (e.g. setting speed/duplex, which calls phy_start_aneg()) could cause
a subsequent state transition before phy_state_machine() has processed
the PHY_RESUMING state change. This would leave the PHY with interrupts
disabled and/or still in the BMCR_PDOWN/low-power mode.

Moving enabling the interrupts and phy_resume() into phy_start() will
guarantee this work always gets done. As the PHY is already in the HALTED
state and interrupts are disabled, it shouldn't conflict with any work
being done in phy_state_machine(). The downside of this change is that if
the PHY_RESUMING state is ever entered from anywhere else, it'll also have
to repeat this work.

Signed-off-by: Tim Beale <tim.beale@alliedtelesis.co.nz>
---
 drivers/net/phy/phy.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 9855b96..87677e6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -465,7 +465,7 @@ int phy_start_aneg(struct phy_device *phydev)
 	if (err < 0)
 		goto out_unlock;
 
-	if (phydev->state != PHY_HALTED && phydev->state != PHY_RESUMING) {
+	if (phydev->state != PHY_HALTED) {
 		if (AUTONEG_ENABLE == phydev->autoneg) {
 			phydev->state = PHY_AN;
 			phydev->link_timeout = PHY_AN_TIMEOUT;
@@ -742,6 +742,9 @@ EXPORT_SYMBOL(phy_stop);
  */
 void phy_start(struct phy_device *phydev)
 {
+	bool do_resume = false;
+	int err = 0;
+
 	mutex_lock(&phydev->lock);
 
 	switch (phydev->state) {
@@ -752,11 +755,22 @@ void phy_start(struct phy_device *phydev)
 		phydev->state = PHY_UP;
 		break;
 	case PHY_HALTED:
+		/* make sure interrupts are re-enabled for the PHY */
+		err = phy_enable_interrupts(phydev);
+		if (err < 0)
+			break;
+
 		phydev->state = PHY_RESUMING;
+		do_resume = true;
+		break;
 	default:
 		break;
 	}
 	mutex_unlock(&phydev->lock);
+
+	/* if phy was suspended, bring the physical link up again */
+	if (do_resume)
+		phy_resume(phydev);
 }
 EXPORT_SYMBOL(phy_start);
 
@@ -769,7 +783,7 @@ void phy_state_machine(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct phy_device *phydev =
 			container_of(dwork, struct phy_device, state_queue);
-	bool needs_aneg = false, do_suspend = false, do_resume = false;
+	bool needs_aneg = false, do_suspend = false;
 	int err = 0;
 
 	mutex_lock(&phydev->lock);
@@ -888,14 +902,6 @@ void phy_state_machine(struct work_struct *work)
 		}
 		break;
 	case PHY_RESUMING:
-		err = phy_clear_interrupt(phydev);
-		if (err)
-			break;
-
-		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
-		if (err)
-			break;
-
 		if (AUTONEG_ENABLE == phydev->autoneg) {
 			err = phy_aneg_done(phydev);
 			if (err < 0)
@@ -933,7 +939,6 @@ void phy_state_machine(struct work_struct *work)
 			}
 			phydev->adjust_link(phydev->attached_dev);
 		}
-		do_resume = true;
 		break;
 	}
 
@@ -943,8 +948,6 @@ void phy_state_machine(struct work_struct *work)
 		err = phy_start_aneg(phydev);
 	else if (do_suspend)
 		phy_suspend(phydev);
-	else if (do_resume)
-		phy_resume(phydev);
 
 	if (err < 0)
 		phy_error(phydev);
-- 
1.9.1
