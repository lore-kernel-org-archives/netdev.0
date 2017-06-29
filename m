From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 29/29] netfilter: nfnetlink: extended ACK reporting
Date: Fri, 30 Jun 2017 00:53:27 +0200
Message-ID: <1498776807-11124-30-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass down struct netlink_ext_ack as parameter to all of our nfnetlink
subsystem callbacks, so we can work on follow up patches to provide
finer grain error reporting using the new infrastructure that
2d4bc93368f5 ("netlink: extended ACK reporting") provides.

No functional change, just pass down this new object to callbacks.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h  | 10 +++---
 net/netfilter/ipset/ip_set_core.c    | 39 ++++++++++++++++--------
 net/netfilter/nf_conntrack_netlink.c | 39 ++++++++++++++++--------
 net/netfilter/nf_tables_api.c        | 59 ++++++++++++++++++++++++------------
 net/netfilter/nfnetlink.c            | 21 +++++++++----
 net/netfilter/nfnetlink_acct.c       |  9 ++++--
 net/netfilter/nfnetlink_cthelper.c   |  9 ++++--
 net/netfilter/nfnetlink_cttimeout.c  | 15 ++++++---
 net/netfilter/nfnetlink_log.c        |  6 ++--
 net/netfilter/nfnetlink_queue.c      | 12 +++++---
 net/netfilter/nft_compat.c           |  3 +-
 net/netfilter/xt_osf.c               |  6 ++--
 12 files changed, 152 insertions(+), 76 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 996711d8a7b4..41d04e9d088a 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -1,7 +1,6 @@
 #ifndef _NFNETLINK_H
 #define _NFNETLINK_H
 
-
 #include <linux/netlink.h>
 #include <linux/capability.h>
 #include <net/netlink.h>
