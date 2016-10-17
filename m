From: David Singleton <davsingl@cisco.com>
Subject: [PATCH] e1000e: x86: e1000 driver trying to free already-free irq.
Date: Mon, 17 Oct 2016 09:51:08 -0700
Message-ID: <20161017165108.29718-5-davsingl@cisco.com>
Cc: khalidm <khalidm@cisco.com>, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: khalidm <khalidm@cisco.com>

During systemd reboot sequence network driver interface is shutdown
by e1000_close. The PCI driver interface is shut by e1000_shutdown.
The e1000_shutdown checks for netif_running status, if still up it
brings down driver. But it disables msi outside of this if statement,
regardless of netif status. All this is OK when e1000_close happens
after shutdown. However, by default, everything in systemd is done
in parallel. This creates a conditions where e1000_shutdown is called
after e1000_close, therefore hitting BUG_ON assert in free_msi_irqs.

Cc-Id: xe-kernel@external.cisco.com
Signed-off-by: khalidm <khalidm@cisco.com>
Signed-off-by: David Singleton <davsingl@cisco.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7017281..79f02a6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6283,8 +6283,8 @@ static int e1000e_pm_freeze(struct device *dev)
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
