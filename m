From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/17] netfilter: nf_tables: add compatibility layer for x_tables
Date: Mon, 14 Oct 2013 18:38:50 +0200
Message-ID: <1381768738-17739-10-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the x_tables compatibility layer. This allows you
to use existing x_tables matches and targets from nf_tables.

This compatibility later allows us to use existing matches/targets
for features that are still missing in nf_tables. We can progressively
replace them with native nf_tables extensions. It also provides the
userspace compatibility software that allows you to express the
rule-set using the iptables syntax but using the nf_tables kernel
components.

In order to get this compatibility layer working, I've done the
following things:

* add NFNL_SUBSYS_NFT_COMPAT: this new nfnetlink subsystem is used
to query the x_tables match/target revision, so we don't need to
use the native x_table getsockopt interface.

* emulate xt structures: this required extending the struct nft_pktinfo
to include the fragment offset, which is already obtained from
ip[6]_tables and that is used by some matches/targets.

* add support for default policy to base chains, required to emulate
  x_tables.

* add NFTA_CHAIN_USE attribute to obtain the number of references to
  chains, required by x_tables emulation.

* add chain packet/byte counters using per-cpu.

* support 32-64 bits compat.

For historical reasons, this patch includes the following patches
that were posted in the netfilter-devel mailing list.

>From Pablo Neira Ayuso:
* nf_tables: add default policy to base chains
* netfilter: nf_tables: add NFTA_CHAIN_USE attribute
* nf_tables: nft_compat: private data of target and matches in contiguous area
* nf_tables: validate hooks for compat match/target
* nf_tables: nft_compat: release cached matches/targets
* nf_tables: x_tables support as a compile time option
* nf_tables: fix alias for xtables over nftables module
* nf_tables: add packet and byte counters per chain
* nf_tables: fix per-chain counter stats if no counters are passed
* nf_tables: don't bump chain stats
* nf_tables: add protocol and flags for xtables over nf_tables
* nf_tables: add ip[6]t_entry emulation
* nf_tables: move specific layer 3 compat code to nf_tables_ipv[4|6]
* nf_tables: support 32bits-64bits x_tables compat
* nf_tables: fix compilation if CONFIG_COMPAT is disabled

>From Patrick McHardy:
* nf_tables: move policy to struct nft_base_chain
* nf_tables: send notifications for base chain policy changes

>From Alexander Primak:
* nf_tables: remove the duplicate NF_INET_LOCAL_OUT

>From Nicolas Dichtel:
* nf_tables: fix compilation when nf-netlink is a module

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h               |   44 +-
 include/net/netfilter/nf_tables_ipv4.h          |   23 +
 include/net/netfilter/nf_tables_ipv6.h          |   30 +
 include/uapi/linux/netfilter/Kbuild             |    1 +
 include/uapi/linux/netfilter/nf_tables.h        |   32 +
 include/uapi/linux/netfilter/nf_tables_compat.h |   38 ++
 include/uapi/linux/netfilter/nfnetlink.h        |    3 +-
 net/ipv4/netfilter/nf_tables_ipv4.c             |   32 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c         |    6 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c       |    6 +-
 net/ipv6/netfilter/nf_tables_ipv6.c             |   33 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c       |    8 +-
 net/netfilter/Kconfig                           |    9 +
 net/netfilter/Makefile                          |    1 +
 net/netfilter/nf_tables_api.c                   |  220 ++++++-
 net/netfilter/nf_tables_core.c                  |   46 +-
 net/netfilter/nft_cmp.c                         |    3 +-
 net/netfilter/nft_compat.c                      |  768 +++++++++++++++++++++++
 net/netfilter/nft_immediate.c                   |   12 +-
 net/netfilter/nft_payload.c                     |    4 +-
 20 files changed, 1241 insertions(+), 78 deletions(-)
 create mode 100644 include/net/netfilter/nf_tables_ipv4.h
 create mode 100644 include/net/netfilter/nf_tables_ipv6.h
 create mode 100644 include/uapi/linux/netfilter/nf_tables_compat.h
 create mode 100644 net/netfilter/nft_compat.c

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 8403f7f5..a68f45f 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -3,6 +3,7 @@
 
 #include <linux/list.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netlink.h>
 
@@ -15,8 +16,23 @@ struct nft_pktinfo {
 	u8				hooknum;
 	u8				nhoff;
 	u8				thoff;
+	/* for x_tables compatibility */
+	struct xt_action_param		xt;
 };
 
