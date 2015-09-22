From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/30] Netfilter/IPVS updates for net-next
Date: Tue, 22 Sep 2015 11:13:50 +0200
Message-ID: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS updates for your net-next tree
in this 4.4 development cycle, they are:

1) Schedule ICMP traffic to IPVS instances, this introduces a new schedule_icmp
   proc knob to enable/disable it. By default is off to retain the old
   behaviour. Patchset from Alex Gartrell.

I'm also including what Alex originally said for the record:

"The configuration of ipvs at Facebook is relatively straightforward.  All
ipvs instances bgp advertise a set of VIPs and the network prefers the
nearest one or uses ECMP in the event of a tie.  For the uninitiated, ECMP
deterministically and statelessly load balances by hashing the packet
(usually a 5-tuple of protocol, saddr, daddr, sport, and dport) and using
that number as an index (basic hash table type logic).

The problem is that ICMP packets (which contain really important
information like whether or not an MTU has been exceeded) will get a
different hash value and may end up at a different ipvs instance.  With no
information about where to route these packets, they are dropped, creating
ICMP black holes and breaking Path MTU discovery.  Suddenly, my mom's
pictures can't load and I'm fielding midday calls that I want nothing to do
with.

To address this, this patch set introduces the ability to schedule icmp
packets which is gated by a sysctl net.ipv4.vs.schedule_icmp.  If set to 0,
the old behavior is maintained -- otherwise ICMP packets are scheduled."

2) Add another proc entry to ignore tunneled packets to avoid routing loops
   from IPVS, also from Alex.

3) Fifteen patches from Eric Biederman to:

* Stop passing nf_hook_ops as parameter to the hook and use the state hook
  object instead all around the netfilter code, so only the private data
  pointer is passed to the registered hook function.

* Now that we've got state->net, propagate the netns pointer to netfilter hook
  clients to avoid its computation over and over again. A good example of how
  this has been simplified is the former TEE target (now nf_dup infrastructure)
  since it has killed the ugly pick_net() function.

