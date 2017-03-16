From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 3/9] net, ipv6: convert inet6_ifaddr.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:25 +0200
Message-ID: <1489688611-4542-4-git-send-email-elena.reshetova@intel.com>
References: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        steffen.klassert@secunet.com, kuznet@ms2.inr.ac.ru,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489688611-4542-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 include/net/addrconf.h | 6 +++---
 include/net/if_inet6.h | 2 +-
 net/ipv6/addrconf.c    | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index e5704b9..7b2fdd4 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -326,18 +326,18 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp);
 
 static inline void in6_ifa_put(struct inet6_ifaddr *ifp)
 {
-	if (atomic_dec_and_test(&ifp->refcnt))
+	if (refcount_dec_and_test(&ifp->refcnt))
 		inet6_ifa_finish_destroy(ifp);
 }
 
 static inline void __in6_ifa_put(struct inet6_ifaddr *ifp)
 {
-	atomic_dec(&ifp->refcnt);
+	refcount_dec(&ifp->refcnt);
 }
 
 static inline void in6_ifa_hold(struct inet6_ifaddr *ifp)
 {
-	atomic_inc(&ifp->refcnt);
+	refcount_inc(&ifp->refcnt);
 }
 
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index e7a17b2..2b41cb8 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -46,7 +46,7 @@ struct inet6_ifaddr {
 	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
 	__u32			valid_lft;
 	__u32			prefered_lft;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	spinlock_t		lock;
 
 	int			state;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a2ce7666..94f45dc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1011,7 +1011,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->idev = idev;
 	in6_dev_hold(idev);
 	/* For caller */
-	in6_ifa_hold(ifa);
+	refcount_set(&ifa->refcnt, 1);
 
 	/* Add to big hash table */
 	hash = inet6_addr_hash(addr);
-- 
2.7.4
