From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/9] net: dsa: mv88e6xxx: extract single VLAN retrieval
Date: Fri, 26 Feb 2016 13:16:01 -0500
Message-ID: <1456510568-13679-3-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Rename _mv88e6xxx_vlan_init in _mv88e6xxx_vtu_new, eventually called
from a new _mv88e6xxx_vtu_get function, which abstracts the VTU GetNext
VID-1 trick to retrieve a single entry.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 55 ++++++++++++++++++++++++++++-----------------
 1 file changed, 35 insertions(+), 20 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index d98dc63..e9e9922 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1458,8 +1458,8 @@ loadpurge:
 	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
-				struct mv88e6xxx_vtu_stu_entry *entry)
+static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
+			      struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan = {
@@ -1509,6 +1509,35 @@ static int _mv88e6xxx_vlan_init(struct dsa_switch *ds, u16 vid,
 	return 0;
 }
 
+static int _mv88e6xxx_vtu_get(struct dsa_switch *ds, u16 vid,
+			      struct mv88e6xxx_vtu_stu_entry *entry, bool creat)
+{
+	int err;
+
+	if (!vid)
+		return -EINVAL;
+
+	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
+	if (err)
+		return err;
+
+	err = _mv88e6xxx_vtu_getnext(ds, entry);
+	if (err)
+		return err;
+
+	if (entry->vid != vid || !entry->valid) {
+		if (!creat)
+			return -EOPNOTSUPP;
+		/* -ENOENT would've been more appropriate, but switchdev expects
+		 * -EOPNOTSUPP to inform bridge about an eventual software VLAN.
+		 */
+
+		err = _mv88e6xxx_vtu_new(ds, vid, entry);
+	}
+
+	return err;
+}
+
 static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 					u16 vid_begin, u16 vid_end)
 {
@@ -1593,20 +1622,10 @@ static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int err;
 
-	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_vtu_getnext(ds, &vlan);
+	err = _mv88e6xxx_vtu_get(ds, vid, &vlan, true);
 	if (err)
 		return err;
 
-	if (vlan.vid != vid || !vlan.valid) {
-		err = _mv88e6xxx_vlan_init(ds, vid, &vlan);
-		if (err)
-			return err;
-	}
-
 	vlan.data[port] = untagged ?
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
@@ -1647,16 +1666,12 @@ static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
 
-	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
-	if (err)
-		return err;
-
-	err = _mv88e6xxx_vtu_getnext(ds, &vlan);
+	err = _mv88e6xxx_vtu_get(ds, vid, &vlan, false);
 	if (err)
 		return err;
 
-	if (vlan.vid != vid || !vlan.valid ||
-	    vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
+	/* Tell switchdev if this VLAN is handled in software */
+	if (vlan.data[port] == GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 		return -EOPNOTSUPP;
 
 	vlan.data[port] = GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
-- 
2.7.1
