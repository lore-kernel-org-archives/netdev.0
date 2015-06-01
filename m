From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 07/14] vxlan: Factor out device configuration
Date: Mon,  1 Jun 2015 16:27:31 +0200
Message-ID: <a7bb16ab94200e009033e484c661af1a121ab4f6.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51005 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbbFAO1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:51 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This factors out the device configuration out of the RTNL newlink
API which allows for in-kernel creation of VXLAN net_devices.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 332 ++++++++++++++++++++++++++++------------------------
 include/net/vxlan.h |  59 ++++++++++
 2 files changed, 236 insertions(+), 155 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d5edba5..3acab95 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -54,10 +54,6 @@
 
 #define PORT_HASH_BITS	8
 #define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
-#define VNI_HASH_BITS	10
-#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
-#define FDB_HASH_BITS	8
-#define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
 #define FDB_AGE_DEFAULT 300 /* 5 min */
 #define FDB_AGE_INTERVAL (10 * HZ)	/* rescan interval */
 
@@ -74,6 +70,7 @@ module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 static int vxlan_net_id;
+static struct rtnl_link_ops vxlan_link_ops;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
@@ -84,21 +81,6 @@ struct vxlan_net {
 	spinlock_t	  sock_lock;
 };
 
-union vxlan_addr {
-	struct sockaddr_in sin;
-	struct sockaddr_in6 sin6;
-	struct sockaddr sa;
-};
-
-struct vxlan_rdst {
-	union vxlan_addr	 remote_ip;
-	__be16			 remote_port;
-	u32			 remote_vni;
-	u32			 remote_ifindex;
-	struct list_head	 list;
-	struct rcu_head		 rcu;
-};
-
 /* Forwarding table entry */
 struct vxlan_fdb {
 	struct hlist_node hlist;	/* linked list of entries */
@@ -111,31 +93,6 @@ struct vxlan_fdb {
 	u8		  eth_addr[ETH_ALEN];
 };
 
-/* Pseudo network device */
-struct vxlan_dev {
-	struct hlist_node hlist;	/* vni hash table */
-	struct list_head  next;		/* vxlan's per namespace list */
-	struct vxlan_sock *vn_sock;	/* listening socket */
-	struct net_device *dev;
-	struct net	  *net;		/* netns for packet i/o */
-	struct vxlan_rdst default_dst;	/* default destination */
-	union vxlan_addr  saddr;	/* source address */
-	__be16		  dst_port;
-	__u16		  port_min;	/* source port range */
-	__u16		  port_max;
-	__u8		  tos;		/* TOS override */
-	__u8		  ttl;
-	u32		  flags;	/* VXLAN_F_* in vxlan.h */
-
-	unsigned long	  age_interval;
-	struct timer_list age_timer;
-	spinlock_t	  hash_lock;
-	unsigned int	  addrcnt;
-	unsigned int	  addrmax;
-
-	struct hlist_head fdb_head[FDB_HASH_SIZE];
-};
-
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
@@ -345,7 +302,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (send_ip && vxlan_nla_put_addr(skb, NDA_DST, &rdst->remote_ip))
 		goto nla_put_failure;
 
-	if (rdst->remote_port && rdst->remote_port != vxlan->dst_port &&
+	if (rdst->remote_port && rdst->remote_port != vxlan->cfg.dst_port &&
 	    nla_put_be16(skb, NDA_PORT, rdst->remote_port))
 		goto nla_put_failure;
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
@@ -749,7 +706,8 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 		if (!(flags & NLM_F_CREATE))
 			return -ENOENT;
 
-		if (vxlan->addrmax && vxlan->addrcnt >= vxlan->addrmax)
+		if (vxlan->cfg.addrmax &&
+		    vxlan->addrcnt >= vxlan->cfg.addrmax)
 			return -ENOSPC;
 
 		/* Disallow replace to add a multicast entry */
@@ -835,7 +793,7 @@ static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
 			return -EINVAL;
 		*port = nla_get_be16(tb[NDA_PORT]);
 	} else {
-		*port = vxlan->dst_port;
+		*port = vxlan->cfg.dst_port;
 	}
 
 	if (tb[NDA_VNI]) {
@@ -1021,7 +979,7 @@ static bool vxlan_snoop(struct net_device *dev,
 			vxlan_fdb_create(vxlan, src_mac, src_ip,
 					 NUD_REACHABLE,
 					 NLM_F_EXCL|NLM_F_CREATE,
-					 vxlan->dst_port,
+					 vxlan->cfg.dst_port,
 					 vxlan->default_dst.remote_vni,
 					 0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
@@ -1945,7 +1903,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	u32 flags = vxlan->flags;
 
 	if (rdst) {
-		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
+		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = rdst->remote_vni;
 		dst = &rdst->remote_ip;
 	} else {
@@ -1955,7 +1913,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto drop;
 		}
 
-		dst_port = tun_info->key.tp_dst ? : vxlan->dst_port;
+		dst_port = tun_info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = be64_to_cpu(tun_info->key.tun_id);
 		remote_ip.sin.sin_family = AF_INET;
 		remote_ip.sin.sin_addr.s_addr = tun_info->key.ipv4_dst;
@@ -1973,16 +1931,16 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	old_iph = ip_hdr(skb);
 
-	ttl = vxlan->ttl;
+	ttl = vxlan->cfg.ttl;
 	if (!ttl && vxlan_addr_multicast(dst))
 		ttl = 1;
 
-	tos = vxlan->tos;
+	tos = vxlan->cfg.tos;
 	if (tos == 1)
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
-	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->port_min,
-				     vxlan->port_max, true);
+	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
+				     vxlan->cfg.port_max, true);
 
 	if (dst->sa.sa_family == AF_INET) {
 		if (tun_info) {
@@ -2008,7 +1966,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		fl4.flowi4_mark = skb->mark;
 		fl4.flowi4_proto = IPPROTO_UDP;
 		fl4.daddr = dst->sin.sin_addr.s_addr;
-		fl4.saddr = vxlan->saddr.sin.sin_addr.s_addr;
+		fl4.saddr = vxlan->cfg.saddr.sin.sin_addr.s_addr;
 
 		rt = ip_route_output_key(vxlan->net, &fl4);
 		if (IS_ERR(rt)) {
@@ -2064,7 +2022,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = rdst ? rdst->remote_ifindex : 0;
 		fl6.daddr = dst->sin6.sin6_addr;
-		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
+		fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
 		fl6.flowi6_mark = skb->mark;
 		fl6.flowi6_proto = IPPROTO_UDP;
 
@@ -2233,7 +2191,7 @@ static void vxlan_cleanup(unsigned long arg)
 			if (f->state & NUD_PERMANENT)
 				continue;
 
-			timeout = f->used + vxlan->age_interval * HZ;
+			timeout = f->used + vxlan->cfg.age_interval * HZ;
 			if (time_before_eq(timeout, jiffies)) {
 				netdev_dbg(vxlan->dev,
 					   "garbage collect %pM\n",
@@ -2297,8 +2255,8 @@ static int vxlan_open(struct net_device *dev)
 	struct vxlan_sock *vs;
 	int ret = 0;
 
-	vs = vxlan_sock_add(vxlan->net, vxlan->dst_port, vxlan_rcv, NULL,
-			    false, vxlan->flags);
+	vs = vxlan_sock_add(vxlan->net, vxlan->cfg.dst_port, vxlan_rcv,
+			    NULL, vxlan->cfg.no_share, vxlan->flags);
 	if (IS_ERR(vs))
 		return PTR_ERR(vs);
 
@@ -2312,7 +2270,7 @@ static int vxlan_open(struct net_device *dev)
 		}
 	}
 
-	if (vxlan->age_interval)
+	if (vxlan->cfg.age_interval)
 		mod_timer(&vxlan->age_timer, jiffies + FDB_AGE_INTERVAL);
 
 	return ret;
@@ -2476,7 +2434,7 @@ static void vxlan_setup(struct net_device *dev)
 	vxlan->age_timer.function = vxlan_cleanup;
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
-	vxlan->dst_port = htons(vxlan_port);
+	vxlan->cfg.dst_port = htons(vxlan_port);
 
 	vxlan->dev = dev;
 
@@ -2676,54 +2634,35 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 }
 EXPORT_SYMBOL_GPL(vxlan_sock_add);
 
-static int vxlan_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
+			       struct vxlan_config *conf)
 {
 	struct vxlan_net *vn = net_generic(src_net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
-	__u32 vni;
 	int err;
 	bool use_ipv6 = false;
-
-	if (!data[IFLA_VXLAN_ID])
-		return -EINVAL;
+	__be16 default_port = vxlan->cfg.dst_port;
 
 	vxlan->net = src_net;
 
-	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
-	dst->remote_vni = vni;
+	dst->remote_vni = conf->vni;
 
-	/* Unless IPv6 is explicitly requested, assume IPv4 */
-	dst->remote_ip.sa.sa_family = AF_INET;
-	if (data[IFLA_VXLAN_GROUP]) {
-		dst->remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
-	} else if (data[IFLA_VXLAN_GROUP6]) {
-		if (!IS_ENABLED(CONFIG_IPV6))
-			return -EPFNOSUPPORT;
-
-		dst->remote_ip.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_GROUP6]);
-		dst->remote_ip.sa.sa_family = AF_INET6;
-		use_ipv6 = true;
-	}
+	memcpy(&dst->remote_ip, &conf->remote_ip, sizeof(conf->remote_ip));
 
-	if (data[IFLA_VXLAN_LOCAL]) {
-		vxlan->saddr.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_LOCAL]);
-		vxlan->saddr.sa.sa_family = AF_INET;
-	} else if (data[IFLA_VXLAN_LOCAL6]) {
-		if (!IS_ENABLED(CONFIG_IPV6))
-			return -EPFNOSUPPORT;
+	/* Unless IPv6 is explicitly requested, assume IPv4 */
+	if (!dst->remote_ip.sa.sa_family)
+		dst->remote_ip.sa.sa_family = AF_INET;
 
-		/* TODO: respect scope id */
-		vxlan->saddr.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_LOCAL6]);
-		vxlan->saddr.sa.sa_family = AF_INET6;
+	if (dst->remote_ip.sa.sa_family == AF_INET6 ||
+	    vxlan->cfg.saddr.sa.sa_family == AF_INET6)
 		use_ipv6 = true;
