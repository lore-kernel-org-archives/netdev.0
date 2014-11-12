From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH nf] netfilter: conntrack: fix race in
 __nf_conntrack_confirm against get_next_corpse
Date: Wed, 12 Nov 2014 08:35:00 +0100
Message-ID: <20141112083500.5404e5f4@redhat.com>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
	<20141106133648.2534.1403.stgit@dragon>
	<20141110165439.GA7788@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: programme110@gmail.com, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	brouer@redhat.com, Patrick McHardy <kaber@trash.net>,
	Joerg Marx <joerg.marx@secunet.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20141110165439.GA7788@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Nov 2014 17:54:39 +0100
Pablo Neira Ayuso <pablo@netfilter.org> wrote:

> On Thu, Nov 06, 2014 at 02:36:48PM +0100, Jesper Dangaard Brouer wrote:
> > From: bill bonaparte <programme110@gmail.com>
> > 
> > After removal of the central spinlock nf_conntrack_lock, in
> > commit 93bb0ceb75be2 ("netfilter: conntrack: remove central
> > spinlock nf_conntrack_lock"), it is possible to race against
> > get_next_corpse().
> > 
> > The race is against the get_next_corpse() cleanup on
> > the "unconfirmed" list (a per-cpu list with seperate locking),
> > which set the DYING bit.
> > 
> > Fix this race, in __nf_conntrack_confirm(), by removing the CT
> > from unconfirmed list before checking the DYING bit.  In case
> > race occured, re-add the CT to the dying list.
> 
> This seems correct to me, some side comments.
> 
> > Fixes: 93bb0ceb75be2 ("netfilter: conntrack: remove central spinlock nf_conntrack_lock")
> > Reported-by: bill bonaparte <programme110@gmail.com>
> > Signed-off-by: bill bonaparte <programme110@gmail.com>
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> > 
> >  net/netfilter/nf_conntrack_core.c |    7 ++++---
> >  1 files changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > index 5016a69..1072650 100644
> > --- a/net/netfilter/nf_conntrack_core.c
> > +++ b/net/netfilter/nf_conntrack_core.c
> > @@ -611,12 +611,15 @@ __nf_conntrack_confirm(struct sk_buff *skb)
> >  	 */
> >  	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
> >  	pr_debug("Confirming conntrack %p\n", ct);
> > -	/* We have to check the DYING flag inside the lock to prevent
> > +
> > +	/* We have to check the DYING flag after unlink to prevent
> >  	   a race against nf_ct_get_next_corpse() possibly called from
> >  	   user context, else we insert an already 'dead' hash, blocking
> >  	   further use of that particular connection -JM */
> 
> While at this, I think it would be good to fix comment style to:
> 
>         /* We have ...
>          * ...
>          */
> 
> I can fix this here, no need to resend, just let me know.

Okay, I was just trying to keep the changes as minimal as possible, if
this should go into a stable-kernel.  Your choice.


> > +	nf_ct_del_from_dying_or_unconfirmed_list(ct);
> >  
> >  	if (unlikely(nf_ct_is_dying(ct))) {
> > +		nf_ct_add_to_dying_list(ct);
> >  		nf_conntrack_double_unlock(hash, reply_hash);
> >  		local_bh_enable();
> >  		return NF_ACCEPT;
> 
> Not directly related to your patch, but I don't find a good reason why
> we're accepting this packet.
> 
> If the conntrack from the unconfirmed list is dying, then the object
> will be released by when the packet leaves the stack to its
> destination. With stateful filtering depending in place, the follow up
> packet in the reply direction will likely be considered invalid (if
> tcp tracking is on). Fortunately for us, the origin will likely
> retransmit the syn again, so the ct will be setup accordingly.
> 
> So, why should we allow this to go through?

True, it also seems strange to me that we accept this packet.

> This return verdict was introduced in: fc35077 ("netfilter:
> nf_conntrack: fix a race in __nf_conntrack_confirm against
> nf_ct_get_next_corpse()") btw.

And the commit does not argue why NF_ACCEPT was chosen...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
