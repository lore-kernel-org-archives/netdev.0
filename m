From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Sun, 17 Nov 2013 09:41:38 -0800
Message-ID: <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org> <20131112083633.GB10318@1wt.eu>
	 <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
	 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	 <20131117141940.GA18569@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:63061 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab3KQRlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 12:41:40 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so1223892pdj.31
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 09:41:39 -0800 (PST)
In-Reply-To: <20131117141940.GA18569@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-11-17 at 15:19 +0100, Willy Tarreau wrote:

> 
> So it is fairly possible that in your case you can't fill the link if you
> consume too many descriptors. For example, if your server uses TCP_NODELAY
> and sends incomplete segments (which is quite common), it's very easy to
> run out of descriptors before the link is full.

BTW I have a very simple patch for TCP stack that could help this exact
situation...

Idea is to use TCP Small Queue so that we dont fill qdisc/TX ring with
very small frames, and let tcp_sendmsg() have more chance to fill
complete packets.

Again, for this to work very well, you need that NIC performs TX
completion in reasonable amount of time...

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3dc0c6c..10456cf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -624,13 +624,19 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 {
 	if (tcp_send_head(sk)) {
 		struct tcp_sock *tp = tcp_sk(sk);
+		struct sk_buff *skb = tcp_write_queue_tail(sk);
 
 		if (!(flags & MSG_MORE) || forced_push(tp))
-			tcp_mark_push(tp, tcp_write_queue_tail(sk));
+			tcp_mark_push(tp, skb);
 
 		tcp_mark_urg(tp, flags);
-		__tcp_push_pending_frames(sk, mss_now,
-					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
+		if (flags & MSG_MORE)
+			nonagle = TCP_NAGLE_CORK;
+		if (atomic_read(&sk->sk_wmem_alloc) > 2048) {
+			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
+			nonagle = TCP_NAGLE_CORK;
+		}
+		__tcp_push_pending_frames(sk, mss_now, nonagle);
 	}
 }
 