-	}
 
-	if (data[IFLA_VXLAN_LINK] &&
-	    (dst->remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
+	if (conf->remote_ifindex) {
 		struct net_device *lowerdev
-			 = __dev_get_by_index(src_net, dst->remote_ifindex);
+			 = __dev_get_by_index(src_net, conf->remote_ifindex);
+
+		dst->remote_ifindex = conf->remote_ifindex;
 
 		if (!lowerdev) {
 			pr_info("ifindex %d does not exist\n", dst->remote_ifindex);
@@ -2741,7 +2680,7 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 		}
 #endif
 
-		if (!tb[IFLA_MTU])
+		if (!conf->mtu)
 			dev->mtu = lowerdev->mtu - (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
 
 		dev->needed_headroom = lowerdev->hard_header_len +
@@ -2749,104 +2688,187 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	} else if (use_ipv6)
 		vxlan->flags |= VXLAN_F_IPV6;
 
+	memcpy(&vxlan->cfg, conf, sizeof(*conf));
+	if (!vxlan->cfg.dst_port)
+		vxlan->cfg.dst_port = default_port;
+	vxlan->flags = conf->flags;
+
+	if (!vxlan->cfg.age_interval)
+		vxlan->cfg.age_interval = FDB_AGE_DEFAULT;
+
+	if (vxlan_find_vni(src_net, conf->vni, use_ipv6 ? AF_INET6 : AF_INET,
+			   vxlan->cfg.dst_port, vxlan->flags))
+		return -EEXIST;
+
+	dev->ethtool_ops = &vxlan_ethtool_ops;
+
+	/* create an fdb entry for a valid default destination */
+	if (!vxlan_addr_any(&vxlan->default_dst.remote_ip)) {
+		err = vxlan_fdb_create(vxlan, all_zeros_mac,
+				       &vxlan->default_dst.remote_ip,
+				       NUD_REACHABLE|NUD_PERMANENT,
+				       NLM_F_EXCL|NLM_F_CREATE,
+				       vxlan->cfg.dst_port,
+				       vxlan->default_dst.remote_vni,
+				       vxlan->default_dst.remote_ifindex,
+				       NTF_SELF);
+		if (err)
+			return err;
+	}
+
+	err = register_netdevice(dev);
+	if (err) {
+		vxlan_fdb_delete_default(vxlan);
+		return err;
+	}
+
+	list_add(&vxlan->next, &vn->vxlan_list);
+
+	return 0;
+}
+
+struct net_device *vxlan_dev_create(struct net *net, const char *name,
+				    u8 name_assign_type, struct vxlan_config *conf)
+{
+	struct nlattr *tb[IFLA_MAX+1];
+	struct net_device *dev;
+	int err;
+
+	memset(&tb, 0, sizeof(tb));
+
+	dev = rtnl_create_link(net, name, name_assign_type,
+			       &vxlan_link_ops, tb);
+	if (IS_ERR(dev))
+		return dev;
+
+	err = vxlan_dev_configure(net, dev, conf);
+	if (err < 0) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(vxlan_dev_create);
+
+static int vxlan_newlink(struct net *src_net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vxlan_config conf;
+	int err;
+
+	if (!data[IFLA_VXLAN_ID])
+		return -EINVAL;
+
+	memset(&conf, 0, sizeof(conf));
+	conf.vni = nla_get_u32(data[IFLA_VXLAN_ID]);
+
+	if (data[IFLA_VXLAN_GROUP]) {
+		conf.remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
+	} else if (data[IFLA_VXLAN_GROUP6]) {
+		if (!IS_ENABLED(CONFIG_IPV6))
+			return -EPFNOSUPPORT;
+
+		conf.remote_ip.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_GROUP6]);
+		conf.remote_ip.sa.sa_family = AF_INET6;
+	}
+
+	if (data[IFLA_VXLAN_LOCAL]) {
+		conf.saddr.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_LOCAL]);
+		conf.saddr.sa.sa_family = AF_INET;
+	} else if (data[IFLA_VXLAN_LOCAL6]) {
+		if (!IS_ENABLED(CONFIG_IPV6))
+			return -EPFNOSUPPORT;
+
+		/* TODO: respect scope id */
+		conf.saddr.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_LOCAL6]);
+		conf.saddr.sa.sa_family = AF_INET6;
+	}
+
+	if (data[IFLA_VXLAN_LINK])
+		conf.remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]);
+
 	if (data[IFLA_VXLAN_TOS])
