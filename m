From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 00/14] net/mlx4_en: Optimizations to TX flow
Date: Sun,  5 Oct 2014 12:35:08 +0300
Message-ID: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52644 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751019AbaJEJfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 05:35:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset contains optimizations to TX flow in mlx4_en driver. It also introduce
setting/getting tx copybreak, to enable controlling inline threshold dynamically.

TX flow optimizations was authored and posted to the mailing list by Eric
Dumazet [1] as a single patch. I splitted this patch to smaller patches,
Reviewed it and tested.
Changed from original patch:
- s/iowrite32be/iowrite32/, since ring->doorbell_qpn is stored as be32

The tx copybreak patch was also suggested by Eric Dumazet, and was edited and
reviewed by me. User space patch will be sent after kernel code is ready.

I am sending this patchset now since the merge window is near and don't want to
miss it.

More work need to do:
- Disable BF when xmit_more is in use
- Make TSO use xmit_more too. Maybe by splitting small TSO packets in the
  driver itself, to avoid extra cpu/memory costs of GSO before the driver
- Fix mlx4_en_xmit buggy handling of queue full in the middle of a burst
  partially posted to send queue using xmit_more

Eric, I edited the patches to have you as the Author and the first
signed-off-by. I hope it is ok with you (I wasn't sure if it is ok to sign by
you), anyway all the credit to those changes should go to you.

Patchset was tested and applied over commit 1e203c1 "(net: sched:
suspicious RCU usage in qdisc_watchdog")

[1] - https://patchwork.ozlabs.org/patch/394256/

Thanks,
Amir

Amir Vadai (13):
  net/mlx4_en: Code cleanups in tx path
  net/mlx4_en: Align tx path structures to cache lines
  net/mlx4_en: Avoid calling bswap in tx fast path
  net/mlx4_en: tx_info allocated with kmalloc() instead of vmalloc()
  net/mlx4_en: Avoid a cache line miss in TX completion for single frag
    skb's
  net/mlx4_en: Use prefetch in tx path
  net/mlx4_en: Avoid false sharing in mlx4_en_en_process_tx_cq()
  net/mlx4_en: mlx4_en_xmit() reads ring->cons once, and ahead of time
    to avoid stalls
  net/mlx4_en: Use local var in tx flow for skb_shinfo(skb)
  net/mlx4_en: Use local var for skb_headlen(skb)
  net/mlx4_en: tx_info->ts_requested was not cleared
  net/mlx4_en: Enable the compiler to make is_inline() inlined
  ethtool: Ethtool parameter to dynamically change tx_copybreak

Eric Dumazet (1):
  net/mlx4_en: Use the new tx_copybreak to set inline threshold

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  44 ++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 330 ++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  90 ++++---
 include/linux/mlx4/device.h                     |   2 +-
 include/uapi/linux/ethtool.h                    |   1 +
 net/core/ethtool.c                              |   1 +
 6 files changed, 290 insertions(+), 178 deletions(-)

-- 
1.8.3.4
