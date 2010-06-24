From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v2 4/5] skb: add tracepoints to freeing skb
Date: Thu, 24 Jun 2010 17:19:44 +0900
Message-ID: <4C231520.6000603@jp.fujitsu.com>
References: <4C2312A8.9060903@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, scott.a.mcmillan@intel.com,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:53277 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab0FXITn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 04:19:43 -0400
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5O8JgnO003535
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Thu, 24 Jun 2010 17:19:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1E2045DE59
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:19:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B2FBE45DE52
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:19:41 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 92D82E08003
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:19:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2685F1DB805B
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:19:41 +0900 (JST)
In-Reply-To: <4C2312A8.9060903@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch adds tracepoint to consume_skb and dev_kfree_skb_irq.
Combinating with tracepoint on dev_hard_start_xmit, we can check how long it
takes to free transmited packets. And using it, we can calculate how many
packets driver had at that time. It is useful when a drop of transmited packet
is a problem.

          <idle>-0     [001] 241409.218333: consume_skb: skbaddr=dd6b2fb8
          <idle>-0     [001] 241409.490555: dev_kfree_skb_irq: skbaddr=f5e29840

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
index 4b64b21..807b1ca 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -131,6 +131,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <trace/events/net.h>
+#include <trace/events/skb.h>
 #include <linux/pci.h>
 
 #include "net-sysfs.h"
@@ -1580,6 +1581,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
 		struct softnet_data *sd;
 		unsigned long flags;
 
+		trace_dev_kfree_skb_irq(skb);
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
 		skb->next = sd->completion_queue;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 34432b4..a7b4036 100644
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

