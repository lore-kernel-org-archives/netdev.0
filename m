From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/6] net/mlx5e: Fix XDP error path of mlx5e_open_channel()
Date: Fri,  4 Nov 2016 01:48:42 +0200
Message-ID: <1478216927-31328-2-git-send-email-saeedm@mellanox.com>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37677 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933616AbcKCXuO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:14 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of mlx5e_open_rq fails the error handling will jump to
label err_close_xdp_sq and will try to close the xdp_sq unconditionally.
xdp_sq is valid only in case of XDP use cases, i.e priv->xdp_prog is
not null.

To fix this in this patch we test xdp_sq validity prior to closing it.

In addition we now close the xdp_sq.cq as well.

Fixes: b5503b994ed5 ("net/mlx5e: XDP TX forwarding support")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f4c687c..c83619d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1512,7 +1512,10 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 	return 0;
 err_close_xdp_sq:
-	mlx5e_close_sq(&c->xdp_sq);
+	if (priv->xdp_prog) {
+		mlx5e_close_sq(&c->xdp_sq);
+		mlx5e_close_cq(&c->xdp_sq.cq);
+	}
 
 err_close_sqs:
 	mlx5e_close_sqs(c);
-- 
2.7.4
