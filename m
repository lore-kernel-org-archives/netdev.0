From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH net-next 1/3] net/mlx4_en: use READ_ONCE when freeing xdp_prog
Date: Wed, 20 Jul 2016 17:22:33 -0700
Message-ID: <1469060555-20250-2-git-send-email-bblanco@plumgrid.com>
References: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36413 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646AbcGUAXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 20:23:07 -0400
Received: by mail-pa0-f43.google.com with SMTP id pp5so22901193pac.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 17:23:07 -0700 (PDT)
In-Reply-To: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For consistency, and in order to hint at the synchronous nature of the
xdp_prog field, use READ_ONCE in the destroy path of the ring. All
occurrences should now use either READ_ONCE or xchg.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 11d88c8..a02dec6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -535,9 +535,11 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring = *pring;
+	struct bpf_prog *old_prog;
 
-	if (ring->xdp_prog)
-		bpf_prog_put(ring->xdp_prog);
+	old_prog = READ_ONCE(ring->xdp_prog);
+	if (old_prog)
+		bpf_prog_put(old_prog);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
-- 
2.8.2
