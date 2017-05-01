From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 12/18] net: dsa: mv88e6xxx: load STU entry with VTU entry
Date: Mon,  1 May 2017 14:05:21 -0400
Message-ID: <20170501180527.11756-13-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48406 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdEASHp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:07:45 -0400
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the code writes both VTU and STU data when loading a VTU entry,
load the corresponding STU entry at the same time.

This allows us to get rid of the STU management in the
_mv88e6xxx_vtu_new helper and thus remove the separate implementations
of STU Load/Purge and STU GetNext, as well as the unused family checks.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 108 ++-------------------------------------
 1 file changed, 4 insertions(+), 104 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 38c3e047fbf9..fc30a3e3df47 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -677,31 +677,6 @@ static int mv88e6xxx_phy_ppu_write(struct mv88e6xxx_chip *chip,
 	return err;
 }
 
-static bool mv88e6xxx_6097_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6097;
-}
-
-static bool mv88e6xxx_6165_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6165;
-}
-
-static bool mv88e6xxx_6341_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6341;
-}
-
-static bool mv88e6xxx_6351_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6351;
-}
-
-static bool mv88e6xxx_6352_family(struct mv88e6xxx_chip *chip)
-{
-	return chip->info->family == MV88E6XXX_FAMILY_6352;
-}
-
 static int mv88e6xxx_port_setup_mac(struct mv88e6xxx_chip *chip, int port,
 				    int link, int speed, int duplex,
 				    phy_interface_t mode)
@@ -1393,6 +1368,10 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 		err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
 		if (err)
 			return err;
+
+		err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+		if (err)
+			return err;
 	}
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
@@ -1410,60 +1389,6 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_vtu_op(chip, op);
 }
 
-static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
-				  struct mv88e6xxx_vtu_entry *entry)
-{
-	struct mv88e6xxx_vtu_entry next = {
-		.sid = sid,
-	};
-	int err;
-
-	err = mv88e6xxx_g1_vtu_op_wait(chip);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_stu_getnext(chip, &next);
-	if (err)
-		return err;
-
-	if (next.valid) {
-		err = mv88e6185_g1_vtu_data_read(chip, &next);
-		if (err)
-			return err;
-	}
-
-	*entry = next;
-	return 0;
-}
-
-static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
-				    struct mv88e6xxx_vtu_entry *entry)
-{
-	int err;
-
-	err = mv88e6xxx_g1_vtu_op_wait(chip);
-	if (err)
-		return err;
-
-	if (!entry->valid)
-		goto loadpurge;
-
-	/* Write port states */
-	err = mv88e6185_g1_vtu_data_write(chip, entry);
-	if (err)
-		return err;
-loadpurge:
-	err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
-	if (err)
-		return err;
-
-	err = mv88e6xxx_g1_vtu_sid_write(chip, entry);
-	if (err)
-		return err;
-
-	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
-}
-
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
@@ -1527,31 +1452,6 @@ static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
 			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
-	if (mv88e6xxx_6097_family(chip) || mv88e6xxx_6165_family(chip) ||
-	    mv88e6xxx_6351_family(chip) || mv88e6xxx_6352_family(chip) ||
-	    mv88e6xxx_6341_family(chip)) {
-		struct mv88e6xxx_vtu_entry vstp;
-
-		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
-		 * implemented, only one STU entry is needed to cover all VTU
-		 * entries. Thus, validate the SID 0.
-		 */
-		vlan.sid = 0;
-		err = _mv88e6xxx_stu_getnext(chip, GLOBAL_VTU_SID_MASK, &vstp);
-		if (err)
-			return err;
-
-		if (vstp.sid != vlan.sid || !vstp.valid) {
-			memset(&vstp, 0, sizeof(vstp));
-			vstp.valid = true;
-			vstp.sid = vlan.sid;
-
-			err = _mv88e6xxx_stu_loadpurge(chip, &vstp);
-			if (err)
-				return err;
-		}
-	}
-
 	*entry = vlan;
 	return 0;
 }
-- 
2.12.2
