From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] i40e: Test memory before ethtool alloc succeeds
Date: Fri,  6 May 2016 00:03:46 -0700
Message-ID: <1462518228-30527-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40897 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757923AbcEFHGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:34 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

When testing on systems with very limited amounts of RAM, a bug was
found where, while changing the number of descriptors using ethtool,
the driver didn't test the limits of system memory before permanently
assuming it would be able to get receive buffer memory.

Work around this issue by pre-allocation of the receive buffer
memory, in the "ghost" ring, which is then used during reinit
using the new ring length.

Change-Id: I92d7a5fb59a6c884b2efdd1ec652845f101c3359
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 34 +++++++++++++++++++++++---
 1 file changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6fd730ac..51a994d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1274,6 +1274,13 @@ static int i40e_set_ringparam(struct net_device *netdev,
 		}
 
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			/* this is to allow wr32 to have something to write to
+			 * during early allocation of Rx buffers
+			 */
+			u32 __iomem faketail = 0;
+			struct i40e_ring *ring;
+			u16 unused;
+
 			/* clone ring and setup updated count */
 			rx_rings[i] = *vsi->rx_rings[i];
 			rx_rings[i].count = new_rx_count;
@@ -1282,12 +1289,22 @@ static int i40e_set_ringparam(struct net_device *netdev,
 			 */
 			rx_rings[i].desc = NULL;
 			rx_rings[i].rx_bi = NULL;
+			rx_rings[i].tail = (u8 __iomem *)&faketail;
 			err = i40e_setup_rx_descriptors(&rx_rings[i]);
+			if (err)
+				goto rx_unwind;
+
+			/* now allocate the Rx buffers to make sure the OS
+			 * has enough memory, any failure here means abort
+			 */
+			ring = &rx_rings[i];
+			unused = I40E_DESC_UNUSED(ring);
+			err = i40e_alloc_rx_buffers(ring, unused);
+rx_unwind:
 			if (err) {
-				while (i) {
-					i--;
+				do {
 					i40e_free_rx_resources(&rx_rings[i]);
-				}
+				} while (i--);
 				kfree(rx_rings);
 				rx_rings = NULL;
 
@@ -1313,6 +1330,17 @@ static int i40e_set_ringparam(struct net_device *netdev,
 	if (rx_rings) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			i40e_free_rx_resources(vsi->rx_rings[i]);
+			/* get the real tail offset */
+			rx_rings[i].tail = vsi->rx_rings[i]->tail;
+			/* this is to fake out the allocation routine
+			 * into thinking it has to realloc everything
+			 * but the recycling logic will let us re-use
+			 * the buffers allocated above
+			 */
+			rx_rings[i].next_to_use = 0;
+			rx_rings[i].next_to_clean = 0;
+			rx_rings[i].next_to_alloc = 0;
+			/* do a struct copy */
 			*vsi->rx_rings[i] = rx_rings[i];
 		}
 		kfree(rx_rings);
-- 
2.5.5
