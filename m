From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net 2/2] net: cls_u32: be more strict about skip-sw flag
Date: Mon, 06 Jun 2016 10:25:57 -0700
Message-ID: <5755B225.7040600@intel.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com> <1465226208-32097-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34103 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbcFFR0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 13:26:24 -0400
In-Reply-To: <1465226208-32097-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/6/2016 8:16 AM, Jakub Kicinski wrote:
> Return an error if user requested skip-sw and the underlaying
> hardware cannot handle tc offloads (or offloads are disabled).
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

looks good. I think we need similar checks in u32_replace_hw_knode() too.


> ---
>   net/sched/cls_u32.c | 21 +++++++++++----------
>   1 file changed, 11 insertions(+), 10 deletions(-)
>
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index b17e090f2fe1..fe05449537a3 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -457,20 +457,21 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp,
>   	struct tc_to_netdev offload;
>   	int err;
>   
> +	if (!tc_should_offload(dev, flags))
> +		return tc_skip_sw(flags) ? -EINVAL : 0;
> +
>   	offload.type = TC_SETUP_CLSU32;
>   	offload.cls_u32 = &u32_offload;
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
>   	return 0;
>   }
