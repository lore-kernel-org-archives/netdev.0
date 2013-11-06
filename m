From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Wed, 06 Nov 2013 08:39:49 -0800
Message-ID: <1383755989.4291.178.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>
	 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
	 <20131106093028.GA18435@gondor.apana.org.au> <527A109E.5040000@secunet.com>
	 <20131106095217.GA18851@gondor.apana.org.au> <527A391B.4050907@secunet.com>
	 <20131106124811.GA20404@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mathias Krause <mathias.krause@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43092 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab3KFQjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 11:39:55 -0500
Received: by mail-pd0-f173.google.com with SMTP id r10so10367090pdi.18
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 08:39:54 -0800 (PST)
In-Reply-To: <20131106124811.GA20404@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 20:48 +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 01:42:03PM +0100, Mathias Krause wrote:
> >
> > Well, skb_cow_data() will only copy, i.e. call __pskb_pull_tail(), in
> > case the skb is either cloned or fragmented. As you already said it
> > won't be cloned in your case. Does it contain fragments, i.e. is
> > skb_shinfo(skb)->nr_frags != 0? If not, we won't copy with the current
> > code either.
> 
> Whenever we say page it means nr_frags != 0.  So currently as
> long as we have pages in our skb we will copy.  With your patch
> we will no longer copy in the case where we have pages but the
> skb isn't cloned.  In fact that is the whole point of your patch.
> 
> > Can you please explain why this would be needed? I still don't get the
> > reasoning behind "pages are considered not writable at the moment even
> > if they are anonymous".
> 
> As I said you don't know where the page in the skb came from.  It
> may point to read-only memory or memory that's shared with another
> task that isn't expecting things to change underneath it.

Note that we might have now a per skb flag telling is all page frags are
owned.

This is SKBTX_SHARED_FRAG

If SKBTX_SHARED_FRAG is set on shared_info->tx_flags, then at least
one frag is not safe and we must copy all frags.


For example, this flag is set in TCP sendfile() path (vmsplice()...),
and zero copy paths in general (macvtap, tun)

I am not 100% sure, but this could be a hint.
