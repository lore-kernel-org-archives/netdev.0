From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 5/5] net: sh_eth: use NAPI
Date: Fri, 11 May 2012 16:35:29 +0100
Message-ID: <1336750529.2874.69.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FACD007.1070308@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4FACD007.1070308@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-05-11 at 17:38 +0900, Shimoda, Yoshihiro wrote:
> This patch modifies the driver to use NAPI.
[...]
> +static int sh_eth_poll(struct napi_struct *napi, int budget)
> +{
> +	struct sh_eth_private *mdp = container_of(napi, struct sh_eth_private,
> +						  napi);
> +	struct net_device *ndev = mdp->ndev;
> +	struct sh_eth_cpu_data *cd = mdp->cd;
> +	int work_done = 0, txfree_num;
> +	u32 intr_status = sh_eth_read(ndev, EESR);
> +
> +	/* Clear interrupt flags */
> +	sh_eth_write(ndev, intr_status, EESR);
> +
> +	/* check txdesc */
> +	txfree_num = sh_eth_txfree(ndev);
> +	if (txfree_num)
>  		netif_wake_queue(ndev);
> -	}
> 
> +	/* check rxdesc */
> +	sh_eth_rx(ndev, &work_done, budget);
> +
> +	/* check error flags */
>  	if (intr_status & cd->eesr_err_check)
>  		sh_eth_error(ndev, intr_status);
> 
> -other_irq:
> -	spin_unlock(&mdp->lock);
> +	/* get current interrupt flags */
> +	intr_status = sh_eth_read(ndev, EESR);
> 
> -	return ret;
> +	/* check whether the controller doesn't have any events */
> +	if (!txfree_num && !(intr_status & cd->eesr_err_check) &&
> +	    work_done < budget) {
> +		napi_complete(napi);

If and only if you return a value less than the budget then you *must*
call napi_complete().  You can't add these extra conditions.

> +		/* Enable all interrupts */
> +		sh_eth_write(ndev, cd->eesipr_value, EESIPR);
> +	}
> +
> +	return work_done;
>  }
> 
>  /* PHY state control function */
> @@ -1565,6 +1590,8 @@ static int sh_eth_open(struct net_device *ndev)
> 
>  	pm_runtime_get_sync(&mdp->pdev->dev);
> 
> +	napi_enable(&mdp->napi);
> +
>  	ret = request_irq(ndev->irq, sh_eth_interrupt,
>  #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
>  	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
> @@ -1705,6 +1732,8 @@ static int sh_eth_close(struct net_device *ndev)
>  		phy_disconnect(mdp->phydev);
>  	}
> 
> +	napi_disable(&mdp->napi);
> +
[...]

You will also need to call napi_disable() and napi_enable() in the
set_ringparam implementation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

