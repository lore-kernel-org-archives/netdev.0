From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: introduce generic net_random_N helper
Date: Tue,  3 Sep 2013 12:26:49 +0200
Message-ID: <1378204010-27050-2-git-send-email-dborkman@redhat.com>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759867Ab3ICK0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 06:26:55 -0400
In-Reply-To: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have implemented the same function over and over, so introduce a
generic helper net_random_N() that unifies these implementations.
It internally used net_random() which eventually resolves to
prandom_u32(). Explicit include of reciprocal_div.h is not necessary.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/team/team_mode_random.c | 7 +------
 include/linux/net.h                 | 7 +++++++
 include/net/red.h                   | 2 +-
 net/802/garp.c                      | 2 +-
 net/802/mrp.c                       | 2 +-
 net/packet/af_packet.c              | 2 +-
 net/sched/sch_choke.c               | 8 +-------
 7 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/team/team_mode_random.c b/drivers/net/team/team_mode_random.c
index 7f032e2..b2294f8 100644
--- a/drivers/net/team/team_mode_random.c
+++ b/drivers/net/team/team_mode_random.c
@@ -16,17 +16,12 @@
 #include <linux/reciprocal_div.h>
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
+	port_index = net_random_N(team->en_port_count);
 	port = team_get_port_by_index_rcu(team, port_index);
 	if (unlikely(!port))
 		goto drop;
diff --git a/include/linux/net.h b/include/linux/net.h
index 4f27575..86ffce7 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -24,6 +24,7 @@
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/kmemcheck.h>
 #include <linux/rcupdate.h>
+#include <linux/reciprocal_div.h>
 #include <uapi/linux/net.h>
 
 struct poll_table_struct;
@@ -243,6 +244,12 @@ do {								\
 #define net_random()		prandom_u32()
 #define net_srandom(seed)	prandom_seed((__force u32)(seed))
 
+/* deliver a random number between 0 and N - 1 */
+static inline u32 net_random_N(u32 N)
+{
+	return reciprocal_divide(net_random(), N);
+}
+
 extern int   	     kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 				    struct kvec *vec, size_t num, size_t len);
 extern int   	     kernel_recvmsg(struct socket *sock, struct msghdr *msg,
diff --git a/include/net/red.h b/include/net/red.h
index ef46058..b17ed60 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -303,7 +303,7 @@ static inline unsigned long red_calc_qavg(const struct red_parms *p,
 
 static inline u32 red_random(const struct red_parms *p)
 {
-	return reciprocal_divide(net_random(), p->max_P_reciprocal);
+	return net_random_N(p->max_P_reciprocal);
 }
 
 static inline int red_mark_probability(const struct red_parms *p,
diff --git a/net/802/garp.c b/net/802/garp.c
index 5d9630a..c6fe7ca 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
+	delay = net_random_N(msecs_to_jiffies(garp_join_time));
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 1eb05d8..7338a7c 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -578,7 +578,7 @@ static void mrp_join_timer_arm(struct mrp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(mrp_join_time) * net_random() >> 32;
+	delay = net_random_N(msecs_to_jiffies(mrp_join_time));
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2e8286b..7ac669e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1162,7 +1162,7 @@ static unsigned int fanout_demux_rnd(struct packet_fanout *f,
 				     struct sk_buff *skb,
 				     unsigned int num)
 {
-	return reciprocal_divide(prandom_u32(), num);
+	return net_random_N(num);
 }
 
 static unsigned int fanout_demux_rollover(struct packet_fanout *f,
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index ef53ab8..e19b20be 100644
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
+		*pidx = (q->head + net_random_N(choke_len(q))) & q->tab_mask;
 		skb = q->tab[*pidx];
 		if (skb)
 			return skb;
-- 
1.7.11.7
