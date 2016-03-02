From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next] net: sched: use pfifo_fast for non real queues
Date: Wed,  2 Mar 2016 08:21:43 -0800
Message-ID: <1456935703-27585-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36796 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755496AbcCBQWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 11:22:04 -0500
Received: by mail-pa0-f48.google.com with SMTP id a9so13680456pat.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 08:22:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices declare a high number of TX queues, then set a much
lower real_num_tx_queues

This cause setups using fq_codel, sfq or fq as the default qdisc to consume
more memory than really needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sch_generic.h | 6 ++++++
 net/sched/sch_generic.c   | 1 +
 net/sched/sch_mq.c        | 2 +-
 net/sched/sch_mqprio.c    | 3 ++-
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e5bba897d206..46e55f0202a6 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -345,6 +345,12 @@ extern struct Qdisc_ops pfifo_fast_ops;
 extern struct Qdisc_ops mq_qdisc_ops;
 extern struct Qdisc_ops noqueue_qdisc_ops;
 extern const struct Qdisc_ops *default_qdisc_ops;
+static inline const struct Qdisc_ops *
+get_default_qdisc_ops(const struct net_device *dev, int ntx)
+{
+	return ntx < dev->real_num_tx_queues ?
+			default_qdisc_ops : &pfifo_fast_ops;
+}
 
 struct Qdisc_class_common {
 	u32			classid;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 16bc83b2842a..f18c35024207 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -567,6 +567,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.dump		=	pfifo_fast_dump,
 	.owner		=	THIS_MODULE,
 };
+EXPORT_SYMBOL(pfifo_fast_ops);
 
 static struct lock_class_key qdisc_tx_busylock;
 
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 3e82f047caaf..56a77b878eb3 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -57,7 +57,7 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		dev_queue = netdev_get_tx_queue(dev, ntx);
-		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
+		qdisc = qdisc_create_dflt(dev_queue, get_default_qdisc_ops(dev, ntx),
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
 		if (qdisc == NULL)
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 02ffb3fbbc20..b8002ce3d010 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -125,7 +125,8 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		dev_queue = netdev_get_tx_queue(dev, i);
-		qdisc = qdisc_create_dflt(dev_queue, default_qdisc_ops,
+		qdisc = qdisc_create_dflt(dev_queue,
+					  get_default_qdisc_ops(dev, i),
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(i + 1)));
 		if (qdisc == NULL) {
-- 
2.7.0.rc3.207.g0ac5344
