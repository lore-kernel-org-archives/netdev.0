From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] net_sched: sch_plug: use a private throttled status
Date: Fri, 10 Jun 2016 16:41:36 -0700
Message-ID: <1465602099-15808-2-git-send-email-edumazet@google.com>
References: <1465602099-15808-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33550 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbcFJXlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 19:41:47 -0400
Received: by mail-pf0-f179.google.com with SMTP id y124so27587051pfy.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 16:41:46 -0700 (PDT)
In-Reply-To: <1465602099-15808-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to get rid of generic qdisc throttled management,
so this qdisc has to use a private flag.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_plug.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index ff0d968750df..a12cd37680f8 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -64,6 +64,8 @@ struct plug_sched_data {
 	 */
 	bool unplug_indefinite;
 
+	bool throttled;
+
 	/* Queue Limit in bytes */
 	u32 limit;
 
@@ -103,7 +105,7 @@ static struct sk_buff *plug_dequeue(struct Qdisc *sch)
 {
 	struct plug_sched_data *q = qdisc_priv(sch);
 
-	if (qdisc_is_throttled(sch))
+	if (q->throttled)
 		return NULL;
 
 	if (!q->unplug_indefinite) {
@@ -111,7 +113,7 @@ static struct sk_buff *plug_dequeue(struct Qdisc *sch)
 			/* No more packets to dequeue. Block the queue
 			 * and wait for the next release command.
 			 */
-			qdisc_throttled(sch);
+			q->throttled = true;
 			return NULL;
 		}
 		q->pkts_to_release--;
@@ -141,7 +143,7 @@ static int plug_init(struct Qdisc *sch, struct nlattr *opt)
 		q->limit = ctl->limit;
 	}
 
-	qdisc_throttled(sch);
+	q->throttled = true;
 	return 0;
 }
 
@@ -173,7 +175,7 @@ static int plug_change(struct Qdisc *sch, struct nlattr *opt)
 		q->pkts_last_epoch = q->pkts_current_epoch;
 		q->pkts_current_epoch = 0;
 		if (q->unplug_indefinite)
-			qdisc_throttled(sch);
+			q->throttled = true;
 		q->unplug_indefinite = false;
 		break;
 	case TCQ_PLUG_RELEASE_ONE:
@@ -182,7 +184,7 @@ static int plug_change(struct Qdisc *sch, struct nlattr *opt)
 		 */
 		q->pkts_to_release += q->pkts_last_epoch;
 		q->pkts_last_epoch = 0;
-		qdisc_unthrottled(sch);
+		q->throttled = false;
 		netif_schedule_queue(sch->dev_queue);
 		break;
 	case TCQ_PLUG_RELEASE_INDEFINITE:
@@ -190,7 +192,7 @@ static int plug_change(struct Qdisc *sch, struct nlattr *opt)
 		q->pkts_to_release = 0;
 		q->pkts_last_epoch = 0;
 		q->pkts_current_epoch = 0;
-		qdisc_unthrottled(sch);
+		q->throttled = false;
 		netif_schedule_queue(sch->dev_queue);
 		break;
 	case TCQ_PLUG_LIMIT:
-- 
2.8.0.rc3.226.g39d4020
