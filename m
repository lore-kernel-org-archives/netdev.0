From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/29] netfilter: conntrack: use NFPROTO_MAX to size array
Date: Fri, 30 Jun 2017 00:53:25 +0200
Message-ID: <1498776807-11124-28-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We don't support anything larger than NFPROTO_MAX, so we can shrink this a bit:

     text data  dec  hex filename
old: 8259 1096 9355 248b net/netfilter/nf_conntrack_proto.o
new: 8259  624 8883 22b3 net/netfilter/nf_conntrack_proto.o

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h |  4 ++--
 net/netfilter/nf_conntrack_proto.c           | 18 +++++++++---------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index e01559b4d781..6d14b36e3a49 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -71,7 +71,7 @@ struct nf_conntrack_l3proto {
 	struct module *me;
 };
 
-extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
+extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[NFPROTO_NUMPROTO];
 
 #ifdef CONFIG_SYSCTL
 /* Protocol pernet registration. */
@@ -100,7 +100,7 @@ extern struct nf_conntrack_l3proto nf_conntrack_l3proto_generic;
 static inline struct nf_conntrack_l3proto *
 __nf_ct_l3proto_find(u_int16_t l3proto)
 {
-	if (unlikely(l3proto >= AF_MAX))
+	if (unlikely(l3proto >= NFPROTO_NUMPROTO))
 		return &nf_conntrack_l3proto_generic;
 	return rcu_dereference(nf_ct_l3protos[l3proto]);
 }
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 6a36623e897c..1dcad229c3cc 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -28,8 +28,8 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
 
-static struct nf_conntrack_l4proto __rcu **nf_ct_protos[PF_MAX] __read_mostly;
-struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX] __read_mostly;
+static struct nf_conntrack_l4proto __rcu **nf_ct_protos[NFPROTO_NUMPROTO] __read_mostly;
+struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[NFPROTO_NUMPROTO] __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_l3protos);
 
 static DEFINE_MUTEX(nf_ct_proto_mutex);
@@ -68,7 +68,7 @@ nf_ct_unregister_sysctl(struct ctl_table_header **header,
 struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto)
 {
-	if (unlikely(l3proto >= AF_MAX || nf_ct_protos[l3proto] == NULL))
+	if (unlikely(l3proto >= NFPROTO_NUMPROTO || nf_ct_protos[l3proto] == NULL))
 		return &nf_conntrack_l4proto_generic;
 
 	return rcu_dereference(nf_ct_protos[l3proto][l4proto]);
@@ -212,7 +212,7 @@ int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 	int ret = 0;
 	struct nf_conntrack_l3proto *old;
 
-	if (proto->l3proto >= AF_MAX)
+	if (proto->l3proto >= NFPROTO_NUMPROTO)
 		return -EBUSY;
 
 	if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
@@ -254,7 +254,7 @@ EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_register);
 
 void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
-	BUG_ON(proto->l3proto >= AF_MAX);
+	BUG_ON(proto->l3proto >= NFPROTO_NUMPROTO);
 
 	mutex_lock(&nf_ct_proto_mutex);
 	BUG_ON(rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
@@ -341,7 +341,7 @@ int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *l4proto)
 {
 	int ret = 0;
 
-	if (l4proto->l3proto >= PF_MAX)
+	if (l4proto->l3proto >= ARRAY_SIZE(nf_ct_protos))
 		return -EBUSY;
 
 	if ((l4proto->to_nlattr && !l4proto->nlattr_size) ||
@@ -423,7 +423,7 @@ EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_register_one);
 static void __nf_ct_l4proto_unregister_one(struct nf_conntrack_l4proto *l4proto)
 
 {
-	BUG_ON(l4proto->l3proto >= PF_MAX);
+	BUG_ON(l4proto->l3proto >= ARRAY_SIZE(nf_ct_protos));
 
 	BUG_ON(rcu_dereference_protected(
 			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
@@ -556,7 +556,7 @@ void nf_conntrack_proto_pernet_fini(struct net *net)
 int nf_conntrack_proto_init(void)
 {
 	unsigned int i;
-	for (i = 0; i < AF_MAX; i++)
+	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		rcu_assign_pointer(nf_ct_l3protos[i],
 				   &nf_conntrack_l3proto_generic);
 	return 0;
@@ -566,6 +566,6 @@ void nf_conntrack_proto_fini(void)
 {
 	unsigned int i;
 	/* free l3proto protocol tables */
-	for (i = 0; i < PF_MAX; i++)
+	for (i = 0; i < ARRAY_SIZE(nf_ct_protos); i++)
 		kfree(nf_ct_protos[i]);
 }
-- 
2.1.4

