From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH net] net/mlx4_en: fixup xdp tx irq to match rx
Date: Thu, 13 Oct 2016 13:13:11 -0700
Message-ID: <20161013201311.20844-1-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34793 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752883AbcJMUNZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 16:13:25 -0400
Received: by mail-pf0-f170.google.com with SMTP id r16so15784970pfg.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 13:13:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In cases where the number of tx rings is not a multiple of the number of
rx rings, the tx completion event will be handled on a different core
from the transmit and population of the ring. Races on the ring will
lead to a double-free of the page, and possibly other corruption.

The rings are initialized by default with a valid multiple of rings,
based on the number of cpus, therefore an invalid configuration requires
ethtool to change the ring layout. For instance 'ethtool -L eth0 rx 9 tx
8' will cause packets received on rx0, and XDP_TX'd to tx48, to be
completed on cpu3 (48 % 9 == 3).

Resolve this discrepancy by shifting the irq for the xdp tx queues to
start again from 0, modulo rx_ring_num.

Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 132cea6..e3be7e4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -127,7 +127,15 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		/* For TX we use the same irq per
 		ring we assigned for the RX    */
 		struct mlx4_en_cq *rx_cq;
-
+		int xdp_index;
+
+		/* The xdp tx irq must align with the rx ring that forwards to
+		 * it, so reindex these from 0. This should only happen when
+		 * tx_ring_num is not a multiple of rx_ring_num.
+		 */
+		xdp_index = (priv->xdp_ring_num - priv->tx_ring_num) + cq_idx;
+		if (xdp_index >= 0)
+			cq_idx = xdp_index;
 		cq_idx = cq_idx % priv->rx_ring_num;
 		rx_cq = priv->rx_cq[cq_idx];
 		cq->vector = rx_cq->vector;
-- 
2.9.3
