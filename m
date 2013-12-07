From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 5/5] neigh: ipv6: respect default values set before an address is assigned to device
Date: Sat,  7 Dec 2013 19:26:57 +0100
Message-ID: <1386440817-7846-6-git-send-email-jiri@resnulli.us>
References: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:57499 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758916Ab3LGS1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 13:27:12 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so839761ead.34
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 10:27:12 -0800 (PST)
In-Reply-To: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the behaviour similar to ipv4. This will allow user to set sysctl
default neigh param values and these values will be respected even by
devices registered before (that ones what do not have address set yet).

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/addrconf.h | 7 +++++++
 net/core/neighbour.c   | 7 ++++++-
 net/ipv6/addrconf.c    | 2 ++
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 86505bf..dad8a85 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -248,6 +248,13 @@ static inline struct inet6_dev *in6_dev_get(const struct net_device *dev)
 	return idev;
 }
 
+static inline struct neigh_parms *__in6_dev_nd_parms_get_rcu(const struct net_device *dev)
+{
+	struct inet6_dev *idev = __in6_dev_get(dev);
+
+	return idev ? idev->nd_parms : NULL;
+}
+
 void in6_dev_finish_destroy(struct inet6_dev *idev);
 
 static inline void in6_dev_put(struct inet6_dev *idev)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c4a7879..ce2b775 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -39,6 +39,7 @@
 #include <linux/string.h>
 #include <linux/log2.h>
 #include <linux/inetdevice.h>
+#include <net/addrconf.h>
 
 #define DEBUG
 #define NEIGH_DEBUG 1
@@ -2819,8 +2820,12 @@ static int proc_unres_qlen(struct ctl_table *ctl, int write,
 static struct neigh_parms *neigh_get_dev_parms_rcu(struct net_device *dev,
 						   int family)
 {
-	if (family == AF_INET)
+	switch (family) {
+	case AF_INET:
 		return __in_dev_arp_parms_get_rcu(dev);
+	case AF_INET6:
+		return __in6_dev_nd_parms_get_rcu(dev);
+	}
 	return NULL;
 }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b05ad8..be7a83f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -834,6 +834,8 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		goto out;
 	}
 
+	neigh_parms_data_state_setall(idev->nd_parms);
+
 	ifa->addr = *addr;
 	if (peer_addr)
 		ifa->peer_addr = *peer_addr;
-- 
1.8.3.1
