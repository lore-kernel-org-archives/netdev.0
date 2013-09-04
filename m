From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 2/2] net: migrate direct users to prandom_u32_max
Date: Wed,  4 Sep 2013 14:37:27 +0200
Message-ID: <1378298247-29364-3-git-send-email-dborkman@redhat.com>
References: <1378298247-29364-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378298247-29364-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Users that directly use or reimplement what we have in prandom_u32_max()
can be migrated for now to use it directly, so that we can reduce code size
and avoid reimplementations. That's obvious, follow-up patches could inspect
modulo use cases for possible migration as well.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/team/team_mode_random.c | 8 +-------
 include/net/red.h                   | 2 +-
 net/802/garp.c                      | 3 ++-
 net/802/mrp.c                       | 3 ++-
 net/packet/af_packet.c              | 2 +-
 net/sched/sch_choke.c               | 8 +-------
 6 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
index 7f032e2..0dbd1eb 100644
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
+	port_index = prandom_u32_max(team->en_port_count - 1);
 	port = team_get_port_by_index_rcu(team, port_index);
 	if (unlikely(!port))
 		goto drop;
diff --git a/include/net/red.h b/include/net/red.h
index ef46058..56f3c0c 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -303,7 +303,7 @@ static inline unsigned long red_calc_qavg(const struct red_parms *p,
 
 static inline u32 red_random(const struct red_parms *p)
 {
-	return reciprocal_divide(net_random(), p->max_P_reciprocal);
+	return prandom_u32_max(p->max_P_reciprocal - 1);
 }
 
 static inline int red_mark_probability(const struct red_parms *p,
diff --git a/net/802/garp.c b/net/802/garp.c
index 5d9630a..b4be421 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -397,7 +397,8 @@ static void garp_join_timer_arm(struct garp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
+	delay = prandom_u32_max(msecs_to_jiffies(garp_join_time) - 1);
+
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 1eb05d8..1a08ae7 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -578,7 +578,8 @@ static void mrp_join_timer_arm(struct mrp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(mrp_join_time) * net_random() >> 32;
+	delay = prandom_u32_max(msecs_to_jiffies(mrp_join_time) - 1);
+
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2e8286b..1c1ccf9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1162,7 +1162,7 @@ static unsigned int fanout_demux_rnd(struct packet_fanout *f,
 				     struct sk_buff *skb,
 				     unsigned int num)
 {
-	return reciprocal_divide(prandom_u32(), num);
+	return prandom_u32_max(num - 1);
 }
 
 static unsigned int fanout_demux_rollover(struct packet_fanout *f,
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ef53ab8..7a73fbf 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -77,12 +77,6 @@ struct choke_sched_data {
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
@@ -233,7 +227,7 @@ static struct sk_buff *choke_peek_random(const struct choke_sched_data *q,
 	int retrys = 3;
 
 	do {
-		*pidx = (q->head + random_N(choke_len(q))) & q->tab_mask;
+		*pidx = (q->head + prandom_u32_max(choke_len(q) - 1)) & q->tab_mask;
 		skb = q->tab[*pidx];
 		if (skb)
 			return skb;
-- 
1.7.11.7
