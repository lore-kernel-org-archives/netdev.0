From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] s2io: read rx_packets count from the hardware stats
Date: Fri, 25 Jun 2010 01:32:32 +0200
Message-ID: <20100624233230.5864.67401.stgit@leela.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab0FXXtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 19:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the statistics the s2io driver provides in /proc/net/dev
it reads directly from the hardware counters. For some reason it does
not do that for rx_packets. It counts rx_packets purely in software.

A customer reported a bug where in /proc/net/dev the 'multicast' counter
was increasing faster than 'packets' ( = rx_packets in the source code).
This confuses userspace, especially snmpd.

The hardware provides a counter for the total number of received
frames (RMAC_VLD_FRMS) which the driver can use for the rx_packets
statistic. By reading both statistics from the hardware it makes sure
that all multicast frames are included in the total.

The customer tested a patch like this (only modified for RHEL5) with
S2io Inc. Xframe II 10Gbps Ethernet (rev 02)
and it fixed the problem.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---

 drivers/net/s2io.c |   11 ++++++-----
 drivers/net/s2io.h |    1 -
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 668327c..eefc4b2 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4919,6 +4919,10 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 		sp->stats.tx_packets;
 	sp->stats.tx_packets = le32_to_cpu(stats->tmac_frms);
 
+	dev->stats.rx_packets += le32_to_cpu(stats->rmac_vld_frms) -
+		sp->stats.rx_packets;
+	sp->stats.rx_packets = le32_to_cpu(stats->rmac_vld_frms);
+
 	dev->stats.tx_errors += le32_to_cpu(stats->tmac_any_err_frms) -
 		sp->stats.tx_errors;
 	sp->stats.tx_errors = le32_to_cpu(stats->tmac_any_err_frms);
@@ -4935,12 +4939,11 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 		sp->stats.rx_length_errors;
 	sp->stats.rx_length_errors = le64_to_cpu(stats->rmac_long_frms);
 
-	/* collect per-ring rx_packets and rx_bytes */
-	dev->stats.rx_packets = dev->stats.rx_bytes = 0;
+	/* collect per-ring rx_bytes */
+	dev->stats.rx_bytes = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
 		struct ring_info *ring = &mac_control->rings[i];
 
-		dev->stats.rx_packets += ring->rx_packets;
 		dev->stats.rx_bytes += ring->rx_bytes;
 	}
 
@@ -7455,8 +7458,6 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		}
 	}
 
-	/* Updating statistics */
-	ring_data->rx_packets++;
 	rxdp->Host_Control = 0;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 47c36e0..4da9ab8 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -747,7 +747,6 @@ struct ring_info {
 	struct buffAdd **ba;
 
 	/* per-Ring statistics */
-	unsigned long rx_packets;
 	unsigned long rx_bytes;
 } ____cacheline_aligned;
 

