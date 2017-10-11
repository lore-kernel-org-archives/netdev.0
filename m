From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 1/3] sched: act: ife: move encode/decode check to init
Date: Wed, 11 Oct 2017 17:16:06 -0400
Message-ID: <20171011211608.22692-2-aring@mojatatu.com>
References: <20171011211608.22692-1-aring@mojatatu.com>
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:46541 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752760AbdJKVQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:16:40 -0400
Received: by mail-io0-f195.google.com with SMTP id 101so3292798ioj.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:16:39 -0700 (PDT)
In-Reply-To: <20171011211608.22692-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the check of the two possible ife handlings encode
and decode to the init callback. The decode value is for usability
aspect and used in userspace code only. The current code offers encode
else decode only. This patch avoids any other option than this.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 net/sched/act_ife.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 8ccd35825b6b..efac8a32c30a 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -450,6 +450,13 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_IFE_PARMS]);
 
+	/* IFE_DECODE is 0 and indicates the opposite of IFE_ENCODE because
+	 * they cannot run as the same time. Check on all other values which
+	 * are not supported right now.
+	 */
+	if (parm->flags & ~IFE_ENCODE)
+		return -EINVAL;
+
 	exists = tcf_idr_check(tn, parm->index, a, bind);
 	if (exists && bind)
 		return 0;
@@ -772,17 +779,7 @@ static int tcf_ife_act(struct sk_buff *skb, const struct tc_action *a,
 	if (ife->flags & IFE_ENCODE)
 		return tcf_ife_encode(skb, a, res);
 
-	if (!(ife->flags & IFE_ENCODE))
-		return tcf_ife_decode(skb, a, res);
-
-	pr_info_ratelimited("unknown failure(policy neither de/encode\n");
-	spin_lock(&ife->tcf_lock);
-	bstats_update(&ife->tcf_bstats, skb);
-	tcf_lastuse_update(&ife->tcf_tm);
-	ife->tcf_qstats.drops++;
-	spin_unlock(&ife->tcf_lock);
-
-	return TC_ACT_SHOT;
+	return tcf_ife_decode(skb, a, res);
 }
 
 static int tcf_ife_walker(struct net *net, struct sk_buff *skb,
-- 
2.11.0
