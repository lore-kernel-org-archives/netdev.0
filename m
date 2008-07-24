From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 16:34:31 +0300
Message-ID: <200807241634.31614.opurdila@ixiacom.com>
References: <E1KM0DG-0001vY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3903 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751680AbYGXNhC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 09:37:02 -0400
In-Reply-To: <E1KM0DG-0001vY-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 July 2008, Herbert Xu wrote:

Hi Herbert,

Thanks for taking the time for the review. 

>
> Putting it in the share info area makes its life-cycle management
> difficult.  This is also a major change to how we store skb control
> data.
>

Initially I tried putting the new member directly into the skb, but then I
run into issues with cloned packets, since I needed a reference
counter to know when to delete the cmsg queue.

I've noticed that the shared info already has a reference counter and I've 
though that taking advantage of it would be better then doing it myself. 

The shinfo seems to be the right place also because the cmsg queue can not be 
modified once the skb has been pushed into the network stack. It sort of is 
like data, only with special meaning.

Is this approach wrong? Or is there a better way of doing it?

> > @@ -567,6 +612,8 @@ static void copy_skb_header(struct sk_buff *new,
> > const struct sk_buff *old) skb_shinfo(new)->gso_size =
> > skb_shinfo(old)->gso_size;
> >        skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
> >        skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
> > +
> > +       skb_shinfo(new)->cmsg = skb_shinfo(old)->cmsg;
> > }
> >
> > /**
> > @@ -610,7 +657,8 @@ struct sk_buff *skb_copy(const struct sk_buff *skb,
> > gfp_t gfp_mask) BUG();
> >
> >        copy_skb_header(n, skb);
> > -       return n;
> > +
> > +       return skb_cmsg_copy(n, gfp_mask);
>
> What about the other callers of copy_skb_header, like pskb_copy?

>From what I understand, the shinfo remains shared, thus there is no need to do 
the copy here.

> In fact why isn't this in copy_skb_header?
>

In copy_skb_header we do a pointer copy. This should be enough for packets 
that are cloned or partially cloned.

The only problem is when we do a full copy of the packet, where shinfo should 
be also copied. skb_cmsg_copy is called only in these cases.

> Also what about pskb_expand_head?
>

I think this is only touching the skb header, not the shinfo. Thus we should 
be safe?

BTW: I have a dilemma with regard to fully copied skbs: should we copy the 
cmsg queue as well, or should we just prune it in the copy? I don't see a 
real usecase for doing the copy at this point, but since these is at core 
level, maybe it is a good idea to be conservative and do the copying?

Thanks,
tavi
