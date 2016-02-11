From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 1/6] net,
 thunderx: Add TX timeout and RX buffer alloc failure stats.
Date: Thu, 11 Feb 2016 21:50:21 +0530
Message-ID: <1455207626-35488-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
 sgoutham@cavium.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>

When system is low on atomic memory, too many error messages are logged.
Since this is not a total failure but a simple switch to non-atomic allocation
better to have a stat.

Also add a stat for reset, kicked due to transmit watchdog timeout.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |    3 +++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |    2 ++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    1 +
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    3 +--
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 6888288..8af363a 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -248,10 +248,13 @@ struct nicvf_drv_stats {
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
index c24cb2a..95db6b7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1394,6 +1394,7 @@ static void nicvf_tx_timeout(struct net_device *dev)
 		netdev_warn(dev, "%s: Transmit timed out, resetting\n",
 			    dev->name);
 
+	nic->drv_stats.tx_timeout++;
 	schedule_work(&nic->reset_task);
 }
 
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index d0d1b54..50ab6f4 100644
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
