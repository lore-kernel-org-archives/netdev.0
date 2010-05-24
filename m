From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 1/2] netdev: add tracepoint to dev_hard_start_xmit, consume_skb
 and dev_kfree_skb_irq
Date: Mon, 24 May 2010 13:51:23 +0900
Message-ID: <4BFA05CB.7010900@jp.fujitsu.com>
References: <4BFA0551.3080304@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:46861 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab0EXEvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 00:51:20 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4O4pJe9026589
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 24 May 2010 13:51:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 85AC145DE54
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:51:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5707445DE52
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:51:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 367F5E08001
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:51:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D78C91DB8016
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:51:18 +0900 (JST)
In-Reply-To: <4BFA0551.3080304@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoint to dev_hard_start_xmit, consume_skb and
dev_kfree_skb_irq to monitor tx-packets in device.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   64 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             |    4 +++
 net/core/skbuff.c          |    1 +
 3 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..ed97580 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -9,6 +9,52 @@
 #include <linux/tracepoint.h>
 
 /*
+ *  netdev_start_xmit - invoked when skb is passed to the driver
+ *  @skb:		pointer to struct sk_buff
+ *  @dev:		pointer to struct net_device
+ */
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
+		__string(	name,		dev->name	)
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
+TRACE_EVENT(consume_skb,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *,		skbaddr		)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+	),
+
+	TP_printk("skbaddr=%p",
+		__entry->skbaddr)
+);
+
+/*
  * Tracepoint for free an sk_buff:
  */
 TRACE_EVENT(kfree_skb,
@@ -35,6 +81,24 @@ TRACE_EVENT(kfree_skb,
 		__entry->skbaddr, __entry->protocol, __entry->location)
 );
 
+TRACE_EVENT(dev_kfree_skb_irq,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *,		skbaddr		)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+	),
+
+	TP_printk("skbaddr=%p",
+		__entry->skbaddr)
+);
+
 TRACE_EVENT(skb_copy_datagram_iovec,
 
 	TP_PROTO(const struct sk_buff *skb, int len),
diff --git a/net/core/dev.c b/net/core/dev.c
index 32611c8..647d812 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -130,6 +130,7 @@
 #include <linux/jhash.h>
 #include <linux/random.h>
 #include <trace/events/napi.h>
+#include <trace/events/skb.h>
 #include <linux/pci.h>
 
 #include "net-sysfs.h"
@@ -1577,6 +1578,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
 		struct softnet_data *sd;
 		unsigned long flags;
 
+		trace_dev_kfree_skb_irq(skb);
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
 		skb->next = sd->completion_queue;
@@ -1919,6 +1921,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				goto gso;
 		}
 
+		trace_netdev_start_xmit(skb, dev);
 		rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
@@ -1939,6 +1942,7 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
 
+		trace_netdev_start_xmit(nskb, dev);
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a9b0e1f..b9c963c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -466,6 +466,7 @@ void consume_skb(struct sk_buff *skb)
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
 		return;
+	trace_consume_skb(skb);
 	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(consume_skb);

