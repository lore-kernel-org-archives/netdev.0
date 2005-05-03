From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Mystery packet killing tg3
Date: Tue, 3 May 2005 14:05:28 -0700
Message-ID: <20050503140528.1bd2ac74@dxpl.pdx.osdl.net>
References: <20050502162405.65dfb4a9@localhost.localdomain>
	<20050502200251.38271b61.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050502200251.38271b61.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 May 2005 20:02:51 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Mon, 2 May 2005 16:24:05 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > While I was on vacation, OSDL did some networking changes that seems to aggravate some
> > existing bug in the tg3 driver. Could be some VLAN related garbage, not sure.
> > 
> > System is 2 CPU AMD64 and the tg3 is on the motherboard.
> > 
> > I am seeing messages like:
> >  eth0: Tigon3 [partno(BCM95703A30) rev 1002 PHY(5703)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:60:53:08:18
> >  eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0] 
> >  tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2
> > 
> > Any clues?
> 
> This usually means that there is some DMA corruption.
> For example, some bug in the x86_64 IOMMU code or similar
> causes a bogus DMA address to be fed to the tg3 or even
> worse a DMA mapping is unmapped before tg3 is actually
> done with it.
> 
> Please try to get some more debugging.  One thing that might
> be useful would be a dump of the PCI config and PCI status
> registers from PCI config space when that tg3_stop_block
> event triggers.  It will tell us if there was a master or
> slave abort on the PCI bus which would confirm my above
> theory.

Added call to tg_dump_state()

tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2
DEBUG: PCI status [02b0] TG3PCI state[000010e2]
DEBUG: MAC_MODE[00c04c08] MAC_STATUS[00400003]
       MAC_EVENT[00001000] MAC_LED_CTRL[00000880]
DEBUG: MAC_TX_MODE[00000010] MAC_TX_STATUS[00000008]
       MAC_RX_MODE[00000004] MAC_RX_STATUS[00000000]
DEBUG: SNDDATAI_MODE[00000000] SNDDATAI_STATUS[00000000]
       SNDDATAI_STATSCTRL[00000003]
DEBUG: SNDDATAC_MODE[00000000]
DEBUG: SNDBDS_MODE[00000004] SNDBDS_STATUS[00000000]
DEBUG: SNDBDI_MODE[00000004] SNDBDI_STATUS[00000000]
DEBUG: SNDBDC_MODE[00000000]
DEBUG: RCVLPC_MODE[00000000] RCVLPC_STATUS[00000000]
       RCVLPC_STATSCTRL[00000001]
DEBUG: RCVDBDI_MODE[00000010] RCVDBDI_STATUS[00000000]
DEBUG: RCVDCC_MODE[00000004]
DEBUG: RCVBDI_MODE[00000004] RCVBDI_STATUS[00000000]
DEBUG: RCVCC_MODE[00000004] RCVCC_STATUS[00000000]
DEBUG: RCVLSC_MODE[00000004] RCVLSC_STATUS[00000000]
DEBUG: MBFREE_MODE[00000000] MBFREE_STATUS[00000000]
DEBUG: HOSTCC_MODE[00000100] HOSTCC_STATUS[00000000]
DEBUG: HOSTCC_STATS_BLK_HOST_ADDR[0000000006bb8000]
DEBUG: HOSTCC_STATUS_BLK_HOST_ADDR[000000001ce8c000]
DEBUG: HOSTCC_STATS_BLK_NIC_ADDR[00000300]
DEBUG: HOSTCC_STATUS_BLK_NIC_ADDR[00000b00]
DEBUG: MEMARB_MODE[00000002] MEMARB_STATUS[00000000]
DEBUG: BUFMGR_MODE[00000004] BUFMGR_STATUS[00000000]
DEBUG: BUFMGR_MB_POOL_ADDR[00008000] BUFMGR_MB_POOL_SIZE[00018000]
DEBUG: BUFMGR_DMA_DESC_POOL_ADDR[00002000] BUFMGR_DMA_DESC_POOL_SIZE[00002000]
DEBUG: RDMAC_MODE[000003fc] RDMAC_STATUS[00000000]
DEBUG: WDMAC_MODE[000003fc] WDMAC_STATUS[00000000]
DEBUG: DMAC_MODE[00000000]
DEBUG: GRC_MODE[04130034] GRC_MISC_CFG[00081082]
DEBUG: GRC_LOCAL_CTRL[01000209]
DEBUG: RCVDBDI_JUMBO_BD[0000000000000000:00000002:00000000]
DEBUG: RCVDBDI_STD_BD[000000002d1c4000:06000000:00006000]
DEBUG: RCVDBDI_MINI_BD[0000000000000000:00000002:00000000]


