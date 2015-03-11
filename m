From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/8] tcp_metrics: Network namespace bloat reduction v2
Date: Wed, 11 Mar 2015 11:33:29 -0500
Message-ID: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:38764 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbCKQhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:37:11 -0400
In-Reply-To: <87h9tu114z.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Mon, 09 Mar 2015 13:22:52 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a small pile of patches that convert tcp_metrics from using a
hash table per network namespace to using a single hash table for all
network namespaces.

This is broken up into several patches so that each small step along
the way could be carefully scrutinized as I wrote it, and equally so
that each small step can be reviewed.

There are several cleanups included in this series.  The death of
hold_net and release_net.  The addition of a new type possible_net_t to
allow compiling out struct net * pointers in structures without ugly
ifdefs.  The addition of panic calls during boot where we can not handle
failure, and not trying simplifies the code.  The removal of the return
code from tcp_metrics_flush_all.

The motivation for this change is that the tcp_metrics hash table at
128KiB is one of the largest components of a freshly allocated network
namespace.

Eric W. Biederman (6):
      tcp_metrics: panic when tcp_metrics can not be allocated
      tcp_metrics: Mix the network namespace into the hash function.
      tcp_metrics: Add a field tcpm_net and verify it matches on lookup
      tcp_metrics: Remove the unused return code from tcp_metrics_flush_all
      tcp_metrics: Rewrite tcp_metrics_flush_all
      tcp_metrics: Use a single hash table for all network namespaces.

 include/net/netns/ipv4.h |   2 -
 net/ipv4/tcp_metrics.c   | 118 +++++++++++++++++++++++++++++------------------
 2 files changed, 73 insertions(+), 47 deletions(-)

Eric W. Biederman (8):
      net: Kill hold_net release_net
      net: Introduce possible_net_t
      tcp_metrics: panic when tcp_metrics_init fails.
      tcp_metrics: Mix the network namespace into the hash function.
      tcp_metrics: Add a field tcpm_net and verify it matches on lookup
      tcp_metrics: Remove the unused return code from tcp_metrics_flush_all
      tcp_metrics: Rewrite tcp_metrics_flush_all
      tcp_metrics: Use a single hash table for all network namespaces.

 include/linux/netdevice.h            |   9 +--
 include/net/cfg80211.h               |   4 +-
 include/net/fib_rules.h              |   1 -
 include/net/genetlink.h              |   4 +-
 include/net/inet_hashtables.h        |   4 +-
 include/net/ip_vs.h                  |   8 +-
 include/net/neighbour.h              |   8 +-
 include/net/net_namespace.h          |  52 ++++---------
 include/net/netfilter/nf_conntrack.h |   5 +-
 include/net/netns/ipv4.h             |   2 -
 include/net/sock.h                   |   6 +-
 include/net/xfrm.h                   |   8 +-
 net/9p/trans_fd.c                    |   4 +-
 net/core/dev.c                       |   2 -
 net/core/fib_rules.c                 |   8 +-
 net/core/neighbour.c                 |   9 +--
 net/core/net_namespace.c             |  11 ---
 net/core/sock.c                      |   1 -
 net/ipv4/fib_semantics.c             |   3 +-
 net/ipv4/inet_hashtables.c           |   3 +-
 net/ipv4/inet_timewait_sock.c        |   4 +-
 net/ipv4/ipmr.c                      |   4 +-
 net/ipv4/tcp_metrics.c               | 137 +++++++++++++++++++----------------
 net/ipv6/addrlabel.c                 |  11 +--
 net/ipv6/ip6_flowlabel.c             |   3 +-
 net/ipv6/ip6mr.c                     |   4 +-
 net/openvswitch/datapath.c           |   4 +-
 net/openvswitch/datapath.h           |   4 +-
 net/packet/internal.h                |   4 +-
 29 files changed, 121 insertions(+), 206 deletions(-)
