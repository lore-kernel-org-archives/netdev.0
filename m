From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] pci: Add dev_flags bit to access
 VPD through function 0
Date: Tue, 02 Jun 2015 10:48:48 -0700
Message-ID: <556DEC80.70206@redhat.com>
References: <20150602165706.6252.76253.stgit@mdrustad-wks.jf.intel.com> <20150602170414.6252.48036.stgit@mdrustad-wks.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: Mark D Rustad <mark.d.rustad@intel.com>, bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752769AbbFBRs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 13:48:57 -0400
In-Reply-To: <20150602170414.6252.48036.stgit@mdrustad-wks.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2015 10:04 AM, Mark D Rustad wrote:
> Add a dev_flags bit, PCI_DEV_FLAGS_VPD_REF_F0, to access VPD through
> function 0 to provide VPD access on other functions. This solves
> concurrent access problems on many devices without changing the
> attributes exposed in sysfs. Never set this bit on funciton 0 or
> there will be an infinite recursion.
>
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> ---
>   drivers/pci/access.c |   39 ++++++++++++++++++++++++++++++++++++++-
>   include/linux/pci.h  |    2 ++
>   2 files changed, 40 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/pci/access.c b/drivers/pci/access.c
> index d9b64a175990..e435c087c354 100644
> --- a/drivers/pci/access.c
> +++ b/drivers/pci/access.c
> @@ -439,6 +439,40 @@ static const struct pci_vpd_ops pci_vpd_pci22_ops = {
>   	.release = pci_vpd_pci22_release,
>   };
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

I'm pretty sure these could cause some serious errors if you direct 
assign the device into a VM since you then end up with multiple devices 
sharing a bus.  Also it would likely have side-effects on a LOM (Lan On 
Motherboard) as it also shares the bus with multiple non-Ethernet devices.

I believe you still need to add something like a check for 
!pci_is_root_bus(dev->bus) before you attempt to grab function 0.  It 
probably also wouldn't hurt to check the dev->multifunction bit before 
running this code since it wouldn't make sense to go chasing down the 
VPD on another function if the device doesn't have one.  You could 
probably do that either as a part of this code, or perhaps put it in the 
quirk.

- Alex

- Alex
