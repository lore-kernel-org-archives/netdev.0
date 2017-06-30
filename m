From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 15/17] net: convert net.passive from atomic_t to refcount_t
Date: Fri, 30 Jun 2017 13:08:08 +0300
Message-ID: <1498817290-3368-16-git-send-email-elena.reshetova@intel.com>
References: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498817290-3368-1-git-send-email-elena.reshetova@intel.com>
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
 include/net/net_namespace.h | 3 ++-
 net/core/net-sysfs.c        | 2 +-
 net/core/net_namespace.c    | 4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index fe80bb4..bffe0a3 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -5,6 +5,7 @@
 #define __NET_NET_NAMESPACE_H
 
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <linux/workqueue.h>
 #include <linux/list.h>
 #include <linux/sysctl.h>
@@ -46,7 +47,7 @@ struct netns_ipvs;
 #define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
 
 struct net {
-	atomic_t		passive;	/* To decided when the network
+	refcount_t		passive;	/* To decided when the network
 						 * namespace should be freed.
 						 */
 	atomic_t		count;		/* To decided when the network
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index fe7e145..b4f9922 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1448,7 +1448,7 @@ static void *net_grab_current_ns(void)
 	struct net *ns = current->nsproxy->net_ns;
 #ifdef CONFIG_NET_NS
 	if (ns)
-		atomic_inc(&ns->passive);
+		refcount_inc(&ns->passive);
 #endif
 	return ns;
 }
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2178db8..57feb1e 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -284,7 +284,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	LIST_HEAD(net_exit_list);
 
 	atomic_set(&net->count, 1);
-	atomic_set(&net->passive, 1);
+	refcount_set(&net->passive, 1);
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
 	idr_init(&net->netns_ids);
@@ -380,7 +380,7 @@ static void net_free(struct net *net)
 void net_drop_ns(void *p)
 {
 	struct net *ns = p;
-	if (ns && atomic_dec_and_test(&ns->passive))
+	if (ns && refcount_dec_and_test(&ns->passive))
 		net_free(ns);
 }
 
-- 
2.7.4
