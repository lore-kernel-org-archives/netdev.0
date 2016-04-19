From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 4/8] net: core: Another step of skb receive list
 processing
Date: Tue, 19 Apr 2016 14:35:51 +0100
Message-ID: <57163437.2060002@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:19574 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159AbcDSNgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:36:03 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_receive_skb_list_internal() now processes a list and hands it
on to the next function.

The code duplication is unfortunate, but the common part between the list
and non-list versions of the function takes a lock (rcu_read_lock()), so
factoring it out would be a little ugly.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/core/dev.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 46 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4bb6724..586807d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4241,6 +4241,14 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	return ret;
 }
 
+static void __netif_receive_skb_list(struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(list)) != NULL)
+		__netif_receive_skb(skb);
+}
+
 static int netif_receive_skb_internal(struct sk_buff *skb)
 {
 	int ret;
@@ -4269,6 +4277,41 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
 	return ret;
 }
 
+static void netif_receive_skb_list_internal(struct sk_buff_head *list)
+{
+	struct sk_buff_head sublist;
+	struct sk_buff *skb;
+
+	__skb_queue_head_init(&sublist);
+
+	rcu_read_lock();
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		net_timestamp_check(netdev_tstamp_prequeue, skb);
+		if (skb_defer_rx_timestamp(skb)) {
+			/* Handled, don't add to sublist */
+			continue;
+		}
+
+#ifdef CONFIG_RPS
+		if (static_key_false(&rps_needed)) {
+			struct rps_dev_flow voidflow, *rflow = &voidflow;
+			int cpu = get_rps_cpu(skb->dev, skb, &rflow);
+
+			if (cpu >= 0) {
+				enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+				/* Handled, don't add to sublist */
+				continue;
+			}
+		}
+#endif
+		__skb_queue_tail(&sublist, skb);
+	}
+
+	__netif_receive_skb_list(&sublist);
+	rcu_read_unlock();
+	return;
+}
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
@@ -4297,8 +4340,8 @@ EXPORT_SYMBOL(netif_receive_skb);
  *	@list: list of skbs to process.  Must not be shareable (e.g. it may
  *	be on the stack)
  *
- *	For now, just calls netif_receive_skb() in a loop, ignoring the
- *	return value.
+ *	Since return value of netif_receive_skb() is normally ignored, and
+ *	wouldn't be meaningful for a list, this function returns void.
  *
  *	This function may only be called from softirq context and interrupts
  *	should be enabled.
@@ -4309,8 +4352,7 @@ void netif_receive_skb_list(struct sk_buff_head *list)
 
 	skb_queue_for_each(skb, list)
 		trace_netif_receive_skb_list_entry(skb);
-	while ((skb = __skb_dequeue(list)) != NULL)
-		netif_receive_skb_internal(skb);
+	netif_receive_skb_list_internal(list);
 }
 EXPORT_SYMBOL(netif_receive_skb_list);
 
