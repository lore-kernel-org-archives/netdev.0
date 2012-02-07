From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Subject: [PATCH] skbuff: Add new tc classify variable
Date: Tue,  7 Feb 2012 19:39:08 +0100
Message-ID: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nick.hrz.tu-chemnitz.de ([134.109.228.11]:37085 "EHLO
	nick.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756021Ab2BGSzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:55:23 -0500
Received: from p57aa11a5.dip0.t-ipconnect.de ([87.170.17.165] helo=pandem0nium)
	by nick.hrz.tu-chemnitz.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.76)
	(envelope-from <simon.wunderlich@s2003.tu-chemnitz.de>)
	id 1RupwX-0000XQ-FX
	for netdev@vger.kernel.org; Tue, 07 Feb 2012 19:39:10 +0100
Received: from dotslash by pandem0nium with local (Exim 4.72)
	(envelope-from <simon.wunderlich@s2003.tu-chemnitz.de>)
	id 1Rupwa-0006Zq-7z
	for netdev@vger.kernel.org; Tue, 07 Feb 2012 19:39:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The linux traffic control mechanism has different ways to select the
correct class of a qdisc. A common way to do this is to use tc filters
that are directly attached to a qdisc. Another approach is to use the
iptables classify module. The latter one can reduce the amount of work
necessary to process a packet when iptables is already involved in the
packet classification.

The iptables module can be used in the postrouting chain of the mangle
table.

# iptables -F -t mangle
# iptables -X -t mangle
# iptables -t mangle -I POSTROUTING -j CLASSIFY --set-class 1:1337

A simple qdisc with two classes will now route the traffic to 1:1337

# tc qdisc del dev eth0 root
# tc qdisc add dev eth0 root handle 1: htb default 1
# tc class add dev eth0 parent 1: classid 1:1 htb rate 15kbit burst 0kbit
# tc class add dev eth0 parent 1: classid 1:1337 htb rate 250kbit burst 0kbit
# tc -s class show dev eth0

A similar test with an ath9k device will show a complete different
behavior. The default class 1:1 will be used and data is sent through.
This problem seems to be related to the fact that the shared member
variable sk_buff::priority is used to store the tc class id of an
outgoing packet. This variable is also used in other places for
different purposes. An example is the ieee80211_select_queue function
which always overwrites the priority of an outgoing skb.

This conflict can be resolved by an additional member variable
sk_buff::tc_class that is only used for the traffic control
classification.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Marek Lindner <lindner_marek@yahoo.de>
Cc: Sven Eckelmann <sven@narfation.org>
Cc: netfilter-devel@vger.kernel.org
Cc: netfilter@vger.kernel.org
Cc: coreteam@netfilter.org
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
---
 include/linux/skbuff.h      |    2 ++
 net/netfilter/xt_CLASSIFY.c |    4 ++--
 net/sched/sch_atm.c         |    4 ++--
 net/sched/sch_cbq.c         |    2 +-
 net/sched/sch_drr.c         |    4 ++--
 net/sched/sch_dsmark.c      |    4 ++--
 net/sched/sch_generic.c     |    2 +-
 net/sched/sch_hfsc.c        |    4 ++--
 net/sched/sch_htb.c         |    6 +++---
 net/sched/sch_prio.c        |    4 ++--
 net/sched/sch_sfq.c         |    8 ++++----
 11 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 50db9b0..3ffc301 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -352,6 +352,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
+ *	@tc_class: Classification index
  *	@tc_verd: traffic control verdict
  *	@rxhash: the packet hash computed on receive
  *	@queue_mapping: Queue mapping for multiqueue devices
