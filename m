From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 39/44] [XFRM] POLICY: Add Kconfig to support sub policy.
Date: Wed, 23 Aug 2006 22:41:59 -0700 (PDT)
Message-ID: <20060823.224159.83620135.davem@davemloft.net>
References: <11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453671463-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453672872-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13992
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030310AbWHXFl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 01:41:57 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453672872-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:40 +0900

> Add Kconfig to support sub policy.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19

Note that sub-policy support is probably the area which will
need some simplifications and refactoring.

It is clear that IPSEC performance is tied strictly to the
speed at which routes can be resolved.  Sub-policies add more
overhead to this area.

We wish to push fully resolved IPSEC routes into the flow cache so
that we got not only policy but pre-lookup of bundle entry as a result
of lookup.  I attach an example patch implementing that (it is
relative to the tree before all the MIPV6 changes) to give you an
idea.

Also, if sub-policies are really the final way to address the
MIPV6+IPSEC separation issue, probably we should just kill the
kernel config option and optimize it as best we can.

diff --git a/include/net/flow.h b/include/net/flow.h
index 04d89f7..ce0e1a8 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -84,12 +84,16 @@ #define FLOW_DIR_IN	0
 #define FLOW_DIR_OUT	1
 #define FLOW_DIR_FWD	2
 
-struct sock;
 typedef void (*flow_resolve_t)(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
 			       void **objp, atomic_t **obj_refp);
 
-extern void *flow_cache_lookup(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
-	 		       flow_resolve_t resolver);
+struct dst_entry;
+extern void *flow_cache_lookup(struct flowi *key, u32 sk_sid,
+			       u16 family, u8 dir,
+			       struct dst_entry **dstp,
+			       flow_resolve_t resolver);
+extern void flow_cache_dst_set(struct flowi *key, u32 sk_sid,
+			       u16 family, u8 dir, struct dst_entry *dst);
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
diff --git a/net/core/flow.c b/net/core/flow.c
index 2191af5..7949020 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -25,6 +25,7 @@ #include <net/flow.h>
 #include <asm/atomic.h>
 #include <asm/semaphore.h>
 #include <linux/security.h>
+#include <net/dst.h>
 
 struct flow_cache_entry {
 	struct flow_cache_entry	*next;
@@ -35,6 +36,7 @@ struct flow_cache_entry {
 	u32			sk_sid;
 	void			*object;
 	atomic_t		*object_ref;
+	struct dst_entry	*dst;
 };
 
 atomic_t flow_cache_genid = ATOMIC_INIT(0);
@@ -166,7 +168,7 @@ static int flow_key_compare(struct flowi
 }
 
 void *flow_cache_lookup(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
-			flow_resolve_t resolver)
+			struct dst_entry **dstp, flow_resolve_t resolver)
 {
 	struct flow_cache_entry *fle, **head;
 	unsigned int hash;
@@ -196,6 +198,8 @@ void *flow_cache_lookup(struct flowi *ke
 
 				if (ret)
 					atomic_inc(fle->object_ref);
+				if (dstp)
+					*dstp = dst_clone(fle->dst);
 				local_bh_enable();
 
 				return ret;
@@ -217,6 +221,7 @@ void *flow_cache_lookup(struct flowi *ke
 			fle->sk_sid = sk_sid;
 			memcpy(&fle->key, key, sizeof(*key));
 			fle->object = NULL;
+			fle->dst = NULL;
 			flow_count(cpu)++;
 		}
 	}
@@ -245,6 +250,34 @@ nocache:
 	}
 }
 
