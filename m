From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/14] i40e: check vsi ptrs before dumping them
Date: Tue, 22 Oct 2013 07:22:35 -0700
Message-ID: <1382451757-9817-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18001 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753584Ab3JVOWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 10:22:55 -0400
In-Reply-To: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure there really are rings and queues before trying to dump
information in them.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 39 +++++++++++++++-----------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 246b177..ef4cb1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -234,26 +234,33 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 			memcpy(p, vsi, len);
 			p += len;
 
-			len = (sizeof(struct i40e_q_vector)
-				* vsi->num_q_vectors);
-			memcpy(p, vsi->q_vectors, len);
-			p += len;
-
-			len = (sizeof(struct i40e_ring) * vsi->num_queue_pairs);
-			memcpy(p, vsi->tx_rings, len);
-			p += len;
-			memcpy(p, vsi->rx_rings, len);
-			p += len;
+			if (vsi->num_q_vectors) {
+				len = (sizeof(struct i40e_q_vector)
+					* vsi->num_q_vectors);
+				memcpy(p, vsi->q_vectors, len);
+				p += len;
+			}
 
-			for (i = 0; i < vsi->num_queue_pairs; i++) {
-				len = sizeof(struct i40e_tx_buffer);
-				memcpy(p, vsi->tx_rings[i]->tx_bi, len);
+			if (vsi->num_queue_pairs) {
+				len = (sizeof(struct i40e_ring) *
+				      vsi->num_queue_pairs);
+				memcpy(p, vsi->tx_rings, len);
+				p += len;
+				memcpy(p, vsi->rx_rings, len);
 				p += len;
 			}
-			for (i = 0; i < vsi->num_queue_pairs; i++) {
+
+			if (vsi->tx_rings[0]) {
+				len = sizeof(struct i40e_tx_buffer);
+				for (i = 0; i < vsi->num_queue_pairs; i++) {
+					memcpy(p, vsi->tx_rings[i]->tx_bi, len);
+					p += len;
+				}
 				len = sizeof(struct i40e_rx_buffer);
-				memcpy(p, vsi->rx_rings[i]->rx_bi, len);
-				p += len;
+				for (i = 0; i < vsi->num_queue_pairs; i++) {
+					memcpy(p, vsi->rx_rings[i]->rx_bi, len);
+					p += len;
+				}
 			}
 
 			/* macvlan filter list */
-- 
1.8.3.1
