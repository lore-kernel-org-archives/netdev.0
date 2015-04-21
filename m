From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Tue, 21 Apr 2015 12:27:55 -0700
Message-ID: <1429644476-8914-3-git-send-email-ast@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35983 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977AbbDUT2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 15:28:13 -0400
Received: by pdea3 with SMTP id a3so250993748pde.3
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 12:28:12 -0700 (PDT)
In-Reply-To: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC_ACT_QUEUED was always an alias of TC_ACT_STOLEN.
Get rid of redundant checks in all qdiscs.
Instead do it once.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/pkt_cls.h |    2 +-
 net/sched/sch_api.c          |    2 ++
 net/sched/sch_atm.c          |    1 -
 net/sched/sch_cbq.c          |    1 -
 net/sched/sch_choke.c        |    1 -
 net/sched/sch_drr.c          |    1 -
 net/sched/sch_dsmark.c       |    1 -
 net/sched/sch_fq_codel.c     |    1 -
 net/sched/sch_hfsc.c         |    1 -
 net/sched/sch_htb.c          |    1 -
 net/sched/sch_ingress.c      |    1 -
 net/sched/sch_multiq.c       |    1 -
 net/sched/sch_prio.c         |    1 -
 net/sched/sch_qfq.c          |    1 -
 net/sched/sch_sfb.c          |    1 -
 net/sched/sch_sfq.c          |    1 -
 16 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index bf08e76bf505..208e5ed5256c 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -102,7 +102,7 @@ enum {
 #define TC_ACT_SHOT		2
 #define TC_ACT_PIPE		3
 #define TC_ACT_STOLEN		4
-#define TC_ACT_QUEUED		5
+#define TC_ACT_QUEUED		5 /* deprecated. same as TC_ACT_STOLEN */
 #define TC_ACT_REPEAT		6
 #define TC_ACT_JUMP		0x10000000
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ad9eed70bc8f..f7950327bb22 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1820,6 +1820,8 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 #ifdef CONFIG_NET_CLS_ACT
 			if (err != TC_ACT_RECLASSIFY && skb->tc_verd)
 				skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
+			if (err == TC_ACT_QUEUED)
+				return TC_ACT_STOLEN;
 #endif
 			return err;
 		}
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e3e2cc5fd068..7ef0bf4bdce6 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -396,7 +396,6 @@ done:
 		/*@@@ looks good ... but it's not supposed to work :-) */
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
 			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index beeb75f80fdb..eca4725e3273 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -258,7 +258,6 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			goto fallback;
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index c009eb9045ce..a3bc7cf151d3 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -212,7 +212,6 @@ static bool choke_classify(struct sk_buff *skb,
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return false;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 338706092c27..1051c5d4e85b 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -335,7 +335,6 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 66700a6116aa..ce9d4123cbbe 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -236,7 +236,6 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		switch (result) {
 #ifdef CONFIG_NET_CLS_ACT
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			kfree_skb(skb);
 			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 1e52decb7b59..4d00ece3243d 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -104,7 +104,6 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return 0;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e6c7416d0332..3438f9b4fd8b 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1168,7 +1168,6 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f1acb0f60dc3..32c1f081bed9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -232,7 +232,6 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index e68f4a5dbeba..63cbd1e066bd 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -69,7 +69,6 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	case TC_ACT_SHOT:
 		qdisc_qstats_drop(sch);
 	case TC_ACT_STOLEN:
-	case TC_ACT_QUEUED:
 		result = NET_XMIT_DROP;
 		kfree_skb(skb);
 		break;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 42dd218871e0..dc2a708a772c 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -50,7 +50,6 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 #ifdef CONFIG_NET_CLS_ACT
 	switch (err) {
 	case TC_ACT_STOLEN:
-	case TC_ACT_QUEUED:
 		*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 	case TC_ACT_SHOT:
 		return NULL;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 8e5cd34aaa74..de4825a9d0aa 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -46,7 +46,6 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 #ifdef CONFIG_NET_CLS_ACT
 		switch (err) {
 		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 3ec7e88a43ca..9d1e43ea0ccb 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -723,7 +723,6 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 5819dd82630d..61e18108d0d3 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -264,7 +264,6 @@ static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return false;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b877140beda5..b508ff655da3 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -207,7 +207,6 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return 0;
-- 
1.7.9.5
