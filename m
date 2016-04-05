From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/15] fm10k: don't initialize service task until later in probe
Date: Tue,  5 Apr 2016 13:02:19 -0700
Message-ID: <1459886547-146445-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56328 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759719AbcDEUCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:02:32 -0400
In-Reply-To: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Delay initialization of the service timer and service task until late
probe. If we don't wait, failures in probe do not properly cleanup the
service timer or service task items, which results in the kernel panic
below, potentially freezing the whole system. In addition, ensure that
the SERVICE_DISABLE bit is set before we request the MBX IRQ since the
MBX interrupt attempts to schedule the service task otherwise. This
prevents a similar trace from occurring after this change.

We didn't notice this issue before because probe almost always completes
successfully. I discovered it due to a mis-ordered mailbox handler
array, which resulted in the following failure when requesting mailbox
interrupt.

[  555.325619] ------------[ cut here ]------------
[  555.325628] WARNING: CPU: 0 PID: 4941 at lib/list_debug.c:33 __list_add+0xa0/0xd0()
[  555.325631] list_add corruption. prev->next should be next (ffffffff81f46648), but was           (null). (prev=ffff8807fad5d0e8).
<snip>
[  555.325722] CPU: 0 PID: 4941 Comm: insmod Tainted: G           OE   4.0.4-303.fc22.x86_64 #1
[  555.325725] Hardware name: Intel Corporation S2600CO/S2600CO, BIOS SE5C600.86B.02.03.8x23.060520140825 06/05/2014
[  555.325727]  0000000000000000 00000000b4f161b3 ffff88081a21f8e8 ffffffff81783124
[  555.325734]  0000000000000000 ffff88081a21f940 ffff88081a21f928 ffffffff8109c66a
[  555.325740]  0000000064000000 ffff8807fad5d0e8 ffff8807fad5d0e8 ffffffff81f46648
[  555.325746] Call Trace:
[  555.325752]  [<ffffffff81783124>] dump_stack+0x45/0x57
[  555.325757]  [<ffffffff8109c66a>] warn_slowpath_common+0x8a/0xc0
[  555.325759]  [<ffffffff8109c6f5>] warn_slowpath_fmt+0x55/0x70
[  555.325763]  [<ffffffff813ba270>] __list_add+0xa0/0xd0
[  555.325768]  [<ffffffff81102d1d>] __internal_add_timer+0x9d/0x110
[  555.325771]  [<ffffffff81102dbf>] internal_add_timer+0x2f/0xc0
[  555.325774]  [<ffffffff81104e5a>] mod_timer+0x12a/0x230
[  555.325782]  [<ffffffffa03d54ca>] fm10k_probe+0x69a/0xc80 [fm10k]
[  555.325787]  [<ffffffff813e8355>] local_pci_probe+0x45/0xa0
[  555.325791]  [<ffffffff8129cf42>] ? sysfs_do_create_link_sd.isra.2+0x72/0xc0
[  555.325794]  [<ffffffff813e96b9>] pci_device_probe+0xf9/0x150
[  555.325799]  [<ffffffff814d7e73>] driver_probe_device+0xa3/0x400
[  555.325802]  [<ffffffff814d82ab>] __driver_attach+0x9b/0xa0
[  555.325805]  [<ffffffff814d8210>] ? __device_attach+0x40/0x40
[  555.325808]  [<ffffffff814d5bd3>] bus_for_each_dev+0x73/0xc0
[  555.325811]  [<ffffffff814d78ce>] driver_attach+0x1e/0x20
[  555.325815]  [<ffffffff814d7480>] bus_add_driver+0x180/0x250
[  555.325819]  [<ffffffffa03b2000>] ? 0xffffffffa03b2000
[  555.325823]  [<ffffffff814d8aa4>] driver_register+0x64/0xf0
[  555.325826]  [<ffffffff813e7bec>] __pci_register_driver+0x4c/0x50
[  555.325832]  [<ffffffffa03d6ca3>] fm10k_register_pci_driver+0x23/0x30 [fm10k]
[  555.325838]  [<ffffffffa03b2080>] fm10k_init_module+0x80/0x1000 [fm10k]
[  555.325843]  [<ffffffff81002128>] do_one_initcall+0xb8/0x200
[  555.325848]  [<ffffffff811e10d2>] ? __vunmap+0xa2/0x100
[  555.325852]  [<ffffffff811fe239>] ? kmem_cache_alloc_trace+0x1b9/0x240
[  555.325855]  [<ffffffff8178230e>] ? do_init_module+0x28/0x1cb
[  555.325858]  [<ffffffff81782346>] do_init_module+0x60/0x1cb
[  555.325862]  [<ffffffff8112168e>] load_module+0x205e/0x26b0
[  555.325866]  [<ffffffff8111d110>] ? store_uevent+0x70/0x70
[  555.325870]  [<ffffffff812234b0>] ? kernel_read+0x50/0x80
[  555.325873]  [<ffffffff81121f3e>] SyS_finit_module+0xbe/0xf0
[  555.325878]  [<ffffffff81789749>] system_call_fastpath+0x12/0x17
[  555.325880] ---[ end trace 9e0f58d071eafd2a ]---

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 8c23fb3d..ed1f8cf 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1795,15 +1795,6 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	/* initialize DCBNL interface */
 	fm10k_dcbnl_set_ops(netdev);
 
-	/* Initialize service timer and service task */
-	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
-	setup_timer(&interface->service_timer, &fm10k_service_timer,
-		    (unsigned long)interface);
-	INIT_WORK(&interface->service_task, fm10k_service_task);
-
-	/* kick off service timer now, even when interface is down */
-	mod_timer(&interface->service_timer, (HZ * 2) + jiffies);
-
 	/* Intitialize timestamp data */
 	fm10k_ts_init(interface);
 
@@ -1989,6 +1980,12 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_sw_init;
 
+	/* the mbx interrupt might attempt to schedule the service task, so we
+	 * must ensure it is disabled since we haven't yet requested the timer
+	 * or work item.
+	 */
+	set_bit(__FM10K_SERVICE_DISABLE, &interface->state);
+
 	err = fm10k_mbx_request_irq(interface);
 	if (err)
 		goto err_mbx_interrupt;
@@ -2008,6 +2005,16 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* stop all the transmit queues from transmitting until link is up */
 	netif_tx_stop_all_queues(netdev);
 
+	/* Initialize service timer and service task late in order to avoid
+	 * cleanup issues.
+	 */
+	setup_timer(&interface->service_timer, &fm10k_service_timer,
+		    (unsigned long)interface);
+	INIT_WORK(&interface->service_task, fm10k_service_task);
+
+	/* kick off service timer now, even when interface is down */
+	mod_timer(&interface->service_timer, (HZ * 2) + jiffies);
+
 	/* Register PTP interface */
 	fm10k_ptp_register(interface);
 
-- 
2.5.5
