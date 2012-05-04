From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] ixgbe: fix race condition with shutdown
Date: Fri,  4 May 2012 04:05:01 -0700
Message-ID: <1336129504-29919-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Hariharan Nagarajan <hanagara@cisco.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56123 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755395Ab2EDLFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 07:05:06 -0400
In-Reply-To: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

It was possible for shutdown to pull the rug out from other driver entry
points.  Now we just grab the rtnl lock before taking everything apart.
Thanks to Hariharan for noticing this tight race condition.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Hariharan Nagarajan <hanagara@cisco.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 88f6b2e..d9dbf87 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4866,10 +4866,12 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev)) {
+		rtnl_lock();
 		ixgbe_down(adapter);
 		ixgbe_free_irq(adapter);
 		ixgbe_free_all_tx_resources(adapter);
 		ixgbe_free_all_rx_resources(adapter);
+		rtnl_unlock();
 	}
 
 	ixgbe_clear_interrupt_scheme(adapter);
-- 
1.7.7.6
