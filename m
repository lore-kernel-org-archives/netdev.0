From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 10:22:09 +0100
Message-ID: <20070306092209.GB12365@wotan.suse.de>
References: <20070305.202632.74752497.davem@davemloft.net> <20070306091112.GA12365@wotan.suse.de> <20070306.011706.26279529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, paulmck@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:57966 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbXCFJW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 04:22:29 -0500
Content-Disposition: inline
In-Reply-To: <20070306.011706.26279529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 01:17:06AM -0800, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Tue, 6 Mar 2007 10:11:12 +0100
> 
> > @@ -1449,6 +1472,12 @@ static struct dst_entry *ipv4_negative_a
> >  					  "%u.%u.%u.%u/%02x dropped\n",
> >  				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
> >  #endif
> > +			/* XXX:
> > +			 * What if rt does not exist in rt_hash, but is in
> > +			 * old_rt_hash? Don't we have to also check there?
> > +			 * Similar questions for a couple of other places that
> > +			 * look at rt_hash, but not old_rt_hash.
> > +			 */
> >  			rt_del(h, hash, rt);
> >  			ret = NULL;
> >  		}
> 
> For the cases like ip_rt_redirect() I made the decision that we'll
> just not add the complexity of having to look in the old_rt_hash
> table.
> 
> In these kinds of cases it's OK to miss events, they will just happen
> again.
> 
> It's one of the nice things about the routing cache, if you lose
> information it's OK because we'll just cook up a new entry from
> the persistent backing store that is the real routing tables.
> And for events like redirects, if we miss it, we'll just send the
> packet to the wrong next-hop again and receive another redirect
> message which we'll (hopefully) propagate to a routine cache
> entry.

Ah, that's a very neat trick. OK so with that question out of the
way, there _may_ just be a few other places where you're working
with an rt_hash table outside an rcu read critical section.

I tried to fix up a couple of obvious ones, and I've just put in
the BUG_ON assertions for you to verify the rest.

> Thanks for your feedback patch Nick, I'll process it tomorrow
> hopefully after getting some sleep.

No problem. Thanks.
