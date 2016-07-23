From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/25] Netfilter/IPVS updates for net-next
Date: Sat, 23 Jul 2016 13:08:14 +0200
Message-ID: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, resending this pull request, I modified my robot and it was not
including explicit Cc to netdev.

-o-

Hi David,

The following patchset contains Netfilter/IPVS updates for net-next,
they are:

1) Count pre-established connections as active in "least connection"
   schedulers such that pre-established connections to avoid overloading
   backend servers on peak demands, from Michal Kubecek via Simon Horman.

2) Address a race condition when resizing the conntrack table by caching
   the bucket size when fulling iterating over the hashtable in these
   three possible scenarios: 1) dump via /proc/net/nf_conntrack,
   2) unlinking userspace helper and 3) unlinking custom conntrack timeout.
   From Liping Zhang.

3) Revisit early_drop() path to perform lockless traversal on conntrack
   eviction under stress, use del_timer() as synchronization point to
   avoid two CPUs evicting the same entry, from Florian Westphal.

4) Move NAT hlist_head to nf_conn object, this simplifies the existing
   NAT extension and it doesn't increase size since recent patches to
   align nf_conn, from Florian.

5) Use rhashtable for the by-source NAT hashtable, also from Florian.

6) Don't allow --physdev-is-out from OUTPUT chain, just like
   --physdev-out is not either, from Hangbin Liu.

7) Automagically set on nf_conntrack counters if the user tries to
   match ct bytes/packets from nftables, from Liping Zhang.

8) Remove possible_net_t fields in nf_tables set objects since we just
   simply pass the net pointer to the backend set type implementations.

9) Fix possible off-by-one in h323, from Toby DiPasquale.

10) early_drop() may be called from ctnetlink patch, so we must hold
    rcu read size lock from them too, this amends Florian's patch #3
    coming in this batch, from Liping Zhang.

11) Use binary search to validate jump offset in x_tables, this
    addresses the O(n!) validation that was introduced recently
    resolve security issues with unpriviledge namespaces, from Florian.

12) Fix reference leak to connlabel in error path of nft_ct, from Zhang.

13) Three updates for nft_log: Fix log prefix leak in error path. Bail
    out on loglevel larger than debug in nft_log and set on the new
    NF_LOG_F_COPY_LEN flag when snaplen is specified. Again from Zhang.

14) Allow to filter rule dumps in nf_tables based on table and chain
    names.

15) Simplify connlabel to always use 128 bits to store labels and
    get rid of unused function in xt_connlabel, from Florian.

16) Replace set_expect_timeout() by mod_timer() from the h323 conntrack
    helper, by Gao Feng.

17) Put back x_tables module reference in nft_compat on error, from
    Liping Zhang.

