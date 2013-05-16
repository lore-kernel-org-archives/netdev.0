From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] vxlan: listen on multiple ports
Date: Thu, 16 May 2013 14:35:20 -0700
Message-ID: <20130516143520.581d1d78@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:56587 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3EPVfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 17:35:24 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx1so2911586pab.27
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 14:35:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
  Author: stephen hemminger <stephen@networkplumber.org>
  Date:   Sat Apr 27 11:31:57 2013 +0000

    vxlan: allow choosing destination port per vxlan
    
introduced per-vxlan UDP port configuration but only did half of the
necessary work.  It added per vxlan destination for sending, but
overlooked the handling of multiple ports for incoming traffic.

This patch changes the listening port management to handle multiple
incoming UDP ports. The earlier per-namespace structure is now a hash
list per namespace.

It is also now possible to define the same virtual network id
but with different UDP port values which can be useful for migration.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-05-16 10:46:19.322339180 -0700
+++ b/drivers/net/vxlan.c	2013-05-16 14:26:30.440198255 -0700
@@ -44,6 +44,8 @@
 
 #define VXLAN_VERSION	"0.1"
 
+#define PORT_HASH_BITS	8
+#define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 #define FDB_HASH_BITS	8
@@ -76,13 +78,24 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-/* per-net private data for this module */
 static unsigned int vxlan_net_id;
