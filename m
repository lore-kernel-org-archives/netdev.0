From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/53] netfilter: synproxy: only register hooks when needed
Date: Mon,  1 May 2017 12:47:03 +0200
Message-ID: <1493635640-24325-37-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49784 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378977AbdEAKsv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:51 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id DEF6621057D
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D0378FF2DB
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 407E1FF2D1
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:56 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Defer registration of the synproxy hooks until the first SYNPROXY rule is
added.  Also means we only register hooks in namespaces that need it.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_synproxy.h |  2 +
 net/ipv4/netfilter/ipt_SYNPROXY.c             | 73 ++++++++++++++-------------
 net/ipv6/netfilter/ip6t_SYNPROXY.c            | 73 ++++++++++++++-------------
 3 files changed, 80 insertions(+), 68 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_synproxy.h b/include/net/netfilter/nf_conntrack_synproxy.h
index b0ca402c1f72..a2fcb5271726 100644
--- a/include/net/netfilter/nf_conntrack_synproxy.h
+++ b/include/net/netfilter/nf_conntrack_synproxy.h
@@ -52,6 +52,8 @@ struct synproxy_stats {
 struct synproxy_net {
 	struct nf_conn			*tmpl;
 	struct synproxy_stats __percpu	*stats;
+	unsigned int			hook_ref4;
+	unsigned int			hook_ref6;
 };
 
 extern unsigned int synproxy_net_id;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 3240a2614e82..c308ee0ee0bc 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -409,19 +409,56 @@ static unsigned int ipv4_synproxy_hook(void *priv,
 	return NF_ACCEPT;
 }
 
+static struct nf_hook_ops ipv4_synproxy_ops[] __read_mostly = {
+	{
+		.hook		= ipv4_synproxy_hook,
+		.pf		= NFPROTO_IPV4,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
+	{
+		.hook		= ipv4_synproxy_hook,
+		.pf		= NFPROTO_IPV4,
+		.hooknum	= NF_INET_POST_ROUTING,
+		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
+};
+
 static int synproxy_tg4_check(const struct xt_tgchk_param *par)
 {
+	struct synproxy_net *snet = synproxy_pernet(par->net);
 	const struct ipt_entry *e = par->entryinfo;
+	int err;
 
 	if (e->ip.proto != IPPROTO_TCP ||
 	    e->ip.invflags & XT_INV_PROTO)
 		return -EINVAL;
 
-	return nf_ct_netns_get(par->net, par->family);
+	err = nf_ct_netns_get(par->net, par->family);
+	if (err)
+		return err;
+
+	if (snet->hook_ref4 == 0) {
+		err = nf_register_net_hooks(par->net, ipv4_synproxy_ops,
+					    ARRAY_SIZE(ipv4_synproxy_ops));
+		if (err) {
+			nf_ct_netns_put(par->net, par->family);
+			return err;
+		}
+	}
+
+	snet->hook_ref4++;
+	return err;
 }
 
 static void synproxy_tg4_destroy(const struct xt_tgdtor_param *par)
 {
+	struct synproxy_net *snet = synproxy_pernet(par->net);
+
+	snet->hook_ref4--;
+	if (snet->hook_ref4 == 0)
+		nf_unregister_net_hooks(par->net, ipv4_synproxy_ops,
+					ARRAY_SIZE(ipv4_synproxy_ops));
 	nf_ct_netns_put(par->net, par->family);
 }
 
@@ -436,46 +473,14 @@ static struct xt_target synproxy_tg4_reg __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static struct nf_hook_ops ipv4_synproxy_ops[] __read_mostly = {
-	{
-		.hook		= ipv4_synproxy_hook,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
-	},
-	{
-		.hook		= ipv4_synproxy_hook,
-		.pf		= NFPROTO_IPV4,
-		.hooknum	= NF_INET_POST_ROUTING,
-		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
-	},
-};
-
 static int __init synproxy_tg4_init(void)
 {
-	int err;
-
-	err = nf_register_hooks(ipv4_synproxy_ops,
-				ARRAY_SIZE(ipv4_synproxy_ops));
-	if (err < 0)
-		goto err1;
-
-	err = xt_register_target(&synproxy_tg4_reg);
-	if (err < 0)
-		goto err2;
-
-	return 0;
-
-err2:
-	nf_unregister_hooks(ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
-err1:
-	return err;
+	return xt_register_target(&synproxy_tg4_reg);
 }
 
 static void __exit synproxy_tg4_exit(void)
 {
 	xt_unregister_target(&synproxy_tg4_reg);
-	nf_unregister_hooks(ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
 }
 
 module_init(synproxy_tg4_init);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 4ef1ddd4bbbd..1252537f215f 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -430,20 +430,57 @@ static unsigned int ipv6_synproxy_hook(void *priv,
 	return NF_ACCEPT;
 }
 
+static struct nf_hook_ops ipv6_synproxy_ops[] __read_mostly = {
+	{
+		.hook		= ipv6_synproxy_hook,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
+	{
+		.hook		= ipv6_synproxy_hook,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_POST_ROUTING,
+		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
+	},
+};
+
 static int synproxy_tg6_check(const struct xt_tgchk_param *par)
 {
+	struct synproxy_net *snet = synproxy_pernet(par->net);
 	const struct ip6t_entry *e = par->entryinfo;
+	int err;
 
 	if (!(e->ipv6.flags & IP6T_F_PROTO) ||
 	    e->ipv6.proto != IPPROTO_TCP ||
 	    e->ipv6.invflags & XT_INV_PROTO)
 		return -EINVAL;
 
-	return nf_ct_netns_get(par->net, par->family);
+	err = nf_ct_netns_get(par->net, par->family);
+	if (err)
+		return err;
+
+	if (snet->hook_ref6 == 0) {
+		err = nf_register_net_hooks(par->net, ipv6_synproxy_ops,
+					    ARRAY_SIZE(ipv6_synproxy_ops));
+		if (err) {
+			nf_ct_netns_put(par->net, par->family);
+			return err;
+		}
+	}
+
+	snet->hook_ref6++;
+	return err;
 }
 
 static void synproxy_tg6_destroy(const struct xt_tgdtor_param *par)
 {
+	struct synproxy_net *snet = synproxy_pernet(par->net);
+
+	snet->hook_ref6--;
+	if (snet->hook_ref6 == 0)
+		nf_unregister_net_hooks(par->net, ipv6_synproxy_ops,
+					ARRAY_SIZE(ipv6_synproxy_ops));
 	nf_ct_netns_put(par->net, par->family);
 }
 
@@ -458,46 +495,14 @@ static struct xt_target synproxy_tg6_reg __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static struct nf_hook_ops ipv6_synproxy_ops[] __read_mostly = {
-	{
-		.hook		= ipv6_synproxy_hook,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_LOCAL_IN,
-		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
-	},
-	{
-		.hook		= ipv6_synproxy_hook,
-		.pf		= NFPROTO_IPV6,
-		.hooknum	= NF_INET_POST_ROUTING,
-		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM - 1,
-	},
-};
-
 static int __init synproxy_tg6_init(void)
 {
-	int err;
-
-	err = nf_register_hooks(ipv6_synproxy_ops,
-				ARRAY_SIZE(ipv6_synproxy_ops));
-	if (err < 0)
-		goto err1;
-
-	err = xt_register_target(&synproxy_tg6_reg);
-	if (err < 0)
-		goto err2;
-
-	return 0;
-
-err2:
-	nf_unregister_hooks(ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
-err1:
-	return err;
+	return xt_register_target(&synproxy_tg6_reg);
 }
 
 static void __exit synproxy_tg6_exit(void)
 {
 	xt_unregister_target(&synproxy_tg6_reg);
-	nf_unregister_hooks(ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
 }
 
 module_init(synproxy_tg6_init);
-- 
2.1.4
