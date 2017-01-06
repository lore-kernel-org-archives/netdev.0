From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] e1000e: driver trying to free already-free irq
Date: Fri,  6 Jan 2017 02:48:44 -0800
Message-ID: <20170106104852.10363-3-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: khalidm <khalidm@cisco.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, xe-kernel@external.cisco.com,
        David Singleton <davsingl@cisco.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:26908 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935045AbdAFKtX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:23 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: khalidm <khalidm@cisco.com>

During systemd reboot sequence network driver interface is shutdown
by e1000_close. The PCI driver interface is shut by e1000_shutdown.
The e1000_shutdown checks for netif_running status, if still up it
brings down driver. But it disables msi outside of this if statement,
regardless of netif status. All this is OK when e1000_close happens
after shutdown. However, by default, everything in systemd is done
in parallel. This creates a conditions where e1000_shutdown is called
after e1000_close, therefore hitting BUG_ON assert in free_msi_irqs.

CC: xe-kernel@external.cisco.com
Signed-off-by: khalidm <khalidm@cisco.com>
Signed-off-by: David Singleton <davsingl@cisco.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index eccf1da..af39608 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6276,8 +6276,8 @@ static int e1000e_pm_freeze(struct device *dev)
 		/* Quiesce the device without resetting the hardware */
 		e1000e_down(adapter, false);
 		e1000_free_irq(adapter);
+		e1000e_reset_interrupt_capability(adapter);
 	}
-	e1000e_reset_interrupt_capability(adapter);
 
 	/* Allow time for pending master requests to run */
 	e1000e_disable_pcie_master(&adapter->hw);
-- 
2.9.3
