From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/17] inet: constify ip_route_output_flow() socket argument
Date: Fri, 25 Sep 2015 07:39:10 -0700
Message-ID: <1443191964-923-4-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35452 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:39:54 -0400
Received: by pacfv12 with SMTP id fv12so109572033pac.2
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:39:53 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very soon, TCP stack might call inet_csk_route_req(), which
calls inet_csk_route_req() with an unlocked listener socket,
so we need to make sure ip_route_output_flow() is not trying to
change any field from its socket argument.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/dst.h      | 9 +++++----
 include/net/route.h    | 2 +-
 net/ipv4/route.c       | 2 +-
 net/xfrm/xfrm_policy.c | 6 +++---
 4 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index df0481a07029..779206c15f8b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -489,7 +489,8 @@ struct flowi;
 #ifndef CONFIG_XFRM
 static inline struct dst_entry *xfrm_lookup(struct net *net,
 					    struct dst_entry *dst_orig,
-					    const struct flowi *fl, struct sock *sk,
+					    const struct flowi *fl,
+					    const struct sock *sk,
 					    int flags)
 {
 	return dst_orig;
@@ -498,7 +499,7 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 static inline struct dst_entry *xfrm_lookup_route(struct net *net,
 						  struct dst_entry *dst_orig,
 						  const struct flowi *fl,
-						  struct sock *sk,
+						  const struct sock *sk,
 						  int flags)
 {
 	return dst_orig;
@@ -511,11 +512,11 @@ static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 
 #else
 struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
-			      const struct flowi *fl, struct sock *sk,
+			      const struct flowi *fl, const struct sock *sk,
 			      int flags);
 
 struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
-				    const struct flowi *fl, struct sock *sk,
+				    const struct flowi *fl, const struct sock *sk,
 				    int flags);
 
 /* skb attached with this dst needs transformation if dst->xfrm is valid */
diff --git a/include/net/route.h b/include/net/route.h
index 10a7d21a211c..414beadc619f 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -114,7 +114,7 @@ void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
 struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
-				    struct sock *sk);
+				    const struct sock *sk);
 struct dst_entry *ipv4_blackhole_route(struct net *net,
 				       struct dst_entry *dst_orig);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 80f7c5b7b832..f7afcba8b1a1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2291,7 +2291,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 }
 
 struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
-				    struct sock *sk)
+				    const struct sock *sk)
 {
 	struct rtable *rt = __ip_route_output_key(net, flp4);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e7f64bcb78a8..418daa038edf 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1208,7 +1208,7 @@ static inline int policy_to_flow_dir(int dir)
 	}
 }
 
-static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir,
+static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 						 const struct flowi *fl)
 {
 	struct xfrm_policy *pol;
@@ -2185,7 +2185,7 @@ static struct dst_entry *make_blackhole(struct net *net, u16 family,
  */
 struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			      const struct flowi *fl,
-			      struct sock *sk, int flags)
+			      const struct sock *sk, int flags)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	struct flow_cache_object *flo;
@@ -2333,7 +2333,7 @@ EXPORT_SYMBOL(xfrm_lookup);
  */
 struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
 				    const struct flowi *fl,
-				    struct sock *sk, int flags)
+				    const struct sock *sk, int flags)
 {
 	struct dst_entry *dst = xfrm_lookup(net, dst_orig, fl, sk,
 					    flags | XFRM_LOOKUP_QUEUE |
-- 
2.6.0.rc2.230.g3dd15c0
