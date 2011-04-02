From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 23/24] sysctl: ipv6: register /proc/sys/net/ipv6/neigh empty directory
Date: Sat,  2 Apr 2011 04:53:37 +0200
Message-ID: <0214c88749a0518824f76fdec2c39d1e872329ae.1301711868.git.lucian.grijincu__27162.468530196$1301712984$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756392Ab1DBCzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:55:05 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the previous patch. This patch also changes the moment
/proc/sys/net/ipv6/neigh/default is registered:

- before this patch: the 'default' was registered directly in ndisc_init()

- with this patch: 'default' is registered after the empty
  /proc/sys/net/ipv6/neigh/ directly which is created for each network
  namespace as a pernet operation. Because of this the neigh_tables
  have to be initialised (neigh_table_init) before registering pernet
  ops and cleaned up after unregistering them.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/ipv6.h         |    2 -
 include/net/netns/ipv6.h   |    1 +
 net/ipv6/af_inet6.c        |   12 -------
 net/ipv6/ndisc.c           |   76 ++++++++++++++++++++++++++++++++++----------
 net/ipv6/sysctl_net_ipv6.c |   27 ---------------
 5 files changed, 60 insertions(+), 58 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index bd73439..5e535b3 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -661,8 +661,6 @@ extern ctl_table ipv6_icmp_table[];
 
 extern int ipv6_sysctl_register(void);
 extern void ipv6_sysctl_unregister(void);
-extern int ipv6_static_sysctl_register(void);
-extern void ipv6_static_sysctl_unregister(void);
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index b3c3cd7..58b542f 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -15,6 +15,7 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *table;
 	struct ctl_table_header *frags_hdr;  /* /proc/sys/net/ipv6/ip6frag_*  */
 	struct ctl_table_header *conf_hdr;   /* /proc/sys/net/ipv6/conf/      */
+	struct ctl_table_header *neigh_hdr;  /* /proc/sys/net/ipv6/neigh/     */
 #endif
 	int bindv6only;
 	int flush_delay;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 4b13d5d..5f81711 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1105,11 +1105,6 @@ static int __init inet6_init(void)
 	if (err)
 		goto out_sock_register_fail;
 
-#ifdef CONFIG_SYSCTL
-	err = ipv6_static_sysctl_register();
-	if (err)
-		goto static_sysctl_fail;
-#endif
 	/*
 	 *	ipngwg API draft makes clear that the correct semantics
 	 *	for TCP and UDP is to consider one TCP and UDP instance
@@ -1234,10 +1229,6 @@ ipmr_fail:
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
 register_pernet_fail:
-#ifdef CONFIG_SYSCTL
-	ipv6_static_sysctl_unregister();
-static_sysctl_fail:
-#endif
 	sock_unregister(PF_INET6);
 	rtnl_unregister_all(PF_INET6);
 out_sock_register_fail:
@@ -1294,9 +1285,6 @@ static void __exit inet6_exit(void)
 	rawv6_exit();
 
 	unregister_pernet_subsys(&inet6_net_ops);
-#ifdef CONFIG_SYSCTL
-	ipv6_static_sysctl_unregister();
-#endif
 	proto_unregister(&rawv6_prot);
 	proto_unregister(&udplitev6_prot);
 	proto_unregister(&udpv6_prot);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 61ff29b..1cbc3c6 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1790,19 +1790,58 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write,
 
 #endif
 
+
+#ifdef CONFIG_SYSCTL
+
+/* empty entry for '/proc/sys/net/ipv6/neigh/' */
+static __net_initdata struct ctl_table empty[1];
+static __net_initdata struct ctl_table ipv6_neigh_skel[] = {
+	{
+		.procname       = "neigh",
+		.mode           = 0555,
+		.child          = empty,
+	},
+	{ },
+};
+static __net_initdata const struct ctl_path net_ipv6_path[] = {
+	{ .procname = "net", },
+	{ .procname = "ipv6", },
+	{ },
+};
+
+#endif /* CONFIG_SYSCTL */
+
 static int __net_init ndisc_net_init(struct net *net)
 {
 	struct ipv6_pinfo *np;
 	struct sock *sk;
 	int err;
 
+#ifdef CONFIG_SYSCTL
+	err = -ENOMEM;
+	/* register empty dir for /proc/sys/net/ipv6/neigh/ */
+	net->ipv6.sysctl.neigh_hdr = register_net_sysctl_table(net,
+					net_ipv6_path, ipv6_neigh_skel);
+	if (net->ipv6.sysctl.neigh_hdr == NULL)
+		goto register_net_neigh_skel_fail;
+
+	/* register /proc/sys/net/ipv6/neigh/default */
+	if (net_eq(net, &init_net)) {
+		err = neigh_sysctl_register(NULL, &nd_tbl.parms, "ipv6",
+					    &ndisc_ifinfo_sysctl_change);
+		if (err)
+			goto neigh_sysctl_register_fail;
+	}
+#endif /* CONFIG_SYSCTL */
+
+
 	err = inet_ctl_sock_create(&sk, PF_INET6,
 				   SOCK_RAW, IPPROTO_ICMPV6, net);
 	if (err < 0) {
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 NDISC: Failed to initialize the control socket (err %d).\n",
 			   err);
-		return err;
+		goto inet_ctl_sock_create_fail;
 	}
 
 	net->ipv6.ndisc_sk = sk;
