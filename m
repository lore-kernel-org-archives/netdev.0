From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 3/4] geneve: Remove socket hash table.
Date: Fri,  2 Jan 2015 18:26:04 -0800
Message-ID: <1420251965-44794-4-git-send-email-jesse@nicira.com>
References: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:53684 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752048AbbACC0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 21:26:17 -0500
Received: by mail-qc0-f182.google.com with SMTP id r5so13878468qcx.27
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 18:26:12 -0800 (PST)
In-Reply-To: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hash table for open Geneve ports is used only on creation and
deletion time. It is not performance critical and is not likely to
grow to a large number of items. Therefore, this can be changed
to use a simple linked list.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/net/geneve.h |  2 +-
 net/ipv4/geneve.c    | 26 +++++++-------------------
 2 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/include/net/geneve.h b/include/net/geneve.h
index b40f4af..03aa2ad 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -68,7 +68,7 @@ struct geneve_sock;
 typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *skb);
 
 struct geneve_sock {
-	struct hlist_node	hlist;
+	struct list_head	list;
 	geneve_rcv_t		*rcv;
 	void			*rcv_data;
 	struct socket		*sock;
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index ad8dbae..4fe5a59 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -26,7 +26,6 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
-#include <linux/hash.h>
 #include <linux/ethtool.h>
 #include <linux/mutex.h>
 #include <net/arp.h>
@@ -54,12 +53,9 @@
 /* Protects sock_list and refcounts. */
 static DEFINE_MUTEX(geneve_mutex);
 
-#define PORT_HASH_BITS 8
-#define PORT_HASH_SIZE (1<<PORT_HASH_BITS)
-
 /* per-network namespace private data for this module */
 struct geneve_net {
-	struct hlist_head	sock_list[PORT_HASH_SIZE];
+	struct list_head	sock_list;
 };
 
 static int geneve_net_id;
@@ -69,19 +65,13 @@ static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 	return (struct genevehdr *)(udp_hdr(skb) + 1);
 }
 
-static struct hlist_head *gs_head(struct net *net, __be16 port)
-{
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
-
-	return &gn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
-}
-
 /* Find geneve socket based on network namespace and UDP port */
 static struct geneve_sock *geneve_find_sock(struct net *net, __be16 port)
 {
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 
-	hlist_for_each_entry(gs, gs_head(net, port), hlist) {
+	list_for_each_entry(gs, &gn->sock_list, list) {
 		if (inet_sk(gs->sock->sk)->inet_sport == port)
 			return gs;
 	}
@@ -339,6 +329,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 						geneve_rcv_t *rcv, void *data,
 						bool ipv6)
 {
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 	struct socket *sock;
 	struct udp_tunnel_sock_cfg tunnel_cfg;
@@ -371,7 +362,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	tunnel_cfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
-	hlist_add_head(&gs->hlist, gs_head(net, port));
+	list_add(&gs->list, &gn->sock_list);
 
 	return gs;
 }
@@ -407,7 +398,7 @@ void geneve_sock_release(struct geneve_sock *gs)
 	if (--gs->refcnt)
 		goto unlock;
 
-	hlist_del(&gs->hlist);
+	list_del(&gs->list);
 	geneve_notify_del_rx_port(gs);
 	udp_tunnel_sock_release(gs->sock);
 	kfree_rcu(gs, rcu);
@@ -420,17 +411,14 @@ EXPORT_SYMBOL_GPL(geneve_sock_release);
 static __net_init int geneve_init_net(struct net *net)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	unsigned int h;
 
-	for (h = 0; h < PORT_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&gn->sock_list[h]);
+	INIT_LIST_HEAD(&gn->sock_list);
 
 	return 0;
 }
 
 static struct pernet_operations geneve_net_ops = {
 	.init = geneve_init_net,
-	.exit = NULL,
 	.id   = &geneve_net_id,
 	.size = sizeof(struct geneve_net),
 };
-- 
1.9.1
