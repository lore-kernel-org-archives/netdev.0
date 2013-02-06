From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH ipsec-next v2 2/2] xfrm: make gc_thresh configurable in all
 namespaces
Date: Wed,  6 Feb 2013 10:46:33 +0100 (CET)
Message-ID: <d0fc69e42ced38060bd38b10538486e015b051d4.1360143430.git.mkubecek@suse.cz>
References: <cover.1360143430.git.mkubecek@suse.cz>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58516 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291Ab3BFJqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 04:46:35 -0500
In-Reply-To: <cover.1360143430.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xfrm gc threshold can be configured via xfrm{4,6}_gc_thresh
sysctl but currently only in init_net, other namespaces always
use the default value. This can substantially limit the number
of IPsec tunnels that can be effectively used.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/netns/ipv4.h |    1 +
 include/net/netns/ipv6.h |    1 +
 net/ipv4/xfrm4_policy.c  |   49 ++++++++++++++++++++++++++++++++++++++++---
 net/ipv6/xfrm6_policy.c  |   52 +++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 95 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 9b78862..2ba9de8 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -22,6 +22,7 @@ struct netns_ipv4 {
 	struct ctl_table_header	*frags_hdr;
 	struct ctl_table_header	*ipv4_hdr;
 	struct ctl_table_header *route_hdr;
+	struct ctl_table_header *xfrm4_hdr;
 #endif
 	struct ipv4_devconf	*devconf_all;
 	struct ipv4_devconf	*devconf_dflt;
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 214cb0a..1242f37 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -16,6 +16,7 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *route_hdr;
 	struct ctl_table_header *icmp_hdr;
 	struct ctl_table_header *frags_hdr;
+	struct ctl_table_header *xfrm6_hdr;
 #endif
 	int bindv6only;
 	int flush_delay;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 0e28383..9a459be 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -262,7 +262,51 @@ static struct ctl_table xfrm4_policy_table[] = {
 	{ }
 };
 
-static struct ctl_table_header *sysctl_hdr;
+static int __net_init xfrm4_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	struct ctl_table_header *hdr;
+
+	table = xfrm4_policy_table;
+	if (!net_eq(net, &init_net)) {
+		table = kmemdup(table, sizeof(xfrm4_policy_table), GFP_KERNEL);
+		if (!table)
+			goto err_alloc;
+
+		table[0].data = &net->xfrm.xfrm4_dst_ops.gc_thresh;
+	}
+
+	hdr = register_net_sysctl(net, "net/ipv4", table);
+	if (!hdr)
+		goto err_reg;
+
+	net->ipv4.xfrm4_hdr = hdr;
+	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(table);
+err_alloc:
+	return -ENOMEM;
+}
+
+static void __net_exit xfrm4_net_exit(struct net *net)
+{
+	struct ctl_table *table;
+
+	if (net->ipv4.xfrm4_hdr == NULL)
+		return;
+
+	table = net->ipv4.xfrm4_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(net->ipv4.xfrm4_hdr);
+	if (!net_eq(net, &init_net))
+		kfree(table);
+}
+
+static struct pernet_operations __net_initdata xfrm4_net_ops = {
+	.init	= xfrm4_net_init,
+	.exit	= xfrm4_net_exit,
+};
 #endif
 
 static void __init xfrm4_policy_init(void)
@@ -277,8 +321,7 @@ void __init xfrm4_init(void)
 	xfrm4_state_init();
 	xfrm4_policy_init();
 #ifdef CONFIG_SYSCTL
-	sysctl_hdr = register_net_sysctl(&init_net, "net/ipv4",
-					 xfrm4_policy_table);
+	register_pernet_subsys(&xfrm4_net_ops);
 #endif
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 1282737..4ef7bdb 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -320,7 +320,51 @@ static struct ctl_table xfrm6_policy_table[] = {
 	{ }
 };
 
-static struct ctl_table_header *sysctl_hdr;
+static int __net_init xfrm6_net_init(struct net *net)
+{
+	struct ctl_table *table;
+	struct ctl_table_header *hdr;
+
+	table = xfrm6_policy_table;
+	if (!net_eq(net, &init_net)) {
+		table = kmemdup(table, sizeof(xfrm6_policy_table), GFP_KERNEL);
+		if (!table)
+			goto err_alloc;
+
+		table[0].data = &net->xfrm.xfrm6_dst_ops.gc_thresh;
+	}
+
+	hdr = register_net_sysctl(net, "net/ipv6", table);
+	if (!hdr)
+		goto err_reg;
+
+	net->ipv6.sysctl.xfrm6_hdr = hdr;
+	return 0;
+
+err_reg:
+	if (!net_eq(net, &init_net))
+		kfree(table);
+err_alloc:
+	return -ENOMEM;
+}
+
+static void __net_exit xfrm6_net_exit(struct net *net)
+{
+	struct ctl_table *table;
+
+	if (net->ipv6.sysctl.xfrm6_hdr == NULL)
+		return;
+
+	table = net->ipv6.sysctl.xfrm6_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(net->ipv6.sysctl.xfrm6_hdr);
+	if (!net_eq(net, &init_net))
+		kfree(table);
+}
+
+static struct pernet_operations xfrm6_net_ops = {
+	.init	= xfrm6_net_init,
+	.exit	= xfrm6_net_exit,
+};
 #endif
 
 int __init xfrm6_init(void)
@@ -339,8 +383,7 @@ int __init xfrm6_init(void)
 		goto out_policy;
 
 #ifdef CONFIG_SYSCTL
-	sysctl_hdr = register_net_sysctl(&init_net, "net/ipv6",
-					 xfrm6_policy_table);
+	register_pernet_subsys(&xfrm6_net_ops);
 #endif
 out:
 	return ret;
@@ -352,8 +395,7 @@ out_policy:
 void xfrm6_fini(void)
 {
 #ifdef CONFIG_SYSCTL
-	if (sysctl_hdr)
-		unregister_net_sysctl_table(sysctl_hdr);
+	unregister_pernet_subsys(&xfrm6_net_ops);
 #endif
 	xfrm6_policy_fini();
 	xfrm6_state_fini();
-- 
1.7.10.4
