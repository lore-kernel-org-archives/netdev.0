From: Satoru Moriya <satoru.moriya@hds.com>
Subject: [PATCH v2 2/2] tcp: add tracepoint for tcp retransmission
Date: Fri, 20 Jan 2012 13:09:00 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD6C@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps06.hds.com ([207.126.252.19]:48936 "EHLO
	usindpps06.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab2ATSJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 13:09:29 -0500
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a tracepoint to tcp_retransmit_skb() to get the
pointer to sk and skb, local port number  and return value. This helps
one understand whether problems are in a server or not.

Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
---
 include/trace/events/tcp.h |   38 ++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c      |    1 +
 net/ipv4/tcp_output.c      |    3 +++
 3 files changed, 42 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/tcp.h

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
new file mode 100644
index 0000000..311e783
--- /dev/null
+++ b/include/trace/events/tcp.h
@@ -0,0 +1,38 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM tcp
+
+#if !defined(_TRACE_TCP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_TCP_H
+
+#include <linux/skbuff.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(tcp_retransmit_skb,
+
+	TP_PROTO(struct sock *sk, struct sk_buff *skb, int err),
+
+	TP_ARGS(sk, skb, err),
+
+	TP_STRUCT__entry(
+		__field(void *, skaddr)
+		__field(void *, skbaddr)
+		__field(__u16, lport)
+		__field(int, err)
+	),
+
+	TP_fast_assign(
+		__entry->skaddr = sk;
+		__entry->skbaddr = skb;
+		__entry->lport = inet_sk(sk)->inet_num;
+		__entry->err = err;
+	),
+
+	TP_printk("sk=%p skb=%p port=%hu err=%d",
+		__entry->skaddr, __entry->skbaddr,
+		__entry->lport, __entry->err)
+);
+
+#endif /* _TRACE_TCP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index ba3c012..63f966b 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -31,6 +31,7 @@
 #include <trace/events/napi.h>
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
+#include <trace/events/tcp.h>
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7bd23a8..483cc17 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -40,6 +40,8 @@
 #include <linux/gfp.h>
 #include <linux/module.h>
 
+#include <trace/events/tcp.h>
+
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse __read_mostly = 1;
 
@@ -2199,6 +2201,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
 	}
 out:
+	trace_tcp_retransmit_skb(sk, skb, err);
 	return err;
 }
 
-- 
1.7.6.4
