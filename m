From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/62: netfilter update
Date: Tue, 16 Feb 2010 15:55:19 +0100 (MET)
Message-ID: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is a first netfilter update for 2.6.34. Highlights include:

- further work on completing network namespace support from Alexey

- cleanups and automatic table instantiation in xtables from Jan

- SIP over TCP and SIP T.38 FAX support from myself

- a new xtables target to supply parameters for conntrack initialization
  to the conntrack core from myself

- conntrack zones, allowing conntrack/NAT to handle multiple connections
  with the same identity, from myself

- dynamic IPVS hash sizing by Catalin M. Boie

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 include/linux/netfilter.h                      |   64 +++--
 include/linux/netfilter/Kbuild                 |    1 +
 include/linux/netfilter/nf_conntrack_common.h  |   22 ++
 include/linux/netfilter/nf_conntrack_sip.h     |   19 +-
 include/linux/netfilter/nfnetlink.h            |    8 +-
 include/linux/netfilter/nfnetlink_conntrack.h  |    2 +
 include/linux/netfilter/x_tables.h             |   53 +++--
 include/linux/netfilter/xt_CT.h                |   17 ++
 include/linux/netfilter_arp/arp_tables.h       |    1 +
 include/linux/netfilter_bridge/ebtables.h      |    2 +-
 include/linux/netfilter_ipv4/ip_tables.h       |    3 +-
 include/linux/netfilter_ipv6/ip6_tables.h      |    3 +-
 include/net/ip.h                               |    3 +
 include/net/ip_vs.h                            |   16 +-
 include/net/ipv6.h                             |    5 +
 include/net/net_namespace.h                    |    2 +
 include/net/netfilter/nf_conntrack.h           |   12 +-
 include/net/netfilter/nf_conntrack_core.h      |    3 +-
 include/net/netfilter/nf_conntrack_ecache.h    |   58 ++---
 include/net/netfilter/nf_conntrack_expect.h    |   16 +-
 include/net/netfilter/nf_conntrack_extend.h    |    2 +
 include/net/netfilter/nf_conntrack_helper.h    |    8 +-
 include/net/netfilter/nf_conntrack_l4proto.h   |    4 +-
 include/net/netfilter/nf_conntrack_zones.h     |   23 ++
 include/net/netfilter/nf_nat_helper.h          |   32 ++-
 include/net/netns/ipv4.h                       |    2 +
 include/net/netns/ipv6.h                       |    2 +
 net/bridge/netfilter/ebt_802_3.c               |    2 +-
 net/bridge/netfilter/ebt_arp.c                 |    2 +-
 net/bridge/netfilter/ebt_arpreply.c            |    2 +-
 net/bridge/netfilter/ebt_dnat.c                |    2 +-
 net/bridge/netfilter/ebt_ip.c                  |    2 +-
 net/bridge/netfilter/ebt_ip6.c                 |    2 +-
 net/bridge/netfilter/ebt_limit.c               |    2 +-
 net/bridge/netfilter/ebt_log.c                 |    2 +-
 net/bridge/netfilter/ebt_mark.c                |    2 +-
 net/bridge/netfilter/ebt_mark_m.c              |    2 +-
 net/bridge/netfilter/ebt_nflog.c               |    2 +-
 net/bridge/netfilter/ebt_pkttype.c             |    2 +-
 net/bridge/netfilter/ebt_redirect.c            |    2 +-
 net/bridge/netfilter/ebt_snat.c                |    2 +-
 net/bridge/netfilter/ebt_stp.c                 |    2 +-
 net/bridge/netfilter/ebt_ulog.c                |    2 +-
 net/bridge/netfilter/ebt_vlan.c                |    2 +-
 net/bridge/netfilter/ebtable_broute.c          |    2 +-
 net/bridge/netfilter/ebtable_filter.c          |    2 +-
 net/bridge/netfilter/ebtable_nat.c             |    2 +-
 net/bridge/netfilter/ebtables.c                |   94 ++++---
 net/ipv4/netfilter/arp_tables.c                |   80 ++++---
 net/ipv4/netfilter/arptable_filter.c           |   95 ++------
 net/ipv4/netfilter/ip_tables.c                 |  156 +++++++-----
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   14 +-
 net/ipv4/netfilter/ipt_ULOG.c                  |    4 +-
 net/ipv4/netfilter/iptable_filter.c            |  124 +++-------
 net/ipv4/netfilter/iptable_mangle.c            |  166 +++----------
 net/ipv4/netfilter/iptable_raw.c               |   96 ++-----
 net/ipv4/netfilter/iptable_security.c          |  117 ++-------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    3 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   11 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |   15 +-
 net/ipv4/netfilter/nf_nat_core.c               |   24 +-
 net/ipv4/netfilter/nf_nat_ftp.c                |  105 +++-----
 net/ipv4/netfilter/nf_nat_helper.c             |   39 ++--
 net/ipv4/netfilter/nf_nat_pptp.c               |    3 +-
 net/ipv4/netfilter/nf_nat_rule.c               |   41 +---
 net/ipv4/netfilter/nf_nat_sip.c                |  154 +++++++----
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |   31 +--
 net/ipv6/netfilter/ip6_tables.c                |  158 +++++++-----
 net/ipv6/netfilter/ip6table_filter.c           |  113 ++-------
 net/ipv6/netfilter/ip6table_mangle.c           |  141 +++--------
 net/ipv6/netfilter/ip6table_raw.c              |   86 ++-----
 net/ipv6/netfilter/ip6table_security.c         |  109 ++-------
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   14 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   11 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    7 +-
 net/ipv6/reassembly.c                          |    4 +-
 net/netfilter/Kconfig                          |   25 ++
 net/netfilter/Makefile                         |    1 +
 net/netfilter/ipvs/Kconfig                     |    4 +
 net/netfilter/ipvs/ip_vs_conn.c                |   42 +++-
 net/netfilter/ipvs/ip_vs_ctl.c                 |    8 +-
 net/netfilter/ipvs/ip_vs_ftp.c                 |    2 +-
 net/netfilter/nf_conntrack_core.c              |  164 +++++++++----
 net/netfilter/nf_conntrack_expect.c            |   31 ++-
 net/netfilter/nf_conntrack_extend.c            |    1 -
 net/netfilter/nf_conntrack_h323_main.c         |    3 +-
 net/netfilter/nf_conntrack_helper.c            |   44 +++-
 net/netfilter/nf_conntrack_netlink.c           |  210 +++++++++++----
 net/netfilter/nf_conntrack_pptp.c              |   14 +-
 net/netfilter/nf_conntrack_proto_dccp.c        |    5 +-
 net/netfilter/nf_conntrack_proto_gre.c         |    2 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    4 +-
 net/netfilter/nf_conntrack_proto_udp.c         |    6 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |    4 +-
 net/netfilter/nf_conntrack_sip.c               |  330 ++++++++++++++++++-----
 net/netfilter/nf_conntrack_standalone.c        |    6 +
 net/netfilter/nfnetlink.c                      |   65 +++--
 net/netfilter/nfnetlink_log.c                  |    3 +-
 net/netfilter/nfnetlink_queue.c                |    7 +-
 net/netfilter/x_tables.c                       |   80 +++++-
 net/netfilter/xt_CT.c                          |  164 ++++++++++++
 net/netfilter/xt_NFQUEUE.c                     |    6 +-
 net/netfilter/xt_RATEEST.c                     |    7 +-
 net/netfilter/xt_TCPMSS.c                      |   18 +-
 net/netfilter/xt_connlimit.c                   |   27 +-
 net/netfilter/xt_hashlimit.c                   |  219 +++++++++-------
 net/netfilter/xt_limit.c                       |    4 +-
 net/netfilter/xt_osf.c                         |    4 +-
 net/netfilter/xt_recent.c                      |  164 ++++++++----
 net/netfilter/xt_repldata.h                    |   35 +++
 111 files changed, 2313 insertions(+), 1836 deletions(-)
 create mode 100644 include/linux/netfilter/xt_CT.h
 create mode 100644 include/net/netfilter/nf_conntrack_zones.h
 create mode 100644 net/netfilter/xt_CT.c
 create mode 100644 net/netfilter/xt_repldata.h

