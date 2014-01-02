From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH net-next] tcp: do not increase the rcv window when the FIN has been received
Date: Thu, 2 Jan 2014 23:40:21 +0100
Message-ID: <20140102224021.GA20358@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:54742 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbaABWk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 17:40:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In HTTP performance tests it appeared that my client was always sending
an ACK immediately after receiving the FIN from the server and that the
sole purpose of this ACK was to advertise a larger window. This is not
nedeed when the FIN is received since the peer won't send any more data,
and wastes a packet in the direction to the server. Adding a check for
RCV_SHUTDOWN to the condition to send this packet fixes the issue, as
all packet sizes now behave like the short version. BTW that this is
even visible on the loopback.

Before the patch :

A 536-byte payload induces an immediate ACK after the server's FIN is
received :

    $ injectl464 -o 1 -u 1  -G 192.168.0.176:9000/?s=386 -T 1000

    15:08:38.939425 IP 192.168.0.176.35781 > 192.168.0.176.9000: Flags [S], seq 4152512456, win 43690, options [mss 65495,sackOK,TS val 1581485 ecr 0,nop,wscale 7], length 0
    15:08:38.939441 IP 192.168.0.176.9000 > 192.168.0.176.35781: Flags [S.], seq 691229241, ack 4152512457, win 43690, options [mss 65495,sackOK,TS val 1581485 ecr 1581485,nop,wscale 7], length 0
    15:08:38.939457 IP 192.168.0.176.35781 > 192.168.0.176.9000: Flags [.], ack 691229242, win 342, options [nop,nop,TS val 1581485 ecr 1581485], length 0
    15:08:38.939501 IP 192.168.0.176.35781 > 192.168.0.176.9000: Flags [P.], seq 4152512457:4152512584, ack 691229242, win 342, options [nop,nop,TS val 1581485 ecr 1581485], length 127
    15:08:38.939570 IP 192.168.0.176.9000 > 192.168.0.176.35781: Flags [F.], seq 691229242:691229778, ack 4152512584, win 342, options [nop,nop,TS val 1581485 ecr 1581485], length 536
    15:08:38.939595 IP 192.168.0.176.35781 > 192.168.0.176.9000: Flags [.], ack 691229779, win 342, options [nop,nop,TS val 1581485 ecr 1581485], length 0
    15:08:38.940017 IP 192.168.0.176.35781 > 192.168.0.176.9000: Flags [F.], seq 4152512584, ack 691229779, win 342, options [nop,nop,TS val 1581486 ecr 1581485], length 0
    15:08:38.940035 IP 192.168.0.176.9000 > 192.168.0.176.35781: Flags [.], ack 4152512585, win 342, options [nop,nop,TS val 1581486 ecr 1581486], length 0

A smaller payload (535 bytes and below) does not cause this to happen :

    $ injectl464 -o 1 -u 1  -G 192.168.0.176:9000/?s=385 -T 1000

    15:08:43.691785 IP 192.168.0.176.35782 > 192.168.0.176.9000: Flags [S], seq 1414138895, win 43690, options [mss 65495,sackOK,TS val 1582673 ecr 0,nop,wscale 7], length 0
    15:08:43.691810 IP 192.168.0.176.9000 > 192.168.0.176.35782: Flags [S.], seq 1784595528, ack 1414138896, win 43690, options [mss 65495,sackOK,TS val 1582673 ecr 1582673,nop,wscale 7], length 0
    15:08:43.691825 IP 192.168.0.176.35782 > 192.168.0.176.9000: Flags [.], ack 1784595529, win 342, options [nop,nop,TS val 1582673 ecr 1582673], length 0
    15:08:43.691868 IP 192.168.0.176.35782 > 192.168.0.176.9000: Flags [P.], seq 1414138896:1414139023, ack 1784595529, win 342, options [nop,nop,TS val 1582673 ecr 1582673], length 127
    15:08:43.691933 IP 192.168.0.176.9000 > 192.168.0.176.35782: Flags [F.], seq 1784595529:1784596064, ack 1414139023, win 342, options [nop,nop,TS val 1582673 ecr 1582673], length 535
    15:08:43.692034 IP 192.168.0.176.35782 > 192.168.0.176.9000: Flags [F.], seq 1414139023, ack 1784596065, win 342, options [nop,nop,TS val 1582674 ecr 1582673], length 0
    15:08:43.692048 IP 192.168.0.176.9000 > 192.168.0.176.35782: Flags [.], ack 1414139024, win 342, options [nop,nop,TS val 1582674 ecr 1582674], length 0

Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 net/ipv4/tcp.c       | 3 ++-
 net/ipv4/tcp_input.c | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c4638e6..1eab74c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1350,7 +1350,8 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 		    * receive. */
 		if (icsk->icsk_ack.blocked ||
 		    /* Once-per-two-segments ACK was not sent by tcp_input.c */
-		    tp->rcv_nxt - tp->rcv_wup > icsk->icsk_ack.rcv_mss ||
+		    (!(sk->sk_shutdown & RCV_SHUTDOWN) &&
+		     tp->rcv_nxt - tp->rcv_wup > icsk->icsk_ack.rcv_mss) ||
 		    /*
 		     * If this read emptied read buffer, we send ACK, if
 		     * connection is not bidirectional, user drained
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c53b7f3..c6c0420 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4796,6 +4796,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 
 	    /* More than one full frame received... */
 	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
+	     /* and peer is interested in our window updates */
+	     !(sk->sk_shutdown & RCV_SHUTDOWN) &&
 	     /* ... and right edge of window advances far enough.
 	      * (tcp_recvmsg() will send ACK otherwise). Or...
 	      */
-- 
1.7.12.2.21.g234cd45.dirty
