From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/6] net: dsa: mv88e6xxx: Move mv88e6xxx_port_db_load_purge()
Date: Wed, 27 Sep 2017 00:26:02 +0200
Message-ID: <1506464764-12699-6-git-send-email-andrew@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57019 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969562AbdIZW1h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:27:37 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is going to be needed by a soon to be added new
function. Move it earlier so we can avoid a forward declaration.
No code changes.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 88 ++++++++++++++++++++--------------------
 1 file changed, 44 insertions(+), 44 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8a4756490a5a..9fbe1f02b9ce 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1191,6 +1191,50 @@ mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
+					const unsigned char *addr, u16 vid,
+					u8 state)
+{
+	struct mv88e6xxx_vtu_entry vlan;
+	struct mv88e6xxx_atu_entry entry;
+	int err;
+
+	/* Null VLAN ID corresponds to the port private database */
+	if (vid == 0)
+		err = mv88e6xxx_port_get_fid(chip, port, &vlan.fid);
+	else
+		err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
+	if (err)
+		return err;
+
+	entry.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
+	ether_addr_copy(entry.mac, addr);
+	eth_addr_dec(entry.mac);
+
+	err = mv88e6xxx_g1_atu_getnext(chip, vlan.fid, &entry);
+	if (err)
+		return err;
+
+	/* Initialize a fresh ATU entry if it isn't found */
+	if (entry.state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED ||
+	    !ether_addr_equal(entry.mac, addr)) {
+		memset(&entry, 0, sizeof(entry));
+		ether_addr_copy(entry.mac, addr);
+	}
+
+	/* Purge the ATU entry only if no port is using it anymore */
+	if (state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED) {
+		entry.portvec &= ~BIT(port);
+		if (!entry.portvec)
+			entry.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
+	} else {
+		entry.portvec |= BIT(port);
+		entry.state = state;
+	}
+
+	return mv88e6xxx_g1_atu_loadpurge(chip, vlan.fid, &entry);
+}
+
 static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 				    u16 vid, u8 member)
 {
@@ -1307,50 +1351,6 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
-					const unsigned char *addr, u16 vid,
-					u8 state)
-{
-	struct mv88e6xxx_vtu_entry vlan;
-	struct mv88e6xxx_atu_entry entry;
-	int err;
-
-	/* Null VLAN ID corresponds to the port private database */
-	if (vid == 0)
-		err = mv88e6xxx_port_get_fid(chip, port, &vlan.fid);
-	else
-		err = mv88e6xxx_vtu_get(chip, vid, &vlan, false);
-	if (err)
-		return err;
-
-	entry.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
-	ether_addr_copy(entry.mac, addr);
-	eth_addr_dec(entry.mac);
-
-	err = mv88e6xxx_g1_atu_getnext(chip, vlan.fid, &entry);
-	if (err)
-		return err;
-
-	/* Initialize a fresh ATU entry if it isn't found */
-	if (entry.state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED ||
-	    !ether_addr_equal(entry.mac, addr)) {
-		memset(&entry, 0, sizeof(entry));
-		ether_addr_copy(entry.mac, addr);
-	}
-
-	/* Purge the ATU entry only if no port is using it anymore */
-	if (state == MV88E6XXX_G1_ATU_DATA_STATE_UNUSED) {
-		entry.portvec &= ~BIT(port);
-		if (!entry.portvec)
-			entry.state = MV88E6XXX_G1_ATU_DATA_STATE_UNUSED;
-	} else {
-		entry.portvec |= BIT(port);
-		entry.state = state;
-	}
-
-	return mv88e6xxx_g1_atu_loadpurge(chip, vlan.fid, &entry);
-}
-
 static int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 				  const unsigned char *addr, u16 vid)
 {
-- 
2.14.1