18) Add a reference count to the x_tables extensions cache in
    nft_compat, so we can remove them when unused and avoid a crash
    if the extensions are rmmod, again from Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit a90a6e55f34f28190e4dc2a6a3660ef157827a8f:

  Merge tag 'mac80211-next-for-davem-2016-07-06' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next (2016-07-06 22:32:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to 4b512e1c1f8de6b9ceb796ecef8658e0a083cab7:

  netfilter: nft_compat: fix crash when related match/target module is removed (2016-07-23 12:25:00 +0200)

----------------------------------------------------------------
Florian Westphal (7):
      netfilter: conntrack: simplify early_drop
      netfilter: move nat hlist_head to nf_conn
      netfilter: nat: convert nat bysrc hash to rhashtable
      netfilter: constify arg to is_dying/confirmed
      netfilter: x_tables: speed up jump target validation
      netfilter: conntrack: support a fixed size of 128 distinct labels
      netfilter: connlabels: move set helper to xt_connlabel

Gao Feng (2):
      netfilter: Add helper array register/unregister functions
      netfilter: h323: Use mod_timer instead of set_expect_timeout

Hangbin Liu (1):
      netfilter: physdev: physdev-is-out should not work with OUTPUT chain

Liping Zhang (11):
      netfilter: conntrack: fix race between nf_conntrack proc read and hash resize
      netfilter: cttimeout: unlink timeout obj again when hash resize happen
      netfilter: nf_ct_helper: unlink helper again when hash resize happen
      netfilter: nft_ct: make byte/packet expr more friendly
      netfilter: conntrack: protect early_drop by rcu read lock
      netfilter: nft_ct: fix unpaired nf_connlabels_get/put call
      netfilter: nft_log: fix possible memory leak if log expr init fail
      netfilter: nft_log: check the validity of log level
      netfilter: nft_log: fix snaplen does not truncate packets
      netfilter: nft_compat: put back match/target module if init fail
      netfilter: nft_compat: fix crash when related match/target module is removed

Michal Kubecek (1):
      ipvs: count pre-established TCP states as active

Pablo Neira Ayuso (3):
      netfilter: nf_tables: get rid of possible_net_t from set and basechain
      Merge tag 'ipvs-for-v4.8' of https://git.kernel.org/.../horms/ipvs-next
      netfilter: nf_tables: allow to filter out rules by table and chain

Toby DiPasquale (1):
      netfilter: nf_conntrack_h323: fix off-by-one in DecodeQ931

 include/linux/netfilter/x_tables.h                 |   4 +
 include/net/netfilter/nf_conntrack.h               |   9 +-
 include/net/netfilter/nf_conntrack_core.h          |   2 +
 include/net/netfilter/nf_conntrack_extend.h        |   3 -
 include/net/netfilter/nf_conntrack_helper.h        |  15 +++
 include/net/netfilter/nf_conntrack_labels.h        |  18 +--
 include/net/netfilter/nf_nat.h                     |   3 +-
 include/net/netfilter/nf_tables.h                  |  21 +--
 net/ipv4/netfilter/arp_tables.c                    |  47 ++++---
 net/ipv4/netfilter/ip_tables.c                     |  45 ++++---
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |  14 +-
 net/ipv6/netfilter/ip6_tables.c                    |  45 ++++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c               |  25 +++-
 net/netfilter/nf_conntrack_core.c                  | 115 +++++++++-------
 net/netfilter/nf_conntrack_extend.c                |  15 +--
 net/netfilter/nf_conntrack_ftp.c                   |  58 +++-----
 net/netfilter/nf_conntrack_h323_asn1.c             |   3 +-
 net/netfilter/nf_conntrack_h323_main.c             |  15 +--
 net/netfilter/nf_conntrack_helper.c                |  76 ++++++++++-
 net/netfilter/nf_conntrack_irc.c                   |  36 ++---
 net/netfilter/nf_conntrack_labels.c                |  28 +---
 net/netfilter/nf_conntrack_netlink.c               |  10 +-
 net/netfilter/nf_conntrack_sane.c                  |  57 +++-----
 net/netfilter/nf_conntrack_sip.c                   |  75 ++++-------
 net/netfilter/nf_conntrack_standalone.c            |  14 +-
 net/netfilter/nf_conntrack_tftp.c                  |  48 +++----
 net/netfilter/nf_nat_core.c                        | 149 ++++++++++-----------
 net/netfilter/nf_tables_api.c                      |  48 ++++++-
 net/netfilter/nfnetlink_cttimeout.c                |  20 ++-
 net/netfilter/nft_compat.c                         |  75 ++++++-----
 net/netfilter/nft_ct.c                             |  41 +++---
 net/netfilter/nft_hash.c                           |  20 +--
 net/netfilter/nft_log.c                            |  34 +++--
 net/netfilter/nft_lookup.c                         |   2 +-
 net/netfilter/nft_rbtree.c                         |  26 ++--
 net/netfilter/x_tables.c                           |  50 +++++++
 net/netfilter/xt_connlabel.c                       |  29 ++--
 net/netfilter/xt_physdev.c                         |   8 +-
 net/openvswitch/conntrack.c                        |   4 +-
 39 files changed, 718 insertions(+), 589 deletions(-)
