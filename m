From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/9] net: dsa: mv88e6xxx: remap existing bridge members
Date: Wed, 29 Mar 2017 16:30:18 -0400
Message-ID: <20170329203020.27042-8-vivien.didelot@savoirfairelinux.com>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a local port of a switch chip becomes a member of a bridge group,
we need to reprogram the Cross-chip Port Based VLAN Table (PVT) to allow
existing cross-chip bridge members to egress frames on the new ports.

There is no functional changes yet, since the PVT is still programmed
with all ones, allowing any external port to egress frames locally.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 99f8c6106af5..31c296a04f03 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2143,7 +2143,9 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 static int mv88e6xxx_bridge_map(struct mv88e6xxx_chip *chip,
 				struct net_device *br)
 {
+	struct dsa_switch *ds;
 	int port;
+	int dev;
 	int err;
 
 	/* Remap the Port VLAN of each local bridge group member */
@@ -2155,6 +2157,24 @@ static int mv88e6xxx_bridge_map(struct mv88e6xxx_chip *chip,
 		}
 	}
 
+	if (!mv88e6xxx_has_pvt(chip))
+		return 0;
+
+	/* Remap the Port VLAN of each cross-chip bridge group member */
+	for (dev = 0; dev < DSA_MAX_SWITCHES; ++dev) {
+		ds = chip->ds->dst->ds[dev];
+		if (!ds)
+			break;
+
+		for (port = 0; port < ds->num_ports; ++port) {
+			if (ds->ports[port].bridge_dev == br) {
+				err = mv88e6xxx_pvt_map(chip, dev, port);
+				if (err)
+					return err;
+			}
+		}
+	}
+
 	return 0;
 }
 
-- 
2.12.1
