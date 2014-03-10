From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 3/3] bridge: Support 802.1ad vlan filtering
Date: Mon, 10 Mar 2014 17:11:06 +0900
Message-ID: <1394439067-10477-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:35228 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbaCJILW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 04:11:22 -0400
In-Reply-To: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables us to change protocols for vlan_filtering.
We come to be able to filter frames based on 802.1ad vlan tags through
a bridge.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/uapi/linux/if_bridge.h |  2 ++
 net/bridge/br_netlink.c        | 67 +++++++++++++++++++++++++++++-------------
 net/bridge/br_private.h        |  6 ++++
 net/bridge/br_vlan.c           | 57 +++++++++++++++++++++++++++++++++++
 4 files changed, 111 insertions(+), 21 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 39f621a..cb31364 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -110,12 +110,14 @@ struct __fdb_entry {
  *     [IFLA_BRIDGE_FLAGS]
  *     [IFLA_BRIDGE_MODE]
  *     [IFLA_BRIDGE_VLAN_INFO]
+ *     [IFLA_BRIDGE_VLAN_PROTOCOL]
  * }
  */
 enum {
 	IFLA_BRIDGE_FLAGS,
 	IFLA_BRIDGE_MODE,
 	IFLA_BRIDGE_VLAN_INFO,
+	IFLA_BRIDGE_VLAN_PROTOCOL,
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e74b6d53..eac82a4 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -119,7 +119,7 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 		nla_nest_end(skb, nest);
 	}
 
-	/* Check if  the VID information is requested */
+	/* Check if the vlan information is requested */
 	if (filter_mask & RTEXT_FILTER_BRVLAN) {
 		struct nlattr *af;
 		const struct net_port_vlans *pv;
@@ -127,17 +127,27 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 		u16 vid;
 		u16 pvid;
 
-		if (port)
+		if (port) {
 			pv = nbp_get_vlan_info(port);
-		else
-			pv = br_get_vlan_info(br);
+			if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID))
+				goto done;
 
-		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID))
-			goto done;
+			af = nla_nest_start(skb, IFLA_AF_SPEC);
+			if (!af)
+				goto nla_put_failure;
+		} else {
+			af = nla_nest_start(skb, IFLA_AF_SPEC);
+			if (!af)
+				goto nla_put_failure;
 
-		af = nla_nest_start(skb, IFLA_AF_SPEC);
-		if (!af)
-			goto nla_put_failure;
+			if (nla_put_be16(skb, IFLA_BRIDGE_VLAN_PROTOCOL,
+					 br_get_vlan_proto(br)))
+				goto nla_put_failure;
+
+			pv = br_get_vlan_info(br);
+			if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID))
+				goto afspec_nest_end;
+		}
 
 		pvid = br_get_pvid(pv);
 		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
@@ -153,7 +163,7 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 				    sizeof(vinfo), &vinfo))
 				goto nla_put_failure;
 		}
-
+afspec_nest_end:
 		nla_nest_end(skb, af);
 	}
 
@@ -223,6 +233,7 @@ static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
 	[IFLA_BRIDGE_MODE]	= { .type = NLA_U16 },
 	[IFLA_BRIDGE_VLAN_INFO]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct bridge_vlan_info), },
