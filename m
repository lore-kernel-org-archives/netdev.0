From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 03/10] vxlan: move IGMP join/leave to work queue
Date: Tue,  4 Jun 2013 21:24:07 -0700
Message-ID: <1370406254-6341-3-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33225 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab3FEEYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:23 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so252329pdc.19
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:22 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do join/leave from work queue to avoid lock inversion problems
between normal socket and RTNL. The code comes out cleaner
as well.

Uses Cong Wang's suggestion to turn refcnt into a real atomic
since now need to handle case where last use of socket is IGMP
worker.

Also fixes race where vxlan_stop could be called after
device was deleted on module removal. The call to rtnl_link_unregister
would call dellink while vxlan device was still up. Reordering
the calls fixes it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
The last change probably needs a separate patch for -stable
---
 drivers/net/vxlan.c |  105 ++++++++++++++++++++-------------------------------
 1 file changed, 41 insertions(+), 64 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9085c81..f98f459 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -85,7 +85,7 @@ struct vxlan_sock {
 	struct hlist_node hlist;
 	struct rcu_head	  rcu;
 	struct work_struct del_work;
-	unsigned int	  refcnt;
+	atomic_t	  refcnt;
 	struct socket	  *sock;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 };
@@ -131,6 +131,7 @@ struct vxlan_dev {
 	__u8		  ttl;
 	u32		  flags;	/* VXLAN_F_* below */
 
+	struct work_struct igmp_work;
 	unsigned long	  age_interval;
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
@@ -644,76 +645,58 @@ static int vxlan_snoop(struct net_device *dev,
 
 
 /* See if multicast group is already in use by other ID */
-static bool vxlan_group_used(struct vxlan_net *vn,
-			     const struct vxlan_dev *this)
+static bool vxlan_group_used(struct vxlan_net *vn, __be32 remote_ip)
 {
 	struct vxlan_dev *vxlan;
 
 	list_for_each_entry(vxlan, &vn->vxlan_list, next) {
-		if (vxlan == this)
-			continue;
-
 		if (!netif_running(vxlan->dev))
 			continue;
 
-		if (vxlan->default_dst.remote_ip == this->default_dst.remote_ip)
+		if (vxlan->default_dst.remote_ip == remote_ip)
 			return true;
 	}
 
 	return false;
 }
 
-/* kernel equivalent to IP_ADD_MEMBERSHIP */
-static int vxlan_join_group(struct net_device *dev)
+static void vxlan_sock_hold(struct vxlan_sock *vs)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct sock *sk = vxlan->vn_sock->sock->sk;
-	struct ip_mreqn mreq = {
-		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
-		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
-	};
-	int err;
-
-	/* Already a member of group */
-	if (vxlan_group_used(vn, vxlan))
-		return 0;
+	atomic_inc(&vs->refcnt);
+}
 
-	/* Need to drop RTNL to call multicast join */
-	rtnl_unlock();
-	lock_sock(sk);
-	err = ip_mc_join_group(sk, &mreq);
-	release_sock(sk);
-	rtnl_lock();
+static void vxlan_sock_release(struct vxlan_sock *vs)
+{
+	if (!atomic_dec_and_test(&vs->refcnt))
+		return;
 
-	return err;
+	hlist_del_rcu(&vs->hlist);
+	schedule_work(&vs->del_work);
 }
 
-
-/* kernel equivalent to IP_DROP_MEMBERSHIP */
-static int vxlan_leave_group(struct net_device *dev)
+/* Callback to update multicast group membership.
+ * Scheduled when vxlan goes up/down.
+ */
+static void vxlan_igmp_work(struct work_struct *work)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	int err = 0;
-	struct sock *sk = vxlan->vn_sock->sock->sk;
+	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_work);
+	struct vxlan_net *vn = net_generic(dev_net(vxlan->dev), vxlan_net_id);
+	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct sock *sk = vs->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
 	};
 
-	/* Only leave group when last vxlan is done. */
-	if (vxlan_group_used(vn, vxlan))
-		return 0;
-
-	/* Need to drop RTNL to call multicast leave */
-	rtnl_unlock();
 	lock_sock(sk);
-	err = ip_mc_leave_group(sk, &mreq);
+	if (vxlan_group_used(vn, vxlan->default_dst.remote_ip))
+		ip_mc_join_group(sk, &mreq);
+	else
+		ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
-	rtnl_lock();
 
-	return err;
+	vxlan_sock_release(vs);
+	dev_put(vxlan->dev);
 }
 
 /* Callback from net/ipv4/udp.c to receive packets */
@@ -1261,12 +1244,11 @@ static int vxlan_init(struct net_device *dev)
 static int vxlan_open(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	int err;
 
 	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
-		err = vxlan_join_group(dev);
-		if (err)
-			return err;
+		vxlan_sock_hold(vxlan->vn_sock);
+		dev_hold(dev);
+		schedule_work(&vxlan->igmp_work);
 	}
 
 	if (vxlan->age_interval)
@@ -1297,8 +1279,11 @@ static int vxlan_stop(struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 
-	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)))
-		vxlan_leave_group(dev);
+	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
+		vxlan_sock_hold(vxlan->vn_sock);
+		dev_hold(dev);
+		schedule_work(&vxlan->igmp_work);
+	}
 
 	del_timer_sync(&vxlan->age_timer);
 
@@ -1367,6 +1352,7 @@ static void vxlan_setup(struct net_device *dev)
 
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
+	INIT_WORK(&vxlan->igmp_work, vxlan_igmp_work);
 
 	init_timer_deferrable(&vxlan->age_timer);
 	vxlan->age_timer.function = vxlan_cleanup;
@@ -1510,8 +1496,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port)
 	udp_sk(sk)->encap_type = 1;
 	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
 	udp_encap_enable();
+	atomic_set(&vs->refcnt, 1);
 
-	vs->refcnt = 1;
 	return vs;
 }
 
@@ -1601,7 +1587,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 
 	vs = vxlan_find_port(net, vxlan->dst_port);
 	if (vs)
-		++vs->refcnt;
+		atomic_inc(&vs->refcnt);
 	else {
 		/* Drop lock because socket create acquires RTNL lock */
 		rtnl_unlock();
@@ -1618,12 +1604,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 
 	err = register_netdevice(dev);
 	if (err) {
-		if (--vs->refcnt == 0) {
-			rtnl_unlock();
-			sk_release_kernel(vs->sock->sk);
-			kfree(vs);
-			rtnl_lock();
-		}
+		vxlan_sock_release(vs);
 		return err;
 	}
 
@@ -1641,11 +1622,7 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	hlist_del_rcu(&vxlan->hlist);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
-
-	if (--vs->refcnt == 0) {
-		hlist_del_rcu(&vs->hlist);
-		schedule_work(&vs->del_work);
-	}
+	vxlan_sock_release(vs);
 }
 
 static size_t vxlan_get_size(const struct net_device *dev)
@@ -1784,8 +1761,8 @@ late_initcall(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_pernet_device(&vxlan_net_ops);
+	rtnl_link_unregister(&vxlan_link_ops);
 	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
-- 
1.7.10.4
