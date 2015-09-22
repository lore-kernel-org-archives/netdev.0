From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Tue, 22 Sep 2015 16:04:37 -0400
Message-ID: <CADVnQyn7683PoCo=PaP4CUF6CCNf+V7kCA8RdeZgZwk2SSddig@mail.gmail.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
	<CADVnQy=BXvWMXUGeeABjsHDpfa4FF+RUfCvJXpupcyYKG+=+ig@mail.gmail.com>
	<8021096.gY5K1ti0Dn@garfield>
	<1442933196.29850.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442938150.29850.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442941902.29850.99.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQy=PPe+-HP2Sm7qK6BUxbp-iKjERq7eXvR29+3R1yas7LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:34052 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933591AbbIVUEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 16:04:38 -0400
Received: by obbda8 with SMTP id da8so17113830obb.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 13:04:37 -0700 (PDT)
In-Reply-To: <CADVnQy=PPe+-HP2Sm7qK6BUxbp-iKjERq7eXvR29+3R1yas7LA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 2:02 PM, Neal Cardwell <ncardwell@google.com> wrote:
> More generally, my sense is that we should tweak the is_cwnd_limited code to
> shift from saying "set is_cwnd_limited to true iff the cwnd is known to be
> limiting transmits" to saying "set is_cwnd_limited to true iff the packets in
> flight fill the cwnd".

Here is a proposed patch, and a packetdrill test case based on Eric's,
trying to capture the flavor of your Scenario 1. The test shows how
this proposed variant allows the sender (Reno in this case, for
simplicity) to increase cwnd each RTT in congestion avoidance, since
the cwnd is fully utilized, even though we run out of packets to send
and available cwnd at exactly the same moment.

Bendik, does this fix your scenario? How does this strike you as a
potential fix?

-------------------------------------

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4cd0b50..57a586f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1827,7 +1827,7 @@ static bool tcp_tso_should_defer(struct sock
*sk, struct sk_buff *skb,

        /* Ok, it looks like it is advisable to defer. */

-       if (cong_win < send_win && cong_win < skb->len)
+       if (cong_win < send_win && cong_win <= skb->len)
                *is_cwnd_limited = true;

        return true;
@@ -2060,7 +2060,6 @@ static bool tcp_write_xmit(struct sock *sk,
unsigned int mss_now, int nonagle,

                cwnd_quota = tcp_cwnd_test(tp, skb);
                if (!cwnd_quota) {
-                       is_cwnd_limited = true;
                        if (push_one == 2)
                                /* Force out a loss probe pkt. */
                                cwnd_quota = 1;
@@ -2142,6 +2141,7 @@ repair:
                /* Send one loss probe per tail loss episode. */
                if (push_one != 2)
                        tcp_schedule_loss_probe(sk);
+               is_cwnd_limited |= (tcp_packets_in_flight(tp) >= tp->snd_cwnd);
                tcp_cwnd_validate(sk, is_cwnd_limited);
                return false;
        }

-------------------------------------
# cat cwv-ndc-upstream-1.pkt
--->

// Keep it simple.
`sysctl net.ipv4.tcp_congestion_control=reno`

// Establish a connection and send 1 MSS.
0     socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 65535 <mss 1000,sackOK,nop,nop>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
+.200 < . 1:1(0) ack 1 win 65535
   +0 accept(3, ..., ...) = 4

   +0 write(4, ..., 100) = 100
   +0 > P. 1:101(100) ack 1
+.000 %{ print  tcpi_rto }%

// TLP
+.500~+.505 > P. 1:101(100) ack 1
// RTO
+.600~+.605 > P. 1:101(100) ack 1

+.200 < . 1:1(0) ack 101 win 65535
// cwnd should be 2, ssthresh should be 7
+0 %{ print "1: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%
2.000 write(4, ..., 100) = 100
   +0  > P. 101:201(100) ack 1

// TLP
+.500~+.505 > P. 101:201(100) ack 1
+0 %{ print "2: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%
// RTO
+1.200~+1.210 > P. 101:201(100) ack 1

+0 %{ print "3: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%
+.200 < . 1:1(0) ack 201 win 65535

// cwnd should be 2; since we fill it we should raise it to 3:
+0 %{ assert tcpi_snd_cwnd == 2 }%

+.010 write(4, ..., 1000) = 1000
   +0 > P. 201:1201(1000) ack 1
+0 %{ print "4: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 write(4, ..., 1000) = 1000
   +0 > P. 1201:2201(1000) ack 1
+0 %{ print "5: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 < . 1:1(0) ack 1201 win 65535
+0 %{ print "6: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 < . 1:1(0) ack 2201 win 65535
+0 %{ print "7: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

// cwnd should be 3; since we fill it we should raise it to 4:
+0 %{ assert tcpi_snd_cwnd == 3 }%

+.010 write(4, ..., 1000) = 1000
   +0 > P. 2201:3201(1000) ack 1
+0 %{ print "8: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 write(4, ..., 1000) = 1000
   +0 > P. 3201:4201(1000) ack 1
+0 %{ print "9: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 write(4, ..., 1000) = 1000
   +0 > P. 4201:5201(1000) ack 1
+0 %{ print "9: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 < . 1:1(0) ack 3201 win 65535
+0 %{ print "10: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 < . 1:1(0) ack 4201 win 65535
+0 %{ print "11: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

+.010 < . 1:1(0) ack 5201 win 65535
+0 %{ print "12: cwnd=%d ssthresh=%d out=%d" % (tcpi_snd_cwnd,
tcpi_snd_ssthresh, tcpi_unacked) }%

// cwnd should be 4:
+0 %{ assert tcpi_snd_cwnd == 4 }%

-------------------------------------


Output is:

net.ipv4.tcp_congestion_control = reno
602000
1: cwnd=2 ssthresh=5 out=0
2: cwnd=2 ssthresh=5 out=1
3: cwnd=1 ssthresh=2 out=1
4: cwnd=2 ssthresh=2 out=1
5: cwnd=2 ssthresh=2 out=2
6: cwnd=2 ssthresh=2 out=1
7: cwnd=3 ssthresh=2 out=0
8: cwnd=3 ssthresh=2 out=1
9: cwnd=3 ssthresh=2 out=2
9: cwnd=3 ssthresh=2 out=3
10: cwnd=3 ssthresh=2 out=2
11: cwnd=3 ssthresh=2 out=1
12: cwnd=4 ssthresh=2 out=0
