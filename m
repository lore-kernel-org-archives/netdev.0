From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 1/7] vxlan: Add vxlan_handler.
Date: Fri, 26 Jul 2013 16:14:48 -0700
Message-ID: <1374880488-2884-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:37470 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757690Ab3GZXOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 19:14:51 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so3396162pdi.2
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 16:14:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan and openvswitch modules needs to share port. Following
patch breaks down vxlan per port abstraction in two component.
So now vxlan_sock is broken into struct vxlan_sock handles socket
and vxlan_handler which handler for user of vxlan protocol.

Next commit will extend vxlan_handler for openvswitch.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v3-v4:
 - split vxlan handler part from vxlan rcv function changes.

v1-v2:
 - update patch against vxlan tree.
---
 drivers/net/vxlan.c |  237 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 146 insertions(+), 91 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f401c1a..0bbe2d2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -86,17 +86,29 @@ static const u8 all_zeros_mac[ETH_ALEN];
 struct vxlan_sock {
 	struct hlist_node hlist;
 	struct rcu_head	  rcu;
-	struct work_struct del_work;
-	atomic_t	  refcnt;
 	struct socket	  *sock;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
+	struct list_head  handler_list;
+};
+
+struct vxlan_handler {
+	struct list_head   node;
+	struct vxlan_sock *vs;
+	atomic_t	   refcnt;
+	struct rcu_head    rcu;
+	struct work_struct del_work;
 };
 
+static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
+					    __be16 portno);
+static void vxlan_handler_hold(struct vxlan_handler *vh);
+static void vxlan_handler_put(struct vxlan_handler *vh);
+
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
 	struct hlist_head sock_list[PORT_HASH_SIZE];
