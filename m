From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 2/4] geneve: Simplify locking.
Date: Fri,  2 Jan 2015 18:26:03 -0800
Message-ID: <1420251965-44794-3-git-send-email-jesse@nicira.com>
References: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:56327 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752082AbbACC0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 21:26:12 -0500
Received: by mail-qg0-f49.google.com with SMTP id f51so423620qge.22
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 18:26:11 -0800 (PST)
In-Reply-To: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing Geneve locking scheme was pulled over directly from
VXLAN. However, VXLAN has a number of built in mechanisms which make
the locking more complex and are unlikely to be necessary with Geneve.
This simplifies the locking to use a basic scheme of a mutex
when doing updates plus RCU on receive.

In addition to making the code easier to read, this also avoids the
possibility of a race when creating or destroying sockets since
UDP sockets and the list of Geneve sockets are protected by different
locks. After this change, the entire operation is atomic.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/net/geneve.h |  2 +-
 net/ipv4/geneve.c    | 59 +++++++++++++++++++++++-----------------------------
 2 files changed, 27 insertions(+), 34 deletions(-)

diff --git a/include/net/geneve.h b/include/net/geneve.h
index 56c7e1a..b40f4af 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -73,7 +73,7 @@ struct geneve_sock {
 	void			*rcv_data;
 	struct socket		*sock;
 	struct rcu_head		rcu;
-	atomic_t		refcnt;
+	int			refcnt;
 	struct udp_offload	udp_offloads;
 };
 
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 136a829..ad8dbae 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -17,7 +17,7 @@
 #include <linux/errno.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
-#include <linux/rculist.h>
+#include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -28,6 +28,7 @@
 #include <linux/if_vlan.h>
 #include <linux/hash.h>
 #include <linux/ethtool.h>
+#include <linux/mutex.h>
 #include <net/arp.h>
 #include <net/ndisc.h>
 #include <net/ip.h>
@@ -50,13 +51,15 @@
 #include <net/ip6_checksum.h>
 #endif
 
+/* Protects sock_list and refcounts. */
+static DEFINE_MUTEX(geneve_mutex);
+
 #define PORT_HASH_BITS 8
 #define PORT_HASH_SIZE (1<<PORT_HASH_BITS)
 
 /* per-network namespace private data for this module */
 struct geneve_net {
 	struct hlist_head	sock_list[PORT_HASH_SIZE];
-	spinlock_t		sock_lock;   /* Protects sock_list */
 };
 
 static int geneve_net_id;
@@ -78,7 +81,7 @@ static struct geneve_sock *geneve_find_sock(struct net *net, __be16 port)
 {
 	struct geneve_sock *gs;
 
-	hlist_for_each_entry_rcu(gs, gs_head(net, port), hlist) {
+	hlist_for_each_entry(gs, gs_head(net, port), hlist) {
 		if (inet_sk(gs->sock->sk)->inet_sport == port)
 			return gs;
 	}
@@ -336,7 +339,6 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 						geneve_rcv_t *rcv, void *data,
 						bool ipv6)
 {
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 	struct socket *sock;
 	struct udp_tunnel_sock_cfg tunnel_cfg;
@@ -352,7 +354,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	}
 
 	gs->sock = sock;
-	atomic_set(&gs->refcnt, 1);
+	gs->refcnt = 1;
 	gs->rcv = rcv;
 	gs->rcv_data = data;
 
@@ -360,11 +362,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	gs->udp_offloads.port = port;
 	gs->udp_offloads.callbacks.gro_receive  = geneve_gro_receive;
 	gs->udp_offloads.callbacks.gro_complete = geneve_gro_complete;
-
-	spin_lock(&gn->sock_lock);
-	hlist_add_head_rcu(&gs->hlist, gs_head(net, port));
 	geneve_notify_add_rx_port(gs);
-	spin_unlock(&gn->sock_lock);
 
 	/* Mark socket as an encapsulation socket */
 	tunnel_cfg.sk_user_data = gs;
@@ -373,6 +371,8 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	tunnel_cfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
+	hlist_add_head(&gs->hlist, gs_head(net, port));
+
 	return gs;
 }
 
@@ -380,25 +380,21 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
 				    geneve_rcv_t *rcv, void *data,
 				    bool no_share, bool ipv6)
 {
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 
-	gs = geneve_socket_create(net, port, rcv, data, ipv6);
-	if (!IS_ERR(gs))
-		return gs;
-
-	if (no_share)	/* Return error if sharing is not allowed. */
-		return ERR_PTR(-EINVAL);
+	mutex_lock(&geneve_mutex);
 
-	spin_lock(&gn->sock_lock);
 	gs = geneve_find_sock(net, port);
-	if (gs && ((gs->rcv != rcv) ||
-		   !atomic_add_unless(&gs->refcnt, 1, 0)))
+	if (gs) {
+		if (!no_share && gs->rcv == rcv)
+			gs->refcnt++;
+		else
 			gs = ERR_PTR(-EBUSY);
-	spin_unlock(&gn->sock_lock);
+	} else {
+		gs = geneve_socket_create(net, port, rcv, data, ipv6);
+	}
 
-	if (!gs)
-		gs = ERR_PTR(-EINVAL);
+	mutex_unlock(&geneve_mutex);
 
 	return gs;
 }
@@ -406,19 +402,18 @@ EXPORT_SYMBOL_GPL(geneve_sock_add);
 
 void geneve_sock_release(struct geneve_sock *gs)
 {
-	struct net *net = sock_net(gs->sock->sk);
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	mutex_lock(&geneve_mutex);
 
-	if (!atomic_dec_and_test(&gs->refcnt))
-		return;
+	if (--gs->refcnt)
+		goto unlock;
 
-	spin_lock(&gn->sock_lock);
-	hlist_del_rcu(&gs->hlist);
+	hlist_del(&gs->hlist);
 	geneve_notify_del_rx_port(gs);
-	spin_unlock(&gn->sock_lock);
-
 	udp_tunnel_sock_release(gs->sock);
 	kfree_rcu(gs, rcu);
+
+unlock:
+	mutex_unlock(&geneve_mutex);
 }
 EXPORT_SYMBOL_GPL(geneve_sock_release);
 
@@ -427,8 +422,6 @@ static __net_init int geneve_init_net(struct net *net)
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	unsigned int h;
 
-	spin_lock_init(&gn->sock_lock);
-
 	for (h = 0; h < PORT_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&gn->sock_list[h]);
 
@@ -454,7 +447,7 @@ static int __init geneve_init_module(void)
 
 	return 0;
 }
-late_initcall(geneve_init_module);
+module_init(geneve_init_module);
 
 static void __exit geneve_cleanup_module(void)
 {
-- 
1.9.1
