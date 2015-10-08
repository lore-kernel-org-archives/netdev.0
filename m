From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v3] bridge: allow adding of fdb entries pointing to the bridge device
Date: Thu,  8 Oct 2015 10:38:52 -0700
Message-ID: <1444325932-1577-1-git-send-email-roopa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, nikolay@cumulusnetworks.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35083 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673AbbJHRi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:38:57 -0400
Received: by pabve7 with SMTP id ve7so2045221pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:38:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch enables adding of fdb entries pointing to the bridge device.
This can be used to propagate mac address of vlan interfaces
configured on top of the vlan filtering bridge.

Before:
$bridge fdb add 44:38:39:00:27:9f dev bridge
RTNETLINK answers: Invalid argument

After:
$bridge fdb add 44:38:39:00:27:9f dev bridge

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v1 - v2 : fix kbuild warnings
v2 - v3 : address review comments from Nikolay (use of br_vlan_should_use)

 net/bridge/br_fdb.c  | 122 ++++++++++++++++++++++++++++++++++++++-------------
 net/bridge/br_vlan.c |   1 +
 2 files changed, 93 insertions(+), 30 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 7f7d551..f43ce05 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -608,13 +608,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 	}
 }
 
-static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
+static int fdb_to_nud(const struct net_bridge *br,
+		      const struct net_bridge_fdb_entry *fdb)
 {
 	if (fdb->is_local)
 		return NUD_PERMANENT;
 	else if (fdb->is_static)
 		return NUD_NOARP;
-	else if (has_expired(fdb->dst->br, fdb))
+	else if (has_expired(br, fdb))
 		return NUD_STALE;
 	else
 		return NUD_REACHABLE;
@@ -640,7 +641,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ndm->ndm_flags	 = fdb->added_by_external_learn ? NTF_EXT_LEARNED : 0;
 	ndm->ndm_type	 = 0;
 	ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
-	ndm->ndm_state   = fdb_to_nud(fdb);
+	ndm->ndm_state   = fdb_to_nud(br, fdb);
 
 	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
 		goto nla_put_failure;
@@ -785,7 +786,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 		}
 	}
 
