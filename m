From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [RFC PATCH net-next] vxlan: add ability to configure static multicast group members
Date: Tue, 16 Apr 2013 09:39:38 +0300
Message-ID: <1366094378-7091-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Mike Rapoport <mike.rapoport@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog113.obsmtp.com ([74.125.245.94]:54422 "HELO
	na3sys010aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755440Ab3DPGjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 02:39:47 -0400
Received: by mail-bk0-f69.google.com with SMTP id i18so205656bkv.8
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 23:39:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to multicast group address used as destination when no fdb
entry present, allow explicitly defining "static group members". In
environments that do not allow multicast on the infrastructure level,
e.g. public clouds, the multicast group can be thus defined statically.

Signed-off-by: Mike Rapoport <mike.rapoport@gmail.com>
---
 drivers/net/vxlan.c          | 129 +++++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h |  11 ++++
 2 files changed, 134 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 97a306c..6208073 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -122,6 +122,10 @@ struct vxlan_dev {
 	unsigned int	  addrmax;
 
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
+
+	/* static group management */
+	struct vxlan_rdst group_head;
+	unsigned int	  group_cnt;
 };
 
 #define VXLAN_F_LEARN	0x01
@@ -575,6 +579,61 @@ static void vxlan_snoop(struct net_device *dev,
 	}
 }
 
