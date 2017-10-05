From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] xfrm: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:50:38 -0700
Message-ID: <20171005005038.GA23276@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
helper to pass the timer pointer explicitly.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/xfrm/xfrm_policy.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f06253969972..4838329bb43a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -57,7 +57,7 @@ static __read_mostly seqcount_t xfrm_policy_hash_generation;
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_dst *xdst);
-static void xfrm_policy_queue_process(unsigned long arg);
+static void xfrm_policy_queue_process(struct timer_list *t);
 
 static void __xfrm_policy_link(struct xfrm_policy *pol, int dir);
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
@@ -179,9 +179,9 @@ static inline unsigned long make_jiffies(long secs)
 		return secs*HZ;
 }
 
-static void xfrm_policy_timer(unsigned long data)
+static void xfrm_policy_timer(struct timer_list *t)
 {
-	struct xfrm_policy *xp = (struct xfrm_policy *)data;
+	struct xfrm_policy *xp = from_timer(xp, t, timer);
 	unsigned long now = get_seconds();
 	long next = LONG_MAX;
 	int warn = 0;
@@ -267,10 +267,9 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 		rwlock_init(&policy->lock);
 		refcount_set(&policy->refcnt, 1);
 		skb_queue_head_init(&policy->polq.hold_queue);
-		setup_timer(&policy->timer, xfrm_policy_timer,
-				(unsigned long)policy);
-		setup_timer(&policy->polq.hold_timer, xfrm_policy_queue_process,
-			    (unsigned long)policy);
+		timer_setup(&policy->timer, xfrm_policy_timer, 0);
+		timer_setup(&policy->polq.hold_timer,
+			    xfrm_policy_queue_process, 0);
 	}
 	return policy;
 }
@@ -1852,12 +1851,12 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 	return xdst;
 }
 
-static void xfrm_policy_queue_process(unsigned long arg)
+static void xfrm_policy_queue_process(struct timer_list *t)
 {
 	struct sk_buff *skb;
 	struct sock *sk;
 	struct dst_entry *dst;
-	struct xfrm_policy *pol = (struct xfrm_policy *)arg;
+	struct xfrm_policy *pol = from_timer(pol, t, polq.hold_timer);
 	struct net *net = xp_net(pol);
 	struct xfrm_policy_queue *pq = &pol->polq;
 	struct flowi fl;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
