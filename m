From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Wed, 18 Jan 2017 23:03:08 -0800
Message-ID: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35063 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdASHDL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 02:03:11 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so3428570pge.2
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 23:03:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A driver using dev_alloc_page() must not reuse a page allocated from
emergency memory reserve.

Otherwise all packets using this page will be immediately dropped,
unless for very specific sockets having SOCK_MEMALLOC bit set.

This issue might be hard to debug, because only a fraction of received
packets would be dropped.

Fixes: 4415a0319f92 ("net/mlx5e: Implement RX mapped page cache for page recycle")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 0e2fb3ed1790900ccdc0bbbef8bc5c33267df092..ce46409bde2736ea4d1246ca97855098f052f271 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -193,6 +193,9 @@ static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
 		return false;
 	}
 
+	if (unlikely(page_is_pfmemalloc(dma_info->page)))
+		return false;
+
 	cache->page_cache[cache->tail] = *dma_info;
 	cache->tail = tail_next;
 	return true;
