From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Use firmware provided index to register a network interface
Date: Thu, 23 Sep 2010 20:40:44 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com> <20100922192228.GB29899@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100922192228.GB29899@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]
> Sent: Thursday, September 23, 2010 12:52 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> pci@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave, Jordan;
> Nijhawan, Vijay
> Subject: Re: [PATCH] Use firmware provided index to register a network
> interface
> 
> On Wed, Sep 22, 2010 at 01:31:38PM -0500, Narendra K wrote:
> > Hello,
> >
> > Here is another approach to address the issue of "eth0 does not
> always
> > map to the Integrated NIC Port 1 as denoted on server chassis
label".
> > For more details please refer to the thread -
> > http://marc.info/?l=linux-netdev&m=128163454631618&w=3.
> >
> > Patch makes use of the firmware provided index to derive ethN names.
> > That way the naming scheme adheres to the existing requirements of
> > ethN namespace and with IFNAMSIZ length.
> 
> Ick, again, what's wrong with using udev for this as it is designed
to?
> That way no kernel changes are needed, and no one has to rely on the
> BIOS getting the firmware number right (meaning it will work on all
> types of systems.)
> 

1. We tried addressing this issue using udev only and without any kernel
changes, during Nov-Dec 2008 timeframe using Biosdevname udev helper
utility. Biosdevname utility has the ability to suggest BIOS intended
name of an interface given its OS name.

/sbin/biosdevname -I eth2 - (OS name)
eth0 - (Name according to the BIOS)

KERNEL!="eth*", GOTO="biosdevname_end"
ACTION!="add",  GOTO="biosdevname_end"
NAME=="?*",     GOTO="biosdevname_end"

PROGRAM="/sbin/biosdevname --policy=all_ethN -i %k",
ENV{INTERFACE_NAME}="%c"

LABEL="biosdevname_end"

We observed that renames in the same namespace, which is ethN namespace,
resulted in interface names like eth_rename_ren. The solution was
susceptible to driver load order. Please refer to this bug report-
https://bugzilla.novell.com/show_bug.cgi?id=441079.

This solution was not favored.

2. Based on the suggestions, I am trying to see if we can make use of
the attribute 'index' that is available to udev as a result of the patch
-
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commit;h
=911e1c9b05a8e3559a7aa89083930700a0b9e7ee (PCI: export SMBIOS provided
firmware instance and label to sysfs).(I am not using any udev helper in
this experiment).

On a PowerEdge R805, with 4 BCM5708 Lan-On-Motherboard ports and a dual
port Intel 82576 NIC. In this system the 82576 ports become eth0 and
eth1 and the Lan-On-Motherboard ports are eth2-eth5. Below is how the
70-persistent-net.rules file looks before I modified it -

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1e:4f:fc:1b:32", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth3"

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1e:4f:fc:1b:30", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth2"

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1e:4f:fc:00:40", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth5"

# PCI device 0x8086:0x10c9 (igb) (custom name provided by external tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1b:21:54:33:3c", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth0"

# PCI device 0x8086:0x10c9 (igb) (custom name provided by external tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1b:21:54:33:3d", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth1"

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1e:4f:fc:00:3e", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth4"

I modified the rules to use the ATTR{index} as below to get expected
names -

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{index}=="1",
ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{index}=="2",
ATTR{type}=="1", KERNEL=="eth*", NAME="eth1"

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{index}=="3",
ATTR{type}=="1", KERNEL=="eth*", NAME="eth2"

# PCI device 0x8086:0x10c9 (igb) (custom name provided by external tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1b:21:54:33:3c", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth4"

# PCI device 0x8086:0x10c9 (igb) (custom name provided by external tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
ATTR{address}=="00:1b:21:54:33:3d", ATTR{type}=="1", KERNEL=="eth*",
NAME="eth5"

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
tool)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{index}=="4",
ATTR{type}=="1", KERNEL=="eth*", NAME="eth3"

I observe that the Lan-On-Motherboard ports get named beyond the add-in
interfaces. That is, in the original file the add-in interfaces were
eth4 and eth5. They remain same as expected. But Lan-On-Motherboard
ports get eth6,eth7,eth8,eth9. Dmesg shows the renames that are done 

igb 0000:21:00.1: Using MSI-X interrupts. 8 rx queue(s), 8 tx queue(s)
udev: renamed network interface eth1 to eth5
udev: renamed network interface eth0 to eth4

bnx2 0000:0a:00.0: eth3: Broadcom NetXtreme II BCM5708 1000Base-T (B2)
PCI-X 64-bit 133MHz found at mem ec000000, IRQ 19, node addr
00:1e:4f:fc:00:40
udev: renamed network interface eth0 to eth6
udev: renamed network interface eth2 to eth7
udev: renamed network interface eth3 to eth8
udev: renamed network interface eth1 to eth9

I am trying to figure out what might be going on.

With regards,
Narendra K
