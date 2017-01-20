From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/8] net: dsa: mv88e6xxx: Set the CMODE for mv88e6390 ports 9 & 10
Date: Sat, 21 Jan 2017 00:30:58 +0100
Message-ID: <1484955062-26718-5-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40317 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751396AbdATXbY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:31:24 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike most ports, ports 9 and 10 of the 6390X family have configurable
PHY modes. Set the mode as part of adjust_link().

Ordering is important, because the SERDES interfaces connected to
ports 9 and 10 can be split and assigned to other ports. The CMODE has
to be correctly set before the SERDES interface on another port can be
configured. Such configuration is likely to be performed in
port_enable() and port_disabled(), called on slave_open() and
slave_close().

The simple case is port 9 and 10 are used for 'CPU' or 'DSA'. In this
case, the CMODE is set via a phy-mode in dsa_cpu_dsa_setup(), which is
called early in the switch setup.

When ports 9 or 10 are used as user ports, and have a fixed-phy, when
the fixed fixed-phy is attached, dsa_slave_adjust_link() is called,
which results in the adjust_link function being called, setting the
cmode. The port_enable() will for other ports will be called much
later.

When ports 9 or 10 are used as user ports and have a real phy attached
which does not use all the available SERDES interface, e.g. a 1Gbps
SGMII, there is currently no mechanism in place to set the CMODE of
the port from software. It must be hoped the stripping resistors are
correct.

At the same time, add a function to get the cmode. This will be needed
when configuring the SERDES interfaces.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      |  8 +++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  9 +++++
 drivers/net/dsa/mv88e6xxx/port.c      | 64 +++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  3 ++
 4 files changed, 84 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e79c8d09a95f..4c53db6ceffc 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -718,6 +718,12 @@ static int mv88e6xxx_port_setup_mac(struct mv88e6xxx_chip *chip, int port,
 			goto restore_link;
 	}
 
+	if (chip->info->ops->port_set_cmode) {
+		err = chip->info->ops->port_set_cmode(chip, port, mode);
+		if (err && err != -EOPNOTSUPP)
+			goto restore_link;
+	}
+
 	err = 0;
 restore_link:
 	if (chip->info->ops->port_set_link(chip, port, link))
@@ -3497,6 +3503,7 @@ static const struct mv88e6xxx_ops mv88e6290_ops = {
 	.port_set_egress_unknowns = mv88e6351_port_set_egress_unknowns,
 	.port_set_ether_type = mv88e6351_port_set_ether_type,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
@@ -3688,6 +3695,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_jumbo_config = mv88e6165_port_jumbo_config,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_config = mv88e6390_port_pause_config,
+	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
 	.stats_set_histogram = mv88e6390_g1_stats_set_histogram,
 	.stats_get_sset_count = mv88e6320_stats_get_sset_count,
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index b7f60a1bd4dc..7961467f709e 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -58,6 +58,9 @@
 #define PORT_STATUS_CMODE_100BASE_X	0x8
 #define PORT_STATUS_CMODE_1000BASE_X	0x9
 #define PORT_STATUS_CMODE_SGMII		0xa
+#define PORT_STATUS_CMODE_2500BASEX	0xb
+#define PORT_STATUS_CMODE_XAUI		0xc
+#define PORT_STATUS_CMODE_RXAUI		0xd
 #define PORT_PCS_CTRL		0x01
 #define PORT_PCS_CTRL_RGMII_DELAY_RXCLK	BIT(15)
 #define PORT_PCS_CTRL_RGMII_DELAY_TXCLK	BIT(14)
@@ -833,6 +836,12 @@ struct mv88e6xxx_ops {
 	int (*port_egress_rate_limiting)(struct mv88e6xxx_chip *chip, int port);
 	int (*port_pause_config)(struct mv88e6xxx_chip *chip, int port);
 
+	/* CMODE control what PHY mode the MAC will use, eg. SGMII, RGMII, etc.
+	 * Some chips allow this to be configured on specific ports.
+	 */
+	int (*port_set_cmode)(struct mv88e6xxx_chip *chip, int port,
+			      phy_interface_t mode);
+
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
 	 */
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 0db7fa0373ae..e253ecb6624b 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -11,6 +11,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/phy.h>
 #include "mv88e6xxx.h"
 #include "port.h"
 
@@ -304,6 +305,69 @@ int mv88e6390x_port_set_speed(struct mv88e6xxx_chip *chip, int port, int speed)
 	return mv88e6xxx_port_set_speed(chip, port, speed, true, true);
 }
 
+int mv88e6390x_port_set_cmode(struct mv88e6xxx_chip *chip, int port,
+			      phy_interface_t mode)
+{
+	u16 reg;
+	u16 cmode;
+	int err;
+
+	if (mode == PHY_INTERFACE_MODE_NA)
+		return 0;
+
+	if (port != 9 && port != 10)
+		return -EOPNOTSUPP;
+
+	switch (mode) {
+	case PHY_INTERFACE_MODE_1000BASEX:
+		cmode = PORT_STATUS_CMODE_1000BASE_X;
+		break;
+	case PHY_INTERFACE_MODE_SGMII:
+		cmode = PORT_STATUS_CMODE_SGMII;
+		break;
+	case PHY_INTERFACE_MODE_2500BASEX:
+		cmode = PORT_STATUS_CMODE_2500BASEX;
+		break;
+	case PHY_INTERFACE_MODE_XGMII:
+		cmode = PORT_STATUS_CMODE_XAUI;
+		break;
+	case PHY_INTERFACE_MODE_RXAUI:
+		cmode = PORT_STATUS_CMODE_RXAUI;
+		break;
+	default:
+		cmode = 0;
+	}
+
+	if (cmode) {
+		err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+		if (err)
+			return err;
+
+		reg &= ~PORT_STATUS_CMODE_MASK;
+		reg |= cmode;
+
+		err = mv88e6xxx_port_write(chip, port, PORT_STATUS, reg);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode)
+{
+	int err;
+	u16 reg;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+	if (err)
+		return err;
+
+	*cmode = reg & PORT_STATUS_CMODE_MASK;
+
+	return 0;
+}
+
 /* Offset 0x02: Pause Control
  *
  * Do not limit the period of time that this port can be paused for by
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 7b3bacaacbfe..cb871e306f62 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -67,5 +67,8 @@ int mv88e6095_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_egress_rate_limiting(struct mv88e6xxx_chip *chip, int port);
 int mv88e6097_port_pause_config(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_port_pause_config(struct mv88e6xxx_chip *chip, int port);
+int mv88e6390x_port_set_cmode(struct mv88e6xxx_chip *chip, int port,
+			      phy_interface_t mode);
+int mv88e6xxx_port_get_cmode(struct mv88e6xxx_chip *chip, int port, u8 *cmode);
 
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.11.0
