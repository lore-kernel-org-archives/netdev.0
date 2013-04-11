From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 11 Apr 2013 09:32:41 -0700
Message-ID: <1365697961.3887.176.camel@edumazet-glaptop>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
	 <1362696444.15793.220.camel@edumazet-glaptop>
	 <20130307.181527.390191009324148471.davem@davemloft.net>
	 <20130313232743.GA3686@raven> <1363223884.29475.0.camel@edumazet-glaptop>
	 <20130314144550.GB2512@raven> <1363273531.29475.21.camel@edumazet-glaptop>
	 <1363274946.29475.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:37796 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3DKQcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 12:32:47 -0400
Received: by mail-da0-f52.google.com with SMTP id f10so750454dak.25
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 09:32:47 -0700 (PDT)
In-Reply-To: <1363274946.29475.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 16:29 +0100, Eric Dumazet wrote:
> On Thu, 2013-03-14 at 16:05 +0100, Eric Dumazet wrote:
> > On Thu, 2013-03-14 at 14:45 +0000, Tom Parkin wrote:
> > > On Thu, Mar 14, 2013 at 02:18:04AM +0100, Eric Dumazet wrote:
> > > > Ah thanks for this, as this definitely makes more sense ;)
> > > > 
> > > > Could you try the following fix ?
> > > > 
> > > > diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> > > > index b6d30ac..87f4ecb 100644
> > > > --- a/net/ipv4/ip_fragment.c
> > > > +++ b/net/ipv4/ip_fragment.c
> > > > @@ -529,6 +529,7 @@ found:
> > > >  	    qp->q.meat == qp->q.len)
> > > >  		return ip_frag_reasm(qp, prev, dev);
> > > >  
> > > > +	skb_dst_force(skb);
> > > >  	inet_frag_lru_move(&qp->q);
> > > >  	return -EINPROGRESS;
> > > >
> > > 
> > > Thanks Eric, with this patch I can no longer reproduce the oops :-)
> > 
> > Thanks for testing.
> > 
> > I am considering an alternative patch :
> > 
> > We can drop the reference instead, and use the dst of the last skb.
> > 
> > This would help to not dirty the dst refcount.
> > 
> > I'll send an updated version.
> > 
> 
> OK, I tested the following one instead, please test it so that I can send an official patch.
> 
> Thanks
> 
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index b6d30ac..2d23830 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -529,6 +529,7 @@ found:
>  	    qp->q.meat == qp->q.len)
>  		return ip_frag_reasm(qp, prev, dev);
>  
> +	skb_dst_drop(skb);
>  	inet_frag_lru_move(&qp->q);
>  	return -EINPROGRESS;
>  
> 

Short update : I do not understand yet why this patch is not working.

Normally, the reassembled packet should get the dst from the last skb
(the one completing the packet)...

I have to make more experiments.
