From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: phy: re-apply PHY fixups during phy_register_device
Date: Mon, 28 Jul 2014 16:28:07 -0700
Message-ID: <1406590087-28446-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jogo@openwrt.org, hauke@hauke-m.de,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:45964 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbaG1X2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 19:28:13 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa1so11388091pad.13
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 16:28:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
moved the call to phy_scan_fixups() in phy_init_hw() after a software
reset is performed.

By the time phy_init_hw() is called in phy_device_register(), no driver
has been bound to this PHY yet, so all the checks in phy_init_hw()
against the PHY driver and the PHY driver's config_init function will
return 0. We will therefore never call phy_scan_fixups() as we should.

Fix this by calling phy_scan_fixups() and check for its return value to
restore the intended functionality.

This broke PHY drivers which do register an early PHY fixup callback to
intercept the PHY probing and do things like changing the 32-bits unique
PHY identifier when a pseudo-PHY address has been used, as well as
board-specific PHY fixups that need to be applied during driver probe
time.

Reported-by: Hauke Merthens <hauke-m@hauke-m.de>
Reported-by: Jonas Gorski <jogo@openwrt.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- call phy_scan_fixups directly since this is what we are interested in
- check the phy_scan_fixups return value

Applicable for 3.14+

 drivers/net/phy/phy_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 74a82328dd49..22c57be4dfa0 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -355,7 +355,7 @@ int phy_device_register(struct phy_device *phydev)
 	phydev->bus->phy_map[phydev->addr] = phydev;
 
 	/* Run all of the fixups for this PHY */
-	err = phy_init_hw(phydev);
+	err = phy_scan_fixups(phydev);
 	if (err) {
 		pr_err("PHY %d failed to initialize\n", phydev->addr);
 		goto out;
-- 
1.9.1
