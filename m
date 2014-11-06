From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Thu, 06 Nov 2014 14:11:20 -0800
Message-ID: <1415311880.13896.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141106.162516.1083429539800319166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:47010 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaKFWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 17:11:23 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn18so4301762igb.9
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 14:11:22 -0800 (PST)
In-Reply-To: <20141106.162516.1083429539800319166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-06 at 16:25 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 05 Nov 2014 16:55:20 -0800
> 
> > @@ -4430,8 +4432,19 @@ void napi_complete(struct napi_struct *n)
> >  	if (unlikely(test_bit(NAPI_STATE_NPSVC, &n->state)))
> >  		return;
> >  
> > -	napi_gro_flush(n, false);
> > +	if (n->gro_list) {
> > +		unsigned long timeout = 0;
> > +
> > +		if (n->napi_rx_count)
> > +			timeout = n->dev->gro_flush_timeout;
> 
> Under what circumstances would we see n->gro_list non-NULL yet
> n->napi_rx_count == 0?
> 
> I'm not so sure it can happen.
> 
> Said another way, it looks to me like you could implement this
> using less state.

My goal was to not change any driver, doing a generic change.

Drivers call napi_complete() in their rx napi handler without giving us
the 'work_done' value which tells us if a packet was processed.

So I added a counter that is increased for every packet given to GRO
engine (napi_rx_count), so that napi_complete() has a clue if a packet
was received in _this_ NAPI run.

If at least one packet was received (and we still have packets in
gro_list) -> We ream the 'timer'
If not, we flush packets in GRO engine.

In order to avoid this state, I would have to add a new method, like
napi_complete_done(napi, work_done), and change drivers. I am not sure
its worth the effort ?
