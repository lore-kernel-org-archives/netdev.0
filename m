From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 06/14] net: dsa: mv88e6xxx: rework ATU Flush
Date: Thu,  9 Mar 2017 18:33:16 -0500
Message-ID: <20170309233324.18539-7-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58872 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdCIXfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 18:35:07 -0500
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a fresh documented implementation of the ATU Flush/Move operation.
Use it to replace the current ATU Flush operation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 22 +++++---------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  1 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 37 +++++++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d055ab94066b..ed170a14bc79 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1210,17 +1210,6 @@ static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_atu_cmd(chip, entry->fid, op);
 }
 
-static int _mv88e6xxx_atu_flush(struct mv88e6xxx_chip *chip,
-				u16 fid, bool static_too)
-{
-	struct mv88e6xxx_atu_entry entry = {
-		.fid = fid,
-		.state = 0, /* EntryState bits must be 0 */
-	};
-
-	return _mv88e6xxx_atu_flush_move(chip, &entry, static_too);
-}
-
 static int _mv88e6xxx_atu_move(struct mv88e6xxx_chip *chip, u16 fid,
 			       int from_port, int to_port, bool static_too)
 {
@@ -1310,6 +1299,10 @@ static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 {
 	int err;
 
+	err = mv88e6xxx_g1_atu_flush(chip, 0, true);
+	if (err)
+		return err;
+
 	if (chip->info->tag_protocol != DSA_TAG_PROTO_TRAILER) {
 		err = mv88e6xxx_g1_atu_set_learn2all(chip, true);
 		if (err)
@@ -1716,7 +1709,7 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 		return -ENOSPC;
 
 	/* Clear the database */
-	return _mv88e6xxx_atu_flush(chip, *fid, true);
+	return mv88e6xxx_g1_atu_flush(chip, *fid, true);
 }
 
 static int _mv88e6xxx_vtu_new(struct mv88e6xxx_chip *chip, u16 vid,
@@ -2639,11 +2632,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err < 0)
 		return err;
 
-	/* Clear all ATU entries */
-	err = _mv88e6xxx_atu_flush(chip, 0, true);
-	if (err)
-		return err;
-
 	/* Configure the IP ToS mapping registers. */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 8dd8ecc9f064..187acfc8ed37 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -45,5 +45,6 @@ int mv88e6xxx_g1_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 			     struct mv88e6xxx_atu_entry *entry);
 int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
 			       struct mv88e6xxx_atu_entry *entry);
+int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 94e940522849..7ec9b22feaee 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -232,3 +232,40 @@ int mv88e6xxx_g1_atu_loadpurge(struct mv88e6xxx_chip *chip, u16 fid,
 
 	return mv88e6xxx_g1_atu_op(chip, fid, GLOBAL_ATU_OP_LOAD_DB);
 }
+
+static int mv88e6xxx_g1_atu_flushmove(struct mv88e6xxx_chip *chip, u16 fid,
+				      struct mv88e6xxx_atu_entry *entry,
+				      bool all)
+{
+	u16 op;
+	int err;
+
+	err = mv88e6xxx_g1_atu_op_wait(chip);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_g1_atu_data_write(chip, entry);
+	if (err)
+		return err;
+
+	/* Flush/Move all or non-static entries from all or a given database */
+	if (all && fid)
+		op = GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB;
+	else if (fid)
+		op = GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
+	else if (all)
+		op = GLOBAL_ATU_OP_FLUSH_MOVE_ALL;
+	else
+		op = GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
+
+	return mv88e6xxx_g1_atu_op(chip, fid, op);
+}
+
+int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all)
+{
+	struct mv88e6xxx_atu_entry entry = {
+		.state = 0, /* Null EntryState means Flush */
+	};
+
+	return mv88e6xxx_g1_atu_flushmove(chip, fid, &entry, all);
+}
-- 
2.12.0
