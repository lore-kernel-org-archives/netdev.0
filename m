From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net] net: ipv6: tcp: fix potential use after free in
 tcp_v6_do_rcv
Date: Tue, 3 Sep 2013 13:46:20 -0600
Message-ID: <20130903194620.GE8262@mail.gmail.com>
References: <1378229352-9779-1-git-send-email-dborkman@redhat.com>
 <1378230513.7360.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:64246 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265Ab3ICTsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 15:48:46 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so6439094pdj.4
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 12:48:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1378230513.7360.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Sep 2013 10:48:33 -0700
>
> On Tue, 2013-09-03 at 19:29 +0200, Daniel Borkmann wrote:
> > In tcp_v6_do_rcv() code, when processing pkt options, we soley work
> > on our skb clone opt_skb that we've created earlier before entering
> > tcp_rcv_established() on our way. However, only in condition ...
> > 
> >   if (np->rxopt.bits.rxtclass)
> >     np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
> > 
> > ... we work on skb itself. As we extract every other information out
> > of opt_skb in ipv6_pktoptions path, this seems wrong, since skb can
> > already be released by tcp_rcv_established() earlier on. When we try
> > to access it in ipv6_hdr(), we will dereference freed skb.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/ipv6/tcp_ipv6.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> > index 6e1649d..eeb4cb0 100644
> > --- a/net/ipv6/tcp_ipv6.c
> > +++ b/net/ipv6/tcp_ipv6.c
> > @@ -1427,7 +1427,7 @@ ipv6_pktoptions:
> >  		if (np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim)
> >  			np->mcast_hops = ipv6_hdr(opt_skb)->hop_limit;
> >  		if (np->rxopt.bits.rxtclass)
> > -			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(skb));
> > +			np->rcv_tclass = ipv6_get_dsfield(ipv6_hdr(opt_skb));
> >  		if (ipv6_opt_accepted(sk, opt_skb)) {
> >  			skb_set_owner_r(opt_skb, sk);
> >  			opt_skb = xchg(&np->pktoptions, opt_skb);
> 
> Bug added in commit 4c507d2897bd9b
> ("net: implement IP_RECVTOS for IP_PKTOPTIONS")
> 
> CC Jiri
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

You made a mistake.

It was introduced in commit e7219858a ("ipv6: Use ipv6_get_dsfield()
instead of ipv6_tclass()").

Cc the right party.

-- 
Jean Sacren
