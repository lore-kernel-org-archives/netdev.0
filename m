From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 0/7] netfilter: introduce new chain type for local socket input
Date: Tue, 29 Sep 2015 13:12:13 +0200
Message-ID: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a patch set that enables for full support for match rules
that take into account information about the local receiver socket.

Such rules allow administrators to implement per-application or
per-container firewalls which filter any type of network traffic
directed to or originated from a set of processes on a system,
independent of, for instance, local or remote port numbers.

In theory, such rules are already supported through the 'meta' and
'socket' rule types, but they currently do not work for ingress packets
delivered to unestablished listener sockets. NF_INET_LOCAL_IN chains
are iterated once the IP stack decides a packet is directed to the
local system, but before the local listener socket is determined.
Consequently, filter rules that are based on information derived from
the listener socket cannot be used reliably.

This patch set introduces a new chain type (NF_INET_LOCAL_SOCKET_IN)
that is iterated at a later point in time than NF_INET_LOCAL_IN, after
the listener socket demux has succeeded. Chains of this type are hence
only looked at _if_ there is a local listener.

The input paths for TCP and UDP for IPv4 and IPv6 are patched for
the new hook-up, as well as SCTP and DCCP.

Possible performance penalties for setups in which this new type is
not used need to be considered, but I lack a good test case for that.
I'm sure some people reading this do have proper test scenarios they
can run with these patches applied. I'd be very interested in these
numbers.

For SCTP and DCCP, I admittedly lack a proper test case as well, and
for UDP, I'm aware of a possible deadlock due to nf_hook() being called
under hslot->lock when the stack is flushed preliminarily from
__udp[46]_lib_mcast_deliver(). That's fixable, but I've kept it simple
for this RFC.

Only nftables is supported so far, but enabling iptables as well would
be straight forward.

I also have trivial patches for libnftnl and nftables to enable
the userspace part.

I'd appreciate some feedback about this approach.


Thanks,
Daniel


Daniel Mack (7):
  netfilter: add socket to struct nft_pktinfo
  netfilter: nft_meta: look at pkt->sk rather than skb->sk
  netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
  net: tcp_ipv4, udp_ipv4: hook up LOCAL_SOCKET_IN netfilter chains
  net: tcp_ipv6, udp_ipv6: hook up LOCAL_SOCKET_IN netfilter chains
  net: sctp: hook up LOCAL_SOCKET_IN netfilter chains
  net: dccp: hook up LOCAL_SOCKET_IN netfilter chains

 include/net/netfilter/nf_tables.h   |  2 ++
 include/uapi/linux/netfilter.h      |  1 +
 net/dccp/ipv4.c                     | 14 +++++++++++++-
 net/dccp/ipv6.c                     | 14 +++++++++++++-
 net/ipv4/netfilter/iptable_filter.c |  1 +
 net/ipv4/netfilter/nf_tables_ipv4.c | 14 ++++++++------
 net/ipv4/tcp_ipv4.c                 |  8 ++++++++
 net/ipv4/udp.c                      | 15 +++++++++++++++
 net/ipv6/netfilter/nf_tables_ipv6.c | 14 ++++++++------
 net/ipv6/tcp_ipv6.c                 |  8 ++++++++
 net/ipv6/udp.c                      |  9 +++++++++
 net/netfilter/nf_tables_inet.c      |  3 ++-
 net/netfilter/nft_meta.c            |  7 ++++---
 net/sctp/input.c                    | 11 ++++++++++-
 14 files changed, 102 insertions(+), 19 deletions(-)

-- 
2.5.0

