From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] s2io: implement 64 bit stats
Date: Wed, 08 Jun 2011 17:54:05 -0700
Message-ID: <20110609005417.817071451@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481Ab1FIBQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:31 -0400
Content-Disposition: inline; filename=s2io-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert s2io driver to 64 bit statistics interface.
This driver keeps it private set of counters so change those
to the 64 bit netlink type.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/s2io.c	2011-06-07 17:35:37.372117743 -0700
+++ b/drivers/net/s2io.c	2011-06-07 17:44:14.102680070 -0700
@@ -4897,7 +4897,8 @@ static void s2io_updt_stats(struct s2io_
  *  Return value:
  *  pointer to the updated net_device_stats structure.
  */
-static struct net_device_stats *s2io_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *s2io_get_stats(struct net_device *dev,
+						struct rtnl_link_stats64 *net_stats)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
 	struct mac_info *mac_control = &sp->mac_control;
@@ -4916,40 +4917,32 @@ static struct net_device_stats *s2io_get
 	 */
 	delta = ((u64) le32_to_cpu(stats->rmac_vld_frms_oflow) << 32 |
 		le32_to_cpu(stats->rmac_vld_frms)) - sp->stats.rx_packets;
-	sp->stats.rx_packets += delta;
-	dev->stats.rx_packets += delta;
+	sp->stats.tx_packets += delta;
 
 	delta = ((u64) le32_to_cpu(stats->tmac_frms_oflow) << 32 |
 		le32_to_cpu(stats->tmac_frms)) - sp->stats.tx_packets;
 	sp->stats.tx_packets += delta;
-	dev->stats.tx_packets += delta;
 
 	delta = ((u64) le32_to_cpu(stats->rmac_data_octets_oflow) << 32 |
 		le32_to_cpu(stats->rmac_data_octets)) - sp->stats.rx_bytes;
 	sp->stats.rx_bytes += delta;
-	dev->stats.rx_bytes += delta;
 
 	delta = ((u64) le32_to_cpu(stats->tmac_data_octets_oflow) << 32 |
 		le32_to_cpu(stats->tmac_data_octets)) - sp->stats.tx_bytes;
 	sp->stats.tx_bytes += delta;
-	dev->stats.tx_bytes += delta;
 
 	delta = le64_to_cpu(stats->rmac_drop_frms) - sp->stats.rx_errors;
 	sp->stats.rx_errors += delta;
-	dev->stats.rx_errors += delta;
 
 	delta = ((u64) le32_to_cpu(stats->tmac_any_err_frms_oflow) << 32 |
 		le32_to_cpu(stats->tmac_any_err_frms)) - sp->stats.tx_errors;
 	sp->stats.tx_errors += delta;
-	dev->stats.tx_errors += delta;
 
 	delta = le64_to_cpu(stats->rmac_drop_frms) - sp->stats.rx_dropped;
 	sp->stats.rx_dropped += delta;
-	dev->stats.rx_dropped += delta;
 
 	delta = le64_to_cpu(stats->tmac_drop_frms) - sp->stats.tx_dropped;
 	sp->stats.tx_dropped += delta;
-	dev->stats.tx_dropped += delta;
 
 	/* The adapter MAC interprets pause frames as multicast packets, but
 	 * does not pass them up.  This erroneously increases the multicast
@@ -4961,19 +4954,16 @@ static struct net_device_stats *s2io_get
 	delta -= le64_to_cpu(stats->rmac_pause_ctrl_frms);
 	delta -= sp->stats.multicast;
 	sp->stats.multicast += delta;
-	dev->stats.multicast += delta;
 
 	delta = ((u64) le32_to_cpu(stats->rmac_usized_frms_oflow) << 32 |
 		le32_to_cpu(stats->rmac_usized_frms)) +
 		le64_to_cpu(stats->rmac_long_frms) - sp->stats.rx_length_errors;
 	sp->stats.rx_length_errors += delta;
-	dev->stats.rx_length_errors += delta;
 
 	delta = le64_to_cpu(stats->rmac_fcs_err_frms) - sp->stats.rx_crc_errors;
 	sp->stats.rx_crc_errors += delta;
-	dev->stats.rx_crc_errors += delta;
 
-	return &dev->stats;
+	return &sp->stats;
 }
 
 /**
@@ -7447,7 +7437,7 @@ static int rx_osm_handler(struct ring_in
 		if (err_mask != 0x5) {
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
 				  dev->name, err_mask);
-			dev->stats.rx_crc_errors++;
+			sp->stats.rx_crc_errors++;
 			swstats->mem_freed
 				+= skb->truesize;
 			dev_kfree_skb(skb);
@@ -7731,7 +7721,7 @@ static int rts_ds_steer(struct s2io_nic
 static const struct net_device_ops s2io_netdev_ops = {
 	.ndo_open	        = s2io_open,
 	.ndo_stop	        = s2io_close,
-	.ndo_get_stats	        = s2io_get_stats,
+	.ndo_get_stats64        = s2io_get_stats,
 	.ndo_start_xmit    	= s2io_xmit,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_multicast_list = s2io_set_multicast,
--- a/drivers/net/s2io.h	2011-06-07 17:38:50.921077503 -0700
+++ b/drivers/net/s2io.h	2011-06-07 17:43:59.478607560 -0700
@@ -871,7 +871,7 @@ struct s2io_nic {
 
 	struct mac_addr def_mac_addr[256];
 
-	struct net_device_stats stats;
+	struct rtnl_link_stats64 stats;
 	int high_dma_flag;
 	int device_enabled_once;
 


