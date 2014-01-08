From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Wed, 08 Jan 2014 05:42:16 -0800
Message-ID: <1389188536.26646.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
	 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140107152520.GF9894@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vvs@openvz.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140107152520.GF9894@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-01-07 at 16:25 +0100, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > > index 43549eb..7a34bb2 100644
> > > --- a/net/netfilter/nf_conntrack_core.c
> > > +++ b/net/netfilter/nf_conntrack_core.c
> > > @@ -387,8 +387,12 @@ begin:
> > >  			     !atomic_inc_not_zero(&ct->ct_general.use)))
> > >  			h = NULL;
> > >  		else {
> > > +			/* A conntrack can be recreated with the equal tuple,
> > > +			 * so we need to check that the conntrack is initialized
> > > +			 */
> > >  			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple) ||
> > > -				     nf_ct_zone(ct) != zone)) {
> > > +				     nf_ct_zone(ct) != zone) ||
> > > +				     !nf_ct_is_confirmed(ct)) {
> > >  				nf_ct_put(ct);
> > >  				goto begin;
> > >  			}
> > 
> > I do not think this is the right way to fix this problem (if said
> > problem is confirmed)
> > 
> > Remember the rule about SLAB_DESTROY_BY_RCU :
> > 
> > When a struct is freed, then reused, its important to set the its refcnt
> > (from 0 to 1) only when the structure is fully ready for use.
> > 
> > If a lookup finds a structure which is not yet setup, the
> > atomic_inc_not_zero() will fail.
> 
> Indeed.  But, the structure itself might be ready (or rather,
> can be ready since the allocation side will set the refcount to one
> after doing the initial work, such as zapping old ->status flags and
> setting tuple information).
> 
> The problem is with nat extension area stored in the ct->ext area.
> This extension area is preallocated but the snat/dnat action
> information is only set up after the ct (or rather, the skb that grabbed
> a reference to the nf_conn entry) traverses nat pre/postrouting.
> 
> This will also set up a null-binding when no matching SNAT/DNAT/MASQERUADE
> rule existed.
> 
> The manipulations of the skb->nfct->ext nat area are performed without
> a lock.  Concurrent access is supposedly impossible as the conntrack
> should not (yet) be in the hash table.
> 
> The confirmed bit is set right before we insert the conntrack into
> the hash table (after we traversed rules, ct is ready to be
> 'published').
> 
> i.e. when the confirmed bit is NOT set we should not be 'seeing' the nf_conn
> struct when we perform the lookup, as it should still be sitting on the
> 'unconfirmed' list, being invisible to readers.
> 
> Does that explanation make sense to you?
> 
> Thanks for looking into this.

Still, this patch adds a loop. And maybe an infinite one if confirmed
bit is set from an context that was interrupted by this one.

If you need to test the confirmed bit, then you also need to test it
before taking the refcount.
