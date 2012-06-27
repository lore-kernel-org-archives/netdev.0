From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 7/18] netfilter: nfnetlink_log: Move away from
 NLMSG_PUT().
Date: Wed, 27 Jun 2012 17:49:33 +0100
Message-ID: <1340815773.2591.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120626.220223.1090653207727010874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29823 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750811Ab2F0Qtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 12:49:36 -0400
In-Reply-To: <20120626.220223.1090653207727010874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 22:02 -0700, David Miller wrote:
> And use nlmsg_data() while we're here too.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/netfilter/nfnetlink_log.c |   29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
> index 3c3cfc0..169ab59 100644
> --- a/net/netfilter/nfnetlink_log.c
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -326,18 +326,20 @@ __nfulnl_send(struct nfulnl_instance *inst)
>  {
>  	int status = -1;
>  
> -	if (inst->qlen > 1)
> -		NLMSG_PUT(inst->skb, 0, 0,
> -			  NLMSG_DONE,
> -			  sizeof(struct nfgenmsg));
> -
> +	if (inst->qlen > 1) {
> +		struct nlmsghdr *nlh = nlmsg_put(inst->skb, 0, 0,
> +						 NLMSG_DONE,
> +						 sizeof(struct nfgenmsg),
> +						 0);
> +		if (!nlh)
> +			goto out;
> +	}
>  	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_pid,
>  				   MSG_DONTWAIT);
>  
>  	inst->qlen = 0;
>  	inst->skb = NULL;
> -
> -nlmsg_failure:
> +out:
>  	return status;
>  }
[...]

It looks like this also leaks the skb on failure.  At least,
__nfulnl_flush(inst) is expected to dipose of inst->skb.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
