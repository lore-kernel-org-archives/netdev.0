From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 08/11] ipv6: move in6_dev_finish_destroy() into core kernel
Date: Wed, 28 Aug 2013 13:22:56 +0800
Message-ID: <1377667379-2315-9-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab3H1FZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:25:06 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

in6_dev_put() will be needed by vxlan module, so is
in6_dev_finish_destroy().

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf.c      |   30 ------------------------------
 net/ipv6/addrconf_core.c |   31 +++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1bb0861..ff7967e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -302,36 +302,6 @@ err_ip:
 	return -ENOMEM;
 }
 
-static void snmp6_free_dev(struct inet6_dev *idev)
-{
-	kfree(idev->stats.icmpv6msgdev);
-	kfree(idev->stats.icmpv6dev);
-	snmp_mib_free((void __percpu **)idev->stats.ipv6);
-}
-
-/* Nobody refers to this device, we may destroy it. */
-
-void in6_dev_finish_destroy(struct inet6_dev *idev)
-{
-	struct net_device *dev = idev->dev;
-
-	WARN_ON(!list_empty(&idev->addr_list));
-	WARN_ON(idev->mc_list != NULL);
-	WARN_ON(timer_pending(&idev->rs_timer));
-
-#ifdef NET_REFCNT_DEBUG
-	pr_debug("%s: %s\n", __func__, dev ? dev->name : "NIL");
-#endif
-	dev_put(dev);
-	if (!idev->dead) {
-		pr_warn("Freeing alive inet6 device %p\n", idev);
-		return;
-	}
-	snmp6_free_dev(idev);
-	kfree_rcu(idev, rcu);
-}
-EXPORT_SYMBOL(in6_dev_finish_destroy);
-
 static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index a864033..4c11cbc 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -6,6 +6,7 @@
 #include <linux/export.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
+#include <net/ip.h>
 
 #define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
 
@@ -117,3 +118,33 @@ const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADDR_INTERFACELOCAL
 EXPORT_SYMBOL(in6addr_interfacelocal_allrouters);
 const struct in6_addr in6addr_sitelocal_allrouters = IN6ADDR_SITELOCAL_ALLROUTERS_INIT;
 EXPORT_SYMBOL(in6addr_sitelocal_allrouters);
+
+static void snmp6_free_dev(struct inet6_dev *idev)
+{
+	kfree(idev->stats.icmpv6msgdev);
+	kfree(idev->stats.icmpv6dev);
+	snmp_mib_free((void __percpu **)idev->stats.ipv6);
+}
+
+/* Nobody refers to this device, we may destroy it. */
+
+void in6_dev_finish_destroy(struct inet6_dev *idev)
+{
+	struct net_device *dev = idev->dev;
+
+	WARN_ON(!list_empty(&idev->addr_list));
+	WARN_ON(idev->mc_list != NULL);
+	WARN_ON(timer_pending(&idev->rs_timer));
+
+#ifdef NET_REFCNT_DEBUG
+	pr_debug("%s: %s\n", __func__, dev ? dev->name : "NIL");
+#endif
+	dev_put(dev);
+	if (!idev->dead) {
+		pr_warn("Freeing alive inet6 device %p\n", idev);
+		return;
+	}
+	snmp6_free_dev(idev);
+	kfree_rcu(idev, rcu);
+}
+EXPORT_SYMBOL(in6_dev_finish_destroy);
-- 
1.7.7.6
