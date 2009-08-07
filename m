From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/3] net: Add ftracer to help optimize process
	scheduling based on incomming frame allocations
Date: Fri, 7 Aug 2009 16:28:18 -0400
Message-ID: <20090807202818.GB26677@hmsreliant.think-freely.org>
References: <20090807202130.GA26677@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rostedt@goodmis.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57469 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567AbZHGU2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 16:28:18 -0400
Content-Disposition: inline
In-Reply-To: <20090807202130.GA26677@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb allocation / cosumption tracer - Add consumption tracepoint

This patch adds a tracepoint to skb_copy_datagram_iovec, which is called each
time a userspace process copies a frame from a socket receive queue to a user
space buffer.  It allows us to hook in and examine each sk_buff that the system
receives on a per-socket bases, and can be use to compile a list of which skb's
were received by which processes.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/trace/events/skb.h |   20 ++++++++++++++++++++
 net/core/datagram.c        |    3 +++
 2 files changed, 23 insertions(+)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 1e8fabb..bdc5c1c 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -2,6 +2,7 @@
 #define _TRACE_SKB_H
 
 #include <linux/skbuff.h>
+#include <linux/netdevice.h>
 #include <linux/tracepoint.h>
 
 #undef TRACE_SYSTEM
@@ -34,6 +35,25 @@ TRACE_EVENT(kfree_skb,
 		__entry->skbaddr, __entry->protocol, __entry->location)
 );
 
+TRACE_EVENT(skb_copy_datagram_iovec,
+
+	TP_PROTO(const struct sk_buff *skb, int len),
+
+	TP_ARGS(skb, len),
+
+	TP_STRUCT__entry(
+		__field(	const void *,		skbaddr		)
+		__field(	int,			len		)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = len;
+	),
+
+	TP_printk("skbaddr=%p len=%d", __entry->skbaddr, __entry->len)
+);
+
 #endif /* _TRACE_SKB_H */
 
 /* This part must be outside protection */
diff --git a/net/core/datagram.c b/net/core/datagram.c
index b0fe692..1c6cf3a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -55,6 +55,7 @@
 #include <net/checksum.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
+#include <trace/events/skb.h>
 
 /*
  *	Is a socket 'connection oriented' ?
@@ -284,6 +285,8 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 	int i, copy = start - offset;
 	struct sk_buff *frag_iter;
 
+	trace_skb_copy_datagram_iovec(skb, len);
+
 	/* Copy header. */
 	if (copy > 0) {
 		if (copy > len)
