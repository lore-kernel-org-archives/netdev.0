From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 1/6] bridge: learn dst metadata in FDB
Date: Thu, 17 Aug 2017 13:03:24 +0200
Message-ID: <20170817110324.GK773745@eidolon>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-2-equinox@diac24.net>
 <1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:48690 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751167AbdHQLD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 07:03:27 -0400
Content-Disposition: inline
In-Reply-To: <1fbaa432-6241-fad0-5407-8b87abb965ae@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay,


On Wed, Aug 16, 2017 at 11:38:06PM +0300, Nikolay Aleksandrov wrote:
> On 16/08/17 20:01, David Lamparter wrote:
> > This implements holding dst metadata information in the bridge layer,
> > but only for unicast entries in the MAC table.  Multicast is still left
> > to design and implement.
> 
> Sorry but I do not agree with this change, adding a special case for
> VPLS in the bridge code

I don't think this is specific to VPLS at all, though you're right that
VPLS is the only user currently.

> and hitting the fast path for everyone in a few different places for a
> feature that the majority will not use does not sound acceptable to
> me. We've been trying hard to optimize it, trying to avoid additional
> cache lines, removing tests and keeping special cases to a minimum. 

skb->dst is on the same cacheline as skb->len.
fdb->md_dst is on the same cacheline as fdb->dst.
Both will be 0 in a lot of cases, so this should be two null checks on
data that is hot in the cache.  Are you sure this is an actual problem?

> I understand that you want to use the fdb tables and avoid
> duplication, but this is not worth it. There're other similar use
> cases and they have their own private fdb tables, that way the user
> can opt out and is much cleaner and separated.

Sure, this can be done.  I think it's a noticeable performance penalty
to have the entire fdb copied (multiple times for H-VPLS even), but I
understand that it's preferable to have the normal cases faster in
exchange.  As the previous paragraph notes, I still wonder if that hit
to the normal case exists though.

I will leave this to Amine, he's paid to work on VPLS while I'm doing
this for fun ;)

There is however another concern I have here.  As I noted in my
introductory mail, I'm working on the bridge MDB making similar changes.
And there's actually strong use cases for this in both VPLS and the
802.11 code (though I'm not sure I can code the latter one up, it's
related to rate control and this is seriously complicated - the goal is
to select a multicast rate based on the now-known receiving STAs).

I really hope you're not suggesting the entire MDB with IPv4 & IPv6
snooping be duplicated into both VPLS and mac80211?

> As you've noted this is only an RFC so I will not point out every issue, but there seems
> to be a major problem with br_fdb_update(), note that it runs without any locks except RCU.

Right, Thanks! ... I only thought about concurrent access, forgetting
about concurrent modification...  I'll replace it with an xchg I think.
(No need for a lock that way)

That said, now that I think about it, the skb_dst_set_noref() in the
following chunk is probably not safe if the VPLS device has a qdisc on
it.  I was relying on the fact that br_dev_xmit is holding RCU there,
but if the SKB is queued, md_dst might go away in the meantime...
... probably need to change this to dst_hold() + skb_dst_set()...


-David

> > diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> > index 861ae2a165f4..534cacf02f8d 100644
> > --- a/net/bridge/br_device.c
> > +++ b/net/bridge/br_device.c
> > @@ -81,6 +82,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
> >  		else
> >  			br_flood(br, skb, BR_PKT_MULTICAST, false, true);
> >  	} else if ((dst = br_fdb_find_rcu(br, dest, vid)) != NULL) {
> > +		struct dst_entry *md_dst = rcu_dereference(dst->md_dst);
> > +		if (md_dst)
> > +			skb_dst_set_noref(skb, md_dst);
> >  		br_forward(dst->dst, skb, false, true);
> >  	} else {
> >  		br_flood(br, skb, BR_PKT_UNICAST, false, true);


> > diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> > index a79b648aac88..0751fcb89699 100644
> > @@ -567,10 +579,15 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
> >  					source->dev->name, addr, vid);
> >  		} else {
> >  			unsigned long now = jiffies;
> > +			struct dst_entry *ref_md = rcu_access_pointer(fdb->md_dst);
> >  
> >  			/* fastpath: update of existing entry */
> > -			if (unlikely(source != fdb->dst)) {
> > +			if (unlikely(source != fdb->dst ||
> > +			    dst_metadata_cmp(md_dst, ref_md))) {
> >  				fdb->dst = source;
> > +				dst_release(ref_md);
> > +				rcu_assign_pointer(fdb->md_dst,
> > +						dst_clone(md_dst));
> >  				fdb_modified = true;
> >  				/* Take over HW learned entry */
> >  				if (unlikely(fdb->added_by_external_learn))
