From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] random32: add prandom_u32_lt_N and convert "misuses" of reciprocal_divide
Date: Thu, 16 Jan 2014 00:23:47 +0100
Message-ID: <1389828228-30312-2-git-send-email-dborkman@redhat.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbaAOXX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:23:59 -0500
In-Reply-To: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many functions have open coded a function that return a random
number in range [0,N-1]. Also, only because we have a function
that is named reciprocal_divide(), it has not much to do with
the pupose where it is being used when a previous reciprocal_value()
has not been obtained.

Under the assumption that we have a PRNG such as taus113 with
being well distributed in [0, ~0U] space, we can implement such
a function as uword t = (n*m')>>32, where m' is a random number
obtained from PRNG, n the right open interval border and t our
resulting random number, with n,m',t in u32 universe.

Other users can further be migrated to the new prandom_u32_lt_N()
function later on; for now, we need to make sure to migrate
"misuses" of reciprocal_divide() for the reciprocal_divide()
follow-up fixup.

Joint work with Hannes Frederic Sowa.

Cc: Jakub Zawadzki <darkjames-ws@darkjames.pl>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/team/team_mode_random.c |  8 +-------
 include/linux/random.h              | 19 ++++++++++++++++++-
 include/net/codel.h                 |  4 +---
 net/packet/af_packet.c              |  5 ++---
 net/sched/sch_choke.c               |  9 +--------
 5 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
index 7f032e2..f2d22a5 100644
--- a/drivers/net/team/team_mode_random.c
+++ b/drivers/net/team/team_mode_random.c
@@ -13,20 +13,14 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/reciprocal_div.h>
 #include <linux/if_team.h>
 
-static u32 random_N(unsigned int N)
-{
-	return reciprocal_divide(prandom_u32(), N);
-}
-
 static bool rnd_transmit(struct team *team, struct sk_buff *skb)
 {
 	struct team_port *port;
 	int port_index;
 
-	port_index = random_N(team->en_port_count);
+	port_index = prandom_u32_lt_N(team->en_port_count);
 	port = team_get_port_by_index_rcu(team, port_index);
 	if (unlikely(!port))
 		goto drop;
diff --git a/include/linux/random.h b/include/linux/random.h
index 4002b3d..cc3f006 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -8,7 +8,6 @@
 
 #include <uapi/linux/random.h>
 
-
 extern void add_device_randomness(const void *, unsigned int);
 extern void add_input_randomness(unsigned int type, unsigned int code,
 				 unsigned int value);
@@ -38,6 +37,24 @@ struct rnd_state {
 u32 prandom_u32_state(struct rnd_state *state);
 void prandom_bytes_state(struct rnd_state *state, void *buf, int nbytes);
 
+/**
+ * prandom_u32_lt_N - returns a random number in interval [0, N), the
+ *                    interval is right-open. This is useful when an
+ *                    requesting random index of an array containing
+ *                    N elements, for example.
+ *
+ * @N: higher interval endpoint
+ *
+ * Returns a pseduo-random number that is in interval [0, N). Note
+ * that the result depends on PRNG being well distributed in [0, ~0U]
+ * space. Here, we use maximally equidistributed combined Tausworthe
+ * generator, that is, prandom_u32().
+ */
+static inline u32 prandom_u32_lt_N(u32 N)
+{
+	return (u32)(((u64) prandom_u32() * N) >> 32);
+}
+
 /*
  * Handle minimum values for seeds
  */
diff --git a/include/net/codel.h b/include/net/codel.h
index 3b04ff5..7705a72 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -46,7 +46,6 @@
 #include <linux/skbuff.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
-#include <linux/reciprocal_div.h>
 
 /* Controlling Queue Delay (CoDel) algorithm
  * =========================================
@@ -211,10 +210,9 @@ static codel_time_t codel_control_law(codel_time_t t,
 				      codel_time_t interval,
 				      u32 rec_inv_sqrt)
 {
-	return t + reciprocal_divide(interval, rec_inv_sqrt << REC_INV_SQRT_SHIFT);
+	return t + (u32)(((u64) interval * (rec_inv_sqrt << REC_INV_SQRT_SHIFT)) >> 32);
 }
 
-
 static bool codel_should_drop(const struct sk_buff *skb,
 			      struct Qdisc *sch,
 			      struct codel_vars *vars,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 279467b..f976474 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,7 +88,6 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
-#include <linux/reciprocal_div.h>
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
 #endif
@@ -1220,7 +1219,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
 				      struct sk_buff *skb,
 				      unsigned int num)
 {
-	return reciprocal_divide(skb->rxhash, num);
+	return (u32)(((u64) skb->rxhash * num) >> 32);
 }
 
 static unsigned int fanout_demux_lb(struct packet_fanout *f,
@@ -1247,7 +1246,7 @@ static unsigned int fanout_demux_rnd(struct packet_fanout *f,
 				     struct sk_buff *skb,
 				     unsigned int num)
 {
-	return reciprocal_divide(prandom_u32(), num);
+	return prandom_u32_lt_N(num);
 }
 
 static unsigned int fanout_demux_rollover(struct packet_fanout *f,
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ddd73cb..556b6f6 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -14,7 +14,6 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
-#include <linux/reciprocal_div.h>
 #include <linux/vmalloc.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
@@ -77,12 +76,6 @@ struct choke_sched_data {
 	struct sk_buff **tab;
 };
 
-/* deliver a random number between 0 and N - 1 */
-static u32 random_N(unsigned int N)
-{
-	return reciprocal_divide(prandom_u32(), N);
-}
-
 /* number of elements in queue including holes */
 static unsigned int choke_len(const struct choke_sched_data *q)
 {
@@ -233,7 +226,7 @@ static struct sk_buff *choke_peek_random(const struct choke_sched_data *q,
 	int retrys = 3;
 
 	do {
-		*pidx = (q->head + random_N(choke_len(q))) & q->tab_mask;
+		*pidx = (q->head + prandom_u32_lt_N(choke_len(q))) & q->tab_mask;
 		skb = q->tab[*pidx];
 		if (skb)
 			return skb;
-- 
1.8.3.1
