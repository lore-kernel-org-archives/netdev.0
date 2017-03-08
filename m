From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 00/13] mlx4: order-0 allocations and page recycling
Date: Wed,  8 Mar 2017 08:17:05 -0800
Message-ID: <20170308161718.2867-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34445 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbdCHQRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:23 -0500
Received: by mail-pg0-f54.google.com with SMTP id 77so14838234pgc.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mentioned half a year ago, we better switch mlx4 driver to order-0
allocations and page recycling.

This reduces vulnerability surface thanks to better skb->truesize
tracking and provides better performance in most cases.
(33 Gbit for one TCP flow on my lab hosts)

I will provide for linux-4.13 a patch on top of this series,
trying to improve data locality as described in
https://www.spinics.net/lists/netdev/msg422258.html

v2 provides an ethtool -S new counter (rx_alloc_pages) and
code factorization, plus Tariq fix.

v3 includes various fixes based on Tariq tests and feedback
from Saeed and Tariq.

v4 rebased on net-next for inclusion in linux-4.12, as requested
by Tariq.

Worth noting this patch series deletes ~250 lines of code ;)

Eric Dumazet (13):
  mlx4: dma_dir is a mlx4_en_priv attribute
  mlx4: remove order field from mlx4_en_frag_info
  mlx4: get rid of frag_prefix_size
  mlx4: rx_headroom is a per port attribute
  mlx4: reduce rx ring page_cache size
  mlx4: removal of frag_sizes[]
  mlx4: use order-0 pages for RX
  mlx4: add page recycling in receive path
  mlx4: add rx_alloc_pages counter in ethtool -S
  mlx4: do not access rx_desc from mlx4_en_process_rx_cq()
  mlx4: factorize page_address() calls
  mlx4: make validate_loopback() more generic
  mlx4: remove duplicate code in mlx4_en_process_rx_cq()

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c     |   2 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       | 607 +++++++----------------
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |   6 -
 drivers/net/ethernet/mellanox/mlx4/en_tx.c       |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |  30 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h  |   2 +-
 7 files changed, 201 insertions(+), 452 deletions(-)

-- 
2.12.0.246.ga2ecc84866-goog
