From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 13/13] net: thunderx: Add rx timeout and rcv buffer alloc failure stats
Date: Mon, 30 Nov 2015 23:49:09 +0530
Message-ID: <1448907549-5296-14-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>

Instead of error message added counter for receive buffer allocation failures.
Also added counter for transmit timeout event for debug purposes.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |    3 +++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |    2 ++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    1 +
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    3 +--
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index e782856..defbf17 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -250,10 +250,13 @@ struct nicvf_drv_stats {
 	u64 rx_frames_jumbo;
 	u64 rx_drops;
 
+	u64 rcv_buffer_alloc_failures;
+
 	/* Tx */
 	u64 tx_frames_ok;
 	u64 tx_drops;
 	u64 tx_tso;
+	u64 tx_timeout;
 	u64 txq_stop;
 	u64 txq_wake;
 };
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index a12b2e3..d2d8ef2 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -89,9 +89,11 @@ static const struct nicvf_stat nicvf_drv_stats[] = {
 	NICVF_DRV_STAT(rx_frames_1518),
 	NICVF_DRV_STAT(rx_frames_jumbo),
 	NICVF_DRV_STAT(rx_drops),
+	NICVF_DRV_STAT(rcv_buffer_alloc_failures),
 	NICVF_DRV_STAT(tx_frames_ok),
 	NICVF_DRV_STAT(tx_tso),
 	NICVF_DRV_STAT(tx_drops),
+	NICVF_DRV_STAT(tx_timeout),
 	NICVF_DRV_STAT(txq_stop),
 	NICVF_DRV_STAT(txq_wake),
 };
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a75f21f..a7e2951 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1392,6 +1392,7 @@ static void nicvf_tx_timeout(struct net_device *dev)
 		netdev_warn(dev, "%s: Transmit timed out, resetting\n",
 			    dev->name);
 
+	nic->drv_stats.tx_timeout++;
 	schedule_work(&nic->reset_task);
 }
 
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 4e9709e..28df11a 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -96,8 +96,7 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
 		nic->rb_page = alloc_pages(gfp | __GFP_COMP | __GFP_NOWARN,
 					   order);
 		if (!nic->rb_page) {
-			netdev_err(nic->netdev,
-				   "Failed to allocate new rcv buffer\n");
+			nic->drv_stats.rcv_buffer_alloc_failures++;
 			return -ENOMEM;
 		}
 		nic->rb_page_offset = 0;
-- 
1.7.1
