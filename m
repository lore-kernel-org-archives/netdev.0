From: Willy Tarreau <w@1wt.eu>
Subject: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 07:07:06 +0200
Message-ID: <20091013050705.GA2194@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50174 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152AbZJMFHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 01:07:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was trying to use TCP_DEFER_ACCEPT and noticed that if the
client does not talk, the connection is never accepted and
remains in SYN_RECV state until the retransmits expire, where
it finally is deleted. This is bad when some firewall such as
netfilter sits between the client and the server because the
firewall sees the connection in ESTABLISHED state while the
server will finally silently drop it without sending an RST.

This behaviour contradicts the man page which says it should
wait only for some time :

       TCP_DEFER_ACCEPT (since Linux 2.4)
          Allows a listener to be awakened only when data arrives
          on the socket.  Takes an integer value  (seconds), this
          can  bound  the  maximum  number  of attempts TCP will
          make to complete the connection. This option should not
          be used in code intended to be portable.

Also, looking at ipv4/tcp.c, a retransmit counter is correctly
computed :

        case TCP_DEFER_ACCEPT:
                icsk->icsk_accept_queue.rskq_defer_accept = 0;
                if (val > 0) {
                        /* Translate value in seconds to number of
                         * retransmits */
                        while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
                               val > ((TCP_TIMEOUT_INIT / HZ) <<
                                       icsk->icsk_accept_queue.rskq_defer_accept))
                                icsk->icsk_accept_queue.rskq_defer_accept++;
                        icsk->icsk_accept_queue.rskq_defer_accept++;
                }
                break;

==> rskq_defer_accept is used as a counter of retransmits.

But in tcp_minisocks.c, this counter is only checked. And in
fact, I have found no location which updates it. So I think
that what was intended was to decrease it in tcp_minisocks
whenever it is checked, which the trivial patch below does :

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f8d67cc..1b443b0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -645,6 +645,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
 	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
+		inet_csk(sk)->icsk_accept_queue.rskq_defer_accept--;
 		inet_rsk(req)->acked = 1;
 		return NULL;
 	}
 
Is there anything I am missing ?

Regards,
Willy


