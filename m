From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/17] netfilter: log: protect nf_log_register against double registering
Date: Mon, 24 Nov 2014 14:27:43 +0100
Message-ID: <1416835674-11871-7-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44861 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094AbaKXNZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:55 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Leitner <mleitner@redhat.com>

Currently, despite the comment right before the function,
nf_log_register allows registering two loggers on with the same type and
end up overwriting the previous register.

Not a real issue today as current tree doesn't have two loggers for the
same type but it's better to get this protected.

Also make sure that all of its callers do error checking.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_log_arp.c  |   12 +++++++++++-
 net/ipv4/netfilter/nf_log_ipv4.c |   12 +++++++++++-
 net/ipv6/netfilter/nf_log_ipv6.c |   12 +++++++++++-
 net/netfilter/nf_log.c           |   16 +++++++++++++---
 4 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index ccfc78d..0c8799a 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -10,6 +10,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/spinlock.h>
@@ -130,8 +131,17 @@ static int __init nf_log_arp_init(void)
 	if (ret < 0)
 		return ret;
 
-	nf_log_register(NFPROTO_ARP, &nf_arp_logger);
+	ret = nf_log_register(NFPROTO_ARP, &nf_arp_logger);
+	if (ret < 0) {
+		pr_err("failed to register logger\n");
+		goto err1;
+	}
+
 	return 0;
+
+err1:
+	unregister_pernet_subsys(&nf_log_arp_net_ops);
+	return ret;
 }
 
 static void __exit nf_log_arp_exit(void)
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 078bdca..7510198 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -5,6 +5,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/spinlock.h>
@@ -366,8 +367,17 @@ static int __init nf_log_ipv4_init(void)
 	if (ret < 0)
 		return ret;
 
-	nf_log_register(NFPROTO_IPV4, &nf_ip_logger);
+	ret = nf_log_register(NFPROTO_IPV4, &nf_ip_logger);
+	if (ret < 0) {
+		pr_err("failed to register logger\n");
+		goto err1;
+	}
+
 	return 0;
+
+err1:
+	unregister_pernet_subsys(&nf_log_ipv4_net_ops);
+	return ret;
 }
 
 static void __exit nf_log_ipv4_exit(void)
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 7b17a0b..7fc34d1 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -5,6 +5,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/spinlock.h>
@@ -398,8 +399,17 @@ static int __init nf_log_ipv6_init(void)
 	if (ret < 0)
 		return ret;
 
-	nf_log_register(NFPROTO_IPV6, &nf_ip6_logger);
+	ret = nf_log_register(NFPROTO_IPV6, &nf_ip6_logger);
+	if (ret < 0) {
+		pr_err("failed to register logger\n");
+		goto err1;
+	}
+
 	return 0;
+
+err1:
+	unregister_pernet_subsys(&nf_log_ipv6_net_ops);
+	return ret;
 }
 
 static void __exit nf_log_ipv6_exit(void)
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 5eaf047..9562e39 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -75,6 +75,7 @@ EXPORT_SYMBOL(nf_log_unset);
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
 	int i;
+	int ret = 0;
 
 	if (pf >= ARRAY_SIZE(init_net.nf.nf_loggers))
 		return -EINVAL;
@@ -82,16 +83,25 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 	mutex_lock(&nf_log_mutex);
 
 	if (pf == NFPROTO_UNSPEC) {
+		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++) {
+			if (rcu_access_pointer(loggers[i][logger->type])) {
+				ret = -EEXIST;
+				goto unlock;
+			}
+		}
 		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 			rcu_assign_pointer(loggers[i][logger->type], logger);
 	} else {
-		/* register at end of list to honor first register win */
+		if (rcu_access_pointer(loggers[pf][logger->type])) {
+			ret = -EEXIST;
+			goto unlock;
+		}
 		rcu_assign_pointer(loggers[pf][logger->type], logger);
 	}
 
+unlock:
 	mutex_unlock(&nf_log_mutex);
-
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL(nf_log_register);
 
-- 
1.7.10.4
