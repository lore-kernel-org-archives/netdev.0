From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx4_en: Adjust RX frag strides to frag sizes
Date: Tue,  3 Feb 2015 17:57:20 +0200
Message-ID: <1422979041-25208-7-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40322 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966308AbbBCP6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:37 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This patch improves memory utilization and therefore the packets rate
for special MTU's. Instead of setting the frag_stride to the maximal
hard coded frag_size, use the actual frag_size that is set according to
the MTU, when setting the stride of the last frag.
So, for example, for MTU 1600, where the frag_size of the 2nd frag is
86, the frag_size is set to 128 instead of 4096. See below:

Before:
 frag:0 - size:1536 prefix:0 stride:1536
 frag:1 - size:86 prefix:1536 stride:4096

 frag 0 allocator: - size:32768 frags:21
 frag 1 allocator: - size:32768 frags:8

After:
 frag:0 - size:1536 prefix:0 stride:1536
 frag:1 - size:86 prefix:1536 stride:128

 frag 0 allocator: - size:32768 frags:21
 frag 1 allocator: - size:32768 frags:256

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 30a2203..698d60d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1063,8 +1063,9 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 			(eff_mtu > buf_size + frag_sizes[i]) ?
 				frag_sizes[i] : eff_mtu - buf_size;
 		priv->frag_info[i].frag_prefix_size = buf_size;
-		priv->frag_info[i].frag_stride = ALIGN(frag_sizes[i],
-						       SMP_CACHE_BYTES);
+		priv->frag_info[i].frag_stride =
+				ALIGN(priv->frag_info[i].frag_size,
+				      SMP_CACHE_BYTES);
 		buf_size += priv->frag_info[i].frag_size;
 		i++;
 	}
-- 
1.9.3
