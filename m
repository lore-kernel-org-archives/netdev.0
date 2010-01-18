From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 4/5] tracing/events: add tracepoint to UDP protocol
Date: Mon, 18 Jan 2010 17:28:57 +0900
Message-ID: <4B541BC9.6010706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:49550 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab0ARI2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 03:28:51 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I8SolQ032412
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 18 Jan 2010 17:28:50 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 17CFC45DE60
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EC16645DD75
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D1BF91DB8042
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68ED8E18003
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:46 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoints at UDP protocol.

udp_sendmsg             entry of UDP layer(transmit)
udp_sendpage            entry of UDP layer(transmit)
udp_push_pending_frames all data(udp_sendmsg have) have copied to skb
udp_rcv                 entry of UDP layer(receive).

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   86 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp.c             |    5 +++
 2 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index fbc25e8..1287934 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -6,7 +6,9 @@
 
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <net/inet_sock.h>
 #include <linux/ip.h>
+#include <linux/udp.h>
 #include <linux/tracepoint.h>
 
 #define FORMAT_IPADDR(x) ((unsigned char *)&x)[3],\
@@ -154,6 +156,90 @@ TRACE_EVENT(ip_frag_reasm,
 		__entry->skbaddr, __entry->len)
 );
 
+TRACE_EVENT(udp_sendmsg,
+
+	TP_PROTO(struct sock *sk, size_t len),
+
+	TP_ARGS(sk, len),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skaddr	)
+		__field(	size_t,		len	)
+       ),
+
+	TP_fast_assign(
+		__entry->skaddr = sk;
+		__entry->len = len;
+	),
+
+	TP_printk("sk=%p len=%u",
+		__entry->skaddr, __entry->len)
+);
+
+TRACE_EVENT(udp_sendpage,
+
+	TP_PROTO(struct sock *sk, size_t len),
+
+	TP_ARGS(sk, len),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skaddr	)
+		__field(	size_t,		len	)
+       ),
+
+	TP_fast_assign(
+		__entry->skaddr = sk;
+		__entry->len = len;
+	),
+
+	TP_printk("sk=%p len=%u",
+		__entry->skaddr, __entry->len)
+);
+
+TRACE_EVENT(udp_push_pending_frames,
+
+	TP_PROTO(struct sock *sk),
+
+	TP_ARGS(sk),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skaddr	)
+		__field(	unsigned short,	sport	)
+		__field(	unsigned short,	dport	)
+       ),
+
+	TP_fast_assign(
+		__entry->skaddr = sk;
+		__entry->sport = ntohs(inet_sk(sk)->inet_sport);
+		__entry->dport = ntohs(inet_sk(sk)->inet_dport);
+	),
+
+	TP_printk("sk=%p sport=%u dport=%u",
+		__entry->skaddr, __entry->sport, __entry->dport)
+);
+
+TRACE_EVENT(udp_rcv,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skbaddr	)
+		__field(	unsigned short,	sport	)
+		__field(	unsigned short,	dport	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->sport = ntohs(udp_hdr(skb)->source);
+		__entry->dport = ntohs(udp_hdr(skb)->dest);
+	),
+
+	TP_printk("skbaddr=%p sport=%u dport=%u",
+		__entry->skbaddr, __entry->sport, __entry->dport)
+);
+
 TRACE_EVENT(raw_sendmsg,
 
 	TP_PROTO(struct sock *sk, size_t len),
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f0126fd..c0389ec 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -104,6 +104,7 @@
 #include <net/route.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <trace/events/skb.h>
 #include "udp_impl.h"
 
 struct udp_table udp_table __read_mostly;
@@ -715,6 +716,7 @@ static int udp_push_pending_frames(struct sock *sk)
 	int is_udplite = IS_UDPLITE(sk);
 	__wsum csum = 0;
 
+	trace_udp_push_pending_frames(sk);
 	/* Grab the skbuff where UDP header space exists. */
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
 		goto out;
@@ -784,6 +786,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
+	trace_udp_sendmsg(sk, len);
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
 
@@ -990,6 +993,7 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	struct udp_sock *up = udp_sk(sk);
 	int ret;
 
+	trace_udp_sendpage(sk, size);
 	if (!up->pending) {
 		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };
 
@@ -1608,6 +1612,7 @@ drop:
 
 int udp_rcv(struct sk_buff *skb)
 {
+	trace_udp_rcv(skb);
 	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
 }
 

