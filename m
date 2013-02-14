From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Convert skb->csum_(start|offset) integrity
 BUG_ON() to WARN_ON() & drop
Date: Thu, 14 Feb 2013 08:22:23 -0800
Message-ID: <1360858943.6884.47.camel@edumazet-glaptop>
References: <20130213234021.GA21829@casper.infradead.org>
	 <20130213234843.GB21829@casper.infradead.org>
	 <20130213.193759.1094469499685059296.davem@davemloft.net>
	 <20130214101853.GC21829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50144 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757761Ab3BNQW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 11:22:28 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so1331966pad.20
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 08:22:27 -0800 (PST)
In-Reply-To: <20130214101853.GC21829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 10:18 +0000, Thomas Graf wrote:
> Maybe it's my general dislike of BUG_ON() in the processing
> path, especially if the bug condition can be influenced remotely.
> It looks absolutely doable to trigger the previously mentioned
> partial acking & collapsing on purpose by a malicious receiver
> even with an MTU of 1500. I believe we should avoid total DoS
> in future similar situations that we don't think of yet.

It seems not possible to avoid bugs, being a BUG_ON() or a out of bound
memory access or whatever. We must fix them eventually.

In this case, it seems we must limit payload to 

65535 - MAX_TCP_HEADER 

It would make tcp_xmit_size_goal() a bit shorter.

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2c7e596..2f6c8e5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -793,10 +793,7 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 	xmit_size_goal = mss_now;
 
 	if (large_allowed && sk_can_gso(sk)) {
-		xmit_size_goal = ((sk->sk_gso_max_size - 1) -
-				  inet_csk(sk)->icsk_af_ops->net_header_len -
-				  inet_csk(sk)->icsk_ext_hdr_len -
-				  tp->tcp_header_len);
+		xmit_size_goal = sk->sk_gso_max_size - 1 - MAX_TCP_HEADER;
 
 		/* TSQ : try to have two TSO segments in flight */
 		xmit_size_goal = min_t(u32, xmit_size_goal,
