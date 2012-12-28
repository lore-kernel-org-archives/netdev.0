From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 19/19] netfilter: gre: fix resource leak when unregister gre proto
Date: Fri, 28 Dec 2012 10:36:46 +0800
Message-ID: <1356662206-2260-20-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currectly we unregister proto before all conntrack entries of
this proto being destroyed. so in function destroy_conntrack
we can't find proper l4proto to call l4proto->destroy.
this will cause resource leak.

Because only nf_conntrack_l4proto_gre4 has its own destroy
pointer. fix this problem by marking gre4 proto disabled,
so this proto will not be found. after all contrack entries
of this proto being destroyed, we can unregister this proto
safely.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack.h         |  2 +-
 include/net/netfilter/nf_conntrack_l4proto.h |  9 ++++++
 net/netfilter/nf_conntrack_core.c            |  9 ++++--
 net/netfilter/nf_conntrack_proto.c           | 43 +++++++++++++++++++++++++---
 net/netfilter/nf_conntrack_proto_gre.c       |  3 +-
 5 files changed, 57 insertions(+), 9 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index caca0c4..9ba61fe 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -248,7 +248,7 @@ static inline struct nf_conn *nf_ct_untracked_get(void)
 extern void nf_ct_untracked_status_or(unsigned long bits);
 
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
-extern void
+extern bool
 nf_ct_iterate_cleanup(struct net *net, int (*iter)(struct nf_conn *i, void *data), void *data);
 extern void nf_conntrack_free(struct nf_conn *ct);
 extern struct nf_conn *
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index c001ef7..967ae91 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -23,6 +23,10 @@ struct nf_conntrack_l4proto {
 	/* L4 Protocol number. */
 	u_int8_t l4proto;
 
+	/* under unregistration, proto is unavailable, only being set
+	 * by gre4 proto */
+	bool disabled;
+
 	/* Try to fill in the third arg: dataoff is offset past network protocol
            hdr.  Return true if possible. */
 	bool (*pkt_to_tuple)(const struct sk_buff *skb, unsigned int dataoff,
@@ -115,6 +119,9 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
 #define MAX_NF_CT_PROTO 256
 
 extern struct nf_conntrack_l4proto *
+__nf_ct_l4proto_find_all(u_int16_t l3proto, u_int8_t l4proto);
+
+extern struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto);
 
 extern struct nf_conntrack_l4proto *
@@ -134,6 +141,8 @@ extern int
 nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
 extern void
 nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
+extern void
+nf_conntrack_l4proto_disable(struct nf_conntrack_l4proto *proto);
 
 static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
 {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index fc0805e..788e6fe 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -208,7 +208,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	 * destroy_conntrack() MUST NOT be called with a write lock
 	 * to nf_conntrack_lock!!! -HW */
 	rcu_read_lock();
-	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	l4proto = __nf_ct_l4proto_find_all(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto && l4proto->destroy)
 		l4proto->destroy(ct);
 
@@ -1237,21 +1237,24 @@ found:
 	return ct;
 }
 
-void nf_ct_iterate_cleanup(struct net *net,
+bool nf_ct_iterate_cleanup(struct net *net,
 			   int (*iter)(struct nf_conn *i, void *data),
 			   void *data)
 {
 	struct nf_conn *ct;
 	unsigned int bucket = 0;
+	bool ret = true;
 
 	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
 		if (del_timer(&ct->timeout))
 			death_by_timeout((unsigned long)ct);
 		/* ... else the timer will get him soon. */
-
+		if (atomic_read(&ct->ct_general.use) > 1)
+			ret = false;
 		nf_ct_put(ct);
 	}
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
 
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index ff38923..0f6251e 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -65,13 +65,26 @@ nf_ct_unregister_sysctl(struct ctl_table_header **header,
 #endif
 
 struct nf_conntrack_l4proto *
-__nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto)
+__nf_ct_l4proto_find_all(u_int16_t l3proto, u_int8_t l4proto)
 {
 	if (unlikely(l3proto >= AF_MAX || nf_ct_protos[l3proto] == NULL))
 		return &nf_conntrack_l4proto_generic;
 
 	return rcu_dereference(nf_ct_protos[l3proto][l4proto]);
 }
+EXPORT_SYMBOL_GPL(__nf_ct_l4proto_find_all);
+
+struct nf_conntrack_l4proto *
+__nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto)
+{
+	struct nf_conntrack_l4proto *proto;
+	proto = __nf_ct_l4proto_find_all(l3proto, l4proto);
+
+	if (proto->disabled)
+		return &nf_conntrack_l4proto_generic;
+
+	return proto;
+}
 EXPORT_SYMBOL_GPL(__nf_ct_l4proto_find);
 
 /* this is guaranteed to always return a valid protocol helper, since
@@ -457,6 +470,10 @@ nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 {
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
+	if (l4proto->destroy && !l4proto->disabled)
+		pr_warn("unregister l4proto %s: disable proto first\n",
+			l4proto->name);
+
 	mutex_lock(&nf_ct_proto_mutex);
 	BUG_ON(rcu_dereference_protected(
 			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
@@ -481,12 +498,30 @@ void nf_conntrack_l4proto_pernet_unregister(struct net *net,
 
 	pn->users--;
 	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
-
-	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
+retry:
+	/* Remove all contrack entries for this protocol.
+	 * l4proto is needed in nf_ct_destroy to destroy
+	 * conntrack's proto private data,So make sure all
+	 * conntrack entries being destroyed for this protocol.
+	 * Then the l4proto can be unregistered safely.
+	 */
+	if (!nf_ct_iterate_cleanup(net, kill_l4proto, l4proto)) {
+		schedule();
+		goto retry;
+	}
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_pernet_unregister);
 
+void nf_conntrack_l4proto_disable(struct nf_conntrack_l4proto *proto)
+{
+	mutex_lock(&nf_ct_proto_mutex);
+	proto->disabled = true;
+	mutex_unlock(&nf_ct_proto_mutex);
+
+	synchronize_rcu();
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_disable);
+
 int nf_conntrack_proto_pernet_init(struct net *net)
 {
 	int err;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index ea1f651..2730f0d 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -438,8 +438,9 @@ out_gre4:
 
 static void __exit nf_ct_proto_gre_fini(void)
 {
-	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
+	nf_conntrack_l4proto_disable(&nf_conntrack_l4proto_gre4);
 	unregister_pernet_subsys(&proto_gre_net_ops);
+	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
 }
 
 module_init(nf_ct_proto_gre_init);
-- 
1.7.11.7

