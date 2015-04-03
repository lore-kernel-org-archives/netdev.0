From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e/i40evf: fix bug when skb allocation fails
Date: Fri,  3 Apr 2015 05:04:48 -0700
Message-ID: <1428062698-16180-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18470 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412AbbDCMFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:33 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If the skb allocation fails we should not continue using the skb
pointer.  Breaking out at the point of failure means that at the next
RX interrupt the driver will try the allocation again.

Change-ID: Iefaad69856ced7418bfd92afe55322676341f82e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 5 ++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9b11f2e..5a1a677 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1565,8 +1565,11 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		if (likely(!skb)) {
 			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
 							rx_ring->rx_hdr_len);
-			if (!skb)
+			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
+				break;
+			}
+
 			/* initialize queue mapping */
 			skb_record_rx_queue(skb, rx_ring->queue_index);
 			/* we are reusing so sync this buffer for CPU use */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 1b5ee46..2be50a8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1040,8 +1040,11 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		if (likely(!skb)) {
 			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
 							rx_ring->rx_hdr_len);
-			if (!skb)
+			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
+				break;
+			}
+
 			/* initialize queue mapping */
 			skb_record_rx_queue(skb, rx_ring->queue_index);
 			/* we are reusing so sync this buffer for CPU use */
-- 
1.9.3
