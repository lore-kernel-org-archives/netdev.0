From: Stuart Shelton <stuart@openobjects.com>
Subject: Severe regression in bnx2 driver with bonding in post 2.6.30 kernels
Date: Wed, 31 Mar 2010 13:55:22 +0100
Message-ID: <4BB3463A.2000801@openobjects.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 157.187.34.193.bridgep.com ([193.34.187.157]:49917 "EHLO
	smtp.openobjects.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757348Ab0CaNC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:02:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

The Broadcom NetXtreme II driver appears to have a severe regression in 
all kernels post 2.6.30 - I've observed problems with 2.6.31, 2.6.32. 
and 2.6.33.

The hardware impacted is an IBM Bladecenter LS21 Blade, model 7971.  We 
have a large number of these, and all are affected.

We use generic channel-bonding, with the following options in modprobe.conf:

alias bond0 bonding
options bond0 mode=0 miimon=100

With any kernel prior to 2.6.31, the dmesg output reads:

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
   alloc irq_desc for 17 on cpu 0 node 0
   alloc kstat_irqs on cpu 0 node 0
bnx2 0000:02:04.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
...
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth0: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e2000000, IRQ 17, node addr 00:1a:64:bd:21:04
   alloc irq_desc for 18 on cpu 0 node 0
   alloc kstat_irqs on cpu 0 node 0
bnx2 0000:02:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth1: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e4000000, IRQ 18, node addr 00:1a:64:be:20:80
udev: renamed network interface eth1 to eg1
udev: renamed network interface eth0 to eg0
...
   alloc irq_desc for 32 on cpu 0 node 0
   alloc kstat_irqs on cpu 0 node 0
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: eg0: using MSI
bnx2: eg0 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
   alloc irq_desc for 33 on cpu 0 node 0
   alloc kstat_irqs on cpu 0 node 0
bnx2 0000:02:05.0: irq 33 for MSI/MSI-X
bnx2: eg1: using MSI
bnx2: eg1 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: eg0: using MSI
bonding: bond0: enslaving eg0 as an active interface with a down link.
bnx2: eg0 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2 0000:02:05.0: irq 33 for MSI/MSI-X
bnx2: eg1: using MSI
bonding: bond0: enslaving eg1 as an active interface with a down link.
bonding: bond0: link status definitely up for interface eg0.
bonding: bond0: link status definitely up for interface eg1.
bnx2: eg1 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON


... however, with kernels from 2.6.31 and later, the dmesg output reads:

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
   alloc irq_desc for 17 on node 0
   alloc kstat_irqs on node 0
bnx2 0000:02:04.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth0: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e2000000, IRQ 17, node addr 00:1a:64:bd:21:04
   alloc irq_desc for 18 on node 0
   alloc kstat_irqs on node 0
bnx2 0000:02:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth1: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e4000000, IRQ 18, node addr 00:1a:64:be:20:80
udev: renamed network interface eth1 to eg1
udev: renamed network interface eth0 to eg0
...
   alloc irq_desc for 32 on node 0
   alloc kstat_irqs on node 0
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: eg0: using MSI
bnx2: eg0 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
   alloc irq_desc for 33 on node 0
   alloc kstat_irqs on node 0
bnx2 0000:02:05.0: irq 33 for MSI/MSI-X
bnx2: eg0 NIC SerDes Link is Down
bnx2: eg0 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2: eg1: using MSI
bnx2: eg1 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2: Chip reset did not complete
bnx2: eg1 NIC SerDes Link is Down
bnx2: eg1 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2: fw sync timeout, reset code = 4040005
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: fw sync timeout, reset code = 4040005
bnx2 0000:02:05.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:05.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
NET: Registered protocol family 17
bnx2 0000:02:05.0: PCI INT A disabled
bnx2 0000:02:04.0: PCI INT A disabled
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:02:04.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth0: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e2000000, IRQ 17, node addr 00:1a:64:bd:21:04
bnx2 0000:02:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth1: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e4000000, IRQ 18, node addr 00:1a:64:be:20:80
udev: renamed network interface eth0 to eg0
udev: renamed network interface eth1 to eg1
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:05.0: irq 32 for MSI/MSI-X
bnx2: eg1: using MSI
bnx2: eg1 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2 0000:02:04.0: irq 33 for MSI/MSI-X
bnx2: eg1 NIC SerDes Link is Down
bnx2: eg1 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & 
transmit flow control ON
bnx2: Chip reset did not complete
bnx2 0000:02:04.0: irq 33 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2: Chip reset did not complete
bnx2: fw sync timeout, reset code = 4040005
bnx2 0000:02:05.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:05.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:05.0: PCI INT A disabled
bnx2 0000:02:04.0: PCI INT A disabled
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.1 (May 6, 2009)
bnx2 0000:02:04.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:04.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
eth0: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e2000000, IRQ 17, node addr 00:1a:64:bd:21:04
bnx2 0000:02:05.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-mips-06-4.6.16.fw
bnx2 0000:02:05.0: firmware: requesting bnx2/bnx2-rv2p-06-4.6.16.fw
udev: renamed network interface eth0 to eg0
eth0: Broadcom NetXtreme II BCM5706 1000Base-SX (A2) PCI-X 64-bit 133MHz 
found at mem e4000000, IRQ 18, node addr 00:1a:64:be:20:80
udev: renamed network interface eth0 to eg1
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete
bnx2 0000:02:04.0: irq 32 for MSI/MSI-X
bnx2: Chip reset did not complete

... (this later ouput showing the initial attempt to raise the 
interfaces at boot, and then me manually removing and re-inserting the 
bnx2 driver).  Alongside this, the console outputs "SIOCSIFFLAGS: Device 
or resource busy".

On these more recent kernels, the SIOCSIFFLAGS line is always output, 
but about 50% of the time the network interface is raised.  When this 
fails, then sometimes removing and re-inserting the bnx2 driver can 
result in usable non-bonded interfaces - but as often as not the NICs 
won't be usable even in a standard non-bonded configuration.

With a simple reboot back to a 2.6.30 or earlier kernel, the problem 
goes away (even though the firmware file on disk is the same as that 
used with the later kernels).  Ever blade we have is affected, so this 
is not a hardware problem (or at least, if it is, then it's a very 
common one!).  I thought that the problem might only occur when bonding 
is used - but I can't now recall what made me think this, and I've not 
been able to get the server down-time to extensively test the issue further.

Any advice/guidance greatly appreciated,

Stuart