+static inline void nft_set_pktinfo(struct nft_pktinfo *pkt,
+				   const struct nf_hook_ops *ops,
+				   struct sk_buff *skb,
+				   const struct net_device *in,
+				   const struct net_device *out)
+{
+	pkt->skb = skb;
+	pkt->in = pkt->xt.in = in;
+	pkt->out = pkt->xt.out = out;
+	pkt->hooknum = pkt->xt.hooknum = ops->hooknum;
+	pkt->xt.family = ops->pf;
+}
+
 struct nft_data {
 	union {
 		u32				data[4];
@@ -57,6 +73,7 @@ static inline void nft_data_debug(const struct nft_data *data)
  * 	@afi: address family info
  * 	@table: the table the chain is contained in
  * 	@chain: the chain the rule is contained in
+ *	@nla: netlink attributes
  */
 struct nft_ctx {
 	const struct sk_buff		*skb;
@@ -64,6 +81,7 @@ struct nft_ctx {
 	const struct nft_af_info	*afi;
 	const struct nft_table		*table;
 	const struct nft_chain		*chain;
+	const struct nlattr * const 	*nla;
 };
 
 struct nft_data_desc {
@@ -235,7 +253,8 @@ extern void nf_tables_unbind_set(const struct nft_ctx *ctx, struct nft_set *set,
  *	@maxattr: highest netlink attribute number
  */
 struct nft_expr_type {
-	const struct nft_expr_ops	*(*select_ops)(const struct nlattr * const tb[]);
+	const struct nft_expr_ops	*(*select_ops)(const struct nft_ctx *,
+						       const struct nlattr * const tb[]);
 	const struct nft_expr_ops	*ops;
 	struct list_head		list;
 	const char			*name;
@@ -253,6 +272,8 @@ struct nft_expr_type {
  *	@destroy: destruction function
  *	@dump: function to dump parameters
  *	@type: expression type
+ *	@validate: validate expression, called during loop detection
+ *	@data: extra data to attach to this expression operation
  */
 struct nft_expr;
 struct nft_expr_ops {
@@ -267,8 +288,11 @@ struct nft_expr_ops {
 	void				(*destroy)(const struct nft_expr *expr);
 	int				(*dump)(struct sk_buff *skb,
 						const struct nft_expr *expr);
-	const struct nft_data *		(*get_verdict)(const struct nft_expr *expr);
+	int				(*validate)(const struct nft_ctx *ctx,
+						    const struct nft_expr *expr,
+						    const struct nft_data **data);
 	const struct nft_expr_type	*type;
+	void				*data;
 };
 
 #define NFT_EXPR_MAXATTR		16
@@ -368,16 +392,25 @@ enum nft_chain_type {
 	NFT_CHAIN_T_MAX
 };
 
+struct nft_stats {
+	u64 bytes;
+	u64 pkts;
+};
+
 /**
  *	struct nft_base_chain - nf_tables base chain
  *
  *	@ops: netfilter hook ops
  *	@type: chain type
+ *	@policy: default policy
+ *	@stats: per-cpu chain stats
  *	@chain: the chain
  */
 struct nft_base_chain {
 	struct nf_hook_ops		ops;
 	enum nft_chain_type		type;
+	u8				policy;
+	struct nft_stats __percpu	*stats;
 	struct nft_chain		chain;
 };
 
@@ -386,11 +419,8 @@ static inline struct nft_base_chain *nft_base_chain(const struct nft_chain *chai
 	return container_of(chain, struct nft_base_chain, chain);
 }
 
-extern unsigned int nft_do_chain(const struct nf_hook_ops *ops,
-				 struct sk_buff *skb,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *));
+extern unsigned int nft_do_chain_pktinfo(struct nft_pktinfo *pkt,
+					 const struct nf_hook_ops *ops);
 
 /**
  *	struct nft_table - nf_tables table
diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
new file mode 100644
index 0000000..1be1c2c
--- /dev/null
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -0,0 +1,23 @@
+#ifndef _NF_TABLES_IPV4_H_
+#define _NF_TABLES_IPV4_H_
+
+#include <net/netfilter/nf_tables.h>
+#include <net/ip.h>
+
+static inline void
+nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
+		     const struct nf_hook_ops *ops,
+		     struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out)
+{
+	struct iphdr *ip;
+
+	nft_set_pktinfo(pkt, ops, skb, in, out);
+
+	pkt->xt.thoff = ip_hdrlen(pkt->skb);
+	ip = ip_hdr(pkt->skb);
+	pkt->xt.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
+}
+
+#endif
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
new file mode 100644
index 0000000..4a9b88a
--- /dev/null
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -0,0 +1,30 @@
+#ifndef _NF_TABLES_IPV6_H_
+#define _NF_TABLES_IPV6_H_
+
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <net/ipv6.h>
+
+static inline int
+nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
+		     const struct nf_hook_ops *ops,
+		     struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out)
+{
+	int protohdr, thoff = 0;
+	unsigned short frag_off;
+
+	nft_set_pktinfo(pkt, ops, skb, in, out);
+
+	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
+	/* If malformed, drop it */
+	if (protohdr < 0)
+		return -1;
+
+	pkt->xt.thoff = thoff;
+	pkt->xt.fragoff = frag_off;
+
+	return 0;
+}
+
+#endif
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 6ce0b7f..17c3af2 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -6,6 +6,7 @@ header-y += nf_conntrack_sctp.h
 header-y += nf_conntrack_tcp.h
 header-y += nf_conntrack_tuple_common.h
 header-y += nf_tables.h
+header-y += nf_tables_compat.h
 header-y += nf_nat.h
 header-y += nfnetlink.h
 header-y += nfnetlink_acct.h
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 779cf95..1563875 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -115,7 +115,10 @@ enum nft_table_attributes {
  * @NFTA_CHAIN_HANDLE: numeric handle of the chain (NLA_U64)
  * @NFTA_CHAIN_NAME: name of the chain (NLA_STRING)
  * @NFTA_CHAIN_HOOK: hook specification for basechains (NLA_NESTED: nft_hook_attributes)
+ * @NFTA_CHAIN_POLICY: numeric policy of the chain (NLA_U32)
+ * @NFTA_CHAIN_USE: number of references to this chain (NLA_U32)
  * @NFTA_CHAIN_TYPE: type name of the string (NLA_NUL_STRING)
+ * @NFTA_CHAIN_COUNTERS: counter specification of the chain (NLA_NESTED: nft_counter_attributes)
  */
 enum nft_chain_attributes {
 	NFTA_CHAIN_UNSPEC,
@@ -123,7 +126,10 @@ enum nft_chain_attributes {
 	NFTA_CHAIN_HANDLE,
 	NFTA_CHAIN_NAME,
 	NFTA_CHAIN_HOOK,
+	NFTA_CHAIN_POLICY,
+	NFTA_CHAIN_USE,
 	NFTA_CHAIN_TYPE,
+	NFTA_CHAIN_COUNTERS,
 	__NFTA_CHAIN_MAX
 };
 #define NFTA_CHAIN_MAX		(__NFTA_CHAIN_MAX - 1)
@@ -135,6 +141,7 @@ enum nft_chain_attributes {
  * @NFTA_RULE_CHAIN: name of the chain containing the rule (NLA_STRING)
  * @NFTA_RULE_HANDLE: numeric handle of the rule (NLA_U64)
  * @NFTA_RULE_EXPRESSIONS: list of expressions (NLA_NESTED: nft_expr_attributes)
+ * @NFTA_RULE_COMPAT: compatibility specifications of the rule (NLA_NESTED: nft_rule_compat_attributes)
  */
 enum nft_rule_attributes {
 	NFTA_RULE_UNSPEC,
@@ -142,11 +149,36 @@ enum nft_rule_attributes {
 	NFTA_RULE_CHAIN,
 	NFTA_RULE_HANDLE,
 	NFTA_RULE_EXPRESSIONS,
+	NFTA_RULE_COMPAT,
 	__NFTA_RULE_MAX
 };
 #define NFTA_RULE_MAX		(__NFTA_RULE_MAX - 1)
 
 /**
+ * enum nft_rule_compat_flags - nf_tables rule compat flags
+ *
+ * @NFT_RULE_COMPAT_F_INV: invert the check result
+ */
+enum nft_rule_compat_flags {
+	NFT_RULE_COMPAT_F_INV	= (1 << 1),
+	NFT_RULE_COMPAT_F_MASK	= NFT_RULE_COMPAT_F_INV,
+};
+
+/**
+ * enum nft_rule_compat_attributes - nf_tables rule compat attributes
+ *
+ * @NFTA_RULE_COMPAT_PROTO: numerice value of handled protocol (NLA_U32)
+ * @NFTA_RULE_COMPAT_FLAGS: bitmask of enum nft_rule_compat_flags (NLA_U32)
+ */
+enum nft_rule_compat_attributes {
+	NFTA_RULE_COMPAT_UNSPEC,
+	NFTA_RULE_COMPAT_PROTO,
+	NFTA_RULE_COMPAT_FLAGS,
+	__NFTA_RULE_COMPAT_MAX
+};
+#define NFTA_RULE_COMPAT_MAX	(__NFTA_RULE_COMPAT_MAX - 1)
+
+/**
  * enum nft_set_flags - nf_tables set flags
  *
  * @NFT_SET_ANONYMOUS: name allocation, automatic cleanup on unlink
diff --git a/include/uapi/linux/netfilter/nf_tables_compat.h b/include/uapi/linux/netfilter/nf_tables_compat.h
new file mode 100644
index 0000000..8310f5f
--- /dev/null
+++ b/include/uapi/linux/netfilter/nf_tables_compat.h
@@ -0,0 +1,38 @@
+#ifndef _NFT_COMPAT_NFNETLINK_H_
+#define _NFT_COMPAT_NFNETLINK_H_
+
+enum nft_target_attributes {
+	NFTA_TARGET_UNSPEC,
+	NFTA_TARGET_NAME,
+	NFTA_TARGET_REV,
+	NFTA_TARGET_INFO,
+	__NFTA_TARGET_MAX
+};
+#define NFTA_TARGET_MAX		(__NFTA_TARGET_MAX - 1)
+
+enum nft_match_attributes {
+	NFTA_MATCH_UNSPEC,
+	NFTA_MATCH_NAME,
+	NFTA_MATCH_REV,
+	NFTA_MATCH_INFO,
+	__NFTA_MATCH_MAX
+};
+#define NFTA_MATCH_MAX		(__NFTA_MATCH_MAX - 1)
+
+#define NFT_COMPAT_NAME_MAX	32
+
+enum {
+	NFNL_MSG_COMPAT_GET,
+	NFNL_MSG_COMPAT_MAX
+};
+
+enum {
+	NFTA_COMPAT_UNSPEC = 0,
+	NFTA_COMPAT_NAME,
+	NFTA_COMPAT_REV,
+	NFTA_COMPAT_TYPE,
+	__NFTA_COMPAT_MAX,
+};
+#define NFTA_COMPAT_MAX (__NFTA_COMPAT_MAX - 1)
+
+#endif
diff --git a/include/uapi/linux/netfilter/nfnetlink.h b/include/uapi/linux/netfilter/nfnetlink.h
index d276c3b..2889594 100644
--- a/include/uapi/linux/netfilter/nfnetlink.h
+++ b/include/uapi/linux/netfilter/nfnetlink.h
@@ -54,6 +54,7 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_CTNETLINK_TIMEOUT	8
 #define NFNL_SUBSYS_CTHELPER		9
 #define NFNL_SUBSYS_NFTABLES		10
-#define NFNL_SUBSYS_COUNT		11
+#define NFNL_SUBSYS_NFT_COMPAT		11
+#define NFNL_SUBSYS_COUNT		12
 
 #endif /* _UAPI_NFNETLINK_H */
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 23525c4..c61cffb 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -15,6 +15,8 @@
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_tables.h>
 #include <net/ip.h>
+#include <net/net_namespace.h>
+#include <net/netfilter/nf_tables_ipv4.h>
 
 static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
@@ -22,6 +24,8 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 				    const struct net_device *out,
 				    int (*okfn)(struct sk_buff *))
 {
+	struct nft_pktinfo pkt;
+
 	if (unlikely(skb->len < sizeof(struct iphdr) ||
 		     ip_hdr(skb)->ihl < sizeof(struct iphdr) / 4)) {
 		if (net_ratelimit())
@@ -29,8 +33,9 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 				"packet\n");
 		return NF_ACCEPT;
 	}
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
 
-	return nft_do_chain(ops, skb, in, out, okfn);
+	return nft_do_chain_pktinfo(&pkt, ops);
 }
 
 static struct nft_af_info nft_af_ipv4 __read_mostly = {
@@ -42,6 +47,21 @@ static struct nft_af_info nft_af_ipv4 __read_mostly = {
 	},
 };
 
+
+static unsigned int
+nft_do_chain_ipv4(const struct nf_hook_ops *ops,
+		  struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
 static struct nf_chain_type filter_ipv4 = {
 	.family		= NFPROTO_IPV4,
 	.name		= "filter",
@@ -52,11 +72,11 @@ static struct nf_chain_type filter_ipv4 = {
 			  (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING),
 	.fn		= {
-		[NF_INET_LOCAL_IN]	= nft_do_chain,
-		[NF_INET_LOCAL_OUT]	= nft_do_chain,
-		[NF_INET_FORWARD]	= nft_do_chain,
-		[NF_INET_PRE_ROUTING]	= nft_do_chain,
-		[NF_INET_POST_ROUTING]	= nft_do_chain,
+		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv4,
+		[NF_INET_LOCAL_OUT]	= nft_ipv4_output,
+		[NF_INET_FORWARD]	= nft_do_chain_ipv4,
+		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv4,
+		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv4,
 	},
 };
 
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index cd28630..e09c201 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -23,6 +23,7 @@
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_ipv4.h>
 #include <net/netfilter/nf_nat_l3proto.h>
 #include <net/ip.h>
 
@@ -181,6 +182,7 @@ static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	struct nf_conn_nat *nat;
 	enum nf_nat_manip_type maniptype = HOOK2MANIP(ops->hooknum);
+	struct nft_pktinfo pkt;
 	unsigned int ret;
 
 	if (ct == NULL || nf_ct_is_untracked(ct))
@@ -213,7 +215,9 @@ static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
 		if (nf_nat_initialized(ct, maniptype))
 			break;
 
-		ret = nft_do_chain(ops, skb, in, out, okfn);
+		nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+
+		ret = nft_do_chain_pktinfo(&pkt, ops);
 		if (ret != NF_ACCEPT)
 			return ret;
 		if (!nf_nat_initialized(ct, maniptype)) {
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 6b84e09..4e6bf9a 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -17,6 +17,7 @@
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_ipv4.h>
 #include <net/route.h>
 #include <net/ip.h>
 
@@ -27,6 +28,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 					int (*okfn)(struct sk_buff *))
 {
 	unsigned int ret;
+	struct nft_pktinfo pkt;
 	u32 mark;
 	__be32 saddr, daddr;
 	u_int8_t tos;
@@ -37,13 +39,15 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
+	nft_set_pktinfo_ipv4(&pkt, ops, skb, in, out);
+
 	mark = skb->mark;
 	iph = ip_hdr(skb);
 	saddr = iph->saddr;
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = nft_do_chain(ops, skb, in, out, okfn);
+	ret = nft_do_chain_pktinfo(&pkt, ops);
 	if (ret != NF_DROP && ret != NF_QUEUE) {
 		iph = ip_hdr(skb);
 
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 3631d62..42f905a 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -14,6 +14,7 @@
 #include <linux/ipv6.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_ipv6.h>
 
 static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 				    struct sk_buff *skb,
@@ -21,14 +22,18 @@ static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 				    const struct net_device *out,
 				    int (*okfn)(struct sk_buff *))
 {
+	struct nft_pktinfo pkt;
+
 	if (unlikely(skb->len < sizeof(struct ipv6hdr))) {
 		if (net_ratelimit())
 			pr_info("nf_tables_ipv6: ignoring short SOCK_RAW "
 				"packet\n");
 		return NF_ACCEPT;
 	}
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
+		return NF_DROP;
 
-	return nft_do_chain(ops, skb, in, out, okfn);
+	return nft_do_chain_pktinfo(&pkt, ops);
 }
 
 static struct nft_af_info nft_af_ipv6 __read_mostly = {
@@ -40,6 +45,22 @@ static struct nft_af_info nft_af_ipv6 __read_mostly = {
 	},
 };
 
+static unsigned int
+nft_do_chain_ipv6(const struct nf_hook_ops *ops,
+		  struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sk_buff *))
+{
+	struct nft_pktinfo pkt;
+
+	/* malformed packet, drop it */
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
+		return NF_DROP;
+
+	return nft_do_chain_pktinfo(&pkt, ops);
+}
+
 static struct nf_chain_type filter_ipv6 = {
 	.family		= NFPROTO_IPV6,
 	.name		= "filter",
@@ -50,11 +71,11 @@ static struct nf_chain_type filter_ipv6 = {
 			  (1 << NF_INET_PRE_ROUTING) |
 			  (1 << NF_INET_POST_ROUTING),
 	.fn		= {
-		[NF_INET_LOCAL_IN]	= nft_do_chain,
-		[NF_INET_LOCAL_OUT]	= nft_do_chain,
-		[NF_INET_FORWARD]	= nft_do_chain,
-		[NF_INET_PRE_ROUTING]	= nft_do_chain,
-		[NF_INET_POST_ROUTING]	= nft_do_chain,
+		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv6,
+		[NF_INET_LOCAL_OUT]	= nft_ipv6_output,
+		[NF_INET_FORWARD]	= nft_do_chain_ipv6,
+		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv6,
+		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv6,
 	},
 };
 
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 4cdc992..3fe40f0 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -19,6 +19,7 @@
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_tables_ipv6.h>
 #include <net/route.h>
 
 static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
@@ -28,10 +29,15 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 					int (*okfn)(struct sk_buff *))
 {
 	unsigned int ret;
+	struct nft_pktinfo pkt;
 	struct in6_addr saddr, daddr;
 	u_int8_t hop_limit;
 	u32 mark, flowlabel;
 
+	/* malformed packet, drop it */
+	if (nft_set_pktinfo_ipv6(&pkt, ops, skb, in, out) < 0)
+		return NF_DROP;
+
 	/* save source/dest address, mark, hoplimit, flowlabel, priority */
 	memcpy(&saddr, &ipv6_hdr(skb)->saddr, sizeof(saddr));
 	memcpy(&daddr, &ipv6_hdr(skb)->daddr, sizeof(daddr));
@@ -41,7 +47,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u32 *)ipv6_hdr(skb));
 
-	ret = nft_do_chain(ops, skb, in, out, okfn);
+	ret = nft_do_chain_pktinfo(&pkt, ops);
 	if (ret != NF_DROP && ret != NF_QUEUE &&
 	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
 	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index aa184a46..49e3627 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -450,6 +450,15 @@ config NFT_LIMIT
 	depends on NF_TABLES
 	tristate "Netfilter nf_tables limit module"
 
+config NFT_COMPAT
+	depends on NF_TABLES
+	depends on NETFILTER_XTABLES
+	tristate "Netfilter x_tables over nf_tables module"
+	help
+	  This is required if you intend to use any of existing
+	  x_tables match/target extensions over the nf_tables
+	  framework.
+
 config NETFILTER_XTABLES
 	tristate "Netfilter Xtables support (required for ip_tables)"
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index b6b7875..a678145 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -70,6 +70,7 @@ nf_tables-objs += nft_immediate.o nft_cmp.o nft_lookup.o
 nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
+obj-$(CONFIG_NFT_COMPAT)	+= nft_compat.o
 obj-$(CONFIG_NFT_EXTHDR)	+= nft_exthdr.o
 obj-$(CONFIG_NFT_META)		+= nft_meta.o
 obj-$(CONFIG_NFT_CT)		+= nft_ct.o
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9c2d8d5..61e017b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -438,7 +438,9 @@ static const struct nla_policy nft_chain_policy[NFTA_CHAIN_MAX + 1] = {
 	[NFTA_CHAIN_NAME]	= { .type = NLA_STRING,
 				    .len = NFT_CHAIN_MAXNAMELEN - 1 },
 	[NFTA_CHAIN_HOOK]	= { .type = NLA_NESTED },
+	[NFTA_CHAIN_POLICY]	= { .type = NLA_U32 },
 	[NFTA_CHAIN_TYPE]	= { .type = NLA_NUL_STRING },
+	[NFTA_CHAIN_COUNTERS]	= { .type = NLA_NESTED },
 };
 
 static const struct nla_policy nft_hook_policy[NFTA_HOOK_MAX + 1] = {
@@ -446,6 +448,33 @@ static const struct nla_policy nft_hook_policy[NFTA_HOOK_MAX + 1] = {
 	[NFTA_HOOK_PRIORITY]	= { .type = NLA_U32 },
 };
 
+static int nft_dump_stats(struct sk_buff *skb, struct nft_stats __percpu *stats)
+{
+	struct nft_stats *cpu_stats, total;
+	struct nlattr *nest;
+	int cpu;
+
+	memset(&total, 0, sizeof(total));
+	for_each_possible_cpu(cpu) {
+		cpu_stats = per_cpu_ptr(stats, cpu);
+		total.pkts += cpu_stats->pkts;
+		total.bytes += cpu_stats->bytes;
+	}
+	nest = nla_nest_start(skb, NFTA_CHAIN_COUNTERS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	if (nla_put_be64(skb, NFTA_COUNTER_PACKETS, cpu_to_be64(total.pkts)) ||
+	    nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes)))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest);
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
 static int nf_tables_fill_chain_info(struct sk_buff *skb, u32 portid, u32 seq,
 				     int event, u32 flags, int family,
 				     const struct nft_table *table,
@@ -472,8 +501,11 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, u32 portid, u32 seq,
 		goto nla_put_failure;
 
 	if (chain->flags & NFT_BASE_CHAIN) {
-		const struct nf_hook_ops *ops = &nft_base_chain(chain)->ops;
-		struct nlattr *nest = nla_nest_start(skb, NFTA_CHAIN_HOOK);
+		const struct nft_base_chain *basechain = nft_base_chain(chain);
+		const struct nf_hook_ops *ops = &basechain->ops;
+		struct nlattr *nest;
+
+		nest = nla_nest_start(skb, NFTA_CHAIN_HOOK);
 		if (nest == NULL)
 			goto nla_put_failure;
 		if (nla_put_be32(skb, NFTA_HOOK_HOOKNUM, htonl(ops->hooknum)))
@@ -482,11 +514,21 @@ static int nf_tables_fill_chain_info(struct sk_buff *skb, u32 portid, u32 seq,
 			goto nla_put_failure;
 		nla_nest_end(skb, nest);
 
+		if (nla_put_be32(skb, NFTA_CHAIN_POLICY,
+				 htonl(basechain->policy)))
+			goto nla_put_failure;
+
 		if (nla_put_string(skb, NFTA_CHAIN_TYPE,
 			chain_type[ops->pf][nft_base_chain(chain)->type]->name))
 				goto nla_put_failure;
+
+		if (nft_dump_stats(skb, nft_base_chain(chain)->stats))
+			goto nla_put_failure;
 	}
 
+	if (nla_put_be32(skb, NFTA_CHAIN_USE, htonl(chain->use)))
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -617,6 +659,67 @@ err:
 	return err;
 }
 
+static int
+nf_tables_chain_policy(struct nft_base_chain *chain, const struct nlattr *attr)
+{
+	switch (ntohl(nla_get_be32(attr))) {
+	case NF_DROP:
+		chain->policy = NF_DROP;
+		break;
+	case NF_ACCEPT:
+		chain->policy = NF_ACCEPT;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static const struct nla_policy nft_counter_policy[NFTA_COUNTER_MAX + 1] = {
+	[NFTA_COUNTER_PACKETS]	= { .type = NLA_U64 },
+	[NFTA_COUNTER_BYTES]	= { .type = NLA_U64 },
+};
+
+static int
+nf_tables_counters(struct nft_base_chain *chain, const struct nlattr *attr)
+{
+	struct nlattr *tb[NFTA_COUNTER_MAX+1];
+	struct nft_stats __percpu *newstats;
+	struct nft_stats *stats;
+	int err;
+
+	err = nla_parse_nested(tb, NFTA_COUNTER_MAX, attr, nft_counter_policy);
+	if (err < 0)
+		return err;
+
+	if (!tb[NFTA_COUNTER_BYTES] || !tb[NFTA_COUNTER_PACKETS])
+		return -EINVAL;
+
+	newstats = alloc_percpu(struct nft_stats);
+	if (newstats == NULL)
+		return -ENOMEM;
+
+	/* Restore old counters on this cpu, no problem. Per-cpu statistics
+	 * are not exposed to userspace.
+	 */
+	stats = this_cpu_ptr(newstats);
+	stats->bytes = be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_BYTES]));
+	stats->pkts = be64_to_cpu(nla_get_be64(tb[NFTA_COUNTER_PACKETS]));
+
+	if (chain->stats) {
+		/* nfnl_lock is held, add some nfnl function for this, later */
+		struct nft_stats __percpu *oldstats =
+			rcu_dereference_protected(chain->stats, 1);
+
+		rcu_assign_pointer(chain->stats, newstats);
+		synchronize_rcu();
+		free_percpu(oldstats);
+	} else
+		rcu_assign_pointer(chain->stats, newstats);
+
+	return 0;
+}
+
 static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      const struct nlattr * const nla[])
@@ -626,7 +729,7 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 	const struct nft_af_info *afi;
 	struct nft_table *table;
 	struct nft_chain *chain;
-	struct nft_base_chain *basechain;
+	struct nft_base_chain *basechain = NULL;
 	struct nlattr *ha[NFTA_HOOK_MAX + 1];
 	int family = nfmsg->nfgen_family;
 	u64 handle = 0;
@@ -673,6 +776,26 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		    !IS_ERR(nf_tables_chain_lookup(table, nla[NFTA_CHAIN_NAME])))
 			return -EEXIST;
 
+		if (nla[NFTA_CHAIN_POLICY]) {
+			if (!(chain->flags & NFT_BASE_CHAIN))
+				return -EOPNOTSUPP;
+
+			err = nf_tables_chain_policy(nft_base_chain(chain),
+						     nla[NFTA_CHAIN_POLICY]);
+			if (err < 0)
+				return err;
+		}
+
+		if (nla[NFTA_CHAIN_COUNTERS]) {
+			if (!(chain->flags & NFT_BASE_CHAIN))
+				return -EOPNOTSUPP;
+
+			err = nf_tables_counters(nft_base_chain(chain),
+						 nla[NFTA_CHAIN_COUNTERS]);
+			if (err < 0)
+				return err;
+		}
+
 		if (nla[NFTA_CHAIN_HANDLE] && name)
 			nla_strlcpy(chain->name, name, NFT_CHAIN_MAXNAMELEN);
 
@@ -727,6 +850,36 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 			ops->hook = afi->hooks[ops->hooknum];
 
 		chain->flags |= NFT_BASE_CHAIN;
+
+		if (nla[NFTA_CHAIN_POLICY]) {
+			err = nf_tables_chain_policy(basechain,
+						     nla[NFTA_CHAIN_POLICY]);
+			if (err < 0) {
+				free_percpu(basechain->stats);
+				kfree(basechain);
+				return err;
+			}
+		} else
+			basechain->policy = NF_ACCEPT;
+
+		if (nla[NFTA_CHAIN_COUNTERS]) {
+			err = nf_tables_counters(basechain,
+						 nla[NFTA_CHAIN_COUNTERS]);
+			if (err < 0) {
+				free_percpu(basechain->stats);
+				kfree(basechain);
+				return err;
+			}
+		} else {
+			struct nft_stats __percpu *newstats;
+
+			newstats = alloc_percpu(struct nft_stats);
+			if (newstats == NULL)
+				return -ENOMEM;
+
+			rcu_assign_pointer(nft_base_chain(chain)->stats,
+					   newstats);
+		}
 	} else {
 		chain = kzalloc(sizeof(*chain), GFP_KERNEL);
 		if (chain == NULL)
@@ -739,6 +892,15 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 
 	list_add_tail(&chain->list, &table->chains);
 	table->use++;
+
+	if (chain->flags & NFT_BASE_CHAIN) {
+		err = nf_register_hook(&nft_base_chain(chain)->ops);
+		if (err < 0) {
+			free_percpu(basechain->stats);
+			kfree(basechain);
+			return err;
+		}
+	}
 notify:
 	nf_tables_chain_notify(skb, nlh, table, chain, NFT_MSG_NEWCHAIN,
 			       family);
@@ -751,9 +913,10 @@ static void nf_tables_rcu_chain_destroy(struct rcu_head *head)
 
 	BUG_ON(chain->use > 0);
 
-	if (chain->flags & NFT_BASE_CHAIN)
+	if (chain->flags & NFT_BASE_CHAIN) {
+		free_percpu(nft_base_chain(chain)->stats);
 		kfree(nft_base_chain(chain));
-	else
+	} else
 		kfree(chain);
 }
 
@@ -801,13 +964,15 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 			 const struct nlmsghdr *nlh,
 			 const struct nft_af_info *afi,
 			 const struct nft_table *table,
-			 const struct nft_chain *chain)
+			 const struct nft_chain *chain,
+			 const struct nlattr * const *nla)
 {
 	ctx->skb   = skb;
 	ctx->nlh   = nlh;
 	ctx->afi   = afi;
 	ctx->table = table;
 	ctx->chain = chain;
+	ctx->nla   = nla;
 }
 
 /*
@@ -910,7 +1075,8 @@ struct nft_expr_info {
 	struct nlattr			*tb[NFT_EXPR_MAXATTR + 1];
 };
 
-static int nf_tables_expr_parse(const struct nlattr *nla,
+static int nf_tables_expr_parse(const struct nft_ctx *ctx,
+				const struct nlattr *nla,
 				struct nft_expr_info *info)
 {
 	const struct nft_expr_type *type;
@@ -935,7 +1101,8 @@ static int nf_tables_expr_parse(const struct nlattr *nla,
 		memset(info->tb, 0, sizeof(info->tb[0]) * (type->maxattr + 1));
 
 	if (type->select_ops != NULL) {
-		ops = type->select_ops((const struct nlattr * const *)info->tb);
+		ops = type->select_ops(ctx,
+				       (const struct nlattr * const *)info->tb);
 		if (IS_ERR(ops)) {
 			err = PTR_ERR(ops);
 			goto err1;
@@ -1012,6 +1179,7 @@ static const struct nla_policy nft_rule_policy[NFTA_RULE_MAX + 1] = {
 				    .len = NFT_CHAIN_MAXNAMELEN - 1 },
 	[NFTA_RULE_HANDLE]	= { .type = NLA_U64 },
 	[NFTA_RULE_EXPRESSIONS]	= { .type = NLA_NESTED },
+	[NFTA_RULE_COMPAT]	= { .type = NLA_NESTED },
 };
 
 static int nf_tables_fill_rule_info(struct sk_buff *skb, u32 portid, u32 seq,
@@ -1269,6 +1437,8 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		handle = nf_tables_alloc_handle(table);
 	}
 
+	nft_ctx_init(&ctx, skb, nlh, afi, table, chain, nla);
+
 	n = 0;
 	size = 0;
 	if (nla[NFTA_RULE_EXPRESSIONS]) {
@@ -1278,7 +1448,7 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 				goto err1;
 			if (n == NFT_RULE_MAXEXPRS)
 				goto err1;
-			err = nf_tables_expr_parse(tmp, &info[n]);
+			err = nf_tables_expr_parse(&ctx, tmp, &info[n]);
 			if (err < 0)
 				goto err1;
 			size += info[n].ops->size;
@@ -1294,7 +1464,6 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 	rule->handle = handle;
 	rule->dlen   = size;
 
-	nft_ctx_init(&ctx, skb, nlh, afi, table, chain);
 	expr = nft_expr_first(rule);
 	for (i = 0; i < n; i++) {
 		err = nf_tables_newexpr(&ctx, &info[i], expr);
@@ -1304,13 +1473,6 @@ static int nf_tables_newrule(struct sock *nlsk, struct sk_buff *skb,
 		expr = nft_expr_next(expr);
 	}
 
-	/* Register hook when first rule is inserted into a base chain */
-	if (list_empty(&chain->rules) && chain->flags & NFT_BASE_CHAIN) {
-		err = nf_register_hook(&nft_base_chain(chain)->ops);
-		if (err < 0)
-			goto err2;
-	}
-
 	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
 		list_replace_rcu(&old_rule->list, &rule->list);
 		nf_tables_rule_destroy(old_rule);
@@ -1379,10 +1541,6 @@ static int nf_tables_delrule(struct sock *nlsk, struct sk_buff *skb,
 		}
 	}
 
-	/* Unregister hook when last rule from base chain is deleted */
-	if (list_empty(&chain->rules) && chain->flags & NFT_BASE_CHAIN)
-		nf_unregister_hook(&nft_base_chain(chain)->ops);
-
 	return 0;
 }
 
@@ -1470,7 +1628,7 @@ static int nft_ctx_init_from_setattr(struct nft_ctx *ctx,
 			return PTR_ERR(table);
 	}
 
-	nft_ctx_init(ctx, skb, nlh, afi, table, NULL);
+	nft_ctx_init(ctx, skb, nlh, afi, table, NULL, nla);
 	return 0;
 }
 
@@ -1799,7 +1957,7 @@ static int nf_tables_newset(struct sock *nlsk, struct sk_buff *skb,
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
-	nft_ctx_init(&ctx, skb, nlh, afi, table, NULL);
+	nft_ctx_init(&ctx, skb, nlh, afi, table, NULL, nla);
 
 	set = nf_tables_set_lookup(table, nla[NFTA_SET_NAME]);
 	if (IS_ERR(set)) {
@@ -1987,7 +2145,7 @@ static int nft_ctx_init_from_elemattr(struct nft_ctx *ctx,
 	if (IS_ERR(table))
 		return PTR_ERR(table);
 
-	nft_ctx_init(ctx, skb, nlh, afi, table, NULL);
+	nft_ctx_init(ctx, skb, nlh, afi, table, NULL, nla);
 	return 0;
 }
 
@@ -2435,23 +2593,27 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
 {
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
-	const struct nft_data *data;
 	const struct nft_set *set;
 	struct nft_set_binding *binding;
 	struct nft_set_iter iter;
-	int err;
 
 	if (ctx->chain == chain)
 		return -ELOOP;
 
 	list_for_each_entry(rule, &chain->rules, list) {
 		nft_rule_for_each_expr(expr, last, rule) {
-			if (!expr->ops->get_verdict)
+			const struct nft_data *data = NULL;
+			int err;
+
+			if (!expr->ops->validate)
 				continue;
 
-			data = expr->ops->get_verdict(expr);
+			err = expr->ops->validate(ctx, expr, &data);
+			if (err < 0)
+				return err;
+
 			if (data == NULL)
-				break;
+				continue;
 
 			switch (data->verdict) {
 			case NFT_JUMP:
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 9aede59..e51a45c 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -60,27 +60,34 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 	return true;
 }
 
-unsigned int nft_do_chain(const struct nf_hook_ops *ops,
-			  struct sk_buff *skb,
-			  const struct net_device *in,
-			  const struct net_device *out,
-			  int (*okfn)(struct sk_buff *))
+struct nft_jumpstack {
+	const struct nft_chain	*chain;
+	const struct nft_rule	*rule;
+};
+
+static inline void
+nft_chain_stats(const struct nft_chain *this, const struct nft_pktinfo *pkt,
+		struct nft_jumpstack *jumpstack, unsigned int stackptr)
+{
+	struct nft_stats __percpu *stats;
+	const struct nft_chain *chain = stackptr ? jumpstack[0].chain : this;
+
+	rcu_read_lock_bh();
+	stats = rcu_dereference(nft_base_chain(chain)->stats);
+	__this_cpu_inc(stats->pkts);
+	__this_cpu_add(stats->bytes, pkt->skb->len);
+	rcu_read_unlock_bh();
+}
+
+unsigned int
+nft_do_chain_pktinfo(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
 {
 	const struct nft_chain *chain = ops->priv;
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
 	struct nft_data data[NFT_REG_MAX + 1];
-	const struct nft_pktinfo pkt = {
-		.skb		= skb,
-		.in		= in,
-		.out		= out,
-		.hooknum	= ops->hooknum,
-	};
 	unsigned int stackptr = 0;
-	struct {
-		const struct nft_chain	*chain;
-		const struct nft_rule	*rule;
-	} jumpstack[NFT_JUMP_STACK_SIZE];
+	struct nft_jumpstack jumpstack[NFT_JUMP_STACK_SIZE];
 
 do_chain:
 	rule = list_entry(&chain->rules, struct nft_rule, list);
@@ -91,8 +98,8 @@ next_rule:
 			if (expr->ops == &nft_cmp_fast_ops)
 				nft_cmp_fast_eval(expr, data);
 			else if (expr->ops != &nft_payload_fast_ops ||
-				 !nft_payload_fast_eval(expr, data, &pkt))
-				expr->ops->eval(expr, data, &pkt);
+				 !nft_payload_fast_eval(expr, data, pkt))
+				expr->ops->eval(expr, data, pkt);
 
 			if (data[NFT_REG_VERDICT].verdict != NFT_CONTINUE)
 				break;
@@ -135,10 +142,11 @@ next_rule:
 		rule  = jumpstack[stackptr].rule;
 		goto next_rule;
 	}
+	nft_chain_stats(chain, pkt, jumpstack, stackptr);
 
-	return NF_ACCEPT;
+	return nft_base_chain(chain)->policy;
 }
-EXPORT_SYMBOL_GPL(nft_do_chain);
+EXPORT_SYMBOL_GPL(nft_do_chain_pktinfo);
 
 int __init nf_tables_core_module_init(void)
 {
diff --git a/net/netfilter/nft_cmp.c b/net/netfilter/nft_cmp.c
index 37134f3..954925d 100644
--- a/net/netfilter/nft_cmp.c
+++ b/net/netfilter/nft_cmp.c
@@ -162,7 +162,8 @@ const struct nft_expr_ops nft_cmp_fast_ops = {
 	.dump		= nft_cmp_fast_dump,
 };
 
-static const struct nft_expr_ops *nft_cmp_select_ops(const struct nlattr * const tb[])
+static const struct nft_expr_ops *
+nft_cmp_select_ops(const struct nft_ctx *ctx, const struct nlattr * const tb[])
 {
 	struct nft_data_desc desc;
 	struct nft_data data;
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
new file mode 100644
index 0000000..4811f76
--- /dev/null
+++ b/net/netfilter/nft_compat.c
@@ -0,0 +1,768 @@
+/*
+ * (C) 2012-2013 by Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This software has been sponsored by Sophos Astaro <http://www.sophos.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nf_tables.h>
+#include <linux/netfilter/nf_tables_compat.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#include <asm/uaccess.h> /* for set_fs */
+#include <net/netfilter/nf_tables.h>
+
+union nft_entry {
+	struct ipt_entry e4;
+	struct ip6t_entry e6;
+};
+
+static inline void
+nft_compat_set_par(struct xt_action_param *par, void *xt, const void *xt_info)
+{
+	par->target	= xt;
+	par->targinfo	= xt_info;
+	par->hotdrop	= false;
+}
+
+static void nft_target_eval(const struct nft_expr *expr,
+			    struct nft_data data[NFT_REG_MAX + 1],
+			    const struct nft_pktinfo *pkt)
+{
+	void *info = nft_expr_priv(expr);
+	struct xt_target *target = expr->ops->data;
+	struct sk_buff *skb = pkt->skb;
+	int ret;
+
+	nft_compat_set_par((struct xt_action_param *)&pkt->xt, target, info);
+
+	ret = target->target(skb, &pkt->xt);
+
+	if (pkt->xt.hotdrop)
+		ret = NF_DROP;
+
+	switch(ret) {
+	case XT_CONTINUE:
+		data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+		break;
+	default:
+		data[NFT_REG_VERDICT].verdict = ret;
+		break;
+	}
+	return;
+}
+
+static const struct nla_policy nft_target_policy[NFTA_TARGET_MAX + 1] = {
+	[NFTA_TARGET_NAME]	= { .type = NLA_NUL_STRING },
+	[NFTA_TARGET_REV]	= { .type = NLA_U32 },
+	[NFTA_TARGET_INFO]	= { .type = NLA_BINARY },
+};
+
+static void
+nft_target_set_tgchk_param(struct xt_tgchk_param *par,
+			   const struct nft_ctx *ctx,
+			   struct xt_target *target, void *info,
+			   union nft_entry *entry, u8 proto, bool inv)
+{
+	par->net	= &init_net;
+	par->table	= ctx->table->name;
+	switch (ctx->afi->family) {
+	case AF_INET:
+		entry->e4.ip.proto = proto;
+		entry->e4.ip.invflags = inv ? IPT_INV_PROTO : 0;
+		break;
+	case AF_INET6:
+		entry->e6.ipv6.proto = proto;
+		entry->e6.ipv6.invflags = inv ? IP6T_INV_PROTO : 0;
+		break;
+	}
+	par->entryinfo	= entry;
+	par->target	= target;
+	par->targinfo	= info;
+	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+		const struct nft_base_chain *basechain =
+						nft_base_chain(ctx->chain);
+		const struct nf_hook_ops *ops = &basechain->ops;
+
+		par->hook_mask = 1 << ops->hooknum;
+	}
+	par->family	= ctx->afi->family;
+}
+
+static void target_compat_from_user(struct xt_target *t, void *in, void *out)
+{
+#ifdef CONFIG_COMPAT
+	if (t->compat_from_user) {
+		int pad;
+
+		t->compat_from_user(out, in);
+		pad = XT_ALIGN(t->targetsize) - t->targetsize;
+		if (pad > 0)
+			memset(out + t->targetsize, 0, pad);
+	} else
+#endif
+		memcpy(out, in, XT_ALIGN(t->targetsize));
+}
+
+static inline int nft_compat_target_offset(struct xt_target *target)
+{
+#ifdef CONFIG_COMPAT
+	return xt_compat_target_offset(target);
+#else
+	return 0;
+#endif
+}
+
+static const struct nla_policy nft_rule_compat_policy[NFTA_RULE_COMPAT_MAX + 1] = {
+	[NFTA_RULE_COMPAT_PROTO]	= { .type = NLA_U32 },
+	[NFTA_RULE_COMPAT_FLAGS]	= { .type = NLA_U32 },
+};
+
+static u8 nft_parse_compat(const struct nlattr *attr, bool *inv)
+{
+	struct nlattr *tb[NFTA_RULE_COMPAT_MAX+1];
+	u32 flags;
+	int err;
+
+	err = nla_parse_nested(tb, NFTA_RULE_COMPAT_MAX, attr,
+			       nft_rule_compat_policy);
+	if (err < 0)
+		return err;
+
+	if (!tb[NFTA_RULE_COMPAT_PROTO] || !tb[NFTA_RULE_COMPAT_FLAGS])
+		return -EINVAL;
+
+	flags = ntohl(nla_get_be32(tb[NFTA_RULE_COMPAT_FLAGS]));
+	if (flags & ~NFT_RULE_COMPAT_F_MASK)
+		return -EINVAL;
+	if (flags & NFT_RULE_COMPAT_F_INV)
+		*inv = true;
+
+	return ntohl(nla_get_be32(tb[NFTA_RULE_COMPAT_PROTO]));
+}
+
+static int
+nft_target_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		const struct nlattr * const tb[])
+{
+	void *info = nft_expr_priv(expr);
+	struct xt_target *target = expr->ops->data;
+	struct xt_tgchk_param par;
+	size_t size = XT_ALIGN(nla_len(tb[NFTA_TARGET_INFO]));
+	u8 proto = 0;
+	bool inv = false;
+	union nft_entry e = {};
+	int ret;
+
+	target_compat_from_user(target, nla_data(tb[NFTA_TARGET_INFO]), info);
+
+	if (ctx->nla[NFTA_RULE_COMPAT])
+		proto = nft_parse_compat(ctx->nla[NFTA_RULE_COMPAT], &inv);
+
+	nft_target_set_tgchk_param(&par, ctx, target, info, &e, proto, inv);
+
+	ret = xt_check_target(&par, size, proto, inv);
+	if (ret < 0)
+		goto err;
+
+	/* The standard target cannot be used */
+	if (target->target == NULL) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	return 0;
+err:
+	module_put(target->me);
+	return ret;
+}
+
+static void
+nft_target_destroy(const struct nft_expr *expr)
+{
+	struct xt_target *target = expr->ops->data;
+
+	module_put(target->me);
+}
+
+static int
+target_dump_info(struct sk_buff *skb, const struct xt_target *t, const void *in)
+{
+	int ret;
+
+#ifdef CONFIG_COMPAT
+	if (t->compat_to_user) {
+		mm_segment_t old_fs;
+		void *out;
+
+		out = kmalloc(XT_ALIGN(t->targetsize), GFP_ATOMIC);
+		if (out == NULL)
+			return -ENOMEM;
+
+		/* We want to reuse existing compat_to_user */
+		old_fs = get_fs();
+		set_fs(KERNEL_DS);
+		t->compat_to_user(out, in);
+		set_fs(old_fs);
+		ret = nla_put(skb, NFTA_TARGET_INFO, XT_ALIGN(t->targetsize), out);
+		kfree(out);
+	} else
+#endif
+		ret = nla_put(skb, NFTA_TARGET_INFO, XT_ALIGN(t->targetsize), in);
+
+	return ret;
+}
+
+static int nft_target_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	const struct xt_target *target = expr->ops->data;
+	void *info = nft_expr_priv(expr);
+
+	if (nla_put_string(skb, NFTA_TARGET_NAME, target->name) ||
+	    nla_put_be32(skb, NFTA_TARGET_REV, htonl(target->revision)) ||
+	    target_dump_info(skb, target, info))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int nft_target_validate(const struct nft_ctx *ctx,
+			       const struct nft_expr *expr,
+			       const struct nft_data **data)
+{
+	struct xt_target *target = expr->ops->data;
+	unsigned int hook_mask = 0;
+
+	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+		const struct nft_base_chain *basechain =
+						nft_base_chain(ctx->chain);
+		const struct nf_hook_ops *ops = &basechain->ops;
+
+		hook_mask = 1 << ops->hooknum;
+		if (hook_mask & target->hooks)
+			return 0;
+
+		/* This target is being called from an invalid chain */
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void nft_match_eval(const struct nft_expr *expr,
+			   struct nft_data data[NFT_REG_MAX + 1],
+			   const struct nft_pktinfo *pkt)
+{
+	void *info = nft_expr_priv(expr);
+	struct xt_match *match = expr->ops->data;
+	struct sk_buff *skb = pkt->skb;
+	bool ret;
+
+	nft_compat_set_par((struct xt_action_param *)&pkt->xt, match, info);
+
+	ret = match->match(skb, (struct xt_action_param *)&pkt->xt);
+
+	if (pkt->xt.hotdrop) {
+		data[NFT_REG_VERDICT].verdict = NF_DROP;
+		return;
+	}
+
+	switch(ret) {
+	case true:
+		data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
+		break;
+	case false:
+		data[NFT_REG_VERDICT].verdict = NFT_BREAK;
+		break;
+	}
+}
+
+static const struct nla_policy nft_match_policy[NFTA_MATCH_MAX + 1] = {
+	[NFTA_MATCH_NAME]	= { .type = NLA_NUL_STRING },
+	[NFTA_MATCH_REV]	= { .type = NLA_U32 },
+	[NFTA_MATCH_INFO]	= { .type = NLA_BINARY },
+};
+
+/* struct xt_mtchk_param and xt_tgchk_param look very similar */
+static void
+nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
+			  struct xt_match *match, void *info,
+			  union nft_entry *entry, u8 proto, bool inv)
+{
+	par->net	= &init_net;
+	par->table	= ctx->table->name;
+	switch (ctx->afi->family) {
+	case AF_INET:
+		entry->e4.ip.proto = proto;
+		entry->e4.ip.invflags = inv ? IPT_INV_PROTO : 0;
+		break;
+	case AF_INET6:
+		entry->e6.ipv6.proto = proto;
+		entry->e6.ipv6.invflags = inv ? IP6T_INV_PROTO : 0;
+		break;
+	}
+	par->entryinfo	= entry;
+	par->match	= match;
+	par->matchinfo	= info;
+	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+		const struct nft_base_chain *basechain =
+						nft_base_chain(ctx->chain);
+		const struct nf_hook_ops *ops = &basechain->ops;
+
+		par->hook_mask = 1 << ops->hooknum;
+	}
+	par->family	= ctx->afi->family;
+}
+
+static void match_compat_from_user(struct xt_match *m, void *in, void *out)
+{
+#ifdef CONFIG_COMPAT
+	if (m->compat_from_user) {
+		int pad;
+
+		m->compat_from_user(out, in);
+		pad = XT_ALIGN(m->matchsize) - m->matchsize;
+		if (pad > 0)
+			memset(out + m->matchsize, 0, pad);
+	} else
+#endif
+		memcpy(out, in, XT_ALIGN(m->matchsize));
+}
+
+static int
+nft_match_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
+		const struct nlattr * const tb[])
+{
+	void *info = nft_expr_priv(expr);
+	struct xt_match *match = expr->ops->data;
+	struct xt_mtchk_param par;
+	size_t size = XT_ALIGN(nla_len(tb[NFTA_MATCH_INFO]));
+	u8 proto = 0;
+	bool inv = false;
+	union nft_entry e = {};
+	int ret;
+
+	match_compat_from_user(match, nla_data(tb[NFTA_MATCH_INFO]), info);
+
+	if (ctx->nla[NFTA_RULE_COMPAT])
+		proto = nft_parse_compat(ctx->nla[NFTA_RULE_COMPAT], &inv);
+
+	nft_match_set_mtchk_param(&par, ctx, match, info, &e, proto, inv);
+
+	ret = xt_check_match(&par, size, proto, inv);
+	if (ret < 0)
+		goto err;
+
+	return 0;
+err:
+	module_put(match->me);
+	return ret;
+}
+
+static void
+nft_match_destroy(const struct nft_expr *expr)
+{
+	struct xt_match *match = expr->ops->data;
+
+	module_put(match->me);
+}
+
+static int
+match_dump_info(struct sk_buff *skb, const struct xt_match *m, const void *in)
+{
+	int ret;
+
+#ifdef CONFIG_COMPAT
+	if (m->compat_to_user) {
+		mm_segment_t old_fs;
+		void *out;
+
+		out = kmalloc(XT_ALIGN(m->matchsize), GFP_ATOMIC);
+		if (out == NULL)
+			return -ENOMEM;
+
+		/* We want to reuse existing compat_to_user */
+		old_fs = get_fs();
+		set_fs(KERNEL_DS);
+		m->compat_to_user(out, in);
+		set_fs(old_fs);
+		ret = nla_put(skb, NFTA_MATCH_INFO, XT_ALIGN(m->matchsize), out);
+		kfree(out);
+	} else
+#endif
+		ret = nla_put(skb, NFTA_MATCH_INFO, XT_ALIGN(m->matchsize), in);
+
+	return ret;
+}
+
+static inline int nft_compat_match_offset(struct xt_match *match)
+{
+#ifdef CONFIG_COMPAT
+	return xt_compat_match_offset(match);
+#else
+	return 0;
+#endif
+}
+
+static int nft_match_dump(struct sk_buff *skb, const struct nft_expr *expr)
+{
+	void *info = nft_expr_priv(expr);
+	struct xt_match *match = expr->ops->data;
+
+	if (nla_put_string(skb, NFTA_MATCH_NAME, match->name) ||
+	    nla_put_be32(skb, NFTA_MATCH_REV, htonl(match->revision)) ||
+	    match_dump_info(skb, match, info))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int nft_match_validate(const struct nft_ctx *ctx,
+			      const struct nft_expr *expr,
+			      const struct nft_data **data)
+{
+	struct xt_match *match = expr->ops->data;
+	unsigned int hook_mask = 0;
+
+	if (ctx->chain->flags & NFT_BASE_CHAIN) {
+		const struct nft_base_chain *basechain =
+						nft_base_chain(ctx->chain);
+		const struct nf_hook_ops *ops = &basechain->ops;
+
+		hook_mask = 1 << ops->hooknum;
+		if (hook_mask & match->hooks)
+			return 0;
+
+		/* This match is being called from an invalid chain */
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int
+nfnl_compat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
+		      int event, u16 family, const char *name,
+		      int rev, int target)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = portid ? NLM_F_MULTI : 0;
+
+	event |= NFNL_SUBSYS_NFT_COMPAT << 8;
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = family;
+	nfmsg->version = NFNETLINK_V0;
+	nfmsg->res_id = 0;
+
+	if (nla_put_string(skb, NFTA_COMPAT_NAME, name) ||
+	    nla_put_be32(skb, NFTA_COMPAT_REV, htonl(rev)) ||
+	    nla_put_be32(skb, NFTA_COMPAT_TYPE, htonl(target)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nlmsg_failure:
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int
+nfnl_compat_get(struct sock *nfnl, struct sk_buff *skb,
+		const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+{
+	int ret = 0, target;
+	struct nfgenmsg *nfmsg;
+	const char *fmt;
+	const char *name;
+	u32 rev;
+	struct sk_buff *skb2;
+
+	if (tb[NFTA_COMPAT_NAME] == NULL ||
+	    tb[NFTA_COMPAT_REV] == NULL ||
+	    tb[NFTA_COMPAT_TYPE] == NULL)
+		return -EINVAL;
+
+	name = nla_data(tb[NFTA_COMPAT_NAME]);
+	rev = ntohl(nla_get_be32(tb[NFTA_COMPAT_REV]));
+	target = ntohl(nla_get_be32(tb[NFTA_COMPAT_TYPE]));
+
+	nfmsg = nlmsg_data(nlh);
+
+	switch(nfmsg->nfgen_family) {
+	case AF_INET:
+		fmt = "ipt_%s";
+		break;
+	case AF_INET6:
+		fmt = "ip6t_%s";
+		break;
+	default:
+		pr_err("nft_compat: unsupported protocol %d\n",
+			nfmsg->nfgen_family);
+		return -EINVAL;
+	}
+
+	try_then_request_module(xt_find_revision(nfmsg->nfgen_family, name,
+						 rev, target, &ret),
+						 fmt, name);
+
+	if (ret < 0)
+		return ret;
+
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL)
+		return -ENOMEM;
+
+	/* include the best revision for this extension in the message */
+	if (nfnl_compat_fill_info(skb2, NETLINK_CB(skb).portid,
+				  nlh->nlmsg_seq,
+				  NFNL_MSG_TYPE(nlh->nlmsg_type),
+				  NFNL_MSG_COMPAT_GET,
+				  nfmsg->nfgen_family,
+				  name, ret, target) <= 0) {
+		kfree_skb(skb2);
+		return -ENOSPC;
+	}
+
+	ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid,
+				MSG_DONTWAIT);
+	if (ret > 0)
+		ret = 0;
+
+	return ret == -EAGAIN ? -ENOBUFS : ret;
+}
+
+static const struct nla_policy nfnl_compat_policy_get[NFTA_COMPAT_MAX+1] = {
+	[NFTA_COMPAT_NAME]	= { .type = NLA_NUL_STRING,
+				    .len = NFT_COMPAT_NAME_MAX-1 },
+	[NFTA_COMPAT_REV]	= { .type = NLA_U32 },
+	[NFTA_COMPAT_TYPE]	= { .type = NLA_U32 },
+};
+
+static const struct nfnl_callback nfnl_nft_compat_cb[NFNL_MSG_COMPAT_MAX] = {
+	[NFNL_MSG_COMPAT_GET]		= { .call = nfnl_compat_get,
+					    .attr_count = NFTA_COMPAT_MAX,
+					    .policy = nfnl_compat_policy_get },
+};
+
+static const struct nfnetlink_subsystem nfnl_compat_subsys = {
+	.name		= "nft-compat",
+	.subsys_id	= NFNL_SUBSYS_NFT_COMPAT,
+	.cb_count	= NFNL_MSG_COMPAT_MAX,
+	.cb		= nfnl_nft_compat_cb,
+};
+
+static LIST_HEAD(nft_match_list);
+
+struct nft_xt {
+	struct list_head	head;
+	struct nft_expr_ops	ops;
+};
+
+static struct nft_expr_type nft_match_type;
+
+static const struct nft_expr_ops *
+nft_match_select_ops(const struct nft_ctx *ctx,
+		     const struct nlattr * const tb[])
+{
+	struct nft_xt *nft_match;
+	struct xt_match *match;
+	char *mt_name;
+	__u32 rev, family;
+
+	if (tb[NFTA_MATCH_NAME] == NULL ||
+	    tb[NFTA_MATCH_REV] == NULL ||
+	    tb[NFTA_MATCH_INFO] == NULL)
+		return ERR_PTR(-EINVAL);
+
+	mt_name = nla_data(tb[NFTA_MATCH_NAME]);
+	rev = ntohl(nla_get_be32(tb[NFTA_MATCH_REV]));
+	family = ctx->afi->family;
+
+	/* Re-use the existing match if it's already loaded. */
+	list_for_each_entry(nft_match, &nft_match_list, head) {
+		struct xt_match *match = nft_match->ops.data;
+
+		if (strcmp(match->name, mt_name) == 0 &&
+		    match->revision == rev && match->family == family)
+			return &nft_match->ops;
+	}
+
+	match = xt_request_find_match(family, mt_name, rev);
+	if (IS_ERR(match))
+		return ERR_PTR(-ENOENT);
+
+	/* This is the first time we use this match, allocate operations */
+	nft_match = kzalloc(sizeof(struct nft_xt), GFP_KERNEL);
+	if (nft_match == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	nft_match->ops.type = &nft_match_type;
+	nft_match->ops.size = NFT_EXPR_SIZE(XT_ALIGN(match->matchsize) +
+					    nft_compat_match_offset(match));
+	nft_match->ops.eval = nft_match_eval;
+	nft_match->ops.init = nft_match_init;
+	nft_match->ops.destroy = nft_match_destroy;
+	nft_match->ops.dump = nft_match_dump;
+	nft_match->ops.validate = nft_match_validate;
+	nft_match->ops.data = match;
+
+	list_add(&nft_match->head, &nft_match_list);
+
+	return &nft_match->ops;
+}
+
+static void nft_match_release(void)
+{
+	struct nft_xt *nft_match;
+
+	list_for_each_entry(nft_match, &nft_match_list, head)
+		kfree(nft_match);
+}
+
+static struct nft_expr_type nft_match_type __read_mostly = {
+	.name		= "match",
+	.select_ops	= nft_match_select_ops,
+	.policy		= nft_match_policy,
+	.maxattr	= NFTA_MATCH_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static LIST_HEAD(nft_target_list);
+
+static struct nft_expr_type nft_target_type;
+
+static const struct nft_expr_ops *
+nft_target_select_ops(const struct nft_ctx *ctx,
+		      const struct nlattr * const tb[])
+{
+	struct nft_xt *nft_target;
+	struct xt_target *target;
+	char *tg_name;
+	__u32 rev, family;
+
+	if (tb[NFTA_TARGET_NAME] == NULL ||
+	    tb[NFTA_TARGET_REV] == NULL ||
+	    tb[NFTA_TARGET_INFO] == NULL)
+		return ERR_PTR(-EINVAL);
+
+	tg_name = nla_data(tb[NFTA_TARGET_NAME]);
+	rev = ntohl(nla_get_be32(tb[NFTA_TARGET_REV]));
+	family = ctx->afi->family;
+
+	/* Re-use the existing target if it's already loaded. */
+	list_for_each_entry(nft_target, &nft_match_list, head) {
+		struct xt_target *target = nft_target->ops.data;
+
+		if (strcmp(target->name, tg_name) == 0 &&
+		    target->revision == rev && target->family == family)
+			return &nft_target->ops;
+	}
+
+	target = xt_request_find_target(family, tg_name, rev);
+	if (IS_ERR(target))
+		return ERR_PTR(-ENOENT);
+
+	/* This is the first time we use this target, allocate operations */
+	nft_target = kzalloc(sizeof(struct nft_xt), GFP_KERNEL);
+	if (nft_target == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	nft_target->ops.type = &nft_target_type;
+	nft_target->ops.size = NFT_EXPR_SIZE(XT_ALIGN(target->targetsize) +
+					     nft_compat_target_offset(target));
+	nft_target->ops.eval = nft_target_eval;
+	nft_target->ops.init = nft_target_init;
+	nft_target->ops.destroy = nft_target_destroy;
+	nft_target->ops.dump = nft_target_dump;
+	nft_target->ops.validate = nft_target_validate;
+	nft_target->ops.data = target;
+
+	list_add(&nft_target->head, &nft_target_list);
+
+	return &nft_target->ops;
+}
+
+static void nft_target_release(void)
+{
+	struct nft_xt *nft_target;
+
+	list_for_each_entry(nft_target, &nft_target_list, head)
+		kfree(nft_target);
+}
+
+static struct nft_expr_type nft_target_type __read_mostly = {
+	.name		= "target",
+	.select_ops	= nft_target_select_ops,
+	.policy		= nft_target_policy,
+	.maxattr	= NFTA_TARGET_MAX,
+	.owner		= THIS_MODULE,
+};
+
+static int __init nft_compat_module_init(void)
+{
+	int ret;
+
+	ret = nft_register_expr(&nft_match_type);
+	if (ret < 0)
+		return ret;
+
+	ret = nft_register_expr(&nft_target_type);
+	if (ret < 0)
+		goto err_match;
+
+	ret = nfnetlink_subsys_register(&nfnl_compat_subsys);
+	if (ret < 0) {
+		pr_err("nft_compat: cannot register with nfnetlink.\n");
+		goto err_target;
+	}
+
+	pr_info("nf_tables_compat: (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>\n");
+
+	return ret;
+
+err_target:
+	nft_unregister_expr(&nft_target_type);
+err_match:
+	nft_unregister_expr(&nft_match_type);
+	return ret;
+}
+
+static void __exit nft_compat_module_exit(void)
+{
+	nfnetlink_subsys_unregister(&nfnl_compat_subsys);
+	nft_unregister_expr(&nft_target_type);
+	nft_unregister_expr(&nft_match_type);
+	nft_match_release();
+	nft_target_release();
+}
+
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_NFT_COMPAT);
+
+module_init(nft_compat_module_init);
+module_exit(nft_compat_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_ALIAS_NFT_EXPR("match");
+MODULE_ALIAS_NFT_EXPR("target");
diff --git a/net/netfilter/nft_immediate.c b/net/netfilter/nft_immediate.c
index 1bfeeaf..f169501 100644
--- a/net/netfilter/nft_immediate.c
+++ b/net/netfilter/nft_immediate.c
@@ -90,14 +90,16 @@ nla_put_failure:
 	return -1;
 }
 
-static const struct nft_data *nft_immediate_get_verdict(const struct nft_expr *expr)
+static int nft_immediate_validate(const struct nft_ctx *ctx,
+				  const struct nft_expr *expr,
+				  const struct nft_data **data)
 {
 	const struct nft_immediate_expr *priv = nft_expr_priv(expr);
 
 	if (priv->dreg == NFT_REG_VERDICT)
-		return &priv->data;
-	else
-		return NULL;
+		*data = &priv->data;
+
+	return 0;
 }
 
 static struct nft_expr_type nft_imm_type;
@@ -108,7 +110,7 @@ static const struct nft_expr_ops nft_imm_ops = {
 	.init		= nft_immediate_init,
 	.destroy	= nft_immediate_destroy,
 	.dump		= nft_immediate_dump,
-	.get_verdict	= nft_immediate_get_verdict,
+	.validate	= nft_immediate_validate,
 };
 
 static struct nft_expr_type nft_imm_type __read_mostly = {
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 7cf13f7..bc8bdb2 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -107,7 +107,9 @@ const struct nft_expr_ops nft_payload_fast_ops = {
 	.dump		= nft_payload_dump,
 };
 
-static const struct nft_expr_ops *nft_payload_select_ops(const struct nlattr * const tb[])
+static const struct nft_expr_ops *
+nft_payload_select_ops(const struct nft_ctx *ctx,
+		       const struct nlattr * const tb[])
 {
 	enum nft_payload_bases base;
 	unsigned int offset, len;
-- 
1.7.10.4

