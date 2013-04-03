From: Shiraz Hashim <shiraz.hashim@st.com>
Subject: Re: [net-next.git 2/7] stmmac: review barriers
Date: Wed, 3 Apr 2013 14:21:06 +0530
Message-ID: <20130403085106.GA2039@localhost.localdomain>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
 <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:42644 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762714Ab3DCIvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 04:51:14 -0400
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 7AF7CD9
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 08:43:00 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas4.st.com [10.80.176.69])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id CC24749E
	for <netdev@vger.kernel.org>; Wed,  3 Apr 2013 08:51:07 +0000 (GMT)
Content-Disposition: inline
In-Reply-To: <1364967689-11155-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Giuseppe,

On Wed, Apr 03, 2013 at 01:41:24PM +0800, Giuseppe CAVALLARO wrote:
> In all my tests performed on SH4 and ARM A9 platforms, I've never met problems
> that can be fixed by using memory barriers. In the past there was some issues
> on SMP ARM but fixed by reviewing xmit spinlock.

The problem which was addressed was not because of SMP IMO. It was
rather due to the fact that the write to the GMAC descriptor (which
happens to be in normal memory) has to be ordered with respect to GMAC
DMA as observer. Isn't it ?

> Further barriers have been added in the commits too: 8e83989106562326bf
> 
> This patch is to use the smp_wbm instead of wbm because the driver
                           ^^^^^^^^^^^^^^^^^^^^^^
Perhaps you meant smp_wmb and wmb

> runs on UP systems. Then, IMO it could make sense to only maintain the barriers
> just in places where we touch the dma owner bits (that is the
> only real critical path as we had seen and fixed in the commit:
> eb0dc4bb2e22c04964d).

Replacing wmb by smp_wmb may not be a good idea as we need to order
the store transaction to the descriptor with respect to GMAC DMA and
using smp_* version would just be compiler barrier in uniprocessor
systems.

> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Deepak Sikri <deepak.sikri@st.com>
> Cc: Shiraz Hashim <shiraz.hashim@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++------
>  1 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8b69e3b..c92dcbc 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1797,15 +1797,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  		priv->tx_skbuff[entry] = NULL;
>  		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
>  						priv->mode);
> -		wmb();
> +		smp_wmb();
>  		priv->hw->desc->set_tx_owner(desc);
> -		wmb();

Since it is a loop, shouldn't we ensure that the ownership of a tx
descriptor is set before next descriptor in chain is programmed ?

>  	}
>  
>  	/* Finalize the latest segment. */
>  	priv->hw->desc->close_tx_desc(desc);
>  
> -	wmb();
>  	/* According to the coalesce parameter the IC bit for the latest
>  	 * segment could be reset and the timer re-started to invoke the
>  	 * stmmac_tx function. This approach takes care about the fragments.
> @@ -1821,9 +1819,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	} else
>  		priv->tx_count_frames = 0;
>  
> +	smp_wmb();

Please reconsider, may be keeping wmb is better.

>  	/* To avoid raise condition */
>  	priv->hw->desc->set_tx_owner(first);
> -	wmb();

Not sure about this, perhaps can be removed.

>  
>  	priv->cur_tx++;
>  
> @@ -1899,9 +1897,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
>  
>  			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
>  		}
> -		wmb();
> +		smp_wmb();
>  		priv->hw->desc->set_rx_owner(p);
> -		wmb();

Similarly this is a part of a loop, we need to see if set rx owner
should be reflected before next descriptor program.

--
regards
Shiraz
