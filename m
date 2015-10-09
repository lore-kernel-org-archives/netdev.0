From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: fix erroneous WARN_ON
Date: Thu,  8 Oct 2015 18:32:39 -0700
Message-ID: <1444354374-24351-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbbJIBc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:57 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was issuing a WARN_ON during ring size changes
because the code was cloning the rx_ring struct but
not zeroing out the pointers before allocating new memory.

Zero out the pointers in the cloned copy before allocating
new memory for them.  In this case the code was correctly
avoiding memory leaks but still triggering the warning.

Change-ID: I186dd493948e9b7254ab0593d4aad8b68808918d
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index ffa9431..ef471fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1176,6 +1176,11 @@ static int i40e_set_ringparam(struct net_device *netdev,
 			/* clone ring and setup updated count */
 			tx_rings[i] = *vsi->tx_rings[i];
 			tx_rings[i].count = new_tx_count;
+			/* the desc and bi pointers will be reallocated in the
+			 * setup call
+			 */
+			tx_rings[i].desc = NULL;
+			tx_rings[i].rx_bi = NULL;
 			err = i40e_setup_tx_descriptors(&tx_rings[i]);
 			if (err) {
 				while (i) {
@@ -1206,6 +1211,11 @@ static int i40e_set_ringparam(struct net_device *netdev,
 			/* clone ring and setup updated count */
 			rx_rings[i] = *vsi->rx_rings[i];
 			rx_rings[i].count = new_rx_count;
+			/* the desc and bi pointers will be reallocated in the
+			 * setup call
+			 */
+			rx_rings[i].desc = NULL;
+			rx_rings[i].rx_bi = NULL;
 			err = i40e_setup_rx_descriptors(&rx_rings[i]);
 			if (err) {
 				while (i) {
-- 
2.4.3
