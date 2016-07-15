From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] ixgbe: napi_poll must return the work done
Date: Fri, 15 Jul 2016 00:02:03 -0700
Message-ID: <1468566124-63101-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3140 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbcGOHCs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 03:02:48 -0400
In-Reply-To: <1468566124-63101-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>

Currently the function ixgbe_poll() returns 0 when it clean completely
the rx rings, but this foul budget accounting in core code.
Fix this returning the actual work done, capped to weight - 1, since
the core doesn't allow to return the full budget when the driver modifies
the napi status

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Reviewed-by: Venkatesh Srinivas <venkateshs@google.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 088c47c..8bebd86 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2887,7 +2887,7 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		ixgbe_irq_enable_queues(adapter, BIT_ULL(q_vector->v_idx));
 
-	return 0;
+	return min(work_done, budget - 1);
 }
 
 /**
-- 
2.5.5
