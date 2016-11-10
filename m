From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Don't modify RGMII delays when not RGMII mode
Date: Thu, 10 Nov 2016 15:44:00 +0100
Message-ID: <1478789041-16264-2-git-send-email-andrew@lunn.ch>
References: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34162 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933598AbcKJOoY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 09:44:24 -0500
In-Reply-To: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RGMII modes delays can be set via strapping pings or EEPROM.
Don't change them unless explicitly asked to change them.  The recent
refactoring of setting the MAC configuration changed this behaviours,
in that CPU and DSA ports have any pre-configured RGMII delays
removed. This breaks the Armada 370RD board. Restore the previous
behaviour, in that RGMII delays are only applied/removed when
explicitly asked for via an phy-mode being PHY_INTERFACE_MODE_RGMII*

Fixes: 7340e5ecdbb1 ("net: dsa: mv88e6xxx: setup port's MAC")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/port.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 18eeed083cbd..e4978f6367aa 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -63,9 +63,10 @@ static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 		reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
 			PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
 		break;
-	default:
-		/* no delay */
+	case PHY_INTERFACE_MODE_RGMII:
 		break;
+	default:
+		return 0;
 	}
 
 	err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
-- 
2.10.2
