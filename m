From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Improve Atheros ethernet driver not to do order 4
 GFP_ATOMIC allocation
Date: Mon, 30 Nov 2015 14:21:29 +0100
Message-ID: <20151130132129.GB21950@dhcp22.suse.cz>
References: <20151126163413.GA3816@amd>
 <20151127082010.GA2500@dhcp22.suse.cz>
 <20151128145113.GB4135@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Andrew Morton <akpm@osdl.org>,
	kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com,
	chris.snook@gmail.com, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org,
	nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20151128145113.GB4135@amd>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat 28-11-15 15:51:13, Pavel Machek wrote:
> 
> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> priority. That often breaks  networking after resume. Switch to
> GFP_KERNEL. Still not ideal, but should be significantly better.

It is not clear why GFP_KERNEL can replace GFP_ATOMIC safely neither
from the changelog nor from the patch context. It is correct here
because atl1c_setup_ring_resources is a sleepable context (otherwise
tpd_ring->buffer_info = kzalloc(size, GFP_KERNEL) would be incorrect
already) but a short note wouldn't kill us, would it?

> Signed-off-by: Pavel Machek <pavel@ucw.cz>

Anyway
Reviewed-by: Michal Hocko <mhocko@suse.com>

> 
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 2795d6d..afb71e0 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1016,10 +1016,10 @@ static int atl1c_setup_ring_resources(struct atl1c_adapter *adapter)
>  		sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
>  		8 * 4;
>  
> -	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
> -				&ring_header->dma);
> +	ring_header->desc = dma_alloc_coherent(&pdev->dev, ring_header->size,
> +					       &ring_header->dma, GFP_KERNEL);
>  	if (unlikely(!ring_header->desc)) {
> -		dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
> +		dev_err(&pdev->dev, "could not get memmory for DMA buffer\n");
>  		goto err_nomem;
>  	}
>  	memset(ring_header->desc, 0, ring_header->size);
> 
> -- 
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
