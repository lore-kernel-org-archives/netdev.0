From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 10 Feb 2014 05:12:37 -0800
Message-ID: <1392037957.6615.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
	 <1390810971-23959-2-git-send-email-fw@strlen.de>
	 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140128085706.GB30123@breakpoint.cc>
	 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140209025504.GB17395@gondor.apana.org.au>
	 <20140210122331.GA25153@breakpoint.cc>
	 <20140210123124.GA28752@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49593 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbaBJNMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 08:12:38 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so6197946pab.38
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 05:12:38 -0800 (PST)
In-Reply-To: <20140210123124.GA28752@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 20:31 +0800, Herbert Xu wrote:
> On Mon, Feb 10, 2014 at 01:23:31PM +0100, Florian Westphal wrote:
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > > > static void ip_gso_adjust_seglen(struct sk_buff *skb)
> > > > > {
> > > > >         unsigned int mtu;
> > > > > 
> > > > >         if (!skb_is_gso(skb))
> > > > >                 return;
> > > > > 
> > > > >         mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
> > > > >         skb_shinfo(skb)->gso_size = mtu - sizeof(struct iphdr);
> > > > > }
> > > > > 
> > > > > But this yields
> > > > > 
> > > > > [   28.644776] kernel BUG at net/net/core/skbuff.c:2984!
> > > > 
> > > > Yep, lets CC Herbert Xu, as he 'owns' skb_segment()
> > > 
> > > IMHO we should just stop merging ~DF packets altogether, at least
> > > for TCP.
> > 
> > Eric, you added DF aggregation in db8caf3dbc77599dc90f4ea0a803cd1d97116f30
> > (gro: should aggregate frames without DF).
> > 
> > I guess you don't want to revert this commit?
> > Any other ideas?
> > 
> > skb_gso_segment() is already very complex, I don't want to add more code
> > to it.  And that seems unavoidable if we need to de-couple nr_frags and
> > gso_size.
> 
> I don't think adding all this complexity just to be able to
> aggregate ~DF packets (which are just wrong to begin with) is
> worth it.

Wrong by your standards. Which are not universal.

> 
> If aggregating ~DF packets was a one-liner then sure, but there
> is a reason why I didn't aggregate them in the first place and
> you've found it :)

I sent months ago a solution for skb_segment() that you ignored.

I understand you never hit cases where DF was not set, I can tell you
its happening in the real world.

GRO stack already breaks reversibility by definition since day-0

Recent tunneling support breaks it as well.
