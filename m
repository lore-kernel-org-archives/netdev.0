From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 3/8] net: core: unwrap skb list receive slightly
 further
Date: Tue, 19 Apr 2016 14:35:32 +0100
Message-ID: <57163424.6060709@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:48302 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbcDSNfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:35:42 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds iterator skb_queue_for_each() to run over a list without modifying it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/linux/skbuff.h     | 16 ++++++++++++++++
 include/trace/events/net.h |  7 +++++++
 net/core/dev.c             |  4 +++-
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index da0ace3..2851c38 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1501,6 +1501,22 @@ static inline struct sk_buff *skb_peek_tail(const struct sk_buff_head *list_)
 }
 
 /**
+ *	skb_queue_for_each - iterate over an skb queue
+ *	@pos:        the &struct sk_buff to use as a loop cursor.
+ *	@head:       the &struct sk_buff_head for your list.
+ *
+ *	The reference count is not incremented and the reference is therefore
+ *	volatile; the list lock is not taken either. Use with caution.
+ *
+ *	The list must not be modified (though the individual skbs can be)
+ *	within the loop body.
+ *
+ *	After loop completion, @pos will be %NULL.
+ */
+#define skb_queue_for_each(pos, head) \
+	for (pos = skb_peek(head); pos != NULL; pos = skb_peek_next(pos, head))
+
+/**
  *	skb_queue_len	- get queue length
  *	@list_: list to measure
  *
diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index 49cc7c3..30f359c 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -222,6 +222,13 @@ DEFINE_EVENT(net_dev_rx_verbose_template, netif_receive_skb_entry,
 	TP_ARGS(skb)
 );
 
+DEFINE_EVENT(net_dev_rx_verbose_template, netif_receive_skb_list_entry,
+
+	TP_PROTO(const struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
 DEFINE_EVENT(net_dev_rx_verbose_template, netif_rx_entry,
 
 	TP_PROTO(const struct sk_buff *skb),
diff --git a/net/core/dev.c b/net/core/dev.c
index 7abcb1d..4bb6724 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4307,8 +4307,10 @@ void netif_receive_skb_list(struct sk_buff_head *list)
 {
 	struct sk_buff *skb;
 
+	skb_queue_for_each(skb, list)
+		trace_netif_receive_skb_list_entry(skb);
 	while ((skb = __skb_dequeue(list)) != NULL)
-		netif_receive_skb(skb);
+		netif_receive_skb_internal(skb);
 }
 EXPORT_SYMBOL(netif_receive_skb_list);
 
