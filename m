From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v4 2/2] vxlan: allow specifying multiple default destinations
Date: Sun, 23 Jun 2013 19:22:23 +0300
Message-ID: <1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog112.obsmtp.com ([74.125.245.92]:55994 "HELO
	na3sys010aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751806Ab3FWQWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:22:41 -0400
Received: by mail-ea0-f180.google.com with SMTP id k10so5691257eaj.11
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 09:22:38 -0700 (PDT)
In-Reply-To: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A list of multiple default destinations can be used in environments that
disable multicast on the infrastructure level, e.g. public clouds.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c          | 268 +++++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h |  17 +++
 2 files changed, 276 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e5fb6568..f57a0d94 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -103,6 +103,7 @@ struct vxlan_rdst {
 	u32			 remote_vni;
 	u32			 remote_ifindex;
 	struct list_head	 list;
+	struct rcu_head		 rcu;
 };
 
 /* Forwarding table entry */
@@ -141,6 +142,9 @@ struct vxlan_dev {
 	unsigned int	  addrcnt;
 	unsigned int	  addrmax;
 
+	struct list_head  remotes;     /* additional default destinations */
+	unsigned int	  remotes_cnt;
+
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
@@ -671,6 +675,105 @@ static bool vxlan_snoop(struct net_device *dev,
 	return false;
 }
 
+/* Add remote to default destinations list */
+static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct nlattr *i;
+	__be32 ip = htonl(INADDR_NONE);
+	__be16 port;
+	u32 ifindex, vni;
+	int rem, err;
+
+	port = vxlan->dst_port;
+	vni = vxlan->default_dst.remote_vni;
+	ifindex = vxlan->default_dst.remote_ifindex;
+
+	nla_for_each_nested(i, attr, rem) {
+		switch (nla_type(i)) {
+		case IFLA_VXLAN_REMOTE_ADDR:
+			ip = nla_get_be32(i);
+			break;
+		case IFLA_VXLAN_REMOTE_PORT:
+			port = nla_get_be16(i);
+			break;
+		case IFLA_VXLAN_REMOTE_VNI:
+			vni = nla_get_u32(i);
+			break;
+		case IFLA_VXLAN_REMOTE_IFINDEX:
+			ifindex = nla_get_u32(i);
+			break;
+		default:
+			break;
+		};
+	}
+
+	if (ip == htonl(INADDR_NONE))
+		return -EINVAL;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	err = vxlan_rdst_append(&vxlan->remotes, ip, port, vni, ifindex);
+	spin_unlock_bh(&vxlan->hash_lock);
+
+	if (err < 0)
+		return err;
+
+	if (err == 0)
+		return -EEXIST;
+
+	vxlan->remotes_cnt++;
+
+	return 0;
+}
+
+static void vxlan_remote_free(struct rcu_head *head)
+{
+	struct vxlan_rdst *rd = container_of(head, struct vxlan_rdst, rcu);
+	kfree(rd);
+}
+
+static void vxlan_remote_destroy(struct vxlan_dev *vxlan,
+				 struct vxlan_rdst *rd)
+{
+	vxlan->remotes_cnt--;
+	list_del_rcu(&rd->list);
+	call_rcu(&rd->rcu, vxlan_remote_free);
+}
+
+/* Delete remote from default destinations list */
+static int vxlan_remote_delete(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct vxlan_rdst *rd;
+	struct nlattr *i;
+	__be32 ip = htonl(INADDR_NONE);
+	int rem, err;
+
+	nla_for_each_nested(i, attr, rem) {
+		switch (nla_type(i)) {
+		case IFLA_VXLAN_REMOTE_ADDR:
+			ip = nla_get_be32(i);
+			break;
+		default:
+			break;
+		}
+	}
+
+	if (ip == htonl(INADDR_NONE) || ip == vxlan->default_dst.remote_ip)
+		return -EINVAL;
+
+	err = -ENOENT;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	list_for_each_entry_rcu(rd, &vxlan->remotes, list) {
+		if (rd->remote_ip == ip) {
+			vxlan_remote_destroy(vxlan, rd);
+			err = 0;
+			break;
+		}
+	}
+	spin_unlock_bh(&vxlan->hash_lock);
+
+	return err;
+}
 
 /* See if multicast group is already in use by other ID */
 static bool vxlan_group_used(struct vxlan_net *vn, __be32 remote_ip)
@@ -1159,6 +1262,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool did_rsc = false;
 	struct vxlan_rdst *rdst0, *rdst;
 	struct vxlan_fdb *f;
+	struct list_head *remotes;
 
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
@@ -1183,20 +1287,22 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		    (vxlan->flags & VXLAN_F_L2MISS) &&
 		    !is_multicast_ether_addr(eth->h_dest))
 			vxlan_fdb_miss(vxlan, eth->h_dest);
