From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 04:20:12 +0200
Message-ID: <1335234012.5205.97.camel@edumazet-glaptop>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	 <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop>
	 <20120423.160149.1515408777176168288.davem@davemloft.net>
	 <1335213446.5205.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, maze@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53477 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018Ab2DXCUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:20:15 -0400
Received: by wgbdr13 with SMTP id dr13so163088wgb.1
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 19:20:14 -0700 (PDT)
In-Reply-To: <1335213446.5205.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 22:37 +0200, Eric Dumazet wrote:

> We could try to coalesce ACKs before backlogging them. I'll work on
> this.
> 

I did an experiment, and found a basic coalescing was not working in
case of packet loss and SACK storm.

Doing a smart coalescing in this case sounds really complex.

Should we really continue this way ? 


 include/net/tcp.h   |    1 +
 net/ipv4/tcp_ipv4.c |   32 +++++++++++++++++++++++++++++++-
 2 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fc880e9..de8d847 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1418,6 +1418,7 @@ static inline unsigned int tcp_stream_is_thin(struct tcp_sock *tp)
 	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
 }
 
+extern bool tcp_ack_coalesce(struct sock *sk, struct sk_buff *skb);
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0883921..b5a3bac 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1670,6 +1670,36 @@ csum_err:
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
+/* socket is owned by user.
+ * Before queuing this skb into backlog, try to coalesce it to previous skb.
+ * We only take care of pure ACKS.
+ */
+bool tcp_ack_coalesce(struct sock *sk, struct sk_buff *skb)
+{
+	struct sk_buff *prev = sk->sk_backlog.tail;
+	const struct tcphdr *th, *thp;
+	unsigned int i, thlen;
+
+	if (TCP_SKB_CB(skb)->seq != TCP_SKB_CB(skb)->end_seq ||
+	    !prev ||
+	    TCP_SKB_CB(skb)->seq != TCP_SKB_CB(prev)->end_seq)
+		return false;
+	th = tcp_hdr(skb);
+	thp = tcp_hdr(prev);
+	thlen = th->doff * 4;
+	i = sizeof(th->source) + sizeof(th->dest) +
+	    sizeof(th->seq) + sizeof(th->ack_seq);
+	for (; i < thlen; i += 4) {
+		if (*(u32 *)((u8 *)th + i) != *(u32 *)((u8 *)thp + i))
+			return false;
+	}
+	if (after(TCP_SKB_CB(skb)->ack_seq, TCP_SKB_CB(prev)->ack_seq))
+		TCP_SKB_CB(prev)->ack_seq = TCP_SKB_CB(skb)->ack_seq;
+	consume_skb(skb);
+	return true;
+}
+EXPORT_SYMBOL(tcp_ack_coalesce);
+
 /*
  *	From tcp_input.c
  */
@@ -1752,7 +1782,7 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v4_do_rcv(sk, skb);
 		}
-	} else if (unlikely(sk_add_backlog(sk, skb))) {
+	} else if (!tcp_ack_coalesce(sk, skb) && sk_add_backlog(sk, skb)) {
 		bh_unlock_sock(sk);
 		NET_INC_STATS_BH(net, LINUX_MIB_TCPBACKLOGDROP);
 		goto discard_and_relse;
