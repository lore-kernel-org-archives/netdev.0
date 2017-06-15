From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: add cross-chip multicast support
Date: Thu, 15 Jun 2017 16:14:48 -0400
Message-ID: <20170615201448.22424-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similarly to how cross-chip VLAN works, define a bitmap of multicast
group members for a switch, now including its DSA ports, so that
multicast traffic can be sent to all switches of the fabric.

A switch may drop the frames if no user port is a member.

This brings support for multicast in a multi-chip environment.
As of now, all switches of the fabric must support the multicast
operations in order to program a single fabric port.

Reported-by: Jason Cobham <jcobham@questertangent.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/switch.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index f1029a8d0e20..97e2e9c8cf3f 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -122,19 +122,30 @@ static int dsa_switch_mdb_add(struct dsa_switch *ds,
 {
 	const struct switchdev_obj_port_mdb *mdb = info->mdb;
 	struct switchdev_trans *trans = info->trans;
+	DECLARE_BITMAP(group, ds->num_ports);
+	int port, err;
 
-	/* Do not care yet about other switch chips of the fabric */
-	if (ds->index != info->sw_index)
-		return 0;
+	/* Build a mask of Multicast group members */
+	bitmap_zero(group, ds->num_ports);
+	if (ds->index == info->sw_index)
+		set_bit(info->port, group);
+	for (port = 0; port < ds->num_ports; port++)
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+			set_bit(port, group);
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_mdb_prepare(ds, info->port, mdb, trans);
+		for_each_set_bit(port, group, ds->num_ports) {
+			err = ds->ops->port_mdb_prepare(ds, port, mdb, trans);
+			if (err)
+				return err;
+		}
 	}
 
-	ds->ops->port_mdb_add(ds, info->port, mdb, trans);
+	for_each_set_bit(port, group, ds->num_ports)
+		ds->ops->port_mdb_add(ds, port, mdb, trans);
 
 	return 0;
 }
@@ -144,14 +155,13 @@ static int dsa_switch_mdb_del(struct dsa_switch *ds,
 {
 	const struct switchdev_obj_port_mdb *mdb = info->mdb;
 
-	/* Do not care yet about other switch chips of the fabric */
-	if (ds->index != info->sw_index)
-		return 0;
-
 	if (!ds->ops->port_mdb_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_mdb_del(ds, info->port, mdb);
+	if (ds->index == info->sw_index)
+		return ds->ops->port_mdb_del(ds, info->port, mdb);
+
+	return 0;
 }
 
 static int dsa_switch_vlan_add(struct dsa_switch *ds,
-- 
2.13.1
