From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: [PATCH] sch_prio - fix compile warning + some logic rearrangement in enqueue
Date: Tue, 29 Jun 2004 01:06:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406290106.38304.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Jamal Hadi Salim <jamal@znyx.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

When CONFIG_NET_CLS_ACT is not set 'result' variable in prio_classify is
unused. Also I was looking over the rest of the module and had hard time
understanding the logic in prio_enqueue - I rearranged it a bit for better
readability. Plus there are some formatting changes.

Please consider for inclusion.

-- 
Dmitry


===================================================================


ChangeSet@1.1875, 2004-06-29 00:45:12-05:00, dtor_core@ameritech.net
  NET: sch_prio
       - fix compile warning in prio_classify
       - rearrange prio_enqueue conditional compilation maze
       - minor formatting changes

  Signed-off-by: Dmitry Torokhov <dtor@mail.ru>

 sch_prio.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)


===================================================================



diff -Nru a/net/sched/sch_prio.c b/net/sched/sch_prio.c
--- a/net/sched/sch_prio.c	2004-06-29 00:58:52 -05:00
+++ b/net/sched/sch_prio.c	2004-06-29 00:58:52 -05:00
@@ -47,20 +47,19 @@
 };
 
 
-struct Qdisc *prio_classify(struct sk_buff *skb, struct Qdisc *sch,int *r)
+struct Qdisc *prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *r)
 {
 	struct prio_sched_data *q = (struct prio_sched_data *)sch->data;
 	struct tcf_result res;
 	u32 band;
-	int result = 0;
 
 	band = skb->priority;
 
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
 #ifdef CONFIG_NET_CLS_ACT
-		*r = result = tc_classify(skb, q->filter_list, &res);
+		*r = tc_classify(skb, q->filter_list, &res);
 
-		switch (result) {
+		switch (*r) {
 			case TC_ACT_SHOT:
 			case TC_ACT_STOLEN:
 			case TC_ACT_QUEUED:
@@ -70,22 +69,22 @@
 			case TC_ACT_OK:
 			case TC_ACT_UNSPEC:
 			default:
-			break;
+				break;
 		};
 
-		if (!q->filter_list ) {
+		if (!q->filter_list) {
 #else
 		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
 #endif
 			if (TC_H_MAJ(band))
 				band = 0;
-			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
+			return q->queues[q->prio2band[band & TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
 	if (band > q->bands)
-		return q->queues[q->prio2band[0]];
+		band = q->prio2band[0];
 
 	return q->queues[band];
 }
@@ -112,17 +111,16 @@
 	}
 
 dropped:
+
 #ifdef CONFIG_NET_CLS_ACT
-	if (TC_ACT_SHOT == ret || NET_XMIT_DROP == ret) {
-#endif
-		sch->stats.drops++;
-		return NET_XMIT_DROP;
-#ifdef CONFIG_NET_CLS_ACT
-	} else {
-		sch->stats.overlimits++; /* abuse, but noone uses it */
-		return NET_XMIT_BYPASS; /* we dont want to confuse TCP */
+	if (ret != TC_ACT_SHOT && ret != NET_XMIT_DROP) {
+		sch->stats.overlimits++;	/* abuse, but noone uses it */
+		return NET_XMIT_BYPASS;		/* we dont want to confuse TCP */
 	}
 #endif
+
+	sch->stats.drops++;
+	return NET_XMIT_DROP;
 }
 
 
