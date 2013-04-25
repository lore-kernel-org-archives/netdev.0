From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next 2/2] vxlan: allow specifying multiple default destinations
Date: Thu, 25 Apr 2013 14:03:49 +0300
Message-ID: <1366887829-3950-3-git-send-email-mike.rapoport@ravellosystems.com>
References: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:58923 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757916Ab3DYLEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 07:04:15 -0400
Received: by mail-wi0-f198.google.com with SMTP id c10so3888930wiw.5
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 04:04:13 -0700 (PDT)
In-Reply-To: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A list of multiple default destinations can be used in environments that
disable multicast on the infrastructure level, e.g. public clouds.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c          | 176 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |  14 ++++
 2 files changed, 190 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8963a83..eb4bbec 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -131,6 +131,8 @@ struct vxlan_dev {
 	unsigned int	  addrcnt;
 	unsigned int	  addrmax;
 
+	unsigned int	  remote_cnt;  /* for additional default destinations */
+
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
@@ -679,6 +681,104 @@ static void vxlan_snoop(struct net_device *dev,
 	}
 }
 
+/* Add remote to default destinations list */
+static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct vxlan_addr ip;
+	struct nlattr *i;
+	u32 port, ifindex, vni;
+	int rem, err = 0;
+	bool addr_set = false;
+
+	port = vxlan_port;
+	vni = vxlan->default_dst.remote_vni;
+	ifindex = vxlan->default_dst.remote_ifindex;
+
+	nla_for_each_nested(i, attr, rem) {
+		switch (nla_type(i)) {
+		case IFLA_VXLAN_REMOTE_ADDR:
+			err = vxlan_nla_get_addr(&ip, i);
+			addr_set = true;
+			break;
+		case IFLA_VXLAN_REMOTE_PORT:
+			port = nla_get_u32(attr);
+			break;
+		case IFLA_VXLAN_REMOTE_VNI:
+			vni = nla_get_u32(attr);
+			break;
+		case IFLA_VXLAN_REMOTE_IFINDEX:
+			ifindex = nla_get_u32(attr);
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
+	err = vxlan_rdst_append(&vxlan->default_dst, &ip,
+				port, vni, ifindex);
+	if (err < 0)
+		return err;
+
+	if (err == 0)
+		return -EEXIST;
+
+	vxlan->remote_cnt++;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ip.va_sa == AF_INET6)
+		netdev_dbg(vxlan->dev, "dstadd %pI6\n", &ip.va_sin6);
+	else
+#endif
+		netdev_dbg(vxlan->dev, "dstadd %pI4\n", &ip.va_sin);
+
+	return 0;
+}
+
+static void vxlan_remote_destroy(struct vxlan_dev *vxlan,
+				 struct vxlan_rdst *rd)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (rd->remote_ip.va_sa == AF_INET6)
+		netdev_dbg(vxlan->dev, "dstdel %pI6\n", &rd->remote_ip.va_sin6);
+	else
+#endif
+		netdev_dbg(vxlan->dev, "dstdel %pI4\n", &rd->remote_ip.va_sin);
+
+	--vxlan->remote_cnt;
+	kfree(rd);
+}
+
+/* Delete remote from default destinations list */
+static int vxlan_remote_delete(struct vxlan_dev *vxlan, struct nlattr *attr)
+{
+	struct vxlan_rdst *rd, *rd_prev = NULL;
+	struct vxlan_addr ip;
+	int err;
+
+	err = vxlan_nla_get_addr(&ip, attr);
+	if (err)
+		return err;
+
+	rd_prev = &vxlan->default_dst;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next) {
+		if (vxlan_addr_equal(&rd->remote_ip, &ip)) {
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
@@ -1500,6 +1600,14 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
 	spin_unlock_bh(&vxlan->hash_lock);
 }
 
+static void vxlan_remotes_flush(struct vxlan_dev *vxlan)
+{
+	struct vxlan_rdst *rd;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next)
+		vxlan_remote_destroy(vxlan, rd);
+}
+
 /* Cleanup timer and forwarding table on shutdown */
 static int vxlan_stop(struct net_device *dev)
 {
@@ -1511,6 +1619,7 @@ static int vxlan_stop(struct net_device *dev)
 	del_timer_sync(&vxlan->age_timer);
 
 	vxlan_flush(vxlan);
+	vxlan_remotes_flush(vxlan);
 
 	return 0;
 }
@@ -1662,6 +1771,27 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
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
@@ -1778,6 +1908,23 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	unregister_netdevice_queue(dev, head);
 }
 
+static size_t vxlan_remote_list_size(const struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	ssize_t size = nla_total_size(sizeof(struct nlattr));
+	struct vxlan_rdst *rd;
+
+	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next)
+#if IS_ENABLED(CONFIG_IPV6)
+		if (rd->remote_ip.va_sa == AF_INET6)
+			size += nla_total_size(sizeof(struct in6_addr));
+		else
+#endif
+			size += nla_total_size(sizeof(__be32));
+
+	return size;
+}
+
 static size_t vxlan_get_size(const struct net_device *dev)
 {
 
@@ -1795,6 +1942,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
+		vxlan_remote_list_size(dev) +
 		0;
 }
 
@@ -1857,6 +2005,33 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
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
+			if (rdst->remote_ip.va_sa == AF_INET) {
+				if (nla_put_be32(skb, IFLA_VXLAN_REMOTE_ADDR,
+						 rdst->remote_ip.va_sin))
+					goto nla_put_failure;
+			} else {
+#if IS_ENABLED(CONFIG_IPV6)
+				if (nla_put(skb, IFLA_VXLAN_REMOTE_ADDR,
+					    sizeof(struct in6_addr),
+					    &rdst->remote_ip.va_sin6))
+					goto nla_put_failure;
+#endif
+			}
+		}
+
+		nla_nest_end(skb, nest);
+	}
+
 	return 0;
 
 nla_put_failure:
@@ -1871,6 +2046,7 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
+	.changelink	= vxlan_changelink,
 	.dellink	= vxlan_dellink,
 	.get_size	= vxlan_get_size,
 	.fill_info	= vxlan_fill_info,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 92ae9bd..74f1bb8 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -312,10 +312,24 @@ enum {
 	IFLA_VXLAN_L3MISS,
 	IFLA_VXLAN_REMOTE6,
 	IFLA_VXLAN_LOCAL6,
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
+#define IFLA_VXLAN_REMOTE_MAX	(__IFLA_VXLAN_GRP_MAX - 1)
+
 struct ifla_vxlan_port_range {
 	__be16	low;
 	__be16	high;
-- 
1.8.1.5
