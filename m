From: Jon Mason <jon.mason-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 01/77] PCI/MSI: Fix return value when
 populate_msi_sysfs() failed
Date: Wed, 2 Oct 2013 17:39:05 -0700
Message-ID: <20131003003905.GK6768@jonmason-lab>
References: <cover.1380703262.git.agordeev@redhat.com>
 <3ff5236944aae69f2cd934b5b6da7c1c269df7c1.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andy King <acking-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
	Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iss_storagedev-VXdhtT5mjnY@public.gmane.org,
	linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	Solarflare linux maintainers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	"VMware, Inc." <pv-drivers@vmw
To: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3ff5236944aae69f2cd934b5b6da7c1c269df7c1.1380703262.git.agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:48:17PM +0200, Alexander Gordeev wrote:
> Signed-off-by: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Since you are changing the behavior of the msix_capability_init
function on populate_msi_sysfs error, a comment describing why in this
commit would be nice.

> ---
>  drivers/pci/msi.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index d5f90d6..b43f391 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -719,7 +719,7 @@ static int msix_capability_init(struct pci_dev *dev,
>  
>  	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
>  	if (ret)
> -		goto error;
> +		goto out_avail;
>  
>  	/*
>  	 * Some devices require MSI-X to be enabled before we can touch the
> @@ -732,10 +732,8 @@ static int msix_capability_init(struct pci_dev *dev,
>  	msix_program_entries(dev, entries);
>  
>  	ret = populate_msi_sysfs(dev);
> -	if (ret) {
> -		ret = 0;
> -		goto error;
> -	}
> +	if (ret)
> +		goto out_free;
>  
>  	/* Set MSI-X enabled bits and unmask the function */
>  	pci_intx_for_msi(dev, 0);
> @@ -746,7 +744,7 @@ static int msix_capability_init(struct pci_dev *dev,
>  
>  	return 0;
>  
> -error:
> +out_avail:
>  	if (ret < 0) {
>  		/*
>  		 * If we had some success, report the number of irqs
> @@ -763,6 +761,7 @@ error:
>  			ret = avail;
>  	}
>  
> +out_free:
>  	free_msi_irqs(dev);
>  
>  	return ret;
> -- 
> 1.7.7.6
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
