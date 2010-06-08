From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 4/5] skb: add tracepoints to freeing skb
Date: Tue, 08 Jun 2010 14:30:53 +0900
Message-ID: <4C0DD58D.1010703@jp.fujitsu.com>
References: <4C0DD43F.9090902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:60736 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034Ab0FHFat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:30:49 -0400
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o585UmWP012332
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Tue, 8 Jun 2010 14:30:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C05A327879
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:30:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1216D1EF081
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:30:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C8D1DB8038
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:30:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5310C1DB803C
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:30:45 +0900 (JST)
In-Reply-To: <4C0DD43F.9090902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoint to consume_skb and dev_kfree_skb_irq.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   36 ++++++++++++++++++++++++++++++++++++
 net/core/dev.c             |    2 ++
 net/core/skbuff.c          |    1 +
 3 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..6ab5b34 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -35,6 +35,42 @@ TRACE_EVENT(kfree_skb,
 		__entry->skbaddr, __entry->protocol, __entry->location)
 );
 
+TRACE_EVENT(consume_skb,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *,	skbaddr	)
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
+TRACE_EVENT(dev_kfree_skb_irq,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	void *,	skbaddr	)
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
index f7c731b..e0093c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -131,6 +131,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <trace/events/net.h>
+#include <trace/events/skb.h>
 #include <linux/pci.h>
 
 #include "net-sysfs.h"
@@ -1584,6 +1585,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
 		struct softnet_data *sd;
 		unsigned long flags;
 
+		trace_dev_kfree_skb_irq(skb);
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
 		skb->next = sd->completion_queue;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4e7ac09..008c019 100644
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



