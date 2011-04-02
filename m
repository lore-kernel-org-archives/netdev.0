From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 20/24] sysctl: ipv6: register /proc/sys/net/ipv6/conf empty directory
Date: Sat,  2 Apr 2011 04:53:34 +0200
Message-ID: <e5dae2d99266da1ef9e73617678a1c0279c0f46e.1301711868.git.lucian.grijincu__10309.3178048313$1301713020$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40187 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757114Ab1DBCy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:57 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This does not change any semantics: it just adds a new header that
will be used in the next patch as a parent for all headers for
all /proc/sys/net/ipv6/conf/DEVNAME entries.

For now, all interface headers for /proc/sys/net/ipv6/conf/DEVNAME
will be bound to this header as opposed to another one from above, but
this shouldn't affect performance or behaviour.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/netns/ipv6.h |    3 ++-
 net/ipv6/addrconf.c      |   29 ++++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 81abfcb..b3c3cd7 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -13,7 +13,8 @@ struct ctl_table_header;
 struct netns_sysctl_ipv6 {
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header *table;
-	struct ctl_table_header *frags_hdr;
+	struct ctl_table_header *frags_hdr;  /* /proc/sys/net/ipv6/ip6frag_*  */
+	struct ctl_table_header *conf_hdr;   /* /proc/sys/net/ipv6/conf/      */
 #endif
 	int bindv6only;
 	int flush_delay;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4a28442..6833fcb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4556,8 +4556,25 @@ static void addrconf_sysctl_unregister(struct inet6_dev *idev)
 	neigh_sysctl_unregister(idev->nd_parms);
 }
 
+/* empty entry for '/proc/sys/net/ipv6/conf/' */
+static __net_initdata struct ctl_table empty[1];
+static __net_initdata struct ctl_table ipv6_conf_skel[] = {
+	{
+		.procname       = "conf",
+		.mode           = 0555,
+		.child          = empty,
+	},
+	{ },
+};
+
+static __net_initdata const struct ctl_path net_ipv6_path[] = {
+	{ .procname = "net", },
+	{ .procname = "ipv6", },
+	{ },
+};
+
+#endif /* CONFIG_SYSCTL */
 
-#endif
 
 static int __net_init addrconf_init_net(struct net *net)
 {
@@ -4586,6 +4603,12 @@ static int __net_init addrconf_init_net(struct net *net)
 	net->ipv6.devconf_dflt = dflt;
 
 #ifdef CONFIG_SYSCTL
+	err = -ENOMEM;
+	net->ipv6.sysctl.conf_hdr = register_net_sysctl_table(net,
+					net_ipv6_path, ipv6_conf_skel);
+	if (net->ipv6.sysctl.conf_hdr == NULL)
+		goto err_reg_conf;
+
 	err = __addrconf_sysctl_register(net, "all", NULL, all);
 	if (err < 0)
 		goto err_reg_all;
@@ -4593,6 +4616,7 @@ static int __net_init addrconf_init_net(struct net *net)
 	err = __addrconf_sysctl_register(net, "default", NULL, dflt);
 	if (err < 0)
 		goto err_reg_dflt;
+
 #endif
 	return 0;
 
@@ -4600,6 +4624,8 @@ static int __net_init addrconf_init_net(struct net *net)
 err_reg_dflt:
 	__addrconf_sysctl_unregister(all);
 err_reg_all:
+	unregister_net_sysctl_table(net->ipv6.sysctl.conf_hdr);
+err_reg_conf:
 	kfree(dflt);
 #endif
 err_alloc_dflt:
@@ -4613,6 +4639,7 @@ static void __net_exit addrconf_exit_net(struct net *net)
 #ifdef CONFIG_SYSCTL
 	__addrconf_sysctl_unregister(net->ipv6.devconf_dflt);
 	__addrconf_sysctl_unregister(net->ipv6.devconf_all);
+	unregister_net_sysctl_table(net->ipv6.sysctl.conf_hdr);
 #endif
 	if (!net_eq(net, &init_net)) {
 		kfree(net->ipv6.devconf_dflt);
-- 
1.7.5.rc0

