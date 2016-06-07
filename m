From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCHv2 net 2/2] net: cls_u32: be more strict about skip-sw flag
Date: Tue, 7 Jun 2016 08:53:35 -0700
Message-ID: <5756EDFF.2000301@gmail.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com>
 <1465296416-21449-1-git-send-email-jakub.kicinski@netronome.com>
 <1465296416-21449-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, sridhar.samudrala@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33740 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcFGPxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 11:53:54 -0400
Received: by mail-pa0-f68.google.com with SMTP id di3so14484693pab.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 08:53:53 -0700 (PDT)
In-Reply-To: <1465296416-21449-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-07 03:46 AM, Jakub Kicinski wrote:
> Return an error if user requested skip-sw and the underlaying
> hardware cannot handle tc offloads (or offloads are disabled).
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
> v2:
>   - handle both knode and hnodes
> ---
>  net/sched/cls_u32.c | 58 +++++++++++++++++++++++++++--------------------------
>  1 file changed, 30 insertions(+), 28 deletions(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index b17e090f2fe1..0fc1d47885f8 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -457,20 +457,21 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp,
>  	struct tc_to_netdev offload;
>  	int err;
>  
> +	if (!tc_should_offload(dev, flags))
> +		return tc_skip_sw(flags) ? -EINVAL : 0;
> +
>  	offload.type = TC_SETUP_CLSU32;
>  	offload.cls_u32 = &u32_offload;
>  
> -	if (tc_should_offload(dev, flags)) {
> -		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
> -		offload.cls_u32->hnode.divisor = h->divisor;
> -		offload.cls_u32->hnode.handle = h->handle;
> -		offload.cls_u32->hnode.prio = h->prio;
> +	offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
> +	offload.cls_u32->hnode.divisor = h->divisor;
> +	offload.cls_u32->hnode.handle = h->handle;
> +	offload.cls_u32->hnode.prio = h->prio;
>  
> -		err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
> -						    tp->protocol, &offload);
> -		if (tc_skip_sw(flags))
> -			return err;
> -	}
> +	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
> +					    tp->protocol, &offload);
> +	if (tc_skip_sw(flags))
> +		return err;
>  
>  	return 0;
>  }

Looks like we also need to catch the error at u32_replace_hw_hnode call
sites?


                u32_replace_hw_hnode(tp, ht, flags);
                return 0;
        }

should be

		return replace_hw_hnode(tp, ht,flags)


Thanks,
John
