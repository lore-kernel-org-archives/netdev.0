From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check kmalloc()
 return value.
Date: Mon, 12 Mar 2007 14:15:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703121411170.13933@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit2030@gmail.com, linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965764AbXCLMPW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/9/07, David Miller <davem@davemloft.net> wrote:
> The whole cahce-multipath subsystem has to have it's guts revamped for
> proper error handling.

(Untested patch follows.)

From: Amit Choudhary <amit2030@gmail.com>

Check the return value of kmalloc() in function wrandom_set_nhinfo(),
in file net/ipv4/multipath_wrandom.c.

[penberg@cs.helsinki.fi: return error status to caller.]
Signed-off-by: Amit Choudhary <amit2030@gmail.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/net/ip_mp_alg.h      |    8 +++++---
 net/ipv4/multipath_wrandom.c |   19 +++++++++++++++----
 net/ipv4/route.c             |    9 +++++++--
 3 files changed, 27 insertions(+), 9 deletions(-)

Index: 2.6/include/net/ip_mp_alg.h
===================================================================
--- 2.6.orig/include/net/ip_mp_alg.h	2007-03-12 14:00:13.000000000 +0200
+++ 2.6/include/net/ip_mp_alg.h	2007-03-12 14:03:10.000000000 +0200
@@ -17,7 +17,7 @@ struct ip_mp_alg_ops {
 	void	(*mp_alg_select_route)(const struct flowi *flp,
 				       struct rtable *rth, struct rtable **rp);
 	void	(*mp_alg_flush)(void);
-	void	(*mp_alg_set_nhinfo)(__be32 network, __be32 netmask,
+	int	(*mp_alg_set_nhinfo)(__be32 network, __be32 netmask,
 				     unsigned char prefixlen,
 				     const struct fib_nh *nh);
 	void	(*mp_alg_remove)(struct rtable *rth);
@@ -58,17 +58,19 @@ static inline void multipath_flush(void)
 #endif
 }
 
-static inline void multipath_set_nhinfo(struct rtable *rth,
+static inline int multipath_set_nhinfo(struct rtable *rth,
 					__be32 network, __be32 netmask,
 					unsigned char prefixlen,
 					const struct fib_nh *nh)
 {
+	int err = 0;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	struct ip_mp_alg_ops *ops = ip_mp_alg_table[rth->rt_multipath_alg];
 
 	if (ops && ops->mp_alg_set_nhinfo)
-		ops->mp_alg_set_nhinfo(network, netmask, prefixlen, nh);
+		err = ops->mp_alg_set_nhinfo(network, netmask, prefixlen, nh);
 #endif
+	return err;
 }
 
 static inline void multipath_remove(struct rtable *rth)
Index: 2.6/net/ipv4/multipath_wrandom.c
===================================================================
--- 2.6.orig/net/ipv4/multipath_wrandom.c	2007-03-12 14:00:33.000000000 +0200
+++ 2.6/net/ipv4/multipath_wrandom.c	2007-03-12 14:02:17.000000000 +0200
@@ -216,14 +216,15 @@ 	last_power = 0;
 	*rp = decision;
 }
 
-static void wrandom_set_nhinfo(__be32 network,
-			       __be32 netmask,
-			       unsigned char prefixlen,
-			       const struct fib_nh *nh)
+static int wrandom_set_nhinfo(__be32 network,
+			      __be32 netmask,
+			      unsigned char prefixlen,
+			      const struct fib_nh *nh)
 {
 	const int state_idx = nh->nh_oif % MULTIPATH_STATE_SIZE;
 	struct multipath_route *r, *target_route = NULL;
 	struct multipath_dest *d, *target_dest = NULL;
+	int err = 0;
 
 	/* store the weight information for a certain route */
 	spin_lock_bh(&state[state_idx].lock);
@@ -240,6 +241,10 @@ static void wrandom_set_nhinfo(__be32 ne
 		const size_t size_rt = sizeof(struct multipath_route);
 		target_route = (struct multipath_route *)
 			kmalloc(size_rt, GFP_ATOMIC);
+		if (!target_route) {
+			err = -ENOMEM;
+			goto error;
+		}
 
 		target_route->gw = nh->nh_gw;
 		target_route->oif = nh->nh_oif;
@@ -262,6 +267,10 @@ 		memset(&target_route->rcu, 0, sizeof(s
 		target_dest = (struct multipath_dest*)
 			kmalloc(size_dst, GFP_ATOMIC);
 
+		if (!target_dest) {
+			err = -ENOMEM;
+			goto error;
+		}
 		target_dest->nh_info = nh;
 		target_dest->network = network;
 		target_dest->netmask = netmask;
@@ -275,6 +284,8 @@ 		memset(&target_dest->rcu, 0, sizeof(st
 	 */
 
 	spin_unlock_bh(&state[state_idx].lock);
+  error:
+	return err;
 }
 
 static void __multipath_free(struct rcu_head *head)
Index: 2.6/net/ipv4/route.c
===================================================================
--- 2.6.orig/net/ipv4/route.c	2007-03-12 14:03:24.000000000 +0200
+++ 2.6/net/ipv4/route.c	2007-03-12 14:04:16.000000000 +0200
@@ -1880,11 +1880,13 @@ 	for (hop = 0; hop < hopcount; hop++) {
 			return err;
 
 		/* forward hop information to multipath impl. */
-		multipath_set_nhinfo(rth,
+		err = multipath_set_nhinfo(rth,
 				     FIB_RES_NETWORK(*res),
 				     FIB_RES_NETMASK(*res),
 				     res->prefixlen,
 				     &FIB_RES_NH(*res));
+		if (err)
+			return err;
 	}
 	skb->dst = &rtres->u.dst;
 	return err;
@@ -2334,8 +2336,11 @@ 			if (err != 0)
 					oldflp->oif);
 			err = rt_intern_hash(hash, rth, rp);
 
+			if (err != 0)
+				goto cleanup;
+
 			/* forward hop information to multipath impl. */
-			multipath_set_nhinfo(rth,
+			err = multipath_set_nhinfo(rth,
 					     FIB_RES_NETWORK(*res),
 					     FIB_RES_NETMASK(*res),
 					     res->prefixlen,
