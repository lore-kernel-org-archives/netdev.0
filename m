From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v6 1/8] vxlan: Restructure vxlan socket apis.
Date: Thu,  1 Aug 2013 11:44:40 -0700
Message-ID: <1375382680-3137-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:38280 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752563Ab3HASon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 14:44:43 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so2333510pdj.35
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 11:44:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restructure vxlan-socket management APIs so that it can be
shared between ovs.
This patch does not change any functionality.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   94 +++++++++++++++++++++++++++------------------------
 1 files changed, 50 insertions(+), 44 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f401c1a..548294a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -182,7 +182,7 @@ static inline struct vxlan_rdst *first_remote(struct vxlan_fdb *fdb)
 }
 
 /* Find VXLAN socket based on network namespace and UDP port */
-static struct vxlan_sock *vxlan_find_port(struct net *net, __be16 port)
+static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 {
 	struct vxlan_sock *vs;
 
@@ -199,7 +199,7 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
 	struct vxlan_sock *vs;
 	struct vxlan_dev *vxlan;
 
-	vs = vxlan_find_port(net, port);
+	vs = vxlan_find_sock(net, port);
 	if (!vs)
 		return NULL;
 
@@ -1341,25 +1341,31 @@ static void vxlan_cleanup(unsigned long arg)
 	mod_timer(&vxlan->age_timer, next_timer);
 }
 
+static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
+{
+	__u32 vni = vxlan->default_dst.remote_vni;
+
+	vxlan->vn_sock = vs;
+	hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+}
+
 /* Setup stats when device is created */
 static int vxlan_init(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_sock *vs;
-	__u32 vni = vxlan->default_dst.remote_vni;
 
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	spin_lock(&vn->sock_lock);
-	vs = vxlan_find_port(dev_net(dev), vxlan->dst_port);
+	vs = vxlan_find_sock(dev_net(dev), vxlan->dst_port);
 	if (vs) {
 		/* If we have a socket with same port already, reuse it */
 		atomic_inc(&vs->refcnt);
-		vxlan->vn_sock = vs;
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(vs, vni));
+		vxlan_vs_add_dev(vs, vxlan);
 	} else {
 		/* otherwise make new socket outside of RTNL */
 		dev_hold(dev);
@@ -1602,8 +1608,9 @@ static void vxlan_del_work(struct work_struct *work)
 	kfree_rcu(vs, rcu);
 }
 
-static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
+static void vxlan_socket_create(struct net *net, __be16 port)
 {
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	struct sock *sk;
 	struct sockaddr_in vxlan_addr = {
@@ -1615,8 +1622,10 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	unsigned int h;
 
 	vs = kmalloc(sizeof(*vs), GFP_KERNEL);
-	if (!vs)
-		return ERR_PTR(-ENOMEM);
+	if (!vs) {
+		pr_debug("memory alocation failure\n");
+		return;
+	}
 
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vs->vni_list[h]);
@@ -1628,7 +1637,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	if (rc < 0) {
 		pr_debug("UDP socket create failed\n");
 		kfree(vs);
-		return ERR_PTR(rc);
+		return;
 	}
 
 	/* Put in proper namespace */
@@ -1642,59 +1651,56 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
 		sk_release_kernel(sk);
 		kfree(vs);
-		return ERR_PTR(rc);
+		return;
 	}
+	atomic_set(&vs->refcnt, 0);
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
+	spin_lock(&vn->sock_lock);
+	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
+	spin_unlock(&vn->sock_lock);
 
 	/* Mark socket as an encapsulation socket. */
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
 	udp_encap_enable();
-	atomic_set(&vs->refcnt, 1);
+}
+
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port)
+{
+	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
+	struct vxlan_sock *vs;
+
+	vxlan_socket_create(net, port);
 
+	spin_lock(&vn->sock_lock);
+	vs = vxlan_find_sock(net, port);
+	if (vs)
+		atomic_inc(&vs->refcnt);
+	else
+		vs = ERR_PTR(-EINVAL);
+
+	spin_unlock(&vn->sock_lock);
 	return vs;
 }
 
 /* Scheduled at device creation to bind to a socket */
 static void vxlan_sock_work(struct work_struct *work)
 {
-	struct vxlan_dev *vxlan
-		= container_of(work, struct vxlan_dev, sock_work);
-	struct net_device *dev = vxlan->dev;
-	struct net *net = dev_net(dev);
-	__u32 vni = vxlan->default_dst.remote_vni;
-	__be16 port = vxlan->dst_port;
+	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, sock_work);
+	struct net *net = dev_net(vxlan->dev);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_sock *nvs, *ovs;
-
-	nvs = vxlan_socket_create(net, port);
-	if (IS_ERR(nvs)) {
-		netdev_err(vxlan->dev, "Can not create UDP socket, %ld\n",
-			   PTR_ERR(nvs));
-		goto out;
-	}
+	__be16 port = vxlan->dst_port;
+	struct vxlan_sock *nvs;
 
+	nvs = vxlan_sock_add(net, port);
 	spin_lock(&vn->sock_lock);
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
-	} else {
-		vxlan->vn_sock = nvs;
-		hlist_add_head_rcu(&nvs->hlist, vs_head(net, port));
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
-		spin_unlock(&vn->sock_lock);
-	}
-out:
-	dev_put(dev);
+	if (!IS_ERR(nvs))
+		vxlan_vs_add_dev(nvs, vxlan);
+	spin_unlock(&vn->sock_lock);
+
+	dev_put(vxlan->dev);
 }
 
 static int vxlan_newlink(struct net *net, struct net_device *dev,
-- 
1.7.1
