From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/32] Netfilter updates for net-next
Date: Mon, 15 Jun 2015 23:25:57 +0200
Message-ID: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58726 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbbFOVVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This a bit large (and late) patchset that contains Netfilter updates for
net-next. Most relevantly br_netfilter fixes, ipset RCU support, removal of
x_tables percpu ruleset copy and rework of the nf_tables netdev support. More
specifically, they are:

1) Warn the user when there is a better protocol conntracker available, from
   Marcelo Ricardo Leitner.

2) Fix forwarding of IPv6 fragmented traffic in br_netfilter, from Bernhard
   Thaler. This comes with several patches to prepare the change in first place.

3) Get rid of special mtu handling of PPPoE/VLAN frames for br_netfilter. This
   is not needed anymore since now we use the largest fragment size to
   refragment, from Florian Westphal.

4) Restore vlan tag when refragmenting in br_netfilter, also from Florian.

5) Get rid of the percpu ruleset copy in x_tables, from Florian. Plus another
   follow up patch to refine it from Eric Dumazet.

6) Several ipset cleanups, fixes and finally RCU support, from Jozsef Kadlecsik.

7) Get rid of parens in Netfilter Kconfig files.

8) Attach the net_device to the basechain as opposed to the initial per table
   approach in the nf_tables netdev family.

9) Subscribe to netdev events to detect the removal and registration of a
   device that is referenced by a basechain.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Have a nice and safe travel to NFWS in Budapest.

Thanks!

----------------------------------------------------------------

The following changes since commit c63264def3393dd123bfa630a7a46b5d6d2d6038:

  Merge branch 'tcp-gso-settings-defer' (2015-06-11 16:33:11 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 835b803377f5f11f9ccf234f70ed667a82605c45:

  netfilter: nf_tables_netdev: unregister hooks on net_device removal (2015-06-15 23:02:35 +0200)

----------------------------------------------------------------
Bernhard Thaler (7):
      netfilter: bridge: refactor clearing BRNF_NF_BRIDGE_PREROUTING
      netfilter: bridge: re-order br_nf_pre_routing_finish_ipv6()
      netfilter: bridge: detect NAT66 correctly and change MAC address
      netfilter: bridge: refactor frag_max_size
      netfilter: bridge: rename br_parse_ip_options
      netfilter: bridge: re-order check_hbh_len()
      netfilter: bridge: forward IPv6 fragmented packets

Eric Dumazet (1):
      netfilter: x_tables: remove XT_TABLE_INFO_SZ and a dereference.

Florian Westphal (4):
      net: ip_fragment: remove BRIDGE_NETFILTER mtu special handling
      netfilter: bridge: restore vlan tag when refragmenting
      netfilter: xtables: use percpu rule counters
      netfilter: xtables: avoid percpu ruleset duplication

Jozsef Kadlecsik (10):
      netfilter: ipset: Use MSEC_PER_SEC consistently
      netfilter: ipset: Fix cidr handling for hash:*net* types
      netfilter: ipset: Fix parallel resizing and listing of the same set
      netfilter: ipset: Make sure listing doesn't grab a set which is just being destroyed.
      netfilter:ipset Remove rbtree from hash:net,iface
      netfilter: ipset: Prepare the ipset core to use RCU at set level
      netfilter: ipset: Introduce RCU locking in bitmap:* types
      netfilter: ipset: Introduce RCU locking in hash:* types
      netfilter: ipset: Introduce RCU locking in list type
      netfilter: ipset: Fix coding styles reported by checkpatch.pl

Marcelo Ricardo Leitner (1):
      netfilter: conntrack: warn the user if there is a better helper to use

Pablo Neira Ayuso (5):
      netfilter: Kconfig: get rid of parens around depends on
      Merge branch 'master' of git://blackhole.kfki.hu/nf-next
      netfilter: nf_tables: attach net_device to basechain
      netfilter: nf_tables: add nft_register_basechain() and nft_unregister_basechain()
      netfilter: nf_tables_netdev: unregister hooks on net_device removal

Sergey Popovich (5):
      netfilter: ipset: Use SET_WITH_*() helpers to test set extensions
      netfilter: ipset: Check extensions attributes before getting extensions.
      netfilter: ipset: Permit CIDR equal to the host address CIDR in IPv6
      netfilter: ipset: Make sure we always return line number on batch
      netfilter: ipset: Check CIDR value only when attribute is given

 include/linux/netfilter/ipset/ip_set.h         |   29 +-
 include/linux/netfilter/ipset/ip_set_comment.h |   38 +-
 include/linux/netfilter/ipset/ip_set_timeout.h |   27 +-
 include/linux/netfilter/x_tables.h             |   56 +-
 include/linux/netfilter_bridge.h               |    7 -
 include/linux/netfilter_ipv6.h                 |    3 +
 include/linux/skbuff.h                         |    7 +-
 include/net/netfilter/nf_tables.h              |   11 +-
 include/uapi/linux/netfilter/ipset/ip_set.h    |    6 +-
 include/uapi/linux/netfilter/nf_tables.h       |    4 +-
 net/bridge/br_netfilter.c                      |  398 ++++++++-----
 net/bridge/br_private.h                        |    7 +-
 net/ipv4/ip_output.c                           |    4 -
 net/ipv4/netfilter/Kconfig                     |    3 +-
 net/ipv4/netfilter/arp_tables.c                |   86 +--
 net/ipv4/netfilter/ip_tables.c                 |   95 ++--
 net/ipv6/netfilter.c                           |    2 +
 net/ipv6/netfilter/Kconfig                     |    3 +-
 net/ipv6/netfilter/ip6_tables.c                |   96 ++--
 net/netfilter/Kconfig                          |   18 +-
 net/netfilter/ipset/ip_set_bitmap_gen.h        |   44 +-
 net/netfilter/ipset/ip_set_bitmap_ip.c         |   27 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c      |   46 +-
 net/netfilter/ipset/ip_set_bitmap_port.c       |   24 +-
 net/netfilter/ipset/ip_set_core.c              |  344 ++++++------
 net/netfilter/ipset/ip_set_getport.c           |   13 +-
 net/netfilter/ipset/ip_set_hash_gen.h          |  714 +++++++++++++++---------
 net/netfilter/ipset/ip_set_hash_ip.c           |   39 +-
 net/netfilter/ipset/ip_set_hash_ipmark.c       |   46 +-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   51 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   53 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   58 +-
 net/netfilter/ipset/ip_set_hash_mac.c          |   19 +-
 net/netfilter/ipset/ip_set_hash_net.c          |   49 +-
 net/netfilter/ipset/ip_set_hash_netiface.c     |  225 ++------
 net/netfilter/ipset/ip_set_hash_netnet.c       |  120 ++--
 net/netfilter/ipset/ip_set_hash_netport.c      |   52 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c   |  128 ++---
 net/netfilter/ipset/ip_set_list_set.c          |  419 +++++++-------
 net/netfilter/ipset/pfxlen.c                   |   16 +-
 net/netfilter/nf_conntrack_proto_generic.c     |    8 +-
 net/netfilter/nf_tables_api.c                  |  139 +++--
 net/netfilter/nf_tables_netdev.c               |   75 +++
 net/netfilter/x_tables.c                       |   37 +-
 net/netfilter/xt_set.c                         |   44 +-
 45 files changed, 1972 insertions(+), 1718 deletions(-)
