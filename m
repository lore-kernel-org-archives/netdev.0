From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: do not forget FIN in tcp_shifted_skb()
Date: Fri, 04 Oct 2013 10:31:41 -0700
Message-ID: <1380907901.3564.24.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:50748 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab3JDRbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 13:31:42 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so4440313pad.19
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 10:31:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Yuchung found following problem :

 There are bugs in the SACK processing code, merging part in
 tcp_shift_skb_data(), that incorrectly resets or ignores the sacked
 skbs FIN flag. When a receiver first SACK the FIN sequence, and later
 throw away ofo queue (e.g., sack-reneging), the sender will stop
 retransmitting the FIN flag, and hangs forever.

=46ollowing packetdrill test can be used to reproduce the bug.

$ cat sack-merge-bug.pkt
`sysctl -q net.ipv4.tcp_fack=3D0`

// Establish a connection and send 10 MSS.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
+.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
+.000 bind(3, ..., ...) =3D 0
+.000 listen(3, 1) =3D 0

+.050 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+.000 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+.001 < . 1:1(0) ack 1 win 1024
+.000 accept(3, ..., ...) =3D 4

+.100 write(4, ..., 12000) =3D 12000
+.000 shutdown(4, SHUT_WR) =3D 0
+.000 > . 1:10001(10000) ack 1
+.050 < . 1:1(0) ack 2001 win 257
+.000 > FP. 10001:12001(2000) ack 1
+.050 < . 1:1(0) ack 2001 win 257 <sack 10001:11001,nop,nop>
+.050 < . 1:1(0) ack 2001 win 257 <sack 10001:12002,nop,nop>
// SACK reneg
+.050 < . 1:1(0) ack 12001 win 257
+0 %{ print "unacked: ",tcpi_unacked }%
+5 %{ print "" }%


=46irst, a typo inverted left/right of one OR operation, then
code forgot to advance end_seq if the merged skb carried FIN.

Bug was added in 2.6.29 by commit 832d11c5cd076ab
("tcp: Try to restore large SKBs while SACK processing")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 25a89ea..113dc5f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1284,7 +1284,10 @@ static bool tcp_shifted_skb(struct sock *sk, str=
uct sk_buff *skb,
 		tp->lost_cnt_hint -=3D tcp_skb_pcount(prev);
 	}
=20
-	TCP_SKB_CB(skb)->tcp_flags |=3D TCP_SKB_CB(prev)->tcp_flags;
+	TCP_SKB_CB(prev)->tcp_flags |=3D TCP_SKB_CB(skb)->tcp_flags;
+	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
+		TCP_SKB_CB(prev)->end_seq++;
+
 	if (skb =3D=3D tcp_highest_sack(sk))
 		tcp_advance_highest_sack(sk, skb);
=20
