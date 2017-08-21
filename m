From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 2/6] bridge: lwtunnel netlink interface
Date: Mon, 21 Aug 2017 19:15:19 +0200
Message-ID: <20170821171523.951260-3-equinox@diac24.net>
References: <20170821171523.951260-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:37088 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753446AbdHURPn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:15:43 -0400
In-Reply-To: <20170821171523.951260-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes each FDB entry's metadata dst accessible through the same
ENCAP uapi as lwtunnel uses.  The function signature is slightly
different due to metadata_dst <> lwtunnel_state.

Netlink encapsulation is done by callbacks in net_device_ops.  This is
because the metadata is always used in the context of a port / device on
the bridge; it's not meaningful in a "vacuum".  It makes no sense to
allow inputting metadata of a type that doesn't match the device (where
in lwtunnel it does, by just switching the encapsulation.)  Also, this
way a device can do extended checks of the validity of incoming data
from the user, ensuring it is actually usable.

Note this is not related to ndo_fill_metadata_dst(), that one is used
only by OVS and operates on a packet that is currently being switched,
i.e. data plane.  The API in this patch is control plane.

[TODO: maybe just pass the entire netlink attr block down?]
Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/linux/netdevice.h      | 18 +++++++++
 include/net/ip_tunnels.h       |  5 +++
 include/uapi/linux/neighbour.h |  2 +
 net/bridge/br.c                |  2 +-
 net/bridge/br_fdb.c            | 79 +++++++++++++++++++++++++++++++-------
 net/bridge/br_private.h        |  1 +
 net/ipv4/ip_tunnel_core.c      | 87 +++++++++++++++++++++++++++++++++---------
 7 files changed, 162 insertions(+), 32 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0f1c4cb2441e..2de46f8b3f4f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -828,6 +828,8 @@ struct xfrmdev_ops {
 };
 #endif
 
