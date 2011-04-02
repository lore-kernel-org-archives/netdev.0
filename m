From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 22/24] sysctl: ipv4: register /proc/sys/net/ipv4/neigh empty directory
Date: Sat,  2 Apr 2011 04:53:36 +0200
Message-ID: <012acbd2c767198bdd88d6bd724b5c8b43997cf7.1301711868.git.lucian.grijincu@gmail.com>
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
	with ESMTP id S1756990Ab1DBCzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:55:02 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As opposed to the patches that added the /proc/sys/net/ipv4/conf and
/proc/sys/net/ipv6/conf empty directories, this patch does include a
change in semantics.

Before this patch /proc/sys/net/ipv4/neigh/default/ was registered
from arp_init() directly.

This patch adds new pernet_operations in which it first registers
/proc/sys/net/ipv4/neigh/ and afterwards /proc/sys/net/ipv4/neigh/default/.

These operations are ran for each network namespace in part, even for
init_net (which is the only net that sees the 'default' entry), thus
/proc/sys/net/ipv4/neigh/default/ gets registered, just that the
registration now happens later that before this patch.

In testing this did not seem to create problems, but I haven't checked
the code thoroughly.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/netns/ipv4.h |    1 +
 net/ipv4/arp.c           |   70 ++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/route.c         |   13 ++++----
 3 files changed, 74 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index cdb8307..182dc69 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -17,6 +17,7 @@ struct netns_ipv4 {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*forw_hdr;   /* /proc/sys/net/ipv4/ip_forward */
 	struct ctl_table_header	*conf_hdr;   /* /proc/sys/net/ipv4/conf/ */
+	struct ctl_table_header	*neigh_hdr;  /* /proc/sys/net/ipv4/neigh/ */
 	struct ctl_table_header	*frags_hdr;  /* /proc/sys/net/ipv4/ipfrag_* */
 	struct ctl_table_header	*ipv4_hdr;   /* see @ipv4_net_table */
 	struct ctl_table_header *route_hdr;  /* /proc/sys/net/ipv4/route/flush */
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 090d273..d38654f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1302,6 +1302,7 @@ static struct packet_type arp_packet_type __read_mostly = {
 };
 
 static int arp_proc_init(void);
+static int __init arp_sysctl_init(void);
 
 void __init arp_init(void)
 {
@@ -1309,9 +1310,7 @@ void __init arp_init(void)
 
 	dev_add_pack(&arp_packet_type);
 	arp_proc_init();
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(NULL, &arp_tbl.parms, "ipv4", NULL);
-#endif
+	arp_sysctl_init();
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
 
@@ -1478,3 +1477,68 @@ static int __init arp_proc_init(void)
 }
 
 #endif /* CONFIG_PROC_FS */
+
+
+
+#ifdef CONFIG_SYSCTL
+
+/* empty entry for '/proc/sys/net/ipv4/neigh/' */
+static struct ctl_table empty[1];
+static struct ctl_table ipv4_neigh_skel[] = {
+	{
+		.procname       = "neigh",
+		.mode           = 0555,
+		.child          = empty,
+	},
+	{ },
+};
+static __net_initdata const struct ctl_path net_ipv4_path[] = {
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
+	{ },
+};
+
+static int __net_init arp_sysctl_net_init(struct net *net)
+{
+	/* register empty dir for /proc/sys/net/ipv4/neigh/ */
+	net->ipv4.neigh_hdr = register_net_sysctl_table(net,
+					net_ipv4_path, ipv4_neigh_skel);
+	if (net->ipv4.neigh_hdr == NULL)
+		return -ENOMEM;
+
+	/* register /proc/sys/net/ipv4/neigh/default */
+	if (net_eq(net, &init_net)) {
+		int err;
+		err = neigh_sysctl_register(NULL, &arp_tbl.parms, "ipv4", NULL);
+		if (err) {
+			unregister_net_sysctl_table(net->ipv4.neigh_hdr);
+			return err;
+		}
+	}
+	return 0;
+}
+
+static void __net_exit arp_sysctl_net_exit(struct net *net)
+{
+	neigh_sysctl_unregister(&arp_tbl.parms);
+	unregister_sysctl_table(net->ipv4.neigh_hdr);
+}
+
+static struct pernet_operations arp_sysctl_ops = {
+	.init = arp_sysctl_net_init,
+	.exit = arp_sysctl_net_exit,
+};
+
+static int __init arp_sysctl_init(void)
+{
+	return register_pernet_subsys(&arp_sysctl_ops);
+}
+
+#else /* CONFIG_SYSCTL */
+
+static int __init arp_sysctl_init(void)
+{
+	return 0;
+}
+
+#endif /* CONFIG_SYSCTL */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1e99f01..180a10d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3139,15 +3139,14 @@ static ctl_table ipv4_route_table[] = {
 	{ }
 };
 
-static struct ctl_table empty[1];
-
 static struct ctl_table ipv4_skeleton[] =
 {
-	{ .procname = "route", 
-	  .mode = 0555, .child = ipv4_route_table},
-	{ .procname = "neigh", 
-	  .mode = 0555, .child = empty},
-	{ }
+	{
+		.procname = "route",
+		.mode     = 0555,
+		.child    = ipv4_route_table,
+	},
+	{ },
 };
 
 static __net_initdata struct ctl_path ipv4_path[] = {
-- 
1.7.5.rc0

