From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] pkt_sched: gen_estimator: Dont report fake rate estimators
Date: Thu, 01 Oct 2009 21:07:51 +0200
Message-ID: <4AC4FE07.5070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59278 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbZJATHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 15:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently send TCA_STATS_RATE_EST elements to netlink users, even if no estimator
is running.

# tc -s -d qdisc
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

User has no way to tell if the "rate 0bit 0pps" is a real estimation, or a fake
one (because no estimator is active)

After this patch, tc command output is :
$ tc -s -d qdisc
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/gen_stats.h |   16 +++++++++++++---
 net/core/gen_estimator.c  |    9 +++++----
 net/core/gen_stats.c      |    9 ++++++---
 net/sched/act_police.c    |    2 +-
 4 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
index 710e901..7678ded 100644
--- a/include/linux/gen_stats.h
+++ b/include/linux/gen_stats.h
@@ -30,17 +30,27 @@ struct gnet_stats_basic_packed
 } __attribute__ ((packed));
 
 /**
- * struct gnet_stats_rate_est - rate estimator
+ * struct gnet_stats_user_rate_est - rate estimator
  * @bps: current byte rate
  * @pps: current packet rate
  */
-struct gnet_stats_rate_est
-{
+struct gnet_stats_user_rate_est {
 	__u32	bps;
 	__u32	pps;
 };
 
 /**
+ * struct gnet_stats_rate_est - rate estimator with flags
+ * @est: current byte/packet rate
+ * @flags: set to one if estimation is valid
+ */
+struct gnet_stats_rate_est {
+	struct gnet_stats_user_rate_est	est;
+	int				flags;
+};
+#define RATE_EST_VALID 1
+
+/**
  * struct gnet_stats_queue - queuing statistics
  * @qlen: queue length
  * @backlog: backlog size of queue
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 493775f..5ba9d90 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -129,12 +129,13 @@ static void est_timer(unsigned long arg)
 		brate = (nbytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes = nbytes;
 		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
-		e->rate_est->bps = (e->avbps+0xF)>>5;
+		e->rate_est->est.bps = (e->avbps+0xF)>>5;
 
 		rate = (npackets - e->last_packets)<<(12 - idx);
 		e->last_packets = npackets;
 		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
-		e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		e->rate_est->est.pps = (e->avpps+0x1FF)>>10;
+		e->rate_est->flags |= RATE_EST_VALID;
 skip:
 		read_unlock(&est_lock);
 		spin_unlock(e->stats_lock);
@@ -227,9 +228,9 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 	est->stats_lock = stats_lock;
 	est->ewma_log = parm->ewma_log;
 	est->last_bytes = bstats->bytes;
-	est->avbps = rate_est->bps<<5;
+	est->avbps = rate_est->est.bps<<5;
 	est->last_packets = bstats->packets;
-	est->avpps = rate_est->pps<<10;
+	est->avpps = rate_est->est.pps<<10;
 
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 8569310..b6f723c 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -138,13 +138,16 @@ gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic_packed *b)
 int
 gnet_stats_copy_rate_est(struct gnet_dump *d, struct gnet_stats_rate_est *r)
 {
+	if (!(r->flags & RATE_EST_VALID))
+		return 0;
+
 	if (d->compat_tc_stats) {
-		d->tc_stats.bps = r->bps;
-		d->tc_stats.pps = r->pps;
+		d->tc_stats.bps = r->est.bps;
+		d->tc_stats.pps = r->est.pps;
 	}
 
 	if (d->tail)
-		return gnet_stats_copy(d, TCA_STATS_RATE_EST, r, sizeof(*r));
+		return gnet_stats_copy(d, TCA_STATS_RATE_EST, &r->est, sizeof(r->est));
 
 	return 0;
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 723964c..ba01081 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -292,7 +292,7 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 	police->tcf_bstats.packets++;
 
 	if (police->tcfp_ewma_rate &&
-	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
+	    police->tcf_rate_est.est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
 		if (police->tcf_action == TC_ACT_SHOT)
 			police->tcf_qstats.drops++;