+
+		remotes = &vxlan->remotes;
 	} else {
-		rdst = rdst0 = first_remote(f);
+		remotes = &f->remotes;
+	}
 
-		/* if there are multiple destinations, send copies */
-		list_for_each_entry_continue_rcu(rdst, &f->remotes, list) {
-			struct sk_buff *skb1;
+	/* if there are multiple destinations, send copies */
+	list_for_each_entry_rcu(rdst, remotes, list) {
+		struct sk_buff *skb1;
 
-			skb1 = skb_clone(skb, GFP_ATOMIC);
-			if (skb1)
-				vxlan_xmit_one(skb1, dev, rdst, did_rsc);
-		}
+		skb1 = skb_clone(skb, GFP_ATOMIC);
+		if (skb1)
+			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
 	}
 
-	vxlan_xmit_one(skb, dev, rdst0, did_rsc);
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
@@ -1389,6 +1495,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 	INIT_LIST_HEAD(&vxlan->next);
+	INIT_LIST_HEAD(&vxlan->remotes);
 	spin_lock_init(&vxlan->hash_lock);
 	INIT_WORK(&vxlan->igmp_work, vxlan_igmp_work);
 	INIT_WORK(&vxlan->sock_work, vxlan_sock_work);
@@ -1408,6 +1515,13 @@ static void vxlan_setup(struct net_device *dev)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
 
+static const struct nla_policy vxlan_remotes_policy[IFLA_VXLAN_REMOTE_MAX + 1] = {
+	[IFLA_VXLAN_REMOTE_ADDR]	= { .type = NLA_U32 },
+	[IFLA_VXLAN_REMOTE_IFINDEX]	= { .type = NLA_U32 },
+	[IFLA_VXLAN_REMOTE_PORT]	= { .type = NLA_U16 },
+	[IFLA_VXLAN_REMOTE_VNI]		= { .type = NLA_U32 },
+};
+
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
@@ -1424,10 +1538,35 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
+	[IFLA_VXLAN_REMOTES]	= { .type = NLA_NESTED },
 };
 
+static int vxlan_validate_remotes(struct nlattr *data)
+{
+	struct nlattr *attr;
+	int rem, err;
+
+	if (!data)
+		return 0;
+
+	nla_for_each_nested(attr, data, rem) {
+		if ((nla_type(attr) != IFLA_VXLAN_REMOTE_NEW) &&
+		    (nla_type(attr) != IFLA_VXLAN_REMOTE_DEL))
+			return -EINVAL;
+
+		err = nla_validate_nested(attr, IFLA_VXLAN_REMOTE_MAX,
+					  vxlan_remotes_policy);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
+	int err;
+
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
 			pr_debug("invalid link address (not ethernet)\n");
@@ -1460,6 +1599,10 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		}
 	}
 
+	err = vxlan_validate_remotes(data[IFLA_VXLAN_REMOTES]);
+	if (err)
+		return err;
+
 	return 0;
 }
 
@@ -1668,19 +1811,81 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		return err;
 
 	list_add(&vxlan->next, &vn->vxlan_list);
+	list_add_tail_rcu(&vxlan->default_dst.list, &vxlan->remotes);
 
 	return 0;
 }
 
