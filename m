From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 16/18] net: dsa: mv88e6xxx: simplify VTU entry getter
Date: Wed, 26 Apr 2017 11:53:34 -0400
Message-ID: <20170426155336.5937-17-vivien.didelot@savoirfairelinux.com>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39120 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935255AbdDZPzn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 11:55:43 -0400
In-Reply-To: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code which fetches or initializes a new VTU entry more concise.
This allows us the get rid of the old underscore prefix naming.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 64 ++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 39 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 51c8b2ff9760..aede0194e341 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1359,33 +1359,8 @@ static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 	return mv88e6xxx_g1_atu_flush(chip, *fid, true);
 }
 
-static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
-			      struct mv88e6xxx_vtu_entry *entry)
-{
-	struct dsa_switch *ds = chip->ds;
-	struct mv88e6xxx_vtu_entry vlan = {
-		.valid = true,
-		.vid = vid,
-	};
-	int i, err;
-
-	err = mv88e6xxx_atu_new(chip, &vlan.fid);
-	if (err)
-		return err;
-
-	/* exclude all ports except the CPU and DSA ports */
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
-		vlan.member[i] = dsa_is_cpu_port(ds, i) ||
-			dsa_is_dsa_port(ds, i)
-			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
-			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
-
-	*entry = vlan;
-	return 0;
-}
-
-static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
-			      struct mv88e6xxx_vtu_entry *entry, bool creat)
+static int mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
+			     struct mv88e6xxx_vtu_entry *entry, bool new)
 {
 	int err;
 
@@ -1399,17 +1374,28 @@ static int _mv88e6xxx_vtu_get(struct mv88e6xxx_chip *chip, u16 vid,
 	if (err)
 		return err;
 
-	if (entry->vid != vid || !entry->valid) {
-		if (!creat)
-			return -EOPNOTSUPP;
-		/* -ENOENT would've been more appropriate, but switchdev expects
-		 * -EOPNOTSUPP to inform bridge about an eventual software VLAN.
-		 */
-
-		err = _mv88e6xxx_vtu_new(chip, vid, entry);
+	if (entry->vid == vid && entry->valid)
+		return 0;
+
+	if (new) {
+		int i;
+
+		/* Initialize a fresh VLAN entry */
+		memset(entry, 0, sizeof(*entry));
+		entry->valid = true;
+		entry->vid = vid;
+
+		/* Include only CPU and DSA ports */
+		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
+			entry->member[i] = dsa_is_normal_port(chip->ds, i) ?
+				GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER :
+				GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED;
+
+		return mv88e6xxx_atu_new(chip, &entry->fid);
 	}
 
-	return err;
+	/* switchdev expects -EOPNOTSUPP to honor software VLANs */
+	return -EOPNOTSUPP;
 }
 
 static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
@@ -1519,7 +1505,7 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 	struct mv88e6xxx_vtu_entry vlan;
 	int err;
 
-	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, true);
+	err = mv88e6xxx_vtu_get(chip, vid, &vlan, true);
 	if (err)
 		return err;
 
@@ -1564,7 +1550,7 @@ static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_chip *chip,
 	struct mv88e6xxx_vtu_entry vlan;
 	int i, err;
 
-	err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
+	err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
 		return err;
 
@@ -1639,7 +1625,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	if (vid == 0)
 		err = mv88e6xxx_port_get_fid(chip, port, &vlan.fid);
 	else
-		err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
+		err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
 		return err;
 
-- 
2.12.2
