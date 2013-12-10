From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] ipv6: router reachability probing
Date: Tue, 10 Dec 2013 17:15:44 +0100
Message-ID: <ce8e9118b640b938048aaf18b59e998d46ab400e.1386692051.git.jbenc@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422Ab3LJQQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 11:16:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4191 states in 3.5:

   When a host avoids using any non-reachable router X and instead sends
   a data packet to another router Y, and the host would have used
   router X if router X were reachable, then the host SHOULD probe each
   such router X's reachability by sending a single Neighbor
   Solicitation to that router's address.  A host MUST NOT probe a
   router's reachability in the absence of useful traffic that the host
   would have sent to the router if it were reachable.  In any case,
   these probes MUST be rate-limited to no more than one per minute per
   router.

Currently, when the neighbour corresponding to a router falls into
NUD_FAILED, it's never considered again. Introduce a new rt6_nud_state
value, RT6_NUD_FAIL_PROBE, which suggests the route should not be used but
should be probed with a single NS. The probe is ratelimited by the existing
code. To better distinguish meanings of the failure values, rename
RT6_NUD_FAIL_SOFT to RT6_NUD_FAIL_DO_RR.

We also need to accept NAs when in NUD_FAILED state.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
I admit I'm not much sure about the removal of the NUD_FAILED check in
ndisc_recv_na. I can't find anything in RFC 4861 nor in RFC 4191 which would
prohibit taking the neighbor entry out of failed state if a NA is received.
I also cannot find any place where such change would cause problems in the
kernel, but I may have easily overlooked something. Comments are welcome.
---
 net/ipv6/ndisc.c |    3 ---
 net/ipv6/route.c |   14 +++++++++-----
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 09a22f4f36c9..faf67efc4c99 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -918,9 +918,6 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		u8 old_flags = neigh->flags;
 		struct net *net = dev_net(dev);
 
-		if (neigh->nud_state & NUD_FAILED)
-			goto out;
-
 		/*
 		 * Don't update the neighbor cache entry on a proxy NA from
 		 * ourselves because either the proxied node is off link or it
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ddb9d41c8eea..147c39f7f70d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -66,8 +66,9 @@
 #endif
 
 enum rt6_nud_state {
-	RT6_NUD_FAIL_HARD = -2,
-	RT6_NUD_FAIL_SOFT = -1,
+	RT6_NUD_FAIL_HARD = -3,
+	RT6_NUD_FAIL_PROBE = -2,
+	RT6_NUD_FAIL_DO_RR = -1,
 	RT6_NUD_SUCCEED = 1
 };
 
@@ -577,11 +578,13 @@ static inline enum rt6_nud_state rt6_check_neigh(struct rt6_info *rt)
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		else if (!(neigh->nud_state & NUD_FAILED))
 			ret = RT6_NUD_SUCCEED;
+		else
+			ret = RT6_NUD_FAIL_PROBE;
 #endif
 		read_unlock(&neigh->lock);
 	} else {
 		ret = IS_ENABLED(CONFIG_IPV6_ROUTER_PREF) ?
-		      RT6_NUD_SUCCEED : RT6_NUD_FAIL_SOFT;
+		      RT6_NUD_SUCCEED : RT6_NUD_FAIL_DO_RR;
 	}
 	rcu_read_unlock_bh();
 
@@ -618,16 +621,17 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 		goto out;
 
 	m = rt6_score_route(rt, oif, strict);
-	if (m == RT6_NUD_FAIL_SOFT) {
+	if (m == RT6_NUD_FAIL_DO_RR) {
 		match_do_rr = true;
 		m = 0; /* lowest valid score */
-	} else if (m < 0) {
+	} else if (m == RT6_NUD_FAIL_HARD) {
 		goto out;
 	}
 
 	if (strict & RT6_LOOKUP_F_REACHABLE)
 		rt6_probe(rt);
 
+	/* note that m can be RT6_NUD_FAIL_PROBE at this point */
 	if (m > *mpri) {
 		*do_rr = match_do_rr;
 		*mpri = m;
-- 
1.7.6.5
