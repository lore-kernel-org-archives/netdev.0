From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] mv643xx_eth: fix SMI bus access timeouts
Date: Mon, 03 Nov 2008 15:25:52 -0500
Message-ID: <490F5E50.1000904@garzik.org>
References: <20081101053220.GA13348@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49676 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436AbYKCUZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 15:25:56 -0500
In-Reply-To: <20081101053220.GA13348@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> The mv643xx_eth mii bus implementation uses wait_event_timeout() to
> wait for SMI completion interrupts.
> 
> If wait_event_timeout() would return zero, mv643xx_eth would conclude
> that the SMI access timed out, but this is not necessarily true --
> wait_event_timeout() can also return zero in the case where the SMI
> completion interrupt did happen in time but where it took longer than
> the requested timeout for the process performing the SMI access to be
> scheduled again.  This would lead to occasional SMI access timeouts
> when the system would be under heavy load.
> 
> The fix is to ignore the return value of wait_event_timeout(), and
> to re-check the SMI done bit after wait_event_timeout() returns to
> determine whether or not the SMI access timed out.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
> The commit that introduced this was added in the .28 dev cycle, so
> this fix is for .28 only.  Thanks!
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index d25a302..0e94ed3 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -1065,9 +1065,12 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
>  		return 0;
>  	}
>  
> -	if (!wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
> -				msecs_to_jiffies(100)))
> -		return -ETIMEDOUT;
> +	if (!smi_is_done(msp)) {
> +		wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
> +				   msecs_to_jiffies(100));
> +		if (!smi_is_done(msp))
> +			return -ETIMEDOUT;
> +	}

applied


