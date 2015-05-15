From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH net-next,
 1/1] hv_netvsc: change member name of struct netvsc_stats
Date: Fri, 15 May 2015 02:33:03 -0700
Message-ID: <1431682383-31240-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Simon Xiao <sixiao@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com, devel@linuxdriverproject.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Currently the struct netvsc_stats has a member s_sync
of type u64_stats_sync.
This definition will break kernel build as the macro
netdev_alloc_pcpu_stats requires this member name to be syncp.
(see netdev_alloc_pcpu_stats definition in ./include/linux/netdevice.h)

This patch changes netvsc_stats's member name from s_sync to syncp to fix
the build break.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |  2 +-
 drivers/net/hyperv/netvsc_drv.c | 16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 5a92b36..ddcc7f8 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -614,7 +614,7 @@ struct multi_send_data {
 struct netvsc_stats {
 	u64 packets;
 	u64 bytes;
-	struct u64_stats_sync s_sync;
+	struct u64_stats_sync syncp;
 };
 
 /* The context of the netvsc device  */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0c858724..d9c88bc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -580,10 +580,10 @@ do_send:
 
 drop:
 	if (ret == 0) {
-		u64_stats_update_begin(&tx_stats->s_sync);
+		u64_stats_update_begin(&tx_stats->syncp);
 		tx_stats->packets++;
 		tx_stats->bytes += skb_length;
-		u64_stats_update_end(&tx_stats->s_sync);
+		u64_stats_update_end(&tx_stats->syncp);
 	} else {
 		if (ret != -EAGAIN) {
 			dev_kfree_skb_any(skb);
@@ -692,10 +692,10 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	skb_record_rx_queue(skb, packet->channel->
 			    offermsg.offer.sub_channel_index);
 
-	u64_stats_update_begin(&rx_stats->s_sync);
+	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->packets++;
 	rx_stats->bytes += packet->total_data_buflen;
-	u64_stats_update_end(&rx_stats->s_sync);
+	u64_stats_update_end(&rx_stats->syncp);
 
 	/*
 	 * Pass the skb back up. Network stack will deallocate the skb when it
@@ -776,16 +776,16 @@ static struct rtnl_link_stats64 *netvsc_get_stats64(struct net_device *net,
 		unsigned int start;
 
 		do {
-			start = u64_stats_fetch_begin_irq(&tx_stats->s_sync);
+			start = u64_stats_fetch_begin_irq(&tx_stats->syncp);
 			tx_packets = tx_stats->packets;
 			tx_bytes = tx_stats->bytes;
-		} while (u64_stats_fetch_retry_irq(&tx_stats->s_sync, start));
+		} while (u64_stats_fetch_retry_irq(&tx_stats->syncp, start));
 
 		do {
-			start = u64_stats_fetch_begin_irq(&rx_stats->s_sync);
+			start = u64_stats_fetch_begin_irq(&rx_stats->syncp);
 			rx_packets = rx_stats->packets;
 			rx_bytes = rx_stats->bytes;
-		} while (u64_stats_fetch_retry_irq(&rx_stats->s_sync, start));
+		} while (u64_stats_fetch_retry_irq(&rx_stats->syncp, start));
 
 		t->tx_bytes	+= tx_bytes;
 		t->tx_packets	+= tx_packets;
-- 
1.8.5.2
