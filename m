From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Fri, 10 Jul 2015 17:10:11 -0700
Message-ID: <1436573411-5021-1-git-send-email-ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35383 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbbGKHEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 03:04:32 -0400
Received: by pdrg1 with SMTP id g1so63729437pdr.2
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2015 00:04:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC actions need to check for very unlikely event skb->users != 1,
otherwise subsequent pskb_may_pull/pskb_expand_head will crash.
When skb_shared() just drop the packet, since in the middle of actions
it's too late to call skb_share_check(), since classifiers/actions assume
the same skb pointer.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/sched/act_csum.c |    3 +++
 net/sched/act_nat.c  |    3 +++
 net/sched/act_vlan.c |    3 +++
 3 files changed, 9 insertions(+)

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index b07c535ba8e7..ac150bdc24f4 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -510,6 +510,9 @@ static int tcf_csum(struct sk_buff *skb,
 	if (unlikely(action == TC_ACT_SHOT))
 		goto drop;
 
+	if (unlikely(skb_shared(skb)))
+		goto drop;
+
 	switch (tc_skb_protocol(skb)) {
 	case cpu_to_be16(ETH_P_IP):
 		if (!tcf_csum_ipv4(skb, update_flags))
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 5be0b3c1c5b0..8bb2657de635 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -114,6 +114,9 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 	if (unlikely(action == TC_ACT_SHOT))
 		goto drop;
 
+	if (unlikely(skb_shared(skb)))
+		goto drop;
+
 	noff = skb_network_offset(skb);
 	if (!pskb_may_pull(skb, sizeof(*iph) + noff))
 		goto drop;
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 796785e0bf96..6365ae036c6e 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -33,6 +33,9 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 	bstats_update(&v->tcf_bstats, skb);
 	action = v->tcf_action;
 
+	if (unlikely(skb_shared(skb)))
+		goto drop;
+
 	switch (v->tcfv_action) {
 	case TCA_VLAN_ACT_POP:
 		err = skb_vlan_pop(skb);
-- 
1.7.9.5
