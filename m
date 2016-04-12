From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net v3] net: sched: do not requeue a NULL skb
Date: Tue, 12 Apr 2016 08:45:52 +0200
Message-ID: <1460443552-26710-1-git-send-email-larper@axis.com>
Cc: jhs@mojatatu.com, linux-kernel@vger.kernel.org,
	xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A failure in validate_xmit_skb_list() triggered an unconditional call
to dev_requeue_skb with skb=NULL. This slowly grows the queue
discipline's qlen count until all traffic through the queue stops.

We take the optimistic approach and continue running the queue after a
failure since it is unknown if later packets also will fail in the
validate path.

Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
Signed-off-by: Lars Persson <larper@axis.com>
---
v3: After a discussion with Eric and Cong I went back to v1 and added the
likely() for the common path.
---
 net/sched/sch_generic.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f18c350..80742ed 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -159,12 +159,15 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	if (validate)
 		skb = validate_xmit_skb_list(skb, dev);
 
-	if (skb) {
+	if (likely(skb)) {
 		HARD_TX_LOCK(dev, txq, smp_processor_id());
 		if (!netif_xmit_frozen_or_stopped(txq))
 			skb = dev_hard_start_xmit(skb, dev, txq, &ret);
 
 		HARD_TX_UNLOCK(dev, txq);
+	} else {
+		spin_lock(root_lock);
+		return qdisc_qlen(q);
 	}
 	spin_lock(root_lock);
 
-- 
2.1.4
