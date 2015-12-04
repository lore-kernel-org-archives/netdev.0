From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git)] stmmac: fix resource management when resume
Date: Fri, 4 Dec 2015 08:28:42 +0100
Message-ID: <566140AA.1030005@st.com>
References: <1449210066-30336-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:53106 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750879AbbLDH3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 02:29:21 -0500
In-Reply-To: <1449210066-30336-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

This is the v2, sorry I missed it in the subject.

Re-based on top of net.git.

peppe

On 12/4/2015 7:21 AM, Giuseppe Cavallaro wrote:
> There is a memleak when suspend/resume this driver version.
> Currently the stmmac, during resume step, reallocates all the resources
> but they are not released when suspend.
> The patch is not to release these resources but the logic has been changed.
> In fact, it is not necessary to free and reallocate all from scratch
> because the memory data will be always preserved.
> As final solution, the patch just reinit the descriptors and the rx/tx
> pointers only when resume. Tested done on STi boxes.
>
> Reported-by: ZhengShunQian <zhengsq@rock-chips.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 ++++++---
>   1 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3c6549a..a5b869e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3046,8 +3046,6 @@ int stmmac_suspend(struct net_device *ndev)
>   	priv->hw->dma->stop_tx(priv->ioaddr);
>   	priv->hw->dma->stop_rx(priv->ioaddr);
>
> -	stmmac_clear_descriptors(priv);
> -
>   	/* Enable Power down mode by programming the PMT regs */
>   	if (device_may_wakeup(priv->device)) {
>   		priv->hw->mac->pmt(priv->hw, priv->wolopts);
> @@ -3105,7 +3103,12 @@ int stmmac_resume(struct net_device *ndev)
>
>   	netif_device_attach(ndev);
>
> -	init_dma_desc_rings(ndev, GFP_ATOMIC);
> +	priv->cur_rx = 0;
> +	priv->dirty_rx = 0;
> +	priv->dirty_tx = 0;
> +	priv->cur_tx = 0;
> +	stmmac_clear_descriptors(priv);
> +
>   	stmmac_hw_setup(ndev, false);
>   	stmmac_init_tx_coalesce(priv);
>   	stmmac_set_rx_mode(ndev);
>