-		vxlan->tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
+		conf.tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
 
 	if (data[IFLA_VXLAN_TTL])
-		vxlan->ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
+		conf.ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
 
 	if (!data[IFLA_VXLAN_LEARNING] || nla_get_u8(data[IFLA_VXLAN_LEARNING]))
-		vxlan->flags |= VXLAN_F_LEARN;
+		conf.flags |= VXLAN_F_LEARN;
 
 	if (data[IFLA_VXLAN_AGEING])
-		vxlan->age_interval = nla_get_u32(data[IFLA_VXLAN_AGEING]);
-	else
-		vxlan->age_interval = FDB_AGE_DEFAULT;
+		conf.age_interval = nla_get_u32(data[IFLA_VXLAN_AGEING]);
 
 	if (data[IFLA_VXLAN_PROXY] && nla_get_u8(data[IFLA_VXLAN_PROXY]))
-		vxlan->flags |= VXLAN_F_PROXY;
+		conf.flags |= VXLAN_F_PROXY;
 
 	if (data[IFLA_VXLAN_RSC] && nla_get_u8(data[IFLA_VXLAN_RSC]))
-		vxlan->flags |= VXLAN_F_RSC;
+		conf.flags |= VXLAN_F_RSC;
 
 	if (data[IFLA_VXLAN_L2MISS] && nla_get_u8(data[IFLA_VXLAN_L2MISS]))
