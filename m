From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 11/17] net: convert netpoll_info.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:29:01 +0200
Message-ID: <1489678147-21404-12-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:38188 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754797AbdCPPaF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 11:30:05 -0400
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
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
 include/linux/netpoll.h | 3 ++-
 net/core/netpoll.c      | 6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 1828900..27c0aaa 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -11,6 +11,7 @@
 #include <linux/interrupt.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
+#include <linux/refcount.h>
 
 union inet_addr {
 	__u32		all[4];
@@ -34,7 +35,7 @@ struct netpoll {
 };
 
 struct netpoll_info {
-	atomic_t refcnt;
+	refcount_t refcnt;
 
 	struct semaphore dev_lock;
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 891d88e..8b9083d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -626,7 +626,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
 
-		atomic_set(&npinfo->refcnt, 1);
+		refcount_set(&npinfo->refcnt, 1);
 
 		ops = np->dev->netdev_ops;
 		if (ops->ndo_netpoll_setup) {
@@ -636,7 +636,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 		}
 	} else {
 		npinfo = rtnl_dereference(ndev->npinfo);
-		atomic_inc(&npinfo->refcnt);
+		refcount_inc(&npinfo->refcnt);
 	}
 
 	npinfo->netpoll = np;
@@ -815,7 +815,7 @@ void __netpoll_cleanup(struct netpoll *np)
 
 	synchronize_srcu(&netpoll_srcu);
 
-	if (atomic_dec_and_test(&npinfo->refcnt)) {
+	if (refcount_dec_and_test(&npinfo->refcnt)) {
 		const struct net_device_ops *ops;
 
 		ops = np->dev->netdev_ops;
-- 
2.7.4
