From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Check num sacks in SACK fast path
Date: Thu, 01 Feb 2007 14:38:00 -0800 (PST)
Message-ID: <20070201.143800.78710936.davem@davemloft.net>
References: <20070129071349.24050.56022.sendpatchset@galon.ev-en.org>
	<20070131.125246.85686582.davem@davemloft.net>
	<20070201072252.GX22455@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932857AbXBAWiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 17:38:02 -0500
In-Reply-To: <20070201072252.GX22455@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Thu, 1 Feb 2007 09:22:52 +0200

> * David Miller <davem@davemloft.net> [070131 22:52]:
> > We should never see a SACK block from sequence zero to zero,
> > which would be an empty SACK block.
> 
> That would work as well at the cost of extra writing to memory for each
> ack packet. Though I won't guess what is worse, the extra memory used or
> the extra writing.

Good point.  The recv_sack_cache is 32-bytes, so sits in at most
2 cache lines.  The writes are consequetive and in order so would
compress into cpu store buffers.

But it's definitely not free. :-)

> > Something like the following?
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index c26076f..84cd722 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -999,6 +1001,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
> >  				return 0;
> >  		}
> >  	}
> > +	for (; i <= 4; i++) {
> 
> That won't work though, the <= should be <, I've actually used
> ARRAY_SIZE just to be on the safe side.

Thanks for catching that.