> Also what PCI controller is in this box?  (ie. the north bridge,
> lspci -v would tell)

00:06.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8111 PCI (rev 07) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=69
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: c0100000-c01fffff
	Capabilities: [c0] HyperTransport: Slave or Primary Interface
	Capabilities: [f0] HyperTransport: Interrupt Discovery and Configuration

00:07.0 ISA bridge: Advanced Micro Devices [AMD] AMD-8111 LPC (rev 05)
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, 66Mhz, medium devsel, latency 0

00:07.1 IDE interface: Advanced Micro Devices [AMD] AMD-8111 IDE (rev 03) (prog-if 8a [Master SecP PriP])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 64
	I/O ports at 1460 [size=16]

00:07.2 SMBus: Advanced Micro Devices [AMD] AMD-8111 SMBus 2.0 (rev 02)
	Subsystem: IBM: Unknown device 02b7
	Flags: medium devsel, IRQ 11
	I/O ports at 1440 [size=32]

00:07.3 Bridge: Advanced Micro Devices [AMD] AMD-8111 ACPI (rev 05)
	Subsystem: IBM: Unknown device 02b7
	Flags: medium devsel

00:07.5 Multimedia audio controller: Advanced Micro Devices [AMD] AMD-8111 AC97 Audio (rev 03)
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 64, IRQ 169
	I/O ports at 1000 [size=256]
	I/O ports at 1400 [size=64]

00:0a.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=64
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: c0200000-c02fffff
	Capabilities: [a0] PCI-X bridge device.
	Capabilities: [b8] HyperTransport: Interrupt Discovery and Configuration
	Capabilities: [c0] HyperTransport: Slave or Primary Interface

00:0a.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X APIC (rev 01) (prog-if 10 [IO-APIC])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 0
	Memory at c0000000 (64-bit, non-prefetchable) [size=4K]

00:0b.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=64
	Memory behind bridge: c0300000-c03fffff
	Capabilities: [a0] PCI-X bridge device.
	Capabilities: [b8] HyperTransport: Interrupt Discovery and Configuration

00:0b.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X APIC (rev 01) (prog-if 10 [IO-APIC])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 0
	Memory at c0001000 (64-bit, non-prefetchable) [size=4K]

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
	Flags: fast devsel
	Capabilities: [80] HyperTransport: Host or Secondary Interface
	Capabilities: [a0] HyperTransport: Host or Secondary Interface
	Capabilities: [c0] HyperTransport: Host or Secondary Interface

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Flags: fast devsel

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Flags: fast devsel

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Flags: fast devsel

00:19.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
	Flags: fast devsel
	Capabilities: [80] HyperTransport: Host or Secondary Interface
	Capabilities: [a0] HyperTransport: Host or Secondary Interface
	Capabilities: [c0] HyperTransport: Host or Secondary Interface

00:19.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Flags: fast devsel

00:19.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Flags: fast devsel

00:19.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Flags: fast devsel

01:02.0 Unknown mass storage controller: Silicon Image, Inc. (formerly CMD Technology Inc) SiI 3512 [SATALink/SATARaid] Serial ATA Controller (rev 01) (prog-if 85)
	Subsystem: IBM: Unknown device 3512
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 169
	I/O ports at 2020 [size=8]
	I/O ports at 2014 [size=4]
	I/O ports at 2018 [size=8]
	I/O ports at 2010 [size=4]
	I/O ports at 2000 [size=16]
	Memory at c0104000 (32-bit, non-prefetchable) [size=512]
	Capabilities: [60] Power Management version 2

