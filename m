From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] net: sched: introduce a TRAP control action
Date: Mon,  5 Jun 2017 16:38:27 +0200
Message-ID: <20170605143832.7025-2-jiri@resnulli.us>
References: <20170605143832.7025-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35629 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdFEOih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:38:37 -0400
Received: by mail-wr0-f195.google.com with SMTP id g76so7635325wrd.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 07:38:36 -0700 (PDT)
In-Reply-To: <20170605143832.7025-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There is need to instruct the HW offloaded path to push certain matched
packets to cpu/kernel for further analysis. So this patch introduces a
new TRAP control action to TC.

For kernel datapath, this action does not make much sense. So with the
same logic as in HW, new TRAP behaves similar to STOLEN. The skb is just
dropped in the datapath (and virtually ejected to an upper level, which
does not exist in case of kernel).

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
---
 include/uapi/linux/pkt_cls.h | 5 +++++
 net/core/dev.c               | 2 ++
 net/sched/cls_bpf.c          | 1 +
 net/sched/sch_atm.c          | 1 +
 net/sched/sch_cbq.c          | 1 +
 net/sched/sch_drr.c          | 1 +
 net/sched/sch_dsmark.c       | 1 +
 net/sched/sch_fq_codel.c     | 1 +
 net/sched/sch_hfsc.c         | 1 +
 net/sched/sch_htb.c          | 1 +
 net/sched/sch_multiq.c       | 1 +
 net/sched/sch_prio.c         | 1 +
 net/sched/sch_qfq.c          | 1 +
 net/sched/sch_sfb.c          | 1 +
 net/sched/sch_sfq.c          | 1 +
 15 files changed, 20 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index edf43dd..5d6f711 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -37,6 +37,11 @@ enum {
 #define TC_ACT_QUEUED		5
 #define TC_ACT_REPEAT		6
 #define TC_ACT_REDIRECT		7
+#define TC_ACT_TRAP		8 /* For hw path, this means "trap to cpu",
+				   * for sw path, this is equivalent of
+				   * TC_ACT_STOLEN - drop the skb and act
+				   * like everything is allright.
+				   */
 
 /* There is a special kind of actions called "extended actions",
  * which need a value parameter. These have a local opcode located in
diff --git a/net/core/dev.c b/net/core/dev.c
index 06e0a74..8f72f4a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3269,6 +3269,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
 		return NULL;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
+	case TC_ACT_TRAP:
 		*ret = NET_XMIT_SUCCESS;
 		consume_skb(skb);
 		return NULL;
@@ -4038,6 +4039,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
 		return NULL;
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
+	case TC_ACT_TRAP:
 		consume_skb(skb);
 		return NULL;
 	case TC_ACT_REDIRECT:
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5ebeae9..a9c56ad 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -70,6 +70,7 @@ static int cls_bpf_exec_opcode(int code)
 	case TC_ACT_OK:
 	case TC_ACT_SHOT:
 	case TC_ACT_STOLEN:
+	case TC_ACT_TRAP:
 	case TC_ACT_REDIRECT:
 	case TC_ACT_UNSPEC:
 		return code;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index f435546..de16259 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -406,6 +406,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			__qdisc_drop(skb, to_free);
 			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 8dd6d0a..481036f 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -254,6 +254,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 5db2a28..a413dc1 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -339,6 +339,7 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 7ccdd82..6d94fcc 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -243,6 +243,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 #ifdef CONFIG_NET_CLS_ACT
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			__qdisc_drop(skb, to_free);
 			return NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index f201e73..337f2d6 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -103,6 +103,7 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return 0;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index a324f84..b52f746 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1155,6 +1155,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 195bbca9..203286a 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -238,6 +238,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 6047674..f143b7b 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -52,6 +52,7 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	switch (err) {
 	case TC_ACT_STOLEN:
 	case TC_ACT_QUEUED:
+	case TC_ACT_TRAP:
 		*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 	case TC_ACT_SHOT:
 		return NULL;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a240468..e3e364c 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -48,6 +48,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		switch (err) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 076ad03..0e16dfd 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -726,6 +726,7 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return NULL;
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 9756b1c..11fb6ec 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -266,6 +266,7 @@ static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 		switch (result) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return false;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 66dfd15..f80ea2c 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -187,6 +187,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		switch (result) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
+		case TC_ACT_TRAP:
 			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
 		case TC_ACT_SHOT:
 			return 0;
-- 
2.9.3
