From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 09/20] net: dsa: mv88e6xxx: check HW vlan with dsa_port
Date: Wed, 27 Apr 2016 18:30:06 -0400
Message-ID: <1461796217-18893-10-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the mv88e6xxx_port_check_hw_vlan function for a
mv88e6xxx_port_check_vtu which takes a dsa_port structure as parameter.
This will help us get rid of the bridge_dev pointer.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7e03f4c..00a0b92 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1729,12 +1729,13 @@ static int _mv88e6xxx_vtu_get(struct dsa_switch *ds, u16 vid,
 	return err;
 }
 
-static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
-					u16 vid_begin, u16 vid_end)
+static int mv88e6xxx_port_check_vtu(struct dsa_switch *ds, struct dsa_port *dp,
+				    u16 vid_begin, u16 vid_end)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_vtu_stu_entry vlan;
-	int i, err;
+	struct dsa_port *intp;
+	int err;
 
 	if (!vid_begin)
 		return -EOPNOTSUPP;
@@ -1756,22 +1757,21 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 		if (vlan.vid > vid_end)
 			break;
 
-		for (i = 0; i < ps->info->num_ports; ++i) {
-			if (dsa_is_dsa_port(ds, i) || dsa_is_cpu_port(ds, i))
+		dsa_switch_for_each_port(ds, intp, ps->info->num_ports) {
+			if (dsa_is_dsa_port(ds, intp->port) ||
+			    dsa_is_cpu_port(ds, intp->port))
 				continue;
 
-			if (vlan.data[i] ==
+			if (vlan.data[intp->port] ==
 			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
-			if (ps->ports[i].bridge_dev ==
-			    ps->ports[port].bridge_dev)
+			if (intp->br == dp->br)
 				break; /* same bridge, check next VLAN */
 
-			netdev_warn(ds->ports[port],
+			netdev_warn(ds->ports[dp->port],
 				    "hardware VLAN %d already used by %s\n",
-				    vlan.vid,
-				    netdev_name(ps->ports[i].bridge_dev));
+				    vlan.vid, netdev_name(intp->br));
 			err = -EOPNOTSUPP;
 			goto unlock;
 		}
@@ -1836,8 +1836,7 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, struct dsa_port *dp,
 	/* If the requested port doesn't belong to the same bridge as the VLAN
 	 * members, do not support it (yet) and fallback to software VLAN.
 	 */
-	err = mv88e6xxx_port_check_hw_vlan(ds, dp->port, vlan->vid_begin,
-					   vlan->vid_end);
+	err = mv88e6xxx_port_check_vtu(ds, dp, vlan->vid_begin, vlan->vid_end);
 	if (err)
 		return err;
 
-- 
2.8.0
