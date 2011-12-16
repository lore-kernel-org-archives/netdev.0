From: igorm@etf.rs
Subject: [PATCH 05/10 net-next] include:net:ip: Tuned up IP_*_STATS macros for per device statistics and added functions for (un)registering per device proc entries
Date: Fri, 16 Dec 2011 16:25:58 +0100
Message-ID: <1324049163-11207-6-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:35808 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759882Ab1LPP0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:21 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Changed IP_*_STATS so now they call _DEV* macros.
They call _DEV* macros under rcu_read_lock,
so we could get in_device* from net_device* with function
__in_dev_get_rcu_safely. This function is safe if dev==NULL.

Included <linux/inetdevice.h> so we could call __in_dev_get_rcu_safely.

Added prototypes for snmp_(un)register_dev.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 include/net/ip.h |   60 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 54 insertions(+), 6 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 775009f..9895b1f 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -26,6 +26,7 @@
 #include <linux/ip.h>
 #include <linux/in.h>
 #include <linux/skbuff.h>
+#include <linux/inetdevice.h>
 
 #include <net/inet_sock.h>
 #include <net/snmp.h>
@@ -184,12 +185,54 @@ struct ipv4_config {
 };
 
 extern struct ipv4_config ipv4_config;
-#define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
-#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
-#define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
-#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
-#define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
-#define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
+#define IP_INC_STATS(net, dev, field)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVINC(net, ip, 64, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field);	\
+		rcu_read_unlock();	\
+	})
+
+#define IP_INC_STATS_BH(net, dev, field)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVINC(net, ip, 64_BH, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field);	\
+		rcu_read_unlock();	\
+	})
+
+#define IP_ADD_STATS(net, dev, field, val)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVADD(net, ip, 64, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field, val);	\
+		rcu_read_unlock();	\
+	})
+
+#define IP_ADD_STATS_BH(net, dev, field, val)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVADD(net, ip, 64_BH, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field, val);	\
+		rcu_read_unlock();	\
+	})
+
+#define IP_UPD_PO_STATS(net, dev, field, val)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVUPD(net, ip, 64, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field, val);	\
+		rcu_read_unlock();	\
+	})
+
+#define IP_UPD_PO_STATS_BH(net, dev, field, val)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVUPD(net, ip, 64_BH, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field, val);	\
+		rcu_read_unlock();	\
+	})
+
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
 #define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
 #define NET_INC_STATS_USER(net, field) 	SNMP_INC_STATS_USER((net)->mib.net_statistics, field)
@@ -470,6 +513,11 @@ extern void	ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 
 #ifdef CONFIG_PROC_FS
 extern int ip_misc_proc_init(void);
+extern int snmp_register_dev(struct in_device *idev);
+extern int snmp_unregister_dev(struct in_device *idev);
+#else
+extern int snmp_register_dev(struct in_device *idev) { return 0;}
+extern int snmp_unregister_dev(struct in_device *idev) { return 0;}
 #endif
 
 #endif	/* _IP_H */
-- 
1.7.5.4
