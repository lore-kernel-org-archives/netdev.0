From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2] ixgbe: add counter for times rx pages gets
 allocated, not recycled
Date: Mon, 04 Sep 2017 20:40:22 +0200
Message-ID: <150455042211.455.6804897285651927718.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753932AbdIDSk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 14:40:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ixgbe driver have page recycle scheme based around the RX-ring
queue, where a RX page is shared between two packets. Based on the
refcnt, the driver can determine if the RX-page is currently only used
by a single packet, if so it can then directly refill/recycle the
RX-slot by with the opposite "side" of the page.

While this is a clever trick, it is hard to determine when this
recycling is successful and when it fails.  Adding a counter, which is
available via ethtool --statistics as 'alloc_rx_page'.  Which counts
the number of times the recycle fails and the real page allocator is
invoked.  When interpreting the stats, do remember that every alloc
will serve two packets.

The counter is collected per rx_ring, but is summed and ethtool
exported as 'alloc_rx_page'.  It would be relevant to know what
rx_ring that cannot keep up, but that can be exported later if
someone experience a need for this.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    4 ++++
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index dd5578756ae0..008d0085e01f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -275,6 +275,7 @@ struct ixgbe_rx_queue_stats {
 	u64 rsc_count;
 	u64 rsc_flush;
 	u64 non_eop_descs;
+	u64 alloc_rx_page;
 	u64 alloc_rx_page_failed;
 	u64 alloc_rx_buff_failed;
 	u64 csum_err;
@@ -655,6 +656,7 @@ struct ixgbe_adapter {
 	u64 rsc_total_count;
 	u64 rsc_total_flush;
 	u64 non_eop_descs;
+	u32 alloc_rx_page;
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 72c565712a5f..d96d9d6c3492 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -104,6 +104,7 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"tx_flow_control_xoff", IXGBE_STAT(stats.lxofftxc)},
 	{"rx_flow_control_xoff", IXGBE_STAT(stats.lxoffrxc)},
 	{"rx_csum_offload_errors", IXGBE_STAT(hw_csum_rx_error)},
+	{"alloc_rx_page", IXGBE_STAT(alloc_rx_page)},
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
 	{"rx_no_dma_resources", IXGBE_STAT(hw_rx_no_dma_resources)},
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d962368d08d0..d6ac9da8d628 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1620,6 +1620,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 	bi->page = page;
 	bi->page_offset = ixgbe_rx_offset(rx_ring);
 	bi->pagecnt_bias = 1;
+	rx_ring->rx_stats.alloc_rx_page++;
 
 	return true;
 }
@@ -6771,6 +6772,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 	u64 non_eop_descs = 0, restart_queue = 0, tx_busy = 0;
 	u64 alloc_rx_page_failed = 0, alloc_rx_buff_failed = 0;
+	u64 alloc_rx_page = 0;
 	u64 bytes = 0, packets = 0, hw_csum_rx_error = 0;
 
 	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
@@ -6791,6 +6793,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct ixgbe_ring *rx_ring = adapter->rx_ring[i];
 		non_eop_descs += rx_ring->rx_stats.non_eop_descs;
+		alloc_rx_page += rx_ring->rx_stats.alloc_rx_page;
 		alloc_rx_page_failed += rx_ring->rx_stats.alloc_rx_page_failed;
 		alloc_rx_buff_failed += rx_ring->rx_stats.alloc_rx_buff_failed;
 		hw_csum_rx_error += rx_ring->rx_stats.csum_err;
@@ -6798,6 +6801,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		packets += rx_ring->stats.packets;
 	}
 	adapter->non_eop_descs = non_eop_descs;
+	adapter->alloc_rx_page = alloc_rx_page;
 	adapter->alloc_rx_page_failed = alloc_rx_page_failed;
 	adapter->alloc_rx_buff_failed = alloc_rx_buff_failed;
 	adapter->hw_csum_rx_error = hw_csum_rx_error;
