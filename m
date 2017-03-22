From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v2 2/2] net: phy: Don't miss phy_suspend() on PHY_HALTED for PHYs with interrupts
Date: Wed, 22 Mar 2017 13:02:04 +0200
Message-ID: <1490180524-28675-3-git-send-email-rogerq@ti.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <davem@davemloft.net>, <kyle.roeschley@ni.com>,
        <nsekhar@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Roger Quadros <rogerq@ti.com>,
        "stable # v4 . 9+" <stable@vger.kernel.org>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:25785 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759083AbdCVLWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 07:22:31 -0400
In-Reply-To: <1490180524-28675-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_suspend() doesn't get called as part of phy_stop() for PHYs
using interrupts because the phy state machine is never triggered
after a phy_stop().

Explicitly trigger the PHY state machine in phy_stop() so that it can
see the new PHY state (HALTED) and suspend the PHY.

As most PHYLIB consumers will call phy_stop() with rtnl_lock() held
from ndo_close() so we use don't wait for workqueue cancellation in
phy_trigger_machine() by passing false for the 'sync' argument.

Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
Cc: stable <stable@vger.kernel.org> # v4.9+
Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 49dedf8..ab14e7b 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -907,6 +907,7 @@ void phy_stop(struct phy_device *phydev)
 	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
 	 * will not reenable interrupts.
 	 */
+	phy_trigger_machine(phydev, false);
 }
 EXPORT_SYMBOL(phy_stop);
 
-- 
2.7.4
