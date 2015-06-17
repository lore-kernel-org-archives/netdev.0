From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 28/43] x_tables: Where possible convert to the new hook registration method
Date: Wed, 17 Jun 2015 10:28:37 -0500
Message-ID: <1434554932-4552-28-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39766 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbbFQPiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:23 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/netfilter/arptable_filter.c   | 22 +++-------------------
 net/ipv4/netfilter/iptable_filter.c    | 20 +++-----------------
 net/ipv4/netfilter/iptable_mangle.c    | 20 +++-----------------
 net/ipv4/netfilter/iptable_raw.c       | 20 +++-----------------
 net/ipv4/netfilter/iptable_security.c  | 23 +++--------------------
 net/ipv6/netfilter/ip6table_filter.c   | 24 +++---------------------
 net/ipv6/netfilter/ip6table_mangle.c   | 23 +++--------------------
 net/ipv6/netfilter/ip6table_raw.c      | 24 +++---------------------
 net/ipv6/netfilter/ip6table_security.c | 23 +++--------------------
 9 files changed, 27 insertions(+), 172 deletions(-)

diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 40fd714dafd1..90c70cf0cd5d 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -17,12 +17,14 @@ MODULE_DESCRIPTION("arptables filter table");
 #define FILTER_VALID_HOOKS ((1 << NF_ARP_IN) | (1 << NF_ARP_OUT) | \
 			   (1 << NF_ARP_FORWARD))
 
+static xt_hookfn arptable_filter_hook;
 static const struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_ARP,
 	.priority	= NF_IP_PRI_FILTER,
+	.fn		= arptable_filter_hook,
 };
 
 /* The work comes in here from netfilter.c */
@@ -33,8 +35,6 @@ arptable_filter_hook(void *priv, struct sk_buff *skb,
 	return arpt_do_table(skb, state, state->net->ipv4.arptable_filter);
 }
 
-static struct nf_hook_ops *arpfilter_ops __read_mostly;
-
 static int __net_init arptable_filter_net_init(struct net *net)
 {
 	struct arpt_replace *repl;
@@ -60,27 +60,11 @@ static struct pernet_operations arptable_filter_net_ops = {
 
 static int __init arptable_filter_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&arptable_filter_net_ops);
-	if (ret < 0)
-		return ret;
-
-	arpfilter_ops = xt_hook_link(&packet_filter, arptable_filter_hook);
-	if (IS_ERR(arpfilter_ops)) {
-		ret = PTR_ERR(arpfilter_ops);
-		goto cleanup_table;
-	}
-	return ret;
-
-cleanup_table:
-	unregister_pernet_subsys(&arptable_filter_net_ops);
-	return ret;
+	return register_pernet_subsys(&arptable_filter_net_ops);
 }
 
 static void __exit arptable_filter_fini(void)
 {
-	xt_hook_unlink(&packet_filter, arpfilter_ops);
 	unregister_pernet_subsys(&arptable_filter_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 397ef2dd133e..535e3f61a18c 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -24,12 +24,14 @@ MODULE_DESCRIPTION("iptables filter table");
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
 
+static xt_hookfn iptable_filter_hook;
 static const struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV4,
 	.priority	= NF_IP_PRI_FILTER,
+	.fn		= iptable_filter_hook,
 };
 
 static unsigned int
@@ -45,8 +47,6 @@ iptable_filter_hook(void *priv, struct sk_buff *skb,
 	return ipt_do_table(skb, state, state->net->ipv4.iptable_filter);
 }
 
-static struct nf_hook_ops *filter_ops __read_mostly;
-
 /* Default to forward because I got too much mail already. */
 static bool forward = true;
 module_param(forward, bool, 0000);
@@ -80,25 +80,11 @@ static struct pernet_operations iptable_filter_net_ops = {
 
 static int __init iptable_filter_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&iptable_filter_net_ops);
-	if (ret < 0)
-		return ret;
-
-	/* Register hooks */
-	filter_ops = xt_hook_link(&packet_filter, iptable_filter_hook);
-	if (IS_ERR(filter_ops)) {
-		ret = PTR_ERR(filter_ops);
-		unregister_pernet_subsys(&iptable_filter_net_ops);
-	}
-
-	return ret;
+	return register_pernet_subsys(&iptable_filter_net_ops);
 }
 
 static void __exit iptable_filter_fini(void)
 {
-	xt_hook_unlink(&packet_filter, filter_ops);
 	unregister_pernet_subsys(&iptable_filter_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 2d6fc911866f..e88f0fb23bd8 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -28,12 +28,14 @@ MODULE_DESCRIPTION("iptables mangle table");
 			    (1 << NF_INET_LOCAL_OUT) | \
 			    (1 << NF_INET_POST_ROUTING))
 
+static xt_hookfn iptable_mangle_hook;
 static const struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV4,
 	.priority	= NF_IP_PRI_MANGLE,
+	.fn		= iptable_mangle_hook,
 };
 
 static unsigned int
