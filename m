From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 11:32:19 -0700
Message-ID: <20091010113219.3136fb8b@s6510>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	<20091009140000.GA18765@mock.linuxdev.us.dell.com>
	<20091009210909.GA9836@auslistsprd01.us.dell.com>
	<20091009194401.036da080@nehalam>
	<20091010044056.GA5350@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091010044056.GA5350@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Oct 2009 23:40:57 -0500
Matt Domsch <Matt_Domsch@dell.com> wrote:

> On Fri, Oct 09, 2009 at 07:44:01PM -0700, Stephen Hemminger wrote:
> > Maybe I'm dense but can't see why having a useless /dev/net/ symlinks
> > is a good interface choice. Perhaps you should explain the race between
> > PCI scan and udev in more detail, and why solving it in either of those
> > places won't work. As it stands you are proposing yet another wart to
> > the already complex set of network interface API's which has implications
> > for security as well as increasing the number of possible bugs.
> 
> The fundamental challenge is that system administrators, particularly
> those of server-class hardware with multiple network ports present
> (some on the motherboard, some on add-in cards), have the
> not-so-unreasonable expectation that there is a deterministic mapping
> between those ports and the name one uses to address those ports.
> 
> The fundamental roadblock to this is that enumeration != naming,
> except that it is for network devices, and we keep changing the
> enumeration order.
> 
> Today, port naming is completely nondeterministic.  If you have but
> one NIC, there are few chances to get the name wrong (it'll be eth0).
> If you have >1 NIC, chances increase to get it wrong.
> 
> The complexity arises at multiple levels.
> 
> First, device driver load order.  In the 2.4 kernel days, and even
> mostly early 2.6 kernel days, the order in which network drivers
> loaded played a role in determining the name of the device.  Drivers
> loaded first would get their devices named first.  If I have two types
> of devices, say an e100-driven NIC and a tg3-driven NIC, I could
> figure out that the names would be eth0=e100 and eth1=tg3 by setting
> the load order in /etc/modules.conf (now modprobe.conf).  If I wanted
> the other order, fine, just switch it around in modules.conf and
> reboot.  OS installers, being the first running instance of Linux,
> before modprobe.conf existed to set that ordering, had to have other
> mechanisms to load drivers (often manually, or if programmatically
> such as in a kickstart or autoyast file, was still somewhat fixed).
> 
> With the advent of modaliases + udev, now modprobe.conf doesn't
> contain this ordering anymore, and udev loads the drivers.  So while
> it wasn't perfect, it was better than nothing, and that's gone now.
> 
> It gets even worse as, to speed up boot time, modprobes can be run in
> parallel, and even within individual drivers, the NICs get initialized
> (and named) in parallel.  Further confusing things, some devices need
> firmware loaded into them before getting names assigned, which is done
> from userspace, and they race.
> 
> Second, PCI device list order.  In the 2.4 kernel days, the PCI device
> list was scanned "breadth-first" (for each bus; for each device; for
> each function; do load...).  FWIW, Windows still does this.  It gives
> BIOS, which assigns PCI bus numbers, a chance to put LOMs at a lower
> bus number than add-in cards.  Module load order still mattered, but
> at least if you had say 2 e1000 ports as LOMs, and 2 e1000 ports on
> add-in cards, you pretty much knew the ordering would be eth0 as
> lowest bdf on the motherboard, eth1 as next bdf on the motherboard,
> and eth2 and 3 as the add-in cards in ascending slot order.
> 
> With the advent of PCI hot plug in the 2.5 kernel series, the
> breadth-first ordering became depth-first.    (for each bus; for each
> device; if the device is a bridge, scan the busses behind it.).  This
> caused NICs on bus 0 device 5, and bus 1 device 3, (eth0 and 1
> respectively) to be enumerated differently due to the  a bridge from
> bus 0 to bus 1 at 0:4.  My crude hack of pci=bfsort, with some dmi
> strings to match and auto-enable, at least reverted this back to the
> ordering the 2.4 kernel and Windows used.  Now we have to keep adding
> systems to this DMI list (Dell has a number of systems on this list
> today; HP has even more).  And it doesn't completely solve the
> problem, just masks it.
> 
> So, to address the ordering problem, I placed a constraint on our
> server hardware teams, forcing them to lay out their boards and assign
> PCIe lanes and bus numbers, such that at least the designed "first"
> LOM would get found first in either depth-first or breadth-first
> order.  Our 10G and 11G servers have this restriction in place, though
> it wasn't easy.  And it's gotten even harder, as the PCIe switches
> expand the number of lanes available.  We no longer have the
> traditional tiered buses architecture, but the PCI layer for this
> purpose thinks we do.  I need to remove this constraint on the
> hardware teams - it's gotten to be impossible for the chipset lanes to
> be laid out efficiently with this constraint.
> 
> All of the above just papered over the enumeration != naming problem.
> 
> Third, stateless computing is becoming more and more commonplace.  The
> Field Replaceable Unit is the server itself.  Got a bad server?  Pull
> it out, move the disks to an identical unit, insert the new server,
> and go.  Fix the bad server offline and bring it back.  In this model,
> having MAC addresses as the mechanism that is providing the
> determinism (/etc/mactab or udev persistent naming rules) breaks,
> because the MAC addresses of the ports on the new server won't be the
> same as on the old server.  HP even has a technology to solve _this_
> problem (in their blade chassis) - Virtual Connect.  The MACs get
> assigned by the chassis to the blades at POST, and are fixed to the
> slot.  Slick, and Dell has an even more flexible similar feature
> FlexAddress.  This doesn't solve the OS installer problem of "which of
> these NICs should I use to do an install?" but it does recognize the
> problem space and tries to overcome it.
> 
> Fourth, for OS installers, choosing which NIC to use at installtime,
> when all the NICs are plugged in, can be difficult.  PXE environments,
> using pxelinux and its IPAPPEND 2 option, will append
> "BOOTIF=xx:xx:xx:xx:xx:xx" to the kernel command line, that
> containing the MAC address of the NIC used for PXE.  Neat trick.  Yes,
> we then had to teach the OS installers to recognize and use this.  But
> it only works if you PXE boot, and only for that one NIC.
> 
> Fifth, network devices can have only a single name.  eth0.  If we look
> at disks, we see udev manages a tree of symlinks for
> /dev/disk/by-label, /dev/disk/by-path, /dev/disk/by-uuid. And as a
> system admin, if I wanted to also create a udev rule for
> /dev/disk/by-function (boot, swap, mattsstorage), it's trivial to do
> so.  Why can't we have this flexibility for network devices too?
> 
> So, how do we get deterministic naming for all the NICs in a system?
> That's what I'm going for.  Picture a network switch, with several
> blades, and several ports on each blade.  The network admin addresses
> each port as say 1/16 (the 16th port on blade 1, clearly labeled).
> The parallel on servers is the chassis label printed on the outside
> (say, "Gb1").  But due the above, there is no guarantee, and in fact
> little chance, that Gb1 will be consistently named eth0 - it may vary
> from boot to boot.  That's full of fail.
> 
> For a concrete example, the 4 bnx2 chips in my PowerEdge R610 with a
> current 2.6 kernel, loading only one driver, the ports get assigned
> names in nondeterministic order on each boot.  Given that the
> ifcfg-eth* rules, netfilter rules, and the rest all expect
> deterministic naming, massive failure ensues unless some form of
> determinism is brought back in.
> 
> The idea to use a character device node to expose the ifindex value,
> and udev to manage a tree of symlinks to it, really follows the model
> used today for disks.  It allows us to get deterministic names for
> devices (albeit, the names are symlinks), and multiple names for
> devices (through multiple symlink rules).  That some people want to
> use the char device to call ioctl() and read/write, as is possible on
> the BSDs, would just be gravy IMHO.
> 
> It does require a change in behavior for a system administrator.
> Instead of hard-coding 'eth0' into her scripts, she uses
> '/dev/net/by-function/boot' or somesuch.  But then that name is
> guaranteed to always refer to the "right" NIC.  Every admin I've
> spoken to is willing to make this kind of change, as long as they get
> the consistent, deterministic naming they expect but don't have
> today.  And it does require patching userspace apps to take both a
> kernel device name, or a path, and to resolve the path to device name
> or ifindex.  We wrote libnetdevname (really, one function), and have
> patches for several userspace apps to use it, to prove it can be done.
> 
> One alternative would be to do something using the sysfs ifindex value
> already exported.  e.g.
>   /sys/devices/pci0000:00/0000:00:05.0/0000:05:00.0/0000:06:07.0/net/eth0/ifindex
> 
> but we have never had symlinks from /dev into /sys before (doesn't
> mean we couldn't though).  In that case, udev would grow to manage
> /dev/net/by-chassis-label/Embedded_NIC_1 -> /sys/devices/.../net/eth0,
> and libnetdevname would be used to follow the symlink in applications.
> This approach could solve my problem without (many or any?) kernel
> changes needed, but wouldn't help those who want to do
> ioctl/read/write to a devnode.
> 
> Given the problem, I really do need a solution.  I've proposed one
> method, and an alternative, but I can't afford to let the problem stay
> unaddressed any longer, and need a clear direction to be chosen.  The
> char device gives me what I need, and others what they want also.
> 
> Thanks for listening to the diatribe.  For more examples and
> workarounds that we've been telling our customers for several years,
> check out http://linux.dell.com/papers.shtml for the Network Interface
> Card Naming whitepaper.
> 
> 

Why isn't the available through sysfs enough, if not why not
add the necessary attributes there.

BTW, for our distro, we are looking into device renaming based on PCI slot
because that is what router OS's do. Customers expect if they replace the card
in slot 0, it will come back with the same name.  This is not what server
customers expect.
