From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH] net: mv88e6xxx: Fix ingress rate removal for mv6131 chips
Date: Mon, 22 Aug 2016 22:47:08 +0100
Message-ID: <1471902428-24250-1-git-send-email-jm@lentin.co.uk>
Cc: netdev@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from marmot.wormnet.eu ([188.246.204.87]:32832 "EHLO
        marmot.wormnet.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755580AbcHVVrp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 17:47:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PORT_RATE_CONTROL register works differently on 88e6095/6095f/6131
in comparison to 6123/61/65, and 0x0 disables. The distinction was lost
Linux 4.1 --> 4.2

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
Tested on a Netgear WNR854T With a mv88e6131 switch chip, on top of
Andrew Lunn's 6131 tagging work:
  https://www.mail-archive.com/netdev@vger.kernel.org/msg124142.html

Also available at https://github.com/lentinj/linux 6131-ingress-rate-v1
---
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 82d4516..22d02dd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2646,15 +2646,19 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			return ret;
 	}
 
+	/* Rate Control: disable ingress rate limiting. */
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
-	    mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip) ||
 	    mv88e6xxx_6320_family(chip)) {
-		/* Rate Control: disable ingress rate limiting. */
 		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
 					   PORT_RATE_CONTROL, 0x0001);
 		if (ret)
 			return ret;
+	} else if (mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip)) {
+		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
+					   PORT_RATE_CONTROL, 0x0000);
+		if (ret)
+			return ret;
 	}
 
 	/* Port Control 1: disable trunking, disable sending
-- 
2.8.1
