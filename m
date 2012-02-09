From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/8] ixgbe: do not update real num queues when netdev is going away
Date: Thu,  9 Feb 2012 01:34:19 -0800
Message-ID: <1328780061-25000-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23892 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757578Ab2BIJe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:34:28 -0500
In-Reply-To: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

If the netdev is already in NETREG_UNREGISTERING/_UNREGISTERED state, do not
update the real num tx queues. netdev_queue_update_kobjects() is already
called via remove_queue_kobjects() at NETREG_UNREGISTERING time. So, when
upper layer driver, e.g., FCoE protocol stack is monitoring the netdev
event of NETDEV_UNREGISTER and calls back to LLD ndo_fcoe_disable() to remove
extra queues allocated for FCoE, the associated txq sysfs kobjects are already
removed, and trying to update the real num queues would cause something like
below:

...
PID: 25138  TASK: ffff88021e64c440  CPU: 3   COMMAND: "kworker/3:3"
 #0 [ffff88021f007760] machine_kexec at ffffffff810226d9
 #1 [ffff88021f0077d0] crash_kexec at ffffffff81089d2d
 #2 [ffff88021f0078a0] oops_end at ffffffff813bca78
 #3 [ffff88021f0078d0] no_context at ffffffff81029e72
 #4 [ffff88021f007920] __bad_area_nosemaphore at ffffffff8102a155
 #5 [ffff88021f0079f0] bad_area_nosemaphore at ffffffff8102a23e
 #6 [ffff88021f007a00] do_page_fault at ffffffff813bf32e
 #7 [ffff88021f007b10] page_fault at ffffffff813bc045
    [exception RIP: sysfs_find_dirent+17]
    RIP: ffffffff81178611  RSP: ffff88021f007bc0  RFLAGS: 00010246
    RAX: ffff88021e64c440  RBX: ffffffff8156cc63  RCX: 0000000000000004
    RDX: ffffffff8156cc63  RSI: 0000000000000000  RDI: 0000000000000000
    RBP: ffff88021f007be0   R8: 0000000000000004   R9: 0000000000000008
    R10: ffffffff816fed00  R11: 0000000000000004  R12: 0000000000000000
    R13: ffffffff8156cc63  R14: 0000000000000000  R15: ffff8802222a0000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #8 [ffff88021f007be8] sysfs_get_dirent at ffffffff81178c07
 #9 [ffff88021f007c18] sysfs_remove_group at ffffffff8117ac27
#10 [ffff88021f007c48] netdev_queue_update_kobjects at ffffffff813178f9
#11 [ffff88021f007c88] netif_set_real_num_tx_queues at ffffffff81303e38
#12 [ffff88021f007cc8] ixgbe_set_num_queues at ffffffffa0249763 [ixgbe]
#13 [ffff88021f007cf8] ixgbe_init_interrupt_scheme at ffffffffa024ea89 [ixgbe]
#14 [ffff88021f007d48] ixgbe_fcoe_disable at ffffffffa0267113 [ixgbe]
#15 [ffff88021f007d68] vlan_dev_fcoe_disable at ffffffffa014fef5 [8021q]
#16 [ffff88021f007d78] fcoe_interface_cleanup at ffffffffa02b7dfd [fcoe]
#17 [ffff88021f007df8] fcoe_destroy_work at ffffffffa02b7f08 [fcoe]
#18 [ffff88021f007e18] process_one_work at ffffffff8105d7ca
#19 [ffff88021f007e68] worker_thread at ffffffff81060513
#20 [ffff88021f007ee8] kthread at ffffffff810648b6
#21 [ffff88021f007f48] kernel_thread_helper at ffffffff813c40f4

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0688704..3dc6cef 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4330,6 +4330,10 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	adapter->num_tx_queues = 1;
 
 done:
+	if ((adapter->netdev->reg_state == NETREG_UNREGISTERED) ||
+	    (adapter->netdev->reg_state == NETREG_UNREGISTERING))
+		return 0;
+
 	/* Notify the stack of the (possibly) reduced queue counts. */
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
 	return netif_set_real_num_rx_queues(adapter->netdev,
-- 
1.7.7.6