@@ -91,8 +93,6 @@ iptable_mangle_hook(void *priv,
 	return ipt_do_table(skb, state, state->net->ipv4.iptable_mangle);
 }
 
-static struct nf_hook_ops *mangle_ops __read_mostly;
-
 static int __net_init iptable_mangle_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
@@ -118,25 +118,11 @@ static struct pernet_operations iptable_mangle_net_ops = {
 
 static int __init iptable_mangle_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&iptable_mangle_net_ops);
-	if (ret < 0)
-		return ret;
-
-	/* Register hooks */
-	mangle_ops = xt_hook_link(&packet_mangler, iptable_mangle_hook);
-	if (IS_ERR(mangle_ops)) {
-		ret = PTR_ERR(mangle_ops);
-		unregister_pernet_subsys(&iptable_mangle_net_ops);
-	}
-
-	return ret;
+	return register_pernet_subsys(&iptable_mangle_net_ops);
 }
 
 static void __exit iptable_mangle_fini(void)
 {
-	xt_hook_unlink(&packet_mangler, mangle_ops);
 	unregister_pernet_subsys(&iptable_mangle_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 1ba02811acb0..bb740ae812e3 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -10,12 +10,14 @@
 
 #define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
+static xt_hookfn iptable_raw_hook;
 static const struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks =  RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
 	.af = NFPROTO_IPV4,
 	.priority = NF_IP_PRI_RAW,
+	.fn = iptable_raw_hook,
 };
 
 /* The work comes in here from netfilter.c. */
@@ -32,8 +34,6 @@ iptable_raw_hook(void *priv, struct sk_buff *skb,
 	return ipt_do_table(skb, state, state->net->ipv4.iptable_raw);
 }
 
-static struct nf_hook_ops *rawtable_ops __read_mostly;
-
 static int __net_init iptable_raw_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
@@ -59,25 +59,11 @@ static struct pernet_operations iptable_raw_net_ops = {
 
 static int __init iptable_raw_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&iptable_raw_net_ops);
-	if (ret < 0)
-		return ret;
-
-	/* Register hooks */
-	rawtable_ops = xt_hook_link(&packet_raw, iptable_raw_hook);
-	if (IS_ERR(rawtable_ops)) {
-		ret = PTR_ERR(rawtable_ops);
-		unregister_pernet_subsys(&iptable_raw_net_ops);
-	}
-
-	return ret;
+	return register_pernet_subsys(&iptable_raw_net_ops);
 }
 
 static void __exit iptable_raw_fini(void)
 {
-	xt_hook_unlink(&packet_raw, rawtable_ops);
 	unregister_pernet_subsys(&iptable_raw_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index f534e2f05bad..9a16b8343673 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -28,12 +28,14 @@ MODULE_DESCRIPTION("iptables security table, for MAC rules");
 				(1 << NF_INET_FORWARD) | \
 				(1 << NF_INET_LOCAL_OUT)
 
+static xt_hookfn iptable_security_hook;
 static const struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV4,
 	.priority	= NF_IP_PRI_SECURITY,
+	.fn		= iptable_security_hook,
 };
 
 static unsigned int
@@ -49,8 +51,6 @@ iptable_security_hook(void *priv, struct sk_buff *skb,
 	return ipt_do_table(skb, state, state->net->ipv4.iptable_security);
 }
 
-static struct nf_hook_ops *sectbl_ops __read_mostly;
-
 static int __net_init iptable_security_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
@@ -76,28 +76,11 @@ static struct pernet_operations iptable_security_net_ops = {
 
 static int __init iptable_security_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&iptable_security_net_ops);
-        if (ret < 0)
-		return ret;
-
-	sectbl_ops = xt_hook_link(&security_table, iptable_security_hook);
-	if (IS_ERR(sectbl_ops)) {
-		ret = PTR_ERR(sectbl_ops);
-		goto cleanup_table;
-	}
-
-	return ret;
-
-cleanup_table:
-	unregister_pernet_subsys(&iptable_security_net_ops);
-	return ret;
+	return register_pernet_subsys(&iptable_security_net_ops);
 }
 
 static void __exit iptable_security_fini(void)
 {
-	xt_hook_unlink(&security_table, sectbl_ops);
 	unregister_pernet_subsys(&iptable_security_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 8b277b983ca5..8b30c57aba79 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -22,12 +22,14 @@ MODULE_DESCRIPTION("ip6tables filter table");
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
 
+static xt_hookfn ip6table_filter_hook;
 static const struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV6,
 	.priority	= NF_IP6_PRI_FILTER,
+	.fn		= ip6table_filter_hook,
 };
 
 /* The work comes in here from netfilter.c. */
@@ -38,8 +40,6 @@ ip6table_filter_hook(void *priv, struct sk_buff *skb,
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_filter);
 }
 
