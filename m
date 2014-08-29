From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] lib/rhashtable: allow users to set the
 minimum shifts of shrinking
Date: Fri, 29 Aug 2014 10:31:07 +0100
Message-ID: <20140829093107.GA3563@casper.infradead.org>
References: <1409190324-27828-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40315 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaH2JbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 05:31:10 -0400
Content-Disposition: inline
In-Reply-To: <1409190324-27828-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/14 at 09:45am, Ying Xue wrote:
> Now the resizeable hash table size is allowed to shrink a too smaller
> size - HASH_MIN_SIZE(4) although users initially specify a rather big
> size when table is created. Especially when the number of objects
> saved in the table keeps a small value in comparison with the initial
> setting of table size during a quite long time, lots of actions of
> expanding and shrinking are involved with objects being inserted or

Can you work on this part of the commit message a bit? I know what
you want to say but it's not very clear from the text.

> removed from table. However, as synchronize_rcu() has to be called
> during expanding and shrinking, these unnecessary actions would
> seriously hit users' performance.
> 
> Therefore, we should permit users to set the minimum table size
> through configuring the minimum of number of shifts when table is
> created according to users specific requirement.
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index a2c7881..85a4ac2 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -566,8 +568,13 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
>  	    (!params->key_len && !params->obj_hashfn))
>  		return -EINVAL;
>  
> +	if (params->min_shift)
> +		params->min_shift = max(params->min_shift, min_shift);
> +	else
> +		params->min_shift = min_shift;
> +

You can simplify all of the above to just:

  params->min_shift = max(params->min_shift, ilog2(HASH_MIN_SIZE));
