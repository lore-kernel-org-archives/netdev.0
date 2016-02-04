From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH v2 net-next 1/4] net: add event_list to struct net and provide utility functions
Date: Thu,  4 Feb 2016 15:35:53 -0800
Message-ID: <1454628956-4803-2-git-send-email-noureddine@arista.com>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:24078 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757306AbcBDXnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 18:43:02 -0500
In-Reply-To: <1454628956-4803-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 include/net/net_namespace.h | 22 ++++++++++++++++++++++
 net/core/net_namespace.c    |  1 +
 2 files changed, 23 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 4089abc..6dbc0b2 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -58,6 +58,7 @@ struct net {
 	struct list_head	list;		/* list of network namespaces */
 	struct list_head	cleanup_list;	/* namespaces on death row */
 	struct list_head	exit_list;	/* Use only net_mutex */
+	struct list_head	event_list;     /* net_device notifier list */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
 	spinlock_t		nsid_lock;
@@ -380,4 +381,25 @@ static inline void fnhe_genid_bump(struct net *net)
 	atomic_inc(&net->fnhe_genid);
 }
 
+#ifdef CONFIG_NET_NS
+static inline void net_add_event_list(struct list_head *head, struct net *net)
+{
+	if (list_empty(&net->event_list))
+		list_add_tail(&net->event_list, head);
+}
+
+static inline void net_del_event_list(struct net *net)
+{
+	list_del_init(&net->event_list);
+}
+#else
+static inline void net_add_event_list(struct list_head *head, struct net *net)
+{
+}
+
+static inline void net_del_event_list(struct net *net)
+{
+}
+#endif
+
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b..58e84ce 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -282,6 +282,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	net->user_ns = user_ns;
 	idr_init(&net->netns_ids);
 	spin_lock_init(&net->nsid_lock);
+	INIT_LIST_HEAD(&net->event_list);
 
 	list_for_each_entry(ops, &pernet_list, list) {
 		error = ops_init(ops, net);
-- 
1.8.1.4