-		vxlan->flags |= VXLAN_F_L2MISS;
+		conf.flags |= VXLAN_F_L2MISS;
 
 	if (data[IFLA_VXLAN_L3MISS] && nla_get_u8(data[IFLA_VXLAN_L3MISS]))
-		vxlan->flags |= VXLAN_F_L3MISS;
+		conf.flags |= VXLAN_F_L3MISS;
 
 	if (data[IFLA_VXLAN_LIMIT])
-		vxlan->addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
+		conf.addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
 
 	if (data[IFLA_VXLAN_FLOWBASED] && nla_get_u8(data[IFLA_VXLAN_FLOWBASED]))
-		vxlan->flags |= VXLAN_F_FLOW_BASED;
+		conf.flags |= VXLAN_F_FLOW_BASED;
 
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
 		const struct ifla_vxlan_port_range *p
 			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
-		vxlan->port_min = ntohs(p->low);
-		vxlan->port_max = ntohs(p->high);
+		conf.port_min = ntohs(p->low);
+		conf.port_max = ntohs(p->high);
 	}
 
 	if (data[IFLA_VXLAN_PORT])
-		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
+		conf.dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
 
 	if (data[IFLA_VXLAN_UDP_CSUM] && nla_get_u8(data[IFLA_VXLAN_UDP_CSUM]))
