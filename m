From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours:
	ip6_dst_lookup_tail NULL crash
Date: Tue, 9 Sep 2008 06:56:22 -0400
Message-ID: <20080909105622.GA5991@hmsreliant.think-freely.org>
References: <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080907181109.GA2466@2ka.mipt.ru> <200809072119.50307.rdenis@simphalempin.com> <20080908.131547.26037628.davem@davemloft.net> <20080908203418.GA16637@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rdenis@simphalempin.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33572 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbYIIMPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 08:15:01 -0400
Content-Disposition: inline
In-Reply-To: <20080908203418.GA16637@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 12:34:18AM +0400, Evgeniy Polyakov wrote:
> Hi David.
> 
> On Mon, Sep 08, 2008 at 01:15:47PM -0700, David Miller (davem@davemloft.net) wrote:
> > But I don't like this patch for several reasons:
> > 
> > 1) Slapping on a NULL check in response to a OOPS at that exact
> >    location is usually a very big red flag, and deserves high scrutiny
> >    instead of blind acceptance.
> > 
> > 2) Looking at the indentation of this DAD code block (it's all one tab
> >    too much) it's obviously a very shitty cut and paste job.  If the
> >    coding style was too difficult to get right, what does this say
> >    about that change that brought the code here, semantically? :-/
> > 
> >    This means we should figure out how this code got to this place,
> >    and what kind of invariants existed at the old location that might
> >    make this dst->neighbour dereference valid, and what implications
> >    there are for the fact that it can now be NULL.
> > 
> > Really, we really need to understand much more deeply this situation.
> 
> Well, yes. The whole 'optimistic' dad looks a bit suspicious. I think
> failed dst entry without neighbour is a result of the 'static' dst entry
> returned by the above route lookup and previously neighbour was not
> used at all. This patch fixes the opps, but may be just hiding a
> problem, but reading how this optimistic duplicate address detection
> works, I see no strict requirements that returned route entry has to
> have neighbour, so this check actually can be a right fix.
> 
> I've added Neil Horman, who created the patch 1.5 years ago, to the
> copy list.
> 
I agree, while I don't normally like to fix an oops with just a NULL check,
since as dave mentions, thats a pretty big red flag about not having thought
through the problem, I think in this case its probably the right fix.  having a
dst entry without a corresponding neightbor entry is going to be a rarity to say
the least, but it can happen (Evgeniy's above example, for instance, or perhaps
a situation in which the arp cache was explicitly purged at just the right time
from userspace).  Regardless, making sure we have one by explicitly checking the
pointer seems like the right thing to do.  As Evgeniy noted, the Optimistic DAD
code provides no explicit guarantee that we have a neigh entry for this dst.
We just want to be sure we forward packets to an incomplete neighbour that is
marked as optimistic to the router.  We already do this dst->neighbour NULL
check in many other locations (giving us precident, see ip6_output_finish and
ip6_forward as just a few examples).  I think its right to do the same check in
the Optimistic DAD code.  I just never hit it in my testing since its an
uncommon case.


As for the indentation, I'm pretty sure this was the only point I wrote/used
this code, so I'm loathe to believe that the indentation was a cut and paste
error.  Unfortunately, that just implies it was my own stupidity and poor
eyesight that created that uglynesss.  Apologies Dave, I'll submit a patch
shortly to correct that.

Thanks & Regards
Neil

> -- 
> 	Evgeniy Polyakov
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
