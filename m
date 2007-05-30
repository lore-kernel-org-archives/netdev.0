From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] qdisc_run de inline.
Date: Wed, 30 May 2007 09:23:24 -0700
Message-ID: <20070530092324.2f0fa703@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:57346 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbXE3Qen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 12:34:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It isn't worth inlining qdisc_run, into two parts. The code is
cleaner (and smaller) to just have it as one routine.

--- a/include/net/pkt_sched.h	2007-05-02 12:26:34.000000000 -0700
+++ b/include/net/pkt_sched.h	2007-05-30 09:12:22.000000000 -0700
@@ -80,14 +80,7 @@ extern struct qdisc_rate_table *qdisc_ge
 		struct rtattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern void __qdisc_run(struct net_device *dev);
-
-static inline void qdisc_run(struct net_device *dev)
-{
-	if (!netif_queue_stopped(dev) &&
-	    !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
-		__qdisc_run(dev);
-}
+extern void qdisc_run(struct net_device *dev);
 
 extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	struct tcf_result *res);
--- a/net/sched/sch_generic.c	2007-05-29 08:14:38.000000000 -0700
+++ b/net/sched/sch_generic.c	2007-05-30 09:14:08.000000000 -0700
@@ -177,14 +177,16 @@ out:
 	return q->q.qlen;
 }
 
-void __qdisc_run(struct net_device *dev)
+void qdisc_run(struct net_device *dev)
 {
-	do {
-		if (!qdisc_restart(dev))
-			break;
-	} while (!netif_queue_stopped(dev));
+	if (!test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state)) {
+		while (!netif_queue_stopped(dev)) {
+			if (!qdisc_restart(dev))
+				break;
+		}
 
-	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+		clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+	}
 }
 
 static void dev_watchdog(unsigned long arg)
