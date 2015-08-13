From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/7] net: dsa: mv88e6xxx: add VLAN support to FDB dump
Date: Thu, 13 Aug 2015 12:52:20 -0400
Message-ID: <1439484743-5126-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Chris Healy" <cphealy@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an helper function to read the next valid VLAN entry for a given
port. It is used in the VID to FID conversion function to retrieve the
forwarding database assigned to a given VLAN port.

Finally update the FDB getnext operation to iterate on the next valid
port VLAN when the end of the current database is reached.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ecdd9da..6c86bad 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1307,6 +1307,29 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds, u16 vid,
 	return 0;
 }
 
+static int _mv88e6xxx_port_vtu_getnext(struct dsa_switch *ds, int port, u16 vid,
+				       struct mv88e6xxx_vtu_stu_entry *entry)
+{
+	int err;
+
+	do {
+		if (vid == 4095)
+			return -ENOENT;
+
+		err = _mv88e6xxx_vtu_getnext(ds, vid, entry);
+		if (err)
+			return err;
+
+		if (!entry->valid)
+			return -ENOENT;
+
+		vid = entry->vid;
+	} while (entry->data[port] != GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED &&
+		 entry->data[port] != GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED);
+
+	return 0;
+}
+
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged)
 {
@@ -1421,10 +1444,19 @@ static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
 static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct mv88e6xxx_vtu_stu_entry vlan;
+	int err;
 
 	if (vid == 0)
 		return ps->fid[port];
 
+	err = _mv88e6xxx_port_vtu_getnext(ds, port, vid - 1, &vlan);
+	if (err)
+		return err;
+
+	if (vlan.vid == vid)
+		return vlan.fid;
+
 	return -ENOENT;
 }
 
@@ -1548,8 +1580,14 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 
 	do {
 		if (is_broadcast_ether_addr(addr)) {
-			ret = -ENOENT;
-			goto unlock;
+			struct mv88e6xxx_vtu_stu_entry vtu;
+
+			ret = _mv88e6xxx_port_vtu_getnext(ds, port, *vid, &vtu);
+			if (ret < 0)
+				goto unlock;
+
+			*vid = vtu.vid;
+			fid = vtu.fid;
 		}
 
 		ret = _mv88e6xxx_atu_getnext(ds, fid, addr, &next);
-- 
2.5.0
