From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [net-next 5/5] PCI: disable FLR for 82579 device
Date: Fri, 23 Sep 2016 09:01:36 -0500
Message-ID: <20160923140136.GC1514@localhost>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, bhelgaas@google.com,
        Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, linux-pci@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56084 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034358AbcIWOBm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 10:01:42 -0400
Content-Disposition: inline
In-Reply-To: <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 11:39:01PM -0700, Jeff Kirsher wrote:
> From: Sasha Neftin <sasha.neftin@intel.com>
> 
> 82579 has a problem reattaching itself after the device is detached.
> The bug was reported by Redhat. The suggested fix is to disable
> FLR capability in PCIe configuration space.
> 
> Reproduction:
> Attach the device to a VM, then detach and try to attach again.
> 
> Fix:
> Disable FLR capability to prevent the 82579 from hanging.

Is there a bugzilla or other reference URL to include here?  Should
this be marked for stable?

> Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/pci/quirks.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index 44e0ff3..59fba6e 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -4431,3 +4431,24 @@ static void quirk_intel_qat_vf_cap(struct pci_dev *pdev)
>  	}
>  }
>  DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x443, quirk_intel_qat_vf_cap);
> +/*
> + * Workaround FLR issues for 82579
> + * This code disables the FLR (Function Level Reset) via PCIe, in order
> + * to workaround a bug found while using device passthrough, where the
> + * interface would become non-responsive.
> + * NOTE: the FLR bit is Read/Write Once (RWO) in config space, so if
> + * the BIOS or kernel writes this register * then this workaround will
> + * not work.

This doesn't sound like a root cause.  Is the issue a hardware
erratum?  Linux PCI core bug?  VFIO bug?  Device firmware bug?

The changelog suggests that the problem only affects passthrough,
which suggests some sort of kernel bug related to how passthrough is
implemented.

> + */
> +static void quirk_intel_flr_cap_dis(struct pci_dev *dev)
> +{
> +	int pos = pci_find_capability(dev, PCI_CAP_ID_AF);
> +	if (pos) {
> +		u8 cap;
> +		pci_read_config_byte(dev, pos + PCI_AF_CAP, &cap);
> +		cap = cap & (~PCI_AF_CAP_FLR);
> +		pci_write_config_byte(dev, pos + PCI_AF_CAP, cap);
> +	}
> +}
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1502, quirk_intel_flr_cap_dis);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, 0x1503, quirk_intel_flr_cap_dis);
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