-	if (fdb_to_nud(fdb) != state) {
+	if (fdb_to_nud(br, fdb) != state) {
 		if (state & NUD_PERMANENT) {
 			fdb->is_local = 1;
 			if (!fdb->is_static) {
@@ -846,8 +847,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	       const unsigned char *addr, u16 vid, u16 nlh_flags)
 {
 	struct net_bridge_vlan_group *vg;
-	struct net_bridge_port *p;
+	struct net_bridge_port *p = NULL;
 	struct net_bridge_vlan *v;
+	struct net_bridge *br = NULL;
 	int err = 0;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
@@ -860,26 +862,36 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	p = br_port_get_rtnl(dev);
-	if (p == NULL) {
-		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
-			dev->name);
-		return -EINVAL;
+	if (dev->priv_flags & IFF_EBRIDGE) {
+		br = netdev_priv(dev);
+		vg = br_vlan_group(br);
+	} else {
+		p = br_port_get_rtnl(dev);
+		if (!p) {
+			pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
+				dev->name);
+			return -EINVAL;
+		}
+		vg = nbp_vlan_group(p);
 	}
 
-	vg = nbp_vlan_group(p);
 	if (vid) {
 		v = br_vlan_find(vg, vid);
-		if (!v) {
-			pr_info("bridge: RTM_NEWNEIGH with unconfigured "
-				"vlan %d on port %s\n", vid, dev->name);
+		if (!v || !br_vlan_should_use(v)) {
+			pr_info("bridge: RTM_NEWNEIGH with unconfigured vlan %d on %s\n", vid, dev->name);
 			return -EINVAL;
 		}
 
 		/* VID was specified, so use it. */
-		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
+		if (dev->priv_flags & IFF_EBRIDGE)
+			err = br_fdb_insert(br, NULL, addr, vid);
+		else
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 	} else {
-		err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
+		if (dev->priv_flags & IFF_EBRIDGE)
+			err = br_fdb_insert(br, NULL, addr, 0);
+		else
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
 		if (err || !vg || !vg->num_vlans)
 			goto out;
 
@@ -888,7 +900,13 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		 * vlan on this port.
 		 */
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
-			err = __br_fdb_add(ndm, p, addr, nlh_flags, v->vid);
+			if (!br_vlan_should_use(v))
+				continue;
+			if (dev->priv_flags & IFF_EBRIDGE)
+				err = br_fdb_insert(br, NULL, addr, v->vid);
+			else
+				err = __br_fdb_add(ndm, p, addr, nlh_flags,
+						   v->vid);
 			if (err)
 				goto out;
 		}
@@ -898,6 +916,32 @@ out:
 	return err;
 }
 
+static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
+			      u16 vid)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
+	struct net_bridge_fdb_entry *fdb;
+
+	fdb = fdb_find(head, addr, vid);
+	if (!fdb)
+		return -ENOENT;
+
+	fdb_delete(br, fdb);
+	return 0;
+}
+
+static int __br_fdb_delete_by_addr(struct net_bridge *br,
+				   const unsigned char *addr, u16 vid)
+{
+	int err;
+
+	spin_lock_bh(&br->hash_lock);
+	err = fdb_delete_by_addr(br, addr, vid);
+	spin_unlock_bh(&br->hash_lock);
+
+	return err;
+}
+
 static int fdb_delete_by_addr_and_port(struct net_bridge_port *p,
 				       const u8 *addr, u16 vlan)
 {
@@ -931,35 +975,53 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  const unsigned char *addr, u16 vid)
 {
 	struct net_bridge_vlan_group *vg;
-	struct net_bridge_port *p;
+	struct net_bridge_port *p = NULL;
 	struct net_bridge_vlan *v;
+	struct net_bridge *br = NULL;
 	int err;
 
-	p = br_port_get_rtnl(dev);
-	if (p == NULL) {
-		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
-			dev->name);
-		return -EINVAL;
+	if (dev->priv_flags & IFF_EBRIDGE) {
+		br = netdev_priv(dev);
+		vg = br_vlan_group(br);
+	} else {
+		p = br_port_get_rtnl(dev);
+		if (!p) {
+			pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
+				dev->name);
+			return -EINVAL;
+		}
+		vg = nbp_vlan_group(p);
 	}
 
-	vg = nbp_vlan_group(p);
 	if (vid) {
 		v = br_vlan_find(vg, vid);
 		if (!v) {
-			pr_info("bridge: RTM_DELNEIGH with unconfigured "
-				"vlan %d on port %s\n", vid, dev->name);
+			pr_info("bridge: RTM_DELNEIGH with unconfigured vlan %d on %s\n", vid, dev->name);
 			return -EINVAL;
 		}
 
-		err = __br_fdb_delete(p, addr, vid);
+		if (dev->priv_flags & IFF_EBRIDGE)
+			err = __br_fdb_delete_by_addr(br, addr, vid);
+		else
+			err = __br_fdb_delete(p, addr, vid);
 	} else {
 		err = -ENOENT;
-		err &= __br_fdb_delete(p, addr, 0);
+		if (dev->priv_flags & IFF_EBRIDGE)
+			err = __br_fdb_delete_by_addr(br, addr, 0);
+		else
+			err &= __br_fdb_delete(p, addr, 0);
+
 		if (!vg || !vg->num_vlans)
 			goto out;
 
-		list_for_each_entry(v, &vg->vlan_list, vlist)
-			err &= __br_fdb_delete(p, addr, v->vid);
+		list_for_each_entry(v, &vg->vlan_list, vlist) {
+			if (!br_vlan_should_use(v))
+				continue;
+			if (dev->priv_flags & IFF_EBRIDGE)
+				err = __br_fdb_delete_by_addr(br, addr, v->vid);
+			else
+				err &= __br_fdb_delete(p, addr, v->vid);
+		}
 	}
 out:
 	return err;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index eae07ee..7a95e31 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -564,6 +564,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 		return -ENOENT;
 
 	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
+	br_fdb_delete_by_port(br, NULL, vid, 0);
 
 	return __vlan_del(v);
 }
-- 
1.9.1
