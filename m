From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] vfio-pci: PCI_DEV_FLAGS_ASSIGNED flag not set when PCI
 device is assigned
Date: Wed, 13 May 2015 12:39:17 -0600
Message-ID: <1431542357.3625.62.camel@redhat.com>
References: <20150513013550.10328.1416.stgit@bwallan-smackover2.jf.intel.com>
	 <1431484908.3625.10.camel@redhat.com>
	 <804857E1F29AAC47BF68C404FC60A1846BBD2E63@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965001AbbEMSjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 14:39:21 -0400
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1846BBD2E63@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 17:50 +0000, Allan, Bruce W wrote:
> > -----Original Message-----
> > From: Alex Williamson [mailto:alex.williamson@redhat.com]
> > Sent: Tuesday, May 12, 2015 7:42 PM
> > To: Allan, Bruce W
> > Cc: kvm@vger.kernel.org; netdev@vger.kernel.org; intel-wired-
> > lan@lists.osuosl.org
> > Subject: Re: [PATCH] vfio-pci: PCI_DEV_FLAGS_ASSIGNED flag not set when
> > PCI device is assigned
> > 
> > On Tue, 2015-05-12 at 18:35 -0700, Bruce Allan wrote:
> > > A number of PCI device drivers supporting SR-IOV use pci_vfs_assigned()
> > to
> > > check if there are any VF devices assigned by a VMM prior to disabling
> > > SR-IOV (i.e. bnx2x, be2net, fm10k, i40e, igb, ixgbe, qlcnic).  This check
> > > works fine with the legacy device assignment (pci-stub enables the
> > device)
> > > which calls pci_set_dev_assigned().  The newer VFIO-based assignment
> > > (vfio-pci enables device) doesn't call pci_set_dev_assigned() potentially
> > > leading to issues in those drivers when disabling SR-IOV with VFs assigned.
> > >
> > > Add calls to pci_[set|clear]_dev_assigned() to set the flag as expected.
> > >
> > > Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> > > ---
> > >  drivers/vfio/pci/vfio_pci.c |    4 ++++
> > >  1 file changed, 4 insertions(+)
> > 
> > 
> > Why should a device exposed to the user be handled differently than a
> > device used by a host driver?  The reason the assigned flag exists is
> > because legacy KVM device assignment doesn't actually claim the device
> > using the driver model, it relies on pci-stub to act as a placeholder to
> > prevent other drivers from binding to the device, but pci-stub has no
> > visibility to the device usage and will immediately release it
> > regardless of it being in use.  vfio-pci participates in the driver
> > model, signals the user for the device to be released and blocks until
> > it is released.  Beyond that, the assigned flag is a racy hack.  There's
> > no locking whatsoever to imply that the flag as any meaning beyond the
> > instant that it's tested.  I'd like to see the assigned flag deprecated
> > along with legacy KVM device assignment, not perpetuated in newer
> > drivers.  The patch is also wrong because we can tell when the device is
> > actually opened by the user, not just bound to the vfio-pci driver.
> > Thanks,
> > 
> > Alex
> 
> So for clarification, in the drivers mentioned above would you recommend
> rather than checking pci_vfs_assigned() before disabling SR-IOV the drivers
> should instead check if any of the VF devices are bound/opened by another
> driver?

That would also be racy, it could be unbound at your test point and
bound immediately after.  Driver binding also doesn't necessarily imply
that the device is in use; vfio-pci will immediately release an unused
device.  Again, why are we trying to handle this as a special case?
vfio-pci is just another driver.  If it can release the device, it will.
It will even try to signal the user to release it.  Beyond that, we're
bound by the driver model.  If we want drivers to be able to return
-EBUSY if the device is in use, fix the driver model, don't hack around
it with racy tests like the assigned flag.  Thanks,

Alex
