From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/2] net: dsa: mv88e6171: Enable access to phys via internal mdio bus
Date: Sat, 14 Feb 2015 19:17:51 +0100
Message-ID: <1423937871-9180-3-git-send-email-andrew@lunn.ch>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44417 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091AbbBNSUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Feb 2015 13:20:51 -0500
In-Reply-To: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device is configured to use single chip addressing mode, the
phy devices of the port are not accessible on the host MDIO
bus. Instead the switch internal MDIO bus must be used. For this to
work, the phy polling unit must be enabled.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6171.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index aa33d16f2e22..9808c860a797 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -51,8 +51,11 @@ static int mv88e6171_switch_reset(struct dsa_switch *ds)
 	/* Wait for transmit queues to drain. */
 	usleep_range(2000, 4000);
 
-	/* Reset the switch. */
-	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
+	/* Reset the switch. Keep PPU active.  The PPU needs to be
+	 * active to support indirect phy register accesses through
+	 * global registers 0x18 and 0x19.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x04, 0xc000);
 
 	/* Wait up to one second for reset to complete. */
 	timeout = jiffies + 1 * HZ;
@@ -83,11 +86,10 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	int ret;
 	int i;
 
-	/* Disable the PHY polling unit (since there won't be any
-	 * external PHYs to poll), don't discard packets with
-	 * excessive collisions, and mask all interrupt sources.
+	/* Discard packets with excessive collisions, mask all
+	 * interrupt sources, enable PPU.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x0000);
+	REG_WRITE(REG_GLOBAL, 0x04, 0x6000);
 
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
@@ -336,7 +338,7 @@ mv88e6171_phy_read(struct dsa_switch *ds, int port, int regnum)
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_read(ds, addr, regnum);
+	ret = mv88e6xxx_phy_read_indirect(ds, addr, regnum);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
@@ -350,7 +352,7 @@ mv88e6171_phy_write(struct dsa_switch *ds,
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write(ds, addr, regnum, val);
+	ret = mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
-- 
2.1.4
