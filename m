From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/5] net: add protocol level recvmmsg support
Date: Fri, 25 Nov 2016 16:39:51 +0100
Message-ID: <cover.1480086321.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35028 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754801AbcKYPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:41:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of recvmmsg() is to amortize the syscall overhead on a possible
long messages batch, but for most networking protocols, e.g. udp the
syscall overhead is negligible compared to the protocol specific operations
like dequeuing.

Moreover, the current recvmmsg() implementation has a long-standing bug with
the timeout argument that can be solved only with protocol level support for
recvmmsg().

This patch series aims to solve both issues, introducing support for
the recvmmsg implementation at the protocol level, adding some generic helpers
for such operation, and finally implementing recvmmsg() support for
udp[v6]/udplite[v6]. Such support does not cover MSG_PEEK and MSG_ERRQUEUE,
as a trade-off between benefit and implementation complexity.

The udp version of recvmmsg() tries to bulk-dequeue skbs from the receive queue,
each burst acquires the lock once to extract as many skbs from the receive
queue as possible, up to the number needed to reach the specified maximum.
rmem_alloc and fwd memory are touched once per burst.

When the protocol-level recvmmsg() is not available or it does not support the
specified flags, the code falls-back to the current generic implementation.

This series introduces some behavior changes for the recvmmsg() syscall (only
for udp):
- the timeout argument now works as expected
- recvmmsg() does not stop anymore when getting the first error, instead
  it keeps processing the current burst and then handle the error code as
  in the generic implementation.

The measured performance delta is as follow:

		before		after
		(Kpps)		(Kpps)

udp flood[1]	570		1800(+215%)
max tput[2]	1850		3500(+89%)
single queue[3]	1850		1630(-11%)

[1] line rate flood using multiple 64 bytes packets and multiple flows
[2] like [1], but using the minimum number of flows to saturate the user space
 sink, that is 1 flow for the old kernel and 3 for the patched one.
 the tput increases since the contention on the rx lock is low.
[3] like [1] but using a single flow with both old and new kernel. All the
 packets land on the same rx queue and there is a single ksoftirqd instance
 running

The regression in the single queue scenario is actually due to the improved
performance of the recvmmsg() syscall: the user space process is now
significantly faster than the ksoftirqd process so that the latter needs often
to wake up the user space process.

Since ksoftirqd is the bottle-neck is such scenario, overall this causes a
tput reduction. In a real use case, where the udp sink is performing some
actual processing of the received data, such regression is unlikely to really
have an effect.

Join work with Sabrina Dubroca <sd@queasysnail.net>.

Paolo Abeni (5):
  net/socket: factor out msghdr manipulation helpers
  net/socket: add per protocol mmesg support
  net/udp: factor out main skb processing routine
  net/socket: add helpers for recvmmsg
  udp: add recvmmsg implementation

 include/linux/net.h       |   5 ++
 include/linux/skbuff.h    |  20 +++++
 include/net/inet_common.h |   3 +
 include/net/sock.h        |  43 +++++++++++
 include/net/udp.h         |   7 ++
 net/core/datagram.c       |  65 ++++++++++++++++
 net/ipv4/af_inet.c        |  16 ++++
 net/ipv4/udp.c            | 188 +++++++++++++++++++++++++++++++++++++++-------
 net/ipv4/udp_impl.h       |   3 +
 net/ipv4/udplite.c        |   1 +
 net/ipv6/af_inet6.c       |   1 +
 net/ipv6/udp.c            |  89 +++++++++++++++-------
 net/ipv6/udp_impl.h       |   3 +
 net/ipv6/udplite.c        |   1 +
 net/socket.c              | 183 ++++++++++++++++++++++++++++++++------------
 15 files changed, 528 insertions(+), 100 deletions(-)

-- 
1.8.3.1
