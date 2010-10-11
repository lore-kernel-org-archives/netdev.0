From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] b44: fix resume, request_irq after hw reset
Date: Mon, 11 Oct 2010 16:34:40 -0700
Message-ID: <20101011163440.072e0227.akpm@linux-foundation.org>
References: <201010120022.13171.james@albanarts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>,
	Jiri Pirko <jpirko@redhat.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: James Hogan <james@albanarts.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201010120022.13171.james@albanarts.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2010 00:22:12 +0100
James Hogan <james@albanarts.com> wrote:

> This driver was hanging on resume because it was requesting a shared irq
> that it wasn't ready to immediately handle, which was tested in
> request_irq because of the CONFIG_DEBUG_SHIRQ config option. The
> interrupt handler tried to read the interrupt status register but for
> some reason it hung the system.
> 
> The request_irq is now moved a bit later after resetting the hardware
> which seems to fix it.
> 
> Signed-off-by: James Hogan <james@albanarts.com>
> ---
>  drivers/net/b44.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 1e620e2..dbba981 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -2296,12 +2296,6 @@ static int b44_resume(struct ssb_device *sdev)
>  	if (!netif_running(dev))
>  		return 0;
>  
> -	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
> -	if (rc) {
> -		netdev_err(dev, "request_irq failed\n");
> -		return rc;
> -	}
> -
>  	spin_lock_irq(&bp->lock);
>  
>  	b44_init_rings(bp);
> @@ -2309,6 +2303,12 @@ static int b44_resume(struct ssb_device *sdev)
>  	netif_device_attach(bp->dev);
>  	spin_unlock_irq(&bp->lock);
>  
> +	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
> +	if (rc) {
> +		netdev_err(dev, "request_irq failed\n");
> +		return rc;
> +	}
> +
>  	b44_enable_ints(bp);
>  	netif_wake_queue(dev);

OK, running the interrupt handler before b44_init_hw() is presumably
the problem here.

The hardware surely won't be generating interrupts until we've run
b44_init_hw() and b44_enable_ints(), so this patch really is only to
keep CONFIG_DEBUG_SHIRQ happy.