Alexey Dobriyan (16):
      netfilter: nfnetlink: netns support
      netfilter: ctnetlink: netns support
      netfilter: xt_connlimit: netns support
      netfilter: netns: #ifdef ->iptable_security, ->ip6table_security
      netfilter: xt_hashlimit: simplify seqfile code
      netfilter: xtables: add struct xt_mtchk_param::net
      netfilter: xtables: add struct xt_mtdtor_param::net
      netfilter: xt_recent: netns support
      netfilter: xt_hashlimit: netns support
      netfiltr: ipt_CLUSTERIP: simplify seq_file codeA
      netfilter: xtables: CONFIG_COMPAT redux
      netfilter: xtables: consistent struct compat_xt_counters definition
      netfilter: xtables: symmetric COMPAT_XT_ALIGN definition
      netfilter: xtables: fix mangle tables
      netfilter: nf_conntrack: elegantly simplify nf_ct_exp_net()
      netfilter: don't use INIT_RCU_HEAD()

Catalin(ux) M. BOIE (1):
      IPVS: Allow boot time change of hash size

Eric Leblond (1):
      netfilter: nfnetlink_queue: simplify warning message

Florian Westphal (4):
      netfilter: fix build failure with CONNTRACK=y NAT=n
      netfilter: ebtables: abort if next_offset is too small
      netfilter: ebtables: avoid explicit XT_ALIGN() in match/targets
      netfilter: CONFIG_COMPAT: allow delta to exceed 32767

