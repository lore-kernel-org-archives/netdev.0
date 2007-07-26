From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Fix prio/ingress classification logic error
Date: Thu, 26 Jul 2007 13:32:19 +0200
Message-ID: <46A88643.5010003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030404090709050601080000"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40873 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbXGZLhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 07:37:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030404090709050601080000
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This is the final fix for the problem Peter reported.
Turns out most other schedulers get it right, the only
other case is ingress setting skb->tc_index to the
uninitialized value of res.classid.



--------------030404090709050601080000
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Fix prio/ingress classification logic error

Fix handling of empty or completely non-matching filter chains. In
that case -1 is returned and tcf_result is uninitialized, the
qdisc should fall back to default classification in that case.

Noticed by PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c98436c161ff45850346b08f89cfb444be7c7817
tree 07e3ea0f508243f41e70645b6c358e23244ea0b4
parent e4903fb59590f86190280a549420f6cb85bd7f7e
author Patrick McHardy <kaber@trash.net> Thu, 26 Jul 2007 13:32:26 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 26 Jul 2007 13:32:26 +0200

 net/sched/sch_ingress.c |    3 +--
 net/sched/sch_prio.c    |    7 +++----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 51f16b0..2d32fd2 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -158,9 +158,8 @@ static int ingress_enqueue(struct sk_buff *skb,struct Qdisc *sch)
 			break;
 		case TC_ACT_RECLASSIFY:
 		case TC_ACT_OK:
-		case TC_ACT_UNSPEC:
-		default:
 			skb->tc_index = TC_H_MIN(res.classid);
+		default:
 			result = TC_ACT_OK;
 			break;
 	}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2d8c084..71bafde 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -38,9 +38,11 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	u32 band = skb->priority;
 	struct tcf_result res;
+	int err;
 
 	*qerr = NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
+		err = tc_classify(skb, q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
 		switch (tc_classify(skb, q->filter_list, &res)) {
 		case TC_ACT_STOLEN:
@@ -49,11 +51,8 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_SHOT:
 			return NULL;
 		}
-
-		if (!q->filter_list ) {
-#else
-		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
 #endif
+		if (!q->filter_list || err < 0) {
 			if (TC_H_MAJ(band))
 				band = 0;
 			band = q->prio2band[band&TC_PRIO_MAX];

--------------030404090709050601080000--
