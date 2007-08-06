From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH] kexec: fix pci device initialization fail after kexec (2.6.23-rc2). (Related to e1000 doesn't resume properly from standby)
Date: Mon, 6 Aug 2007 22:42:46 +0900
Message-ID: <b25c3fa70708060642w1b3a326q792a81fdaa3036c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Pavel Machek" <pavel@ucw.cz>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Kexec Mailing List" <kexec@lists.infradead.org>,
	"Simon Arlott" <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:8289 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbXHFNmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 09:42:47 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1123274rvb
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2007 06:42:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.
I think that the pci_set_power_state() has bug.
The specification says that some delays is required.

Simon, please can I know whether it works to you?
It is seems to the things are related.

Joonwoo Park.

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 37c00f6..9f78064 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -493,8 +493,14 @@ pci_set_power_state(struct pci_dev *dev, pci_power_t state)
   * restore at least the BARs so that the device will be
   * accessible to its driver.
   */
- if (need_restore)
+ if (need_restore) {
+   /* The specification also says that "Must ensure that all of
+    * its PCI signal drivers remain disabled for the duration of
+    * the D3hot to D0 Uninitialized state transition".
+    */
+   msleep(10);
    pci_restore_bars(dev);
+ }

  return 0;
 }


2007/8/6, Simon Arlott <simon@fire.lp0.eu>:
> On Mon, August 6, 2007 11:44, Pavel Machek wrote:
> > Hi!
> >
> >> >00:0a.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet
> >> >Controller (Copper) (rev 01)
> >> >        Subsystem: Intel Corp.: Unknown device 1012
> >> >        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 5
> >> >        Memory at e3020000 (64-bit, non-prefetchable) [size=128K]
> >> >        I/O ports at b000 [size=64]
> >> >        Capabilities: [dc] Power Management version 2
> >> >        Capabilities: [e4] PCI-X non-bridge device.
> >> >        Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0
> >> >        Enable-
> >> >
> >> >00:0a.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet
> >> >Controller (Copper) (rev 01)
> >> >        Subsystem: Intel Corp.: Unknown device 1012
> >> >        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 12
> >> >        Memory at e3000000 (64-bit, non-prefetchable) [size=128K]
> >> >        I/O ports at b400 [size=64]
> >> >        Capabilities: [dc] Power Management version 2
> >> >        Capabilities: [e4] PCI-X non-bridge device.
> >> >        Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0
> >> >        Enable-
> >> >
> >> >[  950.132046] Stopping tasks ... done.
> >> >[  950.459794] Suspending console(s)
> >> >[  951.776277] pnp: Device 00:0c disabled.
> >> >[  951.776673] pnp: Device 00:0a disabled.
> >> >[  951.776984] pnp: Device 00:09 disabled.
> >> >[  951.777306] pnp: Device 00:08 disabled.
> >> >[  951.777786] ACPI: PCI interrupt for device 0000:00:11.5 disabled
> >> >[  951.995359] ACPI: PCI interrupt for device 0000:00:11.3 disabled
> >> >[  952.006094] ACPI: PCI interrupt for device 0000:00:11.2 disabled
> >> >[  952.022243] ACPI handle has no context!
> >> >[  952.033068] ACPI: PCI interrupt for device 0000:00:0c.2 disabled
> >> >[  952.044086] ACPI: PCI interrupt for device 0000:00:0c.1 disabled
> >> >[  952.055083] ACPI: PCI interrupt for device 0000:00:0c.0 disabled
> >> >[  952.282211] ACPI: PCI interrupt for device 0000:00:0a.1 disabled
> >> >[  952.282221] ACPI handle has no context!
> >> >[  952.537474] ACPI: PCI interrupt for device 0000:00:0a.0 disabled
> >> >[  952.537495] ACPI handle has no context!
> >> >
> >> >[  956.857085] Back to C!
> >
> > Are you sure that is standby? Looks like suspend-to-RAM to me.
>
> It's S1 (power-on suspend/standby), my BIOS/motherboard doesn't support S2 or S3.
>
> --
> Simon Arlott
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
