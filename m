From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] bridge: add vlan filtering change notification
Date: Wed,  6 Jan 2016 11:11:51 +0100
Message-ID: <1452075116-5726-4-git-send-email-jiri@resnulli.us>
References: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33296 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbcAFKMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:12:03 -0500
Received: by mail-wm0-f52.google.com with SMTP id f206so54081415wmf.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:12:02 -0800 (PST)
In-Reply-To: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Notifying hardware about bridge vlan-aware changes.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_vlan.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 66c4549..190fb33 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -626,9 +626,21 @@ void br_recalculate_fwd_mask(struct net_bridge *br)
 
 int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 {
+	struct switchdev_attr attr = {
+		.orig_dev = br->dev,
+		.id = SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
+		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
+		.u.vlan_filtering = val,
+	};
+	int err;
+
 	if (br->vlan_enabled == val)
 		return 0;
 
+	err = switchdev_port_attr_set(br->dev, &attr);
+	if (err && err != -EOPNOTSUPP)
+		return err;
+
 	br->vlan_enabled = val;
 	br_manage_promisc(br);
 	recalculate_group_addr(br);
@@ -639,13 +651,15 @@ int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 {
+	int err;
+
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	__br_vlan_filter_toggle(br, val);
+	err = __br_vlan_filter_toggle(br, val);
 	rtnl_unlock();
 
-	return 0;
+	return err;
 }
 
 int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
-- 
1.9.3
