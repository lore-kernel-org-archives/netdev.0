From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH v4 4/5] skb: add tracepoints to freeing skb
Date: Mon, 23 Aug 2010 18:46:12 +0900
Message-ID: <4C724364.50903@jp.fujitsu.com>
References: <4C72422C.5070102@jp.fujitsu.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C72422C.5070102@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds tracepoint to consume_skb and add trace_kfree_skb before
__kfree_skb in skb_free_datagram_locked and net_tx_action.
Combinating with tracepoint on dev_hard_start_xmit, we can check how long it
takes to free transmited packets. And using it, we can calculate how many
packets driver had at that time. It is useful when a drop of transmited packet
is a problem.

            sshd-6828  [000] 112689.258154: consume_skb: skbaddr=f2d99bb8

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   17 +++++++++++++++++
 net/core/datagram.c        |    1 +
 net/core/dev.c             |    2 ++
 net/core/skbuff.c          |    1 +
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 4b2be6d..75ce9d5 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -35,6 +35,23 @@ TRACE_EVENT(kfree_skb,
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
+	TP_printk("skbaddr=%p", __entry->skbaddr)
+);
+
 TRACE_EVENT(skb_copy_datagram_iovec,
 
 	TP_PROTO(const struct sk_buff *skb, int len),
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 251997a..282806b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -243,6 +243,7 @@ void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 	unlock_sock_fast(sk, slow);
 
 	/* skb is now orphaned, can be freed outside of locked section */
+	trace_kfree_skb(skb, skb_free_datagram_locked);
 	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(skb_free_datagram_locked);
diff --git a/net/core/dev.c b/net/core/dev.c
index c9b026a..48f7977 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <trace/events/net.h>
+#include <trace/events/skb.h>
 #include <linux/pci.h>
 
 #include "net-sysfs.h"
@@ -2589,6 +2590,7 @@ static void net_tx_action(struct softirq_action *h)
 			clist = clist->next;
 
 			WARN_ON(atomic_read(&skb->users));
+			trace_kfree_skb(skb, net_tx_action);
 			__kfree_skb(skb);
 		}
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 99ef721..ef4ffa8 100644
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
