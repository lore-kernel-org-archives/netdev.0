From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH V4 1/2] pci: Add dev_flags bit to access VPD through
 function 0
Date: Tue, 15 Sep 2015 12:19:12 -0600
Message-ID: <1442341152.23936.122.camel@redhat.com>
References: <20150713183821.19985.52157.stgit@mdrustad-wks.jf.intel.com>
	 <20150713184001.19985.64867.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, linux-pci@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Myron Stowe <myron.stowe@redhat.com>
To: Mark D Rustad <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbbIOSTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 14:19:13 -0400
In-Reply-To: <20150713184001.19985.64867.stgit@mdrustad-wks.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-13 at 11:40 -0700, Mark D Rustad wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Add a dev_flags bit, PCI_DEV_FLAGS_VPD_REF_F0, to access VPD through
> function 0 to provide VPD access on other functions. This is for
> hardware devices that provide copies of the same VPD capability
> registers in multiple functions. Because the kernel expects that
> each function has its own registers, both the locking and the state
> tracking are affected by VPD accesses to different functions.
> 
> On such devices for example, if a VPD write is performed on function
> 0, *any* later attempt to read VPD from any other function of that
> device will hang. This has to do with how the kernel tracks the
> expected value of the F bit per function.
> 
> Concurrent accesses to different functions of the same device can
> not only hang but also corrupt both read and write VPD data.
> 
> When hangs occur, typically the error message:
> 
> vpd r/w failed.  This is likely a firmware bug on this device.
> 
> will be seen.
> 
> Never set this bit on function 0 or there will be an infinite recursion.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> ---
> Changes in V2:
> - Corrected spelling in log message
> - Added checks to see that the referenced function 0 is reasonable
> Changes in V3:
> - Don't leak a device reference
> - Check that function 0 has VPD
> - Make a helper for the function 0 checks
> - Do multifunction check in the quirk
> Changes in V4:
> - Provide a much more detailed explanation in the commit log
> ---
>  drivers/pci/access.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/pci.h  |    2 ++
>  2 files changed, 62 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/pci/access.c b/drivers/pci/access.c
> index d9b64a175990..b965c12168b7 100644
> --- a/drivers/pci/access.c
> +++ b/drivers/pci/access.c
> @@ -439,6 +439,56 @@ static const struct pci_vpd_ops pci_vpd_pci22_ops = {
>  	.release = pci_vpd_pci22_release,
>  };
>  
> +static ssize_t pci_vpd_f0_read(struct pci_dev *dev, loff_t pos, size_t count,
> +			       void *arg)
> +{
> +	struct pci_dev *tdev = pci_get_slot(dev->bus, PCI_SLOT(dev->devfn));
> +	ssize_t ret;
> +
> +	if (!tdev)
> +		return -ENODEV;
> +
> +	ret = pci_read_vpd(tdev, pos, count, arg);
> +	pci_dev_put(tdev);
> +	return ret;
> +}
> +
> +static ssize_t pci_vpd_f0_write(struct pci_dev *dev, loff_t pos, size_t count,
> +				const void *arg)
> +{
> +	struct pci_dev *tdev = pci_get_slot(dev->bus, PCI_SLOT(dev->devfn));
> +	ssize_t ret;
> +
> +	if (!tdev)
> +		return -ENODEV;
> +
> +	ret = pci_write_vpd(tdev, pos, count, arg);
> +	pci_dev_put(tdev);
> +	return ret;
> +}
> +
> +static const struct pci_vpd_ops pci_vpd_f0_ops = {
> +	.read = pci_vpd_f0_read,
> +	.write = pci_vpd_f0_write,
> +	.release = pci_vpd_pci22_release,
> +};
> +
> +static int pci_vpd_f0_dev_check(struct pci_dev *dev)
> +{
> +	struct pci_dev *tdev = pci_get_slot(dev->bus, PCI_SLOT(dev->devfn));
> +	int ret = 0;
> +
> +	if (!tdev)
> +		return -ENODEV;
> +	if (!tdev->vpd || !tdev->multifunction ||
> +	    dev->class != tdev->class || dev->vendor != tdev->vendor ||
> +	    dev->device != tdev->device)
> +		ret = -ENODEV;
> +
> +	pci_dev_put(tdev);
> +	return ret;
> +}
> +
>  int pci_vpd_pci22_init(struct pci_dev *dev)
>  {
>  	struct pci_vpd_pci22 *vpd;
> @@ -447,12 +497,21 @@ int pci_vpd_pci22_init(struct pci_dev *dev)
>  	cap = pci_find_capability(dev, PCI_CAP_ID_VPD);
>  	if (!cap)
>  		return -ENODEV;
> +	if (dev->dev_flags & PCI_DEV_FLAGS_VPD_REF_F0) {
> +		int ret = pci_vpd_f0_dev_check(dev);
> +
> +		if (ret)
> +			return ret;
> +	}


In addition to the (PCI_SLOT() != devfn) issue, I'm concerned about
topologies like we see on Skylake.  IIRC, the integrated NIC appears at
something like 00:1f.6.  I don't know if that specific NIC has VPD, nor
am I sure it really matter because another example or some future
version might.  So we'll set the PCI_DEV_FLAGS_VPD_REF_F0 because we do
so for all (PCI_FUNC() != 0) Intel NICs, we'll call
pci_vpd_f0_dev_check(), which will error because function 0 has a
different class code and device ID, so we return error and if VPD exists
on the device, it's now inaccessible.

I thought there was talk about whitelisting anything on the root bus to
avoid strange root complex integrated devices (and perhaps avoid the
general case for assigned devices within a VM), but I don't see anything
like that here.

Perhaps instead of failing and hiding VPD we should fail, clear the
flag, and allow normal access.  Thanks,

Alex

>  	vpd = kzalloc(sizeof(*vpd), GFP_ATOMIC);
>  	if (!vpd)
>  		return -ENOMEM;
>  
>  	vpd->base.len = PCI_VPD_PCI22_SIZE;
> -	vpd->base.ops = &pci_vpd_pci22_ops;
> +	if (dev->dev_flags & PCI_DEV_FLAGS_VPD_REF_F0)
> +		vpd->base.ops = &pci_vpd_f0_ops;
> +	else
> +		vpd->base.ops = &pci_vpd_pci22_ops;
>  	mutex_init(&vpd->lock);
>  	vpd->cap = cap;
>  	vpd->busy = false;
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 8a0321a8fb59..8edb125db13a 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -180,6 +180,8 @@ enum pci_dev_flags {
>  	PCI_DEV_FLAGS_NO_BUS_RESET = (__force pci_dev_flags_t) (1 << 6),
>  	/* Do not use PM reset even if device advertises NoSoftRst- */
>  	PCI_DEV_FLAGS_NO_PM_RESET = (__force pci_dev_flags_t) (1 << 7),
> +	/* Get VPD from function 0 VPD */
> +	PCI_DEV_FLAGS_VPD_REF_F0 = (__force pci_dev_flags_t) (1 << 8),
>  };
>  
>  enum pci_irq_reroute_variant {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
