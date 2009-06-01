From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] 2.6.30rc7: ksoftirqd CPU saturation (x86-64 only,
 not x86-32) (e1000e-related?)
Date: Mon, 1 Jun 2009 09:48:18 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.1.10.0906010941170.656@jbrandeb-MOBL1.amr.corp.intel.com>
References: <87prdozxns.fsf@hades.wkstn.nix>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Nix <nix@esperi.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46449 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbZFAQsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2009 12:48:18 -0400
In-Reply-To: <87prdozxns.fsf@hades.wkstn.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 31 May 2009, Nix wrote:
> I've just compiled a 64-bit kernel for a couple of quad-core Nehalems
> (one L5520, one Core i7) for the first time. Both were using 32-bit
> kernels happily before, and one (the Core i7) is happy afterwards: but
> the other sees two ksoftirqd threads saturating the CPU (well, half of
> it, this being a 4-core box).

<snip>

> So, not particularly informative.
> 
> CPUs 3 and 5 seem to be receiving the lion's share of the local timer
> interrupts and networking interrupts (this box has twin e1000es):
> 
>        CPU0  CPU1    CPU2   CPU3   CPU4   CPU5   CPU6  CPU7
>   0:     33     0       0   2377      0      0      0     0   IO-APIC-edge      timer
>   1:      0     0       0      2      0      0      0     0   IO-APIC-edge      i8042
>   3:      0     0       0      3      0      0      0     0   IO-APIC-edge
>   4:      0     0       0    372      0      0      0     0   IO-APIC-edge      serial
>   8:      0     0       0     52      0      0      0     0   IO-APIC-edge      rtc0
>  12:      0     0       0      4      0      0      0     0   IO-APIC-edge      i8042
>  16:      0     0       0      0      0      0      0     0   IO-APIC-fasteoi   uhci_hcd:usb3
>  18:      0     0       0      0      0      0      2     0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb8
>  19:      0     0       0      0      0      0      0     0   IO-APIC-fasteoi   uhci_hcd:usb5, uhci_hcd:usb7
>  20:      0     0       0      0      0      0      0     0   IO-APIC-fasteoi   acpi
>  21:      0     0       0      0     70      0      0     0   IO-APIC-fasteoi   uhci_hcd:usb4, firewire_ohci
>  22:      0     0       0      0      0    228      0     0   IO-APIC-fasteoi   HDA Intel
>  23:      0     0       0      0     67      0      0     0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
>  39:      0     0   22405      0      0      0      0     0   IO-APIC-fasteoi   arcmsr
>  48:      0     0       0      0      0      0      0     0  DMAR_MSI-edge      dmar0
>  56:      0     0       0   3961      0      0      0     0   PCI-MSI-edge      ahci
>  57:      0     0       0   7654      0      0      0     0   PCI-MSI-edge      gordianet-rx-0
>  58:      0     0       0      0   8065      0      0     0   PCI-MSI-edge      gordianet-tx-0
>  59:      0     0       0      0      3      0      0     0   PCI-MSI-edge      gordianet
>  60:      0     0       0      0      0   3576      0     0   PCI-MSI-edge      fastnet-rx-0
>  61:      0     0       0      0      0   2555      0     0   PCI-MSI-edge      fastnet-tx-0
>  62:      0     0       0      0      0      0      2     0   PCI-MSI-edge      fastnet

where is the e1000e interrupt here?  I was expecting to see eth0/eth1

> NMI:      0     0       0      0      0      0      0     0   Non-maskable interrupts
> LOC:   8437  2263    6528  60480  13987 113384  16365 57641   Local timer interrupts
> SPU:      0     0       0      0      0      0      0     0   Spurious interrupts
> RES:   3790    55    6780     18   2370    115    893   161   Rescheduling interrupts
> CAL:     83   176     144    155    174    179    173   169   Function call interrupts
> TLB:    125     9     138      4    282     22    310    22   TLB shootdowns
> TRM:      0     0       0      0      0      0      0     0   Thermal event interrupts
> THR:      0     0       0      0      0      0      0     0   Threshold APIC interrupts
> ERR:      0
> MIS:      0
> 
> I'd not expect that level of e1000e interrupt activity to flood the
> ksoftirqds like this, and in 32-bit mode it doesn't.
> 
> So, anyone know what's going on, or how I could find out?

when you went into 64 bit mode your kernel enabled the IOMMU/DMAR, which 
means that map/unmap cycles are taking many more cycles per packet, 
accounting for the increased CPU utilization.  you can disable at boot 
with intel_iommu=off to see if it goes back to previous behavior.

There is no DMAR/IOMMU in 32 bit mode, AFAIK.

Hope this helps,
 Jesse
