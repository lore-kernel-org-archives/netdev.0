From: Tom Herbert <therbert@google.com>
Subject: [PATCH] tcp: fix outsegs stat for TSO segments
Date: Wed, 21 Apr 2010 22:17:24 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004212214110.14731@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:14820 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab0DVFRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:17:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Account for TSO segments of an skb in TCP_MIB_OUTSEGS counter.  Without
this, the counter can be off by orders of magnitude from the
actual number of segments sent.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 884fdbb..92456f1 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -133,6 +133,8 @@ struct linux_xfrm_mib {
 			__this_cpu_add(mib[0]->mibs[field], addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
 			this_cpu_add(mib[1]->mibs[field], addend)
+#define SNMP_ADD_STATS(mib, field, addend)	\
+			this_cpu_add(mib[0]->mibs[field], addend)
 /*
  * Use "__typeof__(*mib[0]) *ptr" instead of "__typeof__(mib[0]) ptr"
  * to make @ptr a non-percpu pointer.
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70c5159..91640fe 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -294,6 +294,7 @@ extern struct proto tcp_prot;
 #define TCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
 #define TCP_DEC_STATS(net, field)	SNMP_DEC_STATS((net)->mib.tcp_statistics, field)
 #define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
+#define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2b7d71f..f89fadc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -888,7 +888,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		tcp_event_data_sent(tp, skb, sk);
 
 	if (after(tcb->end_seq, tp->snd_nxt) || tcb->seq == tcb->end_seq)
-		TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
+		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
+		    tcp_skb_pcount(skb));
 
 	err = icsk->icsk_af_ops->queue_xmit(skb);
 	if (likely(err <= 0))
@@ -2503,7 +2504,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->window = htons(min(req->rcv_wnd, 65535U));
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	th->doff = (tcp_header_size >> 2);
-	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
+	TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS, tcp_skb_pcount(skb));
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