@@ -1813,11 +1852,26 @@ static int __net_init ndisc_net_init(struct net *net)
 	np->mc_loop = 0;
 
 	return 0;
+
+inet_ctl_sock_create_fail:
+
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_unregister(&nd_tbl.parms);
+neigh_sysctl_register_fail:
+	unregister_net_sysctl_table(net->ipv6.sysctl.neigh_hdr);
+register_net_neigh_skel_fail:
+#endif /* CONFIG_SYSCTL */
+
+	return err;
 }
 
 static void __net_exit ndisc_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.ndisc_sk);
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_unregister(&nd_tbl.parms);
+	unregister_net_sysctl_table(net->ipv6.sysctl.neigh_hdr);
+#endif /* CONFIG_SYSCTL */
 }
 
 static struct pernet_operations ndisc_net_ops = {
@@ -1829,20 +1883,15 @@ int __init ndisc_init(void)
 {
 	int err;
 
-	err = register_pernet_subsys(&ndisc_net_ops);
-	if (err)
-		return err;
 	/*
 	 * Initialize the neighbour table
 	 */
 	neigh_table_init(&nd_tbl);
 
-#ifdef CONFIG_SYSCTL
-	err = neigh_sysctl_register(NULL, &nd_tbl.parms, "ipv6",
-				    &ndisc_ifinfo_sysctl_change);
+	err = register_pernet_subsys(&ndisc_net_ops);
 	if (err)
-		goto out_unregister_pernet;
-#endif
+		return err;
+
 	err = register_netdevice_notifier(&ndisc_netdev_notifier);
 	if (err)
 		goto out_unregister_sysctl;
@@ -1850,10 +1899,6 @@ out:
 	return err;
 
 out_unregister_sysctl:
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(&nd_tbl.parms);
-out_unregister_pernet:
-#endif
 	unregister_pernet_subsys(&ndisc_net_ops);
 	goto out;
 }
@@ -1861,9 +1906,6 @@ out_unregister_pernet:
 void ndisc_cleanup(void)
 {
 	unregister_netdevice_notifier(&ndisc_netdev_notifier);
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(&nd_tbl.parms);
-#endif
-	neigh_table_clear(&nd_tbl);
 	unregister_pernet_subsys(&ndisc_net_ops);
+	neigh_table_clear(&nd_tbl);
 }
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 1b6f6fd..b55462f 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,18 +15,6 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-static struct ctl_table empty[1];
-
-static ctl_table ipv6_static_skeleton[] = {
-	{
-		.procname	= "neigh",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= empty,
-	},
-	{ }
-};
-
 static ctl_table ipv6_table[] = {
 	{
 		.procname	= "route",
@@ -114,18 +102,3 @@ void ipv6_sysctl_unregister(void)
 	unregister_net_sysctl_table(ip6_header);
 	unregister_pernet_subsys(&ipv6_sysctl_net_ops);
 }
-
-static struct ctl_table_header *ip6_base;
-
-int ipv6_static_sysctl_register(void)
-{
-	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, ipv6_static_skeleton);
-	if (ip6_base == NULL)
-		return -ENOMEM;
-	return 0;
-}
-
-void ipv6_static_sysctl_unregister(void)
-{
-	unregister_net_sysctl_table(ip6_base);
-}
-- 
1.7.5.rc0

