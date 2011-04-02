From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 18/24] sysctl: ipv4: register /proc/sys/net/ipv4/conf empty directory
Date: Sat,  2 Apr 2011 04:53:32 +0200
Message-ID: <b992ffd8be31308937728a05878ead147f20c95e.1301711868.git.lucian.grijincu__45536.9752868593$1301713053$gmane$org@gmail.com>
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
	with ESMTP id S1756206Ab1DBCyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:53 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This does not change any semantics: it just adds a new header that
will be used in the next patch as a parent for all headers for
all /proc/sys/net/ipv4/conf/DEVNAME entries.

For now, all interface headers for /proc/sys/net/ipv4/conf/DEVNAME
will be bound to this header as opposed to another one from above, but
this shouldn't affect performance or behaviour.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/netns/ipv4.h |    9 +++++----
 net/ipv4/devinet.c       |   25 +++++++++++++++++++++++--
 2 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 542195d..cdb8307 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -15,10 +15,11 @@ struct sock;
 
 struct netns_ipv4 {
 #ifdef CONFIG_SYSCTL
-	struct ctl_table_header	*forw_hdr;
-	struct ctl_table_header	*frags_hdr;
-	struct ctl_table_header	*ipv4_hdr;
-	struct ctl_table_header *route_hdr;
+	struct ctl_table_header	*forw_hdr;   /* /proc/sys/net/ipv4/ip_forward */
+	struct ctl_table_header	*conf_hdr;   /* /proc/sys/net/ipv4/conf/ */
+	struct ctl_table_header	*frags_hdr;  /* /proc/sys/net/ipv4/ipfrag_* */
+	struct ctl_table_header	*ipv4_hdr;   /* see @ipv4_net_table */
+	struct ctl_table_header *route_hdr;  /* /proc/sys/net/ipv4/route/flush */
 #endif
 	struct ipv4_devconf	*devconf_all;
 	struct ipv4_devconf	*devconf_dflt;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 551786f..a31cc90 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1698,6 +1698,18 @@ static void devinet_sysctl_unregister(struct in_device *idev)
 	neigh_sysctl_unregister(idev->arp_parms);
 }
 
+
+/* empty entry for '/proc/sys/net/ipv4/conf/' */
+static __net_initdata struct ctl_table empty[1];
+static __net_initdata struct ctl_table ipv4_conf_skel[] = {
+	{
+		.procname	= "conf",
+		.mode		= 0555,
+		.child		= empty,
+	},
+	{ },
+};
+
 static struct ctl_table ctl_forward_entry[] = {
 	{
 		.procname	= "ip_forward",
@@ -1712,7 +1724,7 @@ static struct ctl_table ctl_forward_entry[] = {
 	{ },
 };
 
-static __net_initdata struct ctl_path net_ipv4_path[] = {
+static __net_initdata const struct ctl_path net_ipv4_path[] = {
 	{ .procname = "net", },
 	{ .procname = "ipv4", },
 	{ },
@@ -1725,7 +1737,7 @@ static __net_init int devinet_init_net(struct net *net)
 	struct ipv4_devconf *all, *dflt;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table *tbl = ctl_forward_entry;
-	struct ctl_table_header *forw_hdr;
+	struct ctl_table_header *forw_hdr, *conf_hdr;
 #endif
 
 	err = -ENOMEM;
@@ -1753,6 +1765,12 @@ static __net_init int devinet_init_net(struct net *net)
 	}
 
 #ifdef CONFIG_SYSCTL
+	err = -ENOMEM;
+	conf_hdr = register_net_sysctl_table(net, net_ipv4_path, ipv4_conf_skel);
+	if (conf_hdr == NULL)
+		goto err_reg_conf;
+	net->ipv4.conf_hdr = conf_hdr;
+
 	err = __devinet_sysctl_register(net, "all", all);
 	if (err < 0)
 		goto err_reg_all;
@@ -1778,6 +1796,8 @@ err_reg_ctl:
 err_reg_dflt:
 	__devinet_sysctl_unregister(all);
 err_reg_all:
+	unregister_net_sysctl_table(conf_hdr);
+err_reg_conf:
 	if (tbl != ctl_forward_entry)
 		kfree(tbl);
 err_alloc_ctl:
@@ -1800,6 +1820,7 @@ static __net_exit void devinet_exit_net(struct net *net)
 	unregister_net_sysctl_table(net->ipv4.forw_hdr);
 	__devinet_sysctl_unregister(net->ipv4.devconf_dflt);
 	__devinet_sysctl_unregister(net->ipv4.devconf_all);
+	unregister_net_sysctl_table(net->ipv4.conf_hdr);
 	kfree(tbl);
 #endif
 	kfree(net->ipv4.devconf_dflt);
-- 
1.7.5.rc0