-		vxlan->flags |= VXLAN_F_UDP_CSUM;
+		conf.flags |= VXLAN_F_UDP_CSUM;
 
 	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
 	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
-		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
+		conf.flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
 
 	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
 	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
-		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
+		conf.flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
 
 	if (data[IFLA_VXLAN_REMCSUM_TX] &&
 	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
-		vxlan->flags |= VXLAN_F_REMCSUM_TX;
+		conf.flags |= VXLAN_F_REMCSUM_TX;
 
 	if (data[IFLA_VXLAN_REMCSUM_RX] &&
 	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
-		vxlan->flags |= VXLAN_F_REMCSUM_RX;
+		conf.flags |= VXLAN_F_REMCSUM_RX;
 
 	if (data[IFLA_VXLAN_GBP])
-		vxlan->flags |= VXLAN_F_GBP;
+		conf.flags |= VXLAN_F_GBP;
 
 	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
-		vxlan->flags |= VXLAN_F_REMCSUM_NOPARTIAL;
+		conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
 
-	if (vxlan_find_vni(src_net, vni, use_ipv6 ? AF_INET6 : AF_INET,
-			   vxlan->dst_port, vxlan->flags)) {
-		pr_info("duplicate VNI %u\n", vni);
-		return -EEXIST;
-	}
-
-	dev->ethtool_ops = &vxlan_ethtool_ops;
+	err = vxlan_dev_configure(src_net, dev, &conf);
+	switch (err) {
+	case -ENODEV:
+		pr_info("ifindex %d does not exist\n", conf.remote_ifindex);
+		break;
 
-	/* create an fdb entry for a valid default destination */
-	if (!vxlan_addr_any(&vxlan->default_dst.remote_ip)) {
-		err = vxlan_fdb_create(vxlan, all_zeros_mac,
-				       &vxlan->default_dst.remote_ip,
-				       NUD_REACHABLE|NUD_PERMANENT,
-				       NLM_F_EXCL|NLM_F_CREATE,
-				       vxlan->dst_port,
-				       vxlan->default_dst.remote_vni,
-				       vxlan->default_dst.remote_ifindex,
-				       NTF_SELF);
-		if (err)
-			return err;
-	}
+	case -EPERM:
+		pr_info("IPv6 is disabled via sysctl\n");
+		break;
 
-	err = register_netdevice(dev);
-	if (err) {
-		vxlan_fdb_delete_default(vxlan);
-		return err;
+	case -EEXIST:
+		pr_info("duplicate VNI %u\n", conf.vni);
+		break;
 	}
 
-	list_add(&vxlan->next, &vn->vxlan_list);
-
-	return 0;
+	return err;
 }
 
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
@@ -2895,8 +2917,8 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	const struct vxlan_dev *vxlan = netdev_priv(dev);
 	const struct vxlan_rdst *dst = &vxlan->default_dst;
 	struct ifla_vxlan_port_range ports = {
-		.low =  htons(vxlan->port_min),
-		.high = htons(vxlan->port_max),
+		.low =  htons(vxlan->cfg.port_min),
+		.high = htons(vxlan->cfg.port_max),
 	};
 
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, dst->remote_vni))
@@ -2919,22 +2941,22 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (dst->remote_ifindex && nla_put_u32(skb, IFLA_VXLAN_LINK, dst->remote_ifindex))
 		goto nla_put_failure;
 
