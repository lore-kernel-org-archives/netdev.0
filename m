From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 01/12] ixgbe: NULL xdp_tx rings on resource cleanup
Date: Mon, 17 Jul 2017 09:26:24 -0700
Message-ID: <20170717162624.24315.64344.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35048 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQQ0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:26:39 -0400
Received: by mail-pg0-f68.google.com with SMTP id d193so19996462pgc.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:26:39 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx_rings and rx_rings are cleaned up on close paths in ixgbe driver
however, xdp_rings are not. Set the xdp_rings to NULL here so that
we can use the pointer to indicate if the XDP rings are initialized.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index b45fdc9..f1bfae0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -1018,8 +1018,12 @@ static void ixgbe_free_q_vector(struct ixgbe_adapter *adapter, int v_idx)
 	struct ixgbe_q_vector *q_vector = adapter->q_vector[v_idx];
 	struct ixgbe_ring *ring;
 
-	ixgbe_for_each_ring(ring, q_vector->tx)
-		adapter->tx_ring[ring->queue_index] = NULL;
+	ixgbe_for_each_ring(ring, q_vector->tx) {
+		if (ring_is_xdp(ring))
+			adapter->xdp_ring[ring->queue_index] = NULL;
+		else
+			adapter->tx_ring[ring->queue_index] = NULL;
+	}
 
 	ixgbe_for_each_ring(ring, q_vector->rx)
 		adapter->rx_ring[ring->queue_index] = NULL;
