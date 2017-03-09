From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/14] net: dsa: mv88e6xxx: rename the port vector member
Date: Thu,  9 Mar 2017 18:33:19 -0500
Message-ID: <20170309233324.18539-10-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all Marvell switch chips support port trunking, which is embedded in
the port vector data for ATU operations.

Rename the portv_trunkid member of the mv88e6xxx_atu_entry structure to
portvec to be more concise and consistent with the different chips.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 8 ++++----
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 8 ++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   | 2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e45c2f3ed654..ef20b33d9a06 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1930,11 +1930,11 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 
 	/* Purge the ATU entry only if no port is using it anymore */
 	if (state == GLOBAL_ATU_DATA_STATE_UNUSED) {
-		entry.portv_trunkid &= ~BIT(port);
-		if (!entry.portv_trunkid)
+		entry.portvec &= ~BIT(port);
+		if (!entry.portvec)
 			entry.state = GLOBAL_ATU_DATA_STATE_UNUSED;
 	} else {
-		entry.portv_trunkid |= BIT(port);
+		entry.portvec |= BIT(port);
 		entry.state = state;
 	}
 
@@ -1997,7 +1997,7 @@ static int mv88e6xxx_port_db_dump_fid(struct mv88e6xxx_chip *chip,
 		if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
 			break;
 
-		if (addr.trunk || (addr.portv_trunkid & BIT(port)) == 0)
+		if (addr.trunk || (addr.portvec & BIT(port)) == 0)
 			continue;
 
 		if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index d753e3eb1359..120b7f41a735 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -124,7 +124,7 @@ static int mv88e6xxx_g1_atu_data_read(struct mv88e6xxx_chip *chip,
 		if (val & GLOBAL_ATU_DATA_TRUNK)
 			entry->trunk = true;
 
-		entry->portv_trunkid = (val >> 4) & mv88e6xxx_port_mask(chip);
+		entry->portvec = (val >> 4) & mv88e6xxx_port_mask(chip);
 	}
 
 	return 0;
@@ -139,7 +139,7 @@ static int mv88e6xxx_g1_atu_data_write(struct mv88e6xxx_chip *chip,
 		if (entry->trunk)
 			data |= GLOBAL_ATU_DATA_TRUNK;
 
-		data |= (entry->portv_trunkid & mv88e6xxx_port_mask(chip)) << 4;
+		data |= (entry->portvec & mv88e6xxx_port_mask(chip)) << 4;
 	}
 
 	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_DATA, data);
@@ -284,8 +284,8 @@ static int mv88e6xxx_g1_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
 	shift = bitmap_weight(&mask, 16);
 
 	entry.state = 0xf, /* Full EntryState means Move */
-	entry.portv_trunkid = from_port & mask;
-	entry.portv_trunkid |= (to_port & mask) << shift;
+	entry.portvec = from_port & mask;
+	entry.portvec |= (to_port & mask) << shift;
 
 	return mv88e6xxx_g1_atu_flushmove(chip, fid, &entry, all);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8724620a9316..c5c54c4608ae 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -719,7 +719,7 @@ struct mv88e6xxx_info {
 struct mv88e6xxx_atu_entry {
 	u8	state;
 	bool	trunk;
-	u16	portv_trunkid;
+	u16	portvec;
 	u8	mac[ETH_ALEN];
 };
 
-- 
2.12.0
