From: Shradha Shah <sshah@solarflare.com>
Subject: Re: [PATCH 31/34] efx: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 17:21:59 +0000
Message-ID: <52EBDBB7.9010503@solarflare.com>
References: <cover.1391172839.git.agordeev@redhat.com> <433fe68f834c10679986274f4bb605aa4ed5eaf3.1391172839.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Solarflare maintainers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <433fe68f834c10679986274f4bb605aa4ed5eaf3.1391172839.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/31/2014 03:08 PM, Alexander Gordeev wrote:
> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.
> 
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>

Acked-by: Shradha Shah <sshah@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/efx.c |   20 +++++++++-----------
>  1 files changed, 9 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index 83d4643..297b97a 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -1346,20 +1346,23 @@ static int efx_probe_interrupts(struct efx_nic *efx)
>  
>  		for (i = 0; i < n_channels; i++)
>  			xentries[i].entry = i;
> -		rc = pci_enable_msix(efx->pci_dev, xentries, n_channels);
> -		if (rc > 0) {
> +		rc = pci_enable_msix_range(efx->pci_dev,
> +					   xentries, 1, n_channels);
> +		if (rc < 0) {
> +			/* Fall back to single channel MSI */
> +			efx->interrupt_mode = EFX_INT_MODE_MSI;
> +			netif_err(efx, drv, efx->net_dev,
> +				  "could not enable MSI-X\n");
> +		} else if (rc < n_channels) {
>  			netif_err(efx, drv, efx->net_dev,
>  				  "WARNING: Insufficient MSI-X vectors"
>  				  " available (%d < %u).\n", rc, n_channels);
>  			netif_err(efx, drv, efx->net_dev,
>  				  "WARNING: Performance may be reduced.\n");
> -			EFX_BUG_ON_PARANOID(rc >= n_channels);
>  			n_channels = rc;
> -			rc = pci_enable_msix(efx->pci_dev, xentries,
> -					     n_channels);
>  		}
>  
> -		if (rc == 0) {
> +		if (rc > 0) {
>  			efx->n_channels = n_channels;
>  			if (n_channels > extra_channels)
>  				n_channels -= extra_channels;
> @@ -1375,11 +1378,6 @@ static int efx_probe_interrupts(struct efx_nic *efx)
>  			for (i = 0; i < efx->n_channels; i++)
>  				efx_get_channel(efx, i)->irq =
>  					xentries[i].vector;
> -		} else {
> -			/* Fall back to single channel MSI */
> -			efx->interrupt_mode = EFX_INT_MODE_MSI;
> -			netif_err(efx, drv, efx->net_dev,
> -				  "could not enable MSI-X\n");
>  		}
>  	}
>  
> 
