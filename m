From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/5] neigh: use tbl->family to distinguish ipv4 from ipv6
Date: Sat,  7 Dec 2013 19:26:55 +0100
Message-ID: <1386440817-7846-4-git-send-email-jiri@resnulli.us>
References: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:45704 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab3LGS1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 13:27:08 -0500
Received: by mail-ea0-f179.google.com with SMTP id r15so843952ead.10
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 10:27:07 -0800 (PST)
In-Reply-To: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/neighbour.h |  7 ++++++-
 net/core/neighbour.c    | 14 +++++++++++++-
 net/ipv4/arp.c          |  2 +-
 net/ipv4/devinet.c      |  2 +-
 net/ipv6/addrconf.c     |  2 +-
 net/ipv6/ndisc.c        |  2 +-
 6 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index ed7eba0..95615c9 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -202,6 +202,11 @@ struct neigh_table {
 	struct pneigh_entry	**phash_buckets;
 };
 
+static inline int neigh_parms_family(struct neigh_parms *p)
+{
+	return p->tbl->family;
+}
+
 #define NEIGH_PRIV_ALIGN	sizeof(long long)
 #define NEIGH_ENTRY_SIZE(size)	ALIGN((size), NEIGH_PRIV_ALIGN)
 
@@ -306,7 +311,7 @@ int neigh_proc_dointvec_ms_jiffies(struct ctl_table *ctl, int write,
 				   size_t *lenp, loff_t *ppos);
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  char *p_name, proc_handler *proc_handler);
+			  proc_handler *proc_handler);
 void neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 60edd97..65ead08 100644
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
+	char *p_name;
 
 	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
 	if (!t)
@@ -2991,6 +2992,17 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	if (neigh_parms_net(p)->user_ns != &init_user_ns)
 		t->neigh_vars[0].procname = NULL;
 
+	switch (neigh_parms_family(p)) {
+	case AF_INET:
+	      p_name = "ipv4";
+	      break;
+	case AF_INET6:
+	      p_name = "ipv6";
+	      break;
+	default:
+	      BUG();
+	}
+
 	snprintf(neigh_path, sizeof(neigh_path), "net/%s/neigh/%s",
 		p_name, dev_name_source);
 	t->sysctl_header =
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 3a37c7d..f041858 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1287,7 +1287,7 @@ void __init arp_init(void)
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
index 5fc6f69..09a22f4 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1730,7 +1730,7 @@ int __init ndisc_init(void)
 	neigh_table_init(&nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-	err = neigh_sysctl_register(NULL, &nd_tbl.parms, "ipv6",
+	err = neigh_sysctl_register(NULL, &nd_tbl.parms,
 				    &ndisc_ifinfo_sysctl_change);
 	if (err)
 		goto out_unregister_pernet;
-- 
1.8.3.1
