From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [net-next 5/5] PCI: disable FLR for 82579 device
Date: Fri, 23 Sep 2016 07:19:59 -0600
Message-ID: <20160923071959.55dd9745@t450s.home>
References: <1474612741-75681-1-git-send-email-jeffrey.t.kirsher@intel.com>
        <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhelgaas@google.com,
        Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, linux-pci@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1474612741-75681-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Sep 2016 23:39:01 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

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
> 
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

This seems like a pretty fragile quirk since we're just hoping that the
BIOS hasn't already written this byte.  Should we at least re-read and
warn if the write didn't take?  What about using dev_flags or a device
specific reset to make this less fragile?  A device specific reset
could pick the best reset mechanism for the device, ignoring AF FLR.
Thanks,

Alex
