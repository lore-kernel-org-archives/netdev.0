From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS
Date: Mon, 18 Jan 2016 19:33:06 -0800
Message-ID: <1453174388-26752-2-git-send-email-f.fainelli@gmail.com>
References: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com, Woojung.Huh@microchip.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33015 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373AbcASDd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 22:33:56 -0500
Received: by mail-pf0-f179.google.com with SMTP id e65so168076535pfe.0
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 19:33:56 -0800 (PST)
In-Reply-To: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2c7b49212a86 ("phy: fix the use of PHY_IGNORE_INTERRUPT") changed
a hunk in phy_state_machine() in the PHY_RUNNING case which was not
needed. The change essentially makes the PHY library treat PHY devices
with PHY_IGNORE_INTERRUPT to keep polling for the PHY device, even
though the intent is not to do it.

Fix this by reverting that specific hunk, which makes the PHY state
machine wait for state changes, and stay in the PHY_RUNNING state for as
long as needed.

Fixes: 2c7b49212a86 ("phy: fix the use of PHY_IGNORE_INTERRUPT")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 8763bb20988a..42b4c1eb7a90 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -905,10 +905,10 @@ void phy_state_machine(struct work_struct *work)
 		phydev->adjust_link(phydev->attached_dev);
 		break;
 	case PHY_RUNNING:
-		/* Only register a CHANGE if we are polling or ignoring
-		 * interrupts and link changed since latest checking.
+		/* Only register a CHANGE if we are polling and link changed
+		 * since latest checking.
 		 */
-		if (!phy_interrupt_is_valid(phydev)) {
+		if (phydev->irq == PHY_POLL) {
 			old_link = phydev->link;
 			err = phy_read_status(phydev);
 			if (err)
@@ -1000,8 +1000,13 @@ void phy_state_machine(struct work_struct *work)
 		   phy_state_to_str(old_state),
 		   phy_state_to_str(phydev->state));
 
-	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
-			   PHY_STATE_TIME * HZ);
+	/* Only re-schedule a PHY state machine change if we are polling the
+	 * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
+	 * between states from phy_mac_interrupt()
+	 */
+	if (phydev->irq == PHY_POLL)
+		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
+				   PHY_STATE_TIME * HZ);
 }
 
 void phy_mac_interrupt(struct phy_device *phydev, int new_link)
-- 
2.1.0
