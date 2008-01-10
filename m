From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/6][NETNS]: Clean out the ipv6-related sysctls
 creation/destruction
Date: Thu, 10 Jan 2008 16:58:53 +0300
Message-ID: <4786249D.4010606@openvz.org>
References: <478623C0.7030008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60313 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701AbYAJN7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 08:59:42 -0500
In-Reply-To: <478623C0.7030008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addrconf sysctls and neigh sysctls are registered and
unregistered always in pairs, so they can be joined into
one (well, two) functions, that accept the struct inet6_dev
and do all the job.

This also get rids of unneeded ifdefs inside the code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/addrconf.c |   63 +++++++++++++++++++++++++++-----------------------
 1 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6a48bb8..27b35dd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -102,7 +102,15 @@
 
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev);
-static void addrconf_sysctl_unregister(struct ipv6_devconf *p);
+static void addrconf_sysctl_unregister(struct inet6_dev *idev);
+#else
+static inline void addrconf_sysctl_register(struct inet6_dev *idev)
+{
+}
+
+static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
+{
+}
 #endif
 
 #ifdef CONFIG_IPV6_PRIVACY
@@ -392,13 +400,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(dev, ndev->nd_parms, NET_IPV6,
-			      NET_IPV6_NEIGH, "ipv6",
-			      &ndisc_ifinfo_sysctl_change,
-			      NULL);
 	addrconf_sysctl_register(ndev);
-#endif
 	/* protected by rtnl_lock */
 	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
@@ -2391,15 +2393,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	case NETDEV_CHANGENAME:
 		if (idev) {
 			snmp6_unregister_dev(idev);
-#ifdef CONFIG_SYSCTL
-			addrconf_sysctl_unregister(&idev->cnf);
-			neigh_sysctl_unregister(idev->nd_parms);
-			neigh_sysctl_register(dev, idev->nd_parms,
-					      NET_IPV6, NET_IPV6_NEIGH, "ipv6",
-					      &ndisc_ifinfo_sysctl_change,
-					      NULL);
+			addrconf_sysctl_unregister(idev);
 			addrconf_sysctl_register(idev);
-#endif
 			err = snmp6_register_dev(idev);
 			if (err)
 				return notifier_from_errno(err);
@@ -2523,10 +2518,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	/* Shot the device (if unregistered) */
 
 	if (how == 1) {
-#ifdef CONFIG_SYSCTL
-		addrconf_sysctl_unregister(&idev->cnf);
-		neigh_sysctl_unregister(idev->nd_parms);
-#endif
+		addrconf_sysctl_unregister(idev);
 		neigh_parms_release(&nd_tbl, idev->nd_parms);
 		neigh_ifdown(&nd_tbl, dev);
 		in6_dev_put(idev);
@@ -4106,21 +4098,34 @@ out:
 	return;
 }
 
+static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
+{
+	struct addrconf_sysctl_table *t;
+
+	if (p->sysctl == NULL)
+		return;
+
+	t = p->sysctl;
+	p->sysctl = NULL;
+	unregister_sysctl_table(t->sysctl_header);
+	kfree(t->dev_name);
+	kfree(t);
+}
+
 static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
+	neigh_sysctl_register(idev->dev, idev->nd_parms, NET_IPV6,
+			      NET_IPV6_NEIGH, "ipv6",
+			      &ndisc_ifinfo_sysctl_change,
+			      NULL);
 	__addrconf_sysctl_register(idev->dev->name, idev->dev->ifindex,
 			idev, &idev->cnf);
 }
 
-static void addrconf_sysctl_unregister(struct ipv6_devconf *p)
+static void addrconf_sysctl_unregister(struct inet6_dev *idev)
 {
-	if (p->sysctl) {
-		struct addrconf_sysctl_table *t = p->sysctl;
-		p->sysctl = NULL;
-		unregister_sysctl_table(t->sysctl_header);
-		kfree(t->dev_name);
-		kfree(t);
-	}
+	__addrconf_sysctl_unregister(&idev->cnf);
+	neigh_sysctl_unregister(idev->nd_parms);
 }
 
 
@@ -4232,8 +4237,8 @@ void addrconf_cleanup(void)
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 
 #ifdef CONFIG_SYSCTL
-	addrconf_sysctl_unregister(&ipv6_devconf_dflt);
-	addrconf_sysctl_unregister(&ipv6_devconf);
+	__addrconf_sysctl_unregister(&ipv6_devconf_dflt);
+	__addrconf_sysctl_unregister(&ipv6_devconf);
 #endif
 
 	rtnl_lock();
-- 
1.5.3.4

