From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] igb: Fix Null-pointer dereference in igb_reset_q_vector
Date: Fri, 21 Mar 2014 05:10:05 -0700
Message-ID: <1395403806-29302-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965540AbaCUMKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:15 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>

When igb_set_interrupt_capability() calls
igb_reset_interrupt_capability() (e.g., because CONFIG_PCI_MSI is unset),
num_q_vectors has been set but no vector has yet been allocated.

igb_reset_interrupt_capability() will then call igb_reset_q_vector,
which assumes that the vector is allocated. As this is not the case, we
are accessing a NULL-pointer.

This patch fixes it by checking that q_vector is indeed different from
NULL.

Fixes: 02ef6e1d0b0023 (igb: Fix queue allocation method to accommodate changing during runtime)
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e8b4f7b..6acf787 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1035,6 +1035,12 @@ static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
 {
 	struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
 
+	/* Coming from igb_set_interrupt_capability, the vectors are not yet
+	 * allocated. So, q_vector is NULL so we should stop here.
+	 */
+	if (!q_vector)
+		return;
+
 	if (q_vector->tx.ring)
 		adapter->tx_ring[q_vector->tx.ring->queue_index] = NULL;
 
-- 
1.8.3.1
