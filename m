From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Sun, 14 Jun 2015 22:07:30 -0500
Message-ID: <87616ppt3h.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While looking into what it would take to route packets out to network
devices in other network namespaces I started looking at the netfilter
hooks, and there is a lot of nasty code to figure out which network
namespace to filter the packets in.

Just passing the network namespace into the netfilter hooks looks like a
significant simplication in the code, and worth it as the first thing
most netfilter hooks do is compute the network namespace.

We probably even want per network namespace netfilter hooks as nftables
tries (and fails to use).  nftables currently has a fairly serious bug
where the tables for one network namespace run for packets in all
network namespaces.  I do not have a fix yet but I think this patchset
making it easy to get at the network namespace is a good starting
place for a fix.

This patshset roots out all of the very weird network namespace
computation logic (except for the code in ipvs) and fixes it.  I really
don't like how the code has been essentially guessing  which network
namespace to use.

Probably the worst guessing is in ipvs in the function skb_net. I have
some preliminary changes to fix ipvs but they are not quite ready yet.
Cleaning up ipvs enough that I can kill skb_net is on my short list.

There are a few extra cleanups sprinkled in as I noticed a few other
things as I was sorting out the network namespace computation logic.

Eric W. Biederman (15):
      netfilter: Kill unused copies of RCV_SKB_FAIL
      netfilter: Pass struct net into the netfilter hooks
      netfilter: Use nf_hook_state.net
      ebtables: Simplify the arguments to ebt_do_table
      inet netfilter: Remove hook from ip6t_do_table, arp_do_table, ipt_do_table
      inet netfilter: Prefer state->hook to ops->hooknum
      nftables: kill nft_pktinfo.ops
      tc: Simplify em_ipset_match
      x_tables: Pass struct net in xt_action_param
      x_tables: Use par->net instead of computing from the passed net devices
      nftables: Pass struct net in nft_pktinfo
      nf_tables: Use pkt->net instead of computing net from the passed net_devices
      nf_conntrack: Add a struct net parameter to l4_pkt_to_tuple
      ipv4: Pass struct net into ip_defrag and ip_check_defrag
      ipv6: Pass struct net into nf_ct_frag6_gather

 drivers/net/macvlan.c                          |  2 +-
 include/linux/netfilter.h                      | 37 +++++++++++++++-----------
 include/linux/netfilter/x_tables.h             |  2 ++
 include/linux/netfilter_arp/arp_tables.h       |  1 -
 include/linux/netfilter_bridge/ebtables.h      |  6 ++---
 include/linux/netfilter_ingress.h              |  2 +-
 include/linux/netfilter_ipv4/ip_tables.h       |  1 -
 include/linux/netfilter_ipv6/ip6_tables.h      |  1 -
 include/net/ip.h                               |  6 ++---
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |  2 +-
 include/net/netfilter/nf_conntrack.h           |  3 ++-
 include/net/netfilter/nf_conntrack_core.h      |  1 +
 include/net/netfilter/nf_conntrack_l4proto.h   |  2 +-
 include/net/netfilter/nf_tables.h              | 11 ++++----
 include/net/netfilter/nf_tables_ipv4.h         |  3 +--
 include/net/netfilter/nf_tables_ipv6.h         |  3 +--
 net/bridge/br_forward.c                        | 12 ++++-----
 net/bridge/br_input.c                          | 13 ++++-----
 net/bridge/br_multicast.c                      |  4 +--
 net/bridge/br_netfilter.c                      | 37 ++++++++++++++------------
 net/bridge/br_stp_bpdu.c                       |  4 +--
 net/bridge/netfilter/ebt_log.c                 |  2 +-
 net/bridge/netfilter/ebt_nflog.c               |  2 +-
 net/bridge/netfilter/ebtable_broute.c          |  8 ++++--
 net/bridge/netfilter/ebtable_filter.c          |  6 ++---
 net/bridge/netfilter/ebtable_nat.c             |  6 ++---
 net/bridge/netfilter/ebtables.c                | 14 +++++-----
 net/bridge/netfilter/nf_tables_bridge.c        | 16 +++++------
 net/bridge/netfilter/nft_reject_bridge.c       | 19 +++++++------
 net/decnet/dn_neigh.c                          | 15 ++++++-----
 net/decnet/dn_nsp_in.c                         |  4 +--
 net/decnet/dn_route.c                          | 24 ++++++++---------
 net/ipv4/arp.c                                 | 10 ++++---
 net/ipv4/ip_forward.c                          | 11 +++++---
 net/ipv4/ip_fragment.c                         |  8 +++---
 net/ipv4/ip_input.c                            | 30 ++++++++++++---------
 net/ipv4/ip_output.c                           | 28 +++++++++++--------
 net/ipv4/ipmr.c                                |  6 ++---
 net/ipv4/netfilter/arp_tables.c                |  3 ++-
 net/ipv4/netfilter/arptable_filter.c           |  5 +---
 net/ipv4/netfilter/ip_tables.c                 | 11 ++++----
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  4 +--
 net/ipv4/netfilter/ipt_rpfilter.c              |  5 ++--
 net/ipv4/netfilter/iptable_filter.c            |  7 ++---
 net/ipv4/netfilter/iptable_mangle.c            | 15 +++++------
 net/ipv4/netfilter/iptable_nat.c               |  4 +--
 net/ipv4/netfilter/iptable_raw.c               |  7 ++---
 net/ipv4/netfilter/iptable_security.c          |  8 ++----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  4 +--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  4 +--
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  9 ++++---
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       | 14 +++++-----
 net/ipv4/netfilter/nf_tables_arp.c             |  2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c            |  2 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        |  2 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c      |  2 +-
 net/ipv4/netfilter/nft_masq_ipv4.c             |  2 +-
 net/ipv4/netfilter/nft_redir_ipv4.c            |  2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c           |  5 ++--
 net/ipv4/raw.c                                 |  5 ++--
 net/ipv4/xfrm4_input.c                         |  4 +--
 net/ipv4/xfrm4_output.c                        |  6 +++--
 net/ipv6/ip6_input.c                           | 10 +++----
 net/ipv6/ip6_output.c                          | 30 ++++++++++-----------
 net/ipv6/ip6mr.c                               |  4 +--
 net/ipv6/mcast.c                               |  7 ++---
 net/ipv6/ndisc.c                               |  4 +--
 net/ipv6/netfilter/ip6_tables.c                | 11 ++++----
 net/ipv6/netfilter/ip6t_REJECT.c               |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  4 +--
 net/ipv6/netfilter/ip6t_rpfilter.c             |  6 ++---
 net/ipv6/netfilter/ip6table_filter.c           |  4 +--
 net/ipv6/netfilter/ip6table_mangle.c           | 14 +++++-----
 net/ipv6/netfilter/ip6table_nat.c              |  4 +--
 net/ipv6/netfilter/ip6table_raw.c              |  4 +--
 net/ipv6/netfilter/ip6table_security.c         |  5 +---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  4 +--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  3 ++-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  4 +--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  5 ++--
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       | 14 +++++-----
 net/ipv6/netfilter/nf_tables_ipv6.c            |  2 +-
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        |  2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |  2 +-
 net/ipv6/netfilter/nft_redir_ipv6.c            |  3 +--
 net/ipv6/netfilter/nft_reject_ipv6.c           |  7 +++--
 net/ipv6/output_core.c                         |  6 +++--
 net/ipv6/raw.c                                 | 10 ++++---
 net/ipv6/xfrm6_input.c                         |  4 +--
 net/ipv6/xfrm6_output.c                        |  6 +++--
 net/netfilter/ipset/ip_set_core.c              |  9 +++----
 net/netfilter/ipvs/ip_vs_core.c                |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                |  4 +--
 net/netfilter/nf_conntrack_core.c              | 10 ++++---
 net/netfilter/nf_conntrack_proto_dccp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |  2 +-
 net/netfilter/nf_conntrack_proto_gre.c         |  3 +--
 net/netfilter/nf_conntrack_proto_sctp.c        |  2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |  2 +-
 net/netfilter/nf_conntrack_proto_udp.c         |  1 +
 net/netfilter/nf_conntrack_proto_udplite.c     |  1 +
 net/netfilter/nf_tables_core.c                 |  4 +--
 net/netfilter/nf_tables_netdev.c               | 16 +++++------
 net/netfilter/nfnetlink_log.c                  |  2 --
 net/netfilter/nfnetlink_queue_core.c           |  5 +---
 net/netfilter/nft_log.c                        |  3 +--
 net/netfilter/nft_meta.c                       |  4 +--
 net/netfilter/nft_queue.c                      |  2 +-
 net/netfilter/nft_reject_inet.c                | 19 +++++++------
 net/netfilter/xt_LOG.c                         |  2 +-
 net/netfilter/xt_NFLOG.c                       |  2 +-
 net/netfilter/xt_TCPMSS.c                      |  2 +-
 net/netfilter/xt_TEE.c                         | 24 +++--------------
 net/netfilter/xt_TPROXY.c                      | 24 ++++++++---------
 net/netfilter/xt_addrtype.c                    |  4 +--
 net/netfilter/xt_connlimit.c                   |  4 +--
 net/netfilter/xt_osf.c                         |  2 +-
 net/netfilter/xt_recent.c                      |  2 +-
 net/netfilter/xt_socket.c                      | 14 +++++-----
 net/packet/af_packet.c                         |  6 ++---
 net/sched/act_connmark.c                       |  2 +-
 net/sched/act_ipt.c                            |  1 +
 net/sched/em_ipset.c                           |  5 ++--
 net/xfrm/xfrm_output.c                         |  4 ++-
 125 files changed, 426 insertions(+), 442 deletions(-)

Eric
