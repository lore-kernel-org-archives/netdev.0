From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: drop unnecessary test in cls_bpf_classify and tcf_bpf
Date: Mon, 12 Sep 2016 23:38:42 +0200
Message-ID: <ae3aa7909739828d317cd6110b320f41d2bcff99.1473715365.git.daniel@iogearbox.net>
References: <cover.1473715365.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42373 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbcILVjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 17:39:00 -0400
In-Reply-To: <cover.1473715365.git.daniel@iogearbox.net>
In-Reply-To: <cover.1473715365.git.daniel@iogearbox.net>
References: <cover.1473715365.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_mac_header_was_set() test in cls_bpf's and act_bpf's fast-path is
actually unnecessary and can be removed altogether. This was added by
commit a166151cbe33 ("bpf: fix bpf helpers to use skb->mac_header relative
offsets"), which was later on improved by 3431205e0397 ("bpf: make programs
see skb->data == L2 for ingress and egress"). We're always guaranteed to
have valid mac header at the time we invoke cls_bpf_classify() or tcf_bpf().

Reason is that since 6d1ccff62780 ("net: reset mac header in dev_start_xmit()")
we do skb_reset_mac_header() in __dev_queue_xmit() before we could call
into sch_handle_egress() or any subsequent enqueue. sch_handle_ingress()
always sees a valid mac header as well (things like skb_reset_mac_len()
would badly fail otherwise). Thus, drop the unnecessary test in classifier
and action case.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/sched/act_bpf.c | 3 ---
 net/sched/cls_bpf.c | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index bfa8707..78400de 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -44,9 +44,6 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 	int action, filter_res;
 	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
 
-	if (unlikely(!skb_mac_header_was_set(skb)))
-		return TC_ACT_UNSPEC;
-
 	tcf_lastuse_update(&prog->tcf_tm);
 	bstats_cpu_update(this_cpu_ptr(prog->common.cpu_bstats), skb);
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 4742f41..1d92d4d 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -83,9 +83,6 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	struct cls_bpf_prog *prog;
 	int ret = -1;
 
-	if (unlikely(!skb_mac_header_was_set(skb)))
-		return -1;
-
 	/* Needed here for accessing maps. */
 	rcu_read_lock();
 	list_for_each_entry_rcu(prog, &head->plist, link) {
-- 
1.9.3
