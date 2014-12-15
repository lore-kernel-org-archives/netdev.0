From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Mon, 15 Dec 2014 13:06:50 -0200
Message-ID: <548EF90A.5070607@gmail.com>
References: <20141213210251.GA12812@teela.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	rajatxjain@gmail.com
To: Nils Holland <nholland@tisys.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20141213210251.GA12812@teela.fritz.box>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-12-2014 19:02, Nils Holland wrote:
> rajatxjain@gmail.com
> Bcc:
> Subject: Re: [bisected] tg3 broken in 3.18.0?
> Reply-To:
> In-Reply-To: <20141212.201831.186234837340644301.davem@davemloft.net>
>
> On Fri, Dec 12, 2014 at 08:18:31PM -0500, David Miller wrote:
>> From: Nils Holland <nholland@tisys.org>
>> Date: Sat, 13 Dec 2014 02:14:08 +0100
>>
>>>
>>> My bisect exercise suggests that the following commit is the culprit:
>>>
>>> 89665a6a71408796565bfd29cfa6a7877b17a667 (PCI: Check only the Vendor
>>> ID to identify Configuration Request Retry)
>>
>> You definitely need to bring this up with the author of that change
>> and the relevent list for the PCI subsystem and/or linux-kernel.
>
> I've now already sent an inquiry to Rajat Jain, the author of the
> patch in question, and this message here is now also CC'd to
> linux-pci@.
>
> With this message, I'd like to add one last result of investigation
> I've done today, in the hope that it will aid the folks with more
> knowledge to go after the issue.

FWIW, reverting this change fixes tg3 in here too.

Thanks Nils for doing the bisect!

With these debugs (note the re-revert):

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c 

index 2306268..4474502 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1436,14 +1436,22 @@ bool pci_bus_read_dev_vendor_id(struct pci_bus *bus, 
int devfn, u32 *l,
                 return false;

         /* Configuration request Retry Status */
-       while (*l == 0xffff0001) {
-               if (!crs_timeout)
+       printk ("pci %04x:%02x:%02x.%d: 1st %x %x\n", pci_domain_nr(bus), 
bus->number,
+               PCI_SLOT(devfn), PCI_FUNC(devfn), *l, *l & 0xffff);
+       while ((*l & 0xffff) == 0x0001) {
+               if (!crs_timeout) {
+                       printk ("pci %04x:%02x:%02x.%d: crs_timeout: %d\n", 
pci_domain_nr(bus),
+                               bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn), 
crs_timeout);
                         return false;
+               }

                 msleep(delay);
                 delay *= 2;
-               if (pci_bus_read_config_dword(bus, devfn, PCI_VENDOR_ID, l))
+               if (pci_bus_read_config_dword(bus, devfn, PCI_VENDOR_ID, l)) {
+                       printk ("pci %04x:%02x:%02x.%d: 
pci_bus_read_config_dword failed\n", pci_domain_nr(bus),
+                               bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn));
                         return false;
+               }
                 /* Card hasn't responded in 60 seconds?  Must be stuck. */
                 if (delay > crs_timeout) {
                         printk(KERN_WARNING "pci %04x:%02x:%02x.%d: not 
responding\n",
@@ -1451,6 +1459,7 @@ bool pci_bus_read_dev_vendor_id(struct pci_bus *bus, int 
devfn, u32 *l,
                                PCI_FUNC(devfn));
                         return false;
                 }
+               printk ("pci %04x:%02x:%02x.%d: %x %x\n", pci_domain_nr(bus), 
bus->number, PCI_SLOT(devfn), PCI_FUNC(devfn), *l, *l & 0xffff);
         }

         return true;

I'm getting, with commit 89665a6a71408796565bfd29cfa6a7877b17a667:

$ grep 'pci 0000:02' tg3.bad
[    0.190733] pci 0000:02:00.0: 1st 165a14e4 14e4
[    0.190736] pci 0000:02:00.0: 1st 165a14e4 14e4
[    0.190810] pci 0000:02:00.0: [14e4:165a] type 00 class 0x020000
[    0.190885] pci 0000:02:00.0: reg 0x10: [mem 0xf7c40000-0xf7c4ffff 64bit]
[    0.191048] pci 0000:02:00.0: reg 0x30: [mem 0xf7c00000-0xf7c3ffff pref]
[    0.191382] pci 0000:02:00.0: PME# supported from D3hot D3cold
[    0.191438] pci 0000:02:00.0: System wakeup disabled by ACPI
[    1.561555] pci 0000:02:00.0: 1st 1 1
[    1.561558] pci 0000:02:00.0: crs_timeout: 0
[   20.412021] pci 0000:02:00.0: 1st 1 1
[   20.412022] pci 0000:02:00.0: crs_timeout: 0
[   20.413596] pci 0000:02:00.0: 1st 1 1
[   20.413598] pci 0000:02:00.0: crs_timeout: 0

And without it:

$ grep 'pci 0000:02' tg3.good
[    0.190734] pci 0000:02:00.0: 1st 165a14e4 14e4
[    0.190738] pci 0000:02:00.0: 1st 165a14e4 14e4
[    0.190811] pci 0000:02:00.0: [14e4:165a] type 00 class 0x020000
[    0.190884] pci 0000:02:00.0: reg 0x10: [mem 0xf7c40000-0xf7c4ffff 64bit]
[    0.191047] pci 0000:02:00.0: reg 0x30: [mem 0xf7c00000-0xf7c3ffff pref]
[    0.191380] pci 0000:02:00.0: PME# supported from D3hot D3cold
[    0.191439] pci 0000:02:00.0: System wakeup disabled by ACPI
[    1.576778] pci 0000:02:00.0: 1st 1 1
[   19.068517] pci 0000:02:00.0: 1st 165a14e4 14e4

Hope that helps!

   Marcelo
