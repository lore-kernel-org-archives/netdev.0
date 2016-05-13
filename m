From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 2/8] net/sched: act_gact: Update statistics when offloaded to hardware
Date: Fri, 13 May 2016 12:55:36 +0000
Message-ID: <1463144142-13810-3-git-send-email-amir@vadai.me>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41782 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751625AbcEMM5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:57:42 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

Implement the stats_update callback that will be called by NIC drivers
for hardware offloaded filters.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 net/sched/act_gact.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 1a6e09f..ec5cc84 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -148,6 +148,20 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 	return action;
 }
 
+static void tcf_gact_stats_update(struct tc_action *a, u64 bytes, u32 packets,
+				  u64 lastuse)
+{
+	struct tcf_gact *gact = a->priv;
+	int action = READ_ONCE(gact->tcf_action);
+	struct tcf_t *tm = &gact->tcf_tm;
+
+	_bstats_cpu_update(this_cpu_ptr(gact->common.cpu_bstats), bytes, packets);
+	if (action == TC_ACT_SHOT)
+		this_cpu_ptr(gact->common.cpu_qstats)->drops += packets;
+
+	tm->lastuse = lastuse;
+}
+
 static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
@@ -207,6 +221,7 @@ static struct tc_action_ops act_gact_ops = {
 	.type		=	TCA_ACT_GACT,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_gact,
+	.stats_update	=	tcf_gact_stats_update,
 	.dump		=	tcf_gact_dump,
 	.init		=	tcf_gact_init,
 	.walk		=	tcf_gact_walker,
-- 
2.8.0
