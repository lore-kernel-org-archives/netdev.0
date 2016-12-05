From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 1/4] net: dsa: mv88e6xxx: add helper to disable ports
Date: Mon,  5 Dec 2016 11:27:00 -0500
Message-ID: <20161205162703.22567-2-vivien.didelot@savoirfairelinux.com>
References: <20161205162703.22567-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <eichest@gmail.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33490 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751518AbcLEQ1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:27:38 -0500
In-Reply-To: <20161205162703.22567-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before resetting a switch, the ports should be set to the Disabled state
and the transmit queues should be drained.

Add an helper to explicit that.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ca453f3..1d4d3be 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2356,6 +2356,26 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6xxx_disable_ports(struct mv88e6xxx_chip *chip)
+{
+	int i, err;
+
+	/* Set all ports to the Disabled state */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); i++) {
+		err = mv88e6xxx_port_set_state(chip, i,
+					       PORT_CONTROL_STATE_DISABLED);
+		if (err)
+			return err;
+	}
+
+	/* Wait for transmit queues to drain,
+	 * i.e. 2ms for a maximum frame to be transmitted at 10 Mbps.
+	 */
+	usleep_range(2000, 4000);
+
+	return 0;
+}
+
 static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 {
 	bool ppu_active = mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE);
@@ -2364,18 +2384,10 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	unsigned long timeout;
 	u16 reg;
 	int err;
-	int i;
 
-	/* Set all ports to the disabled state. */
-	for (i = 0; i < mv88e6xxx_num_ports(chip); i++) {
-		err = mv88e6xxx_port_set_state(chip, i,
-					       PORT_CONTROL_STATE_DISABLED);
-		if (err)
-			return err;
-	}
-
-	/* Wait for transmit queues to drain. */
-	usleep_range(2000, 4000);
+	err = mv88e6xxx_disable_ports(chip);
+	if (err)
+		return err;
 
 	/* If there is a gpio connected to the reset pin, toggle it */
 	if (gpiod) {
-- 
2.10.2
