From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 1/9] net, ipv6: convert ipv6_txoptions.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:23 +0200
Message-ID: <1489688611-4542-2-git-send-email-elena.reshetova@intel.com>
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
 include/net/ipv6.h       | 7 ++++---
 net/ipv6/exthdrs.c       | 4 ++--
 net/ipv6/ipv6_sockglue.c | 2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dbf0abb..125e44a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -16,6 +16,7 @@
 #include <linux/ipv6.h>
 #include <linux/hardirq.h>
 #include <linux/jhash.h>
+#include <linux/refcount.h>
 #include <net/if_inet6.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
@@ -203,7 +204,7 @@ extern rwlock_t ip6_ra_lock;
  */
 
 struct ipv6_txoptions {
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	/* Length of this structure */
 	int			tot_len;
 
@@ -265,7 +266,7 @@ static inline struct ipv6_txoptions *txopt_get(const struct ipv6_pinfo *np)
 	rcu_read_lock();
 	opt = rcu_dereference(np->opt);
 	if (opt) {
-		if (!atomic_inc_not_zero(&opt->refcnt))
+		if (!refcount_inc_not_zero(&opt->refcnt))
 			opt = NULL;
 		else
 			opt = rcu_pointer_handoff(opt);
@@ -276,7 +277,7 @@ static inline struct ipv6_txoptions *txopt_get(const struct ipv6_pinfo *np)
 
 static inline void txopt_put(struct ipv6_txoptions *opt)
 {
-	if (opt && atomic_dec_and_test(&opt->refcnt))
+	if (opt && refcount_dec_and_test(&opt->refcnt))
 		kfree_rcu(opt, rcu);
 }
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 275cac6..a645173 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -970,7 +970,7 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
 			*((char **)&opt2->dst1opt) += dif;
 		if (opt2->srcrt)
 			*((char **)&opt2->srcrt) += dif;
-		atomic_set(&opt2->refcnt, 1);
+		refcount_set(&opt2->refcnt, 1);
 	}
 	return opt2;
 }
@@ -1055,7 +1055,7 @@ ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
 		return ERR_PTR(-ENOBUFS);
 
 	memset(opt2, 0, tot_len);
-	atomic_set(&opt2->refcnt, 1);
+	refcount_set(&opt2->refcnt, 1);
 	opt2->tot_len = tot_len;
 	p = (char *)(opt2 + 1);
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a531ba0..85404e7 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -505,7 +505,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			break;
 
 		memset(opt, 0, sizeof(*opt));
-		atomic_set(&opt->refcnt, 1);
+		refcount_set(&opt->refcnt, 1);
 		opt->tot_len = sizeof(*opt) + optlen;
 		retv = -EFAULT;
 		if (copy_from_user(opt+1, optval, optlen))
-- 
2.7.4
