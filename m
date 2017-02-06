From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH net] mlx4: Invoke softirqs after napi_reschedule
Date: Mon,  6 Feb 2017 09:10:46 -0800
Message-ID: <20170206171046.3765-1-bpoirier@suse.com>
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        linux-rdma@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33822 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdBFRLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 12:11:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4 may schedule napi from a workqueue. Afterwards, softirqs are not run
in a deterministic time frame and the following message may be logged:
NOHZ: local_softirq_pending 08

The problem is the same as what was described in commit ec13ee80145c
("virtio_net: invoke softirqs after __napi_schedule") and this patch
applies the same fix to mlx4.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index eac527e25ec9..14ce1549b638 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -513,10 +513,12 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
 	if (!priv->port_up)
 		return;
 
+	local_bh_disable();
 	for (ring = 0; ring < priv->rx_ring_num; ring++) {
 		if (mlx4_en_is_ring_empty(priv->rx_ring[ring]))
 			napi_reschedule(&priv->rx_cq[ring]->napi);
 	}
+	local_bh_enable();
 }
 
 /* When the rx ring is running in page-per-packet mode, a released frame can go
-- 
2.11.0