Jan Engelhardt (14):
      netfilter: xt_recent: save 8 bytes per htable
      netfilter: xtables: do not grab random bytes at __init
      netfilter: xtables: obtain random bytes earlier, in checkentry
      netfilter: xtables: compact table hook functions (1/2)
      netfilter: xtables: compact table hook functions (2/2)
      netfilter: xtables: use xt_table for hook instantiation
      netfilter: xtables: generate initial table on-demand
      netfilter: xt_recent: inform user when hitcount is too large
      netfilter: iptables: remove unused function arguments
      netfilter: reduce NF_HOOK by one argument
      netfilter: get rid of the grossness in netfilter.h
      netfilter: xtables: print details on size mismatch
      netfilter: xtables: constify args in compat copying functions
      netfilter: xtables: add const qualifiers

Joe Perches (3):
      netfilter: nf_nat_ftp: remove (*mangle[]) array and functions, use %pI4
      ipvs: use standardized format in sprintf
      netfilter: xt_osf: change %pi4 to %pI4

Julia Lawall (1):
      netfilter: SNMP NAT: correct the size argument to kzalloc

Patrick McHardy (21):
      netfilter: xt_hashlimit: fix race condition and simplify locking
      netfilter: ctnetlink: only assign helpers for matching protocols
      netfilter: add struct net * to target parameters
      netfilter: nf_conntrack: split up IPCT_STATUS event
      netfilter: ctnetlink: support selective event delivery
      netfilter: nf_conntrack: support conntrack templates
      netfilter: xtables: add CT target
      Merge branch 'master' of /repos/git/net-next-2.6
      netfilter: ctnetlink: add missing netlink attribute policies
      Merge branch 'master' of git://dev.medozas.de/linux
      netfilter: ctnetlink: dump expectation helper name
      netfilter: nf_conntrack: show helper and class in /proc/net/nf_conntrack_expect
      netfilter: nf_conntrack_sip: fix ct_sip_parse_request() REGISTER request parsing
      netfilter: nf_conntrack_sip: pass data offset to NAT functions
      netfilter: nf_conntrack_sip: add TCP support
      netfilter: nf_nat: support mangling a single TCP packet multiple times
      netfilter: nf_nat_sip: add TCP support
      netfilter: nf_conntrack_sip: add T.38 FAX support
      netfilter: nf_conntrack: pass template to l4proto ->error() handler
      netfilter: nf_conntrack: add support for "conntrack zones"
      netfilter: ctnetlink: add zone support

Shan Wei (2):
      netfilter: nf_conntrack_ipv6: delete the redundant macro definitions
      IPv6: reassembly: replace magic number with macro definitions

Simon Arlott (1):
      netfilter: xt_TCPMSS: SYN packets are allowed to contain data
