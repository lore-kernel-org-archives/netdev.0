From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 3/3] sched: cls_flow: fix panic on filter replace
Date: Fri, 17 Jul 2015 22:38:45 +0200
Message-ID: <e9ed6bbcf7e9d9b3fdbd3dd0b5117d9a284b4399.1437163466.git.daniel@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	edumazet@google.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56602 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbGQUiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:38:55 -0400
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
In-Reply-To: <cover.1437163466.git.daniel@iogearbox.net>
References: <cover.1437163466.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following test case causes a NULL pointer dereference in cls_flow:

  tc filter add dev foo parent 1: handle 0x1 flow hash keys dst action ok
  tc filter replace dev foo parent 1: pref 49152 handle 0x1 \
            flow hash keys mark action drop

To be more precise, actually two different panics are fixed, the first
occurs because tcf_exts_init() is not called on the newly allocated
filter when we do a replace. And the second panic uncovered after that
happens since the arguments of list_replace_rcu() are swapped, the old
element needs to be the first argument and the new element the second.

Fixes: 70da9f0bf999 ("net: sched: cls_flow use RCU")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_flow.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 76bc3a2..bb2a0f5 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -425,6 +425,8 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (!fnew)
 		goto err2;
 
+	tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+
 	fold = (struct flow_filter *)*arg;
 	if (fold) {
 		err = -EINVAL;
@@ -486,7 +488,6 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		fnew->mask  = ~0U;
 		fnew->tp = tp;
 		get_random_bytes(&fnew->hashrnd, 4);
-		tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 	}
 
 	fnew->perturb_timer.function = flow_perturbation;
@@ -526,7 +527,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (*arg == 0)
 		list_add_tail_rcu(&fnew->list, &head->filters);
 	else
-		list_replace_rcu(&fnew->list, &fold->list);
+		list_replace_rcu(&fold->list, &fnew->list);
 
 	*arg = (unsigned long)fnew;
 
-- 
1.9.3
