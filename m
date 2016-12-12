From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH net-next 3/3] net:dsa:mv88e6xxx: use hashtable instead of atu_get
Date: Mon, 12 Dec 2016 14:41:35 +0100
Message-ID: <1481550095-4970-1-git-send-email-volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33363 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbcLLNlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:41:55 -0500
Received: by mail-wj0-f193.google.com with SMTP id kp2so11624352wjc.0
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 05:41:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv88e6xxx_atu_get() is quite slow, and therefore can be
replaced with hashtable helper functions that are much
faster when inserting entries into the database, or searching
for them. The logics in mv88e6xxx_db_load_purte() is similar to
previous implementation, but hashtable helper functions
are used instead of mv88e6xxx_atu_get().

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 63 +++++++++++-----------------------------
 1 file changed, 17 insertions(+), 46 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 6597f3f..6032c5b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2069,42 +2069,6 @@ static u16 mv88e6xxx_pvec_tbl_get(struct mv88e6xxx_chip *chip,
         return 0;
 }
 
-static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
-				  struct mv88e6xxx_atu_entry *entry);
-
-static int mv88e6xxx_atu_get(struct mv88e6xxx_chip *chip, int fid,
-			     const u8 *addr, struct mv88e6xxx_atu_entry *entry)
-{
-	struct mv88e6xxx_atu_entry next;
-	int err;
-
-	eth_broadcast_addr(next.mac);
-
-	err = _mv88e6xxx_atu_mac_write(chip, next.mac);
-	if (err)
-		return err;
-
-	do {
-		err = _mv88e6xxx_atu_getnext(chip, fid, &next);
-		if (err)
-			return err;
-
-		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
-			break;
-
-		if (ether_addr_equal(next.mac, addr)) {
-			*entry = next;
-			return 0;
-		}
-	} while (!is_broadcast_ether_addr(next.mac));
-
-	memset(entry, 0, sizeof(*entry));
-	entry->fid = fid;
-	ether_addr_copy(entry->mac, addr);
-
-	return 0;
-}
-
 static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 					const unsigned char *addr, u16 vid,
 					u8 state)
@@ -2121,18 +2085,25 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	err = mv88e6xxx_atu_get(chip, vlan.fid, addr, &entry);
-	if (err)
-		return err;
+	entry.fid = vlan.fid;
+	entry.state = state;
+	ether_addr_copy(entry.mac, addr);
+
+	/* multicast entries can use several ports for each address */
+	if (is_multicast_ether_addr(addr)) {
+		entry.portv_trunkid = mv88e6xxx_pvec_tbl_get(chip, entry.fid, addr);
+		if (state == GLOBAL_ATU_DATA_STATE_UNUSED)
+			entry.portv_trunkid &= ~BIT(port);
+		else
+			entry.portv_trunkid |= BIT(port);
 
-	/* Purge the ATU entry only if no port is using it anymore */
-	if (state == GLOBAL_ATU_DATA_STATE_UNUSED) {
-		entry.portv_trunkid &= ~BIT(port);
-		if (!entry.portv_trunkid)
-			entry.state = GLOBAL_ATU_DATA_STATE_UNUSED;
+		mv88e6xxx_pvec_tbl_update(chip, entry.fid, addr, entry.portv_trunkid);
+		entry.trunk = false;
 	} else {
-		entry.portv_trunkid |= BIT(port);
-		entry.state = state;
+		if (state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+			entry.trunk = false;
+			entry.portv_trunkid = BIT(port);
+		}
 	}
 
 	return _mv88e6xxx_atu_load(chip, &entry);
-- 
2.7.4
