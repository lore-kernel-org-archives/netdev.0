From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v3 2/2] vxlan: allow specifying multiple default destinations
Date: Wed, 29 May 2013 13:00:16 +0300
Message-ID: <1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog112.obsmtp.com ([74.125.245.92]:33200 "HELO
	na3sys010aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965107Ab3E2KBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 06:01:14 -0400
Received: by mail-ea0-f178.google.com with SMTP id q16so5118379ead.37
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 03:01:12 -0700 (PDT)
In-Reply-To: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A list of multiple default destinations can be used in environments that
disable multicast on the infrastructure level, e.g. public clouds.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c          | 238 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |  17 ++++
 2 files changed, 255 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5a2cf2f..29c1752 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -137,6 +137,8 @@ struct vxlan_dev {
 	unsigned int	  addrcnt;
 	unsigned int	  addrmax;
 
+	unsigned int	  remote_cnt;  /* for additional default destinations */
+
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
@@ -642,6 +644,102 @@ static void vxlan_snoop(struct net_device *dev,
 	}
 }
 
+/* Add remote to default destinations list */
+static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct nlattr *i;
+	__be32 ip = htonl(INADDR_NONE);
+	__be16 port;
+	u32 ifindex, vni;
+	int rem, err = 0;
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
+			err = -EINVAL;
+			break;
+		};
+
+		if (err)
+			return err;
+	}
+
+	if (ip == htonl(INADDR_NONE))
+		return -EINVAL;
+
+	err = vxlan_rdst_append(&vxlan->default_dst, ip, port, vni, ifindex);
+	if (err < 0)
+		return err;
+
+	if (err == 0)
+		return -EEXIST;
+
+	vxlan->remote_cnt++;
+
+	return 0;
+}
+
+static void vxlan_remote_destroy(struct vxlan_dev *vxlan,
+				 struct vxlan_rdst *rd)
+{
+	vxlan->remote_cnt--;
+	kfree(rd);
+}
+
+/* Delete remote from default destinations list */
+static int vxlan_remote_delete(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct vxlan_rdst *rd, *rd_prev = NULL;
+	struct nlattr *i;
+	__be32 ip = htonl(INADDR_NONE);
+	int rem, err = 0;
+
+	nla_for_each_nested(i, attr, rem) {
+		switch (nla_type(i)) {
+		case IFLA_VXLAN_REMOTE_ADDR:
+			ip = nla_get_be32(i);
+			break;
+		default:
+			err = -EINVAL;
+			break;
+		}
+
+		if (err)
+			return err;
+	}
+
+	if (ip == htonl(INADDR_NONE))
+		return -EINVAL;
+
+	rd_prev = &vxlan->default_dst;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next) {
+		if (rd->remote_ip == ip) {
+			rd_prev->remote_next = rd->remote_next;
+			vxlan_remote_destroy(vxlan, rd);
+			return 0;
+		}
+		rd_prev = rd;
+	}
+
+	return -ENOENT;
+}
 
 /* See if multicast group is already in use by other ID */
 static bool vxlan_group_used(struct vxlan_net *vn,
@@ -1380,6 +1478,13 @@ static void vxlan_setup(struct net_device *dev)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
 
+static const struct nla_policy vxlan_remotes_policy[IFLA_VXLAN_REMOTE_MAX + 1] = {
+	[IFLA_VXLAN_REMOTE_ADDR]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_VXLAN_REMOTE_IFINDEX]	= { .type = NLA_U32 },
+	[IFLA_VXLAN_REMOTE_PORT]	= { .type = NLA_U16 },
+	[IFLA_VXLAN_REMOTE_VNI]		= { .type = NLA_U32 },
+};
+
 static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_ID]		= { .type = NLA_U32 },
 	[IFLA_VXLAN_GROUP]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
@@ -1396,10 +1501,35 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
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
@@ -1432,6 +1562,10 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		}
 	}
 
+	err = vxlan_validate_remotes(data[IFLA_VXLAN_REMOTES]);
+	if (err)
+		return err;
+
 	return 0;
 }
 
@@ -1512,6 +1646,46 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	return vs;
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
+			err = -EINVAL;
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
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
@@ -1630,11 +1804,20 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	return 0;
 }
 
+static void vxlan_remotes_flush(struct vxlan_dev *vxlan)
+{
+	struct vxlan_rdst *rd;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next)
+		vxlan_remote_destroy(vxlan, rd);
+}
+
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
+	vxlan_remotes_flush(vxlan);
 	hlist_del_rcu(&vxlan->hlist);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
@@ -1645,6 +1828,20 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	}
 }
 
+static size_t vxlan_remote_list_size(const struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	ssize_t size = nla_total_size(sizeof(struct nlattr));
+	struct vxlan_rdst *rd;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next) {
+		size += nla_total_size(sizeof(struct nlattr));
+		size += nla_total_size(sizeof(__be32));
+	}
+
+	return size;
+}
+
 static size_t vxlan_get_size(const struct net_device *dev)
 {
 
@@ -1663,9 +1860,46 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
 		nla_total_size(sizeof(__be16))+ /* IFLA_VXLAN_PORT */
+		vxlan_remote_list_size(dev) +
 		0;
 }
 
+static int vxlan_fill_remotes_info(struct sk_buff *skb,
+				   const struct vxlan_dev *vxlan)
+{
+	struct vxlan_rdst *rdst;
+	struct nlattr *nest, *rdst_nest;
+	__be32 ip;
+	int i;
+
+	if (vxlan->remote_cnt) {
+		nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		for (rdst = vxlan->default_dst.remote_next, i = 0; rdst;
+		     rdst = rdst->remote_next, i++) {
+			ip = rdst->remote_ip;
+
+			rdst_nest = nla_nest_start(skb, i);
+			if (rdst_nest == NULL)
+				goto nla_put_failure;
+
+			if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR, ip))
+				goto nla_put_failure;
+
+			nla_nest_end(skb, rdst_nest);
+		}
+
+		nla_nest_end(skb, nest);
+	}
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
@@ -1706,6 +1940,9 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
 		goto nla_put_failure;
 
+	if (vxlan_fill_remotes_info(skb, vxlan))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -1720,6 +1957,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
+	.changelink	= vxlan_changelink,
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b05823c..3f25bbd 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -311,10 +311,27 @@ enum {
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
 	IFLA_VXLAN_PORT,	/* destination port */
+	IFLA_VXLAN_REMOTES,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+enum {
+	IFLA_VXLAN_REMOTE_NEW,
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
