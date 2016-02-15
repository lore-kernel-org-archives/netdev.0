From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] net_sched fix: reclassification needs to consider ether protocol changes
Date: Mon, 15 Feb 2016 14:49:09 -0500
Message-ID: <1455565749-30951-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:32799 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbcBOTtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 14:49:22 -0500
Received: by mail-ig0-f193.google.com with SMTP id hb3so7172272igb.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 11:49:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

actions could change the etherproto in particular with ethernet
tunnelled data. Typically such actions, after peeling the outer header,
will ask for the packet to be  reclassified. We then need to restart
the classification with the new proto header.

Example setup used to catch this:
sudo tc qdisc add dev $ETH ingress
sudo tc filter add dev $ETH parent ffff: prio 2 protocol 0xbeef \
u32 match u32 0 0 flowid 1:1 \
action ife decode reclassify

Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_api.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b5c2cf2..07cfb54 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1818,12 +1818,13 @@ done:
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		struct tcf_result *res, bool compat_mode)
 {
-	__be16 protocol = tc_skb_protocol(skb);
 #ifdef CONFIG_NET_CLS_ACT
 	const struct tcf_proto *old_tp = tp;
 	int limit = 0;
+	__be16 protocol;
 
 reclassify:
+	protocol = tc_skb_protocol(skb);
 #endif
 	for (; tp; tp = rcu_dereference_bh(tp->next)) {
 		int err;
-- 
1.9.1
