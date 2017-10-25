From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 4/4] net: phy: Correctly process PHY_HALTED in phy_stop_machine()
Date: Wed, 25 Oct 2017 16:21:24 -0700
Message-ID: <20171025232124.14120-5-f.fainelli@gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        davem@davemloft.net, andrew@lunn.ch, opendmb@gmail.com,
        slash.tmp@free.fr, david.daney@cavium.com, geert+renesas@glider.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:44909 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932197AbdJYXVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 19:21:47 -0400
Received: by mail-qt0-f193.google.com with SMTP id 8so2200910qtv.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:21:47 -0700 (PDT)
In-Reply-To: <20171025232124.14120-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc reported that he was not getting the PHY library adjust_link()
callback function to run when calling phy_stop() + phy_disconnect()
which does not indeed happen because we set the state machine to
PHY_HALTED but we don't get to run it to process this state past that
point.

Fix this with a synchronous call to phy_state_machine() in order to have
the state machine actually act on PHY_HALTED, set the PHY device's link
down, turn the network device's carrier off and finally call the
adjust_link() function.

At the end of phy_state_machine() though, if we are going to be moving
from PHY_HALTED to PHY_HALTED, do not reschedule the state machine, this
is pointless.

Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 0ddeb97217ce..20b84ea013c0 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -594,6 +594,9 @@ void phy_stop_machine(struct phy_device *phydev)
 	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
 		phydev->state = PHY_UP;
 	mutex_unlock(&phydev->lock);
+
+	/* Now we can run the state machine synchronously */
+	phy_state_machine(&phydev->state_queue.work);
 }
 EXPORT_SYMBOL_GPL(phy_stop_machine);
 
@@ -1077,9 +1080,14 @@ void phy_state_machine(struct work_struct *work)
 
 	/* Only re-schedule a PHY state machine change if we are polling the
 	 * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
-	 * between states from phy_mac_interrupt()
+	 * between states from phy_mac_interrupt().
+	 *
+	 * If do_suspend is set to true from PHY_HALTED, in that case, do not
+	 * reschedule the state machine since that would be pointless and
+	 * possibly error prone when called from phy_disconnect()
+	 * synchronously.
 	 */
-	if (phydev->irq == PHY_POLL)
+	if (phydev->irq == PHY_POLL && !do_suspend)
 		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
 				   PHY_STATE_TIME * HZ);
 }
-- 
2.9.3
