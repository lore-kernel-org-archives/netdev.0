From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 1/4] geneve: Remove workqueue.
Date: Fri,  2 Jan 2015 18:26:02 -0800
Message-ID: <1420251965-44794-2-git-send-email-jesse@nicira.com>
References: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:54099 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752048AbbACC0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 21:26:11 -0500
Received: by mail-qg0-f54.google.com with SMTP id l89so13592732qgf.13
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 18:26:10 -0800 (PST)
In-Reply-To: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The work queue is used only to free the UDP socket upon destruction.
This is not necessary with Geneve and generally makes the code more
difficult to reason about. It also introduces nondeterministic
behavior such as when a socket is rapidly deleted and recreated, which
could fail as the the deletion happens asynchronously.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/net/geneve.h |  1 -
 net/ipv4/geneve.c    | 21 ++-------------------
 2 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/include/net/geneve.h b/include/net/geneve.h
index 112132c..56c7e1a 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -71,7 +71,6 @@ struct geneve_sock {
 	struct hlist_node	hlist;
 	geneve_rcv_t		*rcv;
 	void			*rcv_data;
-	struct work_struct	del_work;
 	struct socket		*sock;
 	struct rcu_head		rcu;
 	atomic_t		refcnt;
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 19e256e..136a829 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -61,8 +61,6 @@ struct geneve_net {
 
 static int geneve_net_id;
 
-static struct workqueue_struct *geneve_wq;
-
 static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 {
 	return (struct genevehdr *)(udp_hdr(skb) + 1);
@@ -307,15 +305,6 @@ error:
 	return 1;
 }
 
-static void geneve_del_work(struct work_struct *work)
-{
-	struct geneve_sock *gs = container_of(work, struct geneve_sock,
-					      del_work);
-
-	udp_tunnel_sock_release(gs->sock);
-	kfree_rcu(gs, rcu);
-}
-
 static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 					 __be16 port)
 {
@@ -356,8 +345,6 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	if (!gs)
 		return ERR_PTR(-ENOMEM);
 
-	INIT_WORK(&gs->del_work, geneve_del_work);
-
 	sock = geneve_create_sock(net, ipv6, port);
 	if (IS_ERR(sock)) {
 		kfree(gs);
@@ -430,7 +417,8 @@ void geneve_sock_release(struct geneve_sock *gs)
 	geneve_notify_del_rx_port(gs);
 	spin_unlock(&gn->sock_lock);
 
-	queue_work(geneve_wq, &gs->del_work);
+	udp_tunnel_sock_release(gs->sock);
+	kfree_rcu(gs, rcu);
 }
 EXPORT_SYMBOL_GPL(geneve_sock_release);
 
@@ -458,10 +446,6 @@ static int __init geneve_init_module(void)
 {
 	int rc;
 
-	geneve_wq = alloc_workqueue("geneve", 0, 0);
-	if (!geneve_wq)
-		return -ENOMEM;
-
 	rc = register_pernet_subsys(&geneve_net_ops);
 	if (rc)
 		return rc;
@@ -474,7 +458,6 @@ late_initcall(geneve_init_module);
 
 static void __exit geneve_cleanup_module(void)
 {
-	destroy_workqueue(geneve_wq);
 	unregister_pernet_subsys(&geneve_net_ops);
 }
 module_exit(geneve_cleanup_module);
-- 
1.9.1
