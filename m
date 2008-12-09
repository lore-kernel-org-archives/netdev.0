From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: bnx2x machine check in bnx2x_ack_int()
Date: Tue, 9 Dec 2008 12:04:35 -0700
Message-ID: <200812091204.35296.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:41424 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbYLITEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 14:04:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eilon,

I'm using bnx2x 1.45.23 from RHEL5.3s4 on a prototype ia64 platform,
and I see intermittent machine checks at bnx2x_ack_int+176, which is
just after __ia64_readl() returns.

This is a proto with incomplete firmware, and the driver correctly
complains about that, but it seems like there's still a hole where
things blow up.

The machine check happens intermittently on boot, but I can reproduce
it instantly with a loop like this:

  # while /bin/true; do ifup eth6; date; done

Here's some lspci and dmesg information.  I added a little debug in
bnx2x_ack_int(), so this is a kernel I compiled myself.

Let me know if there's any information I can collect or testing I
can do.

Thanks,
  Bjorn



0001:80:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Subsystem: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Flags: fast devsel, IRQ 56
        Memory at 40020000000 (64-bit, non-prefetchable) [disabled] [size=8M]
        Memory at 40020800000 (64-bit, non-prefetchable) [disabled] [size=8M]
        Capabilities: [48] Power Management version 3
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
        Capabilities: [a0] MSI-X: Enable- Mask- TabSize=1
        Capabilities: [ac] Express Endpoint IRQ 0
        Capabilities: [100] Device Serial Number 00-00-00-00-00-00-00-00
        Capabilities: [110] Advanced Error Reporting
        Capabilities: [150] Power Budgeting
        Capabilities: [160] Virtual Channel

0001:80:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Subsystem: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Flags: fast devsel, IRQ 86
        Memory at 40021000000 (64-bit, non-prefetchable) [disabled] [size=8M]
        Memory at 40021800000 (64-bit, non-prefetchable) [disabled] [size=8M]
        Capabilities: [48] Power Management version 3
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
        Capabilities: [a0] MSI-X: Enable- Mask- TabSize=1
        Capabilities: [ac] Express Endpoint IRQ 0
        Capabilities: [100] Device Serial Number 00-00-00-00-00-00-00-00
        Capabilities: [110] Advanced Error Reporting
        Capabilities: [150] Power Budgeting
        Capabilities: [160] Virtual Channel

0007:80:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Subsystem: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Flags: bus master, fast devsel, latency 0, IRQ 66
        Memory at 40320000000 (64-bit, non-prefetchable) [size=8M]
        Memory at 40320800000 (64-bit, non-prefetchable) [size=8M]
        Capabilities: [48] Power Management version 3
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
        Capabilities: [a0] MSI-X: Enable- Mask- TabSize=1
        Capabilities: [ac] Express Endpoint IRQ 0
        Capabilities: [100] Device Serial Number 00-00-00-00-00-00-00-00
        Capabilities: [110] Advanced Error Reporting
        Capabilities: [150] Power Budgeting
        Capabilities: [160] Virtual Channel

0007:80:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Subsystem: Broadcom Corporation NetXtreme II BCM57710 10Gigabit PCIe [Everest]
        Flags: bus master, fast devsel, latency 0, IRQ 87
        Memory at 40321000000 (64-bit, non-prefetchable) [size=8M]
        Memory at 40321800000 (64-bit, non-prefetchable) [size=8M]
        Capabilities: [48] Power Management version 3
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
        Capabilities: [a0] MSI-X: Enable- Mask- TabSize=1
        Capabilities: [ac] Express Endpoint IRQ 0
        Capabilities: [100] Device Serial Number 00-00-00-00-00-00-00-00
        Capabilities: [110] Advanced Error Reporting
        Capabilities: [150] Power Budgeting
        Capabilities: [160] Virtual Channel

