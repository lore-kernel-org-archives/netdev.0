From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Fri, 16 Mar 2012 22:15:57 +0200
Message-ID: <20120316221557.235f5ffd@vostro>
References: <20120314190156.622c8cd5@vostro>
	<1331745314.6022.27.camel@edumazet-glaptop>
	<20120314192945.65867e9f@vostro>
	<1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
	<20120314215142.655ae607@vostro>
	<1331755965.6022.55.camel@edumazet-glaptop>
	<20120314223343.23dc9df3@vostro>
	<20120314205319.GA28394@electric-eye.fr.zoreil.com>
	<20120315080635.1f76512b@vostro>
	<20120315171148.0050714d@vostro>
	<20120315191118.GA19809@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40635 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757577Ab2CPUQh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 16:16:37 -0400
Received: by wejx9 with SMTP id x9so4279431wej.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 13:16:36 -0700 (PDT)
In-Reply-To: <20120315191118.GA19809@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Mar 2012 20:11:18 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Timo Teras <timo.teras@iki.fi> :
> [...]
> > The other broken box is connected to a HP ProCurve 4202vl-48G, and
> > the switch is reporting drops due to FCS Rx errors.
> [...]
> > So I have two broken pieces of hardware, or there is a driver bug.
> 
> I'll take blame for any bug in the driver. However many ethernet
> controllers are and the PCI 8169 is no exception.

Ok.

As a side though, all these devices suffered from the bug I fixed
earlier. See commit 024a07bac (r8169: fix random mdio_write failures).
Also, all these devices probably got garbage written to their PHY. So
I'm wondering if it is possible that it caused some permanent damage?

Would it be possible to dump/compare the related things?

Additional pointer to this direction is that one of the "broken" boxes
has different PCI ID for the "broken NIC" of the three. The hardware is
Jetway daughter board with the three NICs on single board. So it sounds
really weird that one of those NICs chips would be from different
series. I wonder if the PCI ID and other stuff could have got corrupted
in EEPROM or something similar.

> > I'll try upgrading my kernel to 3.0.x series on the sender box and
> > see if it's fixing anything. Suggestions for further testing would
> > be appreciated.
> 
> Please check you are using nothing but SLAB.

Using SLUB, the current kernel default. Can retry with SLAB later.

> If you have not done so, you may then disable Tx checksumming.

Tx checksumming is off.
 
> If it does not change anything, you may consider using the r8169 from
> David Miller's -next branch (backported ? no, no, the real thing). If
> it still does not change anything and you are interested in new
> experiences, please confirm you are above 18 and we may use Ben
> Grear's bad rx packets capture (available in -next) and the port
> mirroring feature of your switch to see what the corrupted tx frames
> look like. Before that, I would welcome a short description of the
> router boxes (lspci, proc, etc) and overall traffic / irq.

Ah, I see the good stuff. Will try to do capture of the FCS on broken
link. And I'll try to relocate the broken hardware to lab environment
where this can be easier reproduced and debugged.

>From the system with one NIC showing wrong PCI id (but XID and
boottime detection is identical for all these):

# lspci -nn 
00:00.0 Host bridge [0600]: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge [1106:0314]
00:00.1 Host bridge [0600]: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge [1106:1314]
00:00.2 Host bridge [0600]: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge [1106:2314]
00:00.3 Host bridge [0600]: VIA Technologies, Inc. PT890 Host Bridge [1106:3208]
00:00.4 Host bridge [0600]: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge [1106:4314]
00:00.7 Host bridge [0600]: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge [1106:7314]
00:01.0 PCI bridge [0604]: VIA Technologies, Inc. VT8237/VX700 PCI Bridge [1106:b198]
00:09.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet [10ec:8167] (rev 10)
00:0a.0 FireWire (IEEE 1394) [0c00]: VIA Technologies, Inc. VT6306 Fire II IEEE 1394 OHCI Link Layer Controller [1106:3044] (rev 80)
00:0b.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)
00:0c.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet [10ec:8167] (rev 10)
00:0f.0 IDE interface [0101]: VIA Technologies, Inc. VIA VT6420 SATA RAID Controller [1106:3149] (rev 80)
00:0f.1 IDE interface [0101]: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE [1106:0571] (rev 06)
00:10.0 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 81)
00:10.1 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 81)
00:10.2 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 81)
00:10.3 USB Controller [0c03]: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller [1106:3038] (rev 81)
00:10.4 USB Controller [0c03]: VIA Technologies, Inc. USB 2.0 [1106:3104] (rev 86)
00:11.0 ISA bridge [0601]: VIA Technologies, Inc. VT8237 ISA bridge [KT600/K8T800/K8T890 South] [1106:3227]
00:11.5 Multimedia audio controller [0401]: VIA Technologies, Inc. VT8233/A/8235/8237 AC97 Audio Controller [1106:3059] (rev 60)
00:12.0 Ethernet controller [0200]: VIA Technologies, Inc. VT6102 [Rhine-II] [1106:3065] (rev 78)
01:00.0 VGA compatible controller [0300]: VIA Technologies, Inc. CN700/P4M800 Pro/P4M800 CE/VN800 [S3 UniChrome Pro] [1106:3344] (rev 01)

# grep eth /var/log/dmesg 
r8169 0000:00:09.0: eth0: RTL8169sc/8110sc at 0xf81fe000, 00:30:18:a8:14:ac, XID 18000000 IRQ 18
r8169 0000:00:0b.0: eth1: RTL8169sc/8110sc at 0xf8202000, 00:30:18:ab:69:4b, XID 18000000 IRQ 19
r8169 0000:00:0c.0: eth2: RTL8169sc/8110sc at 0xf8206000, 00:30:18:a8:14:ad, XID 18000000 IRQ 16
eth3: VIA Rhine II at 0x1e800, 00:30:18:a0:d5:53, IRQ 23.
eth3: MII PHY found at address 1, status 0x7849 advertising 05e1 Link 0000.

# cat /proc/cpuinfo 
processor	: 0
vendor_id	: CentaurHauls
cpu family	: 6
model		: 13
model name	: VIA Eden Processor 1200MHz
stepping	: 0
cpu MHz		: 1199.906
cache size	: 128 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce apic mtrr pge cmov pat clflush acpi mmx fxsr sse sse2 tm nx up pni est tm2 xtpr rng rng_en ace ace_en ace2 ace2_en phe phe_en pmm pmm_en
bogomips	: 2400.80
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 32 bits virtual
power management:
