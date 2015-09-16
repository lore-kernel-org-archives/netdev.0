From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next 0/30] Passing net through the netfilter hooks
Date: Tue, 15 Sep 2015 19:59:49 -0500
Message-ID: <87mvwn18my.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My primary goal with this patchset and it's follow ups is to cleanup the
network routing paths so that we do not look at the output device to
derive the network namespace.  My plan is to pass the network namespace
of the transmitting socket through the output path, to replace code that
looks at the output network device today.  Once that is done we can have
routes with output devices outside of the current network namespace.
Which should allow reception and transmission of packets in network
namespaces to be as fast as normal packet reception and transmission
with early demux disabled, because it will same code path.

Once skb_dst(skb)->dev is a little better under control I think it will
also be possible to use rcu to cleanup the ancient hack that sets
dst->dev to loopback_dev when a network device is removed.

The work to get there is a series of code cleanups.  I am starting with
passing net into the netfilter hooks and into the functions that are
called after the netfilter hooks.  This removes from netfilter the
need to guess which network namespace it is working on.

To get there I perform a series of minor prep patches so the big changes
at the end are possible to audit without getting lost in the noise.  In
particular I have a lot of patches computing net into a local variable
and then using it through out the function.

So this patchset encompases removing dead code, sorting out the _sk
functions that were added last time someone pushed a prototype change
through the post netfilter functions.  Cleaning up individual functions
use of the network namespace.  Passing net into the netfilter hooks.
Passing net into the post netfilter functions.  Using state->net in
the netfilter code where it is available and trivially usable.

Pablo, Dave I don't know whose tree this makes more sense to go
through.  I am assuming at least initially Pablos as netfilter is
involved.  From what I have seen there will be a lot of back and forth
between the netfilter code paths and the routing code paths.

The patches are also available (against 4.3-rc1) at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

Eric W. Biederman (30):
      netfilter: Remove !CONFIG_NETFITLER definition of nf_hook_thresh
      netfilter: Store net in nf_hook_state
      netfilter: Pass net to nf_hook_thresh
      xfrm: Remove unused afinfo method init_dst
      net: Merge dst_output and dst_output_sk
      ipv4: Compute net once in ip_forward
      ipv4: Compute net once in ip_forward_finish
      ipv4: Compute net once in ip_rcv
      ipv4: Remember the net in ip_output and ip_mc_output
      ipv4: Don't recompute net in ipmr_queue_xmit
      ipv4: Only compute net once in ip_do_fragment
      ipv4: Explicitly compute net in ip_fragment
      ipv4: Only compute net once in ip_finish_output2
      ipv4: Only compute net once in ip_rcv_finish
      ipv4: Only compute net once in ipmr_forward_finish
      ipv6: Only compute net once in ip6mr_forward2_finish
      arp: Introduce arp_xmit_finish
      bridge: Introduce br_send_bpdu_finish
      net: Remove dev_queue_xmit_sk
      ipv6: Don't recompute net in ip6_rcv
      ipv6: Only compute net once in ip6_finish_output2
      ipv6: Cache net in ip6_output
      ipv6: Compute net once in raw6_send_hdrinc
      bridge: Pass net into br_nf_ip_fragment
      bridge: Pass net into br_nf_push_frag_xmit
      bridge: Cache net in br_nf_pre_routing_finish
      bridge: Add br_netif_receive_skb remove netif_receive_skb_sk
      netfilter: Pass struct net into the netfilter hooks
      netfilter: Use nf_hook_state.net
      netfilter: Pass net into okfn

 drivers/net/vrf.c                              |  9 ++--
 include/linux/netdevice.h                      | 14 ++----
 include/linux/netfilter.h                      | 68 ++++++++++++--------------
 include/linux/netfilter_bridge.h               |  2 +-
 include/linux/netfilter_ingress.h              |  2 +-
 include/net/dn_neigh.h                         |  6 +--
 include/net/dst.h                              |  6 +--
 include/net/ipv6.h                             |  2 +-
 include/net/netfilter/br_netfilter.h           |  2 +-
 include/net/xfrm.h                             |  2 -
 net/bridge/br_forward.c                        | 16 +++---
 net/bridge/br_input.c                          | 25 ++++++----
 net/bridge/br_multicast.c                      |  4 +-
 net/bridge/br_netfilter_hooks.c                | 54 ++++++++++----------
 net/bridge/br_netfilter_ipv6.c                 |  8 +--
 net/bridge/br_private.h                        |  6 +--
 net/bridge/br_stp_bpdu.c                       | 12 +++--
 net/bridge/netfilter/ebtable_filter.c          |  4 +-
 net/bridge/netfilter/ebtable_nat.c             |  4 +-
 net/core/dev.c                                 | 12 +++--
 net/decnet/dn_neigh.c                          | 23 +++++----
 net/decnet/dn_nsp_in.c                         |  7 +--
 net/decnet/dn_nsp_out.c                        |  4 +-
 net/decnet/dn_route.c                          | 30 ++++++------
 net/ipv4/arp.c                                 | 20 +++++---
 net/ipv4/ip_forward.c                          | 19 ++++---
 net/ipv4/ip_input.c                            | 39 +++++++--------
 net/ipv4/ip_output.c                           | 58 ++++++++++++----------
 net/ipv4/ip_vti.c                              |  2 +-
 net/ipv4/ipmr.c                                | 15 +++---
 net/ipv4/netfilter/arptable_filter.c           |  4 +-
 net/ipv4/netfilter/ip_tables.c                 |  8 +--
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  2 +-
 net/ipv4/netfilter/iptable_filter.c            |  6 +--
 net/ipv4/netfilter/iptable_mangle.c            |  7 ++-
 net/ipv4/netfilter/iptable_nat.c               |  5 +-
 net/ipv4/netfilter/iptable_raw.c               |  6 +--
 net/ipv4/netfilter/iptable_security.c          |  5 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  4 +-
 net/ipv4/raw.c                                 |  5 +-
 net/ipv4/xfrm4_input.c                         |  7 +--
 net/ipv4/xfrm4_output.c                        | 10 ++--
 net/ipv6/ip6_input.c                           | 15 +++---
 net/ipv6/ip6_output.c                          | 37 +++++++-------
 net/ipv6/ip6_vti.c                             |  2 +-
 net/ipv6/ip6mr.c                               | 12 ++---
 net/ipv6/mcast.c                               |  9 ++--
 net/ipv6/ndisc.c                               |  6 +--
 net/ipv6/netfilter/ip6_tables.c                |  8 +--
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  2 +-
 net/ipv6/netfilter/ip6table_filter.c           |  5 +-
 net/ipv6/netfilter/ip6table_mangle.c           |  6 +--
 net/ipv6/netfilter/ip6table_nat.c              |  5 +-
 net/ipv6/netfilter/ip6table_raw.c              |  5 +-
 net/ipv6/netfilter/ip6table_security.c         |  4 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  4 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  2 +-
 net/ipv6/output_core.c                         |  8 +--
 net/ipv6/raw.c                                 |  9 ++--
 net/ipv6/xfrm6_input.c                         |  4 +-
 net/ipv6/xfrm6_output.c                        | 10 ++--
 net/netfilter/ipvs/ip_vs_xmit.c                |  8 +--
 net/netfilter/nf_queue.c                       |  2 +-
 net/netfilter/nfnetlink_queue_core.c           |  3 +-
 net/xfrm/xfrm_output.c                         | 17 ++++---
 net/xfrm/xfrm_policy.c                         |  4 +-
 67 files changed, 375 insertions(+), 358 deletions(-)
