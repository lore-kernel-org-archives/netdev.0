From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] vxlan: synchronously and race-free destruction of vxlan sockets
Date: Thu,  7 Apr 2016 16:57:40 +0200
Message-ID: <1460041060-8619-1-git-send-email-hannes@stressinduktion.org>
Cc: Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45375 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752991AbcDGO5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:57:47 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 7481320DD0
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 10:57:46 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the fact that the udp socket is destructed asynchronously in a
work queue, we have some nondeterministic behavior during shutdown of
vxlan tunnels and creating new ones. Fix this by keeping the destruction
process synchronous in regards to the user space process so IFF_UP can
be reliably set.

udp_tunnel_sock_release destroys vs->sock->sk if reference counter
indicates so. We expect to have the same lifetime of vxlan_sock and
vxlan_sock->sock->sk even in fast paths with only rcu locks held. So
only destruct the whole socket after we can be sure it cannot be found
by searching vxlan_net->sock_list.

Cc: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c | 20 +++-----------------
 include/net/vxlan.h |  2 --
 2 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1c0fa364323e28..487e48b7a53090 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -98,7 +98,6 @@ struct vxlan_fdb {
 
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
-static struct workqueue_struct *vxlan_wq;
 
 static inline bool vxlan_collect_metadata(struct vxlan_sock *vs)
 {
@@ -1065,7 +1064,9 @@ static void __vxlan_sock_release(struct vxlan_sock *vs)
 	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
-	queue_work(vxlan_wq, &vs->del_work);
+	synchronize_rcu();
+	udp_tunnel_sock_release(vs->sock);
+	kfree(vs);
 }
 
 static void vxlan_sock_release(struct vxlan_dev *vxlan)
@@ -2574,13 +2575,6 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
-static void vxlan_del_work(struct work_struct *work)
-{
-	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
-	udp_tunnel_sock_release(vs->sock);
-	kfree_rcu(vs, rcu);
-}
-
 static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 					__be16 port, u32 flags)
 {
@@ -2626,8 +2620,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vs->vni_list[h]);
 
-	INIT_WORK(&vs->del_work, vxlan_del_work);
-
 	sock = vxlan_create_sock(net, ipv6, port, flags);
 	if (IS_ERR(sock)) {
 		pr_info("Cannot bind port %d, err=%ld\n", ntohs(port),
@@ -3218,10 +3210,6 @@ static int __init vxlan_init_module(void)
 {
 	int rc;
 
-	vxlan_wq = alloc_workqueue("vxlan", 0, 0);
-	if (!vxlan_wq)
-		return -ENOMEM;
-
 	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
 
 	rc = register_pernet_subsys(&vxlan_net_ops);
@@ -3242,7 +3230,6 @@ out3:
 out2:
 	unregister_pernet_subsys(&vxlan_net_ops);
 out1:
-	destroy_workqueue(vxlan_wq);
 	return rc;
 }
 late_initcall(vxlan_init_module);
@@ -3251,7 +3238,6 @@ static void __exit vxlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_netdevice_notifier(&vxlan_notifier_block);
-	destroy_workqueue(vxlan_wq);
 	unregister_pernet_subsys(&vxlan_net_ops);
 	/* rcu_barrier() is called by netns */
 }
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 73ed2e951c020d..2113f808e905a4 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -126,9 +126,7 @@ struct vxlan_metadata {
 /* per UDP socket information */
 struct vxlan_sock {
 	struct hlist_node hlist;
-	struct work_struct del_work;
 	struct socket	 *sock;
-	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
 	struct udp_offload udp_offloads;
-- 
2.5.5
