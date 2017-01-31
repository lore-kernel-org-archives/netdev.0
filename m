From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next 1/2] net/sched: act_sample: Fix error path in init
Date: Tue, 31 Jan 2017 11:33:53 +0200
Message-ID: <1485855234-9941-2-git-send-email-yotamg@mellanox.com>
References: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46503 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751206AbdAaJcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:32:07 -0500
In-Reply-To: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix error path of in sample init, by releasing the tc hash in case of
failure in psample_group creation.

Fixes: 5c5670fae430 ("net/sched: Introduce sample tc action")
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/act_sample.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 3922975..02b6749 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -81,8 +81,11 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 	s->rate = nla_get_u32(tb[TCA_SAMPLE_RATE]);
 	s->psample_group_num = nla_get_u32(tb[TCA_SAMPLE_PSAMPLE_GROUP]);
 	psample_group = psample_group_get(net, s->psample_group_num);
-	if (!psample_group)
+	if (!psample_group) {
+		if (ret == ACT_P_CREATED)
+			tcf_hash_release(*a, bind);
 		return -ENOMEM;
+	}
 	RCU_INIT_POINTER(s->psample_group, psample_group);
 
 	if (tb[TCA_SAMPLE_TRUNC_SIZE]) {
-- 
2.4.11
