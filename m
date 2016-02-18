From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v3 1/1] net_sched fix: reclassification needs to consider ether protocol changes
Date: Thu, 18 Feb 2016 07:38:04 -0500
Message-ID: <1455799084-6166-2-git-send-email-jhs@emojatatu.com>
References: <1455799084-6166-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35711 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425249AbcBRMiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 07:38:16 -0500
Received: by mail-ig0-f178.google.com with SMTP id hb3so11235983igb.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 04:38:16 -0800 (PST)
In-Reply-To: <1455799084-6166-1-git-send-email-jhs@emojatatu.com>
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
 net/sched/sch_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b5c2cf2..af1acf0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1852,6 +1852,7 @@ reset:
 	}
 
 	tp = old_tp;
+	protocol = tc_skb_protocol(skb);
 	goto reclassify;
 #endif
 }
-- 
1.9.1
