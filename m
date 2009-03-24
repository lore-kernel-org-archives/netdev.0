From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 10:46:17 -0500
Message-ID: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You may recall http://lkml.org/lkml/2006/9/29/268, wherein I described
network device enumeration and naming challenges, and several possible
fixes.  Of these, Fix #1 (fix the PCI device list to be sorted
breadth-first) has been implemented in the kernel, and Fix #3 (system
board routing rules) have been implemented on Dell PowerEdge 10G and
11G servers (11G begin selling RSN).

However, these have not been completely satisfactory.  In particular,
it keeps getting harder and harder to route PCI-Express lanes to
guarantee the same ordering between a depth-first and breadth-first
walk, and it turns out, that isn't sufficient anyhow.


Problem:  Users expect on-motherboard NICs to be named eth0..ethN.  This can be difficult to achieve.

Ethernet device names are initially assigned by the kernel, and may be
changed by udev or nameif in userspace.  The initial name assigned by
the kernel is in monotonically increasing order, starting with eth0.
In this instance, the enumeration directly leads to an assigned name.

Complications:

1) Devices are discovered, and presented to the kernel for name
   assignment, based on several factors:

   a) the kernel hotplug mechanism emits events for udev to catch, to
      load the appropriate driver for a given device.  The kernel
      emits these events in some ordering, tied to the depth-first PCI
      bus walk.  Therefore the order in which userspace catches these
      events and starts to load a given device driver is tied to the
      depth-first bus walk.  There is no guarantee within PCI-Express
      hardware topology of any ordering to the discovery of devices.

      To ease this complication, SMBIOS 2.6 includes a mechanism for
      BIOS to specify its expected ordering of devices, for naming
      purposes.  Tools such as biosdevname use this information.


   b) udev may run modprobes in parallel.  It guarantees that the
      events and modprobes are begun in order, but makes no guarantee
      that one event's modprobe completes before beginning a second
      modprobe.  This leads to naming races in the kernel, as drivers
      begun in parallel, which discover their own devices, present
      them to the kernel for name assignment.  In this scenario, if
      you have multiple device drivers for multiple NIC types (say,
      bnx2 and e1000) in the same system, the kernel's naming of the
      ports is non-deterministic.  On one boot you may have two e1000
      ports as eth0 and eth1, then a bnx2 port as eth2, then another
      e1000 port as eth3; on a subsequent boot, you may have the ports
      assigned other names.  The ports are assigned names "in order"
      if you only look within a single device driver, but may be "out
      of order" if you look across all the drivers.

      To get any consistent ordering now, one of two things must
      happen:

      i) drivers must be loaded before udev begins loading drivers
         (either very early in initscripts, or in the inital ramdisk).
     ii) something must "fix up" the kernel-assigned names after
         udev's modprobes complete.  udev does this as well.

2) udev may have rules to change the device names.  This is most often
   seen in the '70-persistent-net.rules' file.  Here we have
   additional challenges:

   a) this does not exist the first time devices are discovered; the
      naming may be incorrect during first discovery, leading to the
      names being permanently incorrect (unless this file is edited).

   b) it introduces state (MAC addresses) to the system, on a system
      that would otherwise not need state.  This complicates
      image-based deployments, Live Media-based deployments, and other
      stateless deployments.

   c) udev may not always be able to change a device's name.  If udev
      uses the kernel assignment namespace (ethN), then a rename of
      eth0->eth1 may require renaming eth1->eth0 (or something else).
      Udev operates on a single device instance at a time, it becomes
      difficult to switch names around for multiple devices, within
      the single namespace.


3) End users have the (reasonable?) expectation that NIC ports
   embedded on the system are named eth0..ethN (Dell sells servers
   with 4 NICs onboard), and that add-in NICs get assigned names
   ethN+1..., ideally in physical PCI slot order.  Which after
   install, using udev to set up rules, we can accomplish (again using
   the SMBIOS 2.6 information), but with the complications noted
   above.

4) When adding a network card to an existing system, what should the
   ports on the new card be named?  If it is added, they will be named
   ethN+1... above the existing named cards.  This means a (new)
   add-in card in PCI slot 3 may have ports named eth5 and eth6, while
   an add-in card in PCI slot 5 may have ports named eth2 and eth3.
   This is not intuitive.

   This really doesn't address the notion of names matching some
   physical attribute.  If you look at a network switch, the naming of
   the ports both in management software and on chassis labels is
   based on physical location, e.g. slot 4, port 2.  For add-in PCI
   cards, being able to match a logical device name to a physical port
   names is important.  The ethtool -p (flash the port's LEDs) trick
   works alright, but still requires a good bit of human interaction
   to know which port is a given ethN number (at the moment...).

   Nor does it address the desire to name devices based on their usage
   (e.g. name the ports public, dmz, private, management, backup,
   storage).


I'd like to see a distinction made between kernel-assigned names, and
user-visible names, for network devices.  We already see this
distinction with non-network devices, in that /dev/sda is "some disk",
yet /dev/disk/by-label/mybootdisk is a symlink to /dev/sda.  Tools
that care about the human-interesting names use the /dev/disk/by-label
name.  Udev takes care of the symlinks.  Network devices do not have
such a method for providing alternative names for a single device,
that I am aware of.


In my ideal world, I would like to see users expectations of network
device naming changed (much as we did in the ide -> libata transition,
where disks went from being named /dev/hda to /dev/sda, with all the
complications that entailed).  I'd like for the names a sysadmin uses
to be physical-based, with on-board NICs named accordingly, and add-in
NICs named for the PCI slot they occupy.  (I'll set aside non-PCI
add-ins, such as USB, for a bit...)

biosdevname (http://linux.dell.com/projects.shtml#biosdevname) takes a
stab at this.  It can be integrated into udev, such that the
70-persistent-net.rules file is never used, and the naming for each
device comes from several different policies.  Its primary drawback is
that it changes the device namespace, which some sysadmins, and tools,
may not like.  Names for devices become eth_s0_0 for the first
onboard NIC, eth_s0_1 for the second; eth_s3_3 for the fourth port
on PCI Slot #3, etc.

If we wish to avoid changing the namespace, (i.e. to keep using ethN),
then we need some method to "fix up" the ethN namespace to be
"correct".


Some options:

Option 0: do nothing different.  Don't use biosdevname.  Keep udev
as-is.  Users continue to have to figure out, for each system type and
potentially for each boot, which NIC is connected to which name.  This
has been the #1 customer complaint about Linux on Dell servers for
several years.  I'd prefer not to keep it this way.

Option 1: use udev + biosdevname, and change the device namespace,
from ethN to eth_sX_Y, or similar.  This solves the problem cleanly,
but changes the names users presently expect.

Option 2: Add alternative names for network devices in some fashion.
The kernel would then assign both the kernel-name (say, en0), and the
initial alternative name (say, eth0), but userspace could then adjust
the alternative name as it sees fit based on naming policy (physical
location, usage, etc.).  Bonus points for allowing multiple
alternative names for a single device, so you can have both
physical-based names and usage-based names, for a single device (as we
do for /dev/disk/by-*).

Option 3: INSERT YOUR IDEA HERE


I'm looking for these or additional options for how to solve this,
once and for all.

Thanks,
Matt

-- 
Matt Domsch
Linux Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
