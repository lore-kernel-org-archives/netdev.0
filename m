From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next 0/14] netfilter: Stop guessing net
Date: Fri, 18 Sep 2015 10:06:24 -0500
Message-ID: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40450 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbIRPNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 11:13:38 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 15 Sep 2015 19:59:49 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the next installment of my work to pass struct net through the
output path so the code does not need to guess how to figure out which
network namespace it is in, and ultimately routes can have output
devices in another network namespace.

This round the changes focus on using nf_hook_state->net in the
netfilter functions, and not passing nf_hook_ops to the functions on the
netfilter chains.

Given the way per network namespace operations are implemented callers
can not rely on addresses or games with container_of.  None of the
netfilter hooks do but we should remove the temptation.  Plus removing
the extra parameter and the extra jump to get at values should reduce
the number of cache line misses.

At a practical matter this is the bulk of the work that other pieces of
code in the netfilter stack will depend on.

The changes are also available against net-next at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

My entire pending set of changes for those who want to look ahead is at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git for-testing

Eric

Eric W. Biederman (14):
      ebtables: Simplify the arguments to ebt_do_table
      inet netfilter: Remove hook from ip6t_do_table, arp_do_table, ipt_do_table
      inet netfilter: Prefer state->hook to ops->hooknum
      nftables: kill nft_pktinfo.ops
      x_tables: Pass struct net in xt_action_param
      x_tables: Use par->net instead of computing from the passed net devices
      nftables: Pass struct net in nft_pktinfo
      nftables: Use pkt->net instead of computing net from the passed net_devices
      net: Pass net to nf_dup_ipv4 and nf_dup_ipv6
      nf_conntrack: Add a struct net parameter to l4_pkt_to_tuple
      ipvs: Read hooknum from state rather than ops->hooknum
      netfilter: Pass priv instead of nf_hook_ops to netfilter hooks
      netfilter: Pass net into nf_xfrm_me_harder
      netfilter: Use nf_ct_net instead of dev_net(out) in nf_nat_masquerade_ipv6

 include/linux/netfilter.h                      |  2 +-
 include/linux/netfilter/x_tables.h             |  3 +-
 include/linux/netfilter_arp/arp_tables.h       |  1 -
 include/linux/netfilter_bridge/ebtables.h      |  6 ++--
 include/linux/netfilter_ipv4/ip_tables.h       |  1 -
 include/linux/netfilter_ipv6/ip6_tables.h      |  1 -
 include/net/netfilter/br_netfilter.h           |  2 +-
 include/net/netfilter/ipv4/nf_dup_ipv4.h       |  2 +-
 include/net/netfilter/ipv6/nf_dup_ipv6.h       |  2 +-
 include/net/netfilter/nf_conntrack.h           |  3 +-
 include/net/netfilter/nf_conntrack_core.h      |  1 +
 include/net/netfilter/nf_conntrack_l4proto.h   |  2 +-
 include/net/netfilter/nf_nat_core.h            |  2 +-
 include/net/netfilter/nf_nat_l3proto.h         | 32 ++++++++++----------
 include/net/netfilter/nf_tables.h              | 14 ++++-----
 include/net/netfilter/nf_tables_ipv4.h         |  3 +-
 include/net/netfilter/nf_tables_ipv6.h         |  3 +-
 net/bridge/br_netfilter_hooks.c                | 14 ++++-----
 net/bridge/br_netfilter_ipv6.c                 |  2 +-
 net/bridge/netfilter/ebt_log.c                 |  2 +-
 net/bridge/netfilter/ebt_nflog.c               |  2 +-
 net/bridge/netfilter/ebtable_broute.c          |  8 +++--
 net/bridge/netfilter/ebtable_filter.c          | 10 +++---
 net/bridge/netfilter/ebtable_nat.c             | 10 +++---
 net/bridge/netfilter/ebtables.c                | 14 +++++----
 net/bridge/netfilter/nf_tables_bridge.c        | 20 ++++++------
 net/bridge/netfilter/nft_reject_bridge.c       | 19 ++++++------
 net/decnet/netfilter/dn_rtmsg.c                |  2 +-
 net/ipv4/netfilter/arp_tables.c                |  3 +-
 net/ipv4/netfilter/arptable_filter.c           |  5 ++-
 net/ipv4/netfilter/ip_tables.c                 |  3 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  4 +--
 net/ipv4/netfilter/ipt_rpfilter.c              |  5 ++-
 net/ipv4/netfilter/iptable_filter.c            |  7 ++---
 net/ipv4/netfilter/iptable_mangle.c            | 14 ++++-----
 net/ipv4/netfilter/iptable_nat.c               | 21 ++++++-------
 net/ipv4/netfilter/iptable_raw.c               |  7 ++---
 net/ipv4/netfilter/iptable_security.c          |  7 ++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 12 ++++----
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  4 +--
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  4 +--
 net/ipv4/netfilter/nf_dup_ipv4.c               | 23 +++-----------
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       | 42 +++++++++++++-------------
 net/ipv4/netfilter/nf_tables_arp.c             |  6 ++--
 net/ipv4/netfilter/nf_tables_ipv4.c            | 10 +++---
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        | 22 +++++++-------
 net/ipv4/netfilter/nft_chain_route_ipv4.c      |  6 ++--
 net/ipv4/netfilter/nft_dup_ipv4.c              |  2 +-
 net/ipv4/netfilter/nft_masq_ipv4.c             |  2 +-
 net/ipv4/netfilter/nft_redir_ipv4.c            |  2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c           |  5 ++-
 net/ipv6/netfilter/ip6_tables.c                |  3 +-
 net/ipv6/netfilter/ip6t_REJECT.c               |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  4 +--
 net/ipv6/netfilter/ip6t_rpfilter.c             |  6 ++--
 net/ipv6/netfilter/ip6table_filter.c           |  5 ++-
 net/ipv6/netfilter/ip6table_mangle.c           | 14 ++++-----
 net/ipv6/netfilter/ip6table_nat.c              | 21 ++++++-------
 net/ipv6/netfilter/ip6table_raw.c              |  5 ++-
 net/ipv6/netfilter/ip6table_security.c         |  5 ++-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 12 ++++----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  3 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  6 ++--
 net/ipv6/netfilter/nf_dup_ipv6.c               | 23 +++-----------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       | 42 +++++++++++++-------------
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c    |  2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c            | 10 +++---
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        | 22 +++++++-------
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |  6 ++--
 net/ipv6/netfilter/nft_dup_ipv6.c              |  2 +-
 net/ipv6/netfilter/nft_redir_ipv6.c            |  3 +-
 net/ipv6/netfilter/nft_reject_ipv6.c           |  7 ++---
 net/netfilter/core.c                           |  2 +-
 net/netfilter/ipset/ip_set_core.c              |  9 ++----
 net/netfilter/ipvs/ip_vs_core.c                | 40 ++++++++++++------------
 net/netfilter/nf_conntrack_core.c              | 10 +++---
 net/netfilter/nf_conntrack_proto_dccp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |  2 +-
 net/netfilter/nf_conntrack_proto_gre.c         |  3 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |  2 +-
 net/netfilter/nf_conntrack_proto_udp.c         |  1 +
 net/netfilter/nf_conntrack_proto_udplite.c     |  1 +
 net/netfilter/nf_nat_core.c                    |  4 +--
 net/netfilter/nf_tables_core.c                 | 10 +++---
 net/netfilter/nf_tables_netdev.c               | 20 ++++++------
 net/netfilter/nft_log.c                        |  3 +-
 net/netfilter/nft_meta.c                       |  4 +--
 net/netfilter/nft_queue.c                      |  2 +-
 net/netfilter/nft_reject_inet.c                | 19 ++++++------
 net/netfilter/xt_LOG.c                         |  2 +-
 net/netfilter/xt_NFLOG.c                       |  2 +-
 net/netfilter/xt_TCPMSS.c                      |  2 +-
 net/netfilter/xt_TEE.c                         |  4 +--
 net/netfilter/xt_TPROXY.c                      | 24 +++++++--------
 net/netfilter/xt_addrtype.c                    |  4 +--
 net/netfilter/xt_connlimit.c                   |  4 +--
 net/netfilter/xt_osf.c                         |  2 +-
 net/netfilter/xt_recent.c                      |  2 +-
 net/netfilter/xt_socket.c                      | 14 +++++----
 net/openvswitch/conntrack.c                    |  2 +-
 net/sched/act_connmark.c                       |  2 +-
 net/sched/act_ipt.c                            |  1 +
 net/sched/em_ipset.c                           |  1 +
 security/selinux/hooks.c                       | 10 +++---
 security/smack/smack_netfilter.c               |  4 +--
 107 files changed, 386 insertions(+), 434 deletions(-)
