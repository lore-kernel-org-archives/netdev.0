From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2] vxlan: synchronously and race-free destruction of vxlan sockets
Date: Fri,  8 Apr 2016 22:55:01 +0200
Message-ID: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Benc <jbenc@redhat.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41960 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbcDHUzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:55:11 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 40C6420E63
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 16:55:10 -0400 (EDT)
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

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jiri Benc <jbenc@redhat.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2) synchronize_rcu -> synchronize_net (proposed by Eric, thanks!)
    also rebased on net-next to apply without conflicts
 drivers/net/vxlan.c | 20 +++-----------------
 include/net/vxlan.h |  2 --
 2 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9f3634064c921f..77ba31a0e44f97 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -98,7 +98,6 @@ struct vxlan_fdb {
 
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
-static struct workqueue_struct *vxlan_wq;
 
 static inline bool vxlan_collect_metadata(struct vxlan_sock *vs)
 {
@@ -1053,7 +1052,9 @@ static void __vxlan_sock_release(struct vxlan_sock *vs)
 	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
-	queue_work(vxlan_wq, &vs->del_work);
+	synchronize_net();
+	udp_tunnel_sock_release(vs->sock);
+	kfree(vs);
 }
 
 static void vxlan_sock_release(struct vxlan_dev *vxlan)
@@ -2674,13 +2675,6 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
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
@@ -2726,8 +2720,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vs->vni_list[h]);
 
-	INIT_WORK(&vs->del_work, vxlan_del_work);
-
 	sock = vxlan_create_sock(net, ipv6, port, flags);
 	if (IS_ERR(sock)) {
 		pr_info("Cannot bind port %d, err=%ld\n", ntohs(port),
@@ -3346,10 +3338,6 @@ static int __init vxlan_init_module(void)
 {
 	int rc;
 
-	vxlan_wq = alloc_workqueue("vxlan", 0, 0);
-	if (!vxlan_wq)
-		return -ENOMEM;
-
 	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
 
 	rc = register_pernet_subsys(&vxlan_net_ops);
@@ -3370,7 +3358,6 @@ out3:
 out2:
 	unregister_pernet_subsys(&vxlan_net_ops);
 out1:
-	destroy_workqueue(vxlan_wq);
 	return rc;
 }
 late_initcall(vxlan_init_module);
@@ -3379,7 +3366,6 @@ static void __exit vxlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_netdevice_notifier(&vxlan_notifier_block);
-	destroy_workqueue(vxlan_wq);
 	unregister_pernet_subsys(&vxlan_net_ops);
 	/* rcu_barrier() is called by netns */
 }
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 2f168f0ea32c39..d442eb3129cde4 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -184,9 +184,7 @@ struct vxlan_metadata {
 /* per UDP socket information */
 struct vxlan_sock {
 	struct hlist_node hlist;
-	struct work_struct del_work;
 	struct socket	 *sock;
-	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
 	u32		  flags;
-- 
2.5.5
