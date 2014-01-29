From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Wed, 29 Jan 2014 12:00:24 +0100
Message-ID: <20140129110024.GG30123@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128085706.GB30123@breakpoint.cc>
 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46360 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750925AbaA2LA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 06:00:26 -0500
Content-Disposition: inline
In-Reply-To: <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Its still unclear if this is the best strategy.
> > > 
> > > TCP stream not using DF flag are very unlikely to care if we adjust
> > > their MTU (lowering gso_size) at this point ?
> > 
> > Thanks for this suggestion.  It would indeed be nice to avoid sw
> > segmentation.  I tried:
> > 
> > static void ip_gso_adjust_seglen(struct sk_buff *skb)
> > {
> >         unsigned int mtu;
> > 
> >         if (!skb_is_gso(skb))
> >                 return;
> > 
> >         mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
> >         skb_shinfo(skb)->gso_size = mtu - sizeof(struct iphdr);

FWIW Erics idea works fine with:

        headerlen = skb_transport_header(skb) - skb_network_header(skb);
        if (likely(skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
                headerlen += tcp_hdrlen(skb);
        skb_shinfo(skb)->gso_size = mtu - headerlen;

and disabling 'sg' on outgoing (lower-mtu) interface.  [ else BUG() ]

> > [   28.644776] kernel BUG at net/net/core/skbuff.c:2984!
> 
> Yep, lets CC Herbert Xu, as he 'owns' skb_segment()
> 
> BUG_ON(skb_headlen(fskb));
