From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 5/8] net: dsa: switch: handle host mdb add/remove
Date: Wed,  6 Sep 2017 01:35:07 +0200
Message-ID: <1504654510-31004-6-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58206 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753545AbdIEXgf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:36:35 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving notifications of the host mdb add/remove, add/remove an
mdb to the CPU port, so that traffic flows from a port to the CPU port
and hence to the host.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/switch.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 60 insertions(+), 12 deletions(-)

diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index e6c06aa349a6..326680039c52 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -108,22 +108,14 @@ static int dsa_switch_fdb_del(struct dsa_switch *ds,
 				     info->vid);
 }
 
-static int dsa_switch_mdb_add(struct dsa_switch *ds,
-			      struct dsa_notifier_mdb_info *info)
+static int dsa_switch_mdb_add_bitmap(struct dsa_switch *ds,
+				     struct dsa_notifier_mdb_info *info,
+				     const struct switchdev_obj_port_mdb *mdb,
+				     unsigned long *group)
 {
-	const struct switchdev_obj_port_mdb *mdb = info->mdb;
 	struct switchdev_trans *trans = info->trans;
-	DECLARE_BITMAP(group, ds->num_ports);
 	int port, err;
 
-	/* Build a mask of Multicast group members */
-	bitmap_zero(group, ds->num_ports);
-	if (ds->index == info->sw_index)
-		set_bit(info->port, group);
-	for (port = 0; port < ds->num_ports; port++)
-		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
-			set_bit(port, group);
-
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_mdb_prepare || !ds->ops->port_mdb_add)
 			return -EOPNOTSUPP;
@@ -141,6 +133,40 @@ static int dsa_switch_mdb_add(struct dsa_switch *ds,
 	return 0;
 }
 
+static int dsa_switch_mdb_add(struct dsa_switch *ds,
+			      struct dsa_notifier_mdb_info *info)
+{
+	const struct switchdev_obj_port_mdb *mdb = info->mdb;
+	DECLARE_BITMAP(group, ds->num_ports);
+	int port;
+
+	/* Build a mask of Multicast group members */
+	bitmap_zero(group, ds->num_ports);
+	if (ds->index == info->sw_index)
+		set_bit(info->port, group);
+	for (port = 0; port < ds->num_ports; port++)
+		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+			set_bit(port, group);
+
+	return dsa_switch_mdb_add_bitmap(ds, info, mdb, group);
+}
+
+static int dsa_switch_host_mdb_add(struct dsa_switch *ds,
+				   struct dsa_notifier_mdb_info *info)
+{
+	const struct switchdev_obj_port_mdb *mdb = info->mdb;
+	DECLARE_BITMAP(group, ds->num_ports);
+	int port;
+
+	/* Build a mask of Multicast group members */
+	bitmap_zero(group, ds->num_ports);
+	for (port = 0; port < ds->num_ports; port++)
+		if (dsa_is_cpu_port(ds, port))
+			set_bit(port, group);
+
+	return dsa_switch_mdb_add_bitmap(ds, info, mdb, group);
+}
+
 static int dsa_switch_mdb_del(struct dsa_switch *ds,
 			      struct dsa_notifier_mdb_info *info)
 {
@@ -155,6 +181,22 @@ static int dsa_switch_mdb_del(struct dsa_switch *ds,
 	return 0;
 }
 
+static int dsa_switch_host_mdb_del(struct dsa_switch *ds,
+				   struct dsa_notifier_mdb_info *info)
+{
+	const struct switchdev_obj_port_mdb *mdb = info->mdb;
+	int port;
+
+	if (!ds->ops->port_mdb_del)
+		return -EOPNOTSUPP;
+
+	for (port = 0; port < ds->num_ports; port++)
+		if (dsa_is_cpu_port(ds, port))
+			ds->ops->port_mdb_del(ds, port, mdb);
+
+	return 0;
+}
+
 static int dsa_switch_vlan_add(struct dsa_switch *ds,
 			       struct dsa_notifier_vlan_info *info)
 {
@@ -230,6 +272,12 @@ static int dsa_switch_event(struct notifier_block *nb,
 	case DSA_NOTIFIER_MDB_DEL:
 		err = dsa_switch_mdb_del(ds, info);
 		break;
+	case DSA_NOTIFIER_HOST_MDB_ADD:
+		err = dsa_switch_host_mdb_add(ds, info);
+		break;
+	case DSA_NOTIFIER_HOST_MDB_DEL:
+		err = dsa_switch_host_mdb_del(ds, info);
+		break;
 	case DSA_NOTIFIER_VLAN_ADD:
 		err = dsa_switch_vlan_add(ds, info);
 		break;
-- 
2.14.1
