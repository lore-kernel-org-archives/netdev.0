From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/5] net: dsa: check VLAN capability of every switch
Date: Wed,  7 Jun 2017 18:12:14 -0400
Message-ID: <20170607221217.2323-3-vivien.didelot@savoirfairelinux.com>
References: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58414 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdFGWOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 18:14:30 -0400
In-Reply-To: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the VLAN object is propagated to every switch chip of the
switch fabric, we can easily ensure that they all support the required
VLAN operations before modifying an entry on a single switch.

To achieve that, remove the condition skipping other target switches,
and add a bitmap of VLAN members, eventually containing the target port,
if we are programming the switch target.

This will allow us to easily add other VLAN members, such as the DSA or
CPU ports (to introduce cross-chip VLAN support) or the other port
members if we want to reduce hardware accesses later.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/switch.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index d8e5c311ee7c..f235ae1e9777 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -159,19 +159,27 @@ static int dsa_switch_vlan_add(struct dsa_switch *ds,
 {
 	const struct switchdev_obj_port_vlan *vlan = info->vlan;
 	struct switchdev_trans *trans = info->trans;
+	DECLARE_BITMAP(members, ds->num_ports);
+	int port, err;
 
-	/* Do not care yet about other switch chips of the fabric */
-	if (ds->index != info->sw_index)
-		return 0;
+	/* Build a mask of VLAN members */
+	bitmap_zero(members, ds->num_ports);
+	if (ds->index == info->sw_index)
+		set_bit(info->port, members);
 
 	if (switchdev_trans_ph_prepare(trans)) {
 		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
 			return -EOPNOTSUPP;
 
-		return ds->ops->port_vlan_prepare(ds, info->port, vlan, trans);
+		for_each_set_bit(port, members, ds->num_ports) {
+			err = ds->ops->port_vlan_prepare(ds, port, vlan, trans);
+			if (err)
+				return err;
+		}
 	}
 
-	ds->ops->port_vlan_add(ds, info->port, vlan, trans);
+	for_each_set_bit(port, members, ds->num_ports)
+		ds->ops->port_vlan_add(ds, port, vlan, trans);
 
 	return 0;
 }
@@ -181,14 +189,13 @@ static int dsa_switch_vlan_del(struct dsa_switch *ds,
 {
 	const struct switchdev_obj_port_vlan *vlan = info->vlan;
 
-	/* Do not care yet about other switch chips of the fabric */
-	if (ds->index != info->sw_index)
-		return 0;
-
 	if (!ds->ops->port_vlan_del)
 		return -EOPNOTSUPP;
 
-	return ds->ops->port_vlan_del(ds, info->port, vlan);
+	if (ds->index == info->sw_index)
+		return ds->ops->port_vlan_del(ds, info->port, vlan);
+
+	return 0;
 }
 
 static int dsa_switch_event(struct notifier_block *nb,
-- 
2.13.1
