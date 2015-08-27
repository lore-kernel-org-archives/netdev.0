From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 3/4] net: sched: register noqueue qdisc
Date: Thu, 27 Aug 2015 21:21:38 +0200
Message-ID: <1440703299-21243-4-git-send-email-phil@nwl.cc>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39735 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254AbbH0TVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 15:21:41 -0400
In-Reply-To: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way users can attach noqueue just like any other qdisc using tc
without having to mess with tx_queue_len first.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/net/sch_generic.h |  1 +
 net/sched/sch_api.c       |  1 +
 net/sched/sch_generic.c   | 12 +++++++++++-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2eab08c..444faa8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -340,6 +340,7 @@ extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_fast_ops;
 extern struct Qdisc_ops mq_qdisc_ops;
+extern struct Qdisc_ops noqueue_qdisc_ops;
 extern const struct Qdisc_ops *default_qdisc_ops;
 
 struct Qdisc_class_common {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f06aa01..6a35551 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1947,6 +1947,7 @@ static int __init pktsched_init(void)
 	register_qdisc(&bfifo_qdisc_ops);
 	register_qdisc(&pfifo_head_drop_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
+	register_qdisc(&noqueue_qdisc_ops);
 
 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL, NULL);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f501b74..d5c7c0d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -416,9 +416,19 @@ struct Qdisc noop_qdisc = {
 };
 EXPORT_SYMBOL(noop_qdisc);
 
-static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
+static int noqueue_init(struct Qdisc *qdisc, struct nlattr *opt)
+{
+	/* register_qdisc() assigns a default of noop_enqueue if unset,
+	 * but __dev_queue_xmit() treats noqueue only as such
+	 * if this is NULL - so clear it here. */
+	qdisc->enqueue = NULL;
+	return 0;
+}
+
+struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.id		=	"noqueue",
 	.priv_size	=	0,
+	.init		=	noqueue_init,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
 	.peek		=	noop_dequeue,
-- 
2.1.2
