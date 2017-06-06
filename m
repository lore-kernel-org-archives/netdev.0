From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/5] net: dsa: mv88e6xxx: do not purge a VTU entry
Date: Tue,  6 Jun 2017 16:56:31 -0400
Message-ID: <20170606205631.22880-6-vivien.didelot@savoirfairelinux.com>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx driver currently tries to be smart and remove by itself a
VLAN entry from the VTU when the driven switch sees no user ports as
members of the VLAN.

This is bad in a multi-chip switch fabric, since a chip in between
others may have no bridge port members, but still needs to be aware of
the VID in order to correctly pass frames in the data path.

Remove the code purging a VTU entry when updating a port membership.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 522f023bb17e..64c0f88f9e79 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1325,9 +1325,8 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 				    int port, u16 vid)
 {
-	struct dsa_switch *ds = chip->ds;
 	struct mv88e6xxx_vtu_entry vlan;
-	int i, err;
+	int err;
 
 	err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
@@ -1339,18 +1338,6 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 
 	vlan.member[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
-	/* keep the VLAN unless all ports are excluded */
-	vlan.valid = false;
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
-			continue;
-
-		if (vlan.member[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
-			vlan.valid = true;
-			break;
-		}
-	}
-
 	err = mv88e6xxx_vtu_loadpurge(chip, &vlan);
 	if (err)
 		return err;
-- 
2.13.0
