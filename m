From: <shh.xie@gmail.com>
Subject: [PATCH] net: phylib: fix interrupts re-enablement in phy_start
Date: Tue, 10 May 2016 17:42:26 +0800
Message-ID: <1462873346-46457-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@nxp.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0080.outbound.protection.outlook.com ([65.55.169.80]:59568
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751054AbcEJK0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 06:26:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@nxp.com>

If phy was suspended and is starting, current driver always enable
phy's interrupts, if phy works in polling, phy can raise unexpected
interrupt which will not be handled, the interrupt will block system
enter suspend again. So interrupts should only be re-enabled if phy
works in interrupt.

Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>
---
 drivers/net/phy/phy.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 6f221c8..baa5ecb 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -871,9 +871,11 @@ void phy_start(struct phy_device *phydev)
 		break;
 	case PHY_HALTED:
 		/* make sure interrupts are re-enabled for the PHY */
-		err = phy_enable_interrupts(phydev);
-		if (err < 0)
-			break;
+		if (phydev->irq != PHY_POLL) {
+			err = phy_enable_interrupts(phydev);
+			if (err < 0)
+				break;
+		}
 
 		phydev->state = PHY_RESUMING;
 		do_resume = true;
-- 
2.1.0.27.g96db324
