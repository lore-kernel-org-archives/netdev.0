From: Tyler Baicar <tbaicar@codeaurora.org>
Subject: [PATCH v2] e1000e: free IRQ regardless of __E1000_DOWN
Date: Wed,  9 Nov 2016 14:41:21 -0700
Message-ID: <1478727681-16505-1-git-send-email-tbaicar@codeaurora.org>
Cc: alexander.duyck@gmail.com, dima.ruinskiy@intel.com,
        Tyler Baicar <tbaicar@codeaurora.org>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        okaya@codeaurora.org, timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49028 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753168AbcKIVl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 16:41:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move IRQ free code so that it will happen regardless of the
__E1000_DOWN bit. Currently the e1000e driver only releases its IRQ
if the __E1000_DOWN bit is cleared. This is not sufficient because
it is possible for __E1000_DOWN to be set without releasing the IRQ.
In such a situation, we will hit a kernel bug later in e1000_remove
because the IRQ still has action since it was never freed. A
secondary bus reset can cause this case to happen.

Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7017281..36cfcb0 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4679,12 +4679,13 @@ int e1000e_close(struct net_device *netdev)
 
 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
 		e1000e_down(adapter, true);
-		e1000_free_irq(adapter);
 
 		/* Link status message must follow this format */
 		pr_info("%s NIC Link is Down\n", adapter->netdev->name);
 	}
 
+	e1000_free_irq(adapter);
+
 	napi_disable(&adapter->napi);
 
 	e1000e_free_tx_resources(adapter->tx_ring);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
