From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/23] nf_tables updates for net-next
Date: Fri, 10 Jan 2014 01:35:19 +0100
Message-ID: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains the following nf_tables updates,
mostly updates from Patrick McHardy, they are:

* Add the "inet" table and filter chain type for this new netfilter
  family: NFPROTO_INET. This special table/chain allows IPv4 and IPv6
  rules, this should help to simplify the burden in the administration
  of dual stack firewalls. This also includes several patches to prepare
  the infrastructure for this new table and a new meta extension to
  match the layer 3 and 4 protocol numbers, from Patrick McHardy.

* Load both IPv4 and IPv6 conntrack modules in nft_ct if the rule is used
  in NFPROTO_INET, as we don't certainly know which one would be used,
  also from Patrick McHardy.

* Do not allow to delete a table that contains sets, otherwise these
  sets become orphan, from Patrick McHardy.

* Hold a reference to the corresponding nf_tables family module when
  creating a table of that family type, to avoid the module deletion
  when in use, from Patrick McHardy.

* Update chain counters before setting the chain policy to ensure that
  we don't leave the chain in inconsistent state in case of errors (aka.
  restore chain atomicity). This also fixes a possible leak if it fails
  to allocate the chain counters if no counters are passed to be restored,
  from Patrick McHardy.

* Don't check for overflows in the table counter if we are just renaming
  a chain, from Patrick McHardy.

* Replay the netlink request after dropping the nfnl lock to load the
  module that supports provides a chain type, from Patrick.

* Fix chain type module references, from Patrick.

* Several cleanups, function renames, constification and code
  refactorizations also from Patrick McHardy.

* Add support to set the connmark, this can be used to set it based on
  the meta mark (similar feature to -j CONNMARK --restore), from
  Kristian Evensen.

* A couple of fixes to the recently added meta/set support and nft_reject,
  and fix missing chain type unregistration if we fail to register our
  the family table/filter chain type, from myself.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

Thanks!

----------------------------------------------------------------

The following changes since commit cdb3f4a31b64c3a1c6eef40bc01ebc9594c58a8c:

  net: Do not enable tx-nocache-copy by default (2014-01-07 16:20:19 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

for you to fetch changes up to cf4dfa85395ebe2769267a072b39e48301669842:

  netfilter: nf_tables: fix error path in the init functions (2014-01-09 23:25:48 +0100)

----------------------------------------------------------------
Kristian Evensen (1):
      netfilter: nft_ct: Add support to set the connmark

Pablo Neira Ayuso (3):
      netfilter: nft_reject: fix compilation warning if NF_TABLES_IPV6 is disabled
      netfilter: nft_meta: fix lack of validation of the input register
      netfilter: nf_tables: fix error path in the init functions

Patrick McHardy (19):
      netfilter: nf_tables: make chain types override the default AF functions
      netfilter: nf_tables: add hook ops to struct nft_pktinfo
      netfilter: nf_tables: add support for multi family tables
      netfilter: nf_tables: add "inet" table for IPv4/IPv6
      netfilter: nf_tables: add nfproto support to meta expression
      netfilter: nft_meta: add l4proto support
      netfilter: nft_ct: load both IPv4 and IPv6 conntrack modules for NFPROTO_INET
      netfilter: nf_tables: split chain policy validation from actually setting it
      netfilter: nf_tables: restore chain change atomicity
      netfilter: nf_tables: fix check for table overflow
      netfilter: nf_tables: fix chain type module reference handling
      netfilter: nf_tables: add missing module references to chain types
      netfilter: nf_tables: replay request after dropping locks to load chain type
      netfilter: nf_tables: constify chain type definitions and pointers
      netfilter: nf_tables: minor nf_chain_type cleanups
      netfilter: nf_tables: perform flags validation before table allocation
      netfilter: nf_tables: take AF module reference when creating a table
      netfilter: nf_tables: prohibit deletion of a table with existing sets
      netfilter: nf_tables: rename nft_do_chain_pktinfo() to nft_do_chain()

 include/net/netfilter/nf_tables.h         |   47 ++++--
 include/net/netfilter/nf_tables_ipv4.h    |    5 +-
 include/net/netfilter/nf_tables_ipv6.h    |    3 +
 include/net/netns/nftables.h              |    1 +
 include/uapi/linux/netfilter.h            |    1 +
 include/uapi/linux/netfilter/nf_tables.h  |    6 +
 net/bridge/netfilter/nf_tables_bridge.c   |   44 +++---
 net/ipv4/netfilter/nf_tables_arp.c        |   44 +++---
 net/ipv4/netfilter/nf_tables_ipv4.c       |   60 ++++----
 net/ipv4/netfilter/nft_chain_nat_ipv4.c   |   10 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c |   10 +-
 net/ipv6/netfilter/nf_tables_ipv6.c       |   65 ++++-----
 net/ipv6/netfilter/nft_chain_nat_ipv6.c   |   10 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c |   10 +-
 net/netfilter/Kconfig                     |    8 ++
 net/netfilter/Makefile                    |    1 +
 net/netfilter/nf_tables_api.c             |  223 +++++++++++++++--------------
 net/netfilter/nf_tables_core.c            |    6 +-
 net/netfilter/nf_tables_inet.c            |  104 ++++++++++++++
 net/netfilter/nft_compat.c                |    8 +-
 net/netfilter/nft_ct.c                    |  199 +++++++++++++++++++++----
 net/netfilter/nft_log.c                   |    2 +-
 net/netfilter/nft_meta.c                  |   11 ++
 net/netfilter/nft_reject.c                |    9 +-
 24 files changed, 595 insertions(+), 292 deletions(-)
 create mode 100644 net/netfilter/nf_tables_inet.c


