From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 3/7] netlink: Move namespace into hash key
Date: Fri, 20 Mar 2015 21:57:01 +1100
Message-ID: <E1YYubt-0004lM-Kq@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53974 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbCTK5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the name space is a de facto key because it has to match
before we find an object in the hash table.  However, it isn't in
the hash value so all objects from different name spaces with the
same port ID hash to the same bucket.

This is bad as the number of name spaces is unbounded.

This patch fixes this by using the namespace when doing the hash.

Because the namespace field doesn't lie next to the portid field
in the netlink socket, this patch switches over to the rhashtable
interface without a fixed key.

This patch also uses the new inlined rhashtable interface where
possible.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |   88 +++++++++++++++++++++++++++++------------------
 1 file changed, 56 insertions(+), 32 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d97aed6..72c6b55 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -116,6 +116,8 @@ static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 static DEFINE_SPINLOCK(netlink_tap_lock);
 static struct list_head netlink_tap_all __read_mostly;
 
+static const struct rhashtable_params netlink_rhashtable_params;
+
 static inline u32 netlink_group_mask(u32 group)
 {
 	return group ? 1 << (group - 1) : 0;
@@ -970,41 +972,49 @@ netlink_unlock_table(void)
 
 struct netlink_compare_arg
 {
-	struct net *net;
+	possible_net_t pnet;
 	u32 portid;
+	char trailer[];
 };
 
-static bool netlink_compare(void *ptr, void *arg)
+#define netlink_compare_arg_len offsetof(struct netlink_compare_arg, trailer)
+
+static inline int netlink_compare(struct rhashtable_compare_arg *arg,
+				  const void *ptr)
 {
-	struct netlink_compare_arg *x = arg;
-	struct sock *sk = ptr;
+	const struct netlink_compare_arg *x = arg->key;
+	const struct netlink_sock *nlk = ptr;
 
-	return nlk_sk(sk)->portid == x->portid &&
-	       net_eq(sock_net(sk), x->net);
+	return nlk->portid != x->portid ||
+	       !net_eq(sock_net(&nlk->sk), read_pnet(&x->pnet));
+}
+
+static void netlink_compare_arg_init(struct netlink_compare_arg *arg,
+				     struct net *net, u32 portid)
+{
+	memset(arg, 0, sizeof(*arg));
+	write_pnet(&arg->pnet, net);
+	arg->portid = portid;
 }
 
 static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 				     struct net *net)
 {
-	struct netlink_compare_arg arg = {
-		.net = net,
-		.portid = portid,
-	};
+	struct netlink_compare_arg arg;
 
-	return rhashtable_lookup_compare(&table->hash, &portid,
-					 &netlink_compare, &arg);
+	netlink_compare_arg_init(&arg, net, portid);
+	return rhashtable_lookup_fast(&table->hash, &arg,
+				      netlink_rhashtable_params);
 }
 
-static bool __netlink_insert(struct netlink_table *table, struct sock *sk)
+static int __netlink_insert(struct netlink_table *table, struct sock *sk)
 {
-	struct netlink_compare_arg arg = {
-		.net = sock_net(sk),
-		.portid = nlk_sk(sk)->portid,
-	};
+	struct netlink_compare_arg arg;
 
-	return rhashtable_lookup_compare_insert(&table->hash,
-						&nlk_sk(sk)->node,
-						&netlink_compare, &arg);
+	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->portid);
+	return rhashtable_lookup_insert_key(&table->hash, &arg,
+					    &nlk_sk(sk)->node,
+					    netlink_rhashtable_params);
 }
 
 static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
@@ -1066,9 +1076,10 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	nlk_sk(sk)->portid = portid;
 	sock_hold(sk);
 
-	err = 0;
-	if (!__netlink_insert(table, sk)) {
-		err = -EADDRINUSE;
+	err = __netlink_insert(table, sk);
+	if (err) {
+		if (err == -EEXIST)
+			err = -EADDRINUSE;
 		sock_put(sk);
 	}
 
@@ -1082,7 +1093,8 @@ static void netlink_remove(struct sock *sk)
 	struct netlink_table *table;
 
 	table = &nl_table[sk->sk_protocol];
-	if (rhashtable_remove(&table->hash, &nlk_sk(sk)->node)) {
+	if (!rhashtable_remove_fast(&table->hash, &nlk_sk(sk)->node,
+				    netlink_rhashtable_params)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
@@ -3114,17 +3126,28 @@ static struct pernet_operations __net_initdata netlink_net_ops = {
 	.exit = netlink_net_exit,
 };
 
+static inline u32 netlink_hash(const void *data, u32 seed)
+{
+	const struct netlink_sock *nlk = data;
+	struct netlink_compare_arg arg;
+
+	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
+	return jhash(&arg, netlink_compare_arg_len, seed);
+}
+
+static const struct rhashtable_params netlink_rhashtable_params = {
+	.head_offset = offsetof(struct netlink_sock, node),
+	.key_len = netlink_compare_arg_len,
+	.hashfn = jhash,
+	.obj_hashfn = netlink_hash,
+	.obj_cmpfn = netlink_compare,
+	.max_size = 65536,
+};
+
 static int __init netlink_proto_init(void)
 {
 	int i;
 	int err = proto_register(&netlink_proto, 0);
-	struct rhashtable_params ht_params = {
-		.head_offset = offsetof(struct netlink_sock, node),
-		.key_offset = offsetof(struct netlink_sock, portid),
-		.key_len = sizeof(u32), /* portid */
-		.hashfn = jhash,
-		.max_size = 65536,
-	};
 
 	if (err != 0)
 		goto out;
@@ -3136,7 +3159,8 @@ static int __init netlink_proto_init(void)
 		goto panic;
 
 	for (i = 0; i < MAX_LINKS; i++) {
-		if (rhashtable_init(&nl_table[i].hash, &ht_params) < 0) {
+		if (rhashtable_init(&nl_table[i].hash,
+				    &netlink_rhashtable_params) < 0) {
 			while (--i > 0)
 				rhashtable_destroy(&nl_table[i].hash);
 			kfree(nl_table);
