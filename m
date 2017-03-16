From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 13/17] net: convert fib_rule.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:29:03 +0200
Message-ID: <1489678147-21404-14-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
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
 include/net/fib_rules.h | 7 ++++---
 net/core/fib_rules.c    | 4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 8dbfdf7..26ae0ad 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -5,6 +5,7 @@
 #include <linux/slab.h>
 #include <linux/netdevice.h>
 #include <linux/fib_rules.h>
+#include <linux/refcount.h>
 #include <net/flow.h>
 #include <net/rtnetlink.h>
 
@@ -29,7 +30,7 @@ struct fib_rule {
 	struct fib_rule __rcu	*ctarget;
 	struct net		*fr_net;
 
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	u32			pref;
 	int			suppress_ifgroup;
 	int			suppress_prefixlen;
@@ -103,12 +104,12 @@ struct fib_rules_ops {
 
 static inline void fib_rule_get(struct fib_rule *rule)
 {
-	atomic_inc(&rule->refcnt);
+	refcount_inc(&rule->refcnt);
 }
 
 static inline void fib_rule_put(struct fib_rule *rule)
 {
-	if (atomic_dec_and_test(&rule->refcnt))
+	if (refcount_dec_and_test(&rule->refcnt))
 		kfree_rcu(rule, rcu);
 }
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index b6791d9..53d55d5 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -32,7 +32,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	if (r == NULL)
 		return -ENOMEM;
 
-	atomic_set(&r->refcnt, 1);
+	refcount_set(&r->refcnt, 1);
 	r->action = FR_ACT_TO_TBL;
 	r->pref = pref;
 	r->table = table;
@@ -269,7 +269,7 @@ int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
 
 		if (err != -EAGAIN) {
 			if ((arg->flags & FIB_LOOKUP_NOREF) ||
-			    likely(atomic_inc_not_zero(&rule->refcnt))) {
+			    likely(refcount_inc_not_zero(&rule->refcnt))) {
 				arg->rule = rule;
 				goto out;
 			}
-- 
2.7.4
