From: Weidong Wang <wangweidong1@huawei.com>
Subject: [PATCH net-next] BNX2: fix a Null Pointer for stats_blk
Date: Tue, 22 Sep 2015 20:42:40 +0800
Message-ID: <56014CC0.3050201@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <rui.xiang@huawei.com>
To: <sony.chacko@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

we have two processes to do:
P1#: ifconfig eth0 down; which will call bnx2_close, then will
, and set Null to stats_blk
P2#: ifconfig eth0; which will call bnx2_get_stats64, it will
use stats_blk.
In one case:
    --P1#--                   --P2#--
                              stats_blk(no null)
    bnx2_free_mem
    ->bp->stats_blk = NULL
                              GET_64BIT_NET_STATS

then it will cause 'NULL Pointer' Problem.
it is as well with 'ethtool -S ethx'.

BTW, the other branch has this problem as well.

So we add a spin_lock to protect stats_blk.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 42 ++++++++++++++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnx2.h |  1 +
 2 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2b66ef3..aec4081 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -830,11 +830,13 @@ bnx2_free_mem(struct bnx2 *bp)
 		}
 	}
 	if (bnapi->status_blk.msi) {
+		spin_lock(&bp->stats64_lock);
 		dma_free_coherent(&bp->pdev->dev, bp->status_stats_size,
 				  bnapi->status_blk.msi,
 				  bp->status_blk_mapping);
 		bnapi->status_blk.msi = NULL;
 		bp->stats_blk = NULL;
+		spin_unlock(&bp->stats64_lock);
 	}
 }

@@ -880,6 +882,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 		}
 	}

+	spin_lock(&bp->stats64_lock);
 	bp->stats_blk = status_blk + status_blk_size;

 	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
@@ -894,20 +897,23 @@ bnx2_alloc_mem(struct bnx2 *bp)
 						&bp->ctx_blk_mapping[i],
 						GFP_KERNEL);
 			if (bp->ctx_blk[i] == NULL)
-				goto alloc_mem_err;
+				goto free_stats64_lock;
 		}
 	}

 	err = bnx2_alloc_rx_mem(bp);
 	if (err)
-		goto alloc_mem_err;
+		goto free_stats64_lock;

 	err = bnx2_alloc_tx_mem(bp);
 	if (err)
-		goto alloc_mem_err;
+		goto free_stats64_lock;

+	spin_unlock(&bp->stats64_lock);
 	return 0;

+free_stats64_lock:
+	spin_unlock(&bp->stats64_lock);
 alloc_mem_err:
 	bnx2_free_mem(bp);
 	return -ENOMEM;
@@ -6756,10 +6762,14 @@ bnx2_close(struct net_device *dev)
 static void
 bnx2_save_stats(struct bnx2 *bp)
 {
-	u32 *hw_stats = (u32 *) bp->stats_blk;
-	u32 *temp_stats = (u32 *) bp->temp_stats_blk;
+	u32 *hw_stats;
+	u32 *temp_stats;
 	int i;

+	spin_lock(&bp->stats64_lock);
+	hw_stats = (u32 *) bp->stats_blk;
+	temp_stats = (u32 *) bp->temp_stats_blk;
+
 	/* The 1st 10 counters are 64-bit counters */
 	for (i = 0; i < 20; i += 2) {
 		u32 hi;
@@ -6775,6 +6785,8 @@ bnx2_save_stats(struct bnx2 *bp)

 	for ( ; i < sizeof(struct statistics_block) / 4; i++)
 		temp_stats[i] += hw_stats[i];
+
+	spin_unlock(&bp->stats64_lock);
 }

 #define GET_64BIT_NET_STATS64(ctr)		\
@@ -6793,8 +6805,11 @@ bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 {
 	struct bnx2 *bp = netdev_priv(dev);

-	if (bp->stats_blk == NULL)
+	spin_lock(&bp->stats64_lock);
+	if (bp->stats_blk == NULL) {
+		spin_unlock(&bp->stats64_lock);
 		return net_stats;
+	}

 	net_stats->rx_packets =
 		GET_64BIT_NET_STATS(stat_IfHCInUcastPkts) +
@@ -6858,6 +6873,7 @@ bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		GET_32BIT_NET_STATS(stat_IfInMBUFDiscards) +
 		GET_32BIT_NET_STATS(stat_FwRxDrop);

+	spin_unlock(&bp->stats64_lock);
 	return net_stats;
 }

@@ -7634,13 +7650,17 @@ bnx2_get_ethtool_stats(struct net_device *dev,
 {
 	struct bnx2 *bp = netdev_priv(dev);
 	int i;
-	u32 *hw_stats = (u32 *) bp->stats_blk;
-	u32 *temp_stats = (u32 *) bp->temp_stats_blk;
+	u32 *hw_stats;
+	u32 *temp_stats;
 	u8 *stats_len_arr = NULL;

+	spin_lock(&bp->stats64_lock);
+	hw_stats = (u32 *) bp->stats_blk;
+	temp_stats = (u32 *) bp->temp_stats_blk;
+
 	if (hw_stats == NULL) {
 		memset(buf, 0, sizeof(u64) * BNX2_NUM_STATS);
-		return;
+		goto free_stats64_lock;
 	}

 	if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
@@ -7673,6 +7693,9 @@ bnx2_get_ethtool_stats(struct net_device *dev,
 			 (((u64) *(temp_stats + offset)) << 32) +
 			 *(temp_stats + offset + 1);
 	}
+
+free_stats64_lock:
+	spin_unlock(&bp->stats64_lock);
 }

 static int
@@ -8125,6 +8148,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)

 	spin_lock_init(&bp->phy_lock);
 	spin_lock_init(&bp->indirect_lock);
+	spin_lock_init(&bp->stats64_lock);
 #ifdef BCM_CNIC
 	mutex_init(&bp->cnic_lock);
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index f92f76c..c88c21b 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6928,6 +6928,7 @@ struct bnx2 {

 	dma_addr_t		status_blk_mapping;

+	spinlock_t stats64_lock;
 	struct statistics_block	*stats_blk;
 	struct statistics_block	*temp_stats_blk;
 	dma_addr_t		stats_blk_mapping;
-- 
1.7.12
