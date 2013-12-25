From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/2] sch_netem: support of 64bit rates
Date: Wed, 25 Dec 2013 17:35:15 +0800
Message-ID: <1387964115-31168-3-git-send-email-yangyingliang@huawei.com>
References: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:11002 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731Ab3LYJfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 04:35:24 -0500
In-Reply-To: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new attribute to support 64bit rates so that
tc can use them to break the 32bit limit.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/uapi/linux/pkt_sched.h |  1 +
 net/sched/sch_netem.c          | 15 +++++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 4566993..8c3b8c4 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -523,6 +523,7 @@ enum {
 	TCA_NETEM_LOSS,
 	TCA_NETEM_RATE,
 	TCA_NETEM_ECN,
+	TCA_NETEM_RATE64,
 	__TCA_NETEM_MAX,
 };
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9632a4e..090a4e3 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -88,7 +88,7 @@ struct netem_sched_data {
 	u32 duplicate;
 	u32 reorder;
 	u32 corrupt;
-	u32 rate;
+	u64 rate;
 	s32 packet_overhead;
 	u32 cell_size;
 	u32 cell_size_reciprocal;
@@ -782,6 +782,7 @@ static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
 	[TCA_NETEM_RATE]	= { .len = sizeof(struct tc_netem_rate) },
 	[TCA_NETEM_LOSS]	= { .type = NLA_NESTED },
 	[TCA_NETEM_ECN]		= { .type = NLA_U32 },
+	[TCA_NETEM_RATE64]	= { .type = NLA_U64 },
 };
 
 static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
@@ -852,6 +853,10 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_NETEM_RATE])
 		get_rate(sch, tb[TCA_NETEM_RATE]);
 
+	if (tb[TCA_NETEM_RATE64])
+		q->rate = max_t(u64, q->rate,
+				nla_get_u64(tb[TCA_NETEM_RATE64]));
+
 	if (tb[TCA_NETEM_ECN])
 		q->ecn = nla_get_u32(tb[TCA_NETEM_ECN]);
 
@@ -974,7 +979,13 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (nla_put(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt))
 		goto nla_put_failure;
 
-	rate.rate = q->rate;
+	if (q->rate >= (1ULL << 32)) {
+		if (nla_put_u64(skb, TCA_NETEM_RATE64, q->rate))
+			goto nla_put_failure;
+		rate.rate = ~0U;
+	} else {
+		rate.rate = q->rate;
+	}
 	rate.packet_overhead = q->packet_overhead;
 	rate.cell_size = q->cell_size;
 	rate.cell_overhead = q->cell_overhead;
-- 
1.8.0
