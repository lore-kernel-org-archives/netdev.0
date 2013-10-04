From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/33] Netfilter updates for net-next
Date: Fri,  4 Oct 2013 10:32:45 +0200
Message-ID: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net-next tree,
mostly ipset improvements and enhancements features, they are:

* Don't call ip_nest_end needlessly in the error path from me, suggested
  by Pablo Neira Ayuso, from Jozsef Kadlecsik.

* Fixed sparse warnings about shadowed variable and missing rcu annotation
  and fix of "may be used uninitialized" warnings, also from Jozsef.

* Renamed simple macro names to avoid namespace issues, reported by David
  Laight, again from Jozsef.

* Use fix sized type for timeout in the extension part, and cosmetic
  ordering of matches and targets separatedly in xt_set.c, from Jozsef.

* Support package fragments for IPv4 protos without ports from Anders K.
  Pedersen. For example this allows a hash:ip,port ipset containing the
  entry 192.168.0.1,gre:0 to match all package fragments for PPTP VPN
  tunnels to/from the host. Without this patch only the first package
  fragment (with fragment offset 0) was matched.

* Introduced a new operation to get both setname and family, from Jozsef.
  ip[6]tables set match and SET target need to know the family of the set
  in order to reject adding rules which refer to a set with a non-mathcing
  family. Currently such rules are silently accepted and then ignored
  instead of generating an error message to the user.

* Reworked extensions support in ipset types from Jozsef. The approach of
  defining structures with all variations is not manageable as the
  number of extensions grows. Therefore a blob for the extensions is
  introduced, somewhat similar to conntrack. The support of extensions
  which need a per data destroy function is added as well.

* When an element timed out in a list:set type of set, the garbage
  collector skipped the checking of the next element. So the purging
  was delayed to the next run of the gc, fixed by Jozsef.

* A small Kconfig fix: NETFILTER_NETLINK cannot be selected and
  ipset requires it.

* hash:net,net type from Oliver Smith. The type provides the ability to
  store pairs of subnets in a set.

* Comment for ipset entries from Oliver Smith. This makes possible to
  annotate entries in a set with comments, for example:

  ipset n foo hash:net,net comment
  ipset a foo 10.0.0.0/21,192.168.1.0/24 comment "office nets A and B"

* Fix of hash types resizing with comment extension from Jozsef.

* Fix of new extensions for list:set type when an element is added
  into a slot from where another element was pushed away from Jozsef.

* Introduction of a common function for the listing of the element
  extensions from Jozsef.

* Net namespace support for ipset from Vitaly Lavrov.

* hash:net,port,net type from Oliver Smith, which makes possible
  to store the triples of two subnets and a protocol, port pair in
  a set.

* Get xt_TCPMSS working with net namespace, by Gao feng.

* Use the proper net netnamespace to allocate skbs, also by Gao feng.

* A couple of cleanups for the conntrack SIP helper, by Holger
  Eitzenberger.

