From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem: restart device after inserting packets
Date: Wed, 8 Dec 2004 12:31:03 -0800
Message-ID: <20041208123103.4cc6b005@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netem@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The version of netem in 2.6.10 moves packets from the delayed queue
to the qdisc in a timer interrupt. But it forgot to force the device to
pick them up.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-12-08 12:29:12 -08:00
+++ b/net/sched/sch_netem.c	2004-12-08 12:29:12 -08:00
@@ -258,12 +258,13 @@
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
@@ -286,7 +287,8 @@
 		else
 			sch->q.qlen++;
 	}
-	spin_unlock_bh(&sch->dev->queue_lock);
+	qdisc_restart(dev);
+	spin_unlock_bh(&dev->queue_lock);
 }
 
 static void netem_reset(struct Qdisc *sch)
