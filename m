From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: Make sure both ports initialize correctly
Date: Wed, 30 Sep 2009 17:28:21 -0700
Message-ID: <20090930172821.7c6bd127@s6510>
References: <4ABA27AC.7030207@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40299 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898AbZJAA2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 20:28:20 -0400
In-Reply-To: <4ABA27AC.7030207@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2009 22:50:36 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> If allocation of the second ports fails, make sure that hw->ports
>  is not 2 otherwise we'll crash trying to access the second port.
> 
> This fix is copied from a similar fix in the sky2 driver (ca519274...),
> but is untested, as I don't have a skge card.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/skge.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index 62e852e..21b816f 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -3982,14 +3982,17 @@ static int __devinit skge_probe(struct pci_dev *pdev,
>  	}
>  	skge_show_addr(dev);
>  
> -	if (hw->ports > 1 && (dev1 = skge_devinit(hw, 1, using_dac))) {
> -		if (register_netdev(dev1) == 0)
> +	if (hw->ports > 1) {
> +		dev1 = skge_devinit(hw, 1, using_dac);
> +		if (dev1 && register_netdev(dev1) == 0)
>  			skge_show_addr(dev1);
>  		else {
>  			/* Failure to register second port need not be fatal */
>  			dev_warn(&pdev->dev, "register of second port failed\n");
>  			hw->dev[1] = NULL;
> -			free_netdev(dev1);
> +			hw->ports = 1;
> +			if (dev1)
> +				free_netdev(dev1);
>  		}
>  	}
>  	pci_set_drvdata(pdev, hw);

Looks good.
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
