From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] atl1c: Improve driver not to do order 4 GFP_ATOMIC
 allocation
Date: Thu, 03 Dec 2015 09:17:28 -0800
Message-ID: <1449163048.25029.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151126163413.GA3816@amd>
	 <20151127082010.GA2500@dhcp22.suse.cz> <20151128145113.GB4135@amd>
	 <20151203155905.GA31974@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Hocko <mhocko@kernel.org>, davem@davemloft.net, Andrew Morton
 <akpm@osdl.org>, kernel list <linux-kernel@vger.kernel.org>,
 jcliburn@gmail.com,  chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael
 J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org,
 nic-devel@qualcomm.com,  ronangeles@gmail.com, ebiederm@xmission.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151203155905.GA31974@amd>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-03 at 16:59 +0100, Pavel Machek wrote:
> atl1c driver is doing order-4 allocation with GFP_ATOMIC
> priority. That often breaks  networking after resume. Switch to
> GFP_KERNEL. Still not ideal, but should be significantly better.
> 
> atl1c_setup_ring_resources() is called from .open() function, and
> already uses GFP_KERNEL, so this change is safe.
>     
> Signed-off-by: Pavel Machek <pavel@ucw.cz>
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
> +		dev_err(&pdev->dev, "could not get memory for DMA buffer\n");
>  		goto err_nomem;
>  	}
>  	memset(ring_header->desc, 0, ring_header->size);
> 
> 

So this memset() will really require a different patch to get removed ?

Sigh, not sure why I review patches.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
