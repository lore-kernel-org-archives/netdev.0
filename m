From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v8 00/11] Add driver bpf hook for early packet drop and forwarding
Date: Tue, 12 Jul 2016 00:51:23 -0700
Message-ID: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35359 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcGLHwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 03:52:31 -0400
Received: by mail-pf0-f170.google.com with SMTP id c2so4333590pfa.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 00:52:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces new infrastructure for programmatically
processing packets in the earliest stages of rx, as part of an effort
others are calling eXpress Data Path (XDP) [1]. Start this effort by
introducing a new bpf program type for early packet filtering, before
even an skb has been allocated.

Extend on this with the ability to modify packet data and send back out
on the same port.

Patch 1 introduces the new prog type and helpers for validating the bpf
  program. A new userspace struct is defined containing only data and
  data_end as fields, with others to follow in the future.
In patch 2, create a new ndo to pass the fd to supported drivers.
In patch 3, expose a new rtnl option to userspace.
In patch 4, enable support in mlx4 driver.
In patch 5, create a sample drop and count program. With single core,
  achieved ~20 Mpps drop rate on a 40G ConnectX3-Pro. This includes
  packet data access, bpf array lookup, and increment.
In patch 6, add a page recycle facility to mlx4 rx, enabled when xdp is
  active.
In patch 7, add the XDP_TX type to bpf.h
In patch 8, add helper in tx patch for writing tx_desc
In patch 9, add support in mlx4 for packet data write and forwarding
In patch 10, turn on packet write support in the bpf verifier
In patch 11, add a sample program for packet write and forwarding. With
  single core, achieved ~10 Mpps rewrite and forwarding.

[1] https://github.com/iovisor/bpf-docs/blob/master/Express_Data_Path.pdf

v8:
 1/11: Reduce WARN_ONCE to single line. Also, change act param of that
   function to u32 to match return type of bpf_prog_run_xdp.
 2/11: Clarify locking semantics in ndo comment.
 4/11: Add en_err warning in mlx4_xdp_set on num_frags/mtu violation.

v7:
 Addressing two of the major discussion points: return codes and ndo.
 The rest will be taken as todo items for separate patches.

 Add an XDP_ABORTED type, which explicitly falls through to DROP. The
 same result must be taken for the default case as well, as it is now
 well-defined API behavior.

 Merge ndo_xdp_* into a single ndo. The style is similar to
 ndo_setup_tc, but with less unidirectional naming convention. The IFLA
 parameter names are unchanged.

 TODOs:
 Add ethtool per-ring stats for aborted, default cases, maybe even drop
 and tx as well.
 Avoid duplicate dma sync operation in XDP_PASS case as mentioned by
 Saeed.

  1/12: Add XDP_ABORTED enum, reword API comment, and update commit
   message.
  2/12: Rewrite ndo_xdp_*() into single ndo_xdp() with type/union style
    calling convention.
  3/12: Switch to ndo_xdp callback.
  4/12: Add XDP_ABORTED case as a fall-through to XDP_DROP. Implement
    ndo_xdp.
 12/12: Dropped, this will need some more work.

v6:
  2/12: drop unnecessary netif_device_present check
  4/12, 6/12, 9/12: Reorder default case statement above drop case to
    remove some copy/paste.

v5:
  0/12: Rebase and remove previous 1/13 patch
  1/12: Fix nits from Daniel. Left the (void *) cast as-is, to be fixed
    in future. Add bpf_warn_invalid_xdp_action() helper, to be used when
    out of bounds action is returned by the program. Add a comment to
    bpf.h denoting the undefined nature of out of bounds returns.
  2/12: Switch to using bpf_prog_get_type(). Rename ndo_xdp_get() to
    ndo_xdp_attached().
  3/12: Add IFLA_XDP as a nested type, and add the associated nla_policy
    for the new subtypes IFLA_XDP_FD and IFLA_XDP_ATTACHED.
  4/12: Fixup the use of READ_ONCE in the ndos. Add a user of
    bpf_warn_invalid_xdp_action helper.
  5/12: Adjust to using the nested netlink options.
  6/12: kbuild was complaining about overflow of u16 on tile
    architecture...bump frag_stride to u32. The page_offset member that
    is computed from this was already u32.

