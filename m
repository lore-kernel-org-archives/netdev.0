From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] sky2: Hold RTNL while calling dev_close()
Date: Tue, 6 May 2008 16:17:20 -0700
Message-ID: <20080506161720.6475e5d4@extreme>
References: <20080506182654.GF2217@solarflare.com>
	<20080506183958.GI2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51020 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751371AbYEFXRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 19:17:31 -0400
In-Reply-To: <20080506183958.GI2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 19:39:58 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sky2.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index f226bca..9b046dd 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2952,7 +2952,9 @@ static void sky2_restart(struct work_struct *work)
>  			if (err) {
>  				printk(KERN_INFO PFX "%s: could not restart %d\n",
>  				       dev->name, err);
> +				rtnl_lock();
>  				dev_close(dev);
> +				rtnl_unlock();
>  			}
>  		}
>  	}
> 

No this is bogus.  The rtnl mutex is already held.
Look a little wider

static void sky2_restart(struct work_struct *work)
{
	struct sky2_hw *hw = container_of(work, struct sky2_hw, restart_work);
	struct net_device *dev;
	int i, err;

	rtnl_lock();
	for (i = 0; i < hw->ports; i++) {
		dev = hw->dev[i];
		if (netif_running(dev))
			sky2_down(dev);
	}

	napi_disable(&hw->napi);
	sky2_write32(hw, B0_IMSK, 0);
	sky2_reset(hw);
	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
	napi_enable(&hw->napi);

	for (i = 0; i < hw->ports; i++) {
		dev = hw->dev[i];
		if (netif_running(dev)) {
			err = sky2_up(dev);
			if (err) {
				printk(KERN_INFO PFX "%s: could not restart %d\n",
				       dev->name, err);
				dev_close(dev);
			}
		}
	}

	rtnl_unlock();
}
