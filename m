From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Tue, 11 Dec 2007 02:32:18 -0800 (PST)
Message-ID: <20071211.023218.31965443.davem@davemloft.net>
References: <001801c83bd6$2001d410$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751925AbXLKKcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:32:19 -0500
In-Reply-To: <001801c83bd6$2001d410$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Joonwoo Park" <joonwpark81@gmail.com>
Date: Tue, 11 Dec 2007 18:13:34 +0900

Joonwoo-ssi annyoung haseyo,

> [NET]: Fix Ooops of napi net_rx_action.
> Before doing list_move_tail napi poll_list, it should be ensured
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 86d6261..74bd5ab 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2207,7 +2207,8 @@ static void net_rx_action(struct softirq_action *h)
>  		 * still "owns" the NAPI instance and therefore can
>  		 * move the instance around on the list at-will.
>  		 */
> -		if (unlikely(work == weight))
> +		if (unlikely((test_bit(NAPI_STATE_SCHED, &n->state))
> +				&& (work == weight)))
>  			list_move_tail(&n->poll_list, list);
>  
>  		netpoll_poll_unlock(have);

How can the NAPI_STATE_SCHED bit be cleared externally yet we take
this list_move_tail() code path?

If NAPI_STATE_SCHED is cleared, work will be zero which will never be
equal to 'weight', and this we'll never attempt the list_move_tail().

If something clears NAPI_STATE_SCHED meanwhile, we have a serious race
and your patch is an incomplete bandaid.  For example, if it can
happen, then a case like:

		if (test_bit(NAPI_STATE_SCHED, &n->state))
	... something clears NAPI_STATE_SCHED right now ...
			work = n->poll(n, weight);

can crash too.
