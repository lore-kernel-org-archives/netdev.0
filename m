From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skge finds PCI error cmd=0x117 status=0x22b0 in 2.6.27.7
Date: Fri, 30 Jan 2009 11:15:41 -0800
Message-ID: <20090130111541.4b570b83@extreme>
References: <1227676694.16069.78.camel@corfu>
	<20081126084805.7c0ab417@extreme>
	<1227747405.31791.17.camel@corfu>
	<1233279948.27909.33.camel@corfu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Guenther Thomsen <guenthert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36287 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752279AbZA3TPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 14:15:43 -0500
In-Reply-To: <1233279948.27909.33.camel@corfu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jan 2009 17:45:48 -0800
Guenther Thomsen <guenthert@gmail.com> wrote:

> On Wed, 2008-11-26 at 16:56 -0800, Guenther Thomsen wrote:
> 
> > On Wed, 2008-11-26 at 08:48 -0800, Stephen Hemminger wrote: 
> > 
> > > On Tue, 25 Nov 2008 21:18:14 -0800
> > > Guenther Thomsen <guenthert@gmail.com> wrote:
> > > 
> > > > Just about an hour or so after upgrading my desktop at work from 4 to
> > > > 8GiB RAM, I lost network connectivity and found following in the
> > > > kernel's message buffer:
> > > > --8<--


The driver supports >4G of memory (64 bit DMA), but sometimes the motherboard
does not. This seems to be especially true for on-motherboard devices.

> > > > Nov 24 17:06:32 corfu kernel: [  116.841025] skge 0000:03:04.0: PCI error cmd=0x117 status=0x22b0
> > > > Nov 24 17:06:32 corfu kernel: [  116.841054] skge 0000:03:04.0: unable to clear error (so ignoring them)
>
> > > > 
> > > > If there is more information I could provide, then please let me know.
> > > 
> > > The problem is your ethernet hardware is unable to access that memory above 4G.
> > > I suspect you have a motherboard which won't work with 4G or more. The skge driver
> > > will, but some of the consumer hardware is crap. There seems to be no good way to
> > > test if the hardware is 
> > > 
> > > What motherboard?
> > > 
> > > Are you running 32bit or 64bit kernel? You need to have 64bit kernel or
> > > compile with HIGHMEM64G option on 32bit.
> > > 
> > > Full lspci output would help as well. Then maybe a PCI quirk could be setup
> > > to force bounce buffer.
> > > 
> > > 
> > 
> > It's a beige box with 
> > > Hardware: Asus M2R32-MVP motherboard (ATI CrossFire Xpress 3200 / ATI
> > 
> > > > SB600 chipset) with Athlon 64 X2 4600+ CPU and Marvell 88E8001 LAN
> > > > controller on MB (autoneg. to 1000Mbps).
> > 
> > 
> > The kernel is configured/compiled to use the CPU in 64bit mode:
> > --8<--
> > CONFIG_64BIT=y
> > # CONFIG_X86_32 is not set
> > CONFIG_X86_64=y
> > CONFIG_X86=y
> > CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
> > -->8--

This looks like an on the motherboard controler.

> > 03:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit Ethernet Controller (rev 13)
> > 	Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabit Ethernet Controller (Asus)
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> > 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 64 bytes
> > 	Interrupt: pin A routed to IRQ 23
> > 	Region 0: Memory at fbffc000 (32-bit, non-prefetchable) [size=16K]
> > 	Region 1: I/O ports at e800 [size=256]
> > 	Expansion ROM at f0000000 [disabled] [size=128K]
> > 	Capabilities: <access denied>
> > 00: ab 11 20 43 17 01 b0 02 13 00 00 02 10 40 00 00
> > 10: 00 c0 ff fb 01 e8 00 00 00 00 00 00 00 00 00 00
> > 20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 1a 81
> > 30: 00 00 fc fb 48 00 00 00 00 00 00 00 03 01 17 1f
> > 
> > gthomsen@corfu:~$ lspci -vvxxx
> > -->8--
> > 
> > Is this
> > --8<--
> > 
> > 	Region 0: Memory at fbffc000 (32-bit, non-prefetchable) [size=16K]
> > -->8--
> > the bad part?
> > 
> > I guess I have to try the "iommu=soft" kernel option. I will try that after the long weekend.
> > 
> > 
> > Thanks for looking into this and happy Turkey Day!
> > 	Guenther
> 
> 
> Only a few days ago, I revisited this issue (if I'm careful, the system
> remains stable ;-}
> I tried then iommu=soft option and didn't have much luck with that. I
> even added an Intel 1000baseT NIC, with its "known good" driver, which
> yielded similar results, see below. I tried 2.6.28.1 and now 2.6.28.2
> and still get the same results.
> 
> I must admit that i couldn't find iommu=soft documented (other than the
> very brief description in Documentation/kernel-parameters.txt) and would
> have expected that it creates a bounce buffer below the magical 4GiB
> limit and that then all PCI problems in combination with addresses
> greater than 2^32 would be solved. So it appears to me, that the
> soft-iommu isn't doing it's job. Or is it? So far I noticed only
> problems with network devices.
> 

That would imply that a pci quirk should be created.
