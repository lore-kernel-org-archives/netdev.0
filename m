From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net,stable 1/2] l2tp: Fix PPP header erasure and memory
 leak
Date: Wed, 12 Jun 2013 07:50:48 -0700
Message-ID: <1371048648.3252.62.camel@edumazet-glaptop>
References: <cover.1371044671.git.g.nault@alphalink.fr>
	 <20130612140723.GB3500@alphalink.fr>
	 <1371048080.3252.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:48291 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab3FLOuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 10:50:52 -0400
Received: by mail-ea0-f173.google.com with SMTP id g15so6905700eak.18
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 07:50:51 -0700 (PDT)
In-Reply-To: <1371048080.3252.61.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 07:41 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-12 at 16:07 +0200, Guillaume Nault wrote:
> > Copy user data after PPP framing header. This prevents erasure of the
> > added PPP header and avoids leaking two bytes of uninitialised memory
> > at the end of skb's data buffer.
> > 
> > Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> > ---
> >  net/l2tp/l2tp_ppp.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
> > index 637a341..681c626 100644
> > --- a/net/l2tp/l2tp_ppp.c
> > +++ b/net/l2tp/l2tp_ppp.c
> > @@ -346,12 +346,12 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
> >  	skb_put(skb, 2);
> >  
> >  	/* Copy user data into skb */
> > -	error = memcpy_fromiovec(skb->data, m->msg_iov, total_len);
> > +	error = memcpy_fromiovec(skb_put(skb, total_len), m->msg_iov,
> > +				 total_len);
> >  	if (error < 0) {
> >  		kfree_skb(skb);
> >  		goto error_put_sess_tun;
> >  	}
> > -	skb_put(skb, total_len);
> >  
> >  	l2tp_xmit_skb(session, skb, session->hdr_len);
> >  
> 
> I see no real change in your patch.
> 
> skb_put(skb, X) returns skb->data before the put operation.
> 
> Could you elaborate ?

Oh well, I missed the prior skb_put(skb, 2), nevermind
