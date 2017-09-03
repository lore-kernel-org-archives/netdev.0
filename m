From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/47] netfilter: constify nf_conntrack_l3/4proto parameters
Date: Mon,  4 Sep 2017 00:28:58 +0200
Message-ID: <1504477763-12205-3-git-send-email-pablo@netfilter.org>
References: <1504477763-12205-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51464 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753050AbdICW3i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:29:38 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C862F190F64
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:29:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B0D96B5028
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:29:11 +0200 (CEST)
In-Reply-To: <1504477763-12205-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>

When a nf_conntrack_l3/4proto parameter is not on the left hand side
of an assignment, its address is not taken, and it is not passed to a
function that may modify its fields, then it can be declared as const.

This change is useful from a documentation point of view, and can
possibly facilitate making some nf_conntrack_l3/4proto structures const
subsequently.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h | 14 +++++++-------
 include/net/netfilter/nf_conntrack_timeout.h |  2 +-
 net/netfilter/nf_conntrack_core.c            |  8 ++++----
 net/netfilter/nf_conntrack_netlink.c         |  6 +++---
 net/netfilter/nf_conntrack_proto.c           | 24 ++++++++++++------------
 net/netfilter/nfnetlink_cttimeout.c          |  5 +++--
 6 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 7032e044bbe2..b6e27cafb1d9 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -125,23 +125,23 @@ struct nf_conntrack_l4proto *__nf_ct_l4proto_find(u_int16_t l3proto,
 
 struct nf_conntrack_l4proto *nf_ct_l4proto_find_get(u_int16_t l3proto,
 						    u_int8_t l4proto);
-void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
+void nf_ct_l4proto_put(const struct nf_conntrack_l4proto *p);
 
 /* Protocol pernet registration. */
 int nf_ct_l4proto_pernet_register_one(struct net *net,
-				      struct nf_conntrack_l4proto *proto);
+				const struct nf_conntrack_l4proto *proto);
 void nf_ct_l4proto_pernet_unregister_one(struct net *net,
-					 struct nf_conntrack_l4proto *proto);
+				const struct nf_conntrack_l4proto *proto);
 int nf_ct_l4proto_pernet_register(struct net *net,
-				  struct nf_conntrack_l4proto *proto[],
+				  struct nf_conntrack_l4proto *const proto[],
 				  unsigned int num_proto);
 void nf_ct_l4proto_pernet_unregister(struct net *net,
-				     struct nf_conntrack_l4proto *proto[],
-				     unsigned int num_proto);
+				struct nf_conntrack_l4proto *const proto[],
+				unsigned int num_proto);
 
 /* Protocol global registration. */
 int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *proto);
-void nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *proto);
+void nf_ct_l4proto_unregister_one(const struct nf_conntrack_l4proto *proto);
 int nf_ct_l4proto_register(struct nf_conntrack_l4proto *proto[],
 			   unsigned int num_proto);
 void nf_ct_l4proto_unregister(struct nf_conntrack_l4proto *proto[],
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index d40b89355fdd..b222957062b5 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -68,7 +68,7 @@ struct nf_conn_timeout *nf_ct_timeout_ext_add(struct nf_conn *ct,
 
 static inline unsigned int *
 nf_ct_timeout_lookup(struct net *net, struct nf_conn *ct,
-		     struct nf_conntrack_l4proto *l4proto)
+		     const struct nf_conntrack_l4proto *l4proto)
 {
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	struct nf_conn_timeout *timeout_ext;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2bc499186186..f2f00eaf217d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1176,8 +1176,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 static noinline struct nf_conntrack_tuple_hash *
 init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       const struct nf_conntrack_tuple *tuple,
-	       struct nf_conntrack_l3proto *l3proto,
-	       struct nf_conntrack_l4proto *l4proto,
+	       const struct nf_conntrack_l3proto *l3proto,
+	       const struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
 	       unsigned int dataoff, u32 hash)
 {
@@ -1288,8 +1288,8 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
 		  u_int8_t protonum,
-		  struct nf_conntrack_l3proto *l3proto,
-		  struct nf_conntrack_l4proto *l4proto)
+		  const struct nf_conntrack_l3proto *l3proto,
+		  const struct nf_conntrack_l4proto *l4proto)
 {
 	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple tuple;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4922c8aefb2a..f4ca48817f66 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -61,8 +61,8 @@ MODULE_LICENSE("GPL");
 static char __initdata version[] = "0.93";
 
 static int ctnetlink_dump_tuples_proto(struct sk_buff *skb,
-				       const struct nf_conntrack_tuple *tuple,
-				       struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_tuple *tuple,
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 	struct nlattr *nest_parms;
@@ -86,7 +86,7 @@ static int ctnetlink_dump_tuples_proto(struct sk_buff *skb,
 
 static int ctnetlink_dump_tuples_ip(struct sk_buff *skb,
 				    const struct nf_conntrack_tuple *tuple,
-				    struct nf_conntrack_l3proto *l3proto)
+				    const struct nf_conntrack_l3proto *l3proto)
 {
 	int ret = 0;
 	struct nlattr *nest_parms;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 7c89dade6fd3..27810cf816a6 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -188,7 +188,7 @@ nf_ct_l4proto_find_get(u_int16_t l3num, u_int8_t l4num)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_find_get);
 
-void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p)
+void nf_ct_l4proto_put(const struct nf_conntrack_l4proto *p)
 {
 	module_put(p->me);
 }
@@ -257,7 +257,7 @@ void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
-					      struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	if (l4proto->get_net_proto) {
 		/* statically built-in protocols use static per-net */
@@ -272,7 +272,7 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 static
 int nf_ct_l4proto_register_sysctl(struct net *net,
 				  struct nf_proto_net *pn,
-				  struct nf_conntrack_l4proto *l4proto)
+				  const struct nf_conntrack_l4proto *l4proto)
 {
 	int err = 0;
 
@@ -295,8 +295,8 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 
 static
 void nf_ct_l4proto_unregister_sysctl(struct net *net,
-				     struct nf_proto_net *pn,
-				     struct nf_conntrack_l4proto *l4proto)
+				struct nf_proto_net *pn,
+				const struct nf_conntrack_l4proto *l4proto)
 {
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table_header != NULL)
@@ -366,7 +366,7 @@ int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *l4proto)
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_register_one);
 
 int nf_ct_l4proto_pernet_register_one(struct net *net,
-				      struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 	struct nf_proto_net *pn = NULL;
@@ -391,7 +391,7 @@ int nf_ct_l4proto_pernet_register_one(struct net *net,
 }
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_register_one);
 
