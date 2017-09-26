From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames in hardware
Date: Wed, 27 Sep 2017 00:26:03 +0200
Message-ID: <1506464764-12699-7-git-send-email-andrew@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57011 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965322AbdIZW1F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:27:05 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, the switch does not flood broadcast frames. Instead the
broadcast address is unknown in the ATU, so the frame gets forwarded
out the cpu port. The software bridge then floods it back to the
individual switch ports which are members of the bridge.

Add an ATU entry in the switch so that it floods broadcast frames out
ports, rather than have the software bridge do it. Also, send a copy
out the cpu port and any dsa ports. Rely on the port vectors to
prevent broadcast frames leaking between bridges, and separated ports.

Additionally, when a VLAN is added, a new FID is allocated.  This
represents a new table of ATU entries. A broadcast entry is added to
the new FID.

With offload_fwd_mark being set, the software bridge will not flood
the frames it receives back to the switch.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9fbe1f02b9ce..908bb867df3b 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1235,6 +1235,30 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 	return mv88e6xxx_g1_atu_loadpurge(chip, vlan.fid, &entry);
 }
 
+static int mv88e6xxx_port_add_broadcast(struct mv88e6xxx_chip *chip, int port,
+					u16 vid)
+{
+	const char broadcast[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+
+	return mv88e6xxx_port_db_load_purge(
+		chip, port, broadcast, vid,
+		MV88E6XXX_G1_ATU_DATA_STATE_MC_STATIC);
+}
+
+static int mv88e6xxx_broadcast_setup(struct mv88e6xxx_chip *chip, u16 vid)
+{
+	int port;
+	int err;
+
+	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {
+		err = mv88e6xxx_port_add_broadcast(chip, port, vid);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 				    u16 vid, u8 member)
 {
@@ -1247,7 +1271,11 @@ static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_chip *chip, int port,
 
 	vlan.member[port] = member;
 
-	return mv88e6xxx_vtu_loadpurge(chip, &vlan);
+	err = mv88e6xxx_vtu_loadpurge(chip, &vlan);
+	if (err)
+		return err;
+
+	return mv88e6xxx_broadcast_setup(chip, vid);
 }
 
 static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
@@ -2025,6 +2053,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (err)
 		goto unlock;
 
+	err = mv88e6xxx_broadcast_setup(chip, 0);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_pot_setup(chip);
 	if (err)
 		goto unlock;
-- 
2.14.1