-static struct nf_hook_ops *filter_ops __read_mostly;
-
 /* Default to forward because I got too much mail already. */
 static bool forward = true;
 module_param(forward, bool, 0000);
@@ -73,29 +73,11 @@ static struct pernet_operations ip6table_filter_net_ops = {
 
 static int __init ip6table_filter_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&ip6table_filter_net_ops);
-	if (ret < 0)
-		return ret;
-
-	/* Register hooks */
-	filter_ops = xt_hook_link(&packet_filter, ip6table_filter_hook);
-	if (IS_ERR(filter_ops)) {
-		ret = PTR_ERR(filter_ops);
-		goto cleanup_table;
-	}
-
-	return ret;
-
- cleanup_table:
-	unregister_pernet_subsys(&ip6table_filter_net_ops);
-	return ret;
+	return register_pernet_subsys(&ip6table_filter_net_ops);
 }
 
 static void __exit ip6table_filter_fini(void)
 {
-	xt_hook_unlink(&packet_filter, filter_ops);
 	unregister_pernet_subsys(&ip6table_filter_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 8745b592b2f6..70304903d36d 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -23,12 +23,14 @@ MODULE_DESCRIPTION("ip6tables mangle table");
 			    (1 << NF_INET_LOCAL_OUT) | \
 			    (1 << NF_INET_POST_ROUTING))
 
+static xt_hookfn ip6table_mangle_hook;
 static const struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV6,
 	.priority	= NF_IP6_PRI_MANGLE,
+	.fn		= ip6table_mangle_hook,
 };
 
 static unsigned int
@@ -87,7 +89,6 @@ ip6table_mangle_hook(void *priv, struct sk_buff *skb,
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_mangle);
 }
 
-static struct nf_hook_ops *mangle_ops __read_mostly;
 static int __net_init ip6table_mangle_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
@@ -113,29 +114,11 @@ static struct pernet_operations ip6table_mangle_net_ops = {
 
 static int __init ip6table_mangle_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&ip6table_mangle_net_ops);
