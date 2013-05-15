From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFT] vxlan: listen on multiple ports
Date: Wed, 15 May 2013 14:37:02 -0700
Message-ID: <20130515143702.38730c3d@nehalam.linuxnetplumber.net>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
	<20130515104825.5cbeaee3@nehalam.linuxnetplumber.net>
	<OF1177AC77.13B8F09E-ON85257B6C.0064777A-85257B6C.0066B974@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45220 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab3EOVhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:37:07 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj3so1894252pad.15
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 14:37:06 -0700 (PDT)
In-Reply-To: <OF1177AC77.13B8F09E-ON85257B6C.0064777A-85257B6C.0066B974@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The earlier change to introduce per-vxlan UDP port configuration did only
half the necessary work. It added per vxlan destination for sending, but
overlooked the handling of multiple ports for incoming, which means it
is broken.

This patch changes the listening port management to handle multiple
incoming UDP ports. The earlier per-namespace structure is now a hash
list per namespace.

It is also now possible to define the same virtual network id
but with different UDP port values.

A lot of the change is cosmetic like renaming vxlan_net to vxlan_sock,
and changing standard local variable from vn to vs.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Compiles and creates/deletes vxlans and creates/deletes sockets,
but still needs more testing before going to -net

--- a/drivers/net/vxlan.c	2013-05-02 14:30:52.230572667 -0700
+++ b/drivers/net/vxlan.c	2013-05-15 14:31:54.633656522 -0700
@@ -42,8 +42,10 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
-#define VXLAN_VERSION	"0.1"
+#define VXLAN_VERSION	"0.2"
 
+#define PORT_HASH_BITS	8
+#define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 #define FDB_HASH_BITS	8
@@ -76,13 +78,22 @@ static bool log_ecn_error = true;
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
+	unsigned int	  refcnt;
+	struct socket	  *sock;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 };
 
