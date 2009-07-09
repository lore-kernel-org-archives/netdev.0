From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH for 2.6.31] cxgb3: Fix crash caused by stashing wrong
 netdev_queue
Date: Thu, 09 Jul 2009 14:15:21 -0700
Message-ID: <4A565DE9.3040504@chelsio.com>
References: <adaeisq23rq.fsf@cisco.com> <adaljmyzof4.fsf@cisco.com>	<4A554A1D.3070703@chelsio.com> <adabpnty7qm.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3201 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbZGIVPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 17:15:23 -0400
In-Reply-To: <adabpnty7qm.fsf_-_@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> Commit c3a8c5b6 ("cxgb3: move away from LLTX") exposed a bug in how
> cxgb3 looks up the netdev_queue it stashes away in a qset during
> initialization.  For multiport devices, the TX queue index it uses is
> offset by the first_qset index of each port.  This leads to a crash
> once LLTX is removed, since hard_start_xmit is called with one TX
> queue lock held, while the TX reclaim timer task grabs a different
> (wrong) TX queue lock when it frees skbs.
>
> Fix this by removing the first_qset offset used to look up the TX
> queue passed into t3_sge_alloc_qset() from setup_sge_qsets().
>   

Thanks Roland!
You were very fast to fix it, you beat us.

Acked-by: Divy Le Ray <divy@chelsio.com>

> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
> OK, found the bug that was causing the crash I saw.  With this patch
> everything looks solid again.  Please apply.
>
>  drivers/net/cxgb3/cxgb3_main.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index 538dda4..fb5df5c 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -642,8 +642,7 @@ static int setup_sge_qsets(struct adapter *adap)
>  		struct port_info *pi = netdev_priv(dev);
>  
>  		pi->qs = &adap->sge.qs[pi->first_qset];
> -		for (j = pi->first_qset; j < pi->first_qset + pi->nqsets;
> -		     ++j, ++qset_idx) {
> +		for (j = 0; j < pi->nqsets; ++j, ++qset_idx) {
>  			set_qset_lro(dev, qset_idx, pi->rx_offload & T3_LRO);
>  			err = t3_sge_alloc_qset(adap, qset_idx, 1,
>  				(adap->flags & USING_MSIX) ? qset_idx + 1 :
>   

