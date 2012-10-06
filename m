From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: gro: selective flush of packets
Date: Sat, 06 Oct 2012 20:08:49 +0200
Message-ID: <1349546929.21172.1598.camel@edumazet-glaptop>
References: <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>
	 <20121006041155.GA27134@gondor.apana.org.au>
	 <1349500126.4883.4.camel@edumazet-laptop>
	 <20121006051407.GA27390@gondor.apana.org.au>
	 <1349504541.21172.183.camel@edumazet-glaptop>
	 <1349506825.21172.241.camel@edumazet-glaptop>
	 <20121006105618.GA28591@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:57015 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab2JFSIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 14:08:55 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so95250eaa.19
        for <netdev@vger.kernel.org>; Sat, 06 Oct 2012 11:08:54 -0700 (PDT)
In-Reply-To: <20121006105618.GA28591@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Current GRO can hold packets in gro_list for almost unlimited
time, in case napi->poll() handler consumes its budget over and over.

In this case, napi_complete()/napi_gro_flush() are not called.

Another problem is that gro_list is flushed in non friendly way :
We scan the list and complete packets in the reverse order.
(youngest packets first, oldest packets last)
This defeats priorities that sender could have cooked.

Since GRO currently only store TCP packets, we dont really notice the
bug because of retransmits, but this behavior can add unexpected
latencies, particularly on mice flows clamped by elephant flows.

This patch makes sure no packet can stay more than 1 ms in queue, and
only in stress situations.

It also complete packets in the right order to minimize latencies.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 drivers/net/ethernet/marvell/skge.c   |    2 -
 drivers/net/ethernet/realtek/8139cp.c |    2 -
 include/linux/netdevice.h             |   15 +++++----
 net/core/dev.c                        |   38 +++++++++++++++++++-----
 4 files changed, 42 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 5a30bf8..eb3cba0 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3189,7 +3189,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 	if (work_done < to_do) {
 		unsigned long flags;
 
-		napi_gro_flush(napi);
+		napi_gro_flush(napi, false);
 		spin_lock_irqsave(&hw->hw_lock, flags);
 		__napi_complete(napi);
 		hw->intr_mask |= napimask[skge->port];
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 995d0cf..1c81825 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -563,7 +563,7 @@ rx_next:
 		if (cpr16(IntrStatus) & cp_rx_intr_mask)
 			goto rx_status_loop;
 
-		napi_gro_flush(napi);
+		napi_gro_flush(napi, false);
 		spin_lock_irqsave(&cp->lock, flags);
 		__napi_complete(napi);
 		cpw16_f(IntrMask, cp_intr_mask);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 01646aa..63efc28 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1497,19 +1497,22 @@ struct napi_gro_cb {
 	/* This indicates where we are processing relative to skb->data. */
 	int data_offset;
 
-	/* This is non-zero if the packet may be of the same flow. */
-	int same_flow;
-
 	/* This is non-zero if the packet cannot be merged with the new skb. */
 	int flush;
 
 	/* Number of segments aggregated. */
-	int count;
+	u16	count;
+
+	/* This is non-zero if the packet may be of the same flow. */
+	u8	same_flow;
 
 	/* Free the skb? */
-	int free;
+	u8	free;
 #define NAPI_GRO_FREE		  1
 #define NAPI_GRO_FREE_STOLEN_HEAD 2
+
+	/* jiffies when first packet was created/queued */
+	unsigned long age;
 };
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
@@ -2157,7 +2160,7 @@ extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
 extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
-extern void		napi_gro_flush(struct napi_struct *napi);
+extern void		napi_gro_flush(struct napi_struct *napi, bool flush_old);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
 extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 1e0a184..8c960e8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3471,17 +3471,31 @@ out:
 	return netif_receive_skb(skb);
 }
 
-inline void napi_gro_flush(struct napi_struct *napi)
+/* napi->gro_list contains packets ordered by age.
+ * youngest packets at the head of it.
+ * Complete skbs in reverse order to reduce latencies.
+ */
+void napi_gro_flush(struct napi_struct *napi, bool flush_old)
 {
-	struct sk_buff *skb, *next;
+	struct sk_buff *skb, *prev = NULL;
 
-	for (skb = napi->gro_list; skb; skb = next) {
-		next = skb->next;
+	/* scan list and build reverse chain */
+	for (skb = napi->gro_list; skb != NULL; skb = skb->next) {
+		skb->prev = prev;
+		prev = skb;
+	}
+
+	for (skb = prev; skb; skb = prev) {
 		skb->next = NULL;
+
+		if (flush_old && NAPI_GRO_CB(skb)->age == jiffies)
+			return;
+
+		prev = skb->prev;
 		napi_gro_complete(skb);
+		napi->gro_count--;
 	}
 
-	napi->gro_count = 0;
 	napi->gro_list = NULL;
 }
 EXPORT_SYMBOL(napi_gro_flush);
@@ -3542,6 +3556,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 
 	napi->gro_count++;
 	NAPI_GRO_CB(skb)->count = 1;
+	NAPI_GRO_CB(skb)->age = jiffies;
 	skb_shinfo(skb)->gso_size = skb_gro_len(skb);
 	skb->next = napi->gro_list;
 	napi->gro_list = skb;
@@ -3876,7 +3891,7 @@ void napi_complete(struct napi_struct *n)
 	if (unlikely(test_bit(NAPI_STATE_NPSVC, &n->state)))
 		return;
 
-	napi_gro_flush(n);
+	napi_gro_flush(n, false);
 	local_irq_save(flags);
 	__napi_complete(n);
 	local_irq_restore(flags);
@@ -3981,8 +3996,17 @@ static void net_rx_action(struct softirq_action *h)
 				local_irq_enable();
 				napi_complete(n);
 				local_irq_disable();
-			} else
+			} else {
+				if (n->gro_list) {
+					/* flush too old packets
+					 * If HZ < 1000, flush all packets.
+					 */
+					local_irq_enable();
+					napi_gro_flush(n, HZ >= 1000);
+					local_irq_disable();
+				}
 				list_move_tail(&n->poll_list, &sd->poll_list);
+			}
 		}
 
 		netpoll_poll_unlock(have);