@@ -10,13 +9,16 @@
 struct nfnl_callback {
 	int (*call)(struct net *net, struct sock *nl, struct sk_buff *skb,
 		    const struct nlmsghdr *nlh,
-		    const struct nlattr * const cda[]);
+		    const struct nlattr * const cda[],
+		    struct netlink_ext_ack *extack);
 	int (*call_rcu)(struct net *net, struct sock *nl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
-			const struct nlattr * const cda[]);
+			const struct nlattr * const cda[],
+			struct netlink_ext_ack *extack);
 	int (*call_batch)(struct net *net, struct sock *nl, struct sk_buff *skb,
 			  const struct nlmsghdr *nlh,
-			  const struct nlattr * const cda[]);
+			  const struct nlattr * const cda[],
+			  struct netlink_ext_ack *extack);
 	const struct nla_policy *policy;	/* netlink attribute policy */
 	const u_int16_t attr_count;		/* number of nlattr's */
 };
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index ba6a5516dc7c..e495b5e484b1 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -841,14 +841,16 @@ find_free_id(struct ip_set_net *inst, const char *name, ip_set_id_t *index,
 
 static int ip_set_none(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const attr[])
+		       const struct nlattr * const attr[],
+		       struct netlink_ext_ack *extack)
 {
 	return -EOPNOTSUPP;
 }
 
 static int ip_set_create(struct net *net, struct sock *ctnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
-			 const struct nlattr * const attr[])
+			 const struct nlattr * const attr[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set, *clash = NULL;
@@ -989,7 +991,8 @@ ip_set_destroy_set(struct ip_set *set)
 
 static int ip_set_destroy(struct net *net, struct sock *ctnl,
 			  struct sk_buff *skb, const struct nlmsghdr *nlh,
-			  const struct nlattr * const attr[])
+			  const struct nlattr * const attr[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *s;
@@ -1067,7 +1070,8 @@ ip_set_flush_set(struct ip_set *set)
 
 static int ip_set_flush(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
-			const struct nlattr * const attr[])
+			const struct nlattr * const attr[],
+			struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *s;
@@ -1106,7 +1110,8 @@ ip_set_setname2_policy[IPSET_ATTR_CMD_MAX + 1] = {
 
 static int ip_set_rename(struct net *net, struct sock *ctnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
-			 const struct nlattr * const attr[])
+			 const struct nlattr * const attr[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set, *s;
@@ -1155,7 +1160,8 @@ static int ip_set_rename(struct net *net, struct sock *ctnl,
 
 static int ip_set_swap(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const attr[])
+		       const struct nlattr * const attr[],
+		       struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *from, *to;
@@ -1428,7 +1434,8 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 
 static int ip_set_dump(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const attr[])
+		       const struct nlattr * const attr[],
+		       struct netlink_ext_ack *extack)
 {
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
@@ -1513,7 +1520,8 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 
 static int ip_set_uadd(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const attr[])
+		       const struct nlattr * const attr[],
+		       struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set;
@@ -1567,7 +1575,8 @@ static int ip_set_uadd(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 
 static int ip_set_udel(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const attr[])
+		       const struct nlattr * const attr[],
+		       struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set;
@@ -1621,7 +1630,8 @@ static int ip_set_udel(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 
 static int ip_set_utest(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
-			const struct nlattr * const attr[])
+			const struct nlattr * const attr[],
+			struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set;
@@ -1656,7 +1666,8 @@ static int ip_set_utest(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 
 static int ip_set_header(struct net *net, struct sock *ctnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
-			 const struct nlattr * const attr[])
+			 const struct nlattr * const attr[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ip_set_net *inst = ip_set_pernet(net);
 	const struct ip_set *set;
@@ -1712,7 +1723,8 @@ static const struct nla_policy ip_set_type_policy[IPSET_ATTR_CMD_MAX + 1] = {
 
 static int ip_set_type(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const attr[])
+		       const struct nlattr * const attr[],
+		       struct netlink_ext_ack *extack)
 {
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
@@ -1770,7 +1782,8 @@ ip_set_protocol_policy[IPSET_ATTR_CMD_MAX + 1] = {
 
 static int ip_set_protocol(struct net *net, struct sock *ctnl,
 			   struct sk_buff *skb, const struct nlmsghdr *nlh,
-			   const struct nlattr * const attr[])
+			   const struct nlattr * const attr[],
+			   struct netlink_ext_ack *extack)
 {
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index e1eca47105bd..573eb83d5d17 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1127,7 +1127,8 @@ static int ctnetlink_flush_conntrack(struct net *net,
 static int ctnetlink_del_conntrack(struct net *net, struct sock *ctnl,
 				   struct sk_buff *skb,
 				   const struct nlmsghdr *nlh,
-				   const struct nlattr * const cda[])
+				   const struct nlattr * const cda[],
+				   struct netlink_ext_ack *extack)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
@@ -1179,7 +1180,8 @@ static int ctnetlink_del_conntrack(struct net *net, struct sock *ctnl,
 static int ctnetlink_get_conntrack(struct net *net, struct sock *ctnl,
 				   struct sk_buff *skb,
 				   const struct nlmsghdr *nlh,
-				   const struct nlattr * const cda[])
+				   const struct nlattr * const cda[],
+				   struct netlink_ext_ack *extack)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
@@ -1340,7 +1342,8 @@ ctnetlink_dump_dying(struct sk_buff *skb, struct netlink_callback *cb)
 static int ctnetlink_get_ct_dying(struct net *net, struct sock *ctnl,
 				  struct sk_buff *skb,
 				  const struct nlmsghdr *nlh,
-				  const struct nlattr * const cda[])
+				  const struct nlattr * const cda[],
+				  struct netlink_ext_ack *extack)
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -1362,7 +1365,8 @@ ctnetlink_dump_unconfirmed(struct sk_buff *skb, struct netlink_callback *cb)
 static int ctnetlink_get_ct_unconfirmed(struct net *net, struct sock *ctnl,
 					struct sk_buff *skb,
 					const struct nlmsghdr *nlh,
-					const struct nlattr * const cda[])
+					const struct nlattr * const cda[],
+					struct netlink_ext_ack *extack)
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -1901,7 +1905,8 @@ ctnetlink_create_conntrack(struct net *net,
 static int ctnetlink_new_conntrack(struct net *net, struct sock *ctnl,
 				   struct sk_buff *skb,
 				   const struct nlmsghdr *nlh,
-				   const struct nlattr * const cda[])
+				   const struct nlattr * const cda[],
+				   struct netlink_ext_ack *extack)
 {
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
@@ -2066,7 +2071,8 @@ ctnetlink_ct_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
 static int ctnetlink_stat_ct_cpu(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -2111,7 +2117,8 @@ ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 
 static int ctnetlink_stat_ct(struct net *net, struct sock *ctnl,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const cda[])
+			     const struct nlattr * const cda[],
+			     struct netlink_ext_ack *extack)
 {
 	struct sk_buff *skb2;
 	int err;
@@ -2773,7 +2780,8 @@ ctnetlink_exp_ct_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 static int ctnetlink_dump_exp_ct(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	int err;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -2817,7 +2825,8 @@ static int ctnetlink_dump_exp_ct(struct net *net, struct sock *ctnl,
 
 static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
-				const struct nlattr * const cda[])
+				const struct nlattr * const cda[],
+				struct netlink_ext_ack *extack)
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
@@ -2829,7 +2838,8 @@ static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		if (cda[CTA_EXPECT_MASTER])
-			return ctnetlink_dump_exp_ct(net, ctnl, skb, nlh, cda);
+			return ctnetlink_dump_exp_ct(net, ctnl, skb, nlh, cda,
+						     extack);
 		else {
 			struct netlink_dump_control c = {
 				.dump = ctnetlink_exp_dump_table,
@@ -2897,7 +2907,8 @@ static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
 
 static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
-				const struct nlattr * const cda[])
+				const struct nlattr * const cda[],
+				struct netlink_ext_ack *extack)
 {
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
@@ -3185,7 +3196,8 @@ ctnetlink_create_expect(struct net *net,
 
 static int ctnetlink_new_expect(struct net *net, struct sock *ctnl,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
-				const struct nlattr * const cda[])
+				const struct nlattr * const cda[],
+				struct netlink_ext_ack *extack)
 {
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
@@ -3291,7 +3303,8 @@ ctnetlink_exp_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
 static int ctnetlink_stat_exp_cpu(struct net *net, struct sock *ctnl,
 				  struct sk_buff *skb,
 				  const struct nlmsghdr *nlh,
-				  const struct nlattr * const cda[])
+				  const struct nlattr * const cda[],
+				  struct netlink_ext_ack *extack)
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 5f3339978f6b..7843efa33c59 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -535,7 +535,8 @@ static int nf_tables_dump_tables(struct sk_buff *skb,
 
 static int nf_tables_gettable(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			      const struct nlattr * const nla[],
+			      struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_cur(net);
@@ -678,7 +679,8 @@ static int nf_tables_updtable(struct nft_ctx *ctx)
 
 static int nf_tables_newtable(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			      const struct nlattr * const nla[],
+			      struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -831,7 +833,8 @@ static int nft_flush(struct nft_ctx *ctx, int family)
 
 static int nf_tables_deltable(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			      const struct nlattr * const nla[],
+			      struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -1127,7 +1130,8 @@ static int nf_tables_dump_chains(struct sk_buff *skb,
 
 static int nf_tables_getchain(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			      const struct nlattr * const nla[],
+			      struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_cur(net);
@@ -1323,7 +1327,8 @@ static void nft_chain_release_hook(struct nft_chain_hook *hook)
 
 static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			      const struct nlattr * const nla[],
+			      struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nlattr * uninitialized_var(name);
@@ -1561,7 +1566,8 @@ static int nf_tables_newchain(struct net *net, struct sock *nlsk,
 
 static int nf_tables_delchain(struct net *net, struct sock *nlsk,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			      const struct nlattr * const nla[],
+			      struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -2042,7 +2048,8 @@ static int nf_tables_dump_rules_done(struct netlink_callback *cb)
 
 static int nf_tables_getrule(struct net *net, struct sock *nlsk,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const nla[])
+			     const struct nlattr * const nla[],
+			     struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_cur(net);
@@ -2135,7 +2142,8 @@ static struct nft_expr_info *info;
 
 static int nf_tables_newrule(struct net *net, struct sock *nlsk,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const nla[])
+			     const struct nlattr * const nla[],
+			     struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -2317,7 +2325,8 @@ static struct nft_rule *nft_rule_lookup_byid(const struct net *net,
 
 static int nf_tables_delrule(struct net *net, struct sock *nlsk,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const nla[])
+			     const struct nlattr * const nla[],
+			     struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -2833,7 +2842,8 @@ static int nf_tables_dump_sets_done(struct netlink_callback *cb)
 
 static int nf_tables_getset(struct net *net, struct sock *nlsk,
 			    struct sk_buff *skb, const struct nlmsghdr *nlh,
-			    const struct nlattr * const nla[])
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	u8 genmask = nft_genmask_cur(net);
 	const struct nft_set *set;
@@ -2909,7 +2919,8 @@ static int nf_tables_set_desc_parse(const struct nft_ctx *ctx,
 
 static int nf_tables_newset(struct net *net, struct sock *nlsk,
 			    struct sk_buff *skb, const struct nlmsghdr *nlh,
-			    const struct nlattr * const nla[])
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -3127,7 +3138,8 @@ static void nf_tables_set_destroy(const struct nft_ctx *ctx, struct nft_set *set
 
 static int nf_tables_delset(struct net *net, struct sock *nlsk,
 			    struct sk_buff *skb, const struct nlmsghdr *nlh,
-			    const struct nlattr * const nla[])
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -3487,7 +3499,8 @@ static int nf_tables_dump_set_done(struct netlink_callback *cb)
 
 static int nf_tables_getsetelem(struct net *net, struct sock *nlsk,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
-				const struct nlattr * const nla[])
+				const struct nlattr * const nla[],
+				struct netlink_ext_ack *extack)
 {
 	u8 genmask = nft_genmask_cur(net);
 	const struct nft_set *set;
@@ -3888,7 +3901,8 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 
 static int nf_tables_newsetelem(struct net *net, struct sock *nlsk,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
-				const struct nlattr * const nla[])
+				const struct nlattr * const nla[],
+				struct netlink_ext_ack *extack)
 {
 	u8 genmask = nft_genmask_next(net);
 	const struct nlattr *attr;
@@ -4085,7 +4099,8 @@ static int nft_flush_set(const struct nft_ctx *ctx,
 
 static int nf_tables_delsetelem(struct net *net, struct sock *nlsk,
 				struct sk_buff *skb, const struct nlmsghdr *nlh,
-				const struct nlattr * const nla[])
+				const struct nlattr * const nla[],
+				struct netlink_ext_ack *extack)
 {
 	u8 genmask = nft_genmask_next(net);
 	const struct nlattr *attr;
@@ -4295,7 +4310,8 @@ static const struct nft_object_type *nft_obj_type_get(u32 objtype)
 
 static int nf_tables_newobj(struct net *net, struct sock *nlsk,
 			    struct sk_buff *skb, const struct nlmsghdr *nlh,
-			    const struct nlattr * const nla[])
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_object_type *type;
@@ -4489,7 +4505,8 @@ nft_obj_filter_alloc(const struct nlattr * const nla[])
 
 static int nf_tables_getobj(struct net *net, struct sock *nlsk,
 			    struct sk_buff *skb, const struct nlmsghdr *nlh,
-			    const struct nlattr * const nla[])
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_cur(net);
@@ -4567,8 +4584,9 @@ static void nft_obj_destroy(struct nft_object *obj)
 }
 
 static int nf_tables_delobj(struct net *net, struct sock *nlsk,
-			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nla[])
+			    struct sk_buff *skb, const struct nlmsghdr *nlh,
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u8 genmask = nft_genmask_next(net);
@@ -4698,7 +4716,8 @@ static void nf_tables_gen_notify(struct net *net, struct sk_buff *skb,
 
 static int nf_tables_getgen(struct net *net, struct sock *nlsk,
 			    struct sk_buff *skb, const struct nlmsghdr *nlh,
-			    const struct nlattr * const nla[])
+			    const struct nlattr * const nla[],
+			    struct netlink_ext_ack *extack)
 {
 	struct sk_buff *skb2;
 	int err;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 80f5ecf2c3d7..92b05e188fd1 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -201,7 +201,8 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 		if (nc->call_rcu) {
 			err = nc->call_rcu(net, net->nfnl, skb, nlh,
-					   (const struct nlattr **)cda);
+					   (const struct nlattr **)cda,
+					   extack);
 			rcu_read_unlock();
 		} else {
 			rcu_read_unlock();
@@ -211,7 +212,8 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 				err = -EAGAIN;
 			else if (nc->call)
 				err = nc->call(net, net->nfnl, skb, nlh,
-					       (const struct nlattr **)cda);
+					       (const struct nlattr **)cda,
+					       extack);
 			else
 				err = -EINVAL;
 			nfnl_unlock(subsys_id);
@@ -226,9 +228,11 @@ struct nfnl_err {
 	struct list_head	head;
 	struct nlmsghdr		*nlh;
 	int			err;
+	struct netlink_ext_ack	extack;
 };
 
-static int nfnl_err_add(struct list_head *list, struct nlmsghdr *nlh, int err)
+static int nfnl_err_add(struct list_head *list, struct nlmsghdr *nlh, int err,
+			const struct netlink_ext_ack *extack)
 {
 	struct nfnl_err *nfnl_err;
 
@@ -238,6 +242,7 @@ static int nfnl_err_add(struct list_head *list, struct nlmsghdr *nlh, int err)
 
 	nfnl_err->nlh = nlh;
 	nfnl_err->err = err;
+	nfnl_err->extack = *extack;
 	list_add_tail(&nfnl_err->head, list);
 
 	return 0;
@@ -262,7 +267,8 @@ static void nfnl_err_deliver(struct list_head *err_list, struct sk_buff *skb)
 	struct nfnl_err *nfnl_err, *next;
 
 	list_for_each_entry_safe(nfnl_err, next, err_list, head) {
-		netlink_ack(skb, nfnl_err->nlh, nfnl_err->err, NULL);
+		netlink_ack(skb, nfnl_err->nlh, nfnl_err->err,
+			    &nfnl_err->extack);
 		nfnl_err_del(nfnl_err);
 	}
 }
@@ -280,6 +286,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	const struct nfnetlink_subsystem *ss;
 	const struct nfnl_callback *nc;
+	struct netlink_ext_ack extack;
 	LIST_HEAD(err_list);
 	u32 status;
 	int err;
@@ -325,6 +332,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	while (skb->len >= nlmsg_total_size(0)) {
 		int msglen, type;
 
+		memset(&extack, 0, sizeof(extack));
 		nlh = nlmsg_hdr(skb);
 		err = 0;
 
@@ -384,7 +392,8 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 			if (nc->call_batch) {
 				err = nc->call_batch(net, net->nfnl, skb, nlh,
-						     (const struct nlattr **)cda);
+						     (const struct nlattr **)cda,
+						     &extack);
 			}
 
 			/* The lock was released to autoload some module, we
@@ -402,7 +411,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 			 * processed, this avoids that the same error is
 			 * reported several times when replaying the batch.
 			 */
-			if (nfnl_err_add(&err_list, nlh, err) < 0) {
+			if (nfnl_err_add(&err_list, nlh, err, &extack) < 0) {
 				/* We failed to enqueue an error, reset the
 				 * list of errors and send OOM to userspace
 				 * pointing to the batch header.
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 9898fb4d0512..c45e6d4358ab 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -49,7 +49,8 @@ struct nfacct_filter {
 
 static int nfnl_acct_new(struct net *net, struct sock *nfnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
-			 const struct nlattr * const tb[])
+			 const struct nlattr * const tb[],
+			 struct netlink_ext_ack *extack)
 {
 	struct nf_acct *nfacct, *matching = NULL;
 	char *acct_name;
@@ -264,7 +265,8 @@ nfacct_filter_alloc(const struct nlattr * const attr)
 
 static int nfnl_acct_get(struct net *net, struct sock *nfnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
-			 const struct nlattr * const tb[])
+			 const struct nlattr * const tb[],
+			 struct netlink_ext_ack *extack)
 {
 	int ret = -ENOENT;
 	struct nf_acct *cur;
@@ -343,7 +345,8 @@ static int nfnl_acct_try_del(struct nf_acct *cur)
 
 static int nfnl_acct_del(struct net *net, struct sock *nfnl,
 			 struct sk_buff *skb, const struct nlmsghdr *nlh,
-			 const struct nlattr * const tb[])
+			 const struct nlattr * const tb[],
+			 struct netlink_ext_ack *extack)
 {
 	struct nf_acct *cur, *tmp;
 	int ret = -ENOENT;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index be678a323598..41628b393673 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -398,7 +398,8 @@ nfnl_cthelper_update(const struct nlattr * const tb[],
 
 static int nfnl_cthelper_new(struct net *net, struct sock *nfnl,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const tb[])
+			     const struct nlattr * const tb[],
+			     struct netlink_ext_ack *extack)
 {
 	const char *helper_name;
 	struct nf_conntrack_helper *cur, *helper = NULL;
@@ -599,7 +600,8 @@ nfnl_cthelper_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 
 static int nfnl_cthelper_get(struct net *net, struct sock *nfnl,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const tb[])
+			     const struct nlattr * const tb[],
+			     struct netlink_ext_ack *extack)
 {
 	int ret = -ENOENT;
 	struct nf_conntrack_helper *cur;
@@ -666,7 +668,8 @@ static int nfnl_cthelper_get(struct net *net, struct sock *nfnl,
 
 static int nfnl_cthelper_del(struct net *net, struct sock *nfnl,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const tb[])
+			     const struct nlattr * const tb[],
+			     struct netlink_ext_ack *extack)
 {
 	char *helper_name = NULL;
 	struct nf_conntrack_helper *cur;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 49638b03ccc9..400e9ae97153 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -69,7 +69,8 @@ ctnl_timeout_parse_policy(void *timeouts, struct nf_conntrack_l4proto *l4proto,
 static int cttimeout_new_timeout(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	__u16 l3num;
 	__u8 l4num;
@@ -239,7 +240,8 @@ ctnl_timeout_dump(struct sk_buff *skb, struct netlink_callback *cb)
 static int cttimeout_get_timeout(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	int ret = -ENOENT;
 	char *name;
@@ -326,7 +328,8 @@ static int ctnl_timeout_try_del(struct net *net, struct ctnl_timeout *timeout)
 static int cttimeout_del_timeout(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	struct ctnl_timeout *cur, *tmp;
 	int ret = -ENOENT;
@@ -357,7 +360,8 @@ static int cttimeout_del_timeout(struct net *net, struct sock *ctnl,
 static int cttimeout_default_set(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	__u16 l3num;
 	__u8 l4num;
@@ -446,7 +450,8 @@ cttimeout_default_fill_info(struct net *net, struct sk_buff *skb, u32 portid,
 static int cttimeout_default_get(struct net *net, struct sock *ctnl,
 				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
-				 const struct nlattr * const cda[])
+				 const struct nlattr * const cda[],
+				 struct netlink_ext_ack *extack)
 {
 	__u16 l3num;
 	__u8 l4num;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index da9704971a83..9c14892ee65f 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -795,7 +795,8 @@ static struct notifier_block nfulnl_rtnl_notifier = {
 
 static int nfulnl_recv_unsupp(struct net *net, struct sock *ctnl,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nfqa[])
+			      const struct nlattr * const nfqa[],
+			      struct netlink_ext_ack *extack)
 {
 	return -ENOTSUPP;
 }
@@ -818,7 +819,8 @@ static const struct nla_policy nfula_cfg_policy[NFULA_CFG_MAX+1] = {
 
 static int nfulnl_recv_config(struct net *net, struct sock *ctnl,
 			      struct sk_buff *skb, const struct nlmsghdr *nlh,
-			      const struct nlattr * const nfula[])
+			      const struct nlattr * const nfula[],
+			      struct netlink_ext_ack *extack)
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t group_num = ntohs(nfmsg->res_id);
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 8a0f218b7938..12b7dc11b6b5 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1032,7 +1032,8 @@ static int nfq_id_after(unsigned int id, unsigned int max)
 static int nfqnl_recv_verdict_batch(struct net *net, struct sock *ctnl,
 				    struct sk_buff *skb,
 				    const struct nlmsghdr *nlh,
-			            const struct nlattr * const nfqa[])
+			            const struct nlattr * const nfqa[],
+				    struct netlink_ext_ack *extack)
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct nf_queue_entry *entry, *tmp;
@@ -1136,7 +1137,8 @@ static int nfqa_parse_bridge(struct nf_queue_entry *entry,
 static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 			      struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
-			      const struct nlattr * const nfqa[])
+			      const struct nlattr * const nfqa[],
+			      struct netlink_ext_ack *extack)
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
@@ -1200,7 +1202,8 @@ static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 
 static int nfqnl_recv_unsupp(struct net *net, struct sock *ctnl,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const nfqa[])
+			     const struct nlattr * const nfqa[],
+			     struct netlink_ext_ack *extack)
 {
 	return -ENOTSUPP;
 }
@@ -1217,7 +1220,8 @@ static const struct nf_queue_handler nfqh = {
 
 static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
 			     struct sk_buff *skb, const struct nlmsghdr *nlh,
-			     const struct nlattr * const nfqa[])
+			     const struct nlattr * const nfqa[],
+			     struct netlink_ext_ack *extack)
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index f753ec69f790..f5a7cb68694e 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -530,7 +530,8 @@ nfnl_compat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 
 static int nfnl_compat_get(struct net *net, struct sock *nfnl,
 			   struct sk_buff *skb, const struct nlmsghdr *nlh,
-			   const struct nlattr * const tb[])
+			   const struct nlattr * const tb[],
+			   struct netlink_ext_ack *extack)
 {
 	int ret = 0, target;
 	struct nfgenmsg *nfmsg;
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index c05fefcec238..71cfa9551d08 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -63,7 +63,8 @@ static const struct nla_policy xt_osf_policy[OSF_ATTR_MAX + 1] = {
 
 static int xt_osf_add_callback(struct net *net, struct sock *ctnl,
 			       struct sk_buff *skb, const struct nlmsghdr *nlh,
-			       const struct nlattr * const osf_attrs[])
+			       const struct nlattr * const osf_attrs[],
+			       struct netlink_ext_ack *extack)
 {
 	struct xt_osf_user_finger *f;
 	struct xt_osf_finger *kf = NULL, *sf;
@@ -107,7 +108,8 @@ static int xt_osf_add_callback(struct net *net, struct sock *ctnl,
 static int xt_osf_remove_callback(struct net *net, struct sock *ctnl,
 				  struct sk_buff *skb,
 				  const struct nlmsghdr *nlh,
-				  const struct nlattr * const osf_attrs[])
+				  const struct nlattr * const osf_attrs[],
+				  struct netlink_ext_ack *extack)
 {
 	struct xt_osf_user_finger *f;
 	struct xt_osf_finger *sf;
-- 
2.1.4

