From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: Don't collapse if resulting skb could overflow
 skb->csum_start
Date: Thu, 28 Feb 2013 09:35:52 -0800
Message-ID: <1362072952.15793.41.camel@edumazet-glaptop>
References: <20130228102603.GA7558@casper.infradead.org>
	 <1362068326.15793.33.camel@edumazet-glaptop>
	 <20130228164502.GD7558@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, foraker1@llnl.gov
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:50836 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab3B1Rfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 12:35:55 -0500
Received: by mail-pb0-f49.google.com with SMTP id xa12so1193101pbc.22
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 09:35:54 -0800 (PST)
In-Reply-To: <20130228164502.GD7558@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 16:45 +0000, Thomas Graf wrote:
> On 02/28/13 at 08:18am, Eric Dumazet wrote:
> > but.... what is the value of skb_availroom(to) ?
> > 
> > The earlier test at line 2302 should already guard this case ?
> > 
> >                /* Punt if not enough space exists in the first SKB for
> >                  * the data in the second
> >                  */
> >                 if (skb->len > skb_availroom(to))
> >                         break;
> 
> Only if it is guaranteed that we never see an MSS > 64K.
> 
> Assuming that is true forever, then a21d45726 (tcp: avoid order-1
> allocations on wifi and tx path) does in fact resolve this
> issue at the cost of not being able to use the extra room
> kmalloc() might have given us in __alloc_skb() for collapsing.
> 
> Was that an intentional side effect of a21d45726?

This had a followup with 22b4a4f22da4
(tcp: fix retransmit of partially acked frames)

I also wonder if there is not another similar potential problem in
__tcp_retransmit_skb) after call to 

tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq)

csum_start can overflow again because of MAX_TCP_HEADER headroom
reserve.

So maybe we should limit TCP MTU to (64K - MAX_TCP_HEADER)
