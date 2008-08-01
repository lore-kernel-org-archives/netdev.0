From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Fri, 1 Aug 2008 19:50:41 +0800
Message-ID: <20080801115041.GA19124@gondor.apana.org.au>
References: <48929C5B.5030108@cn.fujitsu.com> <E1KOqf7-0004lB-00@gondolin.me.apana.org.au> <20080801.021825.51896743.davem@davemloft.net> <20080801092548.GA18424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752594AbYHALu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 07:50:56 -0400
Content-Disposition: inline
In-Reply-To: <20080801092548.GA18424@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2008 at 05:25:48PM +0800, Herbert Xu wrote:
>
> Hmm, so SCTP is the only reason why ipfragok exists and yet it
> doesn't even use icsk_af_ops->queue_xmit.  So unless SCTP has
> plans to use icsk_af_ops, perhaps we could provide it a copy of
> ip_queue_xmit/ip6_xmit that has the ipfragok argument and then
> put a wrapper around them without the argument for icsk_af_ops
> and everybody else.

I dug up this thread from the archives:

http://osdir.com/ml/network/2003-01/msg00065.html

SCTP is just a POS.

However, I think we can improve on what we have at the moment.
Really we only need to clear the DF bit on packets which are
above the PMTU on output.  There is no need to clear the DF for
packets which we don't need to fragment ourselves.

Yes, the RFC says we SHOULD do that, but it's braindead.  In any
case, this isn't allowed by IPv6 and it makes little sense for IPv4.
If we are doing PMTU then we want to get that error back in all
cases.

So we should be able to simply replace ipfragok with skb->local_df.
The only trouble is that SCTP doesn't seem to keep its PMTU setting
in the usual spot so we'll need to fix that before this can be done.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
