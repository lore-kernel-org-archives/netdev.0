From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 3/5] e100: correct rx_dropped and add rx_missed_errors
Date: Mon, 12 Sep 2005 10:48:59 -0400
Message-ID: <09122005104859.522@bilbo.tuxdriver.com>
References: <09122005104859.453@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	jesse.brandeburg@intel.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751146AbVILO6Y@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104859.453@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not count non-error frames dropped by the hardware as
part of rx_dropped. Instead, count those frames dropped as
rx_missed_errors. Also, do not count other error frames as part of
rx_dropped. Finally, do not count oversized frames in rx_dropped
(since they are counted as part of rx_length_errors).

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/e100.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1387,13 +1387,13 @@ static void e100_update_stats(struct nic
 		ns->collisions += nic->tx_collisions;
 		ns->tx_errors += le32_to_cpu(s->tx_max_collisions) +
 			le32_to_cpu(s->tx_lost_crs);
-		ns->rx_dropped += le32_to_cpu(s->rx_resource_errors);
 		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
 			nic->rx_over_length_errors;
 		ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
 		ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
 		ns->rx_over_errors += le32_to_cpu(s->rx_overrun_errors);
 		ns->rx_fifo_errors += le32_to_cpu(s->rx_overrun_errors);
+		ns->rx_missed_errors += le32_to_cpu(s->rx_resource_errors);
 		ns->rx_errors += le32_to_cpu(s->rx_crc_errors) +
 			le32_to_cpu(s->rx_alignment_errors) +
 			le32_to_cpu(s->rx_short_frame_errors) +
@@ -1727,12 +1727,10 @@ static inline int e100_rx_indicate(struc
 
 	if(unlikely(!(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
-		nic->net_stats.rx_dropped++;
 		dev_kfree_skb_any(skb);
 	} else if(actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
 		/* Don't indicate oversized frames */
 		nic->rx_over_length_errors++;
-		nic->net_stats.rx_dropped++;
 		dev_kfree_skb_any(skb);
 	} else {
 		nic->net_stats.rx_packets++;