+/* Add static group member */
+static int vxlan_grp_member_add(struct vxlan_dev *vxlan, __be32 ip)
+{
+	struct vxlan_rdst *gm;
+
+	for (gm = vxlan->group_head.remote_next; gm; gm = gm->remote_next)
+		if (gm->remote_ip == ip)
+			return -EEXIST;
+
+	gm = kzalloc(sizeof(*gm), GFP_KERNEL);
+	if (!gm)
+		return -ENOMEM;
+
+	gm->remote_port = vxlan_port;
+	gm->remote_vni = vxlan->vni;
+	gm->remote_ip = ip;
+	gm->remote_ifindex = vxlan->link;
+
+	++vxlan->group_cnt;
+	gm->remote_next = vxlan->group_head.remote_next;
+	vxlan->group_head.remote_next = gm;
+
+	netdev_dbg(vxlan->dev, "add grp %pI4\n", &gm->remote_ip);
+
+	return 0;
+}
+
+static void vxlan_grp_member_destroy(struct vxlan_dev *vxlan,
+				     struct vxlan_rdst *gm)
+{
+	netdev_dbg(vxlan->dev, "delete grp %pI4\n", &gm->remote_ip);
+
+	--vxlan->group_cnt;
+	kfree(gm);
+}
+
+/* Delete static group member */
+static int vxlan_grp_member_delete(struct vxlan_dev *vxlan, __be32 ip)
+{
+	struct vxlan_rdst *gm, *gm_prev = NULL;
+	int err = -ENOENT;
+
+	gm_prev = &vxlan->group_head;
+
+	for (gm = vxlan->group_head.remote_next; gm; gm = gm->remote_next) {
+		if (gm->remote_ip == ip) {
+			gm_prev->remote_next = gm->remote_next;
+			vxlan_grp_member_destroy(vxlan, gm);
+			return 0;
+		}
+		gm_prev = gm;
+	}
+
+	return err;
+}
 
 /* See if multicast group is already in use by other ID */
 static bool vxlan_group_used(struct vxlan_net *vn,
@@ -1106,12 +1165,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	if (f == NULL) {
 		did_rsc = false;
-		group.remote_port = vxlan_port;
-		group.remote_vni = vxlan->vni;
-		group.remote_ip = vxlan->gaddr;
-		group.remote_ifindex = vxlan->link;
-		group.remote_next = NULL;
-		rdst0 = &group;
+		rdst0 = &vxlan->group_head;
 
 		if (group.remote_ip == htonl(INADDR_ANY) &&
 		    (vxlan->flags & VXLAN_F_L2MISS) &&
@@ -1189,8 +1243,15 @@ static int vxlan_init(struct net_device *dev)
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *group = &vxlan->group_head;
 	int err;
 
+	group->remote_port = vxlan_port;
+	group->remote_vni = vxlan->vni;
+	group->remote_ip = vxlan->gaddr;
+	group->remote_ifindex = vxlan->link;
+	group->remote_next = NULL;
+
 	if (vxlan->gaddr) {
 		err = vxlan_join_group(dev);
 		if (err)
@@ -1220,6 +1281,14 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
 	spin_unlock_bh(&vxlan->hash_lock);
 }
 
+static void vxlan_grp_flush(struct vxlan_dev *vxlan)
+{
+	struct vxlan_rdst *gm;
+
+	for (gm = vxlan->group_head.remote_next; gm; gm = gm->remote_next)
+		vxlan_grp_member_destroy(vxlan, gm);
+}
+
 /* Cleanup timer and forwarding table on shutdown */
 static int vxlan_stop(struct net_device *dev)
 {
@@ -1231,6 +1300,7 @@ static int vxlan_stop(struct net_device *dev)
 	del_timer_sync(&vxlan->age_timer);
 
 	vxlan_flush(vxlan);
+	vxlan_grp_flush(vxlan);
 
 	return 0;
 }
@@ -1383,6 +1453,27 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
+static int vxlan_changelink(struct net_device *dev,
+			    struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	if (data[IFLA_VXLAN_GRP_ADD]) {
+		__be32 addr = nla_get_be32(data[IFLA_VXLAN_GRP_ADD]);
+		int err = vxlan_grp_member_add(vxlan, addr);
+		if (err)
+			netdev_err(dev, "add grp %pI4: %d\n", &addr, err);
+	}
+
+	if (data[IFLA_VXLAN_GRP_DEL]) {
+		__be32 addr = nla_get_be32(data[IFLA_VXLAN_GRP_DEL]);
+		int err = vxlan_grp_member_delete(vxlan, addr);
+		if (err)
+			netdev_err(dev, "del grp %pI4: %d\n", &addr, err);
+	}
+
+	return 0;
+}
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
@@ -1478,6 +1569,13 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	unregister_netdevice_queue(dev, head);
 }
 
+static size_t vxlan_grp_list_size(const struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	return nla_total_size(sizeof(struct nlattr)) +
+		vxlan->group_cnt * nla_total_size(sizeof(__be32));
+}
+
 static size_t vxlan_get_size(const struct net_device *dev)
 {
 
@@ -1495,6 +1593,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
+		vxlan_grp_list_size(dev) +
 		0;
 }
 
@@ -1536,6 +1635,23 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
 		goto nla_put_failure;
 
+	if (vxlan->group_cnt) {
+		struct vxlan_rdst *gm;
+		struct nlattr *nest;
+
+		nest = nla_nest_start(skb, IFLA_VXLAN_GRP_LST);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		for (gm = vxlan->group_head.remote_next; gm;
+		     gm = gm->remote_next)
+			if (nla_put_be32(skb, IFLA_VXLAN_GRP_MEMBER,
+					 gm->remote_ip))
+				goto nla_put_failure;
+
+		nla_nest_end(skb, nest);
+	}
+
 	return 0;
 
 nla_put_failure:
@@ -1550,6 +1666,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
+	.changelink	= vxlan_changelink,
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 6b35c42..f8bf67c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -309,10 +309,21 @@ enum {
 	IFLA_VXLAN_RSC,
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
+	IFLA_VXLAN_GRP_ADD,
+	IFLA_VXLAN_GRP_DEL,
+	IFLA_VXLAN_GRP_LST,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+enum {
+	IFLA_VXLAN_GRP_UNSPEC,
+	IFLA_VXLAN_GRP_MEMBER,
+	__IFLA_VXLAN_GRP_MAX
+};
+
+#define IFLA_VXLAN_GRP_MAX	(__IFLA_VXLAN_GRP_MAX - 1)
+
 struct ifla_vxlan_port_range {
 	__be16	low;
 	__be16	high;
-- 
1.8.1.5
