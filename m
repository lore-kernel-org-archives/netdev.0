From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: gro: fix PV6_GRO_CB(skb)->proto problem
Date: Tue, 09 Oct 2012 15:06:25 +0200
Message-ID: <1349787985.21172.4305.camel@edumazet-glaptop>
References: <1349725130.21172.3663.camel@edumazet-glaptop>
	 <20121008.154148.2288526275691661749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41317 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab2JING2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 09:06:28 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2627096bkc.19
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 06:06:27 -0700 (PDT)
In-Reply-To: <20121008.154148.2288526275691661749.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 15:41 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 08 Oct 2012 21:38:50 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > It seems IPV6_GRO_CB(skb)->proto can be destroyed in skb_gro_receive()
> > if a new skb is allocated (to serve as an anchor for frag_list)
> > 
> > We copy NAPI_GRO_CB() only (not the IPV6 specific part) in :
> > 
> > *NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
> > 
> > So we leave IPV6_GRO_CB(nskb)->proto to 0 (fresh skb allocation) instead
> > of IPPROTO_TCP (6)
> > 
> > ipv6_gro_complete() isnt able to call ops->gro_complete()
> > [ tcp6_gro_complete() ]
> > 
> > Fix this by moving proto in NAPI_GRO_CB() and getting rid of
> > IPV6_GRO_CB
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied and queued up for -stable, thanks Eric.

Hmm, it appears its a false alarm, you can remove it from stable
candidates.

*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);

was in fact redundant with the 

memcpy(new->cb, old->cb, sizeof(old->cb)); 

done in __copy_skb_header()

I'll send a patch to remove this double copy in net-next

Thanks
