From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/20] Netfilter updates for net-next
Date: Thu,  9 Apr 2015 13:34:44 +0200
Message-ID: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33002 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932750AbbDILbB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next tree.
They are:

* nf_tables set timeout infrastructure from Patrick Mchardy.

1) Add support for set timeout support.

2) Add support for set element timeouts using the new set extension
   infrastructure.

4) Add garbage collection helper functions to get rid of stale elements.
   Elements are accumulated in a batch that are asynchronously released
   via RCU when the batch is full.

5) Add garbage collection synchronization helpers. This introduces a new
   element busy bit to address concurrent access from the netlink API and the
   garbage collector.

5) Add timeout support for the nft_hash set implementation. The garbage
   collector peridically checks for stale elements from the workqueue.

* iptables/nftables cgroup fixes:

6) Ignore non full-socket objects from the input path, otherwise cgroup
   match may crash, from Daniel Borkmann.

7) Fix cgroup in nf_tables.

8) Save some cycles from xt_socket by skipping packet header parsing when
   skb->sk is already set because of early demux. Also from Daniel.

* br_netfilter updates from Florian Westphal.

9) Save frag_max_size and restore it from the forward path too.

10) Use a per-cpu area to restore the original source MAC address when traffic
    is DNAT'ed.

11) Add helper functions to access physical devices.

12) Use these new physdev helper function from xt_physdev.

13) Add another nf_bridge_info_get() helper function to fetch the br_netfilter
    state information.

14) Annotate original layer 2 protocol number in nf_bridge info, instead of
    using kludgy flags.

15) Also annotate the pkttype mangling when the packet travels back and forth
    from the IP to the bridge layer, instead of using a flag.


* More nf_tables set enhancement from Patrick:

16) Fix possible usage of set variant that doesn't support timeouts.

17) Avoid spurious "set is full" errors from Netlink API when there are pending
    stale elements scheduled to be released.

18) Restrict loop checks to set maps.

19) Add support for dynamic set updates from the packet path.

20) Add support to store optional user data (eg. comments) per set element.

BTW, I have also pulled net-next into nf-next to anticipate the conflict
resolution between your okfn() signature changes and Florian's br_netfilter
updates.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit ee90b81203a91d4e5385622811ee7872b5bcfe76:

  hv_netvsc: Fix the packet free when it is in skb headroom (2015-04-07 18:45:33 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to aadd51aa71f8d013c818a312bb2a0c5714830dbc:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2015-04-08 18:30:21 +0200)

----------------------------------------------------------------

Daniel Borkmann (2):
      netfilter: x_tables: fix cgroup matching on non-full sks
      netfilter: x_tables: don't extract flow keys on early demuxed sks in socket match

Florian Westphal (7):
      netfilter: bridge: really save frag_max_size between PRE and POST_ROUTING
      netfilter: bridge: don't use nf_bridge_info data to store mac header
      netfilter: bridge: add helpers for fetching physin/outdev
      netfilter: physdev: use helpers
      netfilter: bridge: add and use nf_bridge_info_get helper
      netfilter: bridge: start splitting mask into public/private chunks
      netfilter: bridge: make BRNF_PKT_TYPE flag a bool

Pablo Neira Ayuso (2):
      netfilter: nft_meta: fix cgroup matching
      Merge git://git.kernel.org/.../davem/net-next

Patrick McHardy (10):
      netfilter: nf_tables: add set timeout API support
      netfilter: nf_tables: add set element timeout support
      netfilter: nf_tables: add set garbage collection helpers
      netfilter: nf_tables: add GC synchronization helpers
      netfilter: nft_hash: add support for timeouts
      netfilter: nf_tables: fix set selection when timeouts are requested
      netfilter: nf_tables: prepare set element accounting for async updates
      netfilter: nf_tables: support different set binding types
      netfilter: nf_tables: add support for dynamic set updates
      netfilter: nf_tables: support optional userdata for set elements

 include/linux/netfilter_bridge.h           |   28 +++-
 include/linux/skbuff.h                     |    8 +-
 include/net/netfilter/nf_tables.h          |  155 +++++++++++++++++++-
 include/net/netfilter/nf_tables_core.h     |    3 +
 include/uapi/linux/netfilter/nf_tables.h   |   39 +++++
 net/bridge/br_netfilter.c                  |  144 +++++++++++-------
 net/ipv4/netfilter/nf_reject_ipv4.c        |    4 +-
 net/ipv6/netfilter/nf_reject_ipv6.c        |    4 +-
 net/netfilter/Makefile                     |    2 +-
 net/netfilter/ipset/ip_set_hash_netiface.c |   32 +++-
 net/netfilter/nf_log_common.c              |    5 +-
 net/netfilter/nf_queue.c                   |   18 ++-
 net/netfilter/nf_tables_api.c              |  186 +++++++++++++++++++++---
 net/netfilter/nf_tables_core.c             |    7 +
 net/netfilter/nfnetlink_log.c              |   17 ++-
 net/netfilter/nfnetlink_queue_core.c       |   28 ++--
 net/netfilter/nft_dynset.c                 |  218 ++++++++++++++++++++++++++++
 net/netfilter/nft_hash.c                   |  117 ++++++++++++++-
 net/netfilter/nft_lookup.c                 |    2 +
 net/netfilter/nft_meta.c                   |    5 +-
 net/netfilter/xt_cgroup.c                  |    2 +-
 net/netfilter/xt_physdev.c                 |   34 +++--
 net/netfilter/xt_socket.c                  |   95 ++++++------
 23 files changed, 973 insertions(+), 180 deletions(-)
 create mode 100644 net/netfilter/nft_dynset.c
