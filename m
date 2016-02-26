From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/9] net: dsa: mv88e6xxx: extract single FDB dump
Date: Fri, 26 Feb 2016 13:16:02 -0500
Message-ID: <1456510568-13679-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move out the code which dumps a single FDB to its own function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 79 ++++++++++++++++++++++++++-------------------
 1 file changed, 46 insertions(+), 33 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e9e9922..6329516 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1895,6 +1895,47 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 	return 0;
 }
 
+static int _mv88e6xxx_port_fdb_dump_one(struct dsa_switch *ds, u16 fid, u16 vid,
+					int port,
+					struct switchdev_obj_port_fdb *fdb,
+					int (*cb)(struct switchdev_obj *obj))
+{
+	struct mv88e6xxx_atu_entry addr = {
+		.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
+	};
+	int err;
+
+	err = _mv88e6xxx_atu_mac_write(ds, addr.mac);
+	if (err)
+		return err;
+
+	do {
+		err = _mv88e6xxx_atu_getnext(ds, fid, &addr);
+		if (err)
+			break;
+
+		if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
+			break;
+
+		if (!addr.trunk && addr.portv_trunkid & BIT(port)) {
+			bool is_static = addr.state ==
+				(is_multicast_ether_addr(addr.mac) ?
+				 GLOBAL_ATU_DATA_STATE_MC_STATIC :
+				 GLOBAL_ATU_DATA_STATE_UC_STATIC);
+
+			fdb->vid = vid;
+			ether_addr_copy(fdb->addr, addr.mac);
+			fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
+
+			err = cb(&fdb->obj);
+			if (err)
+				break;
+		}
+	} while (!is_broadcast_ether_addr(addr.mac));
+
+	return err;
+}
+
 int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 			    struct switchdev_obj_port_fdb *fdb,
 			    int (*cb)(struct switchdev_obj *obj))
@@ -1907,51 +1948,23 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
+	/* Dump VLANs' Filtering Information Databases */
 	err = _mv88e6xxx_vtu_vid_write(ds, vlan.vid);
 	if (err)
 		goto unlock;
 
 	do {
-		struct mv88e6xxx_atu_entry addr = {
-			.mac = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
-		};
-
 		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
 		if (err)
-			goto unlock;
+			break;
 
 		if (!vlan.valid)
 			break;
 
-		err = _mv88e6xxx_atu_mac_write(ds, addr.mac);
+		err = _mv88e6xxx_port_fdb_dump_one(ds, vlan.fid, vlan.vid, port,
+						   fdb, cb);
 		if (err)
-			goto unlock;
-
-		do {
-			err = _mv88e6xxx_atu_getnext(ds, vlan.fid, &addr);
-			if (err)
-				goto unlock;
-
-			if (addr.state == GLOBAL_ATU_DATA_STATE_UNUSED)
-				break;
-
-			if (!addr.trunk && addr.portv_trunkid & BIT(port)) {
-				bool is_static = addr.state ==
-					(is_multicast_ether_addr(addr.mac) ?
-					 GLOBAL_ATU_DATA_STATE_MC_STATIC :
-					 GLOBAL_ATU_DATA_STATE_UC_STATIC);
-
-				fdb->vid = vlan.vid;
-				ether_addr_copy(fdb->addr, addr.mac);
-				fdb->ndm_state = is_static ? NUD_NOARP :
-					NUD_REACHABLE;
-
-				err = cb(&fdb->obj);
-				if (err)
-					goto unlock;
-			}
-		} while (!is_broadcast_ether_addr(addr.mac));
-
+			break;
 	} while (vlan.vid < GLOBAL_VTU_VID_MASK);
 
 unlock:
-- 
2.7.1
