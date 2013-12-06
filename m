From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] neigh: store parms type inside the structure
Date: Fri,  6 Dec 2013 19:29:02 +0100
Message-ID: <1386354544-19122-4-git-send-email-jiri@resnulli.us>
References: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org,
	william.manley@youview.com, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:56797 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839Ab3LFS3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 13:29:16 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so464649eaj.35
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 10:29:15 -0800 (PST)
In-Reply-To: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is going to be needed later on to distinguish parms instance
between ipv4 and ipv6. So just store the type inside.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/neighbour.h |  8 +++++++-
 net/core/neighbour.c    | 12 +++++++++++-
 net/ipv4/arp.c          |  3 ++-
 net/ipv4/devinet.c      |  2 +-
 net/ipv6/addrconf.c     |  2 +-
 net/ipv6/ndisc.c        |  3 ++-
 6 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index ed7eba0..b110a58 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -63,6 +63,11 @@ enum {
 	NEIGH_VAR_MAX
 };
 
+enum neigh_parms_type {
+	NEIGH_PARMS_TYPE_IPV4,
+	NEIGH_PARMS_TYPE_IPV6,
+};
+
 struct neigh_parms {
 #ifdef CONFIG_NET_NS
 	struct net *net;
@@ -79,6 +84,7 @@ struct neigh_parms {
 	atomic_t refcnt;
 	struct rcu_head rcu_head;
 
+	enum neigh_parms_type type;
 	int	reachable_time;
 	int	data[NEIGH_VAR_DATA_MAX];
 };
@@ -306,7 +312,7 @@ int neigh_proc_dointvec_ms_jiffies(struct ctl_table *ctl, int write,
 				   size_t *lenp, loff_t *ppos);
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  char *p_name, proc_handler *proc_handler);
+			  proc_handler *proc_handler);
 void neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60edd97..139a380 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2947,12 +2947,13 @@ static struct neigh_sysctl_table {
 };
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  char *p_name, proc_handler *handler)
+			  proc_handler *handler)
 {
 	int i;
 	struct neigh_sysctl_table *t;
 	const char *dev_name_source;
 	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];
+	char *uninitialized_var(p_name);
 
 	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
 	if (!t)
@@ -2991,6 +2992,15 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	if (neigh_parms_net(p)->user_ns != &init_user_ns)
 		t->neigh_vars[0].procname = NULL;
 
+	switch (p->type) {
+	case NEIGH_PARMS_TYPE_IPV4:
+	      p_name = "ipv4";
+	      break;
+	case NEIGH_PARMS_TYPE_IPV6:
+	      p_name = "ipv6";
+	      break;
+	}
+
 	snprintf(neigh_path, sizeof(neigh_path), "net/%s/neigh/%s",
 		p_name, dev_name_source);
 	t->sysctl_header =
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 3a37c7d..1246fa2 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -166,6 +166,7 @@ struct neigh_table arp_tbl = {
 	.id		= "arp_cache",
 	.parms		= {
 		.tbl			= &arp_tbl,
+		.type			= NEIGH_PARMS_TYPE_IPV4,
 		.reachable_time		= 30 * HZ,
 		.data	= {
 			[NEIGH_VAR_MCAST_PROBES] = 3,
@@ -1287,7 +1288,7 @@ void __init arp_init(void)
 	dev_add_pack(&arp_packet_type);
 	arp_proc_init();
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(NULL, &arp_tbl.parms, "ipv4", NULL);
+	neigh_sysctl_register(NULL, &arp_tbl.parms, NULL);
 #endif
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcb..e1c1953 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2160,7 +2160,7 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 
 static void devinet_sysctl_register(struct in_device *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->arp_parms, "ipv4", NULL);
+	neigh_sysctl_register(idev->dev, idev->arp_parms, NULL);
 	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					&idev->cnf);
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 26b46e9..0b05ad8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4993,7 +4993,7 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 
 static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
-	neigh_sysctl_register(idev->dev, idev->nd_parms, "ipv6",
+	neigh_sysctl_register(idev->dev, idev->nd_parms,
 			      &ndisc_ifinfo_sysctl_change);
 	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
 					idev, &idev->cnf);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5fc6f69..9cf1e01 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -125,6 +125,7 @@ struct neigh_table nd_tbl = {
 	.id =		"ndisc_cache",
 	.parms = {
 		.tbl			= &nd_tbl,
+		.type			= NEIGH_PARMS_TYPE_IPV6,
 		.reachable_time		= ND_REACHABLE_TIME,
 		.data = {
 			[NEIGH_VAR_MCAST_PROBES] = 3,
@@ -1730,7 +1731,7 @@ int __init ndisc_init(void)
 	neigh_table_init(&nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-	err = neigh_sysctl_register(NULL, &nd_tbl.parms, "ipv6",
+	err = neigh_sysctl_register(NULL, &nd_tbl.parms,
 				    &ndisc_ifinfo_sysctl_change);
 	if (err)
 		goto out_unregister_pernet;
-- 
1.8.3.1
