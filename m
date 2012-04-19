From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 04/19] net: Kill register_sysctl_rotable
Date: Thu, 19 Apr 2012 16:22:55 -0700
Message-ID: <m1obqngvcg.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55410 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab2DSXSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:18:55 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


register_sysctl_rotable never caught on as an interesting way to
register sysctls.  My take on the situation is that what we want are
sysctls that we can only see in the initial network namespace.  What we
have implemented with register_sysctl_rotable are sysctls that we can
see in all of the network namespaces and can only change in the initial
network namespace.

That is a very silly way to go.  Just register the network sysctls
in the initial network namespace and we don't have any weird special
cases to deal with.

The sysctls affected are:
/proc/sys/net/ipv4/ipfrag_secret_interval
/proc/sys/net/ipv4/ipfrag_max_dist
/proc/sys/net/ipv6/ip6frag_secret_interval
/proc/sys/net/ipv6/mld_max_msf

I really don't expect anyone will miss them if they can't read them in a
child user namespace.

CC: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    2 --
 net/core/sysctl_net_core.c  |    2 +-
 net/ipv4/ip_fragment.c      |    2 +-
 net/ipv6/reassembly.c       |    2 +-
 net/ipv6/sysctl_net_ipv6.c  |    2 +-
 net/sysctl_net.c            |   23 -----------------------
 6 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 767dcd40..6413fcb 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -290,8 +290,6 @@ static inline int net_sysctl_init(void) { return 0; }
 #endif
 extern struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table);
-extern struct ctl_table_header *register_net_sysctl_rotable(
-	const struct ctl_path *path, struct ctl_table *table);
 extern struct ctl_table_header *register_net_sysctl(struct net *net,
 	const char *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cee5991..9504086 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -257,7 +257,7 @@ static __init int sysctl_core_init(void)
 	static struct ctl_table empty[1];
 
 	kmemleak_not_leak(register_sysctl_paths(net_core_path, empty));
-	register_net_sysctl_rotable(net_core_path, net_core_table);
+	register_net_sysctl(&init_net, "net/core", net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 3727e23..a746cca 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -807,7 +807,7 @@ static void __net_exit ip4_frags_ns_ctl_unregister(struct net *net)
 
 static void ip4_frags_ctl_register(void)
 {
-	register_net_sysctl_rotable(net_ipv4_ctl_path, ip4_frags_ctl_table);
+	register_net_sysctl(&init_net, "net/ipv4", ip4_frags_ctl_table);
 }
 #else
 static inline int ip4_frags_ns_ctl_register(struct net *net)
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 9447bd6..42f4f7c 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -674,7 +674,7 @@ static struct ctl_table_header *ip6_ctl_header;
 
 static int ip6_frags_sysctl_register(void)
 {
-	ip6_ctl_header = register_net_sysctl_rotable(net_ipv6_ctl_path,
+	ip6_ctl_header = register_net_sysctl(&init_net, "net/ipv6",
 			ip6_frags_ctl_table);
 	return ip6_ctl_header == NULL ? -ENOMEM : 0;
 }
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 166a57c..06f21e5 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -140,7 +140,7 @@ int ipv6_sysctl_register(void)
 {
 	int err = -ENOMEM;
 
-	ip6_header = register_net_sysctl_rotable(net_ipv6_ctl_path, ipv6_rotable);
+	ip6_header = register_net_sysctl(&init_net, "net/ipv6", ipv6_rotable);
 	if (ip6_header == NULL)
 		goto out;
 
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index ce97237..2b8d1d9 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -59,19 +59,6 @@ static struct ctl_table_root net_sysctl_root = {
 	.permissions = net_ctl_permissions,
 };
 
-static int net_ctl_ro_header_perms(struct ctl_table_root *root,
-		struct nsproxy *namespaces, struct ctl_table *table)
-{
-	if (net_eq(namespaces->net_ns, &init_net))
-		return table->mode;
-	else
-		return table->mode & ~0222;
-}
-
-static struct ctl_table_root net_sysctl_ro_root = {
-	.permissions = net_ctl_ro_header_perms,
-};
-
 static int __net_init sysctl_net_init(struct net *net)
 {
 	setup_sysctl_set(&net->sysctls, &net_sysctl_root, is_seen);
@@ -103,8 +90,6 @@ __init int net_sysctl_init(void)
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
 	if (ret)
 		goto out;
-	setup_sysctl_set(&net_sysctl_ro_root.default_set, &net_sysctl_ro_root, NULL);
-	register_sysctl_root(&net_sysctl_ro_root);
 	register_sysctl_root(&net_sysctl_root);
 out:
 	return ret;
@@ -117,14 +102,6 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
-struct ctl_table_header *register_net_sysctl_rotable(const
-		struct ctl_path *path, struct ctl_table *table)
-{
-	return __register_sysctl_paths(&net_sysctl_ro_root.default_set,
-					path, table);
-}
-EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
-
 struct ctl_table_header *register_net_sysctl(struct net *net,
 	const char *path, struct ctl_table *table)
 {
-- 
1.7.2.5
