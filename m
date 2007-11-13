From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of
 locked section
Date: Tue, 13 Nov 2007 03:33:48 -0800 (PST)
Message-ID: <20071113.033348.13935138.davem@davemloft.net>
References: <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au>
	<200711071717.43429.netdev@axxeo.de>
	<20071108003903.GA11963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752122AbXKMLdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:33:49 -0500
In-Reply-To: <20071108003903.GA11963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Nov 2007 08:39:03 +0800

> On Wed, Nov 07, 2007 at 05:17:42PM +0100, Ingo Oeser wrote:
> > Hi Herbert,
> > 
> > Herbert Xu schrieb:
> > > diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
> > > index a7bc8c6..4a01cb3 100644
> > > --- a/net/ipv6/xfrm6_mode_ro.c
> > > +++ b/net/ipv6/xfrm6_mode_ro.c
> > > @@ -53,7 +54,9 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
> > >  	__skb_pull(skb, hdr_len);
> > >  	memmove(ipv6_hdr(skb), iph, hdr_len);
> > >  
> > > +	spin_lock_bh(&x->lock);
> > >  	x->lastused = get_seconds();
> > > +	spin_unlock_bh(&x->lock);
> > >  
> > >  	return 0;
> > >  }
> > 
> > Can you move the retrieval of the seconds outside the spinlock?
> 
> You certainly could.  Whether it's worth it I won't speculate :)

Make 'lastused' an 'unsigned long' (that's all that get_seconds()
gives to us anyways), fix up the nla_total_size(x->lastused) thing in
net/xfrm/xfrm_user.c, and then you can remove this lock acquisition
completely because the store into x->lastused will now be atomic and
therefore locks aren't protecting anything.
