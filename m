From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [ANNOUNCE] New driver vxge for Neterion's X3100series10GbEPCIe adapter
Date: Wed, 1 Apr 2009 10:30:08 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF0A3@nekter>
References: <1237018825.4966.412.camel@flash> <20090331061333.GA11240@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BEEA1@nekter> <49D257D0.9050104@intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF027@nekter> <20090401025327.GA11687@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF03C@nekter> <20090401050940.GB11687@yzhao-otc.sh.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD77051BF05A@nekter> <20090401065536.GA11781@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Yu Zhao" <yu.zhao@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:32985 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754819AbZDAObn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 10:31:43 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090401065536.GA11781@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Yu Zhao [mailto:yu.zhao@intel.com]
> Sent: Tuesday, March 31, 2009 11:56 PM
> To: Leonid Grossman
> Cc: Ramkrishna Vepa; Duyck, Alexander H; Netdev; David Miller
> Subject: Re: [ANNOUNCE] New driver vxge for Neterion's
> X3100series10GbEPCIe adapter
> 
> On Wed, Apr 01, 2009 at 01:44:45PM +0800, Leonid Grossman wrote:
> > > On Wed, Apr 01, 2009 at 11:36:11AM +0800, Ramkrishna Vepa wrote:
> > > > > Yes, and that's what the PCI subsystem does. If the vxge VF is
> > > > identical
> > > > > to its PF, then vxge should be able to drive both PF and VF
> > without
> > > > any
> > > > > modification.
> > > > [Ram] Ok. In that case, is the call to pci_enable/disable_sriov
> > still
> > > > required for vxge?
> > >
> > > Yes, the vxge driver first binds the PF once it's loaded (VF
doesn't
> > > exist at this time) and calls the SR-IOV API. The VF appears after
the
> > > SR-IOV is enabled and then the same copy of the vxge driver can
bind
> > > the VF too if you want to use the VF in the native Linux. Though
the
> > > hardware is in the SR-IOV mode in this case, it would be equal to
the
> > > multi-function mode. Or you can assign the VF to the Xen/KVM guest
and
> > > let another copy of vxge driver (may be vxge for Windows, Solaris,
> > BSD,
> > > etc.) running in the guest bind it.
> >
> > Yu, could you pl. explain why this call is not optional - SR-IOV
pci-e
> > code should be able to find SR-IOV capable device and enable all VFs
> > based upon pci-e config space alone, without any help from
> > device-specific PF driver.
> 
> Yes, this is true in certain cases. However, there are several things
> that prevent us to enable the SR-IOV implicitly by the PCI subsystem.
> 
> First, the SR-IOV spec says "Once the SRIOV capability is configured
> enabling VF to be assigned to individual SI, the PF takes on a more
> supervisory role. For example, the PF can be used to manage device
> specific functionality such as internal resource allocation to each
> VF, VF arbitration to shared resources such as the PCIe Link or the
> Function-specific Link (e.g., a network or storage Link), etc." And
> some SR-IOV devices follow this suggestion thus their VF cannot work
> without PF driver pre-exits. Intel 82576 is an example -- it requires
> the PF driver to allocate tx/rx queues for the VF so the VF can be
> functional. Only enabling the SR-IOV in the PF PCI config space will
> end up with VF appearing useless even its PCI config space is visible.

Correct, PF driver can "optionally" manage device specific resources
like queue pairs, etc. - this is not the reason though to mandate a PF
driver presence in order for VFs to operate. 
Arguably PCI code (perhaps with the help of SR PCIM) should be
responsible for pci-e resource configuration, and networking driver
should be responsible for network resources configuration. 
If a device like 82576 is implemented in a way that VFs can't operate
without a PF driver present, it's a reasonable design trade-off and this
case should be supported - but other devices like x3100 do not have this
restriction, so PF driver presence should not be a "must have" (pl. see
a use case example below).

> 
> Second, the SR-IOV depends on somethings that are not available before
> the PCI subsystem is fully initialized. This mean we cannot enable the
> SR-IOV capability before all PCI device are enumerated. For example,
> if the VF resides on the bus different than the PF bus, then we can't
> enable the VF before the bus used by the VF is scan because we don't
> know if the bus is reserved by the BIOS for the VF or not. Another
> example is the dependency link used by the PF -- we can't create the
> sysfs symbolic link indicating the dependency before all PFs in a
> device are enumerated.
> 
> And some SR-IOV devices can support multiple modes at same time.
> The 82576 can support N VFs + M VMDq modes (N + M = 8), which means
> sometimes people may want to only enable arbitrary number of VFs.
> The PCI subsystem can't get value to config the NumVFs unless some
> one calls the API. I guess only the PF driver can do this.

Have you considered using SR PCIM for this, instead of using a NIC (or
another device-specific) driver to configure number of pci functions? 
> 
> > Once VFs appear, vxge or any other native netdev driver should be
able
> > to bind a VF regardless of PF driver being loaded first (or at all)
-
> > there are some use cases that do not assume PF driver presence...
> 
> So the PF will not be binded to any driver in these use cases? Can you
> please elaborate?

Yes. For example one of the common use cases for SR IOV is to replace a
large number of "legacy" GbE interfaces (as transparently as possible). 
Assume a customer wants to replace four quad GbE NICs (perhaps running
16 Vlans) with one SR IOV 10GbE card. He considers a PF driver to be a
potential security hole and a configuration overhead, and prevents is
from loading (perhaps via fw option). His expectation is that 16 VFs
will come up and bind to a driver, very much like 16 GbE interfaces did
in the original configuration.

So, there should be arguably a way to enable VFs based upon the
information in device configuration space alone, without requiring a PF
driver to be loaded.
Best, Leonid



> 
> Thanks,
> Yu
