From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] bnx2x: fix napi poll return value for repoll
Date: Tue, 20 Jan 2015 06:51:20 -0800
Message-ID: <1421765480.4832.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>
	 <1421759776-376-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ariel.elior@qlogic.com, ssujith@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>,
	Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:42131 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbbATOvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:51:22 -0500
Received: by mail-pd0-f172.google.com with SMTP id v10so22018054pde.3
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 06:51:22 -0800 (PST)
In-Reply-To: <1421759776-376-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-20 at 18:46 +0530, Govindarajulu Varadarajan wrote:
> With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi repoll
> is done only when work_done == budget. When in busy_poll is we return 0 in
> napi_poll. We should return budget. Also do not return workdone > budget.
> 

I am not sure.

> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 1d1147c..ebcbe92 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -3175,7 +3175,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
>  		}
>  #endif
>  		if (!bnx2x_fp_lock_napi(fp))
> -			return work_done;
> +			return budget;

For this one I am not sure.

Busy poll is not supposed to drain the whole queue.

>  
>  		for_each_cos_in_tx_queue(fp, cos)
>  			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
> @@ -3187,7 +3187,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
>  			/* must not complete if we consumed full budget */
>  			if (work_done >= budget) {
>  				bnx2x_fp_unlock_napi(fp);
> -				break;
> +				return budget;

This one looks fine.

>  			}
>  		}
>  
