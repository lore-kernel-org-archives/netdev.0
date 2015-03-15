From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 9/14] netlink: Move namespace into hash key
Date: Sun, 15 Mar 2015 21:44:34 +1100
Message-ID: <E1YX626-0005oQ-I6@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57234 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbbCOKoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:39 -0400
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

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/netlink/af_netlink.c |   66 +++++++++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 25 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d97aed6..ca048f3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -970,41 +970,46 @@ netlink_unlock_table(void)
 
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
+static bool netlink_compare(const void *arg, const void *ptr)
 {
-	struct netlink_compare_arg *x = arg;
-	struct sock *sk = ptr;
+	const struct netlink_compare_arg *x = arg;
+	const struct netlink_sock *nlk = ptr;
 
-	return nlk_sk(sk)->portid == x->portid &&
-	       net_eq(sock_net(sk), x->net);
+	return nlk->portid == x->portid &&
+	       net_eq(sock_net(&nlk->sk), read_pnet(&x->pnet));
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
+	return rhashtable_lookup(&table->hash, &arg);
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
+					    &nlk_sk(sk)->node);
 }
 
 static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
@@ -1066,9 +1071,10 @@ static int netlink_insert(struct sock *sk, u32 portid)
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
 
@@ -3114,15 +3120,25 @@ static struct pernet_operations __net_initdata netlink_net_ops = {
 	.exit = netlink_net_exit,
 };
 
+static u32 netlink_hash(const void *data, u32 seed)
+{
+	const struct netlink_sock *nlk = data;
+	struct netlink_compare_arg arg;
+
+	netlink_compare_arg_init(&arg, sock_net(&nlk->sk), nlk->portid);
+	return jhash(&arg, netlink_compare_arg_len, seed);
+}
+
 static int __init netlink_proto_init(void)
 {
 	int i;
 	int err = proto_register(&netlink_proto, 0);
 	struct rhashtable_params ht_params = {
 		.head_offset = offsetof(struct netlink_sock, node),
-		.key_offset = offsetof(struct netlink_sock, portid),
-		.key_len = sizeof(u32), /* portid */
+		.key_len = netlink_compare_arg_len,
 		.hashfn = jhash,
+		.obj_hashfn = netlink_hash,
+		.obj_cmpfn = netlink_compare,
 		.max_size = 65536,
 	};
 
