From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 1/5] tracing/events: add tracepoint to netdev layer
Date: Mon, 18 Jan 2010 17:27:20 +0900
Message-ID: <4B541B68.7090101@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:45277 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab0ARI1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 03:27:13 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I8RBhR013205
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 18 Jan 2010 17:27:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A42F245DE7B
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:27:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3950A45DE7A
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:27:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 15EF31DB803F
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:27:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3FEB1DB8042
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:27:09 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoints at dev_hard_start_xmit, dev_queue_xmit and
netif_receive_skb function.

netdev_start_xmit       entry of driver's transmit function.
netdev_receive_skb      entry of netstack(receive).
dev_queue_xmit          entry of Qdisc.	

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   69 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             |    4 ++
 2 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..d732f07 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -8,6 +8,75 @@
 #include <linux/netdevice.h>
 #include <linux/tracepoint.h>
 
+TRACE_EVENT(dev_queue_xmit,
+
+	TP_PROTO(struct sk_buff *skb,
+		 struct net_device *dev),
+
+	TP_ARGS(skb, dev),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skbaddr		)
+		__field(	unsigned int,	len		)
+		__string(		name,	dev->name	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u",
+		__get_str(name), __entry->skbaddr, __entry->len)
+);
+
+TRACE_EVENT(netdev_start_xmit,
+
+	TP_PROTO(struct sk_buff *skb,
+		 struct net_device *dev),
+
+	TP_ARGS(skb, dev),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skbaddr		)
+		__field(	unsigned int,	len		)
+		__string(		name,	dev->name	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u",
+		__get_str(name), __entry->skbaddr, __entry->len)
+);
+
+TRACE_EVENT(netdev_receive_skb,
+
+	TP_PROTO(struct sk_buff *skb,
+		 struct net_device *dev),
+
+	TP_ARGS(skb, dev),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skbaddr		)
+		__field(	unsigned int,	len		)
+		__string(		name,	dev->name	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%p len=%u",
+		__get_str(name), __entry->skbaddr, __entry->len)
+);
+
 /*
  * Tracepoint for free an sk_buff:
  */
diff --git a/net/core/dev.c b/net/core/dev.c
index a008f69..ef38f8e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <trace/events/napi.h>
+#include <trace/events/skb.h>
 
 #include "net-sysfs.h"
 
@@ -1810,6 +1811,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	int rc = NETDEV_TX_OK;
 
 	if (likely(!skb->next)) {
+		trace_netdev_start_xmit(skb, dev);
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(skb, dev);
 
@@ -2043,6 +2045,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
+	trace_dev_queue_xmit(skb, dev);
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
@@ -2458,6 +2461,7 @@ int netif_receive_skb(struct sk_buff *skb)
 
 	__get_cpu_var(netdev_rx_stat).total++;
 
+	trace_netdev_receive_skb(skb, orig_dev);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;

