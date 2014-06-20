From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: Fix dangling ring pointers upon driver removal
Date: Fri, 20 Jun 2014 00:49:39 -0700
Message-ID: <1403250588-14356-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62071 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178AbaFTHt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:56 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

When we resize the number of queues, the driver needs to disassociate any
qvectors that are no longer in use from the original rings, this way we
do not try to access the rings through these qvectors at the time of freeing
the qvectors.

Change-ID: Ie4eb9fc749f8e12348517fe1560f599c58f4a2a4
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 95c331a..7d2aeeb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3151,8 +3151,12 @@ static void i40e_vsi_map_rings_to_vectors(struct i40e_vsi *vsi)
 
 	/* If we don't have enough vectors for a 1-to-1 mapping, we'll have to
 	 * group them so there are multiple queues per vector.
+	 * It is also important to go through all the vectors available to be
+	 * sure that if we don't use all the vectors, that the remaining vectors
+	 * are cleared. This is especially important when decreasing the
+	 * number of queues in use.
 	 */
-	for (; v_start < q_vectors && qp_remaining; v_start++) {
+	for (; v_start < q_vectors; v_start++) {
 		struct i40e_q_vector *q_vector = vsi->q_vectors[v_start];
 
 		num_ringpairs = DIV_ROUND_UP(qp_remaining, q_vectors - v_start);
-- 
1.9.3
