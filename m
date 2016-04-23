From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net/mlx4_en: fix spurious timestamping callbacks
Date: Sat, 23 Apr 2016 11:35:46 -0700
Message-ID: <1461436546.7627.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38112 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcDWSfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 14:35:50 -0400
Received: by mail-ig0-f174.google.com with SMTP id m9so37420009ige.1
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:35:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When multiple skb are TX-completed in a row, we might incorrectly keep
a timestamp of a prior skb and cause extra work.

Fixes: ec693d47010e8 ("net/mlx4_en: Add HW timestamping (TS) support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c0d7b7296236..a386f047c1af 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -405,7 +405,6 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	u32 packets = 0;
 	u32 bytes = 0;
 	int factor = priv->cqe_factor;
-	u64 timestamp = 0;
 	int done = 0;
 	int budget = priv->tx_work_limit;
 	u32 last_nr_txbb;
@@ -445,9 +444,12 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		new_index = be16_to_cpu(cqe->wqe_index) & size_mask;
 
 		do {
+			u64 timestamp = 0;
+
 			txbbs_skipped += last_nr_txbb;
 			ring_index = (ring_index + last_nr_txbb) & size_mask;
-			if (ring->tx_info[ring_index].ts_requested)
+
+			if (unlikely(ring->tx_info[ring_index].ts_requested))
 				timestamp = mlx4_en_get_cqe_ts(cqe);
 
 			/* free next descriptor */
