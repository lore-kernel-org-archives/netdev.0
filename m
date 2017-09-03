From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 38/47] netfilter: conntrack: make protocol tracker pointers const
Date: Mon,  4 Sep 2017 00:42:45 +0200
Message-ID: <1504478574-13281-3-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Doesn't change generated code, but will make it easier to eventually
make the actual trackers themselvers const.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h |  6 +++---
 include/net/netfilter/nf_conntrack_l4proto.h |  4 ++--
 include/net/netfilter/nf_conntrack_timeout.h |  2 +-
 net/netfilter/nf_conntrack_core.c            | 12 ++++++------
 net/netfilter/nf_conntrack_netlink.c         | 22 +++++++++++-----------
 net/netfilter/nf_conntrack_proto.c           | 20 ++++++++++----------
 net/netfilter/nfnetlink_cttimeout.c          | 14 +++++++-------
 net/netfilter/xt_CT.c                        |  2 +-
 net/openvswitch/conntrack.c                  |  4 ++--
 9 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index dabb53b0913c..6269deecbee7 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -64,10 +64,10 @@ struct nf_conntrack_l3proto {
 extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[NFPROTO_NUMPROTO];
 
 /* Protocol global registration. */
-int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto);
-void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto);
+int nf_ct_l3proto_register(const struct nf_conntrack_l3proto *proto);
+void nf_ct_l3proto_unregister(const struct nf_conntrack_l3proto *proto);
 
-struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
+const struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
 
 /* Existing built-in protocols */
 extern struct nf_conntrack_l3proto nf_conntrack_l3proto_generic;
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 4976ef92dc78..d4933d56809d 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -114,10 +114,10 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
 
 #define MAX_NF_CT_PROTO 256
 
