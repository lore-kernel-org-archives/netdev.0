From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Tue,  7 Apr 2015 18:03:45 -0700
Message-ID: <1428455025-5945-2-git-send-email-ast@plumgrid.com>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35437 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbbDHBD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 21:03:56 -0400
Received: by pddn5 with SMTP id n5so96733694pdd.2
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 18:03:56 -0700 (PDT)
In-Reply-To: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC classifers and actions attached to ingress and egress qdiscs see
inconsistent skb->data. For ingress L2 header is already pulled, whereas
for egress it's present. Make them consistent by pushing L2 before calling
into classifiers/actions and pulling L2 back afterwards.

The following cls/act assume L2 and were broken on ingress before this commit:
cls_bpf, act_bpf, cls_rsvp, cls_cgroup, act_csum, act_nat, all of ematch.

All other in-tree cls/act use skb_network_offset() accessors for skb data
and work regardless whether L2 was pulled or not.

Since L2 is now present on ingress update act_mirred (the only action that
was aware of L2 differences) and fix two bugs in it:
- it was forwarding packets with L2 present to tunnel devices if used
  with egress qdisc
- it wasn't updating skb->csum with ingress qdisc
Also rename 'ok_push' to 'needs_l2' to make it more readable.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

V1->V2:
. major refactoring: move push/pull into ingress qdisc
. use dev->hard_header_len instead of hard coding ETH_HLEN
. remove now obsolete hack in samples/bpf/ example

cls_rsvp, act_csum, act_nat may appear to work on ingress, since they're using
skb_*_offset(), but they do pskb_may_pull() assuming L2 is present.
ematches are hard coding skb->data to mean L2 in few places.

The fix may break out-of-tree ingress classifiers that rely on lack of L2 and
which use skb->data directly.

Alternative approach would be to do full push/pull with csum recompute
in ingress_enqueue() which will simplify act_mirred. Not sure which is better.

 include/net/tc_act/tc_mirred.h |    2 +-
 net/sched/act_mirred.c         |   30 ++++++++++++++++++++++--------
 net/sched/sch_ingress.c        |    8 ++++++++
 samples/bpf/tcbpf1_kern.c      |    6 ------
 4 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 4dd77a1c106b..f0cddd81bd6c 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -7,7 +7,7 @@ struct tcf_mirred {
 	struct tcf_common	common;
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
-	int			tcfm_ok_push;
+	int			tcfm_needs_l2;
 	struct net_device	*tcfm_dev;
 	struct list_head	tcfm_list;
 };
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5953517ec059..c015d1c43db7 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -52,7 +52,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct net_device *dev;
-	int ret, ok_push = 0;
+	int ret, needs_l2 = 0;
 
 	if (nla == NULL)
 		return -EINVAL;
@@ -80,10 +80,10 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		case ARPHRD_IPGRE:
 		case ARPHRD_VOID:
 		case ARPHRD_NONE:
-			ok_push = 0;
+			needs_l2 = 0;
 			break;
 		default:
-			ok_push = 1;
+			needs_l2 = 1;
 			break;
 		}
 	} else {
@@ -114,7 +114,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			dev_put(m->tcfm_dev);
 		dev_hold(dev);
 		m->tcfm_dev = dev;
-		m->tcfm_ok_push = ok_push;
+		m->tcfm_needs_l2 = needs_l2;
 	}
 	spin_unlock_bh(&m->tcf_lock);
 	if (ret == ACT_P_CREATED) {
@@ -131,7 +131,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	u32 at;
+	u32 at, hard_header_len;
 	int retval, err = 1;
 
 	spin_lock(&m->tcf_lock);
@@ -155,9 +155,23 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	if (skb2 == NULL)
 		goto out;
 
-	if (!(at & AT_EGRESS)) {
-		if (m->tcfm_ok_push)
-			skb_push(skb2, skb2->dev->hard_header_len);
+	hard_header_len = skb2->dev->hard_header_len;
+
+	if (!m->tcfm_needs_l2) {
+		/* in packets arriving on egress qdiscs skb->csum (complete)
+		 * includes L2, whereas ingress_enqueue() only pushes L2 without
+		 * updating skb->csum.
+		 * So pull L2 here to undo push done by ingress_enqueue()
+		 * and do pull_rcsum for fully checksummed packets
+		 */
+		if (at & AT_INGRESS)
+			skb_pull(skb2, hard_header_len);
+		else
+			skb_pull_rcsum(skb2, hard_header_len);
+	} else {
+		/* ingress_enqueue() already pushed L2, recompute csum here */
+		if (at & AT_INGRESS)
+			skb_postpush_rcsum(skb2, skb2->data, hard_header_len);
 	}
 
 	/* mirror is always swallowed */
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index eb5b8445fef9..658b46082269 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -61,9 +61,17 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 	struct tcf_result res;
 	struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
+	unsigned int hard_header_len = skb->dev->hard_header_len;
 	int result;
 
+	if (unlikely(skb_headroom(skb) < hard_header_len))
+		/* should never happen, since L2 was just pulled on ingress */
+		return TC_ACT_OK;
+
+	/* don't recompute skb->csum back and forth while pushing/pulling L2 */
+	__skb_push(skb, hard_header_len);
 	result = tc_classify(skb, fl, &res);
+	__skb_pull(skb, hard_header_len);
 
 	qdisc_bstats_update(sch, skb);
 	switch (result) {
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
index 7cf3f42a6e39..76cdaab63058 100644
--- a/samples/bpf/tcbpf1_kern.c
+++ b/samples/bpf/tcbpf1_kern.c
@@ -14,12 +14,6 @@ static inline void set_dst_mac(struct __sk_buff *skb, char *mac)
 	bpf_skb_store_bytes(skb, 0, mac, ETH_ALEN, 1);
 }
 
-/* use 1 below for ingress qdisc and 0 for egress */
-#if 0
-#undef ETH_HLEN
-#define ETH_HLEN 0
-#endif
-
 #define IP_CSUM_OFF (ETH_HLEN + offsetof(struct iphdr, check))
 #define TOS_OFF (ETH_HLEN + offsetof(struct iphdr, tos))
 
-- 
1.7.9.5
