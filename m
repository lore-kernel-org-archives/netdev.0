From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] e100: Add missing dma sync for proper operation with
 non-coherent caches.
Date: Tue, 26 Aug 2008 14:50:13 -0400
Message-ID: <48B45065.5050907@roinet.com>
References: <48B3A8D0.2040108@avtrex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-mips <linux-mips@linux-mips.org>
To: David Daney <ddaney@avtrex.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <48B3A8D0.2040108@avtrex.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

David Daney wrote:
> I am running the e100 driver on a MIPS 4KEc system (32 bit mips with
> non-coherent DMA).  There was a problem where received packets would
> get 'stuck' for several seconds at a time and then be released all at
> once.
> 
> The cause was that if an interrupt were received when no RX packets
> were available, the status for the receive buffer would be stuck in
> the cache, so when the next interrupt arrived the old status value was
> read (indicating no packets available) instead of the new value.
> 
> The fix is to call pci_dma_sync_single_for_device on the RX if the
> packet is not available to invalidate the cache so that at the next
> interrupt valid status is returned.
> 
> The driver currently calls pci_dma_sync_single_for_cpu before reading
> the status, and this is indeed needed for cases like the R10000 CPU
> where the cache can be polluted by speculative execution, but for most
> machines it is a nop.
> 
> The patch was tested on 2.6.17-rc4 on a MIPS 4KEc.
> 
> Signed-off-by: David Daney <ddaney@avtrex.com>
> ---
>  drivers/net/e100.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 19d32a2..fb8d551 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1840,6 +1840,11 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
>  
>  			if (readb(&nic->csr->scb.status) & rus_no_res)
>  				nic->ru_running = RU_SUSPENDED;
> +		/* We are done looking at the buffer.  Prepare it for
> +		 * more DMA.  */
> +		pci_dma_sync_single_for_device(nic->pdev, rx->dma_addr,
> +					       sizeof(struct rfd),
> +					       PCI_DMA_FROMDEVICE);
>  		return -ENODATA;
>  	}
>  
Should the call to pci_dma_sync_single_for_device be DMA_TO_DEVICE since 
we are giving the memory back to the device?
-ack
