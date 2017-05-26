From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/18] bridge: Export VLAN filtering state
Date: Fri, 26 May 2017 08:37:23 +0200
Message-ID: <20170526063740.8909-2-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33086 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965796AbdEZGhp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id b84so1689555wmh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:44 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

It's useful for drivers supporting bridge offload to be able to query
the bridge's VLAN filtering state.

Currently, upon enslavement to a bridge master, the offloading driver
will only learn about the bridge's VLAN filtering state after the bridge
device was already linked with its slave.

Being able to query the bridge's VLAN filtering state allows such
drivers to forbid enslavement in case resource couldn't be allocated for
a VLAN-aware bridge and also choose the correct initialization routine
for the enslaved port, which is dependent on the bridge type.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/if_bridge.h | 9 +++++++++
 net/bridge/br_if.c        | 2 +-
 net/bridge/br_mdb.c       | 4 ++--
 net/bridge/br_netlink.c   | 2 +-
 net/bridge/br_private.h   | 9 ---------
 net/bridge/br_vlan.c      | 8 ++++++++
 6 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 0c16866..d6cd103 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -80,4 +80,13 @@ static inline bool br_multicast_has_querier_adjacent(struct net_device *dev,
 }
 #endif
 
+#if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_VLAN_FILTERING)
+bool br_vlan_enabled(const struct net_device *dev);
+#else
+static inline bool br_vlan_enabled(const struct net_device *dev)
+{
+	return false;
+}
+#endif
+
 #endif
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7f8d05c..f3aef22 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -138,7 +138,7 @@ void br_manage_promisc(struct net_bridge *br)
 	/* If vlan filtering is disabled or bridge interface is placed
 	 * into promiscuous mode, place all ports in promiscuous mode.
 	 */
-	if ((br->dev->flags & IFF_PROMISC) || !br_vlan_enabled(br))
+	if ((br->dev->flags & IFF_PROMISC) || !br_vlan_enabled(br->dev))
 		set_all = true;
 
 	list_for_each_entry(p, &br->port_list, list) {
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index b084548..09dcdb9 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -599,7 +599,7 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	vg = nbp_vlan_group(p);
-	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
+	if (br_vlan_enabled(br->dev) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
 			err = __br_mdb_add(net, br, entry);
@@ -694,7 +694,7 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	vg = nbp_vlan_group(p);
-	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
+	if (br_vlan_enabled(br->dev) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
 			err = __br_mdb_del(br, entry);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 574f788..1e63ec4 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1251,7 +1251,7 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u32 ageing_time = jiffies_to_clock_t(br->ageing_time);
 	u32 stp_enabled = br->stp_enabled;
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
-	u8 vlan_enabled = br_vlan_enabled(br);
+	u8 vlan_enabled = br_vlan_enabled(br->dev);
 	u64 clockval;
 
 	clockval = br_timer_value(&br->hello_timer);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0d17728..2062692 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -854,10 +854,6 @@ static inline u16 br_get_pvid(const struct net_bridge_vlan_group *vg)
 	return vg->pvid;
 }
 
-static inline int br_vlan_enabled(struct net_bridge *br)
-{
-	return br->vlan_enabled;
-}
 #else
 static inline bool br_allowed_ingress(const struct net_bridge *br,
 				      struct net_bridge_vlan_group *vg,
@@ -945,11 +941,6 @@ static inline u16 br_get_pvid(const struct net_bridge_vlan_group *vg)
 	return 0;
 }
 
-static inline int br_vlan_enabled(struct net_bridge *br)
-{
-	return 0;
-}
-
 static inline int __br_vlan_filter_toggle(struct net_bridge *br,
 					  unsigned long val)
 {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b838213..26a1a56 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -706,6 +706,14 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 	return __br_vlan_filter_toggle(br, val);
 }
 
+bool br_vlan_enabled(const struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	return !!br->vlan_enabled;
+}
+EXPORT_SYMBOL_GPL(br_vlan_enabled);
+
 int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 {
 	int err = 0;
-- 
2.9.3
