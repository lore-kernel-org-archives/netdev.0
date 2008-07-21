From: "Carlos R. Mafra" <crmafra2@gmail.com>
Subject: Re: Suspend to RAM regression (bisected)
Date: Mon, 21 Jul 2008 13:54:44 -0500
Message-ID: <20080721185443.GA3883@localhost>
References: <20080721020349.GA4328@localhost> <alpine.LFD.1.10.0807202119240.31863@woody.linux-foundation.org> <20080721150415.GA3804@localhost> <alpine.LFD.1.10.0807210951570.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:31376 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbYGUSxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 14:53:22 -0400
Received: by nf-out-0910.google.com with SMTP id d3so527212nfc.21
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 11:53:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0807210951570.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 21.Jul'08 at 10:12:30 -0700, Linus Torvalds wrote:
> 
> 
> On Mon, 21 Jul 2008, Carlos R. Mafra wrote:
> > 
> > Ok, I tried your new v2.6.26-5253-g14b395e and unfortunately suspend to
> > RAM fails completely now. The backlight doesn't turn off and the keyboard
> > leds keep blinking.
> > 
> > After several boots I bisected this new regression down to 
> > 37437bb2e1ae8af470dfcd5b4ff454110894ccaf ("pkt_sched: Schedule qdiscs 
> > instead of netdev_queue.") by David Miller. 
> 
> Ok, I think this is an oops, and since it's bisected down to the same 
> commit that some other oopses were bisected down to at boot-time, it's 
> probably the same thing: something is calling "netif_wake_queue()" without 
> having called "netif_start_queue()".
> 
> Or, to be more precise, in the case of suspending, something has probably 
> called "dev_deactivate()" because of a link event or something like that, 
> which seems to be a total piece-of-sh*t code that sets the qdisc back to 
> the "illegal" noop_qdisc (thus causing oopses if some qdisc event 
> happens), but does so *before* al the qdisc's have been quiesced (which it 
> must do - because otherwise they may keep coming), so the same problem 
> that plagued netif_wake_queue() will happen.
> 
> I don't really know the code very well (I'm waiting for David to fix up 
> the mess), but I can imagine that the appended patch may at least turn the 
> dead machine into a single warning and hopefully a working setup. Can you 
> please try?

I tested your patch below and now suspend to RAM is working again, it 
resumed just fine into X. So both regressions are gone now.

Thanks a lot,
Carlos


> 			Linus
> 
> ---
>  net/core/dev.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2eed17b..43ab4f5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1325,7 +1325,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  
>  void __netif_schedule(struct Qdisc *q)
>  {
> -	BUG_ON(q == &noop_qdisc);
> +	if (WARN_ON_ONCE(q == &noop_qdisc))
> +		return;
>  
>  	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
>  		struct softnet_data *sd;
