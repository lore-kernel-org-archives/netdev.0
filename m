From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH 1/2] can: mcp251x: fix resume when device is down
Date: Wed, 15 Jul 2015 15:05:35 +0200
Message-ID: <a52e25bc10d3d669b41f19faedf82d57@agner.ch>
References: <1431966808-26213-1-git-send-email-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chripell@fsfe.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431966808-26213-1-git-send-email-stefan@agner.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc, hi Wolfgang,

Any comment on this two patches? I don't think these have made it in any
tree...

--
Stefan

On 2015-05-18 18:33, Stefan Agner wrote:
> If a valid power regulator or a dummy regulator is used (which
> happens to be the case when no regulator is specified), restart_work
> is queued no matter whether the device was running or not at suspend
> time. Since work queues get initialized in the ndo_open callback,
> resuming leads to a NULL pointer exception.
> 
> Reverse exactly the steps executed at suspend time:
> - Enable the power regulator in any case
> - Enable the transceiver regulator if the device was running, even in
>   case we have a power regulator
> - Queue restart_work only in case the device was running
> 
> Fixes: bf66f3736a94 ("can: mcp251x: Move to threaded interrupts
> instead of workqueues.")
> Signed-off-by: Stefan Agner <stefan@agner.ch>
> ---
>  drivers/net/can/spi/mcp251x.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/can/spi/mcp251x.c b/drivers/net/can/spi/mcp251x.c
> index bf63fee..34c625e 100644
> --- a/drivers/net/can/spi/mcp251x.c
> +++ b/drivers/net/can/spi/mcp251x.c
> @@ -1221,17 +1221,16 @@ static int __maybe_unused
> mcp251x_can_resume(struct device *dev)
>  	struct spi_device *spi = to_spi_device(dev);
>  	struct mcp251x_priv *priv = spi_get_drvdata(spi);
>  
> -	if (priv->after_suspend & AFTER_SUSPEND_POWER) {
> +	if (priv->after_suspend & AFTER_SUSPEND_POWER)
>  		mcp251x_power_enable(priv->power, 1);
> +
> +	if (priv->after_suspend & AFTER_SUSPEND_UP) {
> +		mcp251x_power_enable(priv->transceiver, 1);
>  		queue_work(priv->wq, &priv->restart_work);
>  	} else {
> -		if (priv->after_suspend & AFTER_SUSPEND_UP) {
> -			mcp251x_power_enable(priv->transceiver, 1);
> -			queue_work(priv->wq, &priv->restart_work);
> -		} else {
> -			priv->after_suspend = 0;
> -		}
> +		priv->after_suspend = 0;
>  	}
> +
>  	priv->force_quit = 0;
>  	enable_irq(spi->irq);
>  	return 0;
