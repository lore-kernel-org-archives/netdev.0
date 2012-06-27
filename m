From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/18] netfilter: nfnetlink_log: Move away from
 NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:23:17 -0700
Message-ID: <1340774597.16533.35.camel@joe2Laptop>
References: <20120626.220223.1090653207727010874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41050 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750929Ab2F0FXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 01:23:18 -0400
In-Reply-To: <20120626.220223.1090653207727010874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 22:02 -0700, David Miller wrote:
> And use nlmsg_data() while we're here too.
[]
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
[]
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

Because nlh isn't used for anything other than a test,
perhaps this is more readable as:

	if (inst->qlen > 1 &&
	    !nlmsg_put(inst->skb, 0, 0, NLMSG_DONE,
		       sizeof(struct nfgenmsg), 0))
		goto out;
