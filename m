From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 21:16:32 +0200
Message-ID: <20100926191632.GB13046@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <1285520567.2530.8.camel@edumazet-laptop> <20100926174014.GA12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45696 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757090Ab0IZTQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 15:16:41 -0400
Content-Disposition: inline
In-Reply-To: <20100926174014.GA12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 07:40:15PM +0200, Willy Tarreau wrote:
> 3) when an ACK comes from the other side, either it's below our last
>    seq, and we simply ignore it, just as if we were in TIME_WAIT, or
>    it is equal to the last seq and indicates that it's now safe to
>    reset ; we would then just send the RST to notify the other side
>    that the data it sent were not read. The connection can then either
>    be destroyed or put in TIME_WAIT. It's the point where the connection
>    normally switches from FIN_WAIT1 to FIN_WAIT2, since the FIN has been
>    acked. The only difference is that we don't need a FIN_WAIT2 state
>    for an orphan.

In fact, the following patch seems to provide the expected result :

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f1813bc..ee5fa5d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1879,7 +1880,7 @@ void tcp_close(struct sock *sk, long timeout)
 	 * advertise a zero window, then kill -9 the FTP client, wheee...
 	 * Note: timeout is always zero in such a case.
 	 */
-	if (data_was_unread) {
+	if (data_was_unread && !tcp_sk(sk)->packets_out) {
 		/* Unread data was tossed, zap the connection. */
 		NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONCLOSE);
 		tcp_set_state(sk, TCP_CLOSE);


Here's what I get if I call it that way :

$ (echo "req1";usleep 200000;echo "req2") | nc6 10.8.3.4 8000

(excuse me for the long lines, I've disabled timestamps for better readability
but they're still long).

21:11:43.379465 IP 10.8.3.1.59244 > 10.8.3.4.8000: Flags [S], seq 210901267, win 5840, options [mss 1460,sackOK,TS val 305301003 ecr 0,nop,wscale 7], length 0
21:11:43.379514 IP 10.8.3.4.8000 > 10.8.3.1.59244: Flags [S.], seq 3131672819, ack 210901268, win 5840, options [mss 1460,nop,nop,sackOK,nop,wscale 6], length 0
21:11:43.379866 IP 10.8.3.1.59244 > 10.8.3.4.8000: Flags [.], ack 3131672820, win 46, length 0
21:11:43.379922 IP 10.8.3.1.59244 > 10.8.3.4.8000: Flags [P.], ack 3131672820, win 46, length 5
21:11:43.379946 IP 10.8.3.4.8000 > 10.8.3.1.59244: Flags [.], ack 210901273, win 92, length 0
21:11:43.581305 IP 10.8.3.1.59244 > 10.8.3.4.8000: Flags [P.], ack 3131672820, win 46, length 5
21:11:43.581331 IP 10.8.3.4.8000 > 10.8.3.1.59244: Flags [.], ack 210901278, win 92, length 0
21:11:44.380442 IP 10.8.3.4.8000 > 10.8.3.1.59244: Flags [P.], ack 210901278, win 92, length 7
21:11:44.380506 IP 10.8.3.4.8000 > 10.8.3.1.59244: Flags [FP.], seq 3131672827:3131672834, ack 210901278, win 92, length 7
21:11:44.380649 IP 10.8.3.1.59244 > 10.8.3.4.8000: Flags [.], ack 3131672827, win 46, length 0
21:11:44.380672 IP 10.8.3.1.59244 > 10.8.3.4.8000: Flags [F.], seq 210901278, ack 3131672835, win 46, length 0
21:11:44.380685 IP 10.8.3.4.8000 > 10.8.3.1.59244: Flags [.], ack 210901279, win 92, length 0

Here we have correctly got a FIN+PUSH for the last data instead of the reset.
The other side ACKs and after the last ACK, the socket is correctly in
TIME_WAIT state.

If I try to push more data after the connection closes, I correctly get
a reset to be sent :

$ (echo "req1";usleep 1200000;echo "req2"; usleep 200000; echo "req3") | nc6 --half-close 10.8.3.4 8000

21:15:00.068376 IP 10.8.3.1.60849 > 10.8.3.4.8000: Flags [S], seq 3284326660, win 5840, options [mss 1460,sackOK,TS val 305350241 ecr 0,nop,wscale 7], length 0
21:15:00.068428 IP 10.8.3.4.8000 > 10.8.3.1.60849: Flags [S.], seq 1933854189, ack 3284326661, win 5840, options [mss 1460,nop,nop,sackOK,nop,wscale 6], length 0
21:15:00.068779 IP 10.8.3.1.60849 > 10.8.3.4.8000: Flags [.], ack 1933854190, win 46, length 0
21:15:00.068830 IP 10.8.3.1.60849 > 10.8.3.4.8000: Flags [P.], ack 1933854190, win 46, length 5
21:15:00.068854 IP 10.8.3.4.8000 > 10.8.3.1.60849: Flags [.], ack 3284326666, win 92, length 0
21:15:01.069238 IP 10.8.3.4.8000 > 10.8.3.1.60849: Flags [P.], ack 3284326666, win 92, length 7
21:15:01.069300 IP 10.8.3.4.8000 > 10.8.3.1.60849: Flags [FP.], seq 1933854197:1933854204, ack 3284326666, win 92, length 7
21:15:01.069448 IP 10.8.3.1.60849 > 10.8.3.4.8000: Flags [.], ack 1933854197, win 46, length 0
21:15:01.109938 IP 10.8.3.1.60849 > 10.8.3.4.8000: Flags [.], ack 1933854205, win 46, length 0
21:15:01.270509 IP 10.8.3.1.60849 > 10.8.3.4.8000: Flags [P.], ack 1933854205, win 46, length 5
21:15:01.270542 IP 10.8.3.4.8000 > 10.8.3.1.60849: Flags [R], seq 1933854205, win 0, length 0

I had already tested that previously but unfortunately the test was
combined with an attempt to zero the rx window, which had corrupted my
tests.

Would you have any problem with the proposed change above ?

Thanks,
Willy