+void flow_cache_dst_set(struct flowi *key, u32 sk_sid, u16 family, u8 dir,
+			struct dst_entry *dst)
+{
+	struct flow_cache_entry *fle, **head;
+	unsigned int hash;
+	int cpu;
+
+	local_bh_disable();
+	cpu = smp_processor_id();
+	hash = flow_hash_code(key, cpu);
+	head = &flow_table(cpu)[hash];
+	for (fle = *head; fle; fle = fle->next) {
+		if (fle->family == family &&
+		    fle->dir == dir &&
+		    fle->sk_sid == sk_sid &&
+		    flow_key_compare(key, &fle->key) == 0) {
+			if (fle->genid == atomic_read(&flow_cache_genid)) {
+				struct dst_entry *orig = fle->dst;
+
+				dst_release(orig);
+				fle->dst = dst_clone(dst);
+			}
+			break;
+		}
+	}
+	local_bh_enable();
+}
+
 static void flow_cache_flush_tasklet(unsigned long data)
 {
 	struct flow_flush_info *info = (void *)data;
@@ -264,6 +297,8 @@ static void flow_cache_flush_tasklet(uns
 
 			fle->object = NULL;
 			atomic_dec(fle->object_ref);
+			dst_release(fle->dst);
+			fle->dst = NULL;
 		}
 	}
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 554f0db..2d4cab5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1149,7 +1149,7 @@ int xfrm_lookup(struct dst_entry **dst_p
 	struct xfrm_state *xfrm[XFRM_MAX_DEPTH];
 	struct dst_entry *dst, *dst_orig = *dst_p;
 	int nx = 0;
-	int err;
+	int err, sock_policy;
 	u32 genid;
 	u16 family;
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
@@ -1157,16 +1157,21 @@ int xfrm_lookup(struct dst_entry **dst_p
 restart:
 	genid = atomic_read(&flow_cache_genid);
 	policy = NULL;
-	if (sk && sk->sk_policy[1])
+	sock_policy = 0;
+	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		policy = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl, sk_sid);
+		if (policy)
+			sock_policy = 1;
+	}
 
+	dst = NULL;
 	if (!policy) {
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_count[XFRM_POLICY_OUT])
 			return 0;
 
 		policy = flow_cache_lookup(fl, sk_sid, dst_orig->ops->family,
-					   dir, xfrm_policy_lookup);
+					   dir, &dst, xfrm_policy_lookup);
 	}
 
 	if (!policy)
@@ -1179,6 +1184,7 @@ restart:
 	case XFRM_POLICY_BLOCK:
 		/* Prohibit the flow */
 		err = -EPERM;
+		dst_release(dst);
 		goto error;
 
 	case XFRM_POLICY_ALLOW:
@@ -1188,6 +1194,14 @@ restart:
 			return 0;
 		}
 
+		/* Cached dst from flow cache?  */
+		if (dst) {
+			if (likely(!stale_bundle(dst)))
+				break;
+			dst_release(dst);
+			flow_cache_dst_set(fl, sk_sid, family, dir, NULL);
+		}
+
 		/* Try to find matching bundle.
 		 *
 		 * LATER: help from flow cache. It is optional, this
@@ -1199,8 +1213,11 @@ restart:
 			goto error;
 		}
 
-		if (dst)
+		if (dst) {
+			if (!sock_policy)
+				flow_cache_dst_set(fl, sk_sid, family, dir, dst);
 			break;
+		}
 
 		nx = xfrm_tmpl_resolve(policy, fl, xfrm, family);
 
@@ -1265,6 +1282,8 @@ restart:
 		policy->bundles = dst;
 		dst_hold(dst);
 		write_unlock_bh(&policy->lock);
+		if (!sock_policy)
+			flow_cache_dst_set(fl, sk_sid, family, dir, dst);
 	}
 	*dst_p = dst;
 	dst_release(dst_orig);
@@ -1374,7 +1393,7 @@ int __xfrm_policy_check(struct sock *sk,
 
 	if (!pol)
 		pol = flow_cache_lookup(&fl, sk_sid, family, fl_dir,
-					xfrm_policy_lookup);
+					NULL, xfrm_policy_lookup);
 
 	if (!pol)
 		return !skb->sp || !secpath_has_tunnel(skb->sp, 0);

