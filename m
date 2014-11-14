From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter/IPVS fixes for net
Date: Fri, 14 Nov 2014 17:58:40 +0100
Message-ID: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter updates for your net tree,
they are:

1) Fix missing initialization of the range structure (allocated in the
   stack) in nft_masq_{ipv4, ipv6}_eval, from Daniel Borkmann.

2) Make sure the data we receive from userspace contains the req_version
   structure, otherwise return an error incomplete on truncated input.
   From Dan Carpenter.

3) Fix handling og skb->sk which may cause incorrect handling
   of connections from a local process. Via Simon Horman, patch from
   Calvin Owens.

4) Fix wrong netns in nft_compat when setting target and match params
   structure.

5) Relax chain type validation in nft_compat that was recently included,
   this broke the matches that need to be run from the route chain type.
   Now iptables-test.py automated regression tests report success again
   and we avoid the only possible problematic case, which is the use of
   nat targets out of nat chain type.

6) Use match->table to validate the tablename, instead of the match->name.
   Again patch for nft_compat.

7) Restore the synchronous release of objects from the commit and abort
   path in nf_tables. This is causing two major problems: splats when using
   nft_compat, given that matches and targets may sleep and call_rcu is
   invoked from softirq context. Moreover Patrick reported possible event
   notification reordering when rules refer to anonymous sets.

8) Fix race condition in between packets that are being confirmed by
   conntrack and the ctnetlink flush operation. This happens since the
   removal of the central spinlock. Thanks to Jesper D. Brouer to looking
   into this.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit d52fdbb735c36a209f36a628d40ca9185b349ba7:

  smc91x: retrieve IRQ and trigger flags in a modern way (2014-11-01 17:04:20 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 5195c14c8b27cc0b18220ddbf0e5ad3328a04187:

  netfilter: conntrack: fix race in __nf_conntrack_confirm against get_next_corpse (2014-11-14 17:43:05 +0100)

----------------------------------------------------------------
Calvin Owens (1):
      ipvs: Keep skb->sk when allocating headroom on tunnel xmit

Dan Carpenter (1):
      netfilter: ipset: small potential read beyond the end of buffer

Daniel Borkmann (1):
      netfilter: nft_masq: fix uninitialized range in nft_masq_{ipv4, ipv6}_eval

Pablo Neira Ayuso (4):
      netfilter: nft_compat: use current net namespace
      netfilter: nft_compat: relax chain type validation
      netfilter: nft_compat: use the match->table to validate dependencies
      netfilter: nf_tables: restore synchronous object release from commit/abort

bill bonaparte (1):
      netfilter: conntrack: fix race in __nf_conntrack_confirm against get_next_corpse

 include/net/netfilter/nf_tables.h  |    2 --
 net/ipv4/netfilter/nft_masq_ipv4.c |    1 +
 net/ipv6/netfilter/nft_masq_ipv6.c |    1 +
 net/netfilter/ipset/ip_set_core.c  |    6 ++++++
 net/netfilter/ipvs/ip_vs_xmit.c    |    2 ++
 net/netfilter/nf_conntrack_core.c  |   14 +++++++------
 net/netfilter/nf_tables_api.c      |   24 ++++++++--------------
 net/netfilter/nft_compat.c         |   40 ++++++------------------------------
 8 files changed, 32 insertions(+), 58 deletions(-)
