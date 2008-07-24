From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 19:22:57 +0300
Message-ID: <200807241922.57361.opurdila@ixiacom.com>
References: <E1KM0DG-0001vY-00@gondolin.me.apana.org.au> <200807241634.31614.opurdila@ixiacom.com> <20080724150116.GA8692@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4698 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751950AbYGXQZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 12:25:24 -0400
In-Reply-To: <20080724150116.GA8692@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 July 2008, Herbert Xu wrote:

> > From what I understand, the shinfo remains shared, thus there is no need
> > to do the copy here.
>
> No pskb_copy does a full copy on the head portion of the packet
> which is where your cmsg is.
>
> > > Also what about pskb_expand_head?
> >
> > I think this is only touching the skb header, not the shinfo. Thus we
> > should be safe?
>
> But you're freeing the cmsg in skb_release_data which is called
> by pskb_expand_head.  This can't possibly work.

Right, I've missed the fact that skb_shinfo is stored in the header part. 

> Do we need to make it so generic? If we do then can you please
> come up with other uses for it too.  For example, find out what
> existing fields can be better suited by storing them as a cmsg.
> Only then can we design this properly.

It looks like we can switch a few members from the skb to cmsg: secmark, 
priority, tstamp, thus saving some space in the skb, but we will have a 
performance overhead for accessing these since we now have to search for them 
in the cmesg list.

So, the more I think about this the more I am inclined to think that we don't 
really need it. For our hw timestamp usecases, the reason of this patch, we 
can get away by adding these new fields in the skb:

u16 flags; /* request / signal presence of RX/TX hw stamps, TX scheduling, TX 	
		    embed hw timestamp in packet */
u8 hwstamp[6];

and of course the mechanism of enabling hw stamps requests on per skb, with 
msghdr.msg_control stuff. 

Would that be acceptable (with proper CONFIG_HW_TSTAMPS of course)?

Thanks,
tavi
