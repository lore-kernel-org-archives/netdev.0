From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/50] netfilter: nat: add dependencies on conntrack module
Date: Wed,  7 Dec 2016 22:52:21 +0100
Message-ID: <1481147576-5690-16-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

MASQUERADE, S/DNAT and REDIRECT already call functions that depend on the
conntrack module.

However, since the conntrack hooks are now registered in a lazy fashion
(i.e., only when needed) a symbol reference is not enough.

Thus, when something is added to a nat table, make sure that it will see
packets by calling nf_ct_netns_get() which will register the conntrack
hooks in the current netns.

An alternative would be to add these dependencies to the NAT table.

However, that has problems when using non-modular builds -- we might
register e.g. ipv6 conntrack before its initcall has run, leading to NULL
deref crashes since its per-netns storage has not yet been allocated.

Adding the dependency in the modules instead has the advantage that nat
table also does not register its hooks until rules are added.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_MASQUERADE.c |  8 +++++++-
 net/netfilter/xt_NETMAP.c           | 11 +++++++++--
 net/netfilter/xt_REDIRECT.c         | 12 ++++++++++--
 net/netfilter/xt_nat.c              | 18 +++++++++++++++++-
 4 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 34cfb9b0bc0a..a03e4e7ef5f9 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -41,7 +41,7 @@ static int masquerade_tg_check(const struct xt_tgchk_param *par)
 		pr_debug("bad rangesize %u\n", mr->rangesize);
 		return -EINVAL;
 	}
-	return 0;
+	return nf_ct_netns_get(par->net, par->family);
 }
 
 static unsigned int
@@ -59,6 +59,11 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 				      xt_out(par));
 }
 
+static void masquerade_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_netns_put(par->net, par->family);
+}
+
 static struct xt_target masquerade_tg_reg __read_mostly = {
 	.name		= "MASQUERADE",
 	.family		= NFPROTO_IPV4,
@@ -67,6 +72,7 @@ static struct xt_target masquerade_tg_reg __read_mostly = {
 	.table		= "nat",
 	.hooks		= 1 << NF_INET_POST_ROUTING,
 	.checkentry	= masquerade_tg_check,
+	.destroy	= masquerade_tg_destroy,
 	.me		= THIS_MODULE,
 };
 
diff --git a/net/netfilter/xt_NETMAP.c b/net/netfilter/xt_NETMAP.c
index 94d0b5411192..e45a01255e70 100644
--- a/net/netfilter/xt_NETMAP.c
+++ b/net/netfilter/xt_NETMAP.c
@@ -60,7 +60,12 @@ static int netmap_tg6_checkentry(const struct xt_tgchk_param *par)
 
 	if (!(range->flags & NF_NAT_RANGE_MAP_IPS))
 		return -EINVAL;
-	return 0;
+	return nf_ct_netns_get(par->net, par->family);
+}
+
+static void netmap_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static unsigned int
@@ -111,7 +116,7 @@ static int netmap_tg4_check(const struct xt_tgchk_param *par)
 		pr_debug("bad rangesize %u.\n", mr->rangesize);
 		return -EINVAL;
 	}
-	return 0;
+	return nf_ct_netns_get(par->net, par->family);
 }
 
 static struct xt_target netmap_tg_reg[] __read_mostly = {
@@ -127,6 +132,7 @@ static struct xt_target netmap_tg_reg[] __read_mostly = {
 		              (1 << NF_INET_LOCAL_OUT) |
 		              (1 << NF_INET_LOCAL_IN),
 		.checkentry = netmap_tg6_checkentry,
+		.destroy    = netmap_tg_destroy,
 		.me         = THIS_MODULE,
 	},
 	{
@@ -141,6 +147,7 @@ static struct xt_target netmap_tg_reg[] __read_mostly = {
 		              (1 << NF_INET_LOCAL_OUT) |
 		              (1 << NF_INET_LOCAL_IN),
 		.checkentry = netmap_tg4_check,
+		.destroy    = netmap_tg_destroy,
 		.me         = THIS_MODULE,
 	},
 };
diff --git a/net/netfilter/xt_REDIRECT.c b/net/netfilter/xt_REDIRECT.c
index 651dce65a30b..98a4c6d4f1cb 100644
--- a/net/netfilter/xt_REDIRECT.c
+++ b/net/netfilter/xt_REDIRECT.c
@@ -40,7 +40,13 @@ static int redirect_tg6_checkentry(const struct xt_tgchk_param *par)
 
 	if (range->flags & NF_NAT_RANGE_MAP_IPS)
 		return -EINVAL;
-	return 0;
+
+	return nf_ct_netns_get(par->net, par->family);
+}
+
+static void redirect_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_netns_put(par->net, par->family);
 }
 
 /* FIXME: Take multiple ranges --RR */
