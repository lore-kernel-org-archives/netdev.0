From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/9] PCI: add interface to set visible size of VPD (rev3)
Date: Thu, 25 Sep 2008 13:22:32 -0400
Message-ID: <48DBC8D8.2080207@pobox.com>
References: <20080925164851.694359776@vyatta.com> <20080925165223.366942933@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080925165223.366942933@vyatta.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The VPD on all devices may not be 32K. Unfortunately, there is no
> generic way to find the size, so this adds a simple API hook
> to reset it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
>  drivers/pci/access.c |   23 +++++++++++++++++++++++
>  include/linux/pci.h  |    1 +
>  2 files changed, 24 insertions(+)
> 
> --- a/drivers/pci/access.c	2008-09-09 13:57:05.000000000 -0700
> +++ b/drivers/pci/access.c	2008-09-09 13:57:06.000000000 -0700
> @@ -340,6 +340,29 @@ int pci_vpd_pci22_init(struct pci_dev *d
>  }
>  
>  /**
> + * pci_vpd_truncate - Set available Vital Product Data size
> + * @dev:	pci device struct
> + * @size:	available memory in bytes
> + *
> + * Adjust size of available VPD area.
> + */
> +int pci_vpd_truncate(struct pci_dev *dev, size_t size)
> +{
> +	if (!dev->vpd)
> +		return -EINVAL;
> +
> +	/* limited by the access method */
> +	if (size > dev->vpd->len)
> +		return -EINVAL;
> +
> +	dev->vpd->len = size;
> +	dev->vpd->attr->size = size;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(pci_vpd_truncate);

What is the initial size?

It seems like a bad idea to start out assuming the max, and reduce once 
a knowledgeable driver appears.

It seems more safe to start out at zero, and let a driver increase it?

That way, by design, you eliminate the possibility (later, if not now) 
of someone assuming that the full 32k can be read as soon as the 
interface is available.

	Jeff