* Extend cttimeout to allow setting default conntrack timeouts via
  nfnetlink, so we can get rid of all our sysctl/proc interfaces in
  the future for timeout tuning, from me.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 8ce440610357b77587433d0df647cea69a6890a8:

  ipv6: do not allow ipv6 module to be removed (2013-09-24 11:31:58 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 91cb498e6a34b429a032f8cfbb57dde28cd20e0c:

  netfilter: cttimeout: allow to set/get default protocol timeouts (2013-10-01 13:17:39 +0200)

----------------------------------------------------------------
Anders K. Pedersen (1):
      netfilter: ipset: Support package fragments for IPv4 protos without ports

Gao feng (4):
      netfilter: xt_TCPMSS: Get mtu only if clamp-mss-to-pmtu is specified
      netfilter: xt_TCPMSS: lookup route from proper net namespace
      netfilter: nfnetlink_queue: use proper net namespace to allocate skb
      netfilter: nfnetlink_log: use proper net to allocate skb

Jozsef Kadlecsik (18):
      netfilter: ipset: Don't call ip_nest_end needlessly in the error path
      netfilter: ipset: Sparse warning about shadowed variable fixed
      netfilter: ipset: Fix sparse warnings due to missing rcu annotations
      netfilter: ipset: Rename simple macro names to avoid namespace issues.
      netfilter: ipset: Fix "may be used uninitialized" warnings
      netfilter: ipset: Use fix sized type for timeout in the extension part
      netfilter: ipset: order matches and targets separatedly in xt_set.c
      netfilter: ipset: Introduce new operation to get both setname and family
      netfilter: ipset: Prepare ipset to support multiple networks for hash types
      netfilter: ipset: Rename extension offset ids to extension ids
      netfilter: ipset: Move extension data to set structure
      netfilter: ipset: Generalize extensions support
      netfilter: ipset: Support extensions which need a per data destroy function
      netfilter: ipset: list:set: make sure all elements are checked by the gc
      netfilter: ipset: Kconfig: ipset needs NETFILTER_NETLINK
      netfilter: ipset: Fix hash resizing with comments
      netfilter: ipset: For set:list types, replaced elements must be zeroed out
      netfilter: ipset: Use a common function at listing the extensions

Oliver Smith (6):
      netfilter: ipset: Add hash:net,net module to kernel.
      netfilter: ipset: Support comments for ipset entries in the core.
      netfilter: ipset: Support comments in bitmap-type ipsets.
      netfilter: ipset: Support comments in the list-type ipset.
      netfilter: ipset: Support comments in hash-type ipsets.
      netfilter: ipset: Add hash:net,port,net module to kernel.

Pablo Neira Ayuso (1):
      netfilter: cttimeout: allow to set/get default protocol timeouts

Vitaly Lavrov (1):
      netfiler: ipset: Add net namespace for ipset

holger@eitzenberger.org (2):
      netfilter: nf_ct_sip: extend RCU read lock in set_expected_rtp_rtcp()
      netfilter: nf_ct_sip: consolidate NAT hook functions

 include/linux/netfilter/ipset/ip_set.h             |  151 ++++-
 include/linux/netfilter/ipset/ip_set_comment.h     |   57 ++
 include/linux/netfilter/ipset/ip_set_timeout.h     |    4 +-
 include/linux/netfilter/nf_conntrack_sip.h         |  107 ++--
 include/uapi/linux/netfilter/ipset/ip_set.h        |   16 +-
 include/uapi/linux/netfilter/nfnetlink_cttimeout.h |    2 +
 net/netfilter/ipset/Kconfig                        |   20 +-
 net/netfilter/ipset/Makefile                       |    2 +
 net/netfilter/ipset/ip_set_bitmap_gen.h            |  163 +++---
 net/netfilter/ipset/ip_set_bitmap_ip.c             |  125 ++---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c          |  156 ++----
 net/netfilter/ipset/ip_set_bitmap_port.c           |  112 +---
 net/netfilter/ipset/ip_set_core.c                  |  361 ++++++++----
 net/netfilter/ipset/ip_set_getport.c               |   18 +-
 net/netfilter/ipset/ip_set_hash_gen.h              |  526 ++++++++---------
 net/netfilter/ipset/ip_set_hash_ip.c               |   58 +-
 net/netfilter/ipset/ip_set_hash_ipport.c           |   80 +--
 net/netfilter/ipset/ip_set_hash_ipportip.c         |   86 +--
 net/netfilter/ipset/ip_set_hash_ipportnet.c        |  108 +---
 net/netfilter/ipset/ip_set_hash_net.c              |   85 +--
 net/netfilter/ipset/ip_set_hash_netiface.c         |   98 +---
 net/netfilter/ipset/ip_set_hash_netnet.c           |  483 ++++++++++++++++
 net/netfilter/ipset/ip_set_hash_netport.c          |   92 +--
 net/netfilter/ipset/ip_set_hash_netportnet.c       |  588 ++++++++++++++++++++
 net/netfilter/ipset/ip_set_list_set.c              |  263 ++++-----
 net/netfilter/nf_conntrack_sip.c                   |  133 ++---
 net/netfilter/nf_nat_sip.c                         |   35 +-
 net/netfilter/nfnetlink_cttimeout.c                |  161 +++++-
 net/netfilter/nfnetlink_log.c                      |   11 +-
 net/netfilter/nfnetlink_queue_core.c               |    6 +-
 net/netfilter/xt_TCPMSS.c                          |   72 +--
 net/netfilter/xt_set.c                             |  222 ++++----
 net/sched/em_ipset.c                               |    7 +-
 33 files changed, 2677 insertions(+), 1731 deletions(-)
 create mode 100644 include/linux/netfilter/ipset/ip_set_comment.h
 create mode 100644 net/netfilter/ipset/ip_set_hash_netnet.c
 create mode 100644 net/netfilter/ipset/ip_set_hash_netportnet.c

