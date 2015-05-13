From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len
 before tc_classify
Date: Wed, 13 May 2015 23:33:48 +0200
Message-ID: <20150513213348.GC6179@breakpoint.cc>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
 <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	fw@strlen.de, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44546 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933957AbbEMVd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:33:58 -0400
Content-Disposition: inline
In-Reply-To: <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
> > removed the call to qdisc_enqueue_root(). However, after this removal
> > we no longer set qdisc pkt length, which this patch fixes. We make use
> > of qdisc_pkt_len_init() from 1def9238d4aa ("net_sched: more precise
> > pkt_len computation"), which was suggested as the current approach so
> > far does not take into account when GRO builds up GSO packets.
> > 
> > Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> > Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> > ---
> >  v1->v2:
> >   - use qdisc_pkt_len_init() as suggested, thanks!
> >
> > @@ -3541,9 +3541,11 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
> >  		*pt_prev = NULL;
> >  	}
> >  
> > -	qdisc_bstats_update_cpu(cl->q, skb);
> > +	qdisc_pkt_len_init(skb);
[..]
> 
> Is qdisc_pkt_len_init() still inlined, now it has 2 callers ?

gcc 4.8.4, OPTIMIZE_FOR_SIZE=n: nope, callq.

> People using policers on ingress are very often disabling GRO for
> various historical reasons.

right, ingress policing is rather poor with GRO (or you need to set mtu 64000
on the tc police cmd line).

> Since handle_ing() is very uncommon, I would prefer not slowing down tx
> just so that GRO ~5% error in ingress is fixed.

Hmm, so whats you suggestion?  Just use

qdisc_skb_cb(skb)->pkt_len = skb->len;

like in v1 of the patch set?
resurrect qdisc_enqueue_root?
set always_inline (i'd prefer not, its not very small)?

Any other idea?

Thanks!
