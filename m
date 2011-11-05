From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 01/11] sch_hfsc.c: update_d() fixup
Date: Sat,  5 Nov 2011 03:32:47 +0100
Message-ID: <1320460377-8682-2-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:13585 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab1KECdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:07 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The deadline time is generated from total rt work + size of the next packet.

Now, when a packet gets dequeued by linkshare criterion, we have to
update the deadline time to match the new situation (that's the job of
update_d()) - but to do that properly, we have to subtract the size of
the packet just dequeued, when calling rtsc_min().

This is actually stated in hfsc paper very clearly, but got (probably)
missed during altq days (or due to some patch at some point).

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6488e64..261accc 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -650,9 +650,9 @@ update_ed(struct hfsc_class *cl, unsigned int next_len)
 }
 
 static inline void
-update_d(struct hfsc_class *cl, unsigned int next_len)
+update_d(struct hfsc_class *cl, unsigned int curr_len, unsigned int next_len)
 {
-	cl->cl_d = rtsc_y2x(&cl->cl_deadline, cl->cl_cumul + next_len);
+	cl->cl_d = rtsc_y2x(&cl->cl_deadline, cl->cl_cumul - curr_len + next_len);
 }
 
 static inline void
@@ -1610,7 +1610,7 @@ hfsc_dequeue(struct Qdisc *sch)
 	struct hfsc_class *cl;
 	struct sk_buff *skb;
 	u64 cur_time;
-	unsigned int next_len;
+	unsigned int curr_len, next_len;
 	int realtime = 0;
 
 	if (sch->q.qlen == 0)
@@ -1640,14 +1640,16 @@ hfsc_dequeue(struct Qdisc *sch)
 	}
 
 	skb = qdisc_dequeue_peeked(cl->qdisc);
+	curr_len = qdisc_pkt_len(skb);
+
 	if (skb == NULL) {
 		qdisc_warn_nonwc("HFSC", cl->qdisc);
 		return NULL;
 	}
 
-	update_vf(cl, qdisc_pkt_len(skb), cur_time);
+	update_vf(cl, curr_len, cur_time);
 	if (realtime)
-		cl->cl_cumul += qdisc_pkt_len(skb);
+		cl->cl_cumul += curr_len;
 
 	if (cl->qdisc->q.qlen != 0) {
 		if (cl->cl_flags & HFSC_RSC) {
@@ -1656,7 +1658,7 @@ hfsc_dequeue(struct Qdisc *sch)
 			if (realtime)
 				update_ed(cl, next_len);
 			else
-				update_d(cl, next_len);
+				update_d(cl, curr_len, next_len);
 		}
 	} else {
 		/* the class becomes passive */
-- 
1.7.7.1