+static int vxlan_remotes_update(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct nlattr *i;
+	int rem, err = 0;
+
+	nla_for_each_nested(i, attr, rem) {
+		switch (nla_type(i)) {
+		case IFLA_VXLAN_REMOTE_NEW:
+			err = vxlan_remote_add(vxlan, i);
+			break;
+		case IFLA_VXLAN_REMOTE_DEL:
+			err = vxlan_remote_delete(vxlan, i);
+			break;
+		default:
+			err = -EOPNOTSUPP;
+			break;
+		};
+
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int vxlan_changelink(struct net_device *dev,
+			    struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	int err;
+
+	if (data[IFLA_VXLAN_REMOTES]) {
+		err = vxlan_remotes_update(vxlan, data[IFLA_VXLAN_REMOTES]);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static void vxlan_remotes_flush(struct vxlan_dev *vxlan)
+{
+	struct vxlan_rdst *rd, *nd;
+
+	spin_lock_bh(&vxlan->hash_lock);
+	list_for_each_entry_safe(rd, nd, &vxlan->remotes, list)
+		vxlan_remote_destroy(vxlan, rd);
+	spin_unlock_bh(&vxlan->hash_lock);
+}
+
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 
+	vxlan_remotes_flush(vxlan);
 	hlist_del_rcu(&vxlan->hlist);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 }
 
+static size_t vxlan_remote_list_size(const struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+
+	return nla_total_size(sizeof(struct nlattr)) +	/* IFLA_VXLAN_REMOTES */
+		(nla_total_size(sizeof(struct nlattr)) +
+		 nla_total_size(sizeof(__be32)) +	/* IFLA_VXLAN_REMOTE_ADDR */
+		 0) * vxlan->remotes_cnt;
+}
+
 static size_t vxlan_get_size(const struct net_device *dev)
 {
 
@@ -1699,9 +1904,50 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
 		nla_total_size(sizeof(__be16))+ /* IFLA_VXLAN_PORT */
+		vxlan_remote_list_size(dev) +
 		0;
 }
 
+static int vxlan_fill_remotes_info(struct sk_buff *skb,
+				   const struct vxlan_dev *vxlan)
+{
+	struct vxlan_rdst *rd;
+	struct nlattr *nest, *rdst_nest;
+	__be32 ip;
+	int i = 1;
+
+	if (!vxlan->remotes_cnt)
+		return 0;
+
+	nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	list_for_each_entry_rcu(rd, &vxlan->remotes, list) {
+		ip = rd->remote_ip;
+
+		if (ip == vxlan->default_dst.remote_ip)
+			continue;
+
+		rdst_nest = nla_nest_start(skb, i);
+		if (rdst_nest == NULL)
+			goto nla_put_failure;
+
+		if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR, ip))
+			goto nla_put_failure;
+
+		nla_nest_end(skb, rdst_nest);
+		i++;
+	}
+
+	nla_nest_end(skb, nest);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	const struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -1742,6 +1988,9 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
 		goto nla_put_failure;
 
+	if (vxlan_fill_remotes_info(skb, vxlan))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -1756,6 +2005,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
+	.changelink	= vxlan_changelink,
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 03f6170..6ef25c1 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -313,10 +313,27 @@ enum {
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
 	IFLA_VXLAN_PORT,	/* destination port */
+	IFLA_VXLAN_REMOTES,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+enum {
+	IFLA_VXLAN_REMOTE_NEW = 1,
+	IFLA_VXLAN_REMOTE_DEL,
+};
+
+enum {
+	IFLA_VXLAN_REMOTE_UNSPEC,
+	IFLA_VXLAN_REMOTE_ADDR,
+	IFLA_VXLAN_REMOTE_IFINDEX,
+	IFLA_VXLAN_REMOTE_PORT,
+	IFLA_VXLAN_REMOTE_VNI,
+	__IFLA_VXLAN_REMOTE_MAX
+};
+
+#define IFLA_VXLAN_REMOTE_MAX	(__IFLA_VXLAN_REMOTE_MAX - 1)
+
 struct ifla_vxlan_port_range {
 	__be16	low;
 	__be16	high;
-- 
1.8.1.5
