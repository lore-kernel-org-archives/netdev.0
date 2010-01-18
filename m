From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 3/5] tracing/events: add tracepoint to RAW protocol
Date: Mon, 18 Jan 2010 17:28:27 +0900
Message-ID: <4B541BAB.600@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com
To: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:45338 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab0ARI2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 03:28:20 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I8SJqf013729
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 18 Jan 2010 17:28:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFB7245DE4E
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A64E445DE4F
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7850D1DB8043
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C401DB803B
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 17:28:18 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoints at RAW protocol.

raw_sendmsg             entry of RAW layer(transmit).
raw_rcv                 entry of RAW layer(receive).

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/skb.h |   40 ++++++++++++++++++++++++++++++++++++++++
 net/ipv4/raw.c             |    4 ++++
 2 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index a33893f..fbc25e8 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -154,6 +154,46 @@ TRACE_EVENT(ip_frag_reasm,
 		__entry->skbaddr, __entry->len)
 );
 
+TRACE_EVENT(raw_sendmsg,
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
+TRACE_EVENT(raw_rcv,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	skbaddr	)
+		__field(	unsigned int,	len	)
+       ),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+	),
+
+	TP_printk("skbaddr=%p len=%u",
+		__entry->skbaddr, __entry->len)
+);
+
 TRACE_EVENT(dev_queue_xmit,
 
 	TP_PROTO(struct sk_buff *skb,
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ce154b4..1b2425a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -77,6 +77,7 @@
 #include <linux/seq_file.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
+#include <trace/events/skb.h>
 
 static struct raw_hashinfo raw_v4_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
@@ -301,6 +302,7 @@ static int raw_rcv_skb(struct sock * sk, struct sk_buff * skb)
 
 int raw_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	trace_raw_rcv(skb);
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb)) {
 		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
@@ -354,6 +356,7 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	err = -EFAULT;
 	if (memcpy_fromiovecend((void *)iph, from, 0, length))
 		goto error_free;
+	trace_senddata_copy_skb(sk, skb, length);
 
 	iphlen = iph->ihl * 4;
 
@@ -459,6 +462,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	u8  tos;
 	int err;
 
+	trace_raw_sendmsg(sk, len);
 	err = -EMSGSIZE;
 	if (len > 0xFFFF)
 		goto out;

