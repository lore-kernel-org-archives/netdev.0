From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25] Cleanup sysctl manipulations in devinet.c
Date: Fri, 07 Dec 2007 19:25:59 +0300
Message-ID: <47597417.9090801@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49932 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbXLGQ0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 11:26:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes:

 * moving neigh_sysctl_(un)register calls inside
   devinet_sysctl_(un)register ones, as they are always
   called in pairs;
 * making __devinet_sysctl_unregister() to unregister
   the ipv4_devconf struct, while original devinet_sysctl_unregister()
   works with the in_device to handle both - devconf and
   neigh sysctls;
 * make stubs for CONFIG_SYSCTL=n case to get rid of
   in-code ifdefs.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0b5f042..872883e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -99,7 +99,14 @@ static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy);
 #ifdef CONFIG_SYSCTL
 static void devinet_sysctl_register(struct in_device *idev);
-static void devinet_sysctl_unregister(struct ipv4_devconf *p);
+static void devinet_sysctl_unregister(struct in_device *idev);
+#else
+static inline void devinet_sysctl_register(struct in_device *idev)
+{
+}
+static inline void devinet_sysctl_unregister(struct in_device *idev)
+{
+}
 #endif
 
 /* Locks all the inet devices. */
@@ -163,17 +170,10 @@ static struct in_device *inetdev_init(struct net_device *dev)
 		goto out_kfree;
 	/* Reference in_dev->dev */
 	dev_hold(dev);
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
-#endif
-
 	/* Account for reference dev->ip_ptr (below) */
 	in_dev_hold(in_dev);
 
-#ifdef CONFIG_SYSCTL
 	devinet_sysctl_register(in_dev);
-#endif
 	ip_mc_init_dev(in_dev);
 	if (dev->flags & IFF_UP)
 		ip_mc_up(in_dev);
@@ -212,15 +212,9 @@ static void inetdev_destroy(struct in_device *in_dev)
 		inet_free_ifa(ifa);
 	}
 
-#ifdef CONFIG_SYSCTL
-	devinet_sysctl_unregister(&in_dev->cnf);
-#endif
-
 	dev->ip_ptr = NULL;
 
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(in_dev->arp_parms);
-#endif
+	devinet_sysctl_unregister(in_dev);
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
 	arp_ifdown(dev);
 
@@ -1114,13 +1108,8 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 		 */
 		inetdev_changename(dev, in_dev);
 
-#ifdef CONFIG_SYSCTL
-		devinet_sysctl_unregister(&in_dev->cnf);
-		neigh_sysctl_unregister(in_dev->arp_parms);
-		neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
-				      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+		devinet_sysctl_unregister(in_dev);
 		devinet_sysctl_register(in_dev);
-#endif
 		break;
 	}
 out:
@@ -1519,21 +1508,31 @@ out:
 	return;
 }
 
+static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
+{
+	struct devinet_sysctl_table *t = cnf->sysctl;
+
+	if (t == NULL)
+		return;
+
+	cnf->sysctl = NULL;
+	unregister_sysctl_table(t->sysctl_header);
+	kfree(t->dev_name);
+	kfree(t);
+}
+
 static void devinet_sysctl_register(struct in_device *idev)
 {
-	return __devinet_sysctl_register(idev->dev->name, idev->dev->ifindex,
+	neigh_sysctl_register(idev->dev, idev->arp_parms, NET_IPV4,
+			NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+	__devinet_sysctl_register(idev->dev->name, idev->dev->ifindex,
 			&idev->cnf);
 }
 
-static void devinet_sysctl_unregister(struct ipv4_devconf *p)
+static void devinet_sysctl_unregister(struct in_device *idev)
 {
-	if (p->sysctl) {
-		struct devinet_sysctl_table *t = p->sysctl;
-		p->sysctl = NULL;
-		unregister_sysctl_table(t->sysctl_header);
-		kfree(t->dev_name);
-		kfree(t);
-	}
+	__devinet_sysctl_unregister(&idev->cnf);
+	neigh_sysctl_unregister(idev->arp_parms);
 }
 #endif
 
-- 
1.5.3.4

