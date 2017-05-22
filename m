From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 22 May 2017 15:34:29 -0400 (EDT)
Message-ID: <20170522.153429.2080376783094628613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mostly netfilter bug fixes in here, but we have some bits elsewhere
as well.

1) Don't do SNAT replies for non-NATed connections in IPVS, from Julian
   Anastasov.

2) Don't delete conntrack helpers while they are still in use, from
   Liping Zhang.

3) Fix zero padding in xtables's xt_data_to_user(), from Willem de
   Bruijn.

4) Add proper RCU protection to nf_tables_dump_set() because we cannot
   guarantee that we hold the NFNL_SUBSYS_NFTABLES lock.  From Liping
   Zhang.

5) Initialize rcv_mss in tcp_disconnect(), from Wei Wang.

6) smsc95xx devices can't handle IPV6 checksums fully, so don't
   advertise support for offloading them.  From Nisar Sayed.

7) Fix out-of-bounds access in __ip6_append_data(), from Eric Dumazet.

8) Make atl2_probe() propagate the error code properly on failures,
   from Alexey Khoroshilov.

9) arp_target[] in bond_check_params() is used uninitialized.  This got
   changes from a global static to a local variable, which is how this
   mistake happened.  Fix from Jarod Wilson.

10) Fix fallout from unnecessary NULL check removal in cls_matchall,
    from Jiri Pirko.  This is definitely brown paper bag territory...

Please pull, thanks a lot!

The following changes since commit 8b4822de59d5d9919b9b045183a36c673ce20b73:

  Merge tag 'md/4.12-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/shli/md (2017-05-18 12:04:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 2d76b2f8b54abd16225cd80afca36ed43f113c41:

  net: sched: cls_matchall: fix null pointer dereference (2017-05-22 14:54:16 -0400)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      net: atheros: atl2: don't return zero on failure path in atl2_probe()

David S. Miller (3):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'arp-always-override-existing-neigh-entries-with-gratuitous-ARP'
      net: Make IP alignment calulations clearer.

Eric Dumazet (1):
      ipv6: fix out of bound writes in __ip6_append_data()

Eric Leblond (1):
      netfilter: synproxy: fix conntrackd interaction

Gao Feng (1):
      ebtables: arpreply: Add the standard target sanity check

Ihar Hrachyshka (4):
      arp: fixed error in a comment
      arp: decompose is_garp logic into a separate function
      arp: postpone addr_type calculation to as late as possible
      arp: always override existing neigh entries with gratuitous ARP

Jarod Wilson (2):
      bonding: fix accounting of active ports in 3ad
      bonding: fix randomly populated arp target array

Jiri Pirko (1):
      net: sched: cls_matchall: fix null pointer dereference

Julian Anastasov (1):
      ipvs: SNAT packet replies only for NATed connections

Liping Zhang (4):
      netfilter: don't setup nat info for confirmed ct
      netfilter: introduce nf_conntrack_helper_put helper function
      netfilter: nfnl_cthelper: reject del request if helper obj is in use
      netfilter: nf_tables: can't assume lock is acquired when dumping set elems

Matthias Kaehlcke (1):
      netfilter: ctnetlink: Make some parameters integer to avoid enum mismatch

Nisar Sayed (1):
      smsc95xx: Support only IPv4 TCP/UDP csum offload

Pablo Neira Ayuso (3):
      Merge tag 'ipvs-fixes-for-v4.12' of http://git.kernel.org/.../horms/ipvs
      netfilter: nf_tables: missing sanitization in data from userspace
      netfilter: nf_tables: revisit chain/object refcounting from elements

WANG Cong (1):
      vsock: use new wait API for vsock_stream_sendmsg()

Wei Wang (1):
      tcp: initialize rcv_mss to TCP_MIN_MSS instead of 0

Willem de Bruijn (2):
      netfilter: xtables: zero padding in data_to_user
      netfilter: xtables: fix build failure from COMPAT_XT_ALIGN outside CONFIG_COMPAT

Xin Long (1):
      bridge: start hello_timer when enabling KERNEL_STP in br_stp_start

 drivers/net/bonding/bond_3ad.c              |   2 +-
 drivers/net/bonding/bond_main.c             |   5 ++--
 drivers/net/ethernet/atheros/atlx/atl2.c    |   8 +++---
 drivers/net/usb/smsc95xx.c                  |  13 ++++++---
 include/linux/netfilter/x_tables.h          |   2 +-
 include/linux/netfilter_bridge/ebtables.h   |   5 ++++
 include/net/netfilter/nf_conntrack_helper.h |   4 +++
 include/net/netfilter/nf_tables.h           |   2 +-
 kernel/bpf/verifier.c                       |  12 ++++++---
 net/bridge/br_stp_if.c                      |   1 +
 net/bridge/br_stp_timer.c                   |   2 +-
 net/bridge/netfilter/ebt_arpreply.c         |   3 +++
 net/bridge/netfilter/ebtables.c             |   9 ++++---
 net/ipv4/arp.c                              |  56 +++++++++++++++++++++++++++------------
 net/ipv4/tcp.c                              |   4 +++
 net/ipv6/ip6_output.c                       |  15 ++++++-----
 net/netfilter/ipvs/ip_vs_core.c             |  19 ++++++++++----
 net/netfilter/nf_conntrack_helper.c         |  12 +++++++++
 net/netfilter/nf_conntrack_netlink.c        |  11 +++++---
 net/netfilter/nf_nat_core.c                 |   4 +++
 net/netfilter/nf_tables_api.c               | 160 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------
 net/netfilter/nfnetlink_cthelper.c          |  17 +++++++-----
 net/netfilter/nft_bitwise.c                 |  19 ++++++++++----
 net/netfilter/nft_cmp.c                     |  12 +++++++--
 net/netfilter/nft_ct.c                      |   4 +--
 net/netfilter/nft_immediate.c               |   5 ++--
 net/netfilter/nft_range.c                   |   4 +--
 net/netfilter/nft_set_hash.c                |   2 +-
 net/netfilter/x_tables.c                    |  24 +++++++++++------
 net/netfilter/xt_CT.c                       |   6 ++---
 net/openvswitch/conntrack.c                 |   4 +--
 net/sched/cls_matchall.c                    |   1 -
 net/vmw_vsock/af_vsock.c                    |  21 ++++++---------
 33 files changed, 335 insertions(+), 133 deletions(-)
