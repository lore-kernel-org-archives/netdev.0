From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 2/9] net, ipv6: convert inet6_dev.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:24 +0200
Message-ID: <1489688611-4542-3-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:49104 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752856AbdCPSX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 14:23:58 -0400
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/addrconf.h | 8 ++++----
 include/net/if_inet6.h | 3 ++-
 net/ipv6/addrconf.c    | 2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 17c6fd8..e5704b9 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -292,7 +292,7 @@ static inline struct inet6_dev *in6_dev_get(const struct net_device *dev)
 	rcu_read_lock();
 	idev = rcu_dereference(dev->ip6_ptr);
 	if (idev)
-		atomic_inc(&idev->refcnt);
+		refcount_inc(&idev->refcnt);
 	rcu_read_unlock();
 	return idev;
 }
@@ -308,18 +308,18 @@ void in6_dev_finish_destroy(struct inet6_dev *idev);
 
 static inline void in6_dev_put(struct inet6_dev *idev)
 {
-	if (atomic_dec_and_test(&idev->refcnt))
+	if (refcount_dec_and_test(&idev->refcnt))
 		in6_dev_finish_destroy(idev);
 }
 
 static inline void __in6_dev_put(struct inet6_dev *idev)
 {
-	atomic_dec(&idev->refcnt);
+	refcount_dec(&idev->refcnt);
 }
 
 static inline void in6_dev_hold(struct inet6_dev *idev)
 {
-	atomic_inc(&idev->refcnt);
+	refcount_inc(&idev->refcnt);
 }
 
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp);
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index f656f90..e7a17b2 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -17,6 +17,7 @@
 
 #include <net/snmp.h>
 #include <linux/ipv6.h>
+#include <linux/refcount.h>
 
 /* inet6_dev.if_flags */
 
@@ -187,7 +188,7 @@ struct inet6_dev {
 
 	struct ifacaddr6	*ac_list;
 	rwlock_t		lock;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	__u32			if_flags;
 	int			dead;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a2025f..a2ce7666 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -421,7 +421,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	}
 
 	/* One reference from device. */
-	in6_dev_hold(ndev);
+	refcount_set(&ndev->refcnt, 1);
 
 	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
 		ndev->cnf.accept_dad = -1;
-- 
2.7.4
