From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 00/13] TProxy IPv6 support 2nd round
Date: Mon, 21 Sep 2009 15:51:40 +0000
Message-ID: <1253548300.12519.20.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is the 2nd version of TProxy and by this time it is complete with UDP
and ICMP support. For those credits go to Harry Mason from Smoothwall.

Now I consider this patch complete, testers, reviews comments are very
welcome.  

If no blockers show up, please consider this a merge request.

I only know of one issue and I hope it does not block merging at this time:
the socket and TPROXY modules both depend on both IPv4 and IPv6 stacks, thus
pulling in the other even if only one of the stacks are in use.  Of course
if IPv6 is not configured into the kernel no such dependency is present.

I've tested the functionality of this patch-set with an automatic test
program that runs a large number of tests and covers most of the TProxy
functionality.  You can find this program at:

git://git.balabit.hu/bazsi/tproxy-test.git/

I would appreciate if someone with more intimate IPv6 knowledge would review
this code, especially:
  * IPv6 ICMP packet parsing
  * the way the default local IP address is found 
    (especially returning a pointer pointing to &inet6_ifaddr->addr outside RCU section)

This patchset is based on an older tree of Linus, I don't expect any
problems with net-next, but please let me know if I have to rebase/retest. 

The userspace portion of the tproxy functionality comes in a followup
patch-set.

In addition to IPv6 support there are 3 patches in this series:
  1) a fix for properly handling TIME_WAIT connections
  2) a fix for the default value of --on-ip
  3) and an optional change in ipv6_pinfo structure

While the last is completely independent of TProxy and is optional, the 
first two are quite important fixes. Although they are independent of this 
submission, they are the  first and last patches of the series, so they can 
be reviewed independently :)

And again, please apply.

Balazs Scheidler (13):
  TProxy: kick out TIME_WAIT sockets in case a new connection comes in
    with the same tuple
  TProxy: add lookup type checks for UDP in nf_tproxy_get_sock_v4()
  TProxy: move dst_cookie to the first cacheline in ipv6_pinfo
  TProxy: split off ipv6 defragmentation to a separate module
  TProxy: added const specifiers to udp lookup functions
  TProxy: added udp6_lib_lookup function
  TProxy: implement IPv6 "local" routing type
  TProxy: added tproxy sockopt interface in the IPV6 layer
  TProxy: allow non-local binds of IPv6 sockets if IP_TRANSPARENT is
    enabled
  TProxy: added IPv6 socket lookup function to nf_tproxy_core
  TProxy: added IPv6 support to the TPROXY target
  TProxy: added IPv6 support to the socket match
  TProxy: use the interface primary IP address as a default value for
    --on-ip

 include/linux/in6.h                            |    5 +
 include/linux/ipv6.h                           |    7 +-
 include/linux/netfilter/xt_TPROXY.h            |   15 +-
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |    6 +
 include/net/netfilter/nf_tproxy_core.h         |  192 +++++++++++++++-
 include/net/udp.h                              |    3 +
 net/ipv6/af_inet6.c                            |    2 +-
 net/ipv6/datagram.c                            |   19 ++
 net/ipv6/ipv6_sockglue.c                       |   22 ++
 net/ipv6/netfilter/Makefile                    |    5 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   58 +-----
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   12 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  109 +++++++++
 net/ipv6/route.c                               |    6 +-
 net/ipv6/udp.c                                 |   16 +-
 net/netfilter/nf_tproxy_core.c                 |   35 ---
 net/netfilter/xt_TPROXY.c                      |  290 ++++++++++++++++++++++--
 net/netfilter/xt_socket.c                      |  154 ++++++++++++-
 18 files changed, 815 insertions(+), 141 deletions(-)
 create mode 100644 include/net/netfilter/ipv6/nf_defrag_ipv6.h
 create mode 100644 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c

