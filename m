From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 6 Jun 2006 09:52:17 -0400
Message-ID: <20060606135217.GA21969@hmsreliant.homelinux.net>
References: <20060605230917.12584.55755.stgit@gitlost.site> <20060605231125.12584.17039.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, jmoyer@redhat.com,
	mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:16907 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932177AbWFFNxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 09:53:53 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <20060605231125.12584.17039.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 04:11:25PM -0700, Kok, Auke wrote:
> 
> Netpoll was broken due to the earlier addition of multiqueue.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index ed15fca..7103a0e 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -4629,10 +4629,17 @@ static void
>  e1000_netpoll(struct net_device *netdev)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
> +#ifdef CONFIG_E1000_NAPI
> +	int budget = 0;
> +
> +	disable_irq(adapter->pdev->irq);
> +	e1000_clean_tx_irq(adapter, adapter->tx_ring);
> +	adapter->clean_rx(adapter, adapter->rx_ring, &budget, netdev->weight);
> +#else
> +
I've been speaking about this fix with a Jeff Moyer, and we've come up with some
concerns regarding its implementation.  Specifically the call to
adapter->clean_rx in the case of the e1000 driver is rather a layering
violation in the netpoll code, in the sense that the function pointed to by clean_rx
is functionality that is nominally used by the dev->poll method.  In fact in
this case, it would appear possible since dev->poll is called under the
poll_lock, but dev->poll_controller is not, that is is possible to have cpus in
a system executing in e1000_clean_rx_irq_[ps] at the same time leading to data
corruption:

CPU0:
netpoll_poll_dev
 dev->poll_controller (e1000_netpoll)
  adapter->clean_rx (e1000_clean_rx_irq)

CPU1:
napi_poll
 dev->poll (e1000_clean)
  e1000_clean_rx_irq

I'm not sure what the right fix is here.  A spinlock in e1000_clean_rx_irq[_ps]
would seem to be an easy and direct fix, but I don't know that thats the best
solution.

Something I don't understand is why the call to adapter->clean_rx is
required in the first place when the napi_poll routine calls it itself directly.
All other drivers schedule a napi poll and receive frames via that path.  My
guess is that it has to do with the fact that we schedule polls on the device in
the polling_netdev array, rather than the actual registered netdev. Looking at
the driver code I note that while an entire array is allocated for polling
netdevs, we only ever use entry 0.  Would it make sense to just remove the the
polling_netdev array and use the registered device like all the other drivers.
I expect that would eliminate the need for this patch as well.

Regards
Neil

>  	disable_irq(adapter->pdev->irq);
>  	e1000_intr(adapter->pdev->irq, netdev, NULL);
>  	e1000_clean_tx_irq(adapter, adapter->tx_ring);
> -#ifndef CONFIG_E1000_NAPI
>  	adapter->clean_rx(adapter, adapter->rx_ring);
>  #endif
>  	enable_irq(adapter->pdev->irq);
> 
> 
> 
> --
> Auke Kok <auke-jan.h.kok@intel.com>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/
