From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/7] net: Add skb_get_hash_perturb
Date: Wed, 29 Apr 2015 04:19:30 -0700
Message-ID: <1430306370.3711.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
	 <1430281661-2271966-2-git-send-email-tom@herbertland.com>
	 <20150429075947.GB30392@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jiri@resnulli.us
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36721 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422882AbbD2LTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 07:19:32 -0400
Received: by pabsx10 with SMTP id sx10so25144466pab.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 04:19:32 -0700 (PDT)
In-Reply-To: <20150429075947.GB30392@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 09:59 +0200, Florian Westphal wrote:
> Tom Herbert <tom@herbertland.com> wrote:
> > This is used to get the skb->hash and then perturb it for a local use.
> > 
> > Signed-off-by: Tom Herbert <tom@herbertland.com>
> > ---
> >  include/linux/skbuff.h | 15 +++++++++++++++
> >  1 file changed, 15 insertions(+)
> > 
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 66e374d..b706889 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -17,6 +17,7 @@
> >  #include <linux/kernel.h>
> >  #include <linux/kmemcheck.h>
> >  #include <linux/compiler.h>
> > +#include <linux/jhash.h>
> >  #include <linux/time.h>
> >  #include <linux/bug.h>
> >  #include <linux/cache.h>
> > @@ -927,6 +928,20 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
> >  	return skb->hash;
> >  }
> >  
> > +static inline __u32 skb_get_hash_perturb(struct sk_buff *skb,
> > +					 u32 perturb)
> > +{
> > +	u32 hash = skb_get_hash(skb);
> > +
> > +	if (likely(hash)) {
> > +		hash = jhash_1word((__force __u32) hash, perturb);
> 
> Whats this perturb for?
> 
> perturb is supposed to make sure that if you have
> 
> flow1, flow2 where hash(flow1, perturb) == hash(flow2, perturb)
> the collision will be temporary and go away once perturb changes.
> 
> If you perturb after hashing, such collision is permanent.
> 
> So I think this either should flow_dissect + hash in software,
> or just use skb_get_hash without perturb.

Yes, I mentioned this several times to Tom in the various past attempts.

Also, this stuff means that sfq will call jhash twice instead of once,
unless skb->hash is already populated before sfq enqueue.

If the goal is to extend skb to include a flow_keys_digest instead of
u32 hash, lets state this right now ;)

I think I already suggested to add a 'perturb' parameter to
skb_get_hash() to use in place of hashrnd (found in
net/core/flow_dissector.c)

If hash is Toeplitz based and provided by a NIC, I doubt a jhash()
perturbation will get anything better.