-struct nf_conntrack_l4proto *__nf_ct_l4proto_find(u_int16_t l3proto,
+const struct nf_conntrack_l4proto *__nf_ct_l4proto_find(u_int16_t l3proto,
 						  u_int8_t l4proto);
 
-struct nf_conntrack_l4proto *nf_ct_l4proto_find_get(u_int16_t l3proto,
+const struct nf_conntrack_l4proto *nf_ct_l4proto_find_get(u_int16_t l3proto,
 						    u_int8_t l4proto);
 void nf_ct_l4proto_put(const struct nf_conntrack_l4proto *p);
 
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index b222957062b5..483d104fa254 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -16,7 +16,7 @@ struct ctnl_timeout {
 	refcount_t		refcnt;
 	char			name[CTNL_TIMEOUT_NAME_MAX];
 	__u16			l3num;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	char			data[0];
 };
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f2f00eaf217d..c23df7c9cd59 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -250,8 +250,8 @@ bool nf_ct_get_tuplepr(const struct sk_buff *skb, unsigned int nhoff,
 		       u_int16_t l3num,
 		       struct net *net, struct nf_conntrack_tuple *tuple)
 {
-	struct nf_conntrack_l3proto *l3proto;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l3proto *l3proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	unsigned int protoff;
 	u_int8_t protonum;
 	int ret;
@@ -400,7 +400,7 @@ static void
 destroy_conntrack(struct nf_conntrack *nfct)
 {
 	struct nf_conn *ct = (struct nf_conn *)nfct;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 
 	pr_debug("destroy_conntrack(%p)\n", ct);
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
@@ -694,7 +694,7 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 {
 	/* This is the conntrack entry already in hashes that won race. */
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
 	if (l4proto->allow_clash &&
@@ -1344,10 +1344,10 @@ unsigned int
 nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		struct sk_buff *skb)
 {
+	const struct nf_conntrack_l3proto *l3proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct nf_conn *ct, *tmpl;
 	enum ip_conntrack_info ctinfo;
-	struct nf_conntrack_l3proto *l3proto;
-	struct nf_conntrack_l4proto *l4proto;
 	unsigned int *timeouts;
 	unsigned int dataoff;
 	u_int8_t protonum;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b59a453a0fd8..de4053d84364 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -109,9 +109,9 @@ static int ctnetlink_dump_tuples_ip(struct sk_buff *skb,
 static int ctnetlink_dump_tuples(struct sk_buff *skb,
 				 const struct nf_conntrack_tuple *tuple)
 {
+	const struct nf_conntrack_l3proto *l3proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	int ret;
-	struct nf_conntrack_l3proto *l3proto;
-	struct nf_conntrack_l4proto *l4proto;
 
 	rcu_read_lock();
 	l3proto = __nf_ct_l3proto_find(tuple->src.l3num);
@@ -163,7 +163,7 @@ static int ctnetlink_dump_timeout(struct sk_buff *skb, const struct nf_conn *ct)
 
 static int ctnetlink_dump_protoinfo(struct sk_buff *skb, struct nf_conn *ct)
 {
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *nest_proto;
 	int ret;
 
@@ -535,9 +535,9 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 
 static inline size_t ctnetlink_proto_size(const struct nf_conn *ct)
 {
-	struct nf_conntrack_l3proto *l3proto;
-	struct nf_conntrack_l4proto *l4proto;
-	size_t len = 0;
+	const struct nf_conntrack_l3proto *l3proto;
+	const struct nf_conntrack_l4proto *l4proto;
+	size_t len;
 
 	l3proto = __nf_ct_l3proto_find(nf_ct_l3num(ct));
 	len = l3proto->nla_size;
@@ -936,8 +936,8 @@ static const struct nla_policy proto_nla_policy[CTA_PROTO_MAX+1] = {
 static int ctnetlink_parse_tuple_proto(struct nlattr *attr,
 				       struct nf_conntrack_tuple *tuple)
 {
+	const struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *tb[CTA_PROTO_MAX+1];
-	struct nf_conntrack_l4proto *l4proto;
 	int ret = 0;
 
 	ret = nla_parse_nested(tb, CTA_PROTO_MAX, attr, proto_nla_policy,
@@ -1580,8 +1580,8 @@ static int ctnetlink_change_protoinfo(struct nf_conn *ct,
 				      const struct nlattr * const cda[])
 {
 	const struct nlattr *attr = cda[CTA_PROTOINFO];
+	const struct nf_conntrack_l4proto *l4proto;
 	struct nlattr *tb[CTA_PROTOINFO_MAX+1];
-	struct nf_conntrack_l4proto *l4proto;
 	int err = 0;
 
 	err = nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, protoinfo_policy,
@@ -2475,11 +2475,11 @@ static int ctnetlink_exp_dump_mask(struct sk_buff *skb,
 				   const struct nf_conntrack_tuple *tuple,
 				   const struct nf_conntrack_tuple_mask *mask)
 {
-	int ret;
-	struct nf_conntrack_l3proto *l3proto;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l3proto *l3proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct nf_conntrack_tuple m;
 	struct nlattr *nest_parms;
+	int ret;
 
 	memset(&m, 0xFF, sizeof(m));
 	memcpy(&m.src.u3, &mask->src.u3, sizeof(m.src.u3));
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 0ecab7163d62..b3e489c859ec 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -65,7 +65,7 @@ nf_ct_unregister_sysctl(struct ctl_table_header **header,
 }
 #endif
 
-struct nf_conntrack_l4proto *
+const struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto)
 {
 	if (unlikely(l3proto >= NFPROTO_NUMPROTO || nf_ct_protos[l3proto] == NULL))
@@ -77,7 +77,7 @@ EXPORT_SYMBOL_GPL(__nf_ct_l4proto_find);
 
 /* this is guaranteed to always return a valid protocol helper, since
  * it falls back to generic_protocol */
-struct nf_conntrack_l3proto *
+const struct nf_conntrack_l3proto *
 nf_ct_l3proto_find_get(u_int16_t l3proto)
 {
 	struct nf_conntrack_l3proto *p;
@@ -95,8 +95,8 @@ EXPORT_SYMBOL_GPL(nf_ct_l3proto_find_get);
 int
 nf_ct_l3proto_try_module_get(unsigned short l3proto)
 {
+	const struct nf_conntrack_l3proto *p;
 	int ret;
-	struct nf_conntrack_l3proto *p;
 
 retry:	p = nf_ct_l3proto_find_get(l3proto);
 	if (p == &nf_conntrack_l3proto_generic) {
@@ -173,10 +173,10 @@ void nf_ct_netns_put(struct net *net, u8 nfproto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_netns_put);
 
-struct nf_conntrack_l4proto *
+const struct nf_conntrack_l4proto *
 nf_ct_l4proto_find_get(u_int16_t l3num, u_int8_t l4num)
 {
-	struct nf_conntrack_l4proto *p;
+	const struct nf_conntrack_l4proto *p;
 
 	rcu_read_lock();
 	p = __nf_ct_l4proto_find(l3num, l4num);
@@ -196,18 +196,18 @@ EXPORT_SYMBOL_GPL(nf_ct_l4proto_put);
 
 static int kill_l3proto(struct nf_conn *i, void *data)
 {
-	return nf_ct_l3num(i) == ((struct nf_conntrack_l3proto *)data)->l3proto;
+	return nf_ct_l3num(i) == ((const struct nf_conntrack_l3proto *)data)->l3proto;
 }
 
 static int kill_l4proto(struct nf_conn *i, void *data)
 {
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	l4proto = data;
 	return nf_ct_protonum(i) == l4proto->l4proto &&
 	       nf_ct_l3num(i) == l4proto->l3proto;
 }
 
-int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
+int nf_ct_l3proto_register(const struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
 	struct nf_conntrack_l3proto *old;
@@ -235,7 +235,7 @@ int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_register);
 
-void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
+void nf_ct_l3proto_unregister(const struct nf_conntrack_l3proto *proto)
 {
 	BUG_ON(proto->l3proto >= NFPROTO_NUMPROTO);
 
@@ -249,7 +249,7 @@ void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 
 	synchronize_rcu();
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_destroy(kill_l3proto, proto);
+	nf_ct_iterate_destroy(kill_l3proto, (void*)proto);
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_unregister);
 
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index fcabccc99f0d..32b1c0b44e79 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -75,7 +75,7 @@ static int cttimeout_new_timeout(struct net *net, struct sock *ctnl,
 {
 	__u16 l3num;
 	__u8 l4num;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct ctnl_timeout *timeout, *matching = NULL;
 	char *name;
 	int ret;
@@ -159,7 +159,7 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
-	struct nf_conntrack_l4proto *l4proto = timeout->l4proto;
+	const struct nf_conntrack_l4proto *l4proto = timeout->l4proto;
 
 	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_TIMEOUT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
@@ -364,10 +364,10 @@ static int cttimeout_default_set(struct net *net, struct sock *ctnl,
 				 const struct nlattr * const cda[],
 				 struct netlink_ext_ack *extack)
 {
+	const struct nf_conntrack_l4proto *l4proto;
+	unsigned int *timeouts;
 	__u16 l3num;
 	__u8 l4num;
-	struct nf_conntrack_l4proto *l4proto;
-	unsigned int *timeouts;
 	int ret;
 
 	if (!cda[CTA_TIMEOUT_L3PROTO] ||
@@ -454,11 +454,11 @@ static int cttimeout_default_get(struct net *net, struct sock *ctnl,
 				 const struct nlattr * const cda[],
 				 struct netlink_ext_ack *extack)
 {
-	__u16 l3num;
-	__u8 l4num;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct sk_buff *skb2;
 	int ret, err;
+	__u16 l3num;
+	__u8 l4num;
 
 	if (!cda[CTA_TIMEOUT_L3PROTO] || !cda[CTA_TIMEOUT_L4PROTO])
 		return -EINVAL;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 623ef37de886..5a152e2acfd5 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -121,9 +121,9 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 {
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
 	typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct ctnl_timeout *timeout;
 	struct nf_conn_timeout *timeout_ext;
-	struct nf_conntrack_l4proto *l4proto;
 	int ret = 0;
 	u8 proto;
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index e3c4c6c3fef7..283363534647 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -579,8 +579,8 @@ static struct nf_conn *
 ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 		     u8 l3num, struct sk_buff *skb, bool natted)
 {
-	struct nf_conntrack_l3proto *l3proto;
-	struct nf_conntrack_l4proto *l4proto;
+	const struct nf_conntrack_l3proto *l3proto;
+	const struct nf_conntrack_l4proto *l4proto;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
-- 
2.1.4