-	spinlock_t	  sock_lock;
+	struct mutex	  sock_lock;	/* RTNL lock nests inside this lock. */
 };
 
 struct vxlan_rdst {
@@ -124,7 +136,7 @@ struct vxlan_fdb {
 struct vxlan_dev {
 	struct hlist_node hlist;	/* vni hash table */
 	struct list_head  next;		/* vxlan's per namespace list */
-	struct vxlan_sock *vn_sock;	/* listening socket */
+	struct vxlan_handler *vh;
 	struct net_device *dev;
 	struct vxlan_rdst default_dst;	/* default destination */
 	__be32		  saddr;	/* source address */
@@ -135,7 +147,7 @@ struct vxlan_dev {
 	__u8		  ttl;
 	u32		  flags;	/* VXLAN_F_* below */
 
-	struct work_struct sock_work;
+	struct work_struct handler_work;
 	struct work_struct igmp_work;
 
 	unsigned long	  age_interval;
@@ -157,7 +169,8 @@ struct vxlan_dev {
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
-static void vxlan_sock_work(struct work_struct *work);
+static void vxlan_handler_work(struct work_struct *work);
+static void vxlan_vh_add_dev(struct vxlan_handler *vh, struct vxlan_dev *vxlan);
 
 /* Virtual Network hash table head */
 static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
@@ -182,7 +195,7 @@ static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
 }
 
 /* Find VXLAN socket based on network namespace and UDP port */
-static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
+static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 {
 	struct vxlan_sock *vs;
 
@@ -199,7 +212,7 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
 	struct vxlan_sock *vs;
 	struct vxlan_dev *vxlan;
 
-	vs = vxlan_find_port(net, port);
+	vs = vxlan_find_sock(net, port);
 	if (!vs)
 		return NULL;
 
@@ -791,23 +804,6 @@ static bool vxlan_group_used(struct vxlan_net *vn, __be32 remote_ip)
 	return false;
 }
 
-static void vxlan_sock_hold(struct vxlan_sock *vs)
-{
-	atomic_inc(&vs->refcnt);
-}
-
-static void vxlan_sock_release(struct vxlan_net *vn, struct vxlan_sock *vs)
-{
-	if (!atomic_dec_and_test(&vs->refcnt))
-		return;
-
-	spin_lock(&vn->sock_lock);
-	hlist_del_rcu(&vs->hlist);
-	spin_unlock(&vn->sock_lock);
-
-	queue_work(vxlan_wq, &vs->del_work);
-}
-
 /* Callback to update multicast group membership.
  * Scheduled when vxlan goes up/down.
  */
@@ -815,8 +811,8 @@ static void vxlan_igmp_work(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_work);
 	struct vxlan_net *vn = net_generic(dev_net(vxlan->dev), vxlan_net_id);
-	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct vxlan_handler *vh = vxlan->vh;
+	struct sock *sk = vh->vs->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
@@ -829,7 +825,7 @@ static void vxlan_igmp_work(struct work_struct *work)
 		ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 
-	vxlan_sock_release(vn, vs);
+	vxlan_handler_put(vh);
 	dev_put(vxlan->dev);
 }
 
@@ -1058,7 +1054,7 @@ static void vxlan_sock_put(struct sk_buff *skb)
 static void vxlan_set_owner(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct sock *sk = vxlan->vn_sock->sock->sk;
+	struct sock *sk = vxlan->vh->vs->sock->sk;
 
 	skb_orphan(skb);
 	sock_hold(sk);
@@ -1347,25 +1343,25 @@ static int vxlan_init(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_sock *vs;
-	__u32 vni = vxlan->default_dst.remote_vni;
 
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_port(dev_net(dev), vxlan->dst_port);
+	mutex_lock(&vn->sock_lock);
+	vs = vxlan_find_sock(dev_net(dev), vxlan->dst_port);
 	if (vs) {
+		struct vxlan_handler *vh;
+
 		/* If we have a socket with same port already, reuse it */
-		atomic_inc(&vs->refcnt);
-		vxlan->vn_sock = vs;
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+		vh = vs_handler_add(vs, vxlan->dst_port);
+		vxlan_vh_add_dev(vh, vxlan);
 	} else {
 		/* otherwise make new socket outside of RTNL */
 		dev_hold(dev);
-		queue_work(vxlan_wq, &vxlan->sock_work);
+		queue_work(vxlan_wq, &vxlan->handler_work);
 	}
-	spin_unlock(&vn->sock_lock);
+	mutex_unlock(&vn->sock_lock);
 
 	return 0;
 }
@@ -1384,13 +1380,11 @@ static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan)
 static void vxlan_uninit(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct vxlan_handler *vh = vxlan->vh;
 
 	vxlan_fdb_delete_default(vxlan);
-
-	if (vs)
-		vxlan_sock_release(vn, vs);
+	if (vh)
+		vxlan_handler_put(vh);
 	free_percpu(dev->tstats);
 }
 
@@ -1398,14 +1392,14 @@ static void vxlan_uninit(struct net_device *dev)
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct vxlan_handler *vh = vxlan->vh;
 
 	/* socket hasn't been created */
-	if (!vs)
+	if (!vh)
 		return -ENOTCONN;
 
 	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
-		vxlan_sock_hold(vs);
+		vxlan_handler_hold(vh);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_work);
 	}
@@ -1439,10 +1433,10 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
 static int vxlan_stop(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct vxlan_handler *vh = vxlan->vh;
 
-	if (vs && IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
-		vxlan_sock_hold(vs);
+	if (vh && IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
+		vxlan_handler_hold(vh);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_work);
 	}
@@ -1510,7 +1504,7 @@ static void vxlan_setup(struct net_device *dev)
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
 	INIT_WORK(&vxlan->igmp_work, vxlan_igmp_work);
-	INIT_WORK(&vxlan->sock_work, vxlan_sock_work);
+	INIT_WORK(&vxlan->handler_work, vxlan_handler_work);
 
 	init_timer_deferrable(&vxlan->age_timer);
 	vxlan->age_timer.function = vxlan_cleanup;
@@ -1594,14 +1588,6 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
-static void vxlan_del_work(struct work_struct *work)
-{
-	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
-
-	sk_release_kernel(vs->sock->sk);
-	kfree_rcu(vs, rcu);
-}
-
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 {
 	struct vxlan_sock *vs;
@@ -1621,7 +1607,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vs->vni_list[h]);
 
-	INIT_WORK(&vs->del_work, vxlan_del_work);
 
 	/* Create UDP socket for encapsulation receive. */
 	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vs->sock);
@@ -1648,52 +1633,122 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
 
+	INIT_LIST_HEAD(&vs->handler_list);
+	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
+
 	/* Mark socket as an encapsulation socket. */
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
 	udp_encap_enable();
-	atomic_set(&vs->refcnt, 1);
 
 	return vs;
 }
 
