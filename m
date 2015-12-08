From: Per Hurtig <per.hurtig@kau.se>
Subject: [RFC PATCHv2 net-next 0/2] tcp: timer restart for tail loss
Date: Tue,  8 Dec 2015 10:19:41 +0100
Message-ID: <cover.1449561786.git.per.hurtig@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se>
Cc: anna.brunstrom@kau.se, apetlund@simula.no, michawe@ifi.uio.no,
	mohammad.rajiullah@kau.se, Per Hurtig <per.hurtig@kau.se>
To: davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	nanditad@google.com, tom@herbertland.com, ycheng@google.com,
	viro@zeniv.linux.org.uk, fw@strlen.de, mleitner@redhat.com,
	daniel@iogearbox.net, willemb@google.com,
	ilpo.jarvinen@helsinki.fi, pasi.sarolahti@iki.fi,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:19627 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755109AbbLHJ04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 04:26:56 -0500
In-Reply-To: <cover.1449478261.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a request for comments.

RTO and TLP restart is a modification to the restart process of the RTO and
TLP timers in TCP. Currently, both timers are restarted with its
corresponding timeout value when an acknowledgment (ACK) for correctly
received data is received. In many situations, resetting the timers on
incoming ACKs will add an implicit offset of at least RTT seconds to the
loss recovery process.

The goal of the modified restart is to provide quicker loss recovery for
segments lost in the end of a burst/connection, where the limited feedback
from a receiver inhibits the use of fast/early retransmit. To accomplish
this the algorithm adjusts the RTO and PTO (TLP's timer) values on each
rearm of the timers to allow them to expire after exactly RTO and PTO ms,
respectively.

The restart behavior is controlled by the new tcp_timer_restart sysctl.
tcp_timer_restart==0; disables RTOR and TLPR.
		 ==1; enables RTOR.
		 ==2; enables TLPR.
		 ==3; enables both RTOR and TLPR. [DEFAULT]

The new restart behavior has been approved by the IETF for publication as
an experimental RFC (for the RTO part of the mechanism) [1], and
experiments have been conducted to show both the benefit of this strategy
(in terms of reduced loss-recovery delays) and the limited negative impact
(in terms of spurious retransmissions) [2]. More information regarding the
mechanism can be found at [3].

Basic functionality tests, using packetdrill, are available at:
https://github.com/perhurt/packetdrill/tree/master/gtests/net/packetdrill/tests/linux/timer_restart


[1] https://datatracker.ietf.org/doc/draft-ietf-tcpm-rtorestart/
[2] http://www.sigcomm.org/sites/default/files/ccr/papers/2015/January/0000000-0000000.pdf
[3] http://riteproject.eu/resources/rto-restart/

Per Hurtig (2):
  tcp: RTO Restart (RTOR)
  tcp: TLP restart (TLPR)

 Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
 include/net/tcp.h                      |  8 +++++++-
 net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
 net/ipv4/tcp_input.c                   | 31 ++++++++++++++++++++++++++++++-
 net/ipv4/tcp_output.c                  | 12 ++++++++++--
 5 files changed, 69 insertions(+), 4 deletions(-)

-- 
1.9.1
