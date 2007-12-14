From: akpm@linux-foundation.org
Subject: [patch 07/10] e100: free IRQ to remove warning when rebooting
Date: Thu, 13 Dec 2007 16:02:58 -0800
Message-ID: <200712140002.lBE02wR8025529@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ianw@gelato.unsw.edu.au, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59724 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933293AbXLNAJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:09:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Wienand <ianw@gelato.unsw.edu.au>

When rebooting today I got

Will now restart.
ACPI: PCI interrupt for device 0000:00:03.0 disabled
GSI 20 (level, low) -> CPU 1 (0x0100) vector 53 unregistered
Destroying IRQ53 without calling free_irq
WARNING: at /home/insecure/ianw/programs/git-kernel/linux-2.6/kernel/irq/chip.c:76 dynamic_irq_cleanup()

Call Trace:
 [<a000000100014340>] show_stack+0x40/0xa0
                                sp=e00000407c927b40 bsp=e00000407c920eb8
 [<a0000001000143d0>] dump_stack+0x30/0x60
                                sp=e00000407c927d10 bsp=e00000407c920ea0
 [<a0000001000e58e0>] dynamic_irq_cleanup+0x160/0x1e0
                                sp=e00000407c927d10 bsp=e00000407c920e70
 [<a0000001000106b0>] destroy_and_reserve_irq+0x30/0xc0
                                sp=e00000407c927d10 bsp=e00000407c920e40
 [<a0000001000508f0>] iosapic_unregister_intr+0x5b0/0x5e0
                                sp=e00000407c927d10 bsp=e00000407c920dd8
 [<a00000010000aa70>] acpi_unregister_gsi+0x30/0x60
                                sp=e00000407c927d10 bsp=e00000407c920db8
 [<a00000010042e300>] acpi_pci_irq_disable+0x140/0x160
                                sp=e00000407c927d10 bsp=e00000407c920d88
 [<a000000100774200>] pcibios_disable_device+0xa0/0xc0
                                sp=e00000407c927d20 bsp=e00000407c920d68
 [<a0000001003778d0>] pci_disable_device+0x130/0x160
                                sp=e00000407c927d20 bsp=e00000407c920d38
 [<a000000100525d20>] e100_shutdown+0x1c0/0x220
                                sp=e00000407c927d30 bsp=e00000407c920d08
 [<a00000010037d0e0>] pci_device_shutdown+0x80/0xc0
                                sp=e00000407c927d30 bsp=e00000407c920ce8
 [<a0000001004ecb70>] device_shutdown+0xf0/0x180
                                sp=e00000407c927d30 bsp=e00000407c920cc8
 [<a0000001000ac4e0>] kernel_restart+0x60/0x120
                                sp=e00000407c927d30 bsp=e00000407c920ca8
 [<a0000001000ac990>] sys_reboot+0x3b0/0x480
                                sp=e00000407c927d30 bsp=e00000407c920c30
 [<a00000010000b4e0>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00000407c927e30 bsp=e00000407c920c30
 [<a000000000010620>] ia64_ivt+0xffffffff00010620/0x400
                                sp=e00000407c928000 bsp=e00000407c920c30
Restarting system.

I think the solution might be to free the IRQ before the pci_device_shutdown

Signed-off-by: Ian Wienand <ianw@gelato.unsw.edu.au>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e100.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/e100.c~e100-free-irq-to-remove-warning-when-rebooting drivers/net/e100.c
--- a/drivers/net/e100.c~e100-free-irq-to-remove-warning-when-rebooting
+++ a/drivers/net/e100.c
@@ -2852,6 +2852,7 @@ static void e100_shutdown(struct pci_dev
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
+	free_irq(pdev->irq, netdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 }
_
