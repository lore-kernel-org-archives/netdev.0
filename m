From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] ixgbe: Remove bimodal SR-IOV disabling
Date: Fri, 10 Jul 2015 16:44:16 -0600
Message-ID: <1436568256.1391.328.camel@redhat.com>
References: <20150710212710.9501.14320.stgit@gimli.home>
	 <C5551D9AAB213A418B7FD5E4A6F30A0789336065@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbbGJWoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 18:44:17 -0400
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0789336065@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-10 at 21:36 +0000, Rose, Gregory V wrote:
> 
> > -----Original Message-----
> > From: Alex Williamson [mailto:alex.williamson@redhat.com]
> > Sent: Friday, July 10, 2015 2:32 PM
> > To: intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T
> > Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Rose, Gregory V
> > Subject: [PATCH] ixgbe: Remove bimodal SR-IOV disabling
> > 
> > When unbinding an SR-IOV device with VFs configured from ixgbe, the driver
> > behaves in one of two ways.  If max_vfs was specified, the SR-IOV state is
> > disabled, removing the VFs.  The occurs regardless of whether the VF count
> > was later modified through sysfs.  If however max_vfs is zero, such as by
> > not specifying the module parameter, the VFs persist after the PF is
> > unbound from ixgbe.  If the PF is then bound to vfio-pci to be assigned to
> > a VM, the PF is non-functional.
> > 
> > >From the comment, commit da36b64736cf ("ixgbe: Implement PCI SR-IOV
> > sysfs callback operation") clearly intended this alternate behavior, but
> > probably didn't realize the PF doesn't work in this mode.
> > 
> > This bimodal behavior is confusing to users and results in a state where
> > the PF is broken for other uses unless the user sets sriov_numvfs to zero
> > prior to unbinding the device.  Remove this behavior so that VFs are
> > removed and the PF is functional for other uses after unbind, regardless
> > of the way VFs are enabled.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
> > Cc: Greg Rose <gregory.v.rose@intel.com>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> > 
> > I can only think that not disabling SR-IOV was meant to enable some sort
> > of persistence for VFs, but that's probably better accomplished with
> > either udev rules and/or modprobe.d install scripts.
> > 
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index 5be12a0..de04e3e 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -8810,12 +8810,7 @@ static void ixgbe_remove(struct pci_dev *pdev)
> >  		unregister_netdev(netdev);
> > 
> >  #ifdef CONFIG_PCI_IOV
> > -	/*
> > -	 * Only disable SR-IOV on unload if the user specified the now
> > -	 * deprecated max_vfs module parameter.
> > -	 */
> > -	if (max_vfs)
> > -		ixgbe_disable_sriov(adapter);
> > +	ixgbe_disable_sriov(adapter);
> >  #endif
> >  	ixgbe_clear_interrupt_scheme(adapter);
> > 
> 
> Please remove max_vfs module parameter - it is deprecated and should be removed from upstream builds.  Dave let us get away with a kernel module a few years ago because the other necessary infrastructure to enable SR-IOV virtual functions via the PCIe interface was not available.  Now that it's there it should be removed and vendors/end users should be forced to move away from this.

I can't really say I'm in favor of removing that option.  It's probably
going to break a lot of people because doing the udev rules right is
hard.  The sysfs sriov interface has been tossed over the wall as the
right way to do things, but there's really no infrastructure to
facilitate even the simple peanut butter, everybody gets the same number
of VFs, interface that max_vfs provides.  I think the existence of this
bug is probably a good indication that the sysfs interface has not
really been adopted yet.  Thanks,

Alex
