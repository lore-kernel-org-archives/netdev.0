From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Wed, 07 Dec 2016 09:19:33 -0800
Message-ID: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35105 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932192AbcLGRUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:20:35 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so11494680pfk.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 09:20:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Under UDP flood, many softirq producers try to add packets to
UDP receive queue, and one user thread is burning one cpu trying
to dequeue packets as fast as possible.

Two parts of the per packet cost are :
- copying payload from kernel space to user space,
- freeing memory pieces associated with skb.

If socket is under pressure, softirq handler(s) can try to pull in
skb->head the payload of the packet if it fits.

Meaning the softirq handler(s) can free/reuse the page fragment
immediately, instead of letting udp_recvmsg() do this hundreds of usec
later, possibly from another node.


Additional gains :
- We reduce skb->truesize and thus can store more packets per SO_RCVBUF
- We avoid cache line misses at copyout() time and consume_skb() time,
and avoid one put_page() with potential alien freeing on NUMA hosts.

This comes at the cost of a copy, bounded to available tail room, which
is usually small. (We might have to fix GRO_MAX_HEAD which looks bigger
than necessary)

This patch gave me about 5 % increase in throughput in my tests.

skb_condense() helper could probably used in other contexts.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h |    2 ++
 net/core/skbuff.c      |   28 ++++++++++++++++++++++++++++
 net/ipv4/udp.c         |   12 +++++++++++-
 3 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fbccf2c7dbfae04cee393460e86d588c26b..0cd92b0f2af5fe5a7c153435b8dc758338180ae3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1966,6 +1966,8 @@ static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
 	return __pskb_pull_tail(skb, len - skb_headlen(skb)) != NULL;
 }
 
+void skb_condense(struct sk_buff *skb);
+
 /**
  *	skb_headroom - bytes at buffer head
  *	@skb: buffer to check
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b45cd1494243fc99686016949f4546dbba11f424..84151cf40aebb973bad5bee3ee4be0758084d83c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4931,3 +4931,31 @@ struct sk_buff *pskb_extract(struct sk_buff *skb, int off,
 	return clone;
 }
 EXPORT_SYMBOL(pskb_extract);
+
+/**
+ * skb_condense - try to get rid of fragments/frag_list if possible
+ * @skb: buffer
+ *
+ * Can be used to save memory before skb is added to a busy queue.
+ * If packet has bytes in frags and enough tail room in skb->head,
+ * pull all of them, so that we can free the frags right now and adjust
+ * truesize.
+ * Notes:
+ *	We do not reallocate skb->head thus can not fail.
+ *	Caller must re-evaluate skb->truesize if needed.
+ */
+void skb_condense(struct sk_buff *skb)
+{
+	if (!skb->data_len ||
+	    skb->data_len > skb->end - skb->tail ||
+	    skb_cloned(skb))
+		return;
+
+	/* Nice, we can free page frag(s) right now */
+	__pskb_pull_tail(skb, skb->data_len);
+
+	/* Now adjust skb->truesize, since __pskb_pull_tail() does
+	 * not do this.
+	 */
+	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
+}
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 16d88ba9ff1c402f77063cfb5eea2708d86da2fc..f5628ada47b53f0d92d08210e5d7e4132a107f73 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1199,7 +1199,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct sk_buff_head *list = &sk->sk_receive_queue;
 	int rmem, delta, amt, err = -ENOMEM;
-	int size = skb->truesize;
+	int size;
 
 	/* try to avoid the costly atomic add/sub pair when the receive
 	 * queue is full; always allow at least a packet
@@ -1208,6 +1208,16 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	if (rmem > sk->sk_rcvbuf)
 		goto drop;
 
+	/* Under mem pressure, it might be helpful to help udp_recvmsg()
+	 * having linear skbs :
+	 * - Reduce memory overhead and thus increase receive queue capacity
+	 * - Less cache line misses at copyout() time
+	 * - Less work at consume_skb() (less alien page frag freeing)
+	 */
+	if (rmem > (sk->sk_rcvbuf >> 1))
+		skb_condense(skb);
+	size = skb->truesize;
+
 	/* we drop only if the receive buf is full and the receive
 	 * queue contains some other skb
 	 */