+struct metadata_dst;
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1128,6 +1130,15 @@ struct xfrmdev_ops {
  * void (*ndo_xdp_flush)(struct net_device *dev);
  *	This function is used to inform the driver to flush a paticular
  *	xpd tx queue. Must be called on same CPU as xdp_xmit.
+ * int (*ndo_metadst_fill)(struct sk_buff *skb, struct metadata_dst *dst);
+ *	Used to encapsulate a metadata_dst that is associated with this
+ *	netdevice into the appropriate netlink attributes on skb.
+ *	Needs to return a lwtunnel_encap_types value if valid data was filled.
+ * int (*ndo_metadst_build)(struct net_device *dev, struct nlattr *meta,
+ *			    struct metadata_dst **dst,
+ *			    struct netlink_ext_ack *extack);
+ *	Reverse of the previous function, build a metadata_dst from netlink
+ *	attributes.  Should perform appropriate validation.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1314,6 +1325,13 @@ struct net_device_ops {
 	int			(*ndo_xdp_xmit)(struct net_device *dev,
 						struct xdp_buff *xdp);
 	void			(*ndo_xdp_flush)(struct net_device *dev);
+
+	int			(*ndo_metadst_fill)(struct sk_buff *skb,
+						    struct metadata_dst *dst);
+	int			(*ndo_metadst_build)(struct net_device *dev,
+						     struct nlattr *meta,
+						     struct metadata_dst **dst,
+						     struct netlink_ext_ack *extack);
 };
 
 /**
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 520809912f03..e6181fb83324 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -451,6 +451,11 @@ void __init ip_tunnel_core_init(void);
 void ip_tunnel_need_metadata(void);
 void ip_tunnel_unneed_metadata(void);
 
+int ip_tunnel_fill_metadst(struct sk_buff *skb, struct metadata_dst *md_dst);
+int ip_tunnel_build_metadst(struct net_device *dev, struct nlattr *meta,
+			    struct metadata_dst **dst,
+			    struct netlink_ext_ack *extack);
+
 #else /* CONFIG_INET */
 
 static inline struct ip_tunnel_info *lwt_tun_info(struct lwtunnel_state *lwtstate)
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 3199d28980b3..cd98ce4b8dd9 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -27,6 +27,8 @@ enum {
 	NDA_MASTER,
 	NDA_LINK_NETNSID,
 	NDA_SRC_VNI,
+	NDA_ENCAP_TYPE,
+	NDA_ENCAP,
 	__NDA_MAX
 };
 
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 1407d1ba7577..822dfcef2649 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -140,7 +140,7 @@ static int br_switchdev_event(struct notifier_block *unused,
 	switch (event) {
 	case SWITCHDEV_FDB_ADD_TO_BRIDGE:
 		fdb_info = ptr;
-		err = br_fdb_external_learn_add(br, p, fdb_info->addr,
+		err = br_fdb_external_learn_add(br, p, NULL, fdb_info->addr,
 						fdb_info->vid);
 		if (err) {
 			err = notifier_from_errno(err);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6ac3b916c39b..452d88bab1a0 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -671,6 +671,27 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 
 	if (fdb->vlan_id && nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
 		goto nla_put_failure;
+	if (fdb->md_dst && fdb->dst) {
+		struct net_device *dev = fdb->dst->dev;
+
+		if (dev->netdev_ops &&
+		    dev->netdev_ops->ndo_metadst_fill) {
+			struct nlattr *nest;
+			int ret;
+
+			nest = nla_nest_start(skb, NDA_ENCAP);
+			if (!nest)
+				goto nla_put_failure;
+			ret = dev->netdev_ops->ndo_metadst_fill(skb,
+								fdb->md_dst);
+			if (ret < 0)
+				goto nla_put_failure;
+			nla_nest_end(skb, nest);
+
+			if (ret && nla_put_u16(skb, NDA_ENCAP_TYPE, ret))
+				goto nla_put_failure;
+		}
+	}
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -776,10 +797,12 @@ int br_fdb_dump(struct sk_buff *skb,
 
 /* Update (create or replace) forwarding database entry */
 static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
-			 const __u8 *addr, __u16 state, __u16 flags, __u16 vid)
+			 struct metadata_dst *md_dst, const __u8 *addr,
+			 __u16 state, __u16 flags, __u16 vid)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
+	struct metadata_dst *old_dst;
 	bool modified = false;
 
 	/* If the port cannot learn allow only local and static entries */
@@ -799,7 +822,7 @@ static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		fdb = fdb_create(head, source, NULL, addr, vid, 0, 0);
+		fdb = fdb_create(head, source, md_dst, addr, vid, 0, 0);
 		if (!fdb)
 			return -ENOMEM;
 
@@ -810,6 +833,11 @@ static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
 
 		if (fdb->dst != source) {
 			fdb->dst = source;
+
+			old_dst = xchg(&fdb->md_dst,
+				       metadata_dst_clone(md_dst));
+			dst_release(&old_dst->dst);
+
 			modified = true;
 		}
 	}
@@ -849,8 +877,8 @@ static int fdb_add_entry(struct net_bridge *br, struct net_bridge_port *source,
 }
 
 static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge *br,
-			struct net_bridge_port *p, const unsigned char *addr,
-			u16 nlh_flags, u16 vid)
+			struct net_bridge_port *p, struct metadata_dst *md_dst,
+			const unsigned char *addr, u16 nlh_flags, u16 vid)
 {
 	int err = 0;
 
@@ -862,14 +890,14 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge *br,
 		}
 		local_bh_disable();
 		rcu_read_lock();
-		br_fdb_update(br, p, NULL, addr, vid, true);
+		br_fdb_update(br, p, md_dst, addr, vid, true);
 		rcu_read_unlock();
 		local_bh_enable();
 	} else if (ndm->ndm_flags & NTF_EXT_LEARNED) {
-		err = br_fdb_external_learn_add(br, p, addr, vid);
+		err = br_fdb_external_learn_add(br, p, md_dst, addr, vid);
 	} else {
 		spin_lock_bh(&br->hash_lock);
-		err = fdb_add_entry(br, p, addr, ndm->ndm_state,
+		err = fdb_add_entry(br, p, md_dst, addr, ndm->ndm_state,
 				    nlh_flags, vid);
 		spin_unlock_bh(&br->hash_lock);
 	}
@@ -886,6 +914,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct net_bridge_port *p = NULL;
 	struct net_bridge_vlan *v;
 	struct net_bridge *br = NULL;
+	struct metadata_dst *md_dst = NULL;
 	int err = 0;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
@@ -898,6 +927,22 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
+	if (tb[NDA_ENCAP_TYPE] && tb[NDA_ENCAP]) {
+		if (!dev->netdev_ops ||
+		    !dev->netdev_ops->ndo_metadst_build) {
+			pr_info("bridge: target device does not support ENCAP\n");
+			return -EINVAL;
+		}
+
+		err = dev->netdev_ops->ndo_metadst_build(dev, tb[NDA_ENCAP],
+							 &md_dst, NULL);
+		if (err)
+			return err;
+	} else if (tb[NDA_ENCAP_TYPE] || tb[NDA_ENCAP]) {
+		pr_info("bridge: RTM_NEWNEIGH with unpaired ENCAP_TYPE / ENCAP\n");
+		return -EINVAL;
+	}
+
 	if (dev->priv_flags & IFF_EBRIDGE) {
 		br = netdev_priv(dev);
 		vg = br_vlan_group(br);
@@ -906,7 +951,8 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		if (!p) {
 			pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
 				dev->name);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 		br = p->br;
 		vg = nbp_vlan_group(p);
@@ -916,13 +962,14 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		v = br_vlan_find(vg, vid);
 		if (!v || !br_vlan_should_use(v)) {
 			pr_info("bridge: RTM_NEWNEIGH with unconfigured vlan %d on %s\n", vid, dev->name);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 
 		/* VID was specified, so use it. */
-		err = __br_fdb_add(ndm, br, p, addr, nlh_flags, vid);
+		err = __br_fdb_add(ndm, br, p, md_dst, addr, nlh_flags, vid);
 	} else {
-		err = __br_fdb_add(ndm, br, p, addr, nlh_flags, 0);
+		err = __br_fdb_add(ndm, br, p, md_dst, addr, nlh_flags, 0);
 		if (err || !vg || !vg->num_vlans)
 			goto out;
 
@@ -933,13 +980,14 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			if (!br_vlan_should_use(v))
 				continue;
-			err = __br_fdb_add(ndm, br, p, addr, nlh_flags, v->vid);
+			err = __br_fdb_add(ndm, br, p, md_dst, addr, nlh_flags, v->vid);
 			if (err)
 				goto out;
 		}
 	}
 
 out:
+	dst_release(&md_dst->dst);
 	return err;
 }
 
@@ -1077,9 +1125,11 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
 }
 
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
+			      struct metadata_dst *md_dst,
 			      const unsigned char *addr, u16 vid)
 {
 	struct net_bridge_fdb_entry *fdb;
+	struct metadata_dst *old_dst;
 	struct hlist_head *head;
 	bool modified = false;
 	int err = 0;
@@ -1089,7 +1139,7 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 	head = &br->hash[br_mac_hash(addr, vid)];
 	fdb = br_fdb_find(br, addr, vid);
 	if (!fdb) {
-		fdb = fdb_create(head, p, NULL, addr, vid, 0, 0);
+		fdb = fdb_create(head, p, md_dst, addr, vid, 0, 0);
 		if (!fdb) {
 			err = -ENOMEM;
 			goto err_unlock;
@@ -1101,6 +1151,9 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 
 		if (fdb->dst != p) {
 			fdb->dst = p;
+			old_dst = xchg(&fdb->md_dst,
+				       metadata_dst_clone(md_dst));
+			dst_release(&old_dst->dst);
 			modified = true;
 		}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 66d33352681f..dd426ccf7475 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -538,6 +538,7 @@ int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
+			      struct metadata_dst *md_dst,
 			      const unsigned char *addr, u16 vid);
 int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 2f39479be92f..9f921d4e2544 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -228,13 +228,10 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 	[LWTUNNEL_IP_FLAGS]	= { .type = NLA_U16 },
 };
 
-static int ip_tun_build_state(struct nlattr *attr,
-			      unsigned int family, const void *cfg,
-			      struct lwtunnel_state **ts,
-			      struct netlink_ext_ack *extack)
+static int ip_tun_build_common(struct ip_tunnel_info *tun_info,
+			       struct nlattr *attr,
+			       struct netlink_ext_ack *extack)
 {
-	struct ip_tunnel_info *tun_info;
-	struct lwtunnel_state *new_state;
 	struct nlattr *tb[LWTUNNEL_IP_MAX + 1];
 	int err;
 
@@ -243,14 +240,6 @@ static int ip_tun_build_state(struct nlattr *attr,
 	if (err < 0)
 		return err;
 
-	new_state = lwtunnel_state_alloc(sizeof(*tun_info));
-	if (!new_state)
-		return -ENOMEM;
-
-	new_state->type = LWTUNNEL_ENCAP_IP;
-
-	tun_info = lwt_tun_info(new_state);
-
 	if (tb[LWTUNNEL_IP_ID])
 		tun_info->key.tun_id = nla_get_be64(tb[LWTUNNEL_IP_ID]);
 
@@ -272,16 +261,59 @@ static int ip_tun_build_state(struct nlattr *attr,
 	tun_info->mode = IP_TUNNEL_INFO_TX;
 	tun_info->options_len = 0;
 
-	*ts = new_state;
+	return 0;
+}
+
+static int ip_tun_build_state(struct nlattr *attr,
+			      unsigned int family, const void *cfg,
+			      struct lwtunnel_state **ts,
+			      struct netlink_ext_ack *extack)
+{
+	struct ip_tunnel_info *tun_info;
+	struct lwtunnel_state *new_state;
+	int err;
+
+	new_state = lwtunnel_state_alloc(sizeof(*tun_info));
+	if (!new_state)
+		return -ENOMEM;
 
+	new_state->type = LWTUNNEL_ENCAP_IP;
+
+	tun_info = lwt_tun_info(new_state);
+	err = ip_tun_build_common(tun_info, attr, extack);
+	if (err) {
+		lwtstate_free(new_state);
+		return err;
+	}
+
+	*ts = new_state;
 	return 0;
 }
 
-static int ip_tun_fill_encap_info(struct sk_buff *skb,
-				  struct lwtunnel_state *lwtstate)
+int ip_tunnel_build_metadst(struct net_device *dev, struct nlattr *meta,
+			    struct metadata_dst **dst,
+			    struct netlink_ext_ack *extack)
 {
-	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
+	struct metadata_dst *md_dst;
+	int err;
+
+	md_dst = metadata_dst_alloc(0, METADATA_IP_TUNNEL, GFP_ATOMIC);
+	if (!md_dst)
+		return -ENOMEM;
 
+	err = ip_tun_build_common(&md_dst->u.tun_info, meta, extack);
+	if (err) {
+		dst_release(&md_dst->dst);
+		return err;
+	}
+	*dst = md_dst;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_build_metadst);
+
+static int ip_tun_fill_common(struct sk_buff *skb,
+			      struct ip_tunnel_info *tun_info)
+{
 	if (nla_put_be64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id,
 			 LWTUNNEL_IP_PAD) ||
 	    nla_put_in_addr(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
@@ -294,6 +326,25 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 	return 0;
 }
 
+static int ip_tun_fill_encap_info(struct sk_buff *skb,
+				  struct lwtunnel_state *lwtstate)
+{
+	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
+	return ip_tun_fill_common(skb, tun_info);
+}
+
+int ip_tunnel_fill_metadst(struct sk_buff *skb, struct metadata_dst *md_dst)
+{
+	int err;
+	if (md_dst->type != METADATA_IP_TUNNEL)
+		return 0;
+	err = ip_tun_fill_common(skb, &md_dst->u.tun_info);
+	if (err)
+		return err;
+	return LWTUNNEL_ENCAP_IP;
+}
+EXPORT_SYMBOL_GPL(ip_tunnel_fill_metadst);
+
 static int ip_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
 	return nla_total_size_64bit(8)	/* LWTUNNEL_IP_ID */
-- 
2.13.0
