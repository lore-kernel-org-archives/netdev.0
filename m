From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 0/4] RCU: introduce noref debug
Date: Fri,  6 Oct 2017 14:57:45 +0200
Message-ID: <cover.1507294365.git.pabeni@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The networking subsystem is currently using some kind of long-lived
RCU-protected, references to avoid the overhead of full book-keeping.

Such references - skb_dst() noref - are stored inside the skbs and can be
moved across relevant slices of the network stack, with the users
being in charge of properly clearing the relevant skb - or properly refcount
the related dst references - before the skb escapes the RCU section.

We currently don't have any deterministic debug infrastructure to check
the dst noref usages - and the introduction of others noref artifact is
currently under discussion.

This series tries to tackle the above introducing an RCU debug infrastructure
aimed at spotting incorrect noref pointer usage, in patch one. The
infrastructure is small and must be explicitly enabled via a newly introduced
build option.

Patch two uses such infrastructure to track dst noref usage in the networking
stack.

Patch 3 and 4 are bugfixes for small buglet found running this infrastructure
on basic scenarios.

Paolo Abeni (4):
  rcu: introduce noref debug
  net: use RCU noref infrastructure to track dst noref
  ipv4: drop unneeded and misleading RCU lock in ip_route_input_noref()
  tcp: avoid noref dst leak on input path

 include/linux/rcupdate.h | 11 ++++++
 include/linux/skbuff.h   |  1 +
 include/net/dst.h        |  5 +++
 kernel/rcu/Kconfig.debug | 15 ++++++++
 kernel/rcu/Makefile      |  1 +
 kernel/rcu/noref_debug.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/route.c         |  7 +---
 net/ipv4/tcp_input.c     |  5 ++-
 8 files changed, 127 insertions(+), 7 deletions(-)
 create mode 100644 kernel/rcu/noref_debug.c

-- 
2.13.6
