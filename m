From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH] vfio-pci: PCI_DEV_FLAGS_ASSIGNED flag not set when PCI
 device is assigned
Date: Tue, 12 May 2015 20:41:48 -0600
Message-ID: <1431484908.3625.10.camel@redhat.com>
References: <20150513013550.10328.1416.stgit@bwallan-smackover2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37615 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933300AbbEMClx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 22:41:53 -0400
In-Reply-To: <20150513013550.10328.1416.stgit@bwallan-smackover2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 18:35 -0700, Bruce Allan wrote:
> A number of PCI device drivers supporting SR-IOV use pci_vfs_assigned() to
> check if there are any VF devices assigned by a VMM prior to disabling
> SR-IOV (i.e. bnx2x, be2net, fm10k, i40e, igb, ixgbe, qlcnic).  This check
> works fine with the legacy device assignment (pci-stub enables the device)
> which calls pci_set_dev_assigned().  The newer VFIO-based assignment
> (vfio-pci enables device) doesn't call pci_set_dev_assigned() potentially
> leading to issues in those drivers when disabling SR-IOV with VFs assigned.
> 
> Add calls to pci_[set|clear]_dev_assigned() to set the flag as expected.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> ---
>  drivers/vfio/pci/vfio_pci.c |    4 ++++
>  1 file changed, 4 insertions(+)


Why should a device exposed to the user be handled differently than a
device used by a host driver?  The reason the assigned flag exists is
because legacy KVM device assignment doesn't actually claim the device
using the driver model, it relies on pci-stub to act as a placeholder to
prevent other drivers from binding to the device, but pci-stub has no
visibility to the device usage and will immediately release it
regardless of it being in use.  vfio-pci participates in the driver
model, signals the user for the device to be released and blocks until
it is released.  Beyond that, the assigned flag is a racy hack.  There's
no locking whatsoever to imply that the flag as any meaning beyond the
instant that it's tested.  I'd like to see the assigned flag deprecated
along with legacy KVM device assignment, not perpetuated in newer
drivers.  The patch is also wrong because we can tell when the device is
actually opened by the user, not just bound to the vfio-pci driver.
Thanks,

Alex

> diff --git a/drivers/vfio/pci/vfio_pci.c b/drivers/vfio/pci/vfio_pci.c
> index 69fab0f..3f368ce 100644
> --- a/drivers/vfio/pci/vfio_pci.c
> +++ b/drivers/vfio/pci/vfio_pci.c
> @@ -956,6 +956,8 @@ static int vfio_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
>  		return ret;
>  	}
>  
> +	pci_set_dev_assigned(pdev);
> +
>  	if (vfio_pci_is_vga(pdev)) {
>  		vga_client_register(pdev, vdev, NULL, vfio_pci_set_vga_decode);
>  		vga_set_legacy_decoding(pdev,
> @@ -990,6 +992,8 @@ static void vfio_pci_remove(struct pci_dev *pdev)
>  	iommu_group_put(pdev->dev.iommu_group);
>  	kfree(vdev);
>  
> +	pci_clear_dev_assigned(pdev);
> +
>  	if (vfio_pci_is_vga(pdev)) {
>  		vga_client_register(pdev, NULL, NULL, NULL);
>  		vga_set_legacy_decoding(pdev,
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
