From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network interface
Date: Thu, 7 Oct 2010 11:31:13 -0500
Message-ID: <20101007163113.GA14260@auslistsprd01.us.dell.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com> <20101007151134.GA25713@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	Jordan_Hargrave@Dell.com, Vijay_Nijhawan@Dell.com,
	Charles_Rose@Dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101007151134.GA25713@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2010 at 08:11:34AM -0700, Greg KH wrote:
> On Thu, Oct 07, 2010 at 07:23:35AM -0700, Narendra_K@Dell.com wrote:
> > Hello,
> > 
> > V1 -> V2:
> > 
> > This patch addresses the scenario of buggy firmware/BIOS tables. The
> > patch introduces a command line parameter 'no_netfwindex', passing which
> > firmware provided index will not be used to derive 'eth' names. By
> > default, firmware index will be used and the parameter can be used to
> > work around buggy firmware/BIOS tables.
> > 
> > Please find the patch below.
> > 
> > From: Narendra K <narendra_k@dell.com>
> > Subject: [PATCH] Use firmware provided index to register a network device
> > 
> > This patch uses the firmware provided index to derive the ethN name.
> > If the firmware provides an index for the corresponding pdev, the N
> > is derived from the index.
> 
> No, this has the very big chance to reorder existing network names and
> should all be done in userspace with the firmware information exported
> in sysfs, if the user so desires.

Existing names that use 70-persistent-net.rules won't change.  They
were non-deterministically assigned and recorded in that file, so
they'll persist.  At most, they'll have to deal with the same
"eth0_rename" garbage that anyone wanting to get a consistent name
from other than MAC address would get.  The only reason the
auto-created 70-persistent-net.rules works is that most people don't
change their NIC configuration after install, so it has no renaming to do.

The kernel patch has the advantage of not requiring users to change
their scripts, by reserving the first N values for onboard devices as
BIOS describes them.

Userspace udev rules require us to change user behavior, and likely
their scripts, to use a new namespace such as ethlom1, in order to get
deterministic naming.


> > It took some time to find out the details asked above. Right,
> > windows does not use SMBIOS type 41 record to derive names. But as
> > a datapoint, windows also has the same problem.

> If windows does not use this field, then you can guarantee it will
> show up incorrectly in BIOSes and never be tested by manufacturers
> before they ship their machines.

There are 2 methods of exporting the information that have gotten
confusing here.

1) SMBIOS type 41 method.  Windows does not use this today, and I
   can't speak to their future plans.  Narendra's kernel patch does,
   as has biosdevname, the udev helper we first wrote for this purpose, for several years.

2) soon-to-be-released PCIe Firmware Spec, exporting label and index
   as an ACPI _DSM().  It is anticipated that Windows will use this
   information in some fashion at some point, per our conversations
   with Microsoft as part of the PCI SIG proposal process.  We've held
   off submitting a kernel patch until the spec is public.



Cases:
1) BIOS doesn't provide this information (the common case today for
   all but Dell 10G and newer servers), nothing is reserved, and
   therefore the existing 70-persistent-net.rules take effect to name
   devices.  No change in behavior for existing systems.  New installs
   will have NICs named non-deterministically, and recorded in
   70-persistent-net.rules.  Users desiring consistent naming must
   adjust 70-persistent-net.rules after install, and to avoid
   eth0_rename collisions, must rename into another namespace.

2) BIOS provides this information correctly (Dell 10G and newer servers, or
   anyone else implementing the spec).  The first N values for onboard
   devices are reserved and assigned by the kernel to onboard
   devices.  70-persistent-net.rules may still try to rename the
   ports, and may fail with eth0_rename collisions.  Users would have
   to adjust 70-persistent-net.rules to accommodate, but they do not
   have to change the namespace from ethX to something else. New
   installs will have onboard NICs named deterministically, and recorded in
   70-persistent-net.rules.


3) BIOS provides this information incorrectly (none known today).
   Some number of N values may be reserved, more or fewer than
   actually present.  In either case, it's possible that
   70-persistent-net.rules would have to be adjusted to accommodate,
   but they do not have to change the namespace from ethX to something
   else. New installs will have onboard NICs named deterministically,
   if not ideally due to buggy BIOS, and recorded in
   70-persistent-net.rules.


What I can't find here is a solution where the user gets determistic
naming, without being forced to change the namespace and adjust their
scripts.  Can anyone?  I'm not opposed to "do it all in userspace" -
really, I'm not.  But the 'where' is only part of the problem.  No
userspace solution has yet been proposed that doesn't require a
namespace change, and I'm still hoping to avoid that.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
