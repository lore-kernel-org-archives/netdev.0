From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: restart device after inserting packets
Date: Tue, 14 Dec 2004 13:11:13 -0800
Message-ID: <20041214131113.32d080fb@dxpl.pdx.osdl.net>
References: <20041208123103.4cc6b005@dxpl.pdx.osdl.net>
	<20041208210031.63f0963f.davem@davemloft.net>
	<41B91901.3070304@trash.net>
	<20041214113249.0725a655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netem@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041214113249.0725a655.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2.4 version of the netem wakeup patch. Also fixes the qlen
in a couple of places. This makes code basically same as 2.6

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-12-14 13:10:18 -08:00
+++ b/net/sched/sch_netem.c	2004-12-14 13:10:18 -08:00
@@ -259,12 +259,13 @@
 {
 	struct Qdisc *sch = (struct Qdisc *)arg;
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = sch->dev;
 	struct sk_buff *skb;
 	psched_time_t now;
 
 	pr_debug("netem_watchdog: fired @%lu\n", jiffies);
 
-	spin_lock_bh(&sch->dev->queue_lock);
+	spin_lock_bh(&dev->queue_lock);
 	PSCHED_GET_TIME(now);
 
 	while ((skb = skb_peek(&q->delayed)) != NULL) {
@@ -284,8 +285,11 @@
 
 		if (q->qdisc->enqueue(skb, q->qdisc))
 			sch->stats.drops++;
+		else
+			sch->q.qlen++;
 	}
-	spin_unlock_bh(&sch->dev->queue_lock);
+	qdisc_run(dev);
+	spin_unlock_bh(&dev->queue_lock);
 }
 
 static void netem_reset(struct Qdisc *sch)
@@ -505,7 +509,7 @@
 	sch_tree_lock(sch);
 	*old = xchg(&q->qdisc, new);
 	qdisc_reset(*old);
-	sch->q.qlen = q->delayed.qlen;
+	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
 
 	return 0;