-struct vxlan_net {
-	struct socket	  *sock;	/* UDP encap socket */
+
+/* per UDP socket information */
+struct vxlan_sock {
+	struct hlist_node hlist;
+	struct rcu_head	  rcu;
+	struct work_struct del_work;
+	unsigned int	  refcnt;
+	struct socket	  *sock;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 };
 
+/* per-network namespace private data for this module */
+struct vxlan_net {
+	struct list_head  vxlan_list;
+	struct hlist_head sock_list[PORT_HASH_SIZE];
+};
+
 struct vxlan_rdst {
 	struct rcu_head		 rcu;
 	__be32			 remote_ip;
@@ -106,7 +119,9 @@ struct vxlan_fdb {
 
 /* Pseudo network device */
 struct vxlan_dev {
-	struct hlist_node hlist;
+	struct hlist_node hlist;	/* vni hash table */
+	struct list_head  next;		/* vxlan's per namespace list */
+	struct vxlan_sock *vn_sock;	/* listening socket */
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
 	__be32		  saddr;	/* source address */
@@ -135,19 +150,43 @@ struct vxlan_dev {
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 
-static inline struct hlist_head *vni_head(struct net *net, u32 id)
+/* Virtual Network hash table head */
+static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
+{
+	return &vs->vni_list[hash_32(id, VNI_HASH_BITS)];
+}
+
+/* Socket hash table head */
+static inline struct hlist_head *vs_head(struct net *net, __be16 port)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 
-	return &vn->vni_list[hash_32(id, VNI_HASH_BITS)];
+	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
+}
+
+/* Find VXLAN socket based on network namespace and UDP port */
+static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
+{
+	struct vxlan_sock *vs;
+
+	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
+		if (inet_sk(vs->sock->sk)->inet_sport == port)
+			return vs;
+	}
+	return NULL;
 }
 
 /* Look up VNI in a per net namespace table */
-static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id)
+static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
 {
+	struct vxlan_sock *vs;
 	struct vxlan_dev *vxlan;
 
-	hlist_for_each_entry_rcu(vxlan, vni_head(net, id), hlist) {
+	vs = vxlan_find_port(net, port);
+	if (!vs)
+		return NULL;
+
+	hlist_for_each_entry_rcu(vxlan, vni_head(vs, id), hlist) {
 		if (vxlan->default_dst.remote_vni == id)
 			return vxlan;
 	}
@@ -592,20 +631,18 @@ static void vxlan_snoop(struct net_devic
 static bool vxlan_group_used(struct vxlan_net *vn,
 			     const struct vxlan_dev *this)
 {
-	const struct vxlan_dev *vxlan;
-	unsigned h;
+	struct vxlan_dev *vxlan;
 
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		hlist_for_each_entry(vxlan, &vn->vni_list[h], hlist) {
-			if (vxlan == this)
-				continue;
+	list_for_each_entry(vxlan, &vn->vxlan_list, next) {
+		if (vxlan == this)
+			continue;
 
-			if (!netif_running(vxlan->dev))
-				continue;
+		if (!netif_running(vxlan->dev))
+			continue;
 
-			if (vxlan->default_dst.remote_ip == this->default_dst.remote_ip)
-				return true;
-		}
+		if (vxlan->default_dst.remote_ip == this->default_dst.remote_ip)
+			return true;
+	}
 
 	return false;
 }
@@ -615,7 +652,7 @@ static int vxlan_join_group(struct net_d
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vn->sock->sk;
+	struct sock *sk = vxlan->vn_sock->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
@@ -643,7 +680,7 @@ static int vxlan_leave_group(struct net_
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	int err = 0;
-	struct sock *sk = vn->sock->sk;
+	struct sock *sk = vxlan->vn_sock->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
@@ -670,6 +707,7 @@ static int vxlan_udp_encap_recv(struct s
 	struct vxlanhdr *vxh;
 	struct vxlan_dev *vxlan;
 	struct pcpu_tstats *stats;
+	__be16 port;
 	__u32 vni;
 	int err;
 
@@ -693,9 +731,11 @@ static int vxlan_udp_encap_recv(struct s
 
 	/* Is this VNI defined? */
 	vni = ntohl(vxh->vx_vni) >> 8;
-	vxlan = vxlan_find_vni(sock_net(sk), vni);
+	port = inet_sk(sk)->inet_sport;
+	vxlan = vxlan_find_vni(sock_net(sk), vni, port);
 	if (!vxlan) {
-		netdev_dbg(skb->dev, "unknown vni %d\n", vni);
+		netdev_dbg(skb->dev, "unknown vni %d port %u\n",
+			   vni, ntohs(port));
 		goto drop;
 	}
 
@@ -875,7 +915,7 @@ static bool route_shortcircuit(struct ne
 	return false;
 }
 
-static void vxlan_sock_free(struct sk_buff *skb)
+static void vxlan_sock_put(struct sk_buff *skb)
 {
 	sock_put(skb->sk);
 }
@@ -883,13 +923,13 @@ static void vxlan_sock_free(struct sk_bu
 /* On transmit, associate with the tunnel socket */
 static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
 {
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vn->sock->sk;
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct sock *sk = vxlan->vn_sock->sock->sk;
 
 	skb_orphan(skb);
 	sock_hold(sk);
 	skb->sk = sk;
-	skb->destructor = vxlan_sock_free;
+	skb->destructor = vxlan_sock_put;
 }
 
 /* Compute source port for outgoing packet
@@ -1031,7 +1071,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 		struct vxlan_dev *dst_vxlan;
 
 		ip_rt_put(rt);
-		dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
+		dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
 		if (!dst_vxlan)
 			goto tx_error;
 		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -1306,6 +1346,7 @@ static void vxlan_setup(struct net_devic
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
+	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
 
 	init_timer_deferrable(&vxlan->age_timer);
@@ -1390,11 +1431,78 @@ static const struct ethtool_ops vxlan_et
 	.get_link	= ethtool_op_get_link,
 };
 
+static void vxlan_del_work(struct work_struct *work)
+{
+	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
+
+	sk_release_kernel(vs->sock->sk);
+	kfree_rcu(vs, rcu);
+}
+
+/* Create new listen socket if needed */
+static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
+{
+	struct vxlan_sock *vs;
+	struct sock *sk;
+	struct sockaddr_in vxlan_addr = {
+		.sin_family = AF_INET,
+		.sin_addr.s_addr = htonl(INADDR_ANY),
+	};
+	int rc;
+	unsigned h;
+
+	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
+	if (!vs)
+		return ERR_PTR(-ENOMEM);
+
+	for (h = 0; h < VNI_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&vs->vni_list[h]);
+
+	INIT_WORK(&vs->del_work, vxlan_del_work);
+
+	/* Create UDP socket for encapsulation receive. */
+	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vs->sock);
+	if (rc < 0) {
+		pr_debug("UDP socket create failed\n");
+		kfree(vs);
+		return ERR_PTR(rc);
+	}
+
+	/* Put in proper namespace */
+	sk = vs->sock->sk;
+	sk_change_net(sk, net);
+
+	vxlan_addr.sin_port = port;
+
+	rc = kernel_bind(vs->sock, (struct sockaddr *) &vxlan_addr,
+			 sizeof(vxlan_addr));
+	if (rc < 0) {
+		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
+			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
+		sk_release_kernel(sk);
+		kfree(vs);
+		return ERR_PTR(rc);
+	}
+
+	/* Disable multicast loopback */
+	inet_sk(sk)->mc_loop = 0;
+
+	/* Mark socket as an encapsulation socket. */
+	udp_sk(sk)->encap_type = 1;
+	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
+	udp_encap_enable();
+
+	vs->refcnt = 1;
+	return vs;
+}
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
+	struct vxlan_sock *vs;
 	__u32 vni;
 	int err;
 
@@ -1402,10 +1510,6 @@ static int vxlan_newlink(struct net *net
 		return -EINVAL;
 
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
-	if (vxlan_find_vni(net, vni)) {
-		pr_info("duplicate VNI %u\n", vni);
-		return -EEXIST;
-	}
 	dst->remote_vni = vni;
 
 	if (data[IFLA_VXLAN_GROUP])
@@ -1471,22 +1575,58 @@ static int vxlan_newlink(struct net *net
 	if (data[IFLA_VXLAN_PORT])
 		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
 
+	if (vxlan_find_vni(net, vni, vxlan->dst_port)) {
+		pr_info("duplicate VNI %u\n", vni);
+		return -EEXIST;
+	}
+
+	vs = vxlan_find_port(net, vxlan->dst_port);
+	if (vs)
+		++vs->refcnt;
+	else {
+		/* Drop lock because socket create acquires RTNL lock */
+		rtnl_unlock();
+		vs = vxlan_socket_create(net, vxlan->dst_port);
+		rtnl_lock();
+		if (IS_ERR(vs))
+			return PTR_ERR(vs);
+
+		hlist_add_head_rcu(&vs->hlist, vs_head(net, vxlan->dst_port));
+	}
+	vxlan->vn_sock = vs;
+
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
 	err = register_netdevice(dev);
-	if (!err)
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(net, dst->remote_vni));
+	if (err) {
+		if (--vs->refcnt == 0) {
+			rtnl_unlock();
+			sk_release_kernel(vs->sock->sk);
+			kfree(vs);
+			rtnl_lock();
+		}
+		return err;
+	}
 
-	return err;
+	list_add(&vxlan->next, &vn->vxlan_list);
+	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+
+	return 0;
 }
 
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	hlist_del_rcu(&vxlan->hlist);
-
+	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
+
+	if (--vs->refcnt == 0) {
+		hlist_del_rcu(&vs->hlist);
+		schedule_work(&vs->del_work);
+	}
 }
 
 static size_t vxlan_get_size(const struct net_device *dev)
@@ -1572,46 +1712,12 @@ static struct rtnl_link_ops vxlan_link_o
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct sock *sk;
-	struct sockaddr_in vxlan_addr = {
-		.sin_family = AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_ANY),
-	};
-	int rc;
 	unsigned h;
 
-	/* Create UDP socket for encapsulation receive. */
-	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
-	if (rc < 0) {
-		pr_debug("UDP socket create failed\n");
-		return rc;
-	}
-	/* Put in proper namespace */
-	sk = vn->sock->sk;
-	sk_change_net(sk, net);
-
-	vxlan_addr.sin_port = htons(vxlan_port);
-
-	rc = kernel_bind(vn->sock, (struct sockaddr *) &vxlan_addr,
-			 sizeof(vxlan_addr));
-	if (rc < 0) {
-		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
-			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
-		sk_release_kernel(sk);
-		vn->sock = NULL;
-		return rc;
-	}
-
-	/* Disable multicast loopback */
-	inet_sk(sk)->mc_loop = 0;
+	INIT_LIST_HEAD(&vn->vxlan_list);
 
-	/* Mark socket as an encapsulation socket. */
-	udp_sk(sk)->encap_type = 1;
-	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-	udp_encap_enable();
-
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&vn->vni_list[h]);
+	for (h = 0; h < PORT_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&vn->sock_list[h]);
 
 	return 0;
 }
@@ -1620,18 +1726,11 @@ static __net_exit void vxlan_exit_net(st
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_dev *vxlan;
-	unsigned h;
 
 	rtnl_lock();
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		hlist_for_each_entry(vxlan, &vn->vni_list[h], hlist)
-			dev_close(vxlan->dev);
+	list_for_each_entry(vxlan, &vn->vxlan_list, next)
+		dev_close(vxlan->dev);
 	rtnl_unlock();
-
-	if (vn->sock) {
-		sk_release_kernel(vn->sock->sk);
-		vn->sock = NULL;
-	}
 }
 
 static struct pernet_operations vxlan_net_ops = {
