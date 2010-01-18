From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 5/5] tracing/events: add tracepoint to TCP protocol
Date: Mon, 18 Jan 2010 17:29:20 +0900
Message-ID: <4B541BE0.6000408@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:49573 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab0ARI3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 03:29:10 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I8T8VT032605
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 18 Jan 2010 17:29:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 376F245DE55
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:29:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 184E045DE4F
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:29:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA5AF1DB8040
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:29:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A2B4C1DB803B
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:29:07 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoints at UDP protocol.

tcp_sendmsg             entry of TCP layer(transmit)
tcp_sendpage            entry of TCP layer(transmit)
tcp_push_pending_frames all data(tcp_sendmsg have) have copied to skb
tcp_v4_rcv              entry of TCP layer(receive)

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   85 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp.c             |    7 ++++
 net/ipv4/tcp_ipv4.c        |    2 +
 net/ipv4/tcp_output.c      |    2 +
 4 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 1287934..2d1ebb3 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -8,6 +8,7 @@
 #include <linux/netdevice.h>
 #include <net/inet_sock.h>
 #include <linux/ip.h>
+#include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/tracepoint.h>
 
@@ -156,6 +157,90 @@ TRACE_EVENT(ip_frag_reasm,
 		__entry->skbaddr, __entry->len)
 );
 
+TRACE_EVENT(tcp_sendmsg,
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
+TRACE_EVENT(tcp_sendpage,
+
+	TP_PROTO(struct sock *sk, size_t len),
+
+	TP_ARGS(sk, len),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skaddr	)
+		__field(	size_t	,	len	)
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
+TRACE_EVENT(tcp_push_pending_frames,
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
+TRACE_EVENT(tcp_v4_rcv,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skbaddr	)
+		__field(	unsigned short, sport	)
+		__field(	unsigned short, dport	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->sport = ntohs(tcp_hdr(skb)->source);
+		__entry->dport = ntohs(tcp_hdr(skb)->dest);
+	),
+
+	TP_printk("skbaddr=%p sport=%u dport=%u",
+		__entry->skbaddr, __entry->sport, __entry->dport)
+);
+
 TRACE_EVENT(udp_sendmsg,
 
 	TP_PROTO(struct sock *sk, size_t len),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d5d69ea..d6c1d55 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -276,6 +276,8 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
+#include <trace/events/skb.h>
+
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
 struct percpu_counter tcp_orphan_count;
@@ -803,6 +805,7 @@ new_segment:
 			skb_fill_page_desc(skb, i, page, offset, copy);
 		}
 
+		trace_senddata_copy_skb(sk, skb, copy);
 		skb->len += copy;
 		skb->data_len += copy;
 		skb->truesize += copy;
@@ -861,6 +864,7 @@ ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
 	ssize_t res;
 	struct sock *sk = sock->sk;
 
+	trace_tcp_sendpage(sk, size);
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
 	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
 		return sock_no_sendpage(sock, page, offset, size, flags);
@@ -911,6 +915,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	lock_sock(sk);
 	TCP_CHECK_TIMER(sk);
 
+	trace_tcp_sendmsg(sk, size);
 	flags = msg->msg_flags;
 	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
 
@@ -988,6 +993,7 @@ new_segment:
 					copy = skb_tailroom(skb);
 				if ((err = skb_add_data(skb, from, copy)) != 0)
 					goto do_fault;
+				trace_senddata_copy_skb(sk, skb, copy);
 			} else {
 				int merge = 0;
 				int i = skb_shinfo(skb)->nr_frags;
@@ -1041,6 +1047,7 @@ new_segment:
 					}
 					goto do_error;
 				}
+				trace_senddata_copy_skb(sk, skb, copy);
 
 				/* Update the skb. */
 				if (merge) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 382f667..1827ba0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -80,6 +80,7 @@
 
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
+#include <trace/events/skb.h>
 
 int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
@@ -1653,6 +1654,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 		goto discard_and_relse;
 
 process:
+	trace_tcp_v4_rcv(skb);
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4a1605d..93e51a1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -38,6 +38,7 @@
 
 #include <linux/compiler.h>
 #include <linux/module.h>
+#include <trace/events/skb.h>
 
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse __read_mostly = 1;
@@ -1801,6 +1802,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 			       int nonagle)
 {
+	trace_tcp_push_pending_frames(sk);
 	/* If we are closed, the bytes will have to remain here.
 	 * In time closedown will finish, we empty the write queue and
 	 * all will be happy.

