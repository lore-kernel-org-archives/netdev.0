From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: sched: optimize class dumps
Date: Wed, 10 May 2017 21:59:28 -0700
Message-ID: <1494478768.7796.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Kosina <jkosina@suse.cz>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34670 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754696AbdEKE7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 00:59:36 -0400
Received: by mail-pg0-f68.google.com with SMTP id u187so2074394pgb.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 21:59:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 59cc1f61f09c ("net: sched: convert qdisc linked list to
hashtable") we missed the opportunity to considerably speed up
tc_dump_tclass_root() if a qdisc handle is provided by user.

Instead of iterating all the qdiscs, use qdisc_match_from_root()
to directly get the one we look for.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_api.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bbe57d57b67fd498692bd41db49147511f1bb091..e88342fde1bc409aed6a3c86e7a628030eaac66f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1831,6 +1831,12 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
 	if (!qdisc_dev(root))
 		return 0;
 
+	if (tcm->tcm_parent) {
+		q = qdisc_match_from_root(root, TC_H_MAJ(tcm->tcm_parent));
+		if (q && tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
+			return -1;
+		return 0;
+	}
 	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
 		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
 			return -1;