01:03.0 USB Controller: NEC Corporation USB (rev 43) (prog-if 10 [OHCI])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 64, IRQ 193
	Memory at c0102000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] Power Management version 2

01:03.1 USB Controller: NEC Corporation USB (rev 43) (prog-if 10 [OHCI])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 64, IRQ 201
	Memory at c0103000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [40] Power Management version 2

01:03.2 USB Controller: NEC Corporation USB 2.0 (rev 04) (prog-if 20 [EHCI])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 132, IRQ 185
	Memory at c0104400 (32-bit, non-prefetchable) [size=256]
	Capabilities: [40] Power Management version 2

02:01.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx Gigabit Ethernet Server Adapter (rev 13)
	Subsystem: Syskonnect (Schneider & Koch) SK-9821 Gigabit Ethernet Server Adapter (SK-NET GE-T)
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 10
	Memory at c0200000 (32-bit, non-prefetchable) [size=16K]
	I/O ports at 3000 [size=256]
	Capabilities: [48] Power Management version 1
	Capabilities: [50] Vital Product Data

03:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5703X Gigabit Ethernet (rev 02)
	Subsystem: IBM: Unknown device 026f
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 177
	Memory at c0300000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] PCI-X non-bridge device.
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-

08:00.0 Host bridge: Advanced Micro Devices [AMD] AMD-8151 System Controller (rev 13)
	Subsystem: IBM: Unknown device 02b7
	Flags: medium devsel
	Memory at d0000000 (32-bit, prefetchable) [size=256M]
	Capabilities: [a0] AGP version 3.0
	Capabilities: [c0] HyperTransport: Slave or Primary Interface

08:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8151 AGP Bridge (rev 13) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 99
	Bus: primary=08, secondary=09, subordinate=0d, sec-latency=68
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: c0700000-c07fffff
	Prefetchable memory behind bridge: e0000000-efffffff

08:03.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=08, secondary=0e, subordinate=12, sec-latency=64
	Capabilities: [a0] PCI-X bridge device.
	Capabilities: [b8] HyperTransport: Interrupt Discovery and Configuration
	Capabilities: [c0] HyperTransport: Slave or Primary Interface

08:03.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X APIC (rev 01) (prog-if 10 [IO-APIC])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 0
	Memory at c0600000 (64-bit, non-prefetchable) [size=4K]

08:04.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=08, secondary=13, subordinate=17, sec-latency=64
	Capabilities: [a0] PCI-X bridge device.
	Capabilities: [b8] HyperTransport: Interrupt Discovery and Configuration

08:04.1 PIC: Advanced Micro Devices [AMD] AMD-8131 PCI-X APIC (rev 01) (prog-if 10 [IO-APIC])
	Subsystem: IBM: Unknown device 02b7
	Flags: bus master, medium devsel, latency 0
	Memory at c0601000 (64-bit, non-prefetchable) [size=4K]

09:00.0 VGA compatible controller: ATI Technologies Inc Radeon R300 NG [FireGL X1] (rev 80) (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc: Unknown device 0172
	Flags: bus master, stepping, 66Mhz, medium devsel, latency 66, IRQ 5
	Memory at e0000000 (32-bit, prefetchable) [size=128M]
	I/O ports at 4000 [size=256]
	Memory at c0700000 (32-bit, non-prefetchable) [size=64K]
	Capabilities: [58] AGP version 3.0
	Capabilities: [50] Power Management version 2

09:00.1 Display controller: ATI Technologies Inc Radeon R300 [FireGL X1] (Secondary) (rev 80)
	Subsystem: ATI Technologies Inc: Unknown device 0173
	Flags: bus master, stepping, 66Mhz, medium devsel, latency 66
	Memory at e8000000 (32-bit, prefetchable) [size=128M]
	Memory at c0710000 (32-bit, non-prefetchable) [size=64K]
	Capabilities: [50] Power Management version 2



-- 
Stephen Hemminger	<shemminger@osdl.org>


> Since AMD promised me an Opteron system last year, but never
> made good on that promise, I've never been able to work on
> fixing this bug myself. :-/
