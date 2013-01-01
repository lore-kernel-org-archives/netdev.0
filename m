From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54pci: don't return zero on failure path in p54p_probe()
Date: Tue, 1 Jan 2013 22:45:42 +0100
Message-ID: <201301012245.43064.chunkeey@googlemail.com>
References: <1357074661-15784-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:61791 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3AAVpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 16:45:49 -0500
In-Reply-To: <1357074661-15784-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 January 2013 22:11:01 Alexey Khoroshilov wrote:
> If pci_set_dma_mask() or pci_set_consistent_dma_mask() fails in p54p_probe(),
> it breaks off initialization, deallocates all resources, but returns zero.
> 
> The patch implements proper error code propagation.

Uh, Thanks!

But wait, I think there's another return 0 in the error
path. See p54pci.c @ line 558:

mem_len = pci_resource_len(pdev, 0);
if (mem_len < sizeof(...)) {
	dev_err(...)
	goto err_disabled_dev;
}

Do you think you can add a err = -EINVAL; before the goto too?
[I wonder why this wasn't found by the verification project as
well? Could it be that pci_resource_len(...) < sizeof(...) is 
somehow always true and this is a dead branch?]

> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>

Regards,
	Christian
> ---
>  drivers/net/wireless/p54/p54pci.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
> index 933e5d9..fef69ea 100644
> --- a/drivers/net/wireless/p54/p54pci.c
> +++ b/drivers/net/wireless/p54/p54pci.c
> @@ -568,8 +568,10 @@ static int p54p_probe(struct pci_dev *pdev,
>  		goto err_disable_dev;
>  	}
>  
> -	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
> -	    pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
> +	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
> +	if (!err)
> +		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
> +	if (err) {
>  		dev_err(&pdev->dev, "No suitable DMA available\n");
>  		goto err_free_reg;
>  	}
> 
