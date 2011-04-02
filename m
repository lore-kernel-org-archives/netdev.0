From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 24/24] sysctl: neigh: ipv4 and ipv6 neigh tables as private children
Date: Sat,  2 Apr 2011 04:53:38 +0200
Message-ID: <6d6e3bdbccbd197cdf416140f0a88411f31dc31b.1301711868.git.lucian.grijincu@gmail.com>
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
	with ESMTP id S1757251Ab1DBCzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:55:08 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ time modprobe dummy numdummies=$n

Without this patch:
 - n=5000 => real:  9:14m, sys: 8:46m
 - n=2000 => real:  1:19m, sys: 1:17m
 - n=1000 => real:  0:14m, sys: 0:14m

With this patch:
 - n=5000 => real: 12.50s
 - n=2000 => real:  1.59s
 - n=1000 => real:  0.44s

$ time find /proc/sys/net/ > /dev/null

Without this patch:
 - n=5000 => real: 15s
 - n=2000 => real: 12s
 - n=1000 => real:  4s

With this patch:
 - n=5000 => real: 3.77s
 - n=2000 => real: 1.55s
 - n=1000 => real: 1.43s

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/neighbour.h |    9 ++++-----
 net/core/neighbour.c    |    6 ++++--
 net/ipv4/arp.c          |    3 ++-
 net/ipv4/devinet.c      |    3 ++-
 net/ipv6/addrconf.c     |    3 ++-
 net/ipv6/ndisc.c        |    3 ++-
 6 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 4014b62..3fabfa3 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -259,11 +259,10 @@ extern void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_table *,
 extern void *neigh_seq_next(struct seq_file *, void *, loff_t *);
 extern void neigh_seq_stop(struct seq_file *, void *);
 
-extern int			neigh_sysctl_register(struct net_device *dev, 
-						      struct neigh_parms *p,
-						      char *p_name,
-						      proc_handler *proc_handler);
-extern void			neigh_sysctl_unregister(struct neigh_parms *p);
+extern int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
+				 char *p_name, proc_handler *proc_handler,
+				 struct ctl_table_header *parent_header);
+extern void neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
 {
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 799f06e..48141cb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2804,7 +2804,8 @@ static struct neigh_sysctl_table {
 };
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  char *p_name, proc_handler *handler)
+			  char *p_name, proc_handler *handler,
+			  struct ctl_table_header *parent_header)
 {
 	struct neigh_sysctl_table *t;
 	const char *dev_name_source = NULL;
@@ -2877,7 +2878,8 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	neigh_path[NEIGH_CTL_PATH_PROTO].procname = p_name;
 
 	t->sysctl_header =
-		register_net_sysctl_table(neigh_parms_net(p), neigh_path, t->neigh_vars);
+		register_net_sysctl_table_with_parent(neigh_parms_net(p),
+				      neigh_path, t->neigh_vars, parent_header);
 	if (!t->sysctl_header)
 		goto free_procname;
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d38654f..a5ba277 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1509,7 +1509,8 @@ static int __net_init arp_sysctl_net_init(struct net *net)
 	/* register /proc/sys/net/ipv4/neigh/default */
 	if (net_eq(net, &init_net)) {
 		int err;
-		err = neigh_sysctl_register(NULL, &arp_tbl.parms, "ipv4", NULL);
+		err = neigh_sysctl_register(NULL, &arp_tbl.parms, "ipv4",
+					    NULL, net->ipv4.neigh_hdr);
 		if (err) {
 			unregister_net_sysctl_table(net->ipv4.neigh_hdr);
 			return err;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2a10365..461466c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1687,7 +1687,8 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 
 static void devinet_sysctl_register(struct in_device *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->arp_parms, "ipv4", NULL);
+	neigh_sysctl_register(idev->dev, idev->arp_parms, "ipv4",
+			      NULL, dev_net(idev->dev)->ipv4.neigh_hdr);
 	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					&idev->cnf);
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6ac29d0..30c163c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4545,7 +4545,8 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
 	neigh_sysctl_register(idev->dev, idev->nd_parms, "ipv6",
-			      &ndisc_ifinfo_sysctl_change);
+			      &ndisc_ifinfo_sysctl_change,
+			      dev_net(idev->dev)->ipv6.sysctl.neigh_hdr);
 	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					idev, &idev->cnf);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1cbc3c6..005d163 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1828,7 +1828,8 @@ static int __net_init ndisc_net_init(struct net *net)
 	/* register /proc/sys/net/ipv6/neigh/default */
 	if (net_eq(net, &init_net)) {
 		err = neigh_sysctl_register(NULL, &nd_tbl.parms, "ipv6",
-					    &ndisc_ifinfo_sysctl_change);
+					    &ndisc_ifinfo_sysctl_change,
+					    net->ipv6.sysctl.neigh_hdr);
 		if (err)
 			goto neigh_sysctl_register_fail;
 	}
-- 
1.7.5.rc0