@@ -439,6 +440,7 @@ struct sk_buff {
 
 	int			skb_iif;
 #ifdef CONFIG_NET_SCHED
+	__u32			tc_class;	/* traffic control class */
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
 	__u16			tc_verd;	/* traffic control verdict */
diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
index af9c4da..9b71957 100644
--- a/net/netfilter/xt_CLASSIFY.c
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -1,5 +1,5 @@
 /*
- * This is a module which is used for setting the skb->priority field
+ * This is a module which is used for setting the skb->tc_class field
  * of an skb for qdisc classification.
  */
 
@@ -33,7 +33,7 @@ classify_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_classify_target_info *clinfo = par->targinfo;
 
-	skb->priority = clinfo->priority;
+	skb->tc_class = clinfo->priority;
 	return XT_CONTINUE;
 }
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e25e490..003511a 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -369,8 +369,8 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	pr_debug("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 	result = TC_POLICE_OK;	/* be nice to gcc */
 	flow = NULL;
-	if (TC_H_MAJ(skb->priority) != sch->handle ||
-	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
+	if (TC_H_MAJ(skb->tc_class) != sch->handle ||
+	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->tc_class))) {
 		list_for_each_entry(flow, &p->flows, list) {
 			if (flow->filter_list) {
 				result = tc_classify_compat(skb,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 24d94c0..b1321f9 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -221,7 +221,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct cbq_class *head = &q->link;
 	struct cbq_class **defmap;
 	struct cbq_class *cl = NULL;
-	u32 prio = skb->priority;
+	u32 prio = skb->tc_class;
 	struct tcf_result res;
 
 	/*
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 6b7fe4a..57b1ca2 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -321,8 +321,8 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	struct tcf_result res;
 	int result;
 
-	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0) {
-		cl = drr_find_class(sch, skb->priority);
+	if (TC_H_MAJ(skb->tc_class ^ sch->handle) == 0) {
+		cl = drr_find_class(sch, skb->tc_class);
 		if (cl != NULL)
 			return cl;
 	}
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 2c79020..60cfe15 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -224,8 +224,8 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 	}
 
-	if (TC_H_MAJ(skb->priority) == sch->handle)
-		skb->tc_index = TC_H_MIN(skb->priority);
+	if (TC_H_MAJ(skb->tc_class) == sch->handle)
+		skb->tc_index = TC_H_MIN(skb->tc_class);
 	else {
 		struct tcf_result res;
 		int result = tc_classify(skb, p->filter_list, &res);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 67fc573..c14779a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -449,7 +449,7 @@ static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 {
 	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
-		int band = prio2band[skb->priority & TC_PRIO_MAX];
+		int band = prio2band[skb->tc_class & TC_PRIO_MAX];
 		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 		struct sk_buff_head *list = band2list(priv, band);
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 9bdca2e..2fcc6ef 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1154,8 +1154,8 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	struct tcf_proto *tcf;
 	int result;
 
-	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0 &&
-	    (cl = hfsc_find_class(skb->priority, sch)) != NULL)
+	if (TC_H_MAJ(skb->tc_class ^ sch->handle) == 0 &&
+	    (cl = hfsc_find_class(skb->tc_class, sch)) != NULL)
 		if (cl->level == 0)
 			return cl;
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 29b942c..ef8dd42 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -197,13 +197,13 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	struct tcf_proto *tcf;
 	int result;
 
-	/* allow to select class by setting skb->priority to valid classid;
+	/* allow to select class by setting skb->tc_class to valid classid;
 	 * note that nfmark can be used too by attaching filter fw with no
 	 * rules in it
 	 */
-	if (skb->priority == sch->handle)
+	if (skb->tc_class == sch->handle)
 		return HTB_DIRECT;	/* X:0 (direct flow) selected */
-	cl = htb_find(skb->priority, sch);
+	cl = htb_find(skb->tc_class, sch);
 	if (cl && cl->level == 0)
 		return cl;
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index b5d56a2..f53a5b99 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -34,12 +34,12 @@ static struct Qdisc *
 prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
-	u32 band = skb->priority;
+	u32 band = skb->tc_class;
 	struct tcf_result res;
 	int err;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	if (TC_H_MAJ(skb->priority) != sch->handle) {
+	if (TC_H_MAJ(skb->tc_class) != sch->handle) {
 		err = tc_classify(skb, q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
 		switch (err) {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 67494ae..79bc0ac 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -190,10 +190,10 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	struct tcf_result res;
 	int result;
 
-	if (TC_H_MAJ(skb->priority) == sch->handle &&
-	    TC_H_MIN(skb->priority) > 0 &&
-	    TC_H_MIN(skb->priority) <= q->divisor)
-		return TC_H_MIN(skb->priority);
+	if (TC_H_MAJ(skb->tc_class) == sch->handle &&
+	    TC_H_MIN(skb->tc_class) > 0 &&
+	    TC_H_MIN(skb->tc_class) <= q->divisor)
+		return TC_H_MIN(skb->tc_class);
 
 	if (!q->filter_list) {
 		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
-- 
1.7.8.3
