From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 3/7] sch_netem: clear old reorder when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:06 +0800
Message-ID: <1392366970-11592-4-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:58745 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaBNIg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:27 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with reorder option, while we
use "#tc qdisc replace ..." that without reorder option
to replace the old qdisc, the old reorder is still there.
We need clear old reorder after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index fd2206d..bb06dd8 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -711,6 +711,12 @@ static void get_reorder(struct netem_sched_data *q, const struct nlattr *attr)
 	init_crandom(&q->reorder_cor, r->correlation);
 }
 
+static void reorder_reset(struct netem_sched_data *q)
+{
+	q->reorder = 0;
+	memset(&q->reorder_cor, 0, sizeof(struct crndstate));
+}
+
 static void get_corrupt(struct netem_sched_data *q, const struct nlattr *attr)
 {
 	const struct tc_netem_corrupt *r = nla_data(attr);
@@ -879,12 +885,16 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	 */
 	if (q->gap)
 		q->reorder = ~0;
+	else
+		q->reorder = 0;
 
 	if (tb[TCA_NETEM_CORR])
 		get_correlation(q, tb[TCA_NETEM_CORR]);
 
 	if (tb[TCA_NETEM_REORDER])
 		get_reorder(q, tb[TCA_NETEM_REORDER]);
+	else
+		reorder_reset(q);
 
 	if (tb[TCA_NETEM_CORRUPT])
 		get_corrupt(q, tb[TCA_NETEM_CORRUPT]);
-- 
1.8.0
