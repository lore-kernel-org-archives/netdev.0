From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [Patch 1/1 net-next] S2io: fix statistics flush after a MTU change
Date: Tue, 22 Jul 2008 16:27:20 -0300
Message-ID: <48863498.3020902@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:47125 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756254AbYGVT1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 15:27:51 -0400
Received: from mailhub3.br.ibm.com (mailhub3 [9.18.232.110])
	by igw2.br.ibm.com (Postfix) with ESMTP id 6CCFD17F687
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 16:14:29 -0300 (BRT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m6MJRQM62392096
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 16:27:35 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6MJRKNd000731
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 16:27:20 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On s2io driver, when you change the interface MTU, it invokes a card
reset, which flush some statistics.  This patch solves this problem, and
also set the net_device->stats as the default statistics structure,
instead of s2io_nic->stats.

To do that, s2io_nic->stats turned into a staging area, where is saved
statistics of the last hardware statistics query. So, the difference
between the current hardware statistics and s2io_nic->stats, is the
value that should be summed up, in order to get the correct statistics
value, even after a reset.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

----

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 9dae40c..f92108e 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3139,7 +3139,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		pkt_cnt++;
 
 		/* Updating the statistics block */
-		nic->stats.tx_bytes += skb->len;
+		nic->dev->stats.tx_bytes += skb->len;
 		nic->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb_irq(skb);
 
@@ -4892,25 +4892,42 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 	/* Configure Stats for immediate updt */
 	s2io_updt_stats(sp);
 
+	/* Using sp->stats as a staging area, because reset (due to mtu
+	   change, for example) will clear some hardware counters */
+	dev->stats.tx_packets +=
+		le32_to_cpu(mac_control->stats_info->tmac_frms) - 
+		sp->stats.tx_packets;
 	sp->stats.tx_packets =
 		le32_to_cpu(mac_control->stats_info->tmac_frms);
+	dev->stats.tx_errors +=
+		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms) -
+		sp->stats.tx_errors;
 	sp->stats.tx_errors =
 		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms);
+	dev->stats.rx_errors +=
+		le64_to_cpu(mac_control->stats_info->rmac_drop_frms) -
+		sp->stats.rx_errors;
 	sp->stats.rx_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_drop_frms);
+	dev->stats.multicast =
+		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms) - 
+		sp->stats.multicast;
 	sp->stats.multicast =
 		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms);
+	dev->stats.rx_length_errors =
+		le64_to_cpu(mac_control->stats_info->rmac_long_frms) - 
+		sp->stats.rx_length_errors;
 	sp->stats.rx_length_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_long_frms);
 
 	/* collect per-ring rx_packets and rx_bytes */
-	sp->stats.rx_packets = sp->stats.rx_bytes = 0;
+	dev->stats.rx_packets = dev->stats.rx_bytes = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		sp->stats.rx_packets += mac_control->rings[i].rx_packets;
-		sp->stats.rx_bytes += mac_control->rings[i].rx_bytes;
+		dev->stats.rx_packets += mac_control->rings[i].rx_packets;
+		dev->stats.rx_bytes += mac_control->rings[i].rx_bytes;
 	}
 
-	return (&sp->stats);
+	return (&dev->stats);
 }
 
 /**
@@ -7413,7 +7430,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		if (err_mask != 0x5) {
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
 				dev->name, err_mask);
-			sp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			sp->mac_control.stats_info->sw_stat.mem_freed
 				+= skb->truesize;
 			dev_kfree_skb(skb);
