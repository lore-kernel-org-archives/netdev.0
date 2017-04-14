From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH 1/7] PCI: export pcie_flr
Date: Fri, 14 Apr 2017 09:34:16 -0500
Message-ID: <20170414143416.GA29349@bhelgaas-glaptop.roam.corp.google.com>
References: <20170413145339.20186-1-hch@lst.de>
 <20170413145339.20186-2-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alex Williamson <alex.williamson@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170413145339.20186-2-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc Alex]

On Thu, Apr 13, 2017 at 04:53:33PM +0200, Christoph Hellwig wrote:
> Currently we opencode the FLR sequence in lots of place, export a core
> helper instead.  We split out the probing for FLR support as all the
> non-core callers already know their hardware.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/pci/pci.c   | 34 +++++++++++++++++++++++++---------
>  include/linux/pci.h |  1 +
>  2 files changed, 26 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 7904d02ffdb9..3256a63c5d08 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -3773,24 +3773,38 @@ static void pci_flr_wait(struct pci_dev *dev)
>  			 (i - 1) * 100);
>  }
>  
> -static int pcie_flr(struct pci_dev *dev, int probe)
> +/**
> + * pcie_has_flr - check if a device supports function level resets
> + * @dev:	device to check
> + *
> + * Returns true if the device advertises support for PCIe function level
> + * resets.
> + */
> +static bool pcie_has_flr(struct pci_dev *dev)
>  {
>  	u32 cap;
>  
>  	pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
> -	if (!(cap & PCI_EXP_DEVCAP_FLR))
> -		return -ENOTTY;
> -
> -	if (probe)
> -		return 0;
> +	return cap & PCI_EXP_DEVCAP_FLR;
> +}
>  
> +/**
> + * pcie_flr - initiate a PCIe function level reset
> + * @dev:	device to reset
> + *
> + * Initiate a function level reset on @dev.  The caller should ensure the
> + * device supports FLR before calling this function, e.g. by using the
> + * pcie_has_flr helper.

s/pcie_has_flr/pcie_has_flr()/

> + */
> +void pcie_flr(struct pci_dev *dev)
> +{
>  	if (!pci_wait_for_pending_transaction(dev))
>  		dev_err(&dev->dev, "timed out waiting for pending transaction; performing function level reset anyway\n");
>  
>  	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
>  	pci_flr_wait(dev);
> -	return 0;
>  }
> +EXPORT_SYMBOL_GPL(pcie_flr);
>  
>  static int pci_af_flr(struct pci_dev *dev, int probe)
>  {
> @@ -3971,9 +3985,11 @@ static int __pci_dev_reset(struct pci_dev *dev, int probe)
>  	if (rc != -ENOTTY)
>  		goto done;
>  
> -	rc = pcie_flr(dev, probe);
> -	if (rc != -ENOTTY)
> +	if (pcie_has_flr(dev)) {
> +		pcie_flr(dev);
> +		rc = 0;
>  		goto done;
> +	}

This performs an FLR (if supported) always, regardless of "probe".
I think it should look something like this instead:

  if (pcie_has_flr(dev)) {
    if (!probe)
      pcie_flr(dev);
    rc = 0;
    goto done;
  }

>  	rc = pci_af_flr(dev, probe);
>  	if (rc != -ENOTTY)
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index eb3da1a04e6c..f35e51eddad0 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1052,6 +1052,7 @@ int pcie_get_mps(struct pci_dev *dev);
>  int pcie_set_mps(struct pci_dev *dev, int mps);
>  int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
>  			  enum pcie_link_width *width);
> +void pcie_flr(struct pci_dev *dev);
>  int __pci_reset_function(struct pci_dev *dev);
>  int __pci_reset_function_locked(struct pci_dev *dev);
>  int pci_reset_function(struct pci_dev *dev);
> -- 
> 2.11.0
> 
