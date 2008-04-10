From: Jim Westfall <jwestfall@surrealistic.net>
Subject: Re: bnx2 probe order change from 2.6.21 -> 2.6.24
Date: Thu, 10 Apr 2008 11:44:55 -0700
Message-ID: <20080410184455.GL84358@surrealistic.net>
References: <20080410154401.GA14486@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snapper.surrealistic.net ([67.40.222.186]:60376 "EHLO
	snapper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbYDJTJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 15:09:39 -0400
Content-Disposition: inline
In-Reply-To: <20080410154401.GA14486@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester <kernel@linuxace.com> wrote [04.10.08]:
> Apologies if this has been covered already, but I searched the archives and
> couldn't find anything.
> 
> I recently upgraded a Dell Poweredge 1950 from 2.6.21 to 2.6.24, and found
> that the onboard Broadcom NetXtreme II nics got probed in the reverse order.
> 
> 2.6.21:
> 
> Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.5.8.1 (May 7, 2007)
> ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> eth8: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 16, node addr 0015c5eaef1c
> ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> eth9: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f4000000, IRQ 16, node addr 0015c5eaef1e
> 
> 2.6.24:
> 
> Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.6.9 (December 8, 2007)
> ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> eth8: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f4000000, IRQ 16, node addr 00:15:c5:ea:ef:1e
> ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> udev: renamed network interface eth8 to eth9
> eth8: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 16, node addr 00:15:c5:ea:ef:1c
> 
> 
> Is this known/expected?  Seems somewhat odd from both a MAC address
> perspective (1c < 1e) and a PCI bus order (04 < 08).  Thoughts?
> 

Hi

We ran into this issue as well when going from 2.6.20 to 2.6.23 on dell 
1950/2950s.

If you check your dmesg output from your older kernel you should see

PCI: Dell PowerEdge 1950 detected, enabling pci=bfsort.

With the newer kernel the code path that triggers the above is removed if 
you have ACPI enabled in the kernel.

We have been using the following patch which re-adds the code path to the 
ACPI PCI code.

thanks
jim


diff -ur linux-2.6.23.16-orig/arch/i386/pci/acpi.c linux-2.6.23.16-inap3/arch/i386/pci/acpi.c
--- linux-2.6.23.16-orig/arch/i386/pci/acpi.c   2008-02-10 22:06:32.000000000 -0800
+++ linux-2.6.23.16-inap3/arch/i386/pci/acpi.c  2008-02-21 16:27:19.000000000 -0800
@@ -2,9 +2,12 @@
 #include <linux/acpi.h>
 #include <linux/init.h>
 #include <linux/irq.h>
+#include <linux/dmi.h>
 #include <asm/numa.h>
 #include "pci.h"
 
+extern struct dmi_system_id __devinitdata pciprobe_dmi_table[];
+
 struct pci_bus * __devinit pci_acpi_scan_root(struct acpi_device *device, int domain, int busnum)
 {
        struct pci_bus *bus;
@@ -27,6 +30,7 @@
                return NULL;
        }
 
+       dmi_check_system(pciprobe_dmi_table);
        sd->node = -1;
 
        pxm = acpi_get_pxm(device->handle);
diff -ur linux-2.6.23.16-orig/arch/i386/pci/common.c linux-2.6.23.16-inap3/arch/i386/pci/common.c
--- linux-2.6.23.16-orig/arch/i386/pci/common.c 2008-02-10 22:06:32.000000000 -0800
+++ linux-2.6.23.16-inap3/arch/i386/pci/common.c        2008-02-21 16:27:19.000000000 -0800
@@ -145,7 +145,7 @@
 }
 #endif
 
-static struct dmi_system_id __devinitdata pciprobe_dmi_table[] = {
+struct dmi_system_id __devinitdata pciprobe_dmi_table[] = {
 #ifdef __i386__
 /*
 
