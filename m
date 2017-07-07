From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 01/12] ixgbe: NULL xdp_tx rings on resource cleanup
Date: Fri, 07 Jul 2017 10:34:40 -0700
Message-ID: <20170707173440.9984.29957.stgit@john-Precision-Tower-5810>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, john.fastabend@gmail.com, andy@greyhouse.net,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36146 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdGGRe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 13:34:56 -0400
Received: by mail-pg0-f67.google.com with SMTP id u36so4798173pgn.3
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 10:34:55 -0700 (PDT)
In-Reply-To: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx_rings and rx_rings are cleaned up on close paths in ixgbe driver
however, xdp_rings are not. Set the xdp_rings to NULL here so that
we can use the pointer to indicate if the XDP rings are initialized.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
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
