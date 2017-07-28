From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: phy: Correctly process PHY_HALTED in phy_stop_machine()
Date: Fri, 28 Jul 2017 11:58:36 -0700
Message-ID: <20170728185836.28759-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, slash.tmp@free.fr,
        marc_gonzalez@sigmadesigns.com, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37376 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752204AbdG1TAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 15:00:43 -0400
Received: by mail-wr0-f196.google.com with SMTP id 12so19132364wrb.4
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 12:00:42 -0700 (PDT)
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

Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- reword subject and commit message based on changes
- dropped flush_scheduled_work() since it is redundant

 drivers/net/phy/phy.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..5068c582d502 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -749,6 +749,9 @@ void phy_stop_machine(struct phy_device *phydev)
 	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
 		phydev->state = PHY_UP;
 	mutex_unlock(&phydev->lock);
+
+	/* Now we can run the state machine synchronously */
+	phy_state_machine(&phydev->state_queue.work);
 }
 
 /**
-- 
2.9.3
