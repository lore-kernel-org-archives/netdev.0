From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net v2 1/2] mlx4: Fix memory leak after mlx4_en_update_priv()
Date: Tue, 31 Jan 2017 22:35:32 -0800
Message-ID: <1485930933-4159518-2-git-send-email-kafai@fb.com>
References: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>,
        Eugenia Emantayev <eugenia@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40922 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751004AbdBAGff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 01:35:35 -0500
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116Wtxq011375
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:35:34 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28b7p18awm-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:35:34 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 a2015c14e84811e6b3650002c99331b0-dc5f9a50 for <netdev@vger.kernel.org>;        Tue,
 31 Jan 2017 22:35:33 -0800
In-Reply-To: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mlx4_en_update_priv(), dst->tx_ring[t] and dst->tx_cq[t]
are over-written by src->tx_ring[t] and src->tx_cq[t] without
first calling kfree.

One of the reproducible code paths is by doing 'ethtool -L'.

The fix is to do the kfree in mlx4_en_free_resources().

Here is the kmemleak report:
unreferenced object 0xffff880841211800 (size 2048):
  comm "ethtool", pid 3096, jiffies 4294716940 (age 528.353s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff81930718>] kmemleak_alloc+0x28/0x50
    [<ffffffff8120b213>] kmem_cache_alloc_trace+0x103/0x260
    [<ffffffff8170e0a8>] mlx4_en_try_alloc_resources+0x118/0x1a0
    [<ffffffff817065a9>] mlx4_en_set_ringparam+0x169/0x210
    [<ffffffff818040c5>] dev_ethtool+0xae5/0x2190
    [<ffffffff8181b898>] dev_ioctl+0x168/0x6f0
    [<ffffffff817d7a72>] sock_do_ioctl+0x42/0x50
    [<ffffffff817d819b>] sock_ioctl+0x21b/0x2d0
    [<ffffffff81247a73>] do_vfs_ioctl+0x93/0x6a0
    [<ffffffff812480f9>] SyS_ioctl+0x79/0x90
    [<ffffffff8193d7ea>] entry_SYSCALL_64_fastpath+0x18/0xad
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880841213000 (size 2048):
  comm "ethtool", pid 3096, jiffies 4294716940 (age 528.353s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff81930718>] kmemleak_alloc+0x28/0x50
    [<ffffffff8120b213>] kmem_cache_alloc_trace+0x103/0x260
    [<ffffffff8170e0cb>] mlx4_en_try_alloc_resources+0x13b/0x1a0
    [<ffffffff817065a9>] mlx4_en_set_ringparam+0x169/0x210
    [<ffffffff818040c5>] dev_ethtool+0xae5/0x2190
    [<ffffffff8181b898>] dev_ioctl+0x168/0x6f0
    [<ffffffff817d7a72>] sock_do_ioctl+0x42/0x50
    [<ffffffff817d819b>] sock_ioctl+0x21b/0x2d0
    [<ffffffff81247a73>] do_vfs_ioctl+0x93/0x6a0
    [<ffffffff812480f9>] SyS_ioctl+0x79/0x90
    [<ffffffff8193d7ea>] entry_SYSCALL_64_fastpath+0x18/0xad
    [<ffffffffffffffff>] 0xffffffffffffffff

(gdb) list *mlx4_en_try_alloc_resources+0x118
0xffffffff8170e0a8 is in mlx4_en_try_alloc_resources (drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2145).
2140                    if (!dst->tx_ring_num[t])
2141                            continue;
2142
2143                    dst->tx_ring[t] = kzalloc(sizeof(struct mlx4_en_tx_ring *) *
2144                                              MAX_TX_RINGS, GFP_KERNEL);
2145                    if (!dst->tx_ring[t])
2146                            goto err_free_tx;
2147
2148                    dst->tx_cq[t] = kzalloc(sizeof(struct mlx4_en_cq *) *
2149                                            MAX_TX_RINGS, GFP_KERNEL);
(gdb) list *mlx4_en_try_alloc_resources+0x13b
0xffffffff8170e0cb is in mlx4_en_try_alloc_resources (drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2150).
2145                    if (!dst->tx_ring[t])
2146                            goto err_free_tx;
2147
2148                    dst->tx_cq[t] = kzalloc(sizeof(struct mlx4_en_cq *) *
2149                                            MAX_TX_RINGS, GFP_KERNEL);
2150                    if (!dst->tx_cq[t]) {
2151                            kfree(dst->tx_ring[t]);
2152                            goto err_free_tx;
2153                    }
2154            }

Fixes: ec25bc04ed8e ("net/mlx4_en: Add resilience in low memory systems")
Cc: Eugenia Emantayev <eugenia@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 761f8b12399c..3abcead208d2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2042,6 +2042,8 @@ static void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 			if (priv->tx_cq[t] && priv->tx_cq[t][i])
 				mlx4_en_destroy_cq(priv, &priv->tx_cq[t][i]);
 		}
+		kfree(priv->tx_ring[t]);
+		kfree(priv->tx_cq[t]);
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
@@ -2214,7 +2216,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	int t;
 
 	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
 
@@ -2248,11 +2249,6 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mlx4_en_free_resources(priv);
 	mutex_unlock(&mdev->state_lock);
 
-	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
-		kfree(priv->tx_ring[t]);
-		kfree(priv->tx_cq[t]);
-	}
-
 	free_netdev(dev);
 }
 
-- 
2.5.1