-static void __nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
+static void __nf_ct_l4proto_unregister_one(const struct nf_conntrack_l4proto *l4proto)
 
 {
 	BUG_ON(l4proto->l3proto >= ARRAY_SIZE(nf_ct_protos));
@@ -404,7 +404,7 @@ static void __nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
 			   &nf_conntrack_l4proto_generic);
 }
 
-void nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
+void nf_ct_l4proto_unregister_one(const struct nf_conntrack_l4proto *l4proto)
 {
 	mutex_lock(&nf_ct_proto_mutex);
 	__nf_ct_l4proto_unregister_one(l4proto);
@@ -415,7 +415,7 @@ void nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister_one);
 
 void nf_ct_l4proto_pernet_unregister_one(struct net *net,
-					 struct nf_conntrack_l4proto *l4proto)
+				const struct nf_conntrack_l4proto *l4proto)
 {
 	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
 
@@ -449,7 +449,7 @@ int nf_ct_l4proto_register(struct nf_conntrack_l4proto *l4proto[],
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_register);
 
 int nf_ct_l4proto_pernet_register(struct net *net,
-				  struct nf_conntrack_l4proto *l4proto[],
+				  struct nf_conntrack_l4proto *const l4proto[],
 				  unsigned int num_proto)
 {
 	int ret = -EINVAL;
@@ -485,8 +485,8 @@ void nf_ct_l4proto_unregister(struct nf_conntrack_l4proto *l4proto[],
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister);
 
 void nf_ct_l4proto_pernet_unregister(struct net *net,
-				     struct nf_conntrack_l4proto *l4proto[],
-				     unsigned int num_proto)
+				struct nf_conntrack_l4proto *const l4proto[],
+				unsigned int num_proto)
 {
 	while (num_proto-- != 0)
 		nf_ct_l4proto_pernet_unregister_one(net, l4proto[num_proto]);
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index f4fb6d4dd0b9..fcabccc99f0d 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -47,7 +47,8 @@ static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
 };
 
 static int
-ctnl_timeout_parse_policy(void *timeouts, struct nf_conntrack_l4proto *l4proto,
+ctnl_timeout_parse_policy(void *timeouts,
+			  const struct nf_conntrack_l4proto *l4proto,
 			  struct net *net, const struct nlattr *attr)
 {
 	int ret = 0;
@@ -401,7 +402,7 @@ static int cttimeout_default_set(struct net *net, struct sock *ctnl,
 static int
 cttimeout_default_fill_info(struct net *net, struct sk_buff *skb, u32 portid,
 			    u32 seq, u32 type, int event,
-			    struct nf_conntrack_l4proto *l4proto)
+			    const struct nf_conntrack_l4proto *l4proto)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-- 
2.1.4
