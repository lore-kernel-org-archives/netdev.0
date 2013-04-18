From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbe: in shutdown, do netif_running() under rtnl_lock
Date: Thu, 18 Apr 2013 16:30:08 -0700
Message-ID: <1366327822-10741-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: akepner <akepner@riverbed.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14087 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936643Ab3DRXas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:30:48 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akepner <akepner@riverbed.com>

During shutdown it's possible for __dev_close() (which holds
rtnl_lock) to clear the __LINK_STATE_START bit, and for ixgbe
to then read that bit (without holding rtnl_lock), and then
not fail to free irqs, etc. The result is a crash like this:

------------[ cut here ]------------
kernel BUG at drivers/pci/msi.c:313!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
CPU 1
Pid: 5910, comm: reboot Tainted: P           ----------------   2.6.32 #1 empty
RIP: 0010:[<ffffffff81305c2b>]  [<ffffffff81305c2b>] free_msi_irqs+0x11b/0x130
RSP: 0018:ffff880185c9bc88  EFLAGS: 00010282
RAX: ffff880219f58bc0 RBX: ffff88021ac53b00 RCX: 0000000000000000
RDX: 0000000000000001 RSI: 0000000000000246 RDI: 000000000000004a
RBP: ffff880185c9bcc8 R08: 0000000000000002 R09: 0000000000000106
R10: 0000000000000000 R11: 0000000000000006 R12: ffff88021e524778
R13: 0000000000000001 R14: ffff88021e524000 R15: 0000000000000000
FS:  00007f90821b7700(0000) GS:ffff880028220000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f90818bd010 CR3: 0000000132c64000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process reboot (pid: 5910, threadinfo ffff880185c9a000, task ffff88021bf04a80)
Stack:
 ffff880185c9bc98 000000018130529d ffff880185c9bcc8 ffff88021e524000
<0> 0000000000000004 ffff88021948c700 0000000000000000 ffff880185c9bda7
<0> ffff880185c9bce8 ffffffff81305cbd ffff880185c9bce8 ffff88021948c700
Call Trace:
 [<ffffffff81305cbd>] pci_disable_msix+0x3d/0x50
 [<ffffffffa00501d5>] ixgbe_reset_interrupt_capability+0x65/0x90 [ixgbe]
 [<ffffffffa00512f6>] ixgbe_clear_interrupt_scheme+0xb6/0xd0 [ixgbe]
 [<ffffffffa005330b>] __ixgbe_shutdown+0x5b/0x200 [ixgbe]
 [<ffffffffa00534ca>] ixgbe_shutdown+0x1a/0x60 [ixgbe]
 [<ffffffff812f6c7c>] pci_device_shutdown+0x2c/0x50
 [<ffffffff813727fb>] device_shutdown+0x4b/0x160
 [<ffffffff8107d98c>] kernel_restart_prepare+0x2c/0x40
 ehci timer_action, mod_timer io_watchdog
 [<ffffffff8107d9e6>] kernel_restart+0x16/0x60
 [<ffffffff8107dbfd>] sys_reboot+0x1ad/0x200
 [<ffffffff811676cf>] ? __d_free+0x3f/0x60
 [<ffffffff81167748>] ? d_free+0x58/0x60
 [<ffffffff8116f7c0>] ? mntput_no_expire+0x30/0x100
 [<ffffffff81152b11>] ? __fput+0x191/0x200
 [<ffffffff816565fe>] ? do_page_fault+0x3e/0xa0
 [<ffffffff8100b132>] system_call_fastpath+0x16/0x1b
Code: 4c 89 ef e8 98 8c e3 ff 4d 39 f4 48 8b 43 10 75 cf 48 83 c4 18 5b 41 5c
41 5d 41 5e 41 5f c9 c3 49 8b 7d 20 e8 07 5a d3 ff eb c9 <0f> 0b 0f 1f 00 eb fb
66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00
 ehci timer_action, mod_timer io_watchdog
RIP  [<ffffffff81305c2b>] free_msi_irqs+0x11b/0x130
 RSP <ffff880185c9bc88>
---[ end trace 27de882a0fe75593 ]---

(This was seen on a pretty old kernel/driver, but looks like
the same bug is still possible.)

Signed-off-by: <akepner@riverbed.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6bd1dd1..48f3fd5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5123,14 +5123,14 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	netif_device_detach(netdev);
 
+	rtnl_lock();
 	if (netif_running(netdev)) {
-		rtnl_lock();
 		ixgbe_down(adapter);
 		ixgbe_free_irq(adapter);
 		ixgbe_free_all_tx_resources(adapter);
 		ixgbe_free_all_rx_resources(adapter);
-		rtnl_unlock();
 	}
+	rtnl_unlock();
 
 	ixgbe_clear_interrupt_scheme(adapter);
 
-- 
1.7.11.7
