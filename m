From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Tue, 15 Oct 2013 22:55:10 +0200
Message-ID: <20131015205510.GA18442@unicorn.suse.cz>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
 <20131015083348.GW7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35210 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759563Ab3JOUzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 16:55:12 -0400
Content-Disposition: inline
In-Reply-To: <20131015083348.GW7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 10:33:48AM +0200, Steffen Klassert wrote:
> > diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
> > index 2906d52..96946fb 100644
> > --- a/net/xfrm/xfrm_ipcomp.c
> > +++ b/net/xfrm/xfrm_ipcomp.c
> > @@ -48,9 +48,11 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
> >  	const int cpu = get_cpu();
> >  	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
> >  	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
> > -	int err = crypto_comp_decompress(tfm, start, plen, scratch, &dlen);
> > +	int err;
> >  	int len;
> >  
> > +	local_bh_disable();
> 
> Maybe we could disable the BHs before we fetch the percpu pointers.
> Then we can use smp_processor_id() to get the cpu. With that we
> could get rid of a (now useless) preempt_disable()/preempt_enable()
> pair. Same could be done in ipcomp_compress().

Sounds like a good idea. I'll send v2 after some basic testing.

                                                 Michal Kubecek
