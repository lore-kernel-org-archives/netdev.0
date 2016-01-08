From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/17] netfilter: nfnetlink: pass down netns pointer to call() and call_rcu()
Date: Fri,  8 Jan 2016 15:02:04 +0100
Message-ID: <1452261737-7475-5-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adapt callsites to avoid recurrent lookup of the netns pointer.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h  |   8 +--
 net/netfilter/ipset/ip_set_core.c    | 108 +++++++++++++++--------------------
 net/netfilter/nf_conntrack_netlink.c |  96 ++++++++++++++-----------------
 net/netfilter/nf_tables_api.c        |  30 ++++------
 net/netfilter/nfnetlink.c            |   6 +-
 net/netfilter/nfnetlink_acct.c       |  21 +++----
 net/netfilter/nfnetlink_cthelper.c   |  18 +++---
 net/netfilter/nfnetlink_cttimeout.c  |  42 ++++++--------
 net/netfilter/nfnetlink_log.c        |  15 ++---
 net/netfilter/nfnetlink_queue.c      |  36 +++++-------
 net/netfilter/nft_compat.c           |   6 +-
 net/netfilter/xt_osf.c               |   7 ++-
 12 files changed, 173 insertions(+), 220 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 5646b24..ceacbf5 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -8,12 +8,12 @@
 #include <uapi/linux/netfilter/nfnetlink.h>
 
 struct nfnl_callback {
-	int (*call)(struct sock *nl, struct sk_buff *skb, 
-		    const struct nlmsghdr *nlh,
-		    const struct nlattr * const cda[]);
-	int (*call_rcu)(struct sock *nl, struct sk_buff *skb, 
+	int (*call)(struct net *net, struct sock *nl, struct sk_buff *skb,
 		    const struct nlmsghdr *nlh,
 		    const struct nlattr * const cda[]);
+	int (*call_rcu)(struct net *net, struct sock *nl, struct sk_buff *skb,
+			const struct nlmsghdr *nlh,
+			const struct nlattr * const cda[]);
 	int (*call_batch)(struct net *net, struct sock *nl, struct sk_buff *skb,
 			  const struct nlmsghdr *nlh,
 			  const struct nlattr * const cda[]);
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 54f3d7c..95db43f 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -825,20 +825,17 @@ find_free_id(struct ip_set_net *inst, const char *name, ip_set_id_t *index,
 	return 0;
 }
 
-static int
-ip_set_none(struct sock *ctnl, struct sk_buff *skb,
-	    const struct nlmsghdr *nlh,
-	    const struct nlattr * const attr[])
+static int ip_set_none(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const attr[])
 {
 	return -EOPNOTSUPP;
 }
 
-static int
-ip_set_create(struct sock *ctnl, struct sk_buff *skb,
-	      const struct nlmsghdr *nlh,
-	      const struct nlattr * const attr[])
+static int ip_set_create(struct net *net, struct sock *ctnl,
+			 struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 const struct nlattr * const attr[])
 {
-	struct net *net = sock_net(ctnl);
 	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set, *clash = NULL;
 	ip_set_id_t index = IPSET_INVALID_ID;
@@ -976,12 +973,11 @@ ip_set_destroy_set(struct ip_set *set)
 	kfree(set);
 }
 
-static int
-ip_set_destroy(struct sock *ctnl, struct sk_buff *skb,
-	       const struct nlmsghdr *nlh,
-	       const struct nlattr * const attr[])
+static int ip_set_destroy(struct net *net, struct sock *ctnl,
+			  struct sk_buff *skb, const struct nlmsghdr *nlh,
+			  const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *s;
 	ip_set_id_t i;
 	int ret = 0;
@@ -1052,12 +1048,11 @@ ip_set_flush_set(struct ip_set *set)
 	spin_unlock_bh(&set->lock);
 }
 
-static int
-ip_set_flush(struct sock *ctnl, struct sk_buff *skb,
-	     const struct nlmsghdr *nlh,
-	     const struct nlattr * const attr[])
+static int ip_set_flush(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+			const struct nlmsghdr *nlh,
+			const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *s;
 	ip_set_id_t i;
 
@@ -1092,12 +1087,11 @@ ip_set_setname2_policy[IPSET_ATTR_CMD_MAX + 1] = {
 				    .len = IPSET_MAXNAMELEN - 1 },
 };
 
-static int
-ip_set_rename(struct sock *ctnl, struct sk_buff *skb,
-	      const struct nlmsghdr *nlh,
-	      const struct nlattr * const attr[])
+static int ip_set_rename(struct net *net, struct sock *ctnl,
+			 struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set, *s;
 	const char *name2;
 	ip_set_id_t i;
@@ -1142,12 +1136,11 @@ out:
  * so the ip_set_list always contains valid pointers to the sets.
  */
 
-static int
-ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
-	    const struct nlmsghdr *nlh,
-	    const struct nlattr * const attr[])
+static int ip_set_swap(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *from, *to;
 	ip_set_id_t from_id, to_id;
 	char from_name[IPSET_MAXNAMELEN];
@@ -1413,10 +1406,9 @@ out:
 	return ret < 0 ? ret : skb->len;
 }
 
-static int
-ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
-	    const struct nlmsghdr *nlh,
-	    const struct nlattr * const attr[])
+static int ip_set_dump(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const attr[])
 {
 	if (unlikely(protocol_failed(attr)))
 		return -IPSET_ERR_PROTOCOL;
@@ -1500,12 +1492,11 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 	return ret;
 }
 
-static int
-ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
-	    const struct nlmsghdr *nlh,
-	    const struct nlattr * const attr[])
+static int ip_set_uadd(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set;
 	struct nlattr *tb[IPSET_ATTR_ADT_MAX + 1] = {};
 	const struct nlattr *nla;
@@ -1555,12 +1546,11 @@ ip_set_uadd(struct sock *ctnl, struct sk_buff *skb,
 	return ret;
 }
 
-static int
-ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
-	    const struct nlmsghdr *nlh,
-	    const struct nlattr * const attr[])
+static int ip_set_udel(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set;
 	struct nlattr *tb[IPSET_ATTR_ADT_MAX + 1] = {};
 	const struct nlattr *nla;
@@ -1610,12 +1600,11 @@ ip_set_udel(struct sock *ctnl, struct sk_buff *skb,
 	return ret;
 }
 
-static int
-ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
-	     const struct nlmsghdr *nlh,
-	     const struct nlattr * const attr[])
+static int ip_set_utest(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+			const struct nlmsghdr *nlh,
+			const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	struct ip_set *set;
 	struct nlattr *tb[IPSET_ATTR_ADT_MAX + 1] = {};
 	int ret = 0;
@@ -1646,12 +1635,11 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 
 /* Get headed data of a set */
 
-static int
-ip_set_header(struct sock *ctnl, struct sk_buff *skb,
-	      const struct nlmsghdr *nlh,
-	      const struct nlattr * const attr[])
+static int ip_set_header(struct net *net, struct sock *ctnl,
+			 struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 const struct nlattr * const attr[])
 {
-	struct ip_set_net *inst = ip_set_pernet(sock_net(ctnl));
+	struct ip_set_net *inst = ip_set_pernet(net);
 	const struct ip_set *set;
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
@@ -1703,10 +1691,9 @@ static const struct nla_policy ip_set_type_policy[IPSET_ATTR_CMD_MAX + 1] = {
 	[IPSET_ATTR_FAMILY]	= { .type = NLA_U8 },
 };
 
-static int
-ip_set_type(struct sock *ctnl, struct sk_buff *skb,
-	    const struct nlmsghdr *nlh,
-	    const struct nlattr * const attr[])
+static int ip_set_type(struct net *net, struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const attr[])
 {
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
@@ -1762,10 +1749,9 @@ ip_set_protocol_policy[IPSET_ATTR_CMD_MAX + 1] = {
 	[IPSET_ATTR_PROTOCOL]	= { .type = NLA_U8 },
 };
 
-static int
-ip_set_protocol(struct sock *ctnl, struct sk_buff *skb,
-		const struct nlmsghdr *nlh,
-		const struct nlattr * const attr[])
+static int ip_set_protocol(struct net *net, struct sock *ctnl,
+			   struct sk_buff *skb, const struct nlmsghdr *nlh,
+			   const struct nlattr * const attr[])
 {
 	struct sk_buff *skb2;
 	struct nlmsghdr *nlh2;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9f52729..dbb1bb3 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1113,12 +1113,11 @@ static int ctnetlink_flush_conntrack(struct net *net,
 	return 0;
 }
 
-static int
-ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			const struct nlmsghdr *nlh,
-			const struct nlattr * const cda[])
+static int ctnetlink_del_conntrack(struct net *net, struct sock *ctnl,
+				   struct sk_buff *skb,
+				   const struct nlmsghdr *nlh,
+				   const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
@@ -1168,12 +1167,11 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	return 0;
 }
 
-static int
-ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			const struct nlmsghdr *nlh,
-			const struct nlattr * const cda[])
+static int ctnetlink_get_conntrack(struct net *net, struct sock *ctnl,
+				   struct sk_buff *skb,
+				   const struct nlmsghdr *nlh,
+				   const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
@@ -1330,10 +1328,10 @@ ctnetlink_dump_dying(struct sk_buff *skb, struct netlink_callback *cb)
 	return ctnetlink_dump_list(skb, cb, true);
 }
 
-static int
-ctnetlink_get_ct_dying(struct sock *ctnl, struct sk_buff *skb,
-		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const cda[])
+static int ctnetlink_get_ct_dying(struct net *net, struct sock *ctnl,
+				  struct sk_buff *skb,
+				  const struct nlmsghdr *nlh,
+				  const struct nlattr * const cda[])
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -1352,10 +1350,10 @@ ctnetlink_dump_unconfirmed(struct sk_buff *skb, struct netlink_callback *cb)
 	return ctnetlink_dump_list(skb, cb, false);
 }
 
-static int
-ctnetlink_get_ct_unconfirmed(struct sock *ctnl, struct sk_buff *skb,
-			     const struct nlmsghdr *nlh,
-			     const struct nlattr * const cda[])
+static int ctnetlink_get_ct_unconfirmed(struct net *net, struct sock *ctnl,
+					struct sk_buff *skb,
+					const struct nlmsghdr *nlh,
+					const struct nlattr * const cda[])
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -1865,12 +1863,11 @@ err1:
 	return ERR_PTR(err);
 }
 
