From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 1/1] net_sched fix: reclassification needs to consider ether protocol changes
Date: Tue, 16 Feb 2016 07:37:05 -0500
Message-ID: <1455626225-16382-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35325 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005AbcBPMhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:37:14 -0500
Received: by mail-ig0-f169.google.com with SMTP id hb3so71991785igb.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:37:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

actions could change the etherproto in particular with ethernet
tunnelled data. Typically such actions, after peeling the outer header,
will ask for the packet to be  reclassified. We then need to restart
the classification with the new proto header.

Example setup used to catch this:
sudo tc qdisc add dev $ETH ingress
sudo $TC filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \
u32 match u32 0 0 flowid 1:1 \
action vlan pop reclassify

Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_api.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b5c2cf2..22ab634 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1818,13 +1818,14 @@ done:
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		struct tcf_result *res, bool compat_mode)
 {
-	__be16 protocol = tc_skb_protocol(skb);
 #ifdef CONFIG_NET_CLS_ACT
-	const struct tcf_proto *old_tp = tp;
 	int limit = 0;
+#endif
+	const struct tcf_proto *old_tp = tp;
+	__be16 protocol;
 
 reclassify:
-#endif
+	protocol = tc_skb_protocol(skb);
 	for (; tp; tp = rcu_dereference_bh(tp->next)) {
 		int err;
 
-- 
1.9.1
