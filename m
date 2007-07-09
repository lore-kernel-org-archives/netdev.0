From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/05]: sch_atm: act_api support
Date: Mon,  9 Jul 2007 22:46:15 +0200 (MEST)
Message-ID: <20070709204614.1461.59556.sendpatchset@localhost.localdomain>
References: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723AbXGIUqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:46:16 -0400
In-Reply-To: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_atm: act_api support

Handle act_api classification results.

The ATM scheduler behaves slightly different than other schedulers
in that it only handles policer results for successful classifications,
this behaviour is retained for the act_api case.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c7c3ff564b59bfb21aadd54cabab9369f120eaba
tree e0c0de83f364229f0bb4b8abb586fd64c204fd12
parent d040f72f96e69c5494179d4431e8db82e8a11c74
author Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:03:09 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:03:09 +0200

 net/sched/sch_atm.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 9b458c4..ccee10d 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -411,11 +411,21 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (flow->vcc)
 			ATM_SKB(skb)->atm_options = flow->vcc->atm_options;
 		/*@@@ looks good ... but it's not supposed to work :-) */
-#ifdef CONFIG_NET_CLS_POLICE
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_QUEUED:
+		case TC_ACT_STOLEN:
+			kfree_skb(skb);
+			return NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
+			kfree_skb(skb);
+			goto drop;
+		}
+#elif defined(CONFIG_NET_CLS_POLICE)
 		switch (result) {
 		case TC_POLICE_SHOT:
 			kfree_skb(skb);
-			break;
+			goto drop;
 		case TC_POLICE_RECLASSIFY:
 			if (flow->excess)
 				flow = flow->excess;
@@ -431,11 +441,8 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 #endif
 	}
-	if (
-#ifdef CONFIG_NET_CLS_POLICE
-		   result == TC_POLICE_SHOT ||
-#endif
-		   (ret = flow->q->enqueue(skb, flow->q)) != 0) {
+	if ((ret = flow->q->enqueue(skb, flow->q)) != 0) {
+drop: __maybe_unused
 		sch->qstats.drops++;
 		if (flow)
 			flow->qstats.drops++;
