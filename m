From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 5/9] net: dsa: mv88e6xxx: rework in-chip bridging
Date: Thu, 30 Mar 2017 17:37:11 -0400
Message-ID: <20170330213715.9666-6-vivien.didelot@savoirfairelinux.com>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All ports -- internal and external, for chips featuring a PVT -- have a
mask restricting to which internal ports a frame is allowed to egress.

Now that DSA exposes the number of ports and their bridge devices, it is
possible to extract the code generating the VLAN map and make it generic
so that it can be shared later with the cross-chip bridging code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 53 ++++++++++++++++++++++++++--------------
 1 file changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 28bdfadbf050..9b2d369715d7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1123,27 +1123,42 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return err;
 }
 
+static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
+{
+	struct dsa_switch *ds = NULL;
+	struct net_device *br;
+	u16 pvlan;
+	int i;
+
+	if (dev < DSA_MAX_SWITCHES)
+		ds = chip->ds->dst->ds[dev];
+
+	/* Prevent frames from unknown switch or port */
+	if (!ds || port >= ds->num_ports)
+		return 0;
+
+	/* Frames from DSA links and CPU ports can egress any local port */
+	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+		return mv88e6xxx_port_mask(chip);
+
+	br = ds->ports[port].bridge_dev;
+	pvlan = 0;
+
+	/* Frames from user ports can egress any local DSA links and CPU ports,
+	 * as well as any local member of their bridge group.
+	 */
+	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
+		if (dsa_is_cpu_port(chip->ds, i) ||
+		    dsa_is_dsa_port(chip->ds, i) ||
+		    (br && chip->ds->ports[i].bridge_dev == br))
+			pvlan |= BIT(i);
+
+	return pvlan;
+}
+
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
-	struct dsa_switch *ds = chip->ds;
-	struct net_device *bridge = ds->ports[port].bridge_dev;
-	u16 output_ports = 0;
-	int i;
-
-	/* allow CPU port or DSA link(s) to send frames to every port */
-	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
-		output_ports = ~0;
-	} else {
-		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-			/* allow sending frames to every group member */
-			if (bridge && ds->ports[i].bridge_dev == bridge)
-				output_ports |= BIT(i);
-
-			/* allow sending frames to CPU port and DSA link(s) */
-			if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
-				output_ports |= BIT(i);
-		}
-	}
+	u16 output_ports = mv88e6xxx_port_vlan(chip, chip->ds->index, port);
 
 	/* prevent frames from going back out of the port they came in on */
 	output_ports &= ~BIT(port);
-- 
2.12.1