There's another round of netns updates from Eric Biederman making the line. To
avoid the patchbomb again to almost all the networking mailing list (that is 84
patches) I'd suggest we send you a pull request with no patches or let me know
if you prefer a better way.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 47bbbb30b4331ec58a74a66a044341f0114b02b3:

  sch_dsmark: improve memory locality (2015-09-17 22:37:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 0a031ac5c00d091ce1f7007f22d5881620bf0a7e:

  netfilter: Use nf_ct_net instead of dev_net(out) in nf_nat_masquerade_ipv6 (2015-09-18 22:00:28 +0200)

----------------------------------------------------------------
Alex Gartrell (15):
      ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
      ipvs: Add hdr_flags to iphdr
      ipvs: Handle inverse and icmp headers in ip_vs_leave
      ipvs: pull out ip_vs_try_to_schedule function
      ipvs: drop inverse argument to conn_{in,out}_get
      ipvs: Make ip_vs_schedule aware of inverse iph'es
      ipvs: add schedule_icmp sysctl
      ipvs: Use outer header in ip_vs_bypass_xmit_v6
      ipvs: sh: support scheduling icmp/inverse packets consistently
      ipvs: attempt to schedule icmp packets
      ipvs: ensure that ICMP cannot be sent in reply to ICMP
      ipvs: support scheduling inverse and icmp TCP packets
      ipvs: support scheduling inverse and icmp UDP packets
      ipvs: support scheduling inverse and icmp SCTP packets
      ipvs: add sysctl to ignore tunneled packets

Eric W. Biederman (15):
      netfilter: ebtables: Simplify the arguments to ebt_do_table
      inet netfilter: Remove hook from ip6t_do_table, arp_do_table, ipt_do_table
      inet netfilter: Prefer state->hook to ops->hooknum
      netfilter: nf_tables: kill nft_pktinfo.ops
      netfilter: x_tables: Pass struct net in xt_action_param
      netfilter: x_tables: Use par->net instead of computing from the passed net devices
      netfilter: nf_tables: Pass struct net in nft_pktinfo
      netfilter: nf_tables: Use pkt->net instead of computing net from the passed net_devices
      netfilter: Pass net to nf_dup_ipv4 and nf_dup_ipv6
      act_connmark: Remember the struct net instead of guessing it.
      netfilter: nf_conntrack: Add a struct net parameter to l4_pkt_to_tuple
      ipvs: Read hooknum from state rather than ops->hooknum
      netfilter: Pass priv instead of nf_hook_ops to netfilter hooks
      netfilter: Pass net into nf_xfrm_me_harder
      netfilter: Use nf_ct_net instead of dev_net(out) in nf_nat_masquerade_ipv6

Pablo Neira Ayuso (1):
      Merge tag 'ipvs-for-v4.4' of https://git.kernel.org/.../horms/ipvs-next

 Documentation/networking/ipvs-sysctl.txt       |   10 +
 include/linux/netfilter.h                      |    2 +-
 include/linux/netfilter/x_tables.h             |    3 +-
 include/linux/netfilter_arp/arp_tables.h       |    1 -
 include/linux/netfilter_bridge/ebtables.h      |    6 +-
 include/linux/netfilter_ipv4/ip_tables.h       |    1 -
 include/linux/netfilter_ipv6/ip6_tables.h      |    1 -
 include/net/ip_vs.h                            |  120 +++++++--
 include/net/netfilter/br_netfilter.h           |    2 +-
 include/net/netfilter/ipv4/nf_dup_ipv4.h       |    2 +-
 include/net/netfilter/ipv6/nf_dup_ipv6.h       |    2 +-
 include/net/netfilter/nf_conntrack.h           |    3 +-
 include/net/netfilter/nf_conntrack_core.h      |    1 +
 include/net/netfilter/nf_conntrack_l4proto.h   |    2 +-
 include/net/netfilter/nf_nat_core.h            |    2 +-
 include/net/netfilter/nf_nat_l3proto.h         |   32 +--
 include/net/netfilter/nf_tables.h              |   14 +-
 include/net/netfilter/nf_tables_ipv4.h         |    3 +-
 include/net/netfilter/nf_tables_ipv6.h         |    3 +-
 include/net/tc_act/tc_connmark.h               |    1 +
 net/bridge/br_netfilter_hooks.c                |   14 +-
 net/bridge/br_netfilter_ipv6.c                 |    2 +-
 net/bridge/netfilter/ebt_log.c                 |    2 +-
 net/bridge/netfilter/ebt_nflog.c               |    2 +-
 net/bridge/netfilter/ebtable_broute.c          |    8 +-
 net/bridge/netfilter/ebtable_filter.c          |   10 +-
 net/bridge/netfilter/ebtable_nat.c             |   10 +-
 net/bridge/netfilter/ebtables.c                |   14 +-
 net/bridge/netfilter/nf_tables_bridge.c        |   20 +-
 net/bridge/netfilter/nft_reject_bridge.c       |   19 +-
 net/decnet/netfilter/dn_rtmsg.c                |    2 +-
 net/ipv4/netfilter/arp_tables.c                |    3 +-
 net/ipv4/netfilter/arptable_filter.c           |    5 +-
 net/ipv4/netfilter/ip_tables.c                 |    3 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |    4 +-
 net/ipv4/netfilter/ipt_rpfilter.c              |    5 +-
 net/ipv4/netfilter/iptable_filter.c            |    7 +-
 net/ipv4/netfilter/iptable_mangle.c            |   14 +-
 net/ipv4/netfilter/iptable_nat.c               |   21 +-
 net/ipv4/netfilter/iptable_raw.c               |    7 +-
 net/ipv4/netfilter/iptable_security.c          |    7 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   12 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    4 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |    4 +-
 net/ipv4/netfilter/nf_dup_ipv4.c               |   23 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |   42 +--
 net/ipv4/netfilter/nf_tables_arp.c             |    6 +-
 net/ipv4/netfilter/nf_tables_ipv4.c            |   10 +-
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        |   22 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c      |    6 +-
 net/ipv4/netfilter/nft_dup_ipv4.c              |    2 +-
 net/ipv4/netfilter/nft_masq_ipv4.c             |    2 +-
 net/ipv4/netfilter/nft_redir_ipv4.c            |    2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c           |    5 +-
 net/ipv6/netfilter/ip6_tables.c                |    3 +-
 net/ipv6/netfilter/ip6t_REJECT.c               |    2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |    4 +-
 net/ipv6/netfilter/ip6t_rpfilter.c             |    6 +-
 net/ipv6/netfilter/ip6table_filter.c           |    5 +-
 net/ipv6/netfilter/ip6table_mangle.c           |   14 +-
 net/ipv6/netfilter/ip6table_nat.c              |   21 +-
 net/ipv6/netfilter/ip6table_raw.c              |    5 +-
 net/ipv6/netfilter/ip6table_security.c         |    5 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   12 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    3 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |    6 +-
 net/ipv6/netfilter/nf_dup_ipv6.c               |   23 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |   42 +--
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c    |    2 +-
 net/ipv6/netfilter/nf_tables_ipv6.c            |   10 +-
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        |   22 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |    6 +-
 net/ipv6/netfilter/nft_dup_ipv6.c              |    2 +-
 net/ipv6/netfilter/nft_redir_ipv6.c            |    3 +-
 net/ipv6/netfilter/nft_reject_ipv6.c           |    7 +-
 net/netfilter/core.c                           |    2 +-
 net/netfilter/ipset/ip_set_core.c              |    9 +-
 net/netfilter/ipvs/ip_vs_conn.c                |   12 +-
 net/netfilter/ipvs/ip_vs_core.c                |  339 ++++++++++++++----------
 net/netfilter/ipvs/ip_vs_ctl.c                 |   15 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c              |    2 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c        |   17 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c          |   34 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c           |   38 ++-
 net/netfilter/ipvs/ip_vs_proto_udp.c           |   25 +-
 net/netfilter/ipvs/ip_vs_sh.c                  |   45 ++--
 net/netfilter/ipvs/ip_vs_xmit.c                |   24 +-
 net/netfilter/nf_conntrack_core.c              |   10 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |    2 +-
 net/netfilter/nf_conntrack_proto_gre.c         |    3 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    2 +-
 net/netfilter/nf_conntrack_proto_udp.c         |    1 +
 net/netfilter/nf_conntrack_proto_udplite.c     |    1 +
 net/netfilter/nf_nat_core.c                    |    4 +-
 net/netfilter/nf_tables_core.c                 |   10 +-
 net/netfilter/nf_tables_netdev.c               |   20 +-
 net/netfilter/nft_log.c                        |    3 +-
 net/netfilter/nft_meta.c                       |    4 +-
 net/netfilter/nft_queue.c                      |    2 +-
 net/netfilter/nft_reject_inet.c                |   19 +-
 net/netfilter/xt_LOG.c                         |    2 +-
 net/netfilter/xt_NFLOG.c                       |    2 +-
 net/netfilter/xt_TCPMSS.c                      |    2 +-
 net/netfilter/xt_TEE.c                         |    4 +-
 net/netfilter/xt_TPROXY.c                      |   24 +-
 net/netfilter/xt_addrtype.c                    |    4 +-
 net/netfilter/xt_connlimit.c                   |    4 +-
 net/netfilter/xt_ipvs.c                        |    4 +-
 net/netfilter/xt_osf.c                         |    2 +-
 net/netfilter/xt_recent.c                      |    2 +-
 net/netfilter/xt_socket.c                      |   14 +-
 net/openvswitch/conntrack.c                    |    2 +-
 net/sched/act_connmark.c                       |    5 +-
 net/sched/act_ipt.c                            |    1 +
 net/sched/em_ipset.c                           |    1 +
 security/selinux/hooks.c                       |   10 +-
 security/smack/smack_netfilter.c               |    4 +-
 120 files changed, 816 insertions(+), 653 deletions(-)
