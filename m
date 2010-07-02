From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH] s2io: resolve statistics issues
Date: Fri, 2 Jul 2010 14:13:49 -0500
Message-ID: <20100702191349.GD22020@exar.com>
References: <20100624233230.5864.67401.stgit@leela.lan>
 <20100630005454.GJ21324@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	Michal Schmidt <mschmidt@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:57816 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab0GBTNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:13:36 -0400
Received: by pxi14 with SMTP id 14so946637pxi.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 12:13:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100630005454.GJ21324@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch resolves a number of issues in the statistics gathering of
the s2io driver.

On Xframe adapters, the received multicast statistics counter includes
pause frames which are not indicated to the driver.  This can cause
issues where the multicast packet count is higher than what has actually
been received, possibly higher than the number of packets received.
    
The driver software counters are replaced with the adapter hardware
statistics for rx_packets, rx_bytes, and tx_bytes.  It also uses the
overflow registers to determine if the statistics wrapped the 32bit
register (removing the window of having a statistic value less than the
previous call).  rx_length_errors statistic now includes undersized
packets in addition to oversized packets in its counting.  Finally,
rx_crc_errors are now being counted.
    
Signed-off-by: Jon Mason <jon.mason@exar.com>

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 22371f1..d0af924 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3129,7 +3129,6 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		pkt_cnt++;
 
 		/* Updating the statistics block */
-		nic->dev->stats.tx_bytes += skb->len;
 		swstats->mem_freed += skb->truesize;
 		dev_kfree_skb_irq(skb);
 
@@ -4900,48 +4899,81 @@ static void s2io_updt_stats(struct s2io_nic *sp)
  *  Return value:
  *  pointer to the updated net_device_stats structure.
  */
-
 static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
-	struct config_param *config = &sp->config;
 	struct mac_info *mac_control = &sp->mac_control;
 	struct stat_block *stats = mac_control->stats_info;
-	int i;
+	u64 delta;
 
 	/* Configure Stats for immediate updt */
 	s2io_updt_stats(sp);
 
-	/* Using sp->stats as a staging area, because reset (due to mtu
-	   change, for example) will clear some hardware counters */
-	dev->stats.tx_packets += le32_to_cpu(stats->tmac_frms) -
-		sp->stats.tx_packets;
-	sp->stats.tx_packets = le32_to_cpu(stats->tmac_frms);
-
-	dev->stats.tx_errors += le32_to_cpu(stats->tmac_any_err_frms) -
-		sp->stats.tx_errors;
-	sp->stats.tx_errors = le32_to_cpu(stats->tmac_any_err_frms);
-
-	dev->stats.rx_errors += le64_to_cpu(stats->rmac_drop_frms) -
-		sp->stats.rx_errors;
-	sp->stats.rx_errors = le64_to_cpu(stats->rmac_drop_frms);
-
-	dev->stats.multicast = le32_to_cpu(stats->rmac_vld_mcst_frms) -
-		sp->stats.multicast;
-	sp->stats.multicast = le32_to_cpu(stats->rmac_vld_mcst_frms);
-
-	dev->stats.rx_length_errors = le64_to_cpu(stats->rmac_long_frms) -
-		sp->stats.rx_length_errors;
-	sp->stats.rx_length_errors = le64_to_cpu(stats->rmac_long_frms);
+	/* A device reset will cause the on-adapter statistics to be zero'ed.
+	 * This can be done while running by changing the MTU.  To prevent the
+	 * system from having the stats zero'ed, the driver keeps a copy of the
+	 * last update to the system (which is also zero'ed on reset).  This
+	 * enables the driver to accurately know the delta between the last
+	 * update and the current update.
+	 */
+	delta = ((u64) le32_to_cpu(stats->rmac_vld_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_vld_frms)) - sp->stats.rx_packets;
+	sp->stats.rx_packets += delta;
+	dev->stats.rx_packets += delta;
+
+	delta = ((u64) le32_to_cpu(stats->tmac_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_frms)) - sp->stats.tx_packets;
+	sp->stats.tx_packets += delta;
+	dev->stats.tx_packets += delta;
+
+	delta = ((u64) le32_to_cpu(stats->rmac_data_octets_oflow) << 32 |
+		le32_to_cpu(stats->rmac_data_octets)) - sp->stats.rx_bytes;
+	sp->stats.rx_bytes += delta;
+	dev->stats.rx_bytes += delta;
+
+	delta = ((u64) le32_to_cpu(stats->tmac_data_octets_oflow) << 32 |
+		le32_to_cpu(stats->tmac_data_octets)) - sp->stats.tx_bytes;
+	sp->stats.tx_bytes += delta;
+	dev->stats.tx_bytes += delta;
+
+	delta = le64_to_cpu(stats->rmac_drop_frms) - sp->stats.rx_errors;
+	sp->stats.rx_errors += delta;
+	dev->stats.rx_errors += delta;
+
+	delta = ((u64) le32_to_cpu(stats->tmac_any_err_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_any_err_frms)) - sp->stats.tx_errors;
+	sp->stats.tx_errors += delta;
+	dev->stats.tx_errors += delta;
+
+	delta = le64_to_cpu(stats->rmac_drop_frms) - sp->stats.rx_dropped;
+	sp->stats.rx_dropped += delta;
+	dev->stats.rx_dropped += delta;
+
+	delta = le64_to_cpu(stats->tmac_drop_frms) - sp->stats.tx_dropped;
+	sp->stats.tx_dropped += delta;
+	dev->stats.tx_dropped += delta;
+
+	/* The adapter MAC interprets pause frames as multicast packets, but
+	 * does not pass them up.  This erroneously increases the multicast
+	 * packet count and needs to be deducted when the multicast frame count
+	 * is queried.
+	 */
+	delta = (u64) le32_to_cpu(stats->rmac_vld_mcst_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_vld_mcst_frms);
+	delta -= le64_to_cpu(stats->rmac_pause_ctrl_frms);
+	delta -= sp->stats.multicast;
+	sp->stats.multicast += delta;
+	dev->stats.multicast += delta;
 
