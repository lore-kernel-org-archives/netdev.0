From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] netem: restore no jitter option
Date: Fri, 06 Aug 2010 12:35:57 -0700
Message-ID: <20100806193559.285832834@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35717 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761961Ab0HFTiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:05 -0400
Content-Disposition: inline; filename=netem-queue.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before netem was forced to be classless, it was possible to prevent
packet reordering by using a pure FIFO queue. This restores the option,
although now it has to be done as a module parameter.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_netem.c	2010-08-02 15:02:36.654303844 -0700
+++ b/net/sched/sch_netem.c	2010-08-02 15:02:59.146459862 -0700
@@ -87,6 +87,10 @@ static inline struct netem_skb_cb *netem
 	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
+static int jitter = 1;
+module_param(jitter, int, 0);
+MODULE_PARM_DESC(jitter, "reorder packets based on delay");
+
 /* init_crandom - initialize correlated random number generator
  * Use entropy source for initial seed.
  */
@@ -531,6 +535,7 @@ static struct Qdisc_ops tfifo_qdisc_ops 
 static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct Qdisc_ops *ops = jitter ? &tfifo_qdisc_ops : &pfifo_qdisc_ops;
 	int ret;
 
 	if (!opt)
@@ -539,8 +544,7 @@ static int netem_init(struct Qdisc *sch,
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	q->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
-				     &tfifo_qdisc_ops,
-				     TC_H_MAKE(sch->handle, 1));
+				     ops, TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
 		pr_debug("netem: qdisc create failed\n");
 		return -ENOMEM;


