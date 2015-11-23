From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] ixgbe: Fix handling of NAPI budget when multiple queues are enabled per vector
Date: Mon, 23 Nov 2015 11:36:08 -0800
Message-ID: <1448307376-20063-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41412 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801AbbKWTgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:23 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch corrects an issue in which the polling routine would increase
the budget for Rx to at least 1 per queue if multiple queues were present.
This would result in Rx packets being processed when the budget was 0 which
is meant to indicate that no Rx can be handled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c9b7e5e..4fa94a3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2783,7 +2783,8 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	ixgbe_for_each_ring(ring, q_vector->tx)
 		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
-	if (!ixgbe_qv_lock_napi(q_vector))
+	/* Exit if we are called by netpoll or busy polling is active */
+	if ((budget <= 0) || !ixgbe_qv_lock_napi(q_vector))
 		return budget;
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
-- 
2.5.0
