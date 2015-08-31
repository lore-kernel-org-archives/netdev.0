From: Andrew Lunn <andrew@lunn.ch>
Subject: [Patch v2 RFT net-next 6/9] dsa: mv88e6xxx: Set the RGMII delay based on phy interface
Date: Mon, 31 Aug 2015 15:56:51 +0200
Message-ID: <1441029414-20062-7-git-send-email-andrew@lunn.ch>
References: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>, Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42631 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040AbbHaOFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 10:05:33 -0400
In-Reply-To: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Marvell switches allow the RGMII Rx and Tx clock to be delayed
when the port is using RGMII. Have the adjust_link function look at
the phy interface type and enable this delay as requested.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1a8c45f3e680..90dee97ae793 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -612,6 +612,16 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	if (phydev->duplex == DUPLEX_FULL)
 		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
 
+	if ((mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds)) &&
+	    (port >= ps->num_ports - 2)) {
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+			reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+			reg |= PORT_PCS_CTRL_RGMII_DELAY_TXCLK;
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+			reg |= (PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
+				PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
+	}
 	_mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_PCS_CTRL, reg);
 
 out:
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 79003c55fe62..9b6f3d9d5ae1 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -46,6 +46,8 @@
 #define PORT_STATUS_TX_PAUSED	BIT(5)
 #define PORT_STATUS_FLOW_CTRL	BIT(4)
 #define PORT_PCS_CTRL		0x01
+#define PORT_PCS_CTRL_RGMII_DELAY_RXCLK	BIT(15)
+#define PORT_PCS_CTRL_RGMII_DELAY_TXCLK	BIT(14)
 #define PORT_PCS_CTRL_FC		BIT(7)
 #define PORT_PCS_CTRL_FORCE_FC		BIT(6)
 #define PORT_PCS_CTRL_LINK_UP		BIT(5)
-- 
2.5.0
