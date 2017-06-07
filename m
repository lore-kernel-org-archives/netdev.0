From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 5/5] net: dsa: mv88e6xxx: do not skip ports on VLAN del
Date: Wed,  7 Jun 2017 18:12:17 -0400
Message-ID: <20170607221217.2323-6-vivien.didelot@savoirfairelinux.com>
References: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx driver currently tries to be smart and remove by itself a
VLAN entry from the VTU when the driven switch sees no user ports as
members of the VLAN.

This is bad in a multi-chip switch fabric, since a chip in between
others may have no bridge port members, but still needs to be aware of
the VID in order to correctly pass frames in the data path.

Now that the DSA core explicitly manages DSA and CPU ports, do not skip
them when checking remaining VLAN members.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 41202b1d6d7f..0534eb706caa 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1325,7 +1325,6 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 				    int port, u16 vid)
 {
-	struct dsa_switch *ds = chip->ds;
 	struct mv88e6xxx_vtu_entry vlan;
 	int i, err;
 
@@ -1342,9 +1341,6 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 	/* keep the VLAN unless all ports are excluded */
 	vlan.valid = false;
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
-			continue;
-
 		if (vlan.member[i] != GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER) {
 			vlan.valid = true;
 			break;
-- 
2.13.1
