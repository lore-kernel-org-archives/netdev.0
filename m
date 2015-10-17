From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/35] netfilter: remove hook owner refcounting
Date: Sat, 17 Oct 2015 13:33:02 +0200
Message-ID: <1445081590-2924-28-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48474 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbbJQL0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:36 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

since commit 8405a8fff3f8 ("netfilter: nf_qeueue: Drop queue entries on
nf_unregister_hook") all pending queued entries are discarded.

So we can simply remove all of the owner handling -- when module is
removed it also needs to unregister all its hooks.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h                      |  1 -
 net/bridge/br_netfilter_hooks.c                |  7 -------
 net/bridge/netfilter/ebtable_filter.c          |  3 ---
 net/bridge/netfilter/ebtable_nat.c             |  3 ---
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  2 --
 net/ipv4/netfilter/iptable_nat.c               |  4 ----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  6 ------
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  2 --
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  2 --
 net/ipv6/netfilter/ip6table_nat.c              |  4 ----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  6 ------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  2 --
 net/netfilter/ipvs/ip_vs_core.c                | 12 ------------
 net/netfilter/nf_queue.c                       |  5 -----
 net/netfilter/nf_tables_api.c                  |  1 -
 net/netfilter/x_tables.c                       |  1 -
 security/selinux/hooks.c                       |  5 -----
 security/smack/smack_netfilter.c               |  2 --
 18 files changed, 68 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index edb3dc3..ef11e1d 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -90,7 +90,6 @@ struct nf_hook_ops {
 	/* User fills in from here down. */
 	nf_hookfn		*hook;
 	struct net_device	*dev;
-	struct module		*owner;
 	void			*priv;
 	u_int8_t		pf;
 	unsigned int		hooknum;
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 18905d4..9d30519 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -901,49 +901,42 @@ EXPORT_SYMBOL_GPL(br_netfilter_enable);
 static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 	{
 		.hook = br_nf_pre_routing,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_PRE_ROUTING,
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
 		.hook = br_nf_local_in,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_LOCAL_IN,
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
 		.hook = br_nf_forward_ip,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_FORWARD,
 		.priority = NF_BR_PRI_BRNF - 1,
 	},
 	{
 		.hook = br_nf_forward_arp,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_FORWARD,
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
 		.hook = br_nf_post_routing,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_BRIDGE,
 		.hooknum = NF_BR_POST_ROUTING,
 		.priority = NF_BR_PRI_LAST,
 	},
 	{
 		.hook = ip_sabotage_in,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_IPV4,
 		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP_PRI_FIRST,
 	},
 	{
 		.hook = ip_sabotage_in,
-		.owner = THIS_MODULE,
 		.pf = NFPROTO_IPV6,
 		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP6_PRI_FIRST,
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index f9242df..32eccd1 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -73,21 +73,18 @@ ebt_out_hook(void *priv, struct sk_buff *skb,
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 	{
 		.hook		= ebt_in_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_IN,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
 		.hook		= ebt_in_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_FORWARD,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
 		.hook		= ebt_out_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
 		.priority	= NF_BR_PRI_FILTER_OTHER,
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 4bbefe0..ec55358 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -73,21 +73,18 @@ ebt_nat_out(void *priv, struct sk_buff *skb,
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 	{
 		.hook		= ebt_nat_out,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
 		.priority	= NF_BR_PRI_NAT_DST_OTHER,
 	},
 	{
 		.hook		= ebt_nat_out,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_POST_ROUTING,
 		.priority	= NF_BR_PRI_NAT_SRC,
 	},
 	{
 		.hook		= ebt_nat_in,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_BRIDGE,
 		.hooknum	= NF_BR_PRE_ROUTING,
 		.priority	= NF_BR_PRI_NAT_DST_BRIDGED,
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 6a6e762..f105b6f 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -437,14 +437,12 @@ static struct xt_target synproxy_tg4_reg __read_mostly = {
 static struct nf_hook_ops ipv4_synproxy_ops[] __read_mostly = {
 	{
 		.hook		= ipv4_synproxy_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
 	},
 	{
 		.hook		= ipv4_synproxy_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 3a2e4d8..ae2cd27 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -68,7 +68,6 @@ static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 	/* Before packet filtering, change destination */
 	{
 		.hook		= iptable_nat_ipv4_in,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_NAT_DST,
@@ -76,7 +75,6 @@ static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 	/* After packet filtering, change source */
 	{
 		.hook		= iptable_nat_ipv4_out,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_NAT_SRC,
@@ -84,7 +82,6 @@ static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 	/* Before packet filtering, change destination */
 	{
 		.hook		= iptable_nat_ipv4_local_fn,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST,
@@ -92,7 +89,6 @@ static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 	/* After packet filtering, change source */
 	{
 		.hook		= iptable_nat_ipv4_fn,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC,
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 752fb40..461ca92 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -166,42 +166,36 @@ static unsigned int ipv4_conntrack_local(void *priv,
 static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 	{
 		.hook		= ipv4_conntrack_in,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv4_conntrack_local,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv4_helper,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_HELPER,
 	},
 	{
 		.hook		= ipv4_confirm,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
 	},
 	{
 		.hook		= ipv4_helper,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_HELPER,
 	},
 	{
 		.hook		= ipv4_confirm,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index b246346..9df3f93 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -94,14 +94,12 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 static struct nf_hook_ops ipv4_defrag_ops[] = {
 	{
 		.hook		= ipv4_conntrack_defrag,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook           = ipv4_conntrack_defrag,
-		.owner          = THIS_MODULE,
 		.pf             = NFPROTO_IPV4,
 		.hooknum        = NF_INET_LOCAL_OUT,
 		.priority       = NF_IP_PRI_CONNTRACK_DEFRAG,
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 5312e9d..3426d9d 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -458,14 +458,12 @@ static struct xt_target synproxy_tg6_reg __read_mostly = {
 static struct nf_hook_ops ipv6_synproxy_ops[] __read_mostly = {
 	{
 		.hook		= ipv6_synproxy_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
 	},
 	{
 		.hook		= ipv6_synproxy_hook,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index abea175..de2a10a 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -70,7 +70,6 @@ static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
 	/* Before packet filtering, change destination */
 	{
 		.hook		= ip6table_nat_in,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_NAT_DST,
@@ -78,7 +77,6 @@ static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
 	/* After packet filtering, change source */
 	{
 		.hook		= ip6table_nat_out,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_NAT_SRC,
@@ -86,7 +84,6 @@ static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
 	/* Before packet filtering, change destination */
 	{
 		.hook		= ip6table_nat_local_fn,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST,
@@ -94,7 +91,6 @@ static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
 	/* After packet filtering, change source */
 	{
 		.hook		= ip6table_nat_fn,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index dd83ad4..1aa5848 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -187,42 +187,36 @@ static unsigned int ipv6_conntrack_local(void *priv,
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 	{
 		.hook		= ipv6_conntrack_in,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv6_conntrack_local,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv6_helper,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK_HELPER,
 	},
 	{
 		.hook		= ipv6_confirm,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_LAST,
 	},
 	{
 		.hook		= ipv6_helper,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_CONNTRACK_HELPER,
 	},
 	{
 		.hook		= ipv6_confirm,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_LAST-1,
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index a99baf6..b6ddca7 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -84,14 +84,12 @@ static unsigned int ipv6_defrag(void *priv,
 static struct nf_hook_ops ipv6_defrag_ops[] = {
 	{
 		.hook		= ipv6_defrag,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv6_defrag,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 3773154..ce37d20 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1923,7 +1923,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply4,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 2,
@@ -1933,7 +1932,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	 * applied to IPVS. */
 	{
 		.hook		= ip_vs_remote_request4,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_NAT_SRC - 1,
@@ -1941,7 +1939,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_local_reply4,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 1,
@@ -1949,7 +1946,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After mangle, schedule and forward local requests */
 	{
 		.hook		= ip_vs_local_request4,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_NAT_DST + 2,
@@ -1958,7 +1954,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
 	{
 		.hook		= ip_vs_forward_icmp,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
@@ -1966,7 +1961,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply4,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
@@ -1975,7 +1969,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply6,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 2,
@@ -1985,7 +1978,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	 * applied to IPVS. */
 	{
 		.hook		= ip_vs_remote_request6,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_NAT_SRC - 1,
@@ -1993,7 +1985,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* Before ip_vs_in, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_local_reply6,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 1,
@@ -2001,7 +1992,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After mangle, schedule and forward local requests */
 	{
 		.hook		= ip_vs_local_request6,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 2,
@@ -2010,7 +2000,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
 	{
 		.hook		= ip_vs_forward_icmp_v6,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 99,
@@ -2018,7 +2007,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		= ip_vs_reply6,
-		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= 100,
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 634d18e..eef1c50 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -69,8 +69,6 @@ void nf_queue_entry_release_refs(struct nf_queue_entry *entry)
 			dev_put(physdev);
 	}
 #endif
-	/* Drop reference to owner of hook which queued us. */
-	module_put(entry->elem->owner);
 }
 EXPORT_SYMBOL_GPL(nf_queue_entry_release_refs);
 
@@ -79,9 +77,6 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
 {
 	struct nf_hook_state *state = &entry->state;
 
-	if (!try_module_get(entry->elem->owner))
-		return false;
-
 	if (state->in)
 		dev_hold(state->in);
 	if (state->out)
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 4a41eb9..93cc473 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1433,7 +1433,6 @@ static int nf_tables_newchain(struct sock *nlsk, struct sk_buff *skb,
 		for (i = 0; i < afi->nops; i++) {
 			ops = &basechain->ops[i];
 			ops->pf		= family;
-			ops->owner	= afi->owner;
 			ops->hooknum	= hooknum;
 			ops->priority	= priority;
 			ops->priv	= chain;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 9b42b5e..d4aaad7 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1193,7 +1193,6 @@ struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
 		if (!(hook_mask & 1))
 			continue;
 		ops[i].hook     = fn;
-		ops[i].owner    = table->me;
 		ops[i].pf       = table->af;
 		ops[i].hooknum  = hooknum;
 		ops[i].priority = table->priority;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 6434016..659bb50 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6127,21 +6127,18 @@ security_initcall(selinux_init);
 static struct nf_hook_ops selinux_nf_ops[] = {
 	{
 		.hook =		selinux_ipv4_postroute,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_POST_ROUTING,
 		.priority =	NF_IP_PRI_SELINUX_LAST,
 	},
 	{
 		.hook =		selinux_ipv4_forward,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
 	},
 	{
 		.hook =		selinux_ipv4_output,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_LOCAL_OUT,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
@@ -6149,14 +6146,12 @@ static struct nf_hook_ops selinux_nf_ops[] = {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	{
 		.hook =		selinux_ipv6_postroute,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_POST_ROUTING,
 		.priority =	NF_IP6_PRI_SELINUX_LAST,
 	},
 	{
 		.hook =		selinux_ipv6_forward,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_FORWARD,
 		.priority =	NF_IP6_PRI_SELINUX_FIRST,
diff --git a/security/smack/smack_netfilter.c b/security/smack/smack_netfilter.c
index a9e41da..6d1706c 100644
--- a/security/smack/smack_netfilter.c
+++ b/security/smack/smack_netfilter.c
@@ -57,7 +57,6 @@ static unsigned int smack_ipv4_output(void *priv,
 static struct nf_hook_ops smack_nf_ops[] = {
 	{
 		.hook =		smack_ipv4_output,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV4,
 		.hooknum =	NF_INET_LOCAL_OUT,
 		.priority =	NF_IP_PRI_SELINUX_FIRST,
@@ -65,7 +64,6 @@ static struct nf_hook_ops smack_nf_ops[] = {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	{
 		.hook =		smack_ipv6_output,
-		.owner =	THIS_MODULE,
 		.pf =		NFPROTO_IPV6,
 		.hooknum =	NF_INET_LOCAL_OUT,
 		.priority =	NF_IP6_PRI_SELINUX_FIRST,
-- 
2.1.4
