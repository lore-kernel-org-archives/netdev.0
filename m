From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 1/4] udp: under rx pressure, try to condense skbs
Date: Thu,  8 Dec 2016 09:38:56 -0800
Message-ID: <1481218739-27089-2-git-send-email-edumazet@google.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36194 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751139AbcLHRjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 12:39:06 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so84641074pfz.3
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:39:06 -0800 (PST)
In-Reply-To: <1481218739-27089-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 28 ++++++++++++++++++++++++++++
 net/ipv4/udp.c         | 12 +++++++++++-
 3 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fbccf2c..0cd92b0f2af5 100644
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
index b45cd1494243..d27e0352ae2a 100644
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
+ * If the packet has bytes in frags and enough tail room in skb->head,
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
index 16d88ba9ff1c..110414903f9e 100644
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
 
+	/* Under mem pressure, it might be helpful to give udp_recvmsg()
+	 * linear skbs :
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
-- 
2.8.0.rc3.226.g39d4020
