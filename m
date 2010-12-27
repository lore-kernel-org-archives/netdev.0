From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v2] Broadcom CNIC core network driver: fix mem leak
 on allocation failures in cnic_alloc_uio_rings()
Date: Sun, 26 Dec 2010 19:57:52 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724240CE6BCAD8@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <alpine.LNX.2.00.1012262124320.20797@swampdragon.chaosbits.net>
 <1293396850.7726.14.camel@Joe-Laptop>
 <alpine.LNX.2.00.1012262154420.20797@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	"'John(Zongxi) Chen'" <zongxi@broadcom.com>
To: "'Jesper Juhl'" <jj@chaosbits.net>,
	"'Joe Perches'" <joe@perches.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012262154420.20797@swampdragon.chaosbits.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:

> 
> We are leaking memory in drivers/net/cnic.c::cnic_alloc_uio_rings() if
> either of the calls to dma_alloc_coherent() fail. This patch fixes it
> by
> freeing both the memory allocated with kzalloc() and memory allocated
> with
> previous calls to dma_alloc_coherent() when there's a failure.
> 
> Thanks to  Joe Perches <joe@perches.com>  for suggesting a better
> implementation than my initial version.
> 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  cnic.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
>   compile tested only since I don't have the hardware to do a proper
> test.
> 
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> index 92bac19..952afac 100644
> --- a/drivers/net/cnic.c
> +++ b/drivers/net/cnic.c
> @@ -940,7 +940,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev
> *dev, int pages)
>  					   &udev->l2_ring_map,
>  					   GFP_KERNEL | __GFP_COMP);
>  	if (!udev->l2_ring)
> -		return -ENOMEM;
> +		goto err_udev;
> 
>  	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp-
> >l2_single_buf_size;
>  	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
> @@ -948,7 +948,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev
> *dev, int pages)
>  					  &udev->l2_buf_map,
>  					  GFP_KERNEL | __GFP_COMP);
>  	if (!udev->l2_buf)
> -		return -ENOMEM;
> +		goto err_dma;
> 
>  	write_lock(&cnic_dev_lock);
>  	list_add(&udev->list, &cnic_udev_list);
> @@ -959,6 +959,12 @@ static int cnic_alloc_uio_rings(struct cnic_dev
> *dev, int pages)
>  	cp->udev = udev;
> 
>  	return 0;
> + err_dma:
> +	dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
> +       			  udev->l2_ring, udev->l2_ring_map);
> + err_udev:
> +	kfree(udev);
> +	return -ENOMEM;
>  }
> 
>  static int cnic_init_uio(struct cnic_dev *dev)
> 
> 
> 
