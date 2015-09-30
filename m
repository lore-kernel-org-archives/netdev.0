From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] i40e: warn on double free
Date: Wed, 30 Sep 2015 05:52:38 -0700
Message-ID: <1443617561-40490-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932536AbbI3Mwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:47 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Down was requesting queue disables, but then exited immediately without
waiting for the queues to actually disable. This could allow any
function called after i40evf_down to run immediately, including
i40evf_up, and causes a memory leak.

This issue has been fixed in a recent refactor of the reset code, but
add a couple WARN_ONs in the slow path to help us recognize if we
reintroduce this issue or if we missed any cases.

Change-ID: I27b6b5c9a79c1892f0ba453129f116bc32647dd0
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5e1a7dc..0d692dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -923,6 +923,8 @@ int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring)
 	if (!dev)
 		return -ENOMEM;
 
+	/* warn if we are about to overwrite the pointer */
+	WARN_ON(tx_ring->tx_bi);
 	bi_size = sizeof(struct i40e_tx_buffer) * tx_ring->count;
 	tx_ring->tx_bi = kzalloc(bi_size, GFP_KERNEL);
 	if (!tx_ring->tx_bi)
@@ -1083,6 +1085,8 @@ int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring)
 	struct device *dev = rx_ring->dev;
 	int bi_size;
 
+	/* warn if we are about to overwrite the pointer */
+	WARN_ON(rx_ring->rx_bi);
 	bi_size = sizeof(struct i40e_rx_buffer) * rx_ring->count;
 	rx_ring->rx_bi = kzalloc(bi_size, GFP_KERNEL);
 	if (!rx_ring->rx_bi)
-- 
2.4.3