-	if (!vxlan_addr_any(&vxlan->saddr)) {
-		if (vxlan->saddr.sa.sa_family == AF_INET) {
+	if (!vxlan_addr_any(&vxlan->cfg.saddr)) {
+		if (vxlan->cfg.saddr.sa.sa_family == AF_INET) {
 			if (nla_put_in_addr(skb, IFLA_VXLAN_LOCAL,
-					    vxlan->saddr.sin.sin_addr.s_addr))
+					    vxlan->cfg.saddr.sin.sin_addr.s_addr))
 				goto nla_put_failure;
 #if IS_ENABLED(CONFIG_IPV6)
 		} else {
 			if (nla_put_in6_addr(skb, IFLA_VXLAN_LOCAL6,
-					     &vxlan->saddr.sin6.sin6_addr))
+					     &vxlan->cfg.saddr.sin6.sin6_addr))
 				goto nla_put_failure;
 #endif
 		}
 	}
 
-	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
-	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->tos) ||
+	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->cfg.ttl) ||
+	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->cfg.tos) ||
 	    nla_put_u8(skb, IFLA_VXLAN_LEARNING,
 			!!(vxlan->flags & VXLAN_F_LEARN)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_PROXY,
@@ -2946,9 +2968,9 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_FLOWBASED,
 			!!(vxlan->flags & VXLAN_F_FLOW_BASED)) ||
-	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
-	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax) ||
-	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port) ||
+	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->cfg.age_interval) ||
+	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->cfg.addrmax) ||
+	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->cfg.dst_port) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_CSUM,
 			!!(vxlan->flags & VXLAN_F_UDP_CSUM)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 4e73df5..c037b27 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -94,6 +94,11 @@ struct vxlanhdr {
 #define VXLAN_VNI_MASK  (VXLAN_VID_MASK << 8)
 #define VXLAN_HLEN (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
 
+#define VNI_HASH_BITS	10
+#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
+#define FDB_HASH_BITS	8
+#define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
+
 struct vxlan_metadata {
 	__be32		vni;
 	u32		gbp;
@@ -117,6 +122,57 @@ struct vxlan_sock {
 	u32		  flags;
 };
 
+union vxlan_addr {
+	struct sockaddr_in sin;
+	struct sockaddr_in6 sin6;
+	struct sockaddr sa;
+};
+
+struct vxlan_rdst {
+	union vxlan_addr	 remote_ip;
+	__be16			 remote_port;
+	u32			 remote_vni;
+	u32			 remote_ifindex;
+	struct list_head	 list;
+	struct rcu_head		 rcu;
+};
+
+struct vxlan_config {
+	union vxlan_addr	remote_ip;
+	union vxlan_addr	saddr;
+	u32			vni;
+	int			remote_ifindex;
+	int			mtu;
+	__be16			dst_port;
+	__u16			port_min;
+	__u16			port_max;
+	__u8			tos;
+	__u8			ttl;
+	u32			flags;
+	unsigned long		age_interval;
+	unsigned int		addrmax;
+	bool			no_share;
+};
+
+/* Pseudo network device */
+struct vxlan_dev {
+	struct hlist_node hlist;	/* vni hash table */
+	struct list_head  next;		/* vxlan's per namespace list */
+	struct vxlan_sock *vn_sock;	/* listening socket */
+	struct net_device *dev;
+	struct net	  *net;		/* netns for packet i/o */
+	struct vxlan_rdst default_dst;	/* default destination */
+	u32		  flags;	/* VXLAN_F_* in vxlan.h */
+
+	struct timer_list age_timer;
+	spinlock_t	  hash_lock;
+	unsigned int	  addrcnt;
+
+	struct vxlan_config	cfg;
+
+	struct hlist_head fdb_head[FDB_HASH_SIZE];
+};
+
 #define VXLAN_F_LEARN			0x01
 #define VXLAN_F_PROXY			0x02
 #define VXLAN_F_RSC			0x04
@@ -145,6 +201,9 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
 				  bool no_share, u32 flags);
 
+struct net_device *vxlan_dev_create(struct net *net, const char *name,
+				    u8 name_assign_type, struct vxlan_config *conf);
+
 void vxlan_sock_release(struct vxlan_sock *vs);
 
 int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-- 
2.3.5
