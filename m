From: Satoru Moriya <satoru.moriya@hds.com>
Subject: [PATCH 2/2] core: add tracepoints for queueing skb to rcvbuf
Date: Fri, 17 Jun 2011 18:00:03 -0400
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E7@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindmx01.hds.com ([207.126.252.12]:41604 "EHLO
	usindmx01.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab1FQWAX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 18:00:23 -0400
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds 2 tracepoints to get a status of a socket receive queue
and related parameter. 

One tracepoint is added to sock_queue_rcv_skb. It records rcvbuf size
and its usage. The other tracepoint is added to __sk_mem_schedule and
it records limitations of memory for sockets and current usage.

By using these tracepoints we're able to know detailed reason why kernel
drop the packet.

Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
---
 include/trace/events/sock.h |   68 +++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c       |    1 +
 net/core/sock.c             |    5 +++
 3 files changed, 74 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/sock.h

diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
new file mode 100644
index 0000000..779abb9
--- /dev/null
+++ b/include/trace/events/sock.h
@@ -0,0 +1,68 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM sock
+
+#if !defined(_TRACE_SOCK_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_SOCK_H
+
+#include <net/sock.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(sock_rcvqueue_full,
+
+	TP_PROTO(struct sock *sk, struct sk_buff *skb),
+
+	TP_ARGS(sk, skb),
+
+	TP_STRUCT__entry(
+		__field(int, rmem_alloc)
+		__field(unsigned int, truesize)
+		__field(int, sk_rcvbuf)
+	),
+
+	TP_fast_assign(
+		__entry->rmem_alloc = atomic_read(&sk->sk_rmem_alloc);
+		__entry->truesize   = skb->truesize;
+		__entry->sk_rcvbuf  = sk->sk_rcvbuf;
+	),
+
+	TP_printk("rmem_alloc=%d truesize=%u sk_rcvbuf=%d",
+		__entry->rmem_alloc, __entry->truesize, __entry->sk_rcvbuf)
+);
+
+TRACE_EVENT(sock_exceed_buf_limit,
+
+	TP_PROTO(struct sock *sk, struct proto *prot, long allocated),
+
+	TP_ARGS(sk, prot, allocated),
+
+	TP_STRUCT__entry(
+		__array(char, name, 32)
+		__field(long *, sysctl_mem)
+		__field(long, allocated)
+		__field(int, sysctl_rmem)
+		__field(int, rmem_alloc)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->name, prot->name, 32);
+		__entry->sysctl_mem = prot->sysctl_mem;
+		__entry->allocated = allocated;
+		__entry->sysctl_rmem = prot->sysctl_rmem[0];
+		__entry->rmem_alloc = atomic_read(&sk->sk_rmem_alloc);
+	),
+
+	TP_printk("proto:%s sysctl_mem=%ld,%ld,%ld allocated=%ld "
+		"sysctl_rmem=%d rmem_alloc=%d",
+		__entry->name,
+		__entry->sysctl_mem[0],
+		__entry->sysctl_mem[1],
+		__entry->sysctl_mem[2],
+		__entry->allocated,
+		__entry->sysctl_rmem,
+		__entry->rmem_alloc)
+);
+
+#endif /* _TRACE_SOCK_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index 13aab64..52380b1 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -28,6 +28,7 @@
 #include <trace/events/skb.h>
 #include <trace/events/net.h>
 #include <trace/events/napi.h>
+#include <trace/events/sock.h>
 #include <trace/events/udp.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 6e81978..76c4031 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -128,6 +128,8 @@
 
 #include <linux/filter.h>
 
+#include <trace/events/sock.h>
+
 #ifdef CONFIG_INET
 #include <net/tcp.h>
 #endif
@@ -292,6 +294,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned)sk->sk_rcvbuf) {
 		atomic_inc(&sk->sk_drops);
+		trace_sock_rcvqueue_full(sk, skb);
 		return -ENOMEM;
 	}
 
@@ -1736,6 +1739,8 @@ suppress_allocation:
 			return 1;
 	}
 
+	trace_sock_exceed_buf_limit(sk, prot, allocated);
+
 	/* Alas. Undo changes. */
 	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
 	atomic_long_sub(amt, prot->memory_allocated);
-- 
1.7.1


