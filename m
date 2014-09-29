From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/34] pull request: netfilter/ipvs updates for net-next
Date: Mon, 29 Sep 2014 14:38:49 +0200
Message-ID: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33981 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbaI2MiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS updates for net-next,
most relevantly they are:

1) Four patches to make the new nf_tables masquerading support
   independent of the x_tables infrastructure. This also resolves a
   compilation breakage if the masquerade target is disabled but the
   nf_tables masq expression is enabled.

2) ipset updates via Jozsef Kadlecsik. This includes the addition of the
   skbinfo extension that allows you to store packet metainformation in the
   elements. This can be used to fetch and restore this to the packets through
   the iptables SET target, patches from Anton Danilov.

3) Add the hash:mac set type to ipset, from Jozsef Kadlecsick.

4) Add simple weighted fail-over scheduler via Simon Horman. This provides
   a fail-over IPVS scheduler (unlike existing load balancing schedulers).
   Connections are directed to the appropriate server based solely on
   highest weight value and server availability, patch from Kenny Mathis.

5) Support IPv6 real servers in IPv4 virtual-services and vice versa.
   Simon Horman informs that the motivation for this is to allow more
   flexibility in the choice of IP version offered by both virtual-servers
   and real-servers as they no longer need to match: An IPv4 connection
   from an end-user may be forwarded to a real-server using IPv6 and
   vice versa. No ip_vs_sync support yet though. Patches from Alex Gartrell
   and Julian Anastasov.

6) Add global generation ID to the nf_tables ruleset. When dumping from
   several different object lists, we need a way to identify that an update
   has ocurred so userspace knows that it needs to refresh its lists. This
   also includes a new command to obtain the 32-bits generation ID. The
   less significant 16-bits of this ID is also exposed through res_id field
   in the nfnetlink header to quickly detect the interference and retry when
   there is no risk of ID wraparound.

7) Move br_netfilter out of the bridge core. The br_netfilter code is
   built in the bridge core by default. This causes problems of different
   kind to people that don't want this: Jesper reported performance drop due
   to the inconditional hook registration and I remember to have read complains
   on netdev from people regarding the unexpected behaviour of our bridging
   stack when br_netfilter is enabled (fragmentation handling, layer 3 and
   upper inspection). People that still need this should easily undo the
   damage by modprobing the new br_netfilter module.

8) Dump the set policy nf_tables that allows set parameterization. So
   userspace can keep user-defined preferences when saving the ruleset.
   From Arturo Borrero.

9) Use __seq_open_private() helper function to reduce boiler plate code
   in x_tables, From Rob Jones.

