From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Tue, 11 Dec 2007 21:57:02 +0900
Message-ID: <b25c3fa70712110457g2bf04c6flc387f2b9cb51cf3b@mail.gmail.com>
References: <001801c83bd6$2001d410$9c94fea9@jason>
	 <20071211.023218.31965443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:1327 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbXLKM5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 07:57:04 -0500
Received: by rv-out-0910.google.com with SMTP id k20so2027975rvb
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 04:57:02 -0800 (PST)
In-Reply-To: <20071211.023218.31965443.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/11, David Miller <davem@davemloft.net>:
> From: "Joonwoo Park" <joonwpark81@gmail.com>
> Date: Tue, 11 Dec 2007 18:13:34 +0900
>
> Joonwoo-ssi annyoung haseyo,

Wow Great! :-)

> How can the NAPI_STATE_SCHED bit be cleared externally yet we take
> this list_move_tail() code path?
>
> If NAPI_STATE_SCHED is cleared, work will be zero which will never be
> equal to 'weight', and this we'll never attempt the list_move_tail().
>
> If something clears NAPI_STATE_SCHED meanwhile, we have a serious race
> and your patch is an incomplete bandaid.  For example, if it can
> happen, then a case like:
>
>                if (test_bit(NAPI_STATE_SCHED, &n->state))
>        ... something clears NAPI_STATE_SCHED right now ...
>                        work = n->poll(n, weight);
>
> can crash too.
>

David,
With your suggestions, I'm feeling a doubt at e1000.
It's seems to me e1000_clean does call netif_rx_complete and returns
non-zero work_done when !netif_running()
So net_rx_action has (work == weight) as true with NAPI_STATE_SCHED cleared.

Here is the e1000_clean.

static int
e1000_clean(struct napi_struct *napi, int budget)
{
    /* Keep link state information with original netdev */
    if (!netif_carrier_ok(poll_dev))
        goto quit_polling;

...

    adapter->clean_rx(adapter, &adapter->rx_ring[0],
                      &work_done, budget);

    /* If no Tx and not enough Rx work done, exit the polling mode */
    if ((!tx_cleaned && (work_done == 0)) ||
       !netif_running(poll_dev)) {
quit_polling:
        if (likely(adapter->itr_setting & 3))
            e1000_set_itr(adapter);
        netif_rx_complete(poll_dev, napi);
        e1000_irq_enable(adapter);
    }

    return work_done;
}

Thanks.
Joonwoo
