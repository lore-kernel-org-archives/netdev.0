From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs consistent
Date: Fri,  3 Apr 2015 14:16:24 -0700
Message-ID: <1428095784-7091-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34292 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbbDCVQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 17:16:32 -0400
Received: by pactp5 with SMTP id tp5so126930224pac.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 14:16:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF programs attached to ingress and egress qdiscs see inconsistent skb->data.
For ingress L2 header is already pulled, whereas for egress it's present.
That makes writing programs more difficult.
Make them consistent by pushing L2 before running the programs and pulling
it back afterwards.
Similar approach is taken by skb_defer_rx_timestamp() which does push/pull
before calling ptp_classify_raw()->BPF_PROG_RUN().

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

Looks like noone has tried bpf with ingress qdisc before, otherwise this
problem would have been found sooner.
This patch is probably not needed for 'net', since tc+bpf infra only starting
to come alive.

 net/sched/cls_bpf.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5c4171c5d2bd..b1cefd2037c9 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -66,6 +66,12 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct cls_bpf_prog *prog;
 	int ret = -1;
 
+	if (tp->q->flags & TCQ_F_INGRESS) {
+		if (skb_headroom(skb) < ETH_HLEN)
+			return -1;
+		__skb_push(skb, ETH_HLEN);
+	}
+
 	/* Needed here for accessing maps. */
 	rcu_read_lock();
 	list_for_each_entry_rcu(prog, &head->plist, link) {
@@ -86,6 +92,9 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	}
 	rcu_read_unlock();
 
+	if (tp->q->flags & TCQ_F_INGRESS)
+		__skb_pull(skb, ETH_HLEN);
+
 	return ret;
 }
 
-- 
1.7.9.5
