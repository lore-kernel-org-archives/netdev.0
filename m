From: Cong Wang <amwang@redhat.com>
Subject: TCP delayed ACK heuristic
Date: Tue, 18 Dec 2012 10:11:24 -0500 (EST)
Message-ID: <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
References: <270756364.27707018.1355842632348.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>, Thomas Graf <tgraf@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:55528 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab2LRPLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 10:11:30 -0500
In-Reply-To: <270756364.27707018.1355842632348.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, TCP experts!

Some time ago, Ben sent a patch [1] to add some knobs for
tuning TCP delayed ACK, but rejected by David.

David's point is that we can do some heuristics for TCP
delayed ACK, so the question is that what kind of heuristics
can we use?

RFC1122 explicitly mentions:

            A TCP SHOULD implement a delayed ACK, but an ACK should not
            be excessively delayed; in particular, the delay MUST be
            less than 0.5 seconds, and in a stream of full-sized
            segments there SHOULD be an ACK for at least every second
            segment.

so this prevents us from using any heuristic for the number
of coalesced delayed ACK.

For the timeout of a delayed ACK, my idea is guessing how many
packet we suppose to receive is the TCP stream is fully utilized,
something like below:

+static inline u32 tcp_expect_packets(struct sock *sk)
+{
+       struct tcp_sock *tp = tcp_sk(sk);
+       int rtt = tp->srtt >> 3;
+       u32 idle = tcp_time_stamp - inet_csk(sk)->icsk_ack.lrcvtime;
+
+       return idle * 2 / rtt;
+}
...
+       ato -= tcp_expect_packets(sk) * delta;


The more we expect, the less we should delay. However this is
not accurate due to congestion control.

Meanwhile, we can also check how many packets are pending in TCP
sending queue, the more we pend, the more we can piggyback with
a single ACK, but not beyond how much we are able to send at
that time.

Comments? Ideas?

Thanks.

1. http://thread.gmane.org/gmane.linux.network/233859
