From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/7] net: bulk alloc side and more bulk free drivers
Date: Fri, 04 Mar 2016 14:01:14 +0100
Message-ID: <20160304130054.32651.51776.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbcCDNBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 08:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset use the bulk ALLOC side of the kmem_cache bulk APIs, for
SKB allocations.  The bulk free side got enabled in merge commit
3134b9f019f2 ("net: mitigating kmem_cache free slowpath").

The first two patches is a followup on the free-side, which enables
bulk-free in the drivers mlx4 and mlx5 (dev_kfree_skb -> napi_consume_skb).

Rest of patchset is focused on bulk alloc-side.  We start with a
conservative bulk alloc of 8 SKB, which all drivers using the
napi_alloc_skb() call will benefit from.  Then the API is extended to,
allow driver hinting on needed SKBs (only some drivers know this
size), and mlx5 driver is the first user of hinting.

Small hint for people wanting to tune their systems. Default number of
SKB objects per slab-page is 32 objects.  This limits the bulking
sizes for the SLUB allocator.  SLUB can be tuned via kernel cmdline
boot option slub_min_objects=128.  Increasing this gives a significant
performance boost, but at the cost of more memory "waste" inside
kmem_cache/slab allocator.

Patchset based on net-next at commit 3ebeac1d0295

---

Jesper Dangaard Brouer (7):
      mlx5: use napi_consume_skb API to get bulk free operations
      mlx4: use napi_consume_skb API to get bulk free operations
      net: bulk alloc and reuse of SKBs in NAPI context
      mlx5: use napi_alloc_skb API to get SKB bulk allocations
      mlx4: use napi_alloc_skb API to get SKB bulk allocations
      net: introduce napi_alloc_skb_hint() for more use-cases
      mlx5: hint the NAPI alloc skb API about the expected bulk size


 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |    7 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   19 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    5 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   11 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    4 +
 include/linux/skbuff.h                            |   19 ++++-
 net/core/skbuff.c                                 |   75 +++++++++++++--------
 8 files changed, 92 insertions(+), 52 deletions(-)