10) Safer default behaviour in case that you forget to load the protocol
   tracker. Daniel Borkmann and Florian Westphal detected that if your
   ruleset is stateful, you allow traffic to at least one single SCTP port
   and the SCTP protocol tracker is not loaded, then any SCTP traffic may
   be pass through unfiltered. After this patch, the connection tracking
   classifies SCTP/DCCP/UDPlite/GRE packets as invalid if your kernel has
   been compiled with support for these modules.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit b954d83421d51d822c42e5ab7b65069b25ad3005:

  net: bpf: only build bpf_jit_binary_{alloc, free}() when jit selected (2014-09-10 14:05:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to db29a9508a9246e77087c5531e45b2c88ec6988b:

  netfilter: conntrack: disable generic tracking for known protocols (2014-09-29 12:17:49 +0200)

----------------------------------------------------------------
Alex Gartrell (10):
      ipvs: Add destination address family to netlink interface
      ipvs: Supply destination addr family to ip_vs_{lookup_dest,find_dest}
      ipvs: Pass destination address family to ip_vs_trash_get_dest
      ipvs: Supply destination address family to ip_vs_conn_new
      ipvs: prevent mixing heterogeneous pools and synchronization
      ipvs: Pull out crosses_local_route_boundary logic
      ipvs: Pull out update_pmtu code
      ipvs: Add generic ensure_mtu_is_adequate to handle mixed pools
      ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
      ipvs: Allow heterogeneous pools now that we support them

Anton Danilov (5):
      netfilter: ipset: Add skbinfo extension kernel support in the ipset core.
      netfilter: ipset: Add skbinfo extension kernel support for the bitmap set types.
      netfilter: ipset: Add skbinfo extension kernel support for the hash set types.
      netfilter: ipset: Add skbinfo extension kernel support for the list set type.
      netfilter: ipset: Add skbinfo extension support to SET target.

Arturo Borrero (1):
      netfilter: nf_tables: store and dump set policy

Florian Westphal (1):
      netfilter: conntrack: disable generic tracking for known protocols

Jozsef Kadlecsik (3):
      netfilter: ipset: Fix static checker warning in ip_set_core.c
      netfilter: ipset: send nonzero skbinfo extensions only
      netfilter: ipset: hash:mac type added to ipset

Julian Anastasov (4):
      ipvs: address family of LBLC entry depends on svc family
      ipvs: address family of LBLCR entry depends on svc family
      ipvs: use correct address family in scheduler logs
      ipvs: use the new dest addr family field

Kenny Mathis (1):
      ipvs: Add simple weighted failover scheduler

Pablo Neira Ayuso (9):
      netfilter: fix compilation of masquerading without IP_NF_TARGET_MASQUERADE
      netfilter: nf_tables: add NFTA_MASQ_UNSPEC to nft_masq_attributes
      netfilter: NFT_CHAIN_NAT_IPV* is independent of NFT_NAT
      netfilter: masquerading needs to be independent of x_tables in Kconfig
      Merge branch 'ipvs-next'
      netfilter: nfnetlink: use original skbuff when committing/aborting
      netfilter: nf_tables: export rule-set generation ID
      netfilter: bridge: nf_bridge_copy_header as static inline in header
      netfilter: bridge: move br_netfilter out of the core

Rob Jones (1):
      net/netfilter/x_tables.c: use __seq_open_private()

 include/linux/netfilter/ipset/ip_set.h       |   60 +++-
 include/linux/netfilter_bridge.h             |   50 +++-
 include/linux/skbuff.h                       |   12 +-
 include/net/ip_vs.h                          |   15 +-
 include/net/neighbour.h                      |    2 +-
 include/net/netfilter/ipv4/nf_reject.h       |    2 +-
 include/net/netfilter/ipv6/nf_reject.h       |    2 +-
 include/net/netfilter/nf_nat.h               |   10 +-
 include/net/netfilter/nf_tables.h            |    2 +
 include/uapi/linux/ip_vs.h                   |    3 +
 include/uapi/linux/netfilter/ipset/ip_set.h  |   12 +
 include/uapi/linux/netfilter/nf_tables.h     |   17 ++
 include/uapi/linux/netfilter/xt_set.h        |   10 +
 net/Kconfig                                  |    7 +-
 net/bridge/Makefile                          |    5 +-
 net/bridge/br.c                              |   14 +-
 net/bridge/br_device.c                       |    4 +-
 net/bridge/br_forward.c                      |    2 +
 net/bridge/br_input.c                        |    1 +
 net/bridge/br_netfilter.c                    |  116 ++------
 net/bridge/br_netlink.c                      |    2 +-
 net/bridge/br_nf_core.c                      |   96 +++++++
 net/bridge/br_private.h                      |   12 +-
 net/bridge/br_sysfs_br.c                     |    4 +-
 net/ipv4/netfilter/Kconfig                   |   46 +--
 net/ipv6/netfilter/Kconfig                   |   50 ++--
 net/netfilter/ipset/Kconfig                  |    9 +
 net/netfilter/ipset/Makefile                 |    1 +
 net/netfilter/ipset/ip_set_bitmap_gen.h      |    4 +
 net/netfilter/ipset/ip_set_bitmap_ip.c       |   11 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |   11 +-
 net/netfilter/ipset/ip_set_bitmap_port.c     |   11 +-
 net/netfilter/ipset/ip_set_core.c            |   30 +-
 net/netfilter/ipset/ip_set_hash_gen.h        |   16 +-
 net/netfilter/ipset/ip_set_hash_ip.c         |   14 +-
 net/netfilter/ipset/ip_set_hash_ipmark.c     |   14 +-
 net/netfilter/ipset/ip_set_hash_ipport.c     |   14 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   14 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   14 +-
 net/netfilter/ipset/ip_set_hash_mac.c        |  173 ++++++++++++
 net/netfilter/ipset/ip_set_hash_net.c        |   16 +-
 net/netfilter/ipset/ip_set_hash_netiface.c   |   16 +-
 net/netfilter/ipset/ip_set_hash_netnet.c     |   16 +-
 net/netfilter/ipset/ip_set_hash_netport.c    |   16 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c |   16 +-
 net/netfilter/ipset/ip_set_list_set.c        |   19 +-
 net/netfilter/ipvs/Kconfig                   |   10 +
 net/netfilter/ipvs/Makefile                  |    1 +
 net/netfilter/ipvs/ip_vs_conn.c              |   74 +++--
 net/netfilter/ipvs/ip_vs_core.c              |   15 +-
 net/netfilter/ipvs/ip_vs_ctl.c               |  112 ++++++--
 net/netfilter/ipvs/ip_vs_dh.c                |    2 +-
 net/netfilter/ipvs/ip_vs_fo.c                |   79 ++++++
 net/netfilter/ipvs/ip_vs_ftp.c               |    6 +-
 net/netfilter/ipvs/ip_vs_lblc.c              |   12 +-
 net/netfilter/ipvs/ip_vs_lblcr.c             |   12 +-
 net/netfilter/ipvs/ip_vs_lc.c                |    2 +-
 net/netfilter/ipvs/ip_vs_nq.c                |    3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c        |    2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c         |    2 +-
 net/netfilter/ipvs/ip_vs_rr.c                |    2 +-
 net/netfilter/ipvs/ip_vs_sed.c               |    3 +-
 net/netfilter/ipvs/ip_vs_sh.c                |    8 +-
 net/netfilter/ipvs/ip_vs_sync.c              |   13 +-
 net/netfilter/ipvs/ip_vs_wlc.c               |    3 +-
 net/netfilter/ipvs/ip_vs_wrr.c               |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c              |  388 ++++++++++++++++----------
 net/netfilter/nf_conntrack_proto_generic.c   |   26 +-
 net/netfilter/nf_tables_api.c                |  146 ++++++++--
 net/netfilter/nfnetlink.c                    |    6 +-
 net/netfilter/x_tables.c                     |   30 +-
 net/netfilter/xt_set.c                       |  155 ++++++++++
 72 files changed, 1595 insertions(+), 510 deletions(-)
 create mode 100644 net/bridge/br_nf_core.c
 create mode 100644 net/netfilter/ipset/ip_set_hash_mac.c
 create mode 100644 net/netfilter/ipvs/ip_vs_fo.c
