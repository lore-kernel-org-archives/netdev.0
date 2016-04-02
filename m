From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Fri,  1 Apr 2016 18:21:53 -0700
Message-ID: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	gerlitz@mellanox.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, brouer@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36399 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877AbcDBBWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 21:22:12 -0400
Received: by mail-pf0-f181.google.com with SMTP id e128so81002288pfe.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 18:22:12 -0700 (PDT)
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
achieved ~14.5 Mpps drop rate on a 40G mlx4. This includes packet data
access, bpf array lookup, and increment.

Interestingly, accessing packet data from the program did not have a
noticeable impact on performance. Even so, future enhancements to
prefetching / batching / page-allocs should hopefully improve the
performance in this path.

[1] https://github.com/iovisor/bpf-docs/blob/master/Express_Data_Path.pdf

Brenden Blanco (5):
  bpf: add PHYS_DEV prog type for early driver filter
  net: add ndo to set bpf prog in adapter rx
  rtnl: add option for setting link bpf prog
  mlx4: add support for fast rx drop bpf program
  Add sample for adding simple drop program to link

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  61 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  18 +++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |   2 +
 include/linux/netdevice.h                      |   8 ++
 include/uapi/linux/bpf.h                       |   5 +
 include/uapi/linux/if_link.h                   |   1 +
 kernel/bpf/verifier.c                          |   1 +
 net/core/dev.c                                 |  12 ++
 net/core/filter.c                              |  68 +++++++++++
 net/core/rtnetlink.c                           |  10 ++
 samples/bpf/Makefile                           |   4 +
 samples/bpf/bpf_load.c                         |   8 ++
 samples/bpf/netdrvx1_kern.c                    |  26 +++++
 samples/bpf/netdrvx1_user.c                    | 155 +++++++++++++++++++++++++
 14 files changed, 379 insertions(+)
 create mode 100644 samples/bpf/netdrvx1_kern.c
 create mode 100644 samples/bpf/netdrvx1_user.c

-- 
2.8.0