@@ -56,7 +62,7 @@ static int redirect_tg4_check(const struct xt_tgchk_param *par)
 		pr_debug("bad rangesize %u.\n", mr->rangesize);
 		return -EINVAL;
 	}
-	return 0;
+	return nf_ct_netns_get(par->net, par->family);
 }
 
 static unsigned int
@@ -72,6 +78,7 @@ static struct xt_target redirect_tg_reg[] __read_mostly = {
 		.revision   = 0,
 		.table      = "nat",
 		.checkentry = redirect_tg6_checkentry,
+		.destroy    = redirect_tg_destroy,
 		.target     = redirect_tg6,
 		.targetsize = sizeof(struct nf_nat_range),
 		.hooks      = (1 << NF_INET_PRE_ROUTING) |
@@ -85,6 +92,7 @@ static struct xt_target redirect_tg_reg[] __read_mostly = {
 		.table      = "nat",
 		.target     = redirect_tg4,
 		.checkentry = redirect_tg4_check,
+		.destroy    = redirect_tg_destroy,
 		.targetsize = sizeof(struct nf_nat_ipv4_multi_range_compat),
 		.hooks      = (1 << NF_INET_PRE_ROUTING) |
 		              (1 << NF_INET_LOCAL_OUT),
diff --git a/net/netfilter/xt_nat.c b/net/netfilter/xt_nat.c
index bea7464cc43f..8107b3eb865f 100644
--- a/net/netfilter/xt_nat.c
+++ b/net/netfilter/xt_nat.c
@@ -23,7 +23,17 @@ static int xt_nat_checkentry_v0(const struct xt_tgchk_param *par)
 			par->target->name);
 		return -EINVAL;
 	}
-	return 0;
+	return nf_ct_netns_get(par->net, par->family);
+}
+
+static int xt_nat_checkentry(const struct xt_tgchk_param *par)
+{
+	return nf_ct_netns_get(par->net, par->family);
+}
+
+static void xt_nat_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_ct_netns_put(par->net, par->family);
 }
 
 static void xt_nat_convert_range(struct nf_nat_range *dst,
@@ -106,6 +116,7 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 		.name		= "SNAT",
 		.revision	= 0,
 		.checkentry	= xt_nat_checkentry_v0,
+		.destroy	= xt_nat_destroy,
 		.target		= xt_snat_target_v0,
 		.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 		.family		= NFPROTO_IPV4,
@@ -118,6 +129,7 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 		.name		= "DNAT",
 		.revision	= 0,
 		.checkentry	= xt_nat_checkentry_v0,
+		.destroy	= xt_nat_destroy,
 		.target		= xt_dnat_target_v0,
 		.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
 		.family		= NFPROTO_IPV4,
@@ -129,6 +141,8 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 	{
 		.name		= "SNAT",
 		.revision	= 1,
+		.checkentry	= xt_nat_checkentry,
+		.destroy	= xt_nat_destroy,
 		.target		= xt_snat_target_v1,
 		.targetsize	= sizeof(struct nf_nat_range),
 		.table		= "nat",
@@ -139,6 +153,8 @@ static struct xt_target xt_nat_target_reg[] __read_mostly = {
 	{
 		.name		= "DNAT",
 		.revision	= 1,
+		.checkentry	= xt_nat_checkentry,
+		.destroy	= xt_nat_destroy,
 		.target		= xt_dnat_target_v1,
 		.targetsize	= sizeof(struct nf_nat_range),
 		.table		= "nat",
-- 
2.1.4

