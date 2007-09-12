From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [-MM, FIX] ixgbe: incorporate napi_struct changes from
 net-2.6.24.git
Date: Wed, 12 Sep 2007 15:16:43 -0700
Message-ID: <20070912151643.cb0e070b.akpm@linux-foundation.org>
References: <20070912181307.13189.33476.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60398 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755385AbXILWQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 18:16:52 -0400
In-Reply-To: <20070912181307.13189.33476.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 11:13:07 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> This incorporates the new napi_struct changes into ixgbe.

I get a reject storm.

> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -557,14 +557,15 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
>  	struct ixgbe_adapter *adapter = rxr->adapter;
>  
>  	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->eims_value);
> -	netif_rx_schedule(adapter->netdev);
> +	netif_rx_schedule(adapter->netdev, &adapter->napi);
>  	return IRQ_HANDLED;
>  }
>  

For example, my copy of ixgbe_msix_clean_rx(), from
git://lost.foo-projects.org/~aveerani/git/linux-2.6#ixgbe is:

static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
{
	struct ixgbe_ring *rxr = data;
	struct ixgbe_adapter *adapter = rxr->adapter;

#ifndef CONFIG_IXGBE_NAPI
	int i;

	for (i = 0; i < IXGBE_MAX_INTR; i++)
		if (unlikely(!ixgbe_clean_rx_irq(adapter, rxr)))
			break;
#else
	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->eims_value);
	netif_rx_schedule(adapter->netdev);
#endif
	return IRQ_HANDLED;
}


which is quite different from the function whcih you're altering here?