+/* per-network namespace private data for this module */
+struct vxlan_net {
+	struct hlist_head sock_list[PORT_HASH_SIZE];
+};
+
 struct vxlan_rdst {
 	struct rcu_head		 rcu;
 	__be32			 remote_ip;
@@ -107,6 +118,7 @@ struct vxlan_fdb {
 /* Pseudo network device */
 struct vxlan_dev {
 	struct hlist_node hlist;
+	struct vxlan_sock *vn_sock;
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
 	__be32		  saddr;	/* source address */
@@ -135,19 +147,41 @@ struct vxlan_dev {
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 
-static inline struct hlist_head *vni_head(struct net *net, u32 id)
+static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
+{
+	return &vs->vni_list[hash_32(id, VNI_HASH_BITS)];
+}
+
+static inline struct hlist_head *vs_head(struct net *net, __be16 port)
+{
+	struct vxlan_net *vns = net_generic(net, vxlan_net_id);
+
+	return &vns->sock_list[hash_32(ntohs(port), PORT_HASH_BITS];
+}
+
+/* Look up a VXLAN net based on network namespace and UDP port */
+static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_sock *vs;
 
-	return &vn->vni_list[hash_32(id, VNI_HASH_BITS)];
+	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
+		if (inet_sk(vs->sock->sk)->inet_dport == port)
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
@@ -589,14 +623,14 @@ static void vxlan_snoop(struct net_devic
 
 
 /* See if multicast group is already in use by other ID */
-static bool vxlan_group_used(struct vxlan_net *vn,
+static bool vxlan_group_used(struct vxlan_sock *vs,
 			     const struct vxlan_dev *this)
 {
 	const struct vxlan_dev *vxlan;
 	unsigned h;
 
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		hlist_for_each_entry(vxlan, &vn->vni_list[h], hlist) {
+		hlist_for_each_entry(vxlan, &vs->vni_list[h], hlist) {
 			if (vxlan == this)
 				continue;
 
@@ -614,8 +648,8 @@ static bool vxlan_group_used(struct vxla
 static int vxlan_join_group(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vn->sock->sk;
+	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct sock *sk = vs->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
@@ -623,7 +657,7 @@ static int vxlan_join_group(struct net_d
 	int err;
 
 	/* Already a member of group */
-	if (vxlan_group_used(vn, vxlan))
+	if (vxlan_group_used(vs, vxlan))
 		return 0;
 
 	/* Need to drop RTNL to call multicast join */
@@ -641,16 +675,16 @@ static int vxlan_join_group(struct net_d
 static int vxlan_leave_group(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct vxlan_sock *vs = vxlan->vn_sock;
 	int err = 0;
-	struct sock *sk = vn->sock->sk;
+	struct sock *sk = vs->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
 	};
 
 	/* Only leave group when last vxlan is done. */
-	if (vxlan_group_used(vn, vxlan))
+	if (vxlan_group_used(vs, vxlan))
 		return 0;
 
 	/* Need to drop RTNL to call multicast leave */
@@ -693,7 +727,8 @@ static int vxlan_udp_encap_recv(struct s
 
 	/* Is this VNI defined? */
 	vni = ntohl(vxh->vx_vni) >> 8;
-	vxlan = vxlan_find_vni(sock_net(sk), vni);
+	vxlan = vxlan_find_vni(sock_net(skb->sk), vni,
+			       inet_sk(sk)->inet_dport);
 	if (!vxlan) {
 		netdev_dbg(skb->dev, "unknown vni %d\n", vni);
 		goto drop;
@@ -883,8 +918,8 @@ static void vxlan_sock_free(struct sk_bu
 /* On transmit, associate with the tunnel socket */
 static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
 {
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vn->sock->sk;
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct sock *sk = vxlan->vn_sock->sock->sk;
 
 	skb_orphan(skb);
 	sock_hold(sk);
@@ -1031,7 +1066,7 @@ static netdev_tx_t vxlan_xmit_one(struct
 		struct vxlan_dev *dst_vxlan;
 
 		ip_rt_put(rt);
-		dst_vxlan = vxlan_find_vni(dev_net(dev), vni);
+		dst_vxlan = vxlan_find_vni(dev_net(dev), vni, dst_port);
 		if (!dst_vxlan)
 			goto tx_error;
 		vxlan_encap_bypass(skb, vxlan, dst_vxlan);
@@ -1390,11 +1425,77 @@ static const struct ethtool_ops vxlan_et
 	.get_link	= ethtool_op_get_link,
 };
 
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
+static void vxlan_socket_destroy(struct vxlan_sock *vs)
+{
+	ASSERT_RTNL();
+
+	hlist_del_rcu(&vs->hlist);
+
+	sk_release_kernel(vs->sock->sk);
+	kfree_rcu(vs, rcu);
+}
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
+	struct vxlan_sock *vs;
 	__u32 vni;
 	int err;
 
@@ -1402,10 +1503,6 @@ static int vxlan_newlink(struct net *net
 		return -EINVAL;
 
 	vni = nla_get_u32(data[IFLA_VXLAN_ID]);
-	if (vxlan_find_vni(net, vni)) {
-		pr_info("duplicate VNI %u\n", vni);
-		return -EEXIST;
-	}
 	dst->remote_vni = vni;
 
 	if (data[IFLA_VXLAN_GROUP])
@@ -1471,22 +1568,48 @@ static int vxlan_newlink(struct net *net
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
+		rtnl_unlock();
+		vs = vxlan_socket_create(net, vxlan->dst_port);
+		rtnl_lock();
+		if (IS_ERR(vs))
+			return PTR_ERR(vs);
+		hlist_add_head_rcu(&vs->hlist, vs_head(net, vxlan->dst_port));
+	}
+	vxlan->vn_sock = vs;
+
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
 	err = register_netdevice(dev);
-	if (!err)
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(net, dst->remote_vni));
+	if (err) {
+		if (--vs->refcnt == 0)
+			vxlan_socket_destroy(vs);
+		return err;
+	}
 
-	return err;
+	hlist_add_head_rcu(&vxlan->hlist,vni_head(vs, vni));
+
+	return 0;
 }
 
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	hlist_del_rcu(&vxlan->hlist);
-
 	unregister_netdevice_queue(dev, head);
+
+	if (--vs->refcnt == 0)
+		vxlan_socket_destroy(vs);
 }
 
 static size_t vxlan_get_size(const struct net_device *dev)
@@ -1571,67 +1694,31 @@ static struct rtnl_link_ops vxlan_link_o
 
 static __net_init int vxlan_init_net(struct net *net)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct sock *sk;
-	struct sockaddr_in vxlan_addr = {
-		.sin_family = AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_ANY),
-	};
-	int rc;
+	struct vxlan_net *vns = net_generic(net, vxlan_net_id);
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
-
-	/* Mark socket as an encapsulation socket. */
-	udp_sk(sk)->encap_type = 1;
-	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-	udp_encap_enable();
-
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&vn->vni_list[h]);
+	for (h = 0; h < PORT_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&vns->sock_list[h]);
 
 	return 0;
 }
 
 static __net_exit void vxlan_exit_net(struct net *net)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_net *vns = net_generic(net, vxlan_net_id);
+	struct vxlan_sock *vs;
 	struct vxlan_dev *vxlan;
-	unsigned h;
+	unsigned n, h;
 
 	rtnl_lock();
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		hlist_for_each_entry(vxlan, &vn->vni_list[h], hlist)
-			dev_close(vxlan->dev);
+	for (n = 0; n < PORT_HASH_SIZE; ++n)
+		hlist_for_each_entry(vs, &vns->sock_list[n], hlist) {
+			for (h = 0; h < VNI_HASH_SIZE; ++h)
+				hlist_for_each_entry(vxlan, &vs->vni_list[h],
+						     hlist)
+					dev_close(vxlan->dev);
+		}
 	rtnl_unlock();
-
-	if (vn->sock) {
-		sk_release_kernel(vn->sock->sk);
-		vn->sock = NULL;
-	}
 }
 
 static struct pernet_operations vxlan_net_ops = {
