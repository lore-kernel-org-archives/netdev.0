From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Broadcom CNIC core network driver: fix mem leak on
 allocation failures in cnic_alloc_uio_rings()
Date: Sun, 26 Dec 2010 12:54:10 -0800
Message-ID: <1293396850.7726.14.camel@Joe-Laptop>
References: <alpine.LNX.2.00.1012262124320.20797@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John(Zongxi) Chen" <zongxi@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012262124320.20797@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2010-12-26 at 21:30 +0100, Jesper Juhl wrote:
> We are leaking memory in drivers/net/cnic.c::cnic_alloc_uio_rings() if 
> either of the calls to dma_alloc_coherent() fail.
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>  cnic.c |   10 ++++++++--
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
[]
> -	if (!udev->l2_ring)
> +	if (!udev->l2_ring) {
> +		kfree(udev);
>  		return -ENOMEM;
> +	}
[]
> -	if (!udev->l2_buf)
> +	if (!udev->l2_buf) {
> +		dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
> +				  udev->l2_ring, udev->l2_ring_map);
> +		kfree(udev);
>  		return -ENOMEM;
> +	}

Perhaps this would be more standard with a goto error / exit block

err_dma:
	dma_free_coherent();
err_udev:
	kfree(udev);
	return -ENOMEM;
