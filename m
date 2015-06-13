From: sfeldma@gmail.com
Subject: [PATCH net-next v2] bridge: use either ndo VLAN ops or switchdev VLAN ops to install MASTER vlans
Date: Fri, 12 Jun 2015 17:39:50 -0700
Message-ID: <1434155990-45616-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, makita.toshiaki@lab.ntt.co.jp,
	roopa@cumulusnetworks.com, jhs@mojatatu.com,
	simon.horman@netronome.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34831 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbbFMAiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 20:38:24 -0400
Received: by pacyx8 with SMTP id yx8so30727328pac.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 17:38:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v2:

Move struct switchdev_obj automatics to inner scope where there used.

v1:

To maintain backward compatibility with the existing iproute2 "bridge vlan"
command, let bridge's setlink/dellink handler call into either the port
driver's 8021q ndo ops or the port driver's bridge_setlink/dellink ops.

This allows port driver to choose 8021q ops or the newer
bridge_setlink/dellink ops when implementing VLAN add/del filtering on the
device.  The iproute "bridge vlan" command does not need to be modified.

To summarize using the "bridge vlan" command examples, we have:

1) bridge vlan add|del vid VID dev DEV

Here iproute2 sets MASTER flag.  Bridge's bridge_setlink/dellink is called.
Vlan is set on bridge for port.  If port driver implements ndo 8021q ops,
call those to port driver can install vlan filter on device.  Otherwise, if
port driver implements bridge_setlink/dellink ops, call those to install
vlan filter to device.  This option only works if port is bridged.

2) bridge vlan add|del vid VID dev DEV master

Same as 1)

3) bridge vlan add|del vid VID dev DEV self

Bridge's bridge_setlink/dellink isn't called.  Port driver's
bridge_setlink/dellink is called, if implemented.  This option works if
port is bridged or not.  If port is not bridged, a VLAN can still be
added/deleted to device filter using this variant.

4) bridge vlan add|del vid VID dev DEV master self

This is a combination of 1) and 3), but will only work if port is bridged.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/bridge/br_vlan.c |   59 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 13013fe..17fc358 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -2,6 +2,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 
@@ -36,6 +37,36 @@ static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
 		clear_bit(vid, v->untagged_bitmap);
 }
 
+static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
+			  u16 vid, u16 flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int err;
+
+	/* If driver uses VLAN ndo ops, use 8021q to install vid
+	 * on device, otherwise try switchdev ops to install vid.
+	 */
+
+	if (ops->ndo_vlan_rx_add_vid) {
+		err = vlan_vid_add(dev, br->vlan_proto, vid);
+	} else {
+		struct switchdev_obj vlan_obj = {
+			.id = SWITCHDEV_OBJ_PORT_VLAN,
+			.u.vlan = {
+				.flags = flags,
+				.vid_start = vid,
+				.vid_end = vid,
+			},
+		};
+
+		err = switchdev_port_obj_add(dev, &vlan_obj);
+		if (err == -EOPNOTSUPP)
+			err = 0;
+	}
+
+	return err;
+}
+
 static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
 	struct net_bridge_port *p = NULL;
@@ -62,7 +93,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 		 * This ensures tagged traffic enters the bridge when
 		 * promiscuous mode is disabled by br_manage_promisc().
 		 */
-		err = vlan_vid_add(dev, br->vlan_proto, vid);
+		err = __vlan_vid_add(dev, br, vid, flags);
 		if (err)
 			return err;
 	}
@@ -86,6 +117,30 @@ out_filt:
 	return err;
 }
 
+static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
+			   u16 vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	/* If driver uses VLAN ndo ops, use 8021q to delete vid
+	 * on device, otherwise try switchdev ops to delete vid.
+	 */
+
+	if (ops->ndo_vlan_rx_kill_vid) {
+		vlan_vid_del(dev, br->vlan_proto, vid);
+	} else {
+		struct switchdev_obj vlan_obj = {
+			.id = SWITCHDEV_OBJ_PORT_VLAN,
+			.u.vlan = {
+				.vid_start = vid,
+				.vid_end = vid,
+			},
+		};
+
+		switchdev_port_obj_del(dev, &vlan_obj);
+	}
+}
+
 static int __vlan_del(struct net_port_vlans *v, u16 vid)
 {
 	if (!test_bit(vid, v->vlan_bitmap))
@@ -96,7 +151,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 
 	if (v->port_idx) {
 		struct net_bridge_port *p = v->parent.port;
-		vlan_vid_del(p->dev, p->br->vlan_proto, vid);
+		__vlan_vid_del(p->dev, p->br, vid);
 	}
 
 	clear_bit(vid, v->vlan_bitmap);
-- 
1.7.10.4
