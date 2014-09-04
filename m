From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V2 3/3] qdisc: debug statements while testing
	prev-patch
Date: Thu, 04 Sep 2014 14:56:00 +0200
Message-ID: <20140904125554.4108.97003.stgit@dragon>
References: <20140904125247.4108.8132.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754442AbaIDM4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 08:56:11 -0400
In-Reply-To: <20140904125247.4108.8132.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not-signed-off
---

 net/sched/sch_generic.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a0c8070..8c8ac40 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -47,8 +47,20 @@ EXPORT_SYMBOL(default_qdisc_ops);
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
+	int bytelimit = netdev_tx_avail_queue(q->dev_queue); //DEBUG
+
 	skb_dst_force(skb);
 	q->gso_skb = skb;
+
+	if (skb->next) // DEBUG
+		net_warn_ratelimited(
+			"%s() dev:%s REQUEUEd SKB list len:%d bql:%d\n",
+			__func__, q->dev_queue->dev->name, bytelimit, skb->len);
+	else if (skb_is_gso(skb)) // DEBUG
+		net_warn_ratelimited(
+			"%s() dev:%s REQUEUEd GSO      len:%d bql:%d\n",
+			__func__, q->dev_queue->dev->name, bytelimit, skb->len);
+
 	q->qstats.requeues++;
 	q->q.qlen++;	/* it's still part of the queue */
 	__netif_schedule(q);
@@ -76,9 +88,11 @@ static inline struct sk_buff *qdisc_bulk_dequeue_skb(struct Qdisc *q,
 						     struct sk_buff *head)
 {
 	struct sk_buff *new, *skb = head;
+//??	struct netdev_queue *txq = skb_get_tx_queue(dev, skb); //which to choose?
 	struct netdev_queue *txq = q->dev_queue;
 	int bytelimit = netdev_tx_avail_queue(txq);
 	int limit = 5;
+	int cnt = 0; //DEBUG
 
 	if (bytelimit <= 0)
 		return head;
@@ -107,10 +121,24 @@ static inline struct sk_buff *qdisc_bulk_dequeue_skb(struct Qdisc *q,
 			 * returns NETDEV_TX_BUSY, which would
 			 * overwrite this requeue.
 			 */
+			if (skb->next) //DEBUG
+				net_warn_ratelimited(
+				"%s() dev:%s pkt-append SKB-list bql:%d cnd:%d\n",
+				__func__, q->dev_queue->dev->name,
+				bytelimit, cnt);
+			else if (skb_is_gso(skb))
+				net_warn_ratelimited(
+				"%s() dev:%s pkt-append real-GSO bql:%d cnd:%d\n",
+				__func__, q->dev_queue->dev->name,
+				bytelimit, cnt);
 		}
 	} while (new && --limit && (bytelimit > 0));
 	skb = head;
 
+	if (cnt > 0) //DEBUG
+		net_warn_ratelimited("%s() dev:%s BULK-active deq:%d bql:%d\n",
+				     __func__, q->dev_queue->dev->name,
+				     cnt, bytelimit);
 	return skb;
 }
 
