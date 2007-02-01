From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 3/3] Check num sacks in SACK fast path
Date: Thu, 1 Feb 2007 09:22:52 +0200
Message-ID: <20070201072252.GX22455@galon.ev-en.org>
References: <20070129071339.24050.21052.sendpatchset@galon.ev-en.org> <20070129071349.24050.56022.sendpatchset@galon.ev-en.org> <20070131.125246.85686582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:33297
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161244AbXBAHWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 02:22:53 -0500
Content-Disposition: inline
In-Reply-To: <20070131.125246.85686582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070131 22:52]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Mon, 29 Jan 2007 09:13:49 +0200
> 
> > When we check for SACK fast path make sure that we also have the same number of
> > SACK blocks in the cache and in the new SACK data. This prevents us from
> > mistakenly taking the cache data if the old data in the SACK cache is the same
> > as the data in the SACK block.
> > 
> > Signed-Off-By: Baruch Even <baruch@ev-en.org>
> 
> We could implement this without extra state, for example by
> clearing out the rest of the recv_sack_cache entries.
> 
> We should never see a SACK block from sequence zero to zero,
> which would be an empty SACK block.

That would work as well at the cost of extra writing to memory for each
ack packet. Though I won't guess what is worse, the extra memory used or
the extra writing.

> Something like the following?
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index c26076f..84cd722 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -999,6 +1001,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
>  				return 0;
>  		}
>  	}
> +	for (; i <= 4; i++) {

That won't work though, the <= should be <, I've actually used
ARRAY_SIZE just to be on the safe side.

> +		tp->recv_sack_cache[i].start_seq = 0;
> +		tp->recv_sack_cache[i].end_seq = 0;
> +	}
>  
>  	if (flag)
>  		num_sacks = 1;

Baruch
