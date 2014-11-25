From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 3/3] sch_fq: segment too big GSO packets
Date: Tue, 25 Nov 2014 21:24:52 +0800
Message-ID: <1416921892-4756-4-git-send-email-yangyingliang@huawei.com>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54739 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338AbaKYNZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 08:25:10 -0500
In-Reply-To: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a GSO packet cost more than 125ms to send, segment the
packet and send individual segments.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_fq.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index ec6eff8..0119340 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -423,6 +423,30 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return qdisc_drop(skb, sch);
 	}
 
+	if (skb_is_gso(skb) && skb_is_too_big(skb, q, NULL)) {
+		struct sk_buff *segs, *nskb;
+		netdev_features_t features = netif_skb_features(skb);
+		int nb = 0;
+
+		segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
+
+		if (IS_ERR_OR_NULL(segs))
+			goto enqueue_out;
+
+		while (segs) {
+			nskb = segs->next;
+			qdisc_skb_cb(segs)->pkt_len = segs->len;
+			__fq_enqueue(segs, sch, f);
+			nb++;
+			segs = nskb;
+		}
+		if (nb > 1)
+			qdisc_tree_decrease_qlen(sch, 1 - nb);
+		consume_skb(skb);
+		return NET_XMIT_SUCCESS;
+	}
+
+enqueue_out:
 	return __fq_enqueue(skb, sch, f);
 }
 
-- 
1.8.0
