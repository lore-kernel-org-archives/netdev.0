From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 4/4] sch_sfb: use skb_flow_dissect()
Date: Mon, 28 Nov 2011 16:25:02 +0100
Message-ID: <1322493902.2292.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Dan Siemon <dan-BZ4SNL/Vixll57MIdRCFDg@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Current SFB double hashing is not fulfilling SFB theory, if two flows
share same rxhash value.

Using skb_flow_dissect() permits to really have better hash dispersion,
and get tunnelling support as well.

Double hashing point was mentioned by Florian Westphal

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/sched/sch_sfb.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index e83c272..96e42ca 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -26,6 +26,7 @@
 #include <net/ip.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
+#include <net/flow_keys.h>
 
 /*
  * SFB uses two B[l][n] : L x N arrays of bins (L levels, N bins per level)
@@ -286,6 +287,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	u32 minqlen = ~0;
 	u32 r, slot, salt, sfbhash;
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	struct flow_keys keys;
 
 	if (unlikely(sch->q.qlen >= q->limit)) {
 		sch->qstats.overlimits++;
@@ -309,13 +311,19 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		/* If using external classifiers, get result and record it. */
 		if (!sfb_classify(skb, q, &ret, &salt))
 			goto other_drop;
+		keys.src = salt;
+		keys.dst = 0;
+		keys.ports = 0;
 	} else {
-		salt = skb_get_rxhash(skb);
+		skb_flow_dissect(skb, &keys);
 	}
 
 	slot = q->slot;
 
-	sfbhash = jhash_1word(salt, q->bins[slot].perturbation);
+	sfbhash = jhash_3words((__force u32)keys.dst,
+			       (__force u32)keys.src,
+			       (__force u32)keys.ports,
+			       q->bins[slot].perturbation);
 	if (!sfbhash)
 		sfbhash = 1;
 	sfb_skb_cb(skb)->hashes[slot] = sfbhash;
@@ -347,7 +355,10 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(p_min >= SFB_MAX_PROB)) {
 		/* Inelastic flow */
 		if (q->double_buffering) {
-			sfbhash = jhash_1word(salt, q->bins[slot].perturbation);
+			sfbhash = jhash_3words((__force u32)keys.dst,
+					       (__force u32)keys.src,
+					       (__force u32)keys.ports,
+					       q->bins[slot].perturbation);
 			if (!sfbhash)
 				sfbhash = 1;
 			sfb_skb_cb(skb)->hashes[slot] = sfbhash;
