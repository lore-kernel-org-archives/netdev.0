From: Tim Beale <tim.beale@alliedtelesis.co.nz>
Subject: [PATCH] net: phy: Make sure PHY_RESUMING state change is always processed
Date: Wed, 13 May 2015 13:55:04 +1200
Message-ID: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Cc: netdev@vger.kernel.org, Tim Beale <tim.beale@alliedtelesis.co.nz>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:40789 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964909AbbEMBzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 21:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If phy_start_aneg() was called while the phydev is in the PHY_RESUMING
state, then its state would immediately transition to PHY_AN (or
PHY_FORCING). This meant the phy_state_machine() never processed the
PHY_RESUMING state change, which meant interrupts weren't enabled for the
PHY. If the PHY used low-power mode (i.e. using BMCR_PDOWN), then the
physical link wouldn't get powered up again.

There seems no point for phy_start_aneg() to make the PHY_RESUMING -->
PHY_AN transition, as the state machine will do this anyway. I'm not sure
about the case where autoneg is disabled, as my patch will change
behaviour so that the PHY goes to PHY_NOLINK instead of PHY_FORCING. An
alternative solution would be to move the phy_config_interrupt() and
phy_resume() work out of the state machine and into phy_start().

The background behind this: we're running linux v3.16.7 and from user-space
we want to enable the eth port (i.e. do a SIOCSIFFLAGS ioctl with the
IFF_UP flag) and immediately afterward set the interface's speed/duplex.
Enabling the interface calls .ndo_open() then phy_start() and the PHY
transitions PHY_HALTED --> PHY_RESUMING. Setting the speed/duplex ends up
calling phy_ethtool_sset(), which calls phy_start_aneg() (meanwhile the
phy_state_machine() hasn't processed the PHY_RESUMING state change yet).

Signed-off-by: Tim Beale <tim.beale@alliedtelesis.co.nz>
---
 drivers/net/phy/phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 52cd8db..9855b96 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -465,7 +465,7 @@ int phy_start_aneg(struct phy_device *phydev)
 	if (err < 0)
 		goto out_unlock;
 
-	if (phydev->state != PHY_HALTED) {
+	if (phydev->state != PHY_HALTED && phydev->state != PHY_RESUMING) {
 		if (AUTONEG_ENABLE == phydev->autoneg) {
 			phydev->state = PHY_AN;
 			phydev->link_timeout = PHY_AN_TIMEOUT;
-- 
1.9.1