+	[IFLA_BRIDGE_VLAN_PROTOCOL] = { .type = NLA_U16 },
 };
 
 static int br_afspec(struct net_bridge *br,
@@ -250,7 +261,7 @@ static int br_afspec(struct net_bridge *br,
 			if (p) {
 				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
 				if (err)
-					break;
+					return err;
 
 				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
 					err = br_vlan_add(p->br, vinfo->vid,
@@ -259,7 +270,7 @@ static int br_afspec(struct net_bridge *br,
 				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
 
 			if (err)
-				break;
+				return err;
 
 			break;
 
@@ -274,6 +285,16 @@ static int br_afspec(struct net_bridge *br,
 		}
 	}
 
+	if (tb[IFLA_BRIDGE_VLAN_PROTOCOL]) {
+		__be16 proto = nla_get_be16(tb[IFLA_BRIDGE_VLAN_PROTOCOL]);
+
+		if (cmd != RTM_SETLINK || p ||
+		    (proto != htons(ETH_P_8021Q) && proto != htons(ETH_P_8021AD)))
+			return -EINVAL;
+
+		err = br_set_vlan_proto(br, proto);
+	}
+
 	return err;
 }
 
@@ -447,20 +468,24 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
-	struct net_port_vlans *pv;
+	struct net_port_vlans *pv = NULL;
+	size_t tot = 0;
 
-	if (br_port_exists(dev))
+	if (br_port_exists(dev)) {
 		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
-	else if (dev->priv_flags & IFF_EBRIDGE)
+	} else if (dev->priv_flags & IFF_EBRIDGE) {
+		tot = nla_total_size(2); /* IFLA_BRIDGE_VLAN_PROTOCOL */
 		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
-	else
-		return 0;
+	}
 
-	if (!pv)
-		return 0;
+	if (pv)
+		/* IFLA_BRIDGE_VLAN_INFO
+		 * Each VLAN is returned in bridge_vlan_info along with flags.
+		 */
+		tot += pv->num_vlans *
+		       nla_total_size(sizeof(struct bridge_vlan_info));
 
-	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
+	return tot;
 }
 
 static struct rtnl_af_ops br_af_ops = {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 500cf0e..d83843a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -591,6 +591,7 @@ void br_vlan_flush(struct net_bridge *br);
 bool br_vlan_find(struct net_bridge *br, u16 vid);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 void br_vlan_init(struct net_bridge *br);
+int br_set_vlan_proto(struct net_bridge *br, __be16 proto);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
@@ -730,6 +731,11 @@ static inline __be16 br_get_vlan_proto(const struct net_bridge *br)
 {
 	return 0;
 }
+
+static inline int br_set_vlan_proto(struct net_bridge *br, __be16 proto)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 /* br_netfilter.c */
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index f05ef6a..b465542 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -328,6 +328,63 @@ void br_vlan_init(struct net_bridge *br)
 	br->vlan_proto = htons(ETH_P_8021Q);
 }
 
+int br_set_vlan_proto(struct net_bridge *br, __be16 proto)
+{
+	int err = 0;
+	struct net_bridge_port *p;
+	struct net_port_vlans *pv;
+	__be16 oldproto = br_get_vlan_proto(br);
+	u16 vid, errvid;
+
+	ASSERT_RTNL();
+
+	if (oldproto == proto)
+		return 0;
+
+	/* Add VLANs for the new proto to the device filter. */
+	list_for_each_entry(p, &br->port_list, list) {
+		pv = rtnl_dereference(p->vlan_info);
+		if (!pv)
+			continue;
+
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+			err = vlan_vid_add(p->dev, proto, vid);
+			if (err)
+				goto out_filt;
+		}
+	}
+
+	br->vlan_proto = proto;
+
+	/* Delete VLANs for the old proto from the device filter. */
+	list_for_each_entry(p, &br->port_list, list) {
+		pv = rtnl_dereference(p->vlan_info);
+		if (!pv)
+			continue;
+
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
+			vlan_vid_del(p->dev, oldproto, vid);
+	}
+
+	return 0;
+
+out_filt:
+	errvid = vid;
+	for_each_set_bit(vid, pv->vlan_bitmap, errvid)
+		vlan_vid_del(p->dev, proto, vid);
+
+	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
+		pv = rtnl_dereference(p->vlan_info);
+		if (!pv)
+			continue;
+
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
+			vlan_vid_del(p->dev, proto, vid);
+	}
+
+	return err;
+}
+
 /* Must be protected by RTNL.
  * Must be called with vid in range from 1 to 4094 inclusive.
  */
-- 
1.8.1.2
