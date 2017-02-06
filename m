From: Benjamin Poirier <bpoirier-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH net v2] mlx4: Invoke softirqs after napi_reschedule
Date: Mon,  6 Feb 2017 10:14:31 -0800
Message-ID: <20170206181431.9664-1-bpoirier@suse.com>
References: <1486403641.7793.43.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486403641.7793.43.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

mlx4 may schedule napi from a workqueue. Afterwards, softirqs are not run
in a deterministic time frame and the following message may be logged:
NOHZ: local_softirq_pending 08

The problem is the same as what was described in commit ec13ee80145c
("virtio_net: invoke softirqs after __napi_schedule") and this patch
applies the same fix to mlx4.

Fixes: 07841f9d94c1 ("net/mlx4_en: Schedule napi when RX buffers allocation fails")
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Benjamin Poirier <bpoirier-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index eac527e25ec9..cc003fdf0ed9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -514,8 +514,11 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
 		return;
 
 	for (ring = 0; ring < priv->rx_ring_num; ring++) {
-		if (mlx4_en_is_ring_empty(priv->rx_ring[ring]))
+		if (mlx4_en_is_ring_empty(priv->rx_ring[ring])) {
+			local_bh_disable();
 			napi_reschedule(&priv->rx_cq[ring]->napi);
+			local_bh_enable();
+		}
 	}
 }
 
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
