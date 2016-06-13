From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] act_ipt: fix a bind refcnt leak
Date: Mon, 13 Jun 2016 13:44:14 -0700
Message-ID: <1465850654-27128-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34381 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422685AbcFMUoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:44:20 -0400
Received: by mail-pa0-f68.google.com with SMTP id ug1so11100911pab.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 13:44:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And avoid calling tcf_hash_check() twice.

Fixes: a57f19d30b2d ("net sched: ipt action fix late binding")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_ipt.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 9f002ad..d4bd19e 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -121,10 +121,13 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	}
 
 	td = (struct xt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
-	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size)
+	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size) {
+		if (exists)
+			tcf_hash_release(a, bind);
 		return -EINVAL;
+	}
 
-	if (!tcf_hash_check(tn, index, a, bind)) {
+	if (!exists) {
 		ret = tcf_hash_create(tn, index, est, a, sizeof(*ipt), bind,
 				      false);
 		if (ret)
-- 
2.1.0
