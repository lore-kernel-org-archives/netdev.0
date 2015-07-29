From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 04/11] net: thunderx: Fix memory leak when changing queue
 count
Date: Wed, 29 Jul 2015 16:49:39 +0300
Message-ID: <1438177787-20940-5-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
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

From: Sunil Goutham <sgoutham@cavium.com>

Fix for memory leak when changing queue/channel count via ethtool

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 23 +++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index 16bd2d7..b22dee6 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -126,6 +126,7 @@ static void nicvf_set_msglevel(struct net_device *netdev, u32 lvl)
 
 static void nicvf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
 {
+	struct nicvf *nic = netdev_priv(netdev);
 	int stats, qidx;
 
 	if (sset != ETH_SS_STATS)
@@ -141,7 +142,7 @@ static void nicvf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
 		data += ETH_GSTRING_LEN;
 	}
 
-	for (qidx = 0; qidx < MAX_RCV_QUEUES_PER_QS; qidx++) {
+	for (qidx = 0; qidx < nic->qs->rq_cnt; qidx++) {
 		for (stats = 0; stats < nicvf_n_queue_stats; stats++) {
 			sprintf(data, "rxq%d: %s", qidx,
 				nicvf_queue_stats[stats].name);
@@ -149,7 +150,7 @@ static void nicvf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
 		}
 	}
 
-	for (qidx = 0; qidx < MAX_SND_QUEUES_PER_QS; qidx++) {
+	for (qidx = 0; qidx < nic->qs->sq_cnt; qidx++) {
 		for (stats = 0; stats < nicvf_n_queue_stats; stats++) {
 			sprintf(data, "txq%d: %s", qidx,
 				nicvf_queue_stats[stats].name);
@@ -170,12 +171,14 @@ static void nicvf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
 
 static int nicvf_get_sset_count(struct net_device *netdev, int sset)
 {
+	struct nicvf *nic = netdev_priv(netdev);
+
 	if (sset != ETH_SS_STATS)
 		return -EINVAL;
 
 	return nicvf_n_hw_stats + nicvf_n_drv_stats +
 		(nicvf_n_queue_stats *
-		 (MAX_RCV_QUEUES_PER_QS + MAX_SND_QUEUES_PER_QS)) +
+		 (nic->qs->rq_cnt + nic->qs->sq_cnt)) +
 		BGX_RX_STATS_COUNT + BGX_TX_STATS_COUNT;
 }
 
@@ -197,13 +200,13 @@ static void nicvf_get_ethtool_stats(struct net_device *netdev,
 		*(data++) = ((u64 *)&nic->drv_stats)
 				[nicvf_drv_stats[stat].index];
 
-	for (qidx = 0; qidx < MAX_RCV_QUEUES_PER_QS; qidx++) {
+	for (qidx = 0; qidx < nic->qs->rq_cnt; qidx++) {
 		for (stat = 0; stat < nicvf_n_queue_stats; stat++)
 			*(data++) = ((u64 *)&nic->qs->rq[qidx].stats)
 					[nicvf_queue_stats[stat].index];
 	}
 
-	for (qidx = 0; qidx < MAX_SND_QUEUES_PER_QS; qidx++) {
+	for (qidx = 0; qidx < nic->qs->sq_cnt; qidx++) {
 		for (stat = 0; stat < nicvf_n_queue_stats; stat++)
 			*(data++) = ((u64 *)&nic->qs->sq[qidx].stats)
 					[nicvf_queue_stats[stat].index];
@@ -543,6 +546,7 @@ static int nicvf_set_channels(struct net_device *dev,
 {
 	struct nicvf *nic = netdev_priv(dev);
 	int err = 0;
+	bool if_up = netif_running(dev);
 
 	if (!channel->rx_count || !channel->tx_count)
 		return -EINVAL;
@@ -551,6 +555,9 @@ static int nicvf_set_channels(struct net_device *dev,
 	if (channel->tx_count > MAX_SND_QUEUES_PER_QS)
 		return -EINVAL;
 
+	if (if_up)
+		nicvf_stop(dev);
+
 	nic->qs->rq_cnt = channel->rx_count;
 	nic->qs->sq_cnt = channel->tx_count;
 	nic->qs->cq_cnt = max(nic->qs->rq_cnt, nic->qs->sq_cnt);
@@ -559,11 +566,9 @@ static int nicvf_set_channels(struct net_device *dev,
 	if (err)
 		return err;
 
-	if (!netif_running(dev))
-		return err;
+	if (if_up)
+		nicvf_open(dev);
 
-	nicvf_stop(dev);
-	nicvf_open(dev);
 	netdev_info(dev, "Setting num Tx rings to %d, Rx rings to %d success\n",
 		    nic->qs->sq_cnt, nic->qs->rq_cnt);
 
-- 
2.4.6