-static int
-ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
-			const struct nlmsghdr *nlh,
-			const struct nlattr * const cda[])
+static int ctnetlink_new_conntrack(struct net *net, struct sock *ctnl,
+				   struct sk_buff *skb,
+				   const struct nlmsghdr *nlh,
+				   const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -2034,10 +2031,10 @@ ctnetlink_ct_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-static int
-ctnetlink_stat_ct_cpu(struct sock *ctnl, struct sk_buff *skb,
-		      const struct nlmsghdr *nlh,
-		      const struct nlattr * const cda[])
+static int ctnetlink_stat_ct_cpu(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
@@ -2080,10 +2077,9 @@ nlmsg_failure:
 	return -1;
 }
 
-static int
-ctnetlink_stat_ct(struct sock *ctnl, struct sk_buff *skb,
-		  const struct nlmsghdr *nlh,
-		  const struct nlattr * const cda[])
+static int ctnetlink_stat_ct(struct net *net, struct sock *ctnl,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     const struct nlattr * const cda[])
 {
 	struct sk_buff *skb2;
 	int err;
@@ -2729,12 +2725,12 @@ out:
 	return skb->len;
 }
 
-static int ctnetlink_dump_exp_ct(struct sock *ctnl, struct sk_buff *skb,
+static int ctnetlink_dump_exp_ct(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
 				 const struct nlattr * const cda[])
 {
 	int err;
-	struct net *net = sock_net(ctnl);
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
 	struct nf_conntrack_tuple tuple;
@@ -2768,12 +2764,10 @@ static int ctnetlink_dump_exp_ct(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
-static int
-ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
-		     const struct nlmsghdr *nlh,
-		     const struct nlattr * const cda[])
+static int ctnetlink_get_expect(struct net *net, struct sock *ctnl,
+				struct sk_buff *skb, const struct nlmsghdr *nlh,
+				const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct sk_buff *skb2;
@@ -2784,7 +2778,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		if (cda[CTA_EXPECT_MASTER])
-			return ctnetlink_dump_exp_ct(ctnl, skb, nlh, cda);
+			return ctnetlink_dump_exp_ct(net, ctnl, skb, nlh, cda);
 		else {
 			struct netlink_dump_control c = {
 				.dump = ctnetlink_exp_dump_table,
@@ -2850,12 +2844,10 @@ out:
 	return err == -EAGAIN ? -ENOBUFS : err;
 }
 
-static int
-ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
-		     const struct nlmsghdr *nlh,
-		     const struct nlattr * const cda[])
+static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
+				struct sk_buff *skb, const struct nlmsghdr *nlh,
+				const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -3136,12 +3128,10 @@ err_ct:
 	return err;
 }
 
-static int
-ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
-		     const struct nlmsghdr *nlh,
-		     const struct nlattr * const cda[])
+static int ctnetlink_new_expect(struct net *net, struct sock *ctnl,
+				struct sk_buff *skb, const struct nlmsghdr *nlh,
+				const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -3242,10 +3232,10 @@ ctnetlink_exp_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-static int
-ctnetlink_stat_exp_cpu(struct sock *ctnl, struct sk_buff *skb,
-		       const struct nlmsghdr *nlh,
-		       const struct nlattr * const cda[])
+static int ctnetlink_stat_exp_cpu(struct net *net, struct sock *ctnl,
+				  struct sk_buff *skb,
+				  const struct nlmsghdr *nlh,
+				  const struct nlattr * const cda[])
 {
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 28cbc45..69cb5be 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -543,15 +543,14 @@ done:
 	return skb->len;
 }
 
-static int nf_tables_gettable(struct sock *nlsk, struct sk_buff *skb,
-			      const struct nlmsghdr *nlh,
+static int nf_tables_gettable(struct net *net, struct sock *nlsk,
+			      struct sk_buff *skb, const struct nlmsghdr *nlh,
 			      const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	const struct nft_af_info *afi;
 	const struct nft_table *table;
 	struct sk_buff *skb2;
-	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	int err;
 
@@ -1097,8 +1096,8 @@ done:
 	return skb->len;
 }
 
-static int nf_tables_getchain(struct sock *nlsk, struct sk_buff *skb,
-			      const struct nlmsghdr *nlh,
+static int nf_tables_getchain(struct net *net, struct sock *nlsk,
+			      struct sk_buff *skb, const struct nlmsghdr *nlh,
 			      const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -1106,7 +1105,6 @@ static int nf_tables_getchain(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_table *table;
 	const struct nft_chain *chain;
 	struct sk_buff *skb2;
-	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	int err;
 
@@ -1923,8 +1921,8 @@ done:
 	return skb->len;
 }
 
-static int nf_tables_getrule(struct sock *nlsk, struct sk_buff *skb,
-			     const struct nlmsghdr *nlh,
+static int nf_tables_getrule(struct net *net, struct sock *nlsk,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
 			     const struct nlattr * const nla[])
 {
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -1933,7 +1931,6 @@ static int nf_tables_getrule(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_chain *chain;
 	const struct nft_rule *rule;
 	struct sk_buff *skb2;
-	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
 	int err;
 
@@ -2604,11 +2601,10 @@ static int nf_tables_dump_sets_done(struct netlink_callback *cb)
 	return 0;
 }
 
-static int nf_tables_getset(struct sock *nlsk, struct sk_buff *skb,
-			    const struct nlmsghdr *nlh,
+static int nf_tables_getset(struct net *net, struct sock *nlsk,
+			    struct sk_buff *skb, const struct nlmsghdr *nlh,
 			    const struct nlattr * const nla[])
 {
-	struct net *net = sock_net(skb->sk);
 	const struct nft_set *set;
 	struct nft_ctx ctx;
 	struct sk_buff *skb2;
@@ -3190,11 +3186,10 @@ nla_put_failure:
 	return -ENOSPC;
 }
 
-static int nf_tables_getsetelem(struct sock *nlsk, struct sk_buff *skb,
-				const struct nlmsghdr *nlh,
+static int nf_tables_getsetelem(struct net *net, struct sock *nlsk,
+				struct sk_buff *skb, const struct nlmsghdr *nlh,
 				const struct nlattr * const nla[])
 {
-	struct net *net = sock_net(skb->sk);
 	const struct nft_set *set;
 	struct nft_ctx ctx;
 	int err;
@@ -3723,11 +3718,10 @@ err:
 	return err;
 }
 
-static int nf_tables_getgen(struct sock *nlsk, struct sk_buff *skb,
-			    const struct nlmsghdr *nlh,
+static int nf_tables_getgen(struct net *net, struct sock *nlsk,
+			    struct sk_buff *skb, const struct nlmsghdr *nlh,
 			    const struct nlattr * const nla[])
 {
-	struct net *net = sock_net(skb->sk);
 	struct sk_buff *skb2;
 	int err;
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 9ed4534..7012154 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -206,7 +206,7 @@ replay:
 		}
 
 		if (nc->call_rcu) {
-			err = nc->call_rcu(net->nfnl, skb, nlh,
+			err = nc->call_rcu(net, net->nfnl, skb, nlh,
 					   (const struct nlattr **)cda);
 			rcu_read_unlock();
 		} else {
@@ -216,8 +216,8 @@ replay:
 			    nfnetlink_find_client(type, ss) != nc)
 				err = -EAGAIN;
 			else if (nc->call)
-				err = nc->call(net->nfnl, skb, nlh,
-						   (const struct nlattr **)cda);
+				err = nc->call(net, net->nfnl, skb, nlh,
+					       (const struct nlattr **)cda);
 			else
 				err = -EINVAL;
 			nfnl_unlock(subsys_id);
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index fefbf5f..5274b04 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -46,12 +46,11 @@ struct nfacct_filter {
 #define NFACCT_F_QUOTA (NFACCT_F_QUOTA_PKTS | NFACCT_F_QUOTA_BYTES)
 #define NFACCT_OVERQUOTA_BIT	2	/* NFACCT_F_OVERQUOTA */
 
-static int
-nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
-	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_acct_new(struct net *net, struct sock *nfnl,
+			 struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 const struct nlattr * const tb[])
 {
 	struct nf_acct *nfacct, *matching = NULL;
-	struct net *net = sock_net(nfnl);
 	char *acct_name;
 	unsigned int size = 0;
 	u32 flags = 0;
@@ -253,11 +252,10 @@ nfacct_filter_alloc(const struct nlattr * const attr)
 	return filter;
 }
 
-static int
-nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
-	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_acct_get(struct net *net, struct sock *nfnl,
+			 struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 const struct nlattr * const tb[])
 {
-	struct net *net = sock_net(nfnl);
 	int ret = -ENOENT;
 	struct nf_acct *cur;
 	char *acct_name;
@@ -333,11 +331,10 @@ static int nfnl_acct_try_del(struct nf_acct *cur)
 	return ret;
 }
 
-static int
-nfnl_acct_del(struct sock *nfnl, struct sk_buff *skb,
-	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_acct_del(struct net *net, struct sock *nfnl,
+			 struct sk_buff *skb, const struct nlmsghdr *nlh,
+			 const struct nlattr * const tb[])
 {
-	struct net *net = sock_net(nfnl);
 	char *acct_name;
 	struct nf_acct *cur;
 	int ret = -ENOENT;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index 54330fb..e924e95 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -286,9 +286,9 @@ nfnl_cthelper_update(const struct nlattr * const tb[],
 	return 0;
 }
 
-static int
-nfnl_cthelper_new(struct sock *nfnl, struct sk_buff *skb,
-		  const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_cthelper_new(struct net *net, struct sock *nfnl,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     const struct nlattr * const tb[])
 {
 	const char *helper_name;
 	struct nf_conntrack_helper *cur, *helper = NULL;
@@ -498,9 +498,9 @@ out:
 	return skb->len;
 }
 
-static int
-nfnl_cthelper_get(struct sock *nfnl, struct sk_buff *skb,
-		  const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_cthelper_get(struct net *net, struct sock *nfnl,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     const struct nlattr * const tb[])
 {
 	int ret = -ENOENT, i;
 	struct nf_conntrack_helper *cur;
@@ -570,9 +570,9 @@ nfnl_cthelper_get(struct sock *nfnl, struct sk_buff *skb,
 	return ret;
 }
 
-static int
-nfnl_cthelper_del(struct sock *nfnl, struct sk_buff *skb,
-	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_cthelper_del(struct net *net, struct sock *nfnl,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     const struct nlattr * const tb[])
 {
 	char *helper_name = NULL;
 	struct nf_conntrack_helper *cur;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 3921d54..5d010f2 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -65,16 +65,15 @@ ctnl_timeout_parse_policy(void *timeouts, struct nf_conntrack_l4proto *l4proto,
 	return ret;
 }
 
-static int
-cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
-		      const struct nlmsghdr *nlh,
-		      const struct nlattr * const cda[])
+static int cttimeout_new_timeout(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
 {
 	__u16 l3num;
 	__u8 l4num;
 	struct nf_conntrack_l4proto *l4proto;
 	struct ctnl_timeout *timeout, *matching = NULL;
-	struct net *net = sock_net(skb->sk);
 	char *name;
 	int ret;
 
@@ -239,12 +238,11 @@ ctnl_timeout_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-static int
-cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
-		      const struct nlmsghdr *nlh,
-		      const struct nlattr * const cda[])
+static int cttimeout_get_timeout(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(skb->sk);
 	int ret = -ENOENT;
 	char *name;
 	struct ctnl_timeout *cur;
@@ -339,15 +337,14 @@ static int ctnl_timeout_try_del(struct net *net, struct ctnl_timeout *timeout)
 	return ret;
 }
 
-static int
-cttimeout_del_timeout(struct sock *ctnl, struct sk_buff *skb,
-		      const struct nlmsghdr *nlh,
-		      const struct nlattr * const cda[])
+static int cttimeout_del_timeout(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
 {
-	struct net *net = sock_net(skb->sk);
-	char *name;
 	struct ctnl_timeout *cur;
 	int ret = -ENOENT;
+	char *name;
 
 	if (!cda[CTA_TIMEOUT_NAME]) {
 		list_for_each_entry(cur, &net->nfct_timeout_list, head)
@@ -370,15 +367,14 @@ cttimeout_del_timeout(struct sock *ctnl, struct sk_buff *skb,
 	return ret;
 }
 
-static int
-cttimeout_default_set(struct sock *ctnl, struct sk_buff *skb,
-		      const struct nlmsghdr *nlh,
-		      const struct nlattr * const cda[])
+static int cttimeout_default_set(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
 {
 	__u16 l3num;
 	__u8 l4num;
 	struct nf_conntrack_l4proto *l4proto;
-	struct net *net = sock_net(skb->sk);
 	unsigned int *timeouts;
 	int ret;
 
@@ -460,14 +456,14 @@ nla_put_failure:
 	return -1;
 }
 
-static int cttimeout_default_get(struct sock *ctnl, struct sk_buff *skb,
+static int cttimeout_default_get(struct net *net, struct sock *ctnl,
+				 struct sk_buff *skb,
 				 const struct nlmsghdr *nlh,
 				 const struct nlattr * const cda[])
 {
 	__u16 l3num;
 	__u8 l4num;
 	struct nf_conntrack_l4proto *l4proto;
-	struct net *net = sock_net(skb->sk);
 	struct sk_buff *skb2;
 	int ret, err;
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 70b6bd3..6a57f10 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -785,10 +785,9 @@ static struct notifier_block nfulnl_rtnl_notifier = {
 	.notifier_call	= nfulnl_rcv_nl_event,
 };
 
-static int
-nfulnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
-		   const struct nlmsghdr *nlh,
-		   const struct nlattr * const nfqa[])
+static int nfulnl_recv_unsupp(struct net *net, struct sock *ctnl,
+			      struct sk_buff *skb, const struct nlmsghdr *nlh,
+			      const struct nlattr * const nfqa[])
 {
 	return -ENOTSUPP;
 }
@@ -809,16 +808,14 @@ static const struct nla_policy nfula_cfg_policy[NFULA_CFG_MAX+1] = {
 	[NFULA_CFG_FLAGS]	= { .type = NLA_U16 },
 };
 
-static int
-nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
-		   const struct nlmsghdr *nlh,
-		   const struct nlattr * const nfula[])
+static int nfulnl_recv_config(struct net *net, struct sock *ctnl,
+			      struct sk_buff *skb, const struct nlmsghdr *nlh,
+			      const struct nlattr * const nfula[])
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t group_num = ntohs(nfmsg->res_id);
 	struct nfulnl_instance *inst;
 	struct nfulnl_msg_config_cmd *cmd = NULL;
-	struct net *net = sock_net(ctnl);
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
 	int ret = 0;
 	u16 flags = 0;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 861c661..3d1f16c 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -957,10 +957,10 @@ static int nfq_id_after(unsigned int id, unsigned int max)
 	return (int)(id - max) > 0;
 }
 
-static int
-nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
-		   const struct nlmsghdr *nlh,
-		   const struct nlattr * const nfqa[])
+static int nfqnl_recv_verdict_batch(struct net *net, struct sock *ctnl,
+				    struct sk_buff *skb,
+				    const struct nlmsghdr *nlh,
+			            const struct nlattr * const nfqa[])
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct nf_queue_entry *entry, *tmp;
@@ -969,8 +969,6 @@ nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
 	struct nfqnl_instance *queue;
 	LIST_HEAD(batch_list);
 	u16 queue_num = ntohs(nfmsg->res_id);
-
-	struct net *net = sock_net(ctnl);
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
 	queue = verdict_instance_lookup(q, queue_num,
@@ -1029,14 +1027,13 @@ static struct nf_conn *nfqnl_ct_parse(struct nfnl_ct_hook *nfnl_ct,
 	return ct;
 }
 
-static int
-nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
-		   const struct nlmsghdr *nlh,
-		   const struct nlattr * const nfqa[])
+static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
+			      struct sk_buff *skb,
+			      const struct nlmsghdr *nlh,
+			      const struct nlattr * const nfqa[])
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
-
 	struct nfqnl_msg_verdict_hdr *vhdr;
 	struct nfqnl_instance *queue;
 	unsigned int verdict;
@@ -1044,8 +1041,6 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	enum ip_conntrack_info uninitialized_var(ctinfo);
 	struct nfnl_ct_hook *nfnl_ct;
 	struct nf_conn *ct = NULL;
-
-	struct net *net = sock_net(ctnl);
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 
 	queue = instance_lookup(q, queue_num);
@@ -1092,10 +1087,9 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	return 0;
 }
 
-static int
-nfqnl_recv_unsupp(struct sock *ctnl, struct sk_buff *skb,
-		  const struct nlmsghdr *nlh,
-		  const struct nlattr * const nfqa[])
+static int nfqnl_recv_unsupp(struct net *net, struct sock *ctnl,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     const struct nlattr * const nfqa[])
 {
 	return -ENOTSUPP;
 }
@@ -1110,16 +1104,14 @@ static const struct nf_queue_handler nfqh = {
 	.nf_hook_drop	= &nfqnl_nf_hook_drop,
 };
 
-static int
-nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
-		  const struct nlmsghdr *nlh,
-		  const struct nlattr * const nfqa[])
+static int nfqnl_recv_config(struct net *net, struct sock *ctnl,
+			     struct sk_buff *skb, const struct nlmsghdr *nlh,
+			     const struct nlattr * const nfqa[])
 {
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int16_t queue_num = ntohs(nfmsg->res_id);
 	struct nfqnl_instance *queue;
 	struct nfqnl_msg_config_cmd *cmd = NULL;
-	struct net *net = sock_net(ctnl);
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 	int ret = 0;
 
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 9c8fab0..454841b 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -519,9 +519,9 @@ nla_put_failure:
 	return -1;
 }
 
-static int
-nfnl_compat_get(struct sock *nfnl, struct sk_buff *skb,
-		const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+static int nfnl_compat_get(struct net *net, struct sock *nfnl,
+			   struct sk_buff *skb, const struct nlmsghdr *nlh,
+			   const struct nlattr * const tb[])
 {
 	int ret = 0, target;
 	struct nfgenmsg *nfmsg;
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index df8801e..4e3c3af 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -61,8 +61,8 @@ static const struct nla_policy xt_osf_policy[OSF_ATTR_MAX + 1] = {
 	[OSF_ATTR_FINGER]	= { .len = sizeof(struct xt_osf_user_finger) },
 };
 
-static int xt_osf_add_callback(struct sock *ctnl, struct sk_buff *skb,
-			       const struct nlmsghdr *nlh,
+static int xt_osf_add_callback(struct net *net, struct sock *ctnl,
+			       struct sk_buff *skb, const struct nlmsghdr *nlh,
 			       const struct nlattr * const osf_attrs[])
 {
 	struct xt_osf_user_finger *f;
@@ -104,7 +104,8 @@ static int xt_osf_add_callback(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
-static int xt_osf_remove_callback(struct sock *ctnl, struct sk_buff *skb,
+static int xt_osf_remove_callback(struct net *net, struct sock *ctnl,
+				  struct sk_buff *skb,
 				  const struct nlmsghdr *nlh,
 				  const struct nlattr * const osf_attrs[])
 {
-- 
2.1.4