Linux version 2.6.18-124.el5 (root@tahiti.helgaas) (gcc version 4.1.2 20080704 (Red Hat 4.1.2-44)) #10 SMP Fri Dec 5 12:57:00 MST 2008
...
Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver bnx2x 1.45.23 (2008/11/03)
ACPI: PCI Interrupt 0001:80:00.0[A] -> GSI 33 (level, low) -> IRQ 56
[bnx2x_get_hwinfo:7490(eth0)]warning random MAC workaround active
bnx2x: MCP disabled, must load devices in order!
eth0: Broadcom NetXtreme II BCM57710 XGb (A1) PCI-E x8 2.5GHz found at mem 40020000000, IRQ 56, node addr 5a12c9643ce9
GSI 34 (level, low) -> CPU 5 (0x1100) vector 86
ACPI: PCI Interrupt 0001:80:00.1[B] -> GSI 34 (level, low) -> IRQ 86
[bnx2x_get_hwinfo:7490(eth1)]warning random MAC workaround active
eth1: Broadcom NetXtreme II BCM57710 XGb (A1) PCI-E x8 2.5GHz found at mem 40021000000, IRQ 86, node addr 3a7a42d2f596
ACPI: PCI Interrupt 0007:80:00.0[A] -> GSI 201 (level, low) -> IRQ 66
[bnx2x_get_hwinfo:7490(eth2)]warning random MAC workaround active
bnx2x: MCP disabled, must load devices in order!
eth2: Broadcom NetXtreme II BCM57710 XGb (A1) PCI-E x8 2.5GHz found at mem 40320000000, IRQ 66, node addr 02af31dabdd3
GSI 202 (level, low) -> CPU 6 (0x1200) vector 87
ACPI: PCI Interrupt 0007:80:00.1[B] -> GSI 202 (level, low) -> IRQ 87
[bnx2x_get_hwinfo:7490(eth3)]warning random MAC workaround active
eth3: Broadcom NetXtreme II BCM57710 XGb (A1) PCI-E x8 2.5GHz found at mem 40321000000, IRQ 87, node addr ae914301e30b
...

Bringing up interface eth6:  
Determining IP information for eth6...bnx2x_ack_int bp 0xe0001140f8972500 hc_addr 0x108198 addr 0xc000040020108198
[bnx2x_init_common:5394(eth6)]Bootcode is missing - can not initialize link
[bnx2x__link_reset:2001(eth6)]Bootcode is missing -not resetting link
bnx2x_ack_int bp 0xe0001140f8972500 hc_addr 0x108198 addr 0xc000040020108198
[bnx2x_initial_phy_init:1978(eth6)]Bootcode is missing -not initializing link
bnx2x_ack_int bp 0xe0001140f8972500 hc_addr 0x108198 addr 0xc000040020108198
bnx2x_ack_int bp 0xe0001140f8972500 hc_addr 0x108198 addr 0xc000040020108198
ADDRCONF(NETDEV_UP): eth6: link is not ready
 failed; no link present.  Check cable?
bnx2x_ack_int bp 0xe0001140f8972500 hc_addr 0x108198 addr 0xc000040020108198
[bnx2x__link_reset:2001(eth6)]Bootcode is missing -not resetting link
[FAILED]
Bringing up interface eth7:  
Determining IP information for eth7...bnx2x_ack_int bp 0xe0001140f8970500 hc_addr 0x1081b8 addr 0xc0000400211081b8
[bnx2x_init_common:5394(eth7)]Bootcode is missing - can not initialize link
[bnx2x__link_reset:2001(eth7)]Bootcode is missing -not resetting link
bnx2x_ack_int bp 0xe0001140f8970500 hc_addr 0x1081b8 addr 0xc0000400211081b8
[bnx2x_initial_phy_init:1978(eth7)]Bootcode is missing -not initializing link
bnx2x_ack_int bp 0xe0001140f8970500 hc_addr 0x1081b8 addr 0xc0000400211081b8
bnx2x_ack_int bp 0xe0001140f8970500 hc_addr 0x1081b8 addr 0xc0000400211081b8
ADDRCONF(NETDEV_UP): eth7: link is not ready
 failed; no link present.  Check cable?
