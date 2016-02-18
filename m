From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bridge: switchdev: Offload VLAN flags to hardware bridge
Date: Thu, 18 Feb 2016 14:01:46 +0100
Message-ID: <1455800506-13190-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34856 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945978AbcBRNBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 08:01:53 -0500
Received: by mail-wm0-f41.google.com with SMTP id c200so26002940wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 05:01:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When VLANs are created / destroyed on a VLAN filtering bridge (MASTER
flag set), the configuration is passed down to the hardware. However,
when only the flags (e.g. PVID) are toggled, the configuration is done
in the software bridge alone.

While it is possible to pass these flags to hardware when invoked with
the SELF flag set, this creates inconsistency with regards to the way
the VLANs are initially configured.

Pass the flags down to the hardware even when the VLAN already exists
and only the flags are toggled.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_vlan.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 85e43af..9309bb4 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -955,6 +955,13 @@ err_rhtbl:
  */
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 {
+	struct switchdev_obj_port_vlan v = {
+		.obj.orig_dev = port->dev,
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
+		.flags = flags,
+		.vid_begin = vid,
+		.vid_end = vid,
+	};
 	struct net_bridge_vlan *vlan;
 	int ret;
 
@@ -962,6 +969,10 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 
 	vlan = br_vlan_find(nbp_vlan_group(port), vid);
 	if (vlan) {
+		/* Pass the flags to the hardware bridge */
+		ret = switchdev_port_obj_add(port->dev, &v.obj);
+		if (ret && ret != -EOPNOTSUPP)
+			return ret;
 		__vlan_add_flags(vlan, flags);
 		return 0;
 	}
-- 
2.5.0
