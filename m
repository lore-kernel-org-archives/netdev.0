From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/18] Netfilter/nftables/IPVS fixes for net
Date: Fri,  7 Feb 2014 18:41:26 +0100
Message-ID: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41386 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486AbaBGRmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter/IPVS fixes, mostly nftables
fixes, most relevantly they are:

* Fix a crash in the h323 conntrack NAT helper due to expectation list
  corruption, from Alexey Dobriyan.

* A couple of RCU race fixes for conntrack, one manifests by hitting BUG_ON
  in nf_nat_setup_info() and the destroy path, patches from Andrey Vagin and
  me.

* Dump direction attribute in nft_ct only if it is set, from Arturo
  Borrero.

* Fix IPVS bug in its own connection tracking system that may lead to
  copying only 4 bytes of the IPv6 address when initializing the
  ip_vs_conn object, from Michal Kubecek.

* Fix -EBUSY errors in nftables when deleting the rules, chain and tables
  in a row due mixture of asynchronous and synchronous object releasing,
  from me.

* Three fixes for the nf_tables set infrastructure when using intervals and
  mappings, from me.

* Four patches to fixing the nf_tables log, reject and ct expressions from
  the new inet table, from Patrick McHardy.

* Fix memory overrun in the map that is used to dynamically allocate names
  from anonymous sets, also from Patrick.

* Fix a potential oops if you dump a set with NFPROTO_UNSPEC and a table
  name, from Patrick McHardy.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit d922e1cb1ea17ac7f0a5c3c2be98d4bd80d055b8:

  net: Document promote_secondaries (2014-01-27 20:39:21 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 6d8c00d58e9e484fdc41aaaf62e5d8364efe375a:

  netfilter: nf_tables: unininline nft_trace_packet() (2014-02-07 17:50:27 +0100)

----------------------------------------------------------------
Alexey Dobriyan (1):
      netfilter: nf_nat_h323: fix crash in nf_ct_unlink_expect_report()

Andrey Vagin (1):
      netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get

Arturo Borrero (1):
      netfilter: nft_ct: fix unconditional dump of 'dir' attr

Michal Kubecek (1):
      ipvs: fix AF assignment in ip_vs_conn_new()

Pablo Neira Ayuso (5):
      netfilter: nf_conntrack: don't release a conntrack with non-zero refcnt
      netfilter: nf_tables: fix racy rule deletion
      netfilter: nf_tables: do not allow NFT_SET_ELEM_INTERVAL_END flag and data
      netfilter: nft_rbtree: fix data handling of end interval elements
      netfilter: nf_tables: fix loop checking with end interval elements

Patrick McHardy (9):
      netfilter: nf_tables: fix oops when deleting a chain with references
      netfilter: nf_tables: fix overrun in nf_tables_set_alloc_name()
      netfilter: nf_tables: fix potential oops when dumping sets
      netfilter: nft_ct: fix missing NFT_CT_L3PROTOCOL key in validity checks
      netfilter: nf_tables: add AF specific expression support
      netfilter: nft_reject: split up reject module into IPv4 and IPv6 specifc parts
      netfilter: nf_tables: add reject module for NFPROTO_INET
      netfilter: nf_tables: fix log/queue expressions for NFPROTO_INET
      netfilter: nf_tables: unininline nft_trace_packet()

 include/net/netfilter/nf_conntrack.h |    2 +
 include/net/netfilter/nf_tables.h    |    9 ++--
 include/net/netfilter/nft_reject.h   |   25 ++++++++++
 net/ipv4/netfilter/Kconfig           |    5 ++
 net/ipv4/netfilter/Makefile          |    1 +
 net/ipv4/netfilter/nf_nat_h323.c     |    5 +-
 net/ipv4/netfilter/nft_reject_ipv4.c |   75 ++++++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig           |    5 ++
 net/ipv6/netfilter/Makefile          |    1 +
 net/ipv6/netfilter/nft_reject_ipv6.c |   76 +++++++++++++++++++++++++++++
 net/netfilter/Kconfig                |    6 ++-
 net/netfilter/Makefile               |    1 +
 net/netfilter/ipvs/ip_vs_conn.c      |    8 +--
 net/netfilter/nf_conntrack_core.c    |   55 +++++++++++++++++----
 net/netfilter/nf_synproxy_core.c     |    5 +-
 net/netfilter/nf_tables_api.c        |   82 ++++++++++++++++++++-----------
 net/netfilter/nf_tables_core.c       |    6 +--
 net/netfilter/nft_ct.c               |   16 +++++-
 net/netfilter/nft_log.c              |    5 +-
 net/netfilter/nft_queue.c            |    4 +-
 net/netfilter/nft_rbtree.c           |   16 ++++--
 net/netfilter/nft_reject.c           |   89 ++++------------------------------
 net/netfilter/nft_reject_inet.c      |   63 ++++++++++++++++++++++++
 net/netfilter/xt_CT.c                |    7 +--
 24 files changed, 413 insertions(+), 154 deletions(-)
 create mode 100644 include/net/netfilter/nft_reject.h
 create mode 100644 net/ipv4/netfilter/nft_reject_ipv4.c
 create mode 100644 net/ipv6/netfilter/nft_reject_ipv6.c
 create mode 100644 net/netfilter/nft_reject_inet.c
