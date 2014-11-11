From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH 0/4] move pci_assivned_vfs() check (while disabling VFs)
 to pci sub-system
Date: Tue, 11 Nov 2014 13:39:32 -0700
Message-ID: <1415738372.16601.335.camel@ul30vt.home>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
	 <54625EE8.1050509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sathya Perla <sathya.perla@Emulex.Com>, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, ariel.elior@qlogic.com,
	linux.nics@intel.com, shahed.shaikh@qlogic.com
To: Don Dutile <ddutile@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbaKKUjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 15:39:41 -0500
In-Reply-To: <54625EE8.1050509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-11 at 14:09 -0500, Don Dutile wrote:
> On 11/10/2014 06:53 AM, Sathya Perla wrote:
> > A user must not be allowed to disable VFs while they are already assigned to
> > a guest. This check is being made in each individual driver that implements
> > the sriov_configure PCI method.
> > This patch-set fixes this code duplication by moving this check from
> > drivers to the sriov_nuvfs_store() routine just before invoking
> > sriov_configure() when num_vfs is equal to 0.
> >
> > Vasundhara Volam (4):
> >    pci: move pci_assivned_vfs() check while disabling VFs to pci
> >      sub-system
> >    bnx2x: remove pci_assigned_vfs() check while disabling VFs
> >    i40e: remove pci_assigned_vfs() check while disabling VFs
> >    qlcnic: remove pci_assigned_vfs() check while disabling VFs
> >
> >   drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    2 +-
> >   drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    7 +------
> >   .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   10 ----------
> >   drivers/pci/pci-sysfs.c                            |    5 +++++
> >   4 files changed, 7 insertions(+), 17 deletions(-)
> >
> I have had a side conversation with Alex Williamson, VFIO author.
> 
> VFIO is the upstream method that device-assignment is managed/handled on kvm now.
> It does not set the PCI_DEV_FLAGS_ASSIGNED pci dev-flags, and thus,
> this check will not work when VFIO is used.
> 
> This patch set will only work for the former, kvm-managed, device-assignment method,
> which is currently being deprecated in qemu as well.
> 
> So, yes, it works for kvm managed device-assignment, but not the
> newer, VFIO-based device-assignment.
> 
> Note, also, that the pci_assigned_vfs() check in the drivers will
> always return 0 when VFIO is used for device assignment, so keeping
> these checks in the drivers doesn't do what they imply either.
> 
> So, taking in the patch solves old, kvm-managed, device assignment,
> but a new method is needed when VFIO is involved.
> 
> - Don
> 
> ps -- Note: just adding the flag setting in vfio-pci does not necessarily
>        solve this problem.  VFIO does not know if a device is assigned to a guest;
>        it only knows a caller of the ioctl requesting the device to be assigned
>        to vfio, and to be dma-mapped for a region of memory, has been requested.
>        So, a new PF<->VF mechanism needs to be put in place to
>        determine the equivalent information.

pps -- Note: testing pci_assivned_vfs() is racy, nothing prevents the flag
	being added to a device between your check and removing the VF device.
	This is one of the reasons that vfio-pci doesn't use it and that this
	interface should be discouraged in the kernel.
