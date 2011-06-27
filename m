From: Shyam Iyer <shyam.iyer.t@gmail.com>
Subject: [PATCH] [net][bna] Fix call trace when interrupts are disabled while sleeping function  kzalloc is called
Date: Mon, 27 Jun 2011 16:21:32 -0400
Message-ID: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
Cc: rmody@brocade.com, ddutt@brocadel.com,
	Shyam Iyer <shyam_iyer@dell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45037 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095Ab1F0UVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 16:21:42 -0400
Received: by qwk3 with SMTP id 3so2375965qwk.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 13:21:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kzalloc sleeps and disabling interrupts(spin_lock_irqsave) causes oops like the one.

Jun 27 08:15:24 home-t710 kernel: [11735.634550] Brocade 10G Ethernet driver
Jun 27 08:15:24 home-t710 kernel: [11735.634590] bnad_pci_probe : (0xffff880427f3d000, 0xffffffffa020f3e0) PCI Func : (2)
Jun 27 08:15:24 home-t710 kernel: [11735.637677] bna 0000:82:00.2: PCI INT A -> GSI 66 (level, low) -> IRQ 66
Jun 27 08:15:24 home-t710 kernel: [11735.638290] bar0 mapped to ffffc90014980000, len 262144
Jun 27 08:15:24 home-t710 kernel: [11735.638732] BUG: sleeping function called from invalid context at mm/slub.c:847
Jun 27 08:15:24 home-t710 kernel: [11735.638736] in_atomic(): 0, irqs_disabled(): 1, pid: 11243, name: insmod
Jun 27 08:15:24 home-t710 kernel: [11735.638740] Pid: 11243, comm: insmod Not tainted 3.0.0-rc4+ #6
Jun 27 08:15:24 home-t710 kernel: [11735.638743] Call Trace:
Jun 27 08:15:24 home-t710 kernel: [11735.638755]  [<ffffffff81046427>] __might_sleep+0xeb/0xf0
Jun 27 08:15:24 home-t710 kernel: [11735.638766]  [<ffffffffa01fe469>] ? netif_wake_queue+0x3d/0x3d [bna]
Jun 27 08:15:24 home-t710 kernel: [11735.638773]  [<ffffffff8111201c>] kmem_cache_alloc_trace+0x43/0xd8
Jun 27 08:15:24 home-t710 kernel: [11735.638782]  [<ffffffffa01fe469>] ? netif_wake_queue+0x3d/0x3d [bna]
Jun 27 08:15:24 home-t710 kernel: [11735.638787]  [<ffffffff810ab791>] request_threaded_irq+0xa1/0x113
Jun 27 08:15:24 home-t710 kernel: [11735.638798]  [<ffffffffa020f0c0>] bnad_pci_probe+0x612/0x8e5 [bna]
Jun 27 08:15:24 home-t710 kernel: [11735.638807]  [<ffffffffa01fe469>] ? netif_wake_queue+0x3d/0x3d [bna]
Jun 27 08:15:24 home-t710 kernel: [11735.638816]  [<ffffffff81482ef4>] ? _raw_spin_unlock_irqrestore+0x17/0x19
Jun 27 08:15:24 home-t710 kernel: [11735.638822]  [<ffffffff8124d17a>] local_pci_probe+0x44/0x75
Jun 27 08:15:24 home-t710 kernel: [11735.638826]  [<ffffffff8124dc06>] pci_device_probe+0xd0/0xff
Jun 27 08:15:24 home-t710 kernel: [11735.638832]  [<ffffffff812ef8ab>] driver_probe_device+0x131/0x213
Jun 27 08:15:24 home-t710 kernel: [11735.638836]  [<ffffffff812ef9e7>] __driver_attach+0x5a/0x7e
Jun 27 08:15:24 home-t710 kernel: [11735.638840]  [<ffffffff812ef98d>] ? driver_probe_device+0x213/0x213
Jun 27 08:15:24 home-t710 kernel: [11735.638844]  [<ffffffff812ee933>] bus_for_each_dev+0x53/0x89
Jun 27 08:15:24 home-t710 kernel: [11735.638848]  [<ffffffff812ef48a>] driver_attach+0x1e/0x20
Jun 27 08:15:24 home-t710 kernel: [11735.638852]  [<ffffffff812ef0ae>] bus_add_driver+0xd1/0x224
Jun 27 08:15:24 home-t710 kernel: [11735.638858]  [<ffffffffa01b8000>] ? 0xffffffffa01b7fff
Jun 27 08:15:24 home-t710 kernel: [11735.638862]  [<ffffffff812efe57>] driver_register+0x98/0x105
Jun 27 08:15:24 home-t710 kernel: [11735.638866]  [<ffffffffa01b8000>] ? 0xffffffffa01b7fff
Jun 27 08:15:24 home-t710 kernel: [11735.638871]  [<ffffffff8124e4c9>] __pci_register_driver+0x56/0xc1
Jun 27 08:15:24 home-t710 kernel: [11735.638875]  [<ffffffffa01b8000>] ? 0xffffffffa01b7fff
Jun 27 08:15:24 home-t710 kernel: [11735.638884]  [<ffffffffa01b8040>] bnad_module_init+0x40/0x60 [bna]
Jun 27 08:15:24 home-t710 kernel: [11735.638892]  [<ffffffff81002099>] do_one_initcall+0x7f/0x136
Jun 27 08:15:24 home-t710 kernel: [11735.638899]  [<ffffffff8108608b>] sys_init_module+0x88/0x1d0
Jun 27 08:15:24 home-t710 kernel: [11735.638906]  [<ffffffff81489682>] system_call_fastpath+0x16/0x1b
Jun 27 08:15:24 home-t710 kernel: [11735.639642] bnad_pci_probe : (0xffff880427f3e000, 0xffffffffa020f3e0) PCI Func : (3)
Jun 27 08:15:24 home-t710 kernel: [11735.639665] bna 0000:82:00.3: PCI INT A -> GSI 66 (level, low) -> IRQ 66
Jun 27 08:15:24 home-t710 kernel: [11735.639735] bar0 mapped to ffffc90014400000, len 262144


Signed-off-by: Shyam Iyer <shyam_iyer@dell.com>
---
 drivers/net/bna/bnad.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 7d25a97..04da3c8 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -1114,6 +1114,11 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 	unsigned long 	flags;
 	u32	irq;
 	irq_handler_t 	irq_handler;
+	u32	cfg_flags;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	cfg_flags = bnad->cfg_flags;
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	/* Mbox should use only 1 vector */
 
@@ -1121,8 +1126,7 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 	if (!intr_info->idl)
 		return -ENOMEM;
 
-	spin_lock_irqsave(&bnad->bna_lock, flags);
-	if (bnad->cfg_flags & BNAD_CF_MSIX) {
+	if (cfg_flags & BNAD_CF_MSIX) {
 		irq_handler = (irq_handler_t)bnad_msix_mbox_handler;
 		irq = bnad->msix_table[bnad->msix_num - 1].vector;
 		flags = 0;
@@ -1135,7 +1139,6 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 		intr_info->intr_type = BNA_INTR_T_INTX;
 		/* intr_info->idl.vector = 0 ? */
 	}
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	sprintf(bnad->mbox_irq_name, "%s", BNAD_NAME);
 
-- 
1.7.5.4

