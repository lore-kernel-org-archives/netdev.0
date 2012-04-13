From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Fri, 13 Apr 2012 10:46:28 -0700
Message-ID: <4F886674.7050207@codeaurora.org>
References: <1334272530-11119-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, davem@davemloft.net,
	Ben Dooks <ben-linux@fluff.org>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:23628 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170Ab2DMRqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:46:30 -0400
In-Reply-To: <1334272530-11119-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/12 16:15, mjr@cs.wisc.edu wrote:
> From: Matt Renzelmann <mjr@cs.wisc.edu>
>
> All calls to ks8851_rdreg* and ks8851_wrreg* should be protected with
> the driver's lock mutex.  A spurious interrupt may otherwise cause a
> crash. 

This doesn't make any sense anymore because you don't do any mutex things.

>  Thanks to Stephen Boyd, Flavio Leitner, and Ben Hutchings for
> feedback.
>
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> ---
>
> This modified version incorporates Ben Hutchings' bugfix by removing
> the incorrect call to CIDER_REV_GET.
>
>  drivers/net/ethernet/micrel/ks8851.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> index c722aa6..e5dc075 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -1418,6 +1418,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	struct net_device *ndev;
>  	struct ks8851_net *ks;
>  	int ret;
> +	unsigned cider;
>  
>  	ndev = alloc_etherdev(sizeof(struct ks8851_net));
>  	if (!ndev)
> @@ -1484,8 +1485,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	ks8851_soft_reset(ks, GRR_GSR);
>  
>  	/* simple check for a valid chip being connected to the bus */
> -
> -	if ((ks8851_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
> +	cider = ks8851_rdreg16(ks, KS_CIDER);
> +	if ((cider & ~CIDER_REV_MASK) != CIDER_ID) {
>  		dev_err(&spi->dev, "failed to read device ID\n");
>  		ret = -ENODEV;
>  		goto err_id;
> @@ -1516,8 +1517,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
>  	}
>  
>  	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
> -		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
> -		    ndev->dev_addr, ndev->irq,
> +		    CIDER_REV_GET(cider), ndev->dev_addr, ndev->irq,
>  		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
>  
>  	return 0;

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
