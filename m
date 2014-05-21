From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/25] Netfilter/nftables updates for net-next
Date: Wed, 21 May 2014 11:42:58 +0200
Message-ID: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/nftables updates for net-next,
most relevantly they are:

1) Add set element update notification via netlink, from Arturo Borrero.

2) Put all object updates in one single message batch that is sent to
   kernel-space. Before this patch only rules where included in the batch.
   This series also introduces the generic transaction infrastructure so
   updates to all objects (tables, chains, rules and sets) are applied in
   an all-or-nothing fashion, these series from me.

3) Defer release of objects via call_rcu to reduce the time required to
   commit changes. The assumption is that all objects are destroyed in
   reverse order to ensure that dependencies betweem them are fulfilled
   (ie. rules and sets are destroyed first, then chains, and finally
   tables).

4) Allow to match by bridge port name, from Tomasz Bursztyka. This series
   include two patches to prepare this new feature.

5) Implement the proper set selection based on the characteristics of the
   data. The new infrastructure also allows you to specify your preferences
   in terms of memory and computational complexity so the underlying set
   type is also selected according to your needs, from Patrick McHardy.

6) Several cleanup patches for nft expressions, including one minor possible
   compilation breakage due to missing mark support, also from Patrick.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git

Thanks!

----------------------------------------------------------------

The following changes since commit b1586f099ba897542ece36e8a23c1a62907261ef:

  netpoll: Use skb_irq_freeable to make zap_completion_queue safe. (2014-04-01 17:53:36 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

for you to fetch changes up to c7c32e72cbe23cea97c5d87ffcf6e23cc1ec1a65:

  netfilter: nf_tables: defer all object release via rcu (2014-05-19 12:06:13 +0200)

----------------------------------------------------------------
Arturo Borrero (1):
      netfilter: nf_tables: add set_elem notifications

Pablo Neira (1):
      netfilter: nf_tables: relax string validation of NFTA_CHAIN_TYPE

Pablo Neira Ayuso (14):
      netfilter: nf_tables: deconstify table and chain in context structure
      netfilter: nf_tables: generalise transaction infrastructure
      netfilter: nf_tables: relocate commit and abort routines in the source file
      netfilter: nf_tables: add message type to transactions
      netfilter: nf_tables: use new transaction infrastructure to handle sets
      netfilter: nf_tables: refactor chain statistic routines
      netfilter: nf_tables: use new transaction infrastructure to handle chain
      netfilter: nf_tables: disabling table hooks always succeeds
      netfilter: nf_tables: pass context to nf_tables_updtable()
      netfilter: nf_tables: use new transaction infrastructure to handle table
      netfilter: nf_tables: use new transaction infrastructure to handle elements
      netfilter: nf_tables: simplify nf_tables_*_notify
      netfilter: nf_tables: remove skb and nlh from context structure
      netfilter: nf_tables: defer all object release via rcu

Patrick McHardy (6):
      netfilter: nft_ct: add missing ifdef for NFT_MARK setting
      netfilter: nft_meta: split nft_meta_init() into two functions for get/set
      netfilter: nft_ct: split nft_ct_init() into two functions for get/set
      netfilter: nf_tables: implement proper set selection
      netfilter: nft_hash: use set global element counter instead of private one
      netfilter: nf_tables: handle more than 8 * PAGE_SIZE set name allocations

Tomasz Bursztyka (3):
      netfilter: nf_tables: Stack expression type depending on their family
      netfilter: nf_tables: Make meta expression core functions public
      netfilter: nf_tables: Add meta expression key for bridge interface name

 include/net/netfilter/nf_tables.h        |  130 +++-
 include/net/netfilter/nft_meta.h         |   36 +
 include/uapi/linux/netfilter/nf_tables.h |   37 +
 net/bridge/Makefile                      |    2 +-
 net/bridge/netfilter/Kconfig             |   14 +-
 net/bridge/netfilter/Makefile            |    1 +
 net/bridge/netfilter/nft_meta_bridge.c   |  139 ++++
 net/netfilter/nf_tables_api.c            | 1236 +++++++++++++++++++++---------
 net/netfilter/nft_ct.c                   |   96 ++-
 net/netfilter/nft_hash.c                 |   54 +-
 net/netfilter/nft_lookup.c               |   10 +-
 net/netfilter/nft_meta.c                 |  103 ++-
 net/netfilter/nft_rbtree.c               |   21 +
 13 files changed, 1407 insertions(+), 472 deletions(-)
 create mode 100644 include/net/netfilter/nft_meta.h
 create mode 100644 net/bridge/netfilter/nft_meta_bridge.c
