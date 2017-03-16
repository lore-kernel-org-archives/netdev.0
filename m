From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 7/9] net, ipv6: convert ip6addrlbl_entry.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 20:23:29 +0200
Message-ID: <1489688611-4542-8-git-send-email-elena.reshetova@intel.com>
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
 net/ipv6/addrlabel.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index a8f6986..9340804 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -18,6 +18,7 @@
 #include <linux/if_addrlabel.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/refcount.h>
 
 #if 0
 #define ADDRLABEL(x...) printk(x)
@@ -36,7 +37,7 @@ struct ip6addrlbl_entry {
 	int addrtype;
 	u32 label;
 	struct hlist_node list;
-	atomic_t refcnt;
+	refcount_t refcnt;
 	struct rcu_head rcu;
 };
 
@@ -137,12 +138,12 @@ static void ip6addrlbl_free_rcu(struct rcu_head *h)
 
 static bool ip6addrlbl_hold(struct ip6addrlbl_entry *p)
 {
-	return atomic_inc_not_zero(&p->refcnt);
+	return refcount_inc_not_zero(&p->refcnt);
 }
 
 static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
 {
-	if (atomic_dec_and_test(&p->refcnt))
+	if (refcount_dec_and_test(&p->refcnt))
 		call_rcu(&p->rcu, ip6addrlbl_free_rcu);
 }
 
@@ -236,7 +237,7 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
 	write_pnet(&newp->lbl_net, net);
-	atomic_set(&newp->refcnt, 1);
+	refcount_set(&newp->refcnt, 1);
 	return newp;
 }
 
-- 
2.7.4
