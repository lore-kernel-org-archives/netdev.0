From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 05/12] vxlan: fix race caused by dropping
 rtnl_unlock
Date: Mon, 10 Jun 2013 13:24:50 -0700
Message-ID: <20130610132450.7ff7236a@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:52045 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab3FJUZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:57 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1690670pdi.27
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:57 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for two cpu's to race creating vxlan device.
For most cases this is harmless, but the ability to assign "next
avaliable vxlan device" relies on rtnl lock being held across the
whole operation. Therfore two instances of calling:
  ip li add vxlan%d vxlan ...
could collide and create two devices with same name.

To fix this defer creation of socket to a work queue, and
handle possible races there. Introduce a lock to ensure that
changes to vxlan socket hash list is SMP safe.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-06-10 12:19:59.002097934 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:19:59.522092022 -0700
@@ -94,6 +94,7 @@ struct vxlan_sock {
 struct vxlan_net {
 	struct list_head  vxlan_list;
 	struct hlist_head sock_list[PORT_HASH_SIZE];
+	spinlock_t	  sock_lock;
 };
 
 struct vxlan_rdst {
@@ -131,7 +132,9 @@ struct vxlan_dev {
 	__u8		  ttl;
 	u32		  flags;	/* VXLAN_F_* below */
 
+	struct work_struct sock_work;
 	struct work_struct igmp_work;
+
 	unsigned long	  age_interval;
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
@@ -151,6 +154,8 @@ struct vxlan_dev {
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
+static void vxlan_sock_work(struct work_struct *work);
+
 /* Virtual Network hash table head */
 static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
 {
@@ -670,12 +675,15 @@ static void vxlan_sock_hold(struct vxlan
 	atomic_inc(&vs->refcnt);
 }
 
-static void vxlan_sock_release(struct vxlan_sock *vs)
+static void vxlan_sock_release(struct vxlan_net *vn, struct vxlan_sock *vs)
 {
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
+	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
+	spin_unlock(&vn->sock_lock);
+
 	queue_work(vxlan_wq, &vs->del_work);
 }
 
@@ -700,7 +708,7 @@ static void vxlan_igmp_work(struct work_
 		ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 
-	vxlan_sock_release(vs);
+	vxlan_sock_release(vn, vs);
 	dev_put(vxlan->dev);
 }
 
@@ -1238,10 +1246,29 @@ static void vxlan_cleanup(unsigned long
 /* Setup stats when device is created */
 static int vxlan_init(struct net_device *dev)
 {
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct vxlan_sock *vs;
+	__u32 vni = vxlan->default_dst.remote_vni;
+
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	spin_lock(&vn->sock_lock);
+	vs = vxlan_find_port(dev_net(dev), vxlan->dst_port);
+	if (vs) {
+		/* If we have a socket with same port already, reuse it */
+		atomic_inc(&vs->refcnt);
+		vxlan->vn_sock = vs;
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+	} else {
+		/* otherwise make new socket outside of RTNL */
+		dev_hold(dev);
+		queue_work(vxlan_wq, &vxlan->sock_work);
+	}
+	spin_unlock(&vn->sock_lock);
+
 	return 0;
 }
 
@@ -1249,9 +1276,14 @@ static int vxlan_init(struct net_device
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_sock *vs = vxlan->vn_sock;
+
+	/* socket hasn't been created */
+	if (!vs)
+		return -ENOTCONN;
 
 	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
-		vxlan_sock_hold(vxlan->vn_sock);
+		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_work);
 	}
@@ -1283,9 +1315,10 @@ static void vxlan_flush(struct vxlan_dev
 static int vxlan_stop(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_sock *vs = vxlan->vn_sock;
 
-	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
-		vxlan_sock_hold(vxlan->vn_sock);
+	if (vs && IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
+		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_work);
 	}
@@ -1358,6 +1391,7 @@ static void vxlan_setup(struct net_devic
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
 	INIT_WORK(&vxlan->igmp_work, vxlan_igmp_work);
+	INIT_WORK(&vxlan->sock_work, vxlan_sock_work);
 
 	init_timer_deferrable(&vxlan->age_timer);
 	vxlan->age_timer.function = vxlan_cleanup;
@@ -1449,7 +1483,6 @@ static void vxlan_del_work(struct work_s
 	kfree_rcu(vs, rcu);
 }
 
-/* Create new listen socket if needed */
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 {
 	struct vxlan_sock *vs;
@@ -1506,13 +1539,52 @@ static struct vxlan_sock *vxlan_socket_c
 	return vs;
 }
 
+/* Scheduled at device creation to bind to a socket */
+static void vxlan_sock_work(struct work_struct *work)
+{
+	struct vxlan_dev *vxlan
+		= container_of(work, struct vxlan_dev, sock_work);
+	struct net_device *dev = vxlan->dev;
+	struct net *net = dev_net(dev);
+	__u32 vni = vxlan->default_dst.remote_vni;
+	__be16 port = vxlan->dst_port;
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_sock *nvs, *ovs;
+
+	nvs = vxlan_socket_create(net, port);
+	if (IS_ERR(nvs)) {
+		netdev_err(vxlan->dev, "Can not create UDP socket, %ld\n",
+			   PTR_ERR(nvs));
+		goto out;
+	}
+
+	spin_lock(&vn->sock_lock);
+	/* Look again to see if can reuse socket */
+	ovs = vxlan_find_port(net, port);
+	if (ovs) {
+		atomic_inc(&ovs->refcnt);
+		vxlan->vn_sock = ovs;
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(ovs, vni));
+		spin_unlock(&vn->sock_lock);
+
+		sk_release_kernel(nvs->sock->sk);
+		kfree(nvs);
+	} else {
+		vxlan->vn_sock = nvs;
+		hlist_add_head_rcu(&nvs->hlist, vs_head(net, port));
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
+		spin_unlock(&vn->sock_lock);
+	}
+out:
+	dev_put(dev);
+}
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
-	struct vxlan_sock *vs;
 	__u32 vni;
 	int err;
 
@@ -1590,31 +1662,13 @@ static int vxlan_newlink(struct net *net
 		return -EEXIST;
 	}
 
-	vs = vxlan_find_port(net, vxlan->dst_port);
-	if (vs)
-		atomic_inc(&vs->refcnt);
-	else {
-		/* Drop lock because socket create acquires RTNL lock */
-		rtnl_unlock();
-		vs = vxlan_socket_create(net, vxlan->dst_port);
-		rtnl_lock();
-		if (IS_ERR(vs))
-			return PTR_ERR(vs);
-
-		hlist_add_head_rcu(&vs->hlist, vs_head(net, vxlan->dst_port));
-	}
-	vxlan->vn_sock = vs;
-
 	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
 
 	err = register_netdevice(dev);
-	if (err) {
-		vxlan_sock_release(vs);
+	if (err)
 		return err;
-	}
 
 	list_add(&vxlan->next, &vn->vxlan_list);
-	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
 
 	return 0;
 }
@@ -1622,12 +1676,14 @@ static int vxlan_newlink(struct net *net
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	hlist_del_rcu(&vxlan->hlist);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
-	vxlan_sock_release(vs);
+	if (vs)
+		vxlan_sock_release(vn, vs);
 }
 
 static size_t vxlan_get_size(const struct net_device *dev)
@@ -1716,6 +1772,7 @@ static __net_init int vxlan_init_net(str
 	unsigned int h;
 
 	INIT_LIST_HEAD(&vn->vxlan_list);
+	spin_lock_init(&vn->sock_lock);
 
 	for (h = 0; h < PORT_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vn->sock_list[h]);
