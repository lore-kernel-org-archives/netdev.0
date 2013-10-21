From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 3/5] net:stmmac: ensure we reclaim all dirty descriptors.
Date: Mon, 21 Oct 2013 11:07:53 +0200
Message-ID: <5264EEE9.8070607@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jimmy Perchet <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:45339 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754875Ab3JUJH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:07:57 -0400
In-Reply-To: <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jimmy

On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
> On low speed link (10MBit/s), some TX descriptors can remain dirty
> if the tx coalescence timer expires before they were treated. Re-arm timer
> in this case.
>
> Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 0015175..af04b5d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1284,8 +1284,12 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>   			p = priv->dma_tx + entry;
>
>   		/* Check if the descriptor is owned by the DMA. */
> -		if (priv->hw->desc->get_tx_owner(p))
> +		if (priv->hw->desc->get_tx_owner(p)) {
> +			/* Be sure to harvest remaining descriptor. */
> +			mod_timer(&priv->txtimer,
> +			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
>   			break;
> +		}


why should we reload the timer when clean the tx resource?
This is done in the xmit where as soon as a frame has to be
transmitted it makes sense to reload the timer.

Also I have not clear why the problem happens on 10MBit/s speed
  Maybe there is an hidden problem (lock protection)
that should be fixed.

How did you get this problem? Just on low speed and stress the net?
I have never seen it.

peppe

>
>   		/* Verify tx error by looking at the last segment. */
>   		last = priv->hw->desc->get_tx_ls(p);
>
