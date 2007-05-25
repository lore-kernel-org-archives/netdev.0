From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH][NET_SCHED] Update htb rate when stats are polled.
Date: Fri, 25 May 2007 10:11:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: ranjitm@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:25009 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761132AbXEYRLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 13:11:31 -0400
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id l4PHBS3L012614
	for <netdev@vger.kernel.org>; Fri, 25 May 2007 18:11:28 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the HTB rate for a class is update very slowly (once
every 16 seconds). This patch updates the rate whenever the stats
are requested from user space. This enables more accurate rate
monitoring.

Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 035788c..1d6ec60 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -92,6 +92,7 @@ struct htb_class {
  	struct gnet_stats_basic bstats;
  	struct gnet_stats_queue qstats;
  	struct gnet_stats_rate_est rate_est;
+	unsigned long rate_est_when;	/* last time rate was calculated */
  	struct tc_htb_xstats xstats;	/* our special stats */
  	int refcnt;		/* usage count of this class */

@@ -679,6 +680,23 @@ static int htb_requeue(struct sk_buff *s

  #ifdef HTB_RATECM
  #define RT_GEN(D,R) R+=D-(R/HTB_EWMAC);D=0
+
+/* Update packet/byte rate for a class. */
+static void calc_rate(struct htb_class *cl)
+{
+	unsigned long now = jiffies;
+	if (time_after(now, (cl->rate_est_when + HZ))) {
+	unsigned int elapsed_secs =
+			(now - cl->rate_est_when)/HZ;
+		cl->sum_bytes /= elapsed_secs;
+		cl->sum_packets /= elapsed_secs;
+		RT_GEN (cl->sum_bytes,cl->rate_bytes);
+		RT_GEN (cl->sum_packets,cl->rate_packets);
+		cl->rate_est_when = now;
+	} else if time_before(now, cl->rate_est_when)
+		cl->rate_est_when = now; /* Wraparound */
+}
+
  static void htb_rate_timer(unsigned long arg)
  {
  	struct Qdisc *sch = (struct Qdisc *)arg;
@@ -697,10 +715,8 @@ static void htb_rate_timer(unsigned long
  	if (++q->recmp_bucket >= HTB_HSIZE)
  		q->recmp_bucket = 0;

-	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist) {
-		RT_GEN(cl->sum_bytes, cl->rate_bytes);
-		RT_GEN(cl->sum_packets, cl->rate_packets);
-	}
+	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist)
+		calc_rate(cl);
  	spin_unlock_bh(&sch->dev->queue_lock);
  }
  #endif
@@ -1176,8 +1192,9 @@ htb_dump_class_stats(struct Qdisc *sch,
  	struct htb_class *cl = (struct htb_class *)arg;

  #ifdef HTB_RATECM
-	cl->rate_est.bps = cl->rate_bytes / (HTB_EWMAC * HTB_HSIZE);
-	cl->rate_est.pps = cl->rate_packets / (HTB_EWMAC * HTB_HSIZE);
+	calc_rate(cl);
+	cl->rate_est.bps = cl->rate_bytes / HTB_EWMAC;
+	cl->rate_est.pps = cl->rate_packets / HTB_EWMAC;
  #endif

  	if (!cl->level && cl->un.leaf.q)
@@ -1464,6 +1481,7 @@ static int htb_change_class(struct Qdisc
  		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
  		cl->t_c = psched_get_time();
  		cl->cmode = HTB_CAN_SEND;
+		cl->rate_est_when = jiffies;

  		/* attach to the hash list and parent's family */
  		hlist_add_head(&cl->hlist, q->hash + htb_hash(classid));
