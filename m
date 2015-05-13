From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len
 before tc_classify
Date: Wed, 13 May 2015 14:38:52 -0700
Message-ID: <1431553132.27831.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
	 <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513213348.GC6179@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33103 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965463AbbEMViy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:38:54 -0400
Received: by pdbnk13 with SMTP id nk13so63658342pdb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 14:38:54 -0700 (PDT)
In-Reply-To: <20150513213348.GC6179@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 23:33 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
> > > removed the call to qdisc_enqueue_root(). However, after this removal
> > > we no longer set qdisc pkt length, which this patch fixes. We make use
> > > of qdisc_pkt_len_init() from 1def9238d4aa ("net_sched: more precise
> > > pkt_len computation"), which was suggested as the current approach so
> > > far does not take into account when GRO builds up GSO packets.
> > > 
> > > Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> > > Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> > > Signed-off-by: Florian Westphal <fw@strlen.de>
> > > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> > > ---
> > >  v1->v2:
> > >   - use qdisc_pkt_len_init() as suggested, thanks!
> > >
> > > @@ -3541,9 +3541,11 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
> > >  		*pt_prev = NULL;
> > >  	}
> > >  
> > > -	qdisc_bstats_update_cpu(cl->q, skb);
> > > +	qdisc_pkt_len_init(skb);
> [..]
> > 
> > Is qdisc_pkt_len_init() still inlined, now it has 2 callers ?
> 
> gcc 4.8.4, OPTIMIZE_FOR_SIZE=n: nope, callq.
> 
> > People using policers on ingress are very often disabling GRO for
> > various historical reasons.
> 
> right, ingress policing is rather poor with GRO (or you need to set mtu 64000
> on the tc police cmd line).
> 
> > Since handle_ing() is very uncommon, I would prefer not slowing down tx
> > just so that GRO ~5% error in ingress is fixed.
> 
> Hmm, so whats you suggestion?  Just use
> 
> qdisc_skb_cb(skb)->pkt_len = skb->len;
> 
> like in v1 of the patch set?
> resurrect qdisc_enqueue_root?
> set always_inline (i'd prefer not, its not very small)?
> 
> Any other idea?

One possibility would be to set it in GRO engine.

But then we would have to set qdisc_skb_cb(skb)->pkt_len = skb->len for
non GRO packets.

Also note the DODGY thing might be not needed for ingress,
and I am not sure we can currently deliver UDP aggregated packets.

Hmm....