v4:
  2/12: Add inline helper for calling xdp bpf prog under rcu
  3/12: Add detail to ndo comments
  5/12: Remove mlx4_call_xdp and use inline helper instead.
  6/12: Fix checkpatch complaints
  9/12: Introduce new patch 9/12 with common helper for tx_desc write
    Refactor to use common tx_desc write helper
 11/12: Fix checkpatch complaints

v3:
  Rewrite from v2 trying to incorporate feedback from multiple sources.
  Specifically, add ability to forward packets out the same port and
    allow packet modification.
  For packet forwarding, the driver reserves a dedicated set of tx rings
    for exclusive use by xdp. Upon completion, the pages on this ring are
    recycled directly back to a small per-rx-ring page cache without
    being dma unmapped.
  Use of the percpu skb is dropped in favor of a lightweight struct
    xdp_buff. The direct packet access feature is leveraged to remove
    dependence on the skb.
  The mlx4 driver implementation allocates a page-per-packet and maps it
    in PCI_DMA_BIDIRECTIONAL mode when the bpf program is activated.
  Naming is converted to use "xdp" instead of "phys_dev".

v2:
  1/5: Drop xdp from types, instead consistently use bpf_phys_dev_
    Introduce enum for return values from phys_dev hook
  2/5: Move prog->type check to just before invoking ndo
    Change ndo to take a bpf_prog * instead of fd
    Add ndo_bpf_get rather than keeping a bool in the netdev struct
  3/5: Use ndo_bpf_get to fetch bool
  4/5: Enforce that only 1 frag is ever given to bpf prog by disallowing
    mtu to increase beyond FRAG_SZ0 when bpf prog is running, or conversely
    to set a bpf prog when priv->num_frags > 1
    Rename pseudo_skb to bpf_phys_dev_md
    Implement ndo_bpf_get
    Add dma sync just before invoking prog
    Check for explicit bpf return code rather than nonzero
    Remove increment of rx_dropped
  5/5: Use explicit bpf return code in example
    Update commit log with higher pps numbers

Brenden Blanco (11):
  bpf: add XDP prog type for early driver filter
  net: add ndo to setup/query xdp prog in adapter rx
  rtnl: add option for setting link xdp prog
  net/mlx4_en: add support for fast rx drop bpf program
  Add sample for adding simple drop program to link
  net/mlx4_en: add page recycle to prepare rx ring for tx support
  bpf: add XDP_TX xdp_action for direct forwarding
  net/mlx4_en: break out tx_desc write into separate function
  net/mlx4_en: add xdp forwarding and data write support
  bpf: enable direct packet data write for xdp progs
  bpf: add sample for xdp forwarding and rewrite

 drivers/infiniband/hw/mlx4/qp.c                 |  11 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  17 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 108 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 120 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 253 +++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  31 ++-
 include/linux/filter.h                          |  18 ++
 include/linux/mlx4/qp.h                         |  18 +-
 include/linux/netdevice.h                       |  34 ++++
 include/uapi/linux/bpf.h                        |  21 ++
 include/uapi/linux/if_link.h                    |  12 ++
 kernel/bpf/verifier.c                           |  18 +-
 net/core/dev.c                                  |  33 ++++
 net/core/filter.c                               |  79 ++++++++
 net/core/rtnetlink.c                            |  64 ++++++
 samples/bpf/Makefile                            |   9 +
 samples/bpf/bpf_load.c                          |   8 +
 samples/bpf/xdp1_kern.c                         |  93 +++++++++
 samples/bpf/xdp1_user.c                         | 181 +++++++++++++++++
 samples/bpf/xdp2_kern.c                         | 114 +++++++++++
 20 files changed, 1154 insertions(+), 88 deletions(-)
 create mode 100644 samples/bpf/xdp1_kern.c
 create mode 100644 samples/bpf/xdp1_user.c
 create mode 100644 samples/bpf/xdp2_kern.c

-- 
2.8.2
