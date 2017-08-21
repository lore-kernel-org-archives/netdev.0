From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched/hhf: update hierarchical backlog when drop packet
Date: Mon, 21 Aug 2017 11:12:31 +0300
Message-ID: <150330315167.155003.1998024290510727078.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:55231 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751750AbdHUIMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 04:12:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hhf_enqueue() drops packet from another bucket it
have to update backlog at upper qdiscs too.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
---
 net/sched/sch_hhf.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 51d3ba682af9..c8d84436e427 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -406,8 +406,11 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	/* Return Congestion Notification only if we dropped a packet from this
 	 * bucket.
 	 */
-	if (hhf_drop(sch, to_free) == idx)
+	if (hhf_drop(sch, to_free) == idx) {
+		qdisc_tree_reduce_backlog(sch, 0,
+					  prev_backlog - sch->qstats.backlog);
 		return NET_XMIT_CN;
+	}
 
 	/* As we dropped a packet, better let upper stack know this. */
 	qdisc_tree_reduce_backlog(sch, 1, prev_backlog - sch->qstats.backlog);
