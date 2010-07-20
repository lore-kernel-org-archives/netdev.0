From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
Date: Tue, 20 Jul 2010 09:49:10 +0900
Message-ID: <4C44F286.1050907@jp.fujitsu.com>
References: <4C44F12F.5090908@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:43252 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757458Ab0GTAtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 20:49:24 -0400
In-Reply-To: <4C44F12F.5090908@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
This patch adds tracepoint to consume_skb, dev_kfree_skb_irq and
skb_free_datagram_locked. Combinating with tracepoint on dev_hard_start_xmit,
we can check how long it takes to free transmited packets. And using it, we can
calculate how many packets driver had at that time. It is useful when a drop of
transmited packet is a problem.

          <idle>-0     [001] 241409.218333: consume_skb: skbaddr=dd6b2fb8
          <idle>-0     [001] 241409.490555: dev_kfree_skb_irq: skbaddr=f5e29840

        udp-recv-302   [001] 515031.206008: skb_free_datagram_locked: skbaddr=f5b1d900


Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   42 ++++++++++++++++++++++++++++++++++++++++++
 net/core/datagram.c        |    1 +
 net/core/dev.c             |    2 ++
 net/core/skbuff.c          |    1 +
 4 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..84c9041 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -35,6 +35,48 @@ TRACE_EVENT(kfree_skb,
 		__entry->skbaddr, __entry->protocol, __entry->location)
 );
 
+DECLARE_EVENT_CLASS(free_skb,
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
+	TP_printk("skbaddr=%p", __entry->skbaddr)
+
+);
+
+DEFINE_EVENT(free_skb, consume_skb,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+
+);
+
+DEFINE_EVENT(free_skb, dev_kfree_skb_irq,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+
+);
+
+DEFINE_EVENT(free_skb, skb_free_datagram_locked,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+
+);
+
 TRACE_EVENT(skb_copy_datagram_iovec,
 
 	TP_PROTO(const struct sk_buff *skb, int len),
diff --git a/net/core/datagram.c b/net/core/datagram.c
index f5b6f43..1ea32a0 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -231,6 +231,7 @@ void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 {
 	bool slow;
 
+	trace_skb_free_datagram_locked(skb);
 	if (likely(atomic_read(&skb->users) == 1))
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))
diff --git a/net/core/dev.c b/net/core/dev.c
index 4acfec6..d979847 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -131,6 +131,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <trace/events/net.h>
+#include <trace/events/skb.h>
 #include <linux/pci.h>
 
 #include "net-sysfs.h"
@@ -1581,6 +1582,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
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

