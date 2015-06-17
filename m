From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/17] fm10k: add call to fm10k_clean_all_rx_rings in fm10k_down
Date: Wed, 17 Jun 2015 05:54:53 -0700
Message-ID: <1434545704-112470-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30799 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368AbbFQMzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:08 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This prevents a memory leak in fm10k_set_ringparams. The leak occurs
because we go down, change ring parameters, and then come up. However,
fm10k_down on its own is not clearing the Rx rings. Since fm10k_up
assumes the rings are clean we basically drop the buffers and leak a
bunch of memory. Eventually we hit dirty page faults and reboot the
system. This issue does not occur elsewhere because other flows that
involve fm10k_down go through fm10k_close which immediately called
fm10k_free_all_rx_resources which properly cleans the rings.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index df9fda3..445014a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1559,6 +1559,7 @@ void fm10k_down(struct fm10k_intfc *interface)
 
 	/* free any buffers still on the rings */
 	fm10k_clean_all_tx_rings(interface);
+	fm10k_clean_all_rx_rings(interface);
 }
 
 /**
-- 
2.4.3