-/* Scheduled at device creation to bind to a socket */
-static void vxlan_sock_work(struct work_struct *work)
+static void vxlan_socket_del(struct vxlan_sock *vs)
 {
-	struct vxlan_dev *vxlan
-		= container_of(work, struct vxlan_dev, sock_work);
-	struct net_device *dev = vxlan->dev;
-	struct net *net = dev_net(dev);
-	__u32 vni = vxlan->default_dst.remote_vni;
-	__be16 port = vxlan->dst_port;
+	if (list_empty(&vs->handler_list)) {
+		hlist_del_rcu(&vs->hlist);
+
+		sk_release_kernel(vs->sock->sk);
+		kfree_rcu(vs, rcu);
+	}
+}
+
+static void vh_del_work(struct work_struct *work)
+{
+	struct vxlan_handler *vh = container_of(work, struct vxlan_handler, del_work);
+	struct vxlan_sock *vs = vh->vs;
+	struct net *net = sock_net(vs->sock->sk);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_sock *nvs, *ovs;
 
-	nvs = vxlan_socket_create(net, port);
-	if (IS_ERR(nvs)) {
-		netdev_err(vxlan->dev, "Can not create UDP socket, %ld\n",
-			   PTR_ERR(nvs));
+	mutex_lock(&vn->sock_lock);
+
+	list_del_rcu(&vh->node);
+	kfree_rcu(vh, rcu);
+	vxlan_socket_del(vs);
+
+	mutex_unlock(&vn->sock_lock);
+}
+
+static struct vxlan_handler *vs_handler_add(struct vxlan_sock *vs,
+					    __be16 portno)
+{
+	struct vxlan_handler *vh;
+
+	vh = kzalloc(sizeof(*vh), GFP_KERNEL);
+	if (!vh) {
+		vxlan_socket_del(vs);
+		return ERR_PTR(-ENOMEM);
+	}
+	vh->vs = vs;
+	atomic_set(&vh->refcnt, 1);
+	INIT_WORK(&vh->del_work, vh_del_work);
+
+	list_add_rcu(&vh->node, &vs->handler_list);
+	return vh;
+}
+
+static struct vxlan_handler *vxlan_handler_add(struct net *net, __be16 portno)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_handler *vh;
+	struct vxlan_sock *vs;
+
+	/* Create socket but ignore errors so that existing socket
+	 * can be searched. */
+	vs = vxlan_socket_create(net, portno);
+
+	mutex_lock(&vn->sock_lock);
+	if (IS_ERR(vs))
+		vs = vxlan_find_sock(net, portno);
+	if (!vs) {
+		vh = ERR_PTR(-ENOENT);
 		goto out;
 	}
+	vh = vs_handler_add(vs, portno);
+
+out:
+	mutex_unlock(&vn->sock_lock);
+	return vh;
+}
+
+static void vxlan_handler_hold(struct vxlan_handler *vh)
+{
+	atomic_inc(&vh->refcnt);
+}
 
-	spin_lock(&vn->sock_lock);
-	/* Look again to see if can reuse socket */
-	ovs = vxlan_find_port(net, port);
-	if (ovs) {
-		atomic_inc(&ovs->refcnt);
-		vxlan->vn_sock = ovs;
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(ovs, vni));
-		spin_unlock(&vn->sock_lock);
-
-		sk_release_kernel(nvs->sock->sk);
-		kfree(nvs);
+static void vxlan_handler_put(struct vxlan_handler *vh)
+{
+	BUG_ON(!vh->vs);
+
+	if (atomic_dec_and_test(&vh->refcnt))
+		queue_work(vxlan_wq, &vh->del_work);
+}
+
+static void vxlan_vh_add_dev(struct vxlan_handler *vh, struct vxlan_dev *vxlan)
+{
+	if (IS_ERR(vh)) {
+		netdev_err(vxlan->dev, "Can not create UDP socket, %ld\n",
+				PTR_ERR(vh));
 	} else {
-		vxlan->vn_sock = nvs;
-		hlist_add_head_rcu(&nvs->hlist, vs_head(net, port));
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
-		spin_unlock(&vn->sock_lock);
+		__u32 vni = vxlan->default_dst.remote_vni;
+
+		vxlan->vh = vh;
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(vh->vs, vni));
 	}
-out:
+}
+
+/* Scheduled at device creation to bind to a socket */
+static void vxlan_handler_work(struct work_struct *work)
+{
+	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, handler_work);
+	struct net_device *dev = vxlan->dev;
+	struct net *net = dev_net(dev);
+	__be16 port = vxlan->dst_port;
+	struct vxlan_handler *vh = NULL;
+
+	vh = vxlan_handler_add(net, port);
+	vxlan_vh_add_dev(vh, vxlan);
 	dev_put(dev);
 }
 
@@ -1810,9 +1865,9 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 
 	flush_workqueue(vxlan_wq);
 
-	spin_lock(&vn->sock_lock);
+	mutex_lock(&vn->sock_lock);
 	hlist_del_rcu(&vxlan->hlist);
-	spin_unlock(&vn->sock_lock);
+	mutex_unlock(&vn->sock_lock);
 
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
@@ -1904,7 +1959,7 @@ static __net_init int vxlan_init_net(struct net *net)
 	unsigned int h;
 
 	INIT_LIST_HEAD(&vn->vxlan_list);
-	spin_lock_init(&vn->sock_lock);
+	mutex_init(&vn->sock_lock);
 
 	for (h = 0; h < PORT_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vn->sock_list[h]);
-- 
1.7.1
