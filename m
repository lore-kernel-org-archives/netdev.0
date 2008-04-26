From: Frans Pop <elendil@planet.nl>
Subject: Re: [git patches] ISDN cleanups (modularization prep)
Date: Sat, 26 Apr 2008 21:42:12 +0200
Message-ID: <200804262142.13596.elendil@planet.nl>
References: <20080420223959.GA17998@havoc.gtf.org> <200804212221.24586.elendil@planet.nl> <48114620.2060508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Andi Kleen <andi@firstfloor.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml11.kpnxchange.com ([213.75.38.111]:59456 "EHLO
	hpsmtp-eml11.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760742AbYDZTmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 15:42:16 -0400
In-Reply-To: <48114620.2060508@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 April 2008, Jeff Garzik wrote:
> Frans Pop wrote:
> > Also, I doubt that depmod is supposed to fail like the way I saw. Seems
> > to me that the "loop" errors during depmod are the cause of the modules
> > not being loadable.
> > Note that 'modprobe hisaxdiva' fails with the exact same message as for
> > hisax and that depmod even explicitly says that the modules are
> > "ignored"!
>
> Yeah, it looks like the ITK card is still served by the main hisax
> module (not all were converted, just the ones related to PCI).
>
> Maybe try manually modprobing libhisax and then hisaxdiva.

Even manually insmod'ing them does not work: you'll really need to resolve 
those interdependencies that cause the dependency loops first!

> Also try disabling the ITK support in Kconfig and see if that at least
> permits you to load the hisaxdiva driver.

Using a kernel with both Teles and ITK support unselected, depmod -a no 
longer complains.

First I left the old modprobe config:
options        hisax type=9,11 protocol=2,2 irq=10 io=0x398

When I modprobe hisaxdiva with that, I get:
# modprobe hisaxdiva
WARNING: Error inserting hisax 
(/lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisax.ko): No such 
device
WARNING: Error inserting libhisax 
(/lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/libhisax.ko): Unknown 
symbol in module, or unknown parameter (see dmesg)
FATAL: Error inserting hisaxdiva 
(/lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisaxdiva.ko): Unknown 
symbol in module, or unknown parameter (see dmesg)

fjp@selinux:~$ dmesg
[...]
HiSax: Linux Driver for passive ISDN cards
HiSax: Version 3.5 (module)
HiSax: Layer1 Revision 2.46.2.5
HiSax: Layer2 Revision 2.30.2.4
HiSax: TeiMgr Revision 2.20.2.3
HiSax: Layer3 Revision 2.22.2.3
HiSax: LinkLayer Revision 2.59.2.4
HiSax: Total 2 cards defined
HiSax: Card 1 Protocol EDSS1 Id=HiSax (0)
HiSax: Support for ITK ix1-micro Rev.2 Card not selected
HiSax: Card ITK ix1-micro Rev.2 not installed !
HiSax: Card 1 Protocol EDSS1 Id=HiSax (0)
HiSax: Support for Eicon.Diehl Diva Card has moved to separate PCI driver 
module
HiSax: Card Eicon.Diehl Diva not installed !
libhisax: Unknown symbol LogFrame
libhisax: Unknown symbol Logl2Frame
libhisax: Unknown symbol DChannel_proc_xmt
libhisax: Unknown symbol QuickHex
libhisax: Unknown symbol DChannel_proc_rcv
libhisax: Unknown symbol l1_msg_b
libhisax: Unknown symbol setstack_l1_B
libhisax: Unknown symbol dlogframe
libhisax: Unknown symbol l1_msg
libhisax: Unknown symbol setstack_manager
libhisax: Unknown symbol debugl1
hisaxdiva: Unknown symbol LogFrame
hisaxdiva: Unknown symbol HiSax_closecard
hisaxdiva: Unknown symbol Logl2Frame
hisaxdiva: Unknown symbol HscxVersion
hisaxdiva: Unknown symbol QuickHex
hisaxdiva: Unknown symbol hisax_init_hotplug
hisaxdiva: Unknown symbol setup_isac
hisaxdiva: Unknown symbol l1_msg_b
hisaxdiva: Unknown symbol setstack_l1_B
hisaxdiva: Unknown symbol dlogframe
hisaxdiva: Unknown symbol isac_interrupt
hisaxdiva: Unknown symbol ISACVersion
hisaxdiva: Unknown symbol inithscxisac
hisaxdiva: Unknown symbol HiSax_getrev
hisaxdiva: Unknown symbol setstack_manager
hisaxdiva: Unknown symbol hisax_pci_remove_one
hisaxdiva: Unknown symbol debugl1

lsmod does not show any isdn/hisax modules loaded after that.


I then changed the modprobe config to just:
options         hisaxdiva protocol=2

When I 'modprobe hisaxdiva' with that, the result is a lot better:
ISDN subsystem Rev: 1.1.2.3/1.1.2.3/1.1.2.2/none/none/1.1.2.2 loaded
HiSax: Linux Driver for passive ISDN cards
HiSax: Version 3.5 (module)
HiSax: Layer1 Revision 2.46.2.5
HiSax: Layer2 Revision 2.30.2.4
HiSax: TeiMgr Revision 2.20.2.3
HiSax: Layer3 Revision 2.22.2.3
HiSax: LinkLayer Revision 2.59.2.4
libhisax: module license 'unspecified' taints kernel.
HiSax: Card 1 Protocol EDSS1 Id=HiSax (0)
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
ACPI: PCI Interrupt 0000:00:0f.0[A] -> Link [LNKC] -> GSI 11 (level, low) -> 
IRQ 11
HiSax: Eicon.Diehl Diva driver Rev. 1.33.2.6
Diva: IPAC PCI card configured at 0xc8cc2000 IRQ 11
Diva: IPAC PCI space at 0xc8cc0000
Diva: IPAC version ff
Eicon.Diehl Diva: IRQ 11 count 746
Eicon.Diehl Diva: IRQ 11 count 752
HiSax: DSS1 Rev. 2.32.2.3
HiSax: 2 channels added
HiSax: MAX_WAITING_CALLS added
HiSax: if_command 6 called with invalid driverId 0!
HiSax: if_command 6 called with invalid driverId 0!

Issues I can see in this dmesg output:
- the module licence warning for libhisax
- I've never seen the last two lines before

Otherwise the driver seems to have loaded correctly and lsmod now shows:
Module                  Size  Used by
hisaxdiva              27564  0
libhisax               27872  1 hisaxdiva
hisax                 113924  2 hisaxdiva,libhisax
isdn                   70096  1 hisax
crc_ccitt               2144  1 libhisax

Cheers,
FJP
