From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [BUG] 2.6.24-rc8 broke warm reboots on ASUS P5B-E Plus
Date: Fri, 18 Jan 2008 21:00:39 +0100
Message-ID: <18321.1383.662315.709280@harpo.it.uu.se>
References: <18319.54046.912597.487844@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:55940 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760847AbYARUBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 15:01:05 -0500
In-Reply-To: <18319.54046.912597.487844@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2008 23:13:50 +0100, Mikael Pettersson wrote:
 > The problematic machine has an Intel P965/ICH8R based ASUS P5B-E Plus
 > mainboard with a Core2Duo 6600 processor. Kernels up to and including
 > 2.6.24-rc7 work fine on it.
 > 
 > Kernel 2.6.24-rc8 boots Ok, but if I try to do a warm reboot after
 > having run 2.6.24-rc8, the BIOS hangs. The initial BIOS screen shows:
 > 
 > <BIOS version>
 > <CPU identification>
 > <lists hotkeys>
 > <identifies RAM>
 > <initialises USB controllers>
 > [here it always hangs after having run 2.6.24-rc8]
 > <RAM test>
 > <identifies ATA disks>
 > 
 > Pressing reset will not fix the hang, nor will powering the machine
 > down using the mainboard's power button. The only thing that works is
 > to switch the PSU off, wait a few seconds, switch the PSU on again,
 > and then press the mainboard's power button.
 > 
 > Both the 32-bit and 64-bit 2.6.24-rc8 x86 kernels cause this problem,
 > and it's 100% repeatable.
 > 
 > I'll try to do some rc7->rc8 bisecting tomorrow.

I've now narrowed it down to the following change in 2.6.24-rc7-git5:
84cd2dfb04d23a961c5f537baa243fa54d0987ac

>sky2: remove check for PCI wakeup setting from BIOS
>
>The driver checks status of PCI power management to mark
>default setting of Wake On Lan. On some systems this works, but often
>it reports a that WOL is disabled when it isn't.
>
>This patch gets rid of that check and just reports the wake on
>lan status based on the hardware capablity.
>
>Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>Signed-off-by: Jeff Garzik <jeff@garzik.org>

Reverting this eliminates the abovementioned BIOS hang.

I added a debug printk to sky2_init_netdev(), and it showed:

sky2_init_netdev: wol == 0x0, (sky2_wol_supported(hw) & WAKE_MAGIC) == 0x20

That is, 2.6.24-rc7-git4 and earlier drivers would set sky2->wol to 0,
while 2.6.24-rc7-git5 and newer will set it to 0x20. A quick look through
sky2.c shows that this will affect HW programming in several places.

Please revert or fix before 2.6.24 final.

lspci -vvxxx included below.

/Mikael

02:00.0 Ethernet controller: Marvell Technology Group Ltd. Unknown device 4364 (rev 12)
        Subsystem: ASUSTeK Computer Inc. Unknown device 81f8
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size 08
        Interrupt: pin A routed to IRQ 17
        Region 0: Memory at ff9fc000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at c800 [size=256]
        Expansion ROM at ff9c0000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express Legacy Endpoint IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
                Link: Latency L0s <256ns, L1 unlimited
                Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
00: ab 11 64 43 07 00 10 00 12 00 00 02 08 00 00 00
10: 04 c0 9f ff 00 00 00 00 01 c8 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 f8 81
30: 00 00 9c ff 48 00 00 00 00 00 00 00 0a 01 00 00
40: 00 00 f0 01 00 80 a0 01 01 50 03 fe 00 20 00 13
50: 03 5c 00 80 00 00 00 01 00 00 00 01 05 e0 80 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 70 00 00 00 00 00 00 82 a8 e8 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 10 00 11 00 c0 8f 00 00 00 20 19 00 11 ac 07 00
f0: 48 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