-	if (ret < 0)
-		return ret;
-
-	/* Register hooks */
-	mangle_ops = xt_hook_link(&packet_mangler, ip6table_mangle_hook);
-	if (IS_ERR(mangle_ops)) {
-		ret = PTR_ERR(mangle_ops);
-		goto cleanup_table;
-	}
-
-	return ret;
-
- cleanup_table:
-	unregister_pernet_subsys(&ip6table_mangle_net_ops);
-	return ret;
+	return register_pernet_subsys(&ip6table_mangle_net_ops);
 }
 
 static void __exit ip6table_mangle_fini(void)
 {
-	xt_hook_unlink(&packet_mangler, mangle_ops);
 	unregister_pernet_subsys(&ip6table_mangle_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 9021963565c3..87f65c3ca32f 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -9,12 +9,14 @@
 
 #define RAW_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT))
 
+static xt_hookfn ip6table_raw_hook;
 static const struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks = RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
 	.af = NFPROTO_IPV6,
 	.priority = NF_IP6_PRI_RAW,
+	.fn = ip6table_raw_hook,
 };
 
 /* The work comes in here from netfilter.c. */
@@ -25,8 +27,6 @@ ip6table_raw_hook(void *priv, struct sk_buff *skb,
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_raw);
 }
 
-static struct nf_hook_ops *rawtable_ops __read_mostly;
-
 static int __net_init ip6table_raw_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
@@ -52,29 +52,11 @@ static struct pernet_operations ip6table_raw_net_ops = {
 
 static int __init ip6table_raw_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&ip6table_raw_net_ops);
-	if (ret < 0)
-		return ret;
-
-	/* Register hooks */
-	rawtable_ops = xt_hook_link(&packet_raw, ip6table_raw_hook);
-	if (IS_ERR(rawtable_ops)) {
-		ret = PTR_ERR(rawtable_ops);
-		goto cleanup_table;
-	}
-
-	return ret;
-
- cleanup_table:
-	unregister_pernet_subsys(&ip6table_raw_net_ops);
-	return ret;
+	return register_pernet_subsys(&ip6table_raw_net_ops);
 }
 
 static void __exit ip6table_raw_fini(void)
 {
-	xt_hook_unlink(&packet_raw, rawtable_ops);
 	unregister_pernet_subsys(&ip6table_raw_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 0d856fedfeb0..c58f046f4ee9 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -27,12 +27,14 @@ MODULE_DESCRIPTION("ip6tables security table, for MAC rules");
 				(1 << NF_INET_FORWARD) | \
 				(1 << NF_INET_LOCAL_OUT)
 
+static xt_hookfn ip6table_security_hook;
 static const struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
 	.me		= THIS_MODULE,
 	.af		= NFPROTO_IPV6,
 	.priority	= NF_IP6_PRI_SECURITY,
+	.fn		= ip6table_security_hook,
 };
 
 static unsigned int
@@ -42,8 +44,6 @@ ip6table_security_hook(void *priv, struct sk_buff *skb,
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_security);
 }
 
-static struct nf_hook_ops *sectbl_ops __read_mostly;
-
 static int __net_init ip6table_security_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
@@ -69,28 +69,11 @@ static struct pernet_operations ip6table_security_net_ops = {
 
 static int __init ip6table_security_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&ip6table_security_net_ops);
-	if (ret < 0)
-		return ret;
-
-	sectbl_ops = xt_hook_link(&security_table, ip6table_security_hook);
-	if (IS_ERR(sectbl_ops)) {
-		ret = PTR_ERR(sectbl_ops);
-		goto cleanup_table;
-	}
-
-	return ret;
-
-cleanup_table:
-	unregister_pernet_subsys(&ip6table_security_net_ops);
-	return ret;
+	return register_pernet_subsys(&ip6table_security_net_ops);
 }
 
 static void __exit ip6table_security_fini(void)
 {
-	xt_hook_unlink(&security_table, sectbl_ops);
 	unregister_pernet_subsys(&ip6table_security_net_ops);
 }
 
-- 
2.2.1
