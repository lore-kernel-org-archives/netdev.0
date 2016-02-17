From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 1/1] net_sched fix: reclassification needs to consider ether protocol changes
Date: Wed, 17 Feb 2016 06:37:35 -0500
Message-ID: <1455709055-30881-2-git-send-email-jhs@emojatatu.com>
References: <1455709055-30881-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38384 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422658AbcBQLhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:37:53 -0500
Received: by mail-ig0-f180.google.com with SMTP id y8so12867275igp.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:37:53 -0800 (PST)
In-Reply-To: <1455709055-30881-1-git-send-email-jhs@emojatatu.com>
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
action  vlan pop reclassify

Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b5c2cf2..af46fee 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1822,7 +1822,6 @@ int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 #ifdef CONFIG_NET_CLS_ACT
 	const struct tcf_proto *old_tp = tp;
 	int limit = 0;
-
 reclassify:
 #endif
 	for (; tp; tp = rcu_dereference_bh(tp->next)) {
@@ -1852,6 +1851,7 @@ reset:
 	}
 
 	tp = old_tp;
+	protocol = tc_skb_protocol(skb);
 	goto reclassify;
 #endif
 }
-- 
1.9.1
