From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH v2 0/5] Add driver bpf hook for early packet drop
Date: Thu,  7 Apr 2016 21:47:54 -0700
Message-ID: <1460090874-10497-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	ogerlitz@mellanox.com, daniel@iogearbox.net, brouer@redhat.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33041 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbcDHEsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 00:48:05 -0400
Received: by mail-pf0-f176.google.com with SMTP id 184so69154187pff.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 21:48:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces new infrastructure for programmatically
processing packets in the earliest stages of rx, as part of an effort
others are calling Express Data Path (XDP) [1]. Start this effort by
introducing a new bpf program type for early packet filtering, before even
an skb has been allocated.

With this, hope to enable line rate filtering, with this initial
implementation providing drop/allow action only.

Patch 1 introduces the new prog type and helpers for validating the bpf
program. A new userspace struct is defined containing only len as a field,
with others to follow in the future.
In patch 2, create a new ndo to pass the fd to support drivers. 
In patch 3, expose a new rtnl option to userspace.
In patch 4, enable support in mlx4 driver. No skb allocation is required,
instead a static percpu skb is kept in the driver and minimally initialized
for each driver frag.
In patch 5, create a sample drop and count program. With single core,
achieved ~20 Mpps drop rate on a 40G mlx4. This includes packet data
access, bpf array lookup, and increment.

Interestingly, accessing packet data from the program did not have a
noticeable impact on performance. Even so, future enhancements to
prefetching / batching / page-allocs should hopefully improve the
performance in this path.

[1] https://github.com/iovisor/bpf-docs/blob/master/Express_Data_Path.pdf

v2:
  1/5: Drop xdp from types, instead consistently use bpf_phys_dev_.
    Introduce enum for return values from phys_dev hook.
  2/5: Move prog->type check to just before invoking ndo.
    Change ndo to take a bpf_prog * instead of fd.
    Add ndo_bpf_get rather than keeping a bool in the netdev struct.
  3/5: Use ndo_bpf_get to fetch bool.
  4/5: Enforce that only 1 frag is ever given to bpf prog by disallowing
    mtu to increase beyond FRAG_SZ0 when bpf prog is running, or conversely
    to set a bpf prog when priv->num_frags > 1.
    Rename pseudo_skb to bpf_phys_dev_md.
    Implement ndo_bpf_get.
    Add dma sync just before invoking prog.
    Check for explicit bpf return code rather than nonzero.
    Remove increment of rx_dropped.
  5/5: Use explicit bpf return code in example.
    Update commit log with higher pps numbers.

Brenden Blanco (5):
  bpf: add PHYS_DEV prog type for early driver filter
  net: add ndo to set bpf prog in adapter rx
  rtnl: add option for setting link bpf prog
  mlx4: add support for fast rx drop bpf program
  Add sample for adding simple drop program to link

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  65 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  25 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   6 +
 include/linux/netdevice.h                      |  13 +++
 include/uapi/linux/bpf.h                       |  14 +++
 include/uapi/linux/if_link.h                   |   1 +
 kernel/bpf/verifier.c                          |   1 +
 net/core/dev.c                                 |  38 ++++++
 net/core/filter.c                              |  68 +++++++++++
 net/core/rtnetlink.c                           |  12 ++
 samples/bpf/Makefile                           |   4 +
 samples/bpf/bpf_load.c                         |   8 ++
 samples/bpf/netdrvx1_kern.c                    |  26 +++++
 samples/bpf/netdrvx1_user.c                    | 155 +++++++++++++++++++++++++
 14 files changed, 432 insertions(+), 4 deletions(-)
 create mode 100644 samples/bpf/netdrvx1_kern.c
 create mode 100644 samples/bpf/netdrvx1_user.c

-- 
2.8.0
