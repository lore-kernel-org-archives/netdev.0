From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of
 kfree_skb.
Date: Mon, 10 Mar 2014 21:56:35 -0700
Message-ID: <1394513795.21721.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <874n3fow2i.fsf@xmission.com>
	 <20140304.160825.893718566461536483.davem@davemloft.net>
	 <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	 <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <878usho04m.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33848 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaCKE4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 00:56:37 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so8222624pab.19
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 21:56:36 -0700 (PDT)
In-Reply-To: <878usho04m.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 21:00 -0700, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > On Mon, 2014-03-10 at 20:18 -0700, Eric W. Biederman wrote:
> >> Replace kfree_skb with dev_kfree_skb_any in functions that can
> >> be called in hard irq and other contexts.
> >> 
> >> Replace consume_skb with dev_consume_skb_any in functions that can
> >> be called in hard irq and other contexts.
> >> 
> >> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> >> ---
> >>  drivers/net/bonding/bond_3ad.c  |    2 +-
> >>  drivers/net/bonding/bond_alb.c  |    2 +-
> >>  drivers/net/bonding/bond_main.c |   14 +++++++-------
> >>  3 files changed, 9 insertions(+), 9 deletions(-)
> >> 
> >> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> >> index a2ef3f72de88..dee2a84a2929 100644
> >> --- a/drivers/net/bonding/bond_3ad.c
> >> +++ b/drivers/net/bonding/bond_3ad.c
> >> @@ -2479,7 +2479,7 @@ out:
> >>  	return NETDEV_TX_OK;
> >>  err_free:
> >>  	/* no suitable interface, frame not sent */
> >> -	kfree_skb(skb);
> >> +	dev_kfree_skb_any(skb);
> >>  	goto out;
> >>  }
> >>  
> >> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> >> index aaeeacf767f2..9cf836b67b15 100644
> >> --- a/drivers/net/bonding/bond_alb.c
> >> +++ b/drivers/net/bonding/bond_alb.c
> >> @@ -1464,7 +1464,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
> >>  	}
> >>  
> >>  	/* no suitable interface, frame not sent */
> >> -	kfree_skb(skb);
> >> +	dev_kfree_skb_any(skb);
> >>  out:
> >>  	return NETDEV_TX_OK;
> >>  }
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >> index 730d72c706c9..63f8df8af4d4 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -1115,7 +1115,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> >>  	if (recv_probe) {
> >>  		ret = recv_probe(skb, bond, slave);
> >>  		if (ret == RX_HANDLER_CONSUMED) {
> >> -			consume_skb(skb);
> >> +			dev_consume_skb_any(skb);
> >
> > Why is this needed ? AFAIK we run in softirq here.
> 
> Except when we call printk in hard irq context.  Then we can easily have
> a call trace like:
> 
> drivers/net/netconsole.c:write_msg
>   netpoll_send_udp
>     netpoll_send_skb_on_dev
>       netpoll_poll_dev
>         poll_napi
>            poll_one_napi
>          -------------------------
>              tg3_poll
>                 tg3_poll_work   -- Or any other driver supporting netpoll
>                    tg3_rx
>          -------------------------
>                      napi_gro_receive
>                        napi_skb_finish
>                          netif_receive_skb_internal
>                            __netif_receive_skb
>                              __netif_receive_skb_core
>                                 bond_handle_frame

But RX path (napi_gro_receive) is not supposed to be called from hard
irq.

Many things will horribly break.

Sorry, I must be very tired.
