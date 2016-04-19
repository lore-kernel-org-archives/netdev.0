From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 1/8] net: core: trivial netif_receive_skb_list()
 entry point
Date: Tue, 19 Apr 2016 14:34:48 +0100
Message-ID: <571633F8.500@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:20051 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752545AbcDSNe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:34:58 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just calls netif_receive_skb() in a loop.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3bb534..682d0ad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3218,6 +3218,7 @@ static inline void dev_consume_skb_any(struct sk_buff *skb)
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb(struct sk_buff *skb);
+void netif_receive_skb_list(struct sk_buff_head *list);
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
diff --git a/net/core/dev.c b/net/core/dev.c
index 52d446b..7abcb1d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4292,6 +4292,26 @@ int netif_receive_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
+/**
+ *	netif_receive_skb_list - process many receive buffers from network
+ *	@list: list of skbs to process.  Must not be shareable (e.g. it may
+ *	be on the stack)
+ *
+ *	For now, just calls netif_receive_skb() in a loop, ignoring the
+ *	return value.
+ *
+ *	This function may only be called from softirq context and interrupts
+ *	should be enabled.
+ */
+void netif_receive_skb_list(struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(list)) != NULL)
+		netif_receive_skb(skb);
+}
+EXPORT_SYMBOL(netif_receive_skb_list);
+
 /* Network device is going away, flush any packets still pending
  * Called with irqs disabled.
  */
