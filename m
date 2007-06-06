From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/4] b44: timer power saving
Date: Wed, 6 Jun 2007 21:01:20 +0200
Message-ID: <200706062101.20643.mb@bu3sch.de>
References: <20070604202536.503165465@linux-foundation.org> <20070604202712.223155106@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44622
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758473AbXFFTCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 15:02:11 -0400
In-Reply-To: <20070604202712.223155106@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 04 June 2007 22:25:37 Stephen Hemminger wrote:
> Make the PHY and statistic timer run on one second boundary
> for powersaving.
> 
> On resume, the driver should check for link up immediately, to
> get online faster (rather than waiting for the next second).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> ---
>  drivers/net/b44.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> --- a/drivers/net/b44.c	2007-06-04 12:31:27.000000000 -0700
> +++ b/drivers/net/b44.c	2007-06-04 12:31:34.000000000 -0700
> @@ -599,8 +599,7 @@ static void b44_timer(unsigned long __op
>  
>  	spin_unlock_irq(&bp->lock);
>  
> -	bp->timer.expires = jiffies + HZ;
> -	add_timer(&bp->timer);
> +	mod_timer(&bp->timer, round_jiffies(jiffies + HZ));
>  }
>  
>  static void b44_tx(struct b44 *bp)
> @@ -2348,11 +2347,11 @@ static int b44_resume(struct pci_dev *pd
>  	netif_device_attach(bp->dev);
>  	spin_unlock_irq(&bp->lock);
>  
> -	bp->timer.expires = jiffies + HZ;
> -	add_timer(&bp->timer);
> -
>  	b44_enable_ints(bp);
>  	netif_wake_queue(dev);
> +
> +	mod_timer(&bp->timer, jiffies + 1);

I don't think we need +1, if you need to fire immediately
(on the next tick). The timer core will always fire
timers that are in the past immediately.

-- 
Greetings Michael.
