From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [net-next-2.6 PATCH 2/2] net neigh: Decouple per interface neighbour table controls from binary sysctls
Date: Sun, 14 Feb 2010 05:27:03 -0800
Message-ID: <m1bpfskkwo.fsf@fess.ebiederm.org>
References: <m1fx54kkyo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41453 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381Ab0BNN1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 08:27:08 -0500
In-Reply-To: <m1fx54kkyo.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 14 Feb 2010 05\:25\:51 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stop computing the number of neighbour table settings we have by
counting the number of binary sysctls.  This behaviour was silly
and meant that we could not add another neighbour table setting
without also adding another binary sysctl.

Don't pass the binary sysctl path for neighour table entries
into neigh_sysctl_register.  These parameters are no longer
used and so are just dead code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysctl.h  |    1 -
 include/net/neighbour.h |    1 -
 net/core/neighbour.c    |    7 ++++---
 net/ipv4/arp.c          |    3 +--
 net/ipv4/devinet.c      |    3 +--
 net/ipv6/addrconf.c     |    3 +--
 net/ipv6/ndisc.c        |    3 +--
 7 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 7c74e91..f66014c 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -596,7 +596,6 @@ enum {
 	NET_NEIGH_GC_THRESH3=16,
 	NET_NEIGH_RETRANS_TIME_MS=17,
 	NET_NEIGH_REACHABLE_TIME_MS=18,
-	__NET_NEIGH_MAX
 };
 
 /* /proc/sys/net/dccp */
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index b017320..7834f47 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -251,7 +251,6 @@ extern void neigh_seq_stop(struct seq_file *, void *);
 
 extern int			neigh_sysctl_register(struct net_device *dev, 
 						      struct neigh_parms *p,
-						      int p_id, int pdev_id,
 						      char *p_name,
 						      proc_handler *proc_handler);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f2efd72..d102f6d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2556,9 +2556,11 @@ EXPORT_SYMBOL(neigh_app_ns);
 
 #ifdef CONFIG_SYSCTL
 
+#define NEIGH_VARS_MAX 19
+
 static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	struct ctl_table neigh_vars[__NET_NEIGH_MAX];
+	struct ctl_table neigh_vars[NEIGH_VARS_MAX];
 	char *dev_name;
 } neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
@@ -2675,8 +2677,7 @@ static struct neigh_sysctl_table {
 };
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  int p_id, int pdev_id, char *p_name,
-			  proc_handler *handler)
+			  char *p_name, proc_handler *handler)
 {
 	struct neigh_sysctl_table *t;
 	const char *dev_name_source = NULL;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1940b4d..c4dd135 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1284,8 +1284,7 @@ void __init arp_init(void)
 	dev_add_pack(&arp_packet_type);
 	arp_proc_init();
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL);
+	neigh_sysctl_register(NULL, &arp_tbl.parms, "ipv4", NULL);
 #endif
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index b1eddee..014982b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1487,8 +1487,7 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 
 static void devinet_sysctl_register(struct in_device *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->arp_parms, NET_IPV4,
-			NET_IPV4_NEIGH, "ipv4", NULL);
+	neigh_sysctl_register(idev->dev, idev->arp_parms, "ipv4", NULL);
 	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					&idev->cnf);
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 764ad37..c79cbff 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4416,8 +4416,7 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 
 static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->nd_parms, NET_IPV6,
-			      NET_IPV6_NEIGH, "ipv6",
+	neigh_sysctl_register(idev->dev, idev->nd_parms, "ipv6",
 			      &ndisc_ifinfo_sysctl_change);
 	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					idev, &idev->cnf);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2dfec6b..8bcc4b7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1820,8 +1820,7 @@ int __init ndisc_init(void)
 	neigh_table_init(&nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-	err = neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6,
-				    NET_IPV6_NEIGH, "ipv6",
+	err = neigh_sysctl_register(NULL, &nd_tbl.parms, "ipv6",
 				    &ndisc_ifinfo_sysctl_change);
 	if (err)
 		goto out_unregister_pernet;
-- 
1.6.5.2.143.g8cc62

