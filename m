From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v2 2/2] vxlan: allow specifying multiple default destinations
Date: Tue, 28 May 2013 11:31:18 +0300
Message-ID: <1369729878-9690-3-git-send-email-mike.rapoport@ravellosystems.com>
References: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog101.obsmtp.com ([74.125.245.70]:34540 "HELO
	na3sys010aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933515Ab3E1Ibj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:31:39 -0400
Received: by mail-ea0-f180.google.com with SMTP id g10so4153217eak.25
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:31:36 -0700 (PDT)
In-Reply-To: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A list of multiple default destinations can be used in environments that
disable multicast on the infrastructure level, e.g. public clouds.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c          | 150 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |  14 ++++
 2 files changed, 164 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e7facb8..f33ea9d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -138,6 +138,8 @@ struct vxlan_dev {
 	unsigned int	  addrcnt;
 	unsigned int	  addrmax;
 
+	unsigned int	  remote_cnt;  /* for additional default destinations */
+
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
@@ -643,6 +645,92 @@ static void vxlan_snoop(struct net_device *dev,
 	}
 }
 
+/* Add remote to default destinations list */
+static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct nlattr *i;
+	__be32 ip;
+	__be16 port;
+	u32 ifindex, vni;
+	int rem, err = 0;
+	bool addr_set = false;
+
+	port = vxlan->dst_port;
+	vni = vxlan->default_dst.remote_vni;
+	ifindex = vxlan->default_dst.remote_ifindex;
+
+	nla_for_each_nested(i, attr, rem) {
+		switch (nla_type(i)) {
+		case IFLA_VXLAN_REMOTE_ADDR:
+			ip = nla_get_be32(i);
+			addr_set = true;
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
+	if (!addr_set)
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
+	netdev_dbg(vxlan->dev, "dstadd %pI4\n", &ip);
+
+	return 0;
+}
+
+static void vxlan_remote_destroy(struct vxlan_dev *vxlan,
+				 struct vxlan_rdst *rd)
+{
+	__be32 ip = rd->remote_ip;
+	netdev_dbg(vxlan->dev, "dstdel %pI4\n", &ip);
+
+	--vxlan->remote_cnt;
+	kfree(rd);
+}
+
+/* Delete remote from default destinations list */
+static int vxlan_remote_delete(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct vxlan_rdst *rd, *rd_prev = NULL;
+	__be32 ip;
+
+	ip = nla_get_be32(attr);
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
@@ -1513,6 +1601,27 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	return vs;
 }
 
+static int vxlan_changelink(struct net_device *dev,
+			    struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	int err;
+
+	if (data[IFLA_VXLAN_REMOTE_ADD]) {
+		err = vxlan_remote_add(vxlan, data[IFLA_VXLAN_REMOTE_ADD]);
+		if (err)
+			return err;
+	}
+
+	if (data[IFLA_VXLAN_REMOTE_DEL]) {
+		err = vxlan_remote_delete(vxlan, data[IFLA_VXLAN_REMOTE_DEL]);
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
@@ -1631,11 +1740,20 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
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
@@ -1646,6 +1764,18 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	}
 }
 
+static size_t vxlan_remote_list_size(const struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	ssize_t size = nla_total_size(sizeof(struct nlattr));
+	struct vxlan_rdst *rd;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next)
+		size += nla_total_size(sizeof(__be32));
+
+	return size;
+}
+
 static size_t vxlan_get_size(const struct net_device *dev)
 {
 
@@ -1664,6 +1794,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
 		nla_total_size(sizeof(__be16))+ /* IFLA_VXLAN_PORT */
+		vxlan_remote_list_size(dev) +
 		0;
 }
 
@@ -1707,6 +1838,24 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
 		goto nla_put_failure;
 
+	if (vxlan->remote_cnt) {
+		struct vxlan_rdst *rdst;
+		struct nlattr *nest;
+
+		nest = nla_nest_start(skb, IFLA_VXLAN_REMOTE_LST);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		for (rdst = vxlan->default_dst.remote_next; rdst;
+		     rdst = rdst->remote_next) {
+			__be32 ip = rdst->remote_ip;
+			if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR, ip))
+				goto nla_put_failure;
+		}
+
+		nla_nest_end(skb, nest);
+	}
+
 	return 0;
 
 nla_put_failure:
@@ -1721,6 +1870,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
+	.changelink	= vxlan_changelink,
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b05823c..5cab372 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -311,10 +311,24 @@ enum {
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
 	IFLA_VXLAN_PORT,	/* destination port */
+	IFLA_VXLAN_REMOTE_ADD,
+	IFLA_VXLAN_REMOTE_DEL,
+	IFLA_VXLAN_REMOTE_LST,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
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
