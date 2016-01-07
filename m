From: Robert Richter <rric@kernel.org>
Subject: Re: [PATCH] net-thunder: One check less in
 nicvf_register_interrupts() after error detection
Date: Thu, 7 Jan 2016 12:07:01 +0100
Message-ID: <20160107110701.GE25086@rric.localdomain>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5685A273.6070607@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5685A273.6070607@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.12.15 22:47:31, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 31 Dec 2015 22:40:39 +0100
> 
> Adjust a jump target to eliminate a check before error logging.
> Use the identifier "report_failure" instead of "err".

I don't see much value in those changes. Using the 'err' label is ok
as it is not misleading and common use. And, there is no need to
optimize the check since this is not the fast path and will be
compiler optimized anyway. So let's keep the code as it is with the
flavor of the original author.

-Robert

> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> index c24cb2a..21e1579 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> @@ -922,7 +922,7 @@ static int nicvf_register_interrupts(struct nicvf *nic)
>  		ret = request_irq(vector, nicvf_intr_handler,
>  				  0, nic->irq_name[irq], nic->napi[irq]);
>  		if (ret)
> -			goto err;
> +			goto report_failure;
>  		nic->irq_allocated[irq] = true;
>  	}
>  
> @@ -933,7 +933,7 @@ static int nicvf_register_interrupts(struct nicvf *nic)
>  		ret = request_irq(vector, nicvf_rbdr_intr_handler,
>  				  0, nic->irq_name[irq], nic);
>  		if (ret)
> -			goto err;
> +			goto report_failure;
>  		nic->irq_allocated[irq] = true;
>  	}
>  
> @@ -944,13 +944,12 @@ static int nicvf_register_interrupts(struct nicvf *nic)
>  	ret = request_irq(nic->msix_entries[irq].vector,
>  			  nicvf_qs_err_intr_handler,
>  			  0, nic->irq_name[irq], nic);
> -	if (!ret)
> +	if (!ret) {
>  		nic->irq_allocated[irq] = true;
> -
> -err:
> -	if (ret)
> -		netdev_err(nic->netdev, "request_irq failed, vector %d\n", irq);
> -
> +		return 0;
> +	}
> +report_failure:
> +	netdev_err(nic->netdev, "request_irq failed, vector %d\n", irq);
>  	return ret;
>  }
