From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net] igb: Fix Null-pointer dereference in igb_reset_q_vector
Date: Tue, 18 Feb 2014 14:06:57 +0100
Message-ID: <1392728817-21693-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:56935 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbaBRNHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:07:25 -0500
Received: by mail-wg0-f51.google.com with SMTP id n12so3202103wgh.6
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 05:07:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 46d31a49f5ea..bfcf192ee87d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1014,6 +1014,12 @@ static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
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
1.8.3.2