bnx2x_ack_int bp 0xe0001140f8970500 hc_addr 0x1081b8 addr 0xc0000400211081b8
[bnx2x__link_reset:2001(eth7)]Bootcode is missing -not resetting link
[FAILED]
Bringing up interface eth8:  
Determining IP information for eth8...bnx2x_ack_int bp 0xe0001140f896e500 hc_addr 0x108198 addr 0xc000040320108198
[bnx2x_init_common:5394(eth8)]Bootcode is missing - can not initialize link
[bnx2x__link_reset:2001(eth8)]Bootcode is missing -not resetting link
bnx2x_ack_int bp 0xe0001140f896e500 hc_addr 0x108198 addr 0xc000040320108198
[bnx2x_initial_phy_init:1978(eth8)]Bootcode is missing -not initializing link
bnx2x_ack_int bp 0xe0001140f896e500 hc_addr 0x108198 addr 0xc000040320108198
bnx2x_ack_int bp 0xe0001140f896e500 hc_addr 0x108198 addr 0xc000040320108198
ADDRCONF(NETDEV_UP): eth8: link is not ready
 failed; no link present.  Check cable?
bnx2x_ack_int bp 0xe0001140f896e500 hc_addr 0x108198 addr 0xc000040320108198
[bnx2x__link_reset:2001(eth8)]Bootcode is missing -not resetting link
[FAILED]
Bringing up interface eth9:  
Determining IP information for eth9...bnx2x_ack_int bp 0xe0001140f896c500 hc_addr 0x1081b8 addr 0xc0000403211081b8
[bnx2x_init_common:5394(eth9)]Bootcode is missing - can not initialize link
[bnx2x__link_reset:2001(eth9)]Bootcode is missing -not resetting link
bnx2x_ack_int bp 0xe0001140f896c500 hc_addr 0x1081b8 addr 0xc0000403211081b8
[bnx2x_initial_phy_init:1978(eth9)]Bootcode is missing -not initializing link
bnx2x_ack_int bp 0xe0001140f896c500 hc_addr 0x1081b8 addr 0xc0000403211081b8
bnx2x_ack_int bp 0xe0001140f896c500 hc_addr 0x1081b8 addr 0xc0000403211081b8
ADDRCONF(NETDEV_UP): eth9: link is not ready
 failed; no link present.  Check cable?
bnx2x_ack_int bp 0xe0001140f896c500 hc_addr 0x1081b8 addr 0xc0000403211081b8
[bnx2x__link_reset:2001(eth9)]Bootcode is missing -not resetting link
[FAILED]
...


[root@localhost ~]# while /bin/true; do ifup eth6; date; done

Determining IP information for eth6...bnx2x_ack_int bp 0xe0001140ffef6500 hc_addr 0x108198 addr 0xc000040020108198
[bnx2x_init_common:5394(eth6)]Bootcode is missing - can not initialize link
[bnx2x__link_reset:2001(eth6)]Bootcode is missing -not resetting link
bnx2x_ack_int bp 0xe0001140ffef6500 hc_addr 0x108198 addr 0xc000040020108198
[bnx2x_initial_phy_init:1978(eth6)]Bootcode is missing -not initializing link
bnx2x_ack_int bp 0xe0001140ffef6500 hc_addr 0x108198 addr 0xc000040020108198
bnx2x_ack_int bp 0xe0001140ffef6500 hc_addr 0x108198 addr 0xc000040020108198
ADDRCONF(NETDEV_UP): eth6: link is not ready
 failed; no link present.  Check cable?
bnx2x_ack_int bp 0xe0001140ffef6500 hc_addr 0x108198 addr 0xc000040020108198
[bnx2x__link_reset:2001(eth6)]Bootcode is missing -not resetting link
Sat Nov 29 06:27:53 MST 2008

Determining IP information for eth6...bnx2x_ack_int bp 0xe0001140ffef6500 hc_addr 0x108198 addr 0xc000040020108198
[Sending CFW FIFO message (0x12000102) Local MCA (18) partition 0 CPU LID = 258 (0x102) to PDH 0 ... sent.]

sequencer: MCA on cpu17.

MCA occurred : iip=0xA00000010040D1B0, ipsr=0x0000101008526030, ipfs=0x800000000000030B.
