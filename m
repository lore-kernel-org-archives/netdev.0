From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net] net: sched: do not requeue a NULL skb
Date: Wed,  6 Apr 2016 15:10:14 +0200
Message-ID: <1459948214-735-1-git-send-email-larper@axis.com>
Cc: jhs@mojatatu.com, linux-kernel@vger.kernel.org,
	Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A failure in validate_xmit_skb_list() triggered an unconditional call
to dev_requeue_skb with skb=NULL. This slowly grows the queue
discipline's qlen count until all traffic through the queue stops.

Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
Signed-off-by: Lars Persson <larper@axis.com>
---
 net/sched/sch_generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f18c350..1031536 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -165,6 +165,9 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 			skb = dev_hard_start_xmit(skb, dev, txq, &ret);
 
 		HARD_TX_UNLOCK(dev, txq);
+	} else {
+		spin_lock(root_lock);
+		return qdisc_qlen(q);
 	}
 	spin_lock(root_lock);
 
-- 
2.1.4