-	/* collect per-ring rx_packets and rx_bytes */
-	dev->stats.rx_packets = dev->stats.rx_bytes = 0;
-	for (i = 0; i < config->rx_ring_num; i++) {
-		struct ring_info *ring = &mac_control->rings[i];
+	delta = ((u64) le32_to_cpu(stats->rmac_usized_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_usized_frms)) +
+		le64_to_cpu(stats->rmac_long_frms) - sp->stats.rx_length_errors;
+	sp->stats.rx_length_errors += delta;
+	dev->stats.rx_length_errors += delta;
 
-		dev->stats.rx_packets += ring->rx_packets;
-		dev->stats.rx_bytes += ring->rx_bytes;
-	}
+	delta = le64_to_cpu(stats->rmac_fcs_err_frms) - sp->stats.rx_crc_errors;
+	sp->stats.rx_crc_errors += delta;
+	dev->stats.rx_crc_errors += delta;
 
 	return &dev->stats;
 }
@@ -7494,15 +7526,11 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		}
 	}
 
-	/* Updating statistics */
-	ring_data->rx_packets++;
 	rxdp->Host_Control = 0;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
 
-		ring_data->rx_bytes += len;
 		skb_put(skb, len);
-
 	} else if (sp->rxd_mode == RXD_MODE_3B) {
 		int get_block = ring_data->rx_curr_get_info.block_index;
 		int get_off = ring_data->rx_curr_get_info.offset;
@@ -7511,7 +7539,6 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		unsigned char *buff = skb_push(skb, buf0_len);
 
 		struct buffAdd *ba = &ring_data->ba[get_block][get_off];
-		ring_data->rx_bytes += buf0_len + buf2_len;
 		memcpy(buff, ba->ba_0, buf0_len);
 		skb_put(skb, buf2_len);
 	}
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 47c36e0..5e52c75 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -745,10 +745,6 @@ struct ring_info {
 
 	/* Buffer Address store. */
 	struct buffAdd **ba;
-
-	/* per-Ring statistics */
-	unsigned long rx_packets;
-	unsigned long rx_bytes;
 } ____cacheline_aligned;
 
 /* Fifo specific structure */
