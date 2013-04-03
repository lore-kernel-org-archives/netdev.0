From: Linus =?utf-8?b?TMO8c3Npbmc=?= <linus.luessing@web.de>
Subject: Re: [0/3] bridge: Do not send multicast queries by default
Date: Wed, 3 Apr 2013 15:28:42 +0000 (UTC)
Message-ID: <loom.20130403T154347-81@post.gmane.org>
References: <20120413123641.GA758@gondor.apana.org.au> <20120413.105345.319552552748408545.davem@davemloft.net> <20120415111300.GA14147@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:34759 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761643Ab3DCPon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 11:44:43 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UNPs0-0000Sl-5Z
	for netdev@vger.kernel.org; Wed, 03 Apr 2013 17:45:04 +0200
Received: from anon-37-150.vpn.ipredator.se ([anon-37-150.vpn.ipredator.se])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 17:45:04 +0200
Received: from linus.luessing by anon-37-150.vpn.ipredator.se with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 17:45:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert <at> gondor.apana.org.au> writes:

> 
> On Fri, Apr 13, 2012 at 10:53:45AM -0400, David Miller wrote:
> > From: Herbert Xu <herbert <at> gondor.hengli.com.au>
> > Date: Fri, 13 Apr 2012 20:36:41 +0800
> > 
> > > (incidentally, I noticed that our IPv6 code has been "fixed" to not
> > > use zero source addresses, which is wrong as we may end up being THE
> > > MLD querier in a network).
> > 
> > I seem to recall it was explicitly changed to be this way and that
> > there was a good reason for this, see the history.
> 
> Right, the reason given is that RFC2710 (for MLD) requires the
> source address to be a link-local address.
> 
> However, we're not implementing an RFC2710 node here.  What we're
> doing is better described by RFC4541 (IGMP/MLD snooping), which calls
> for the use of a zero source address for both IPv4 and IPv6.

Hm, yes, you're right, RFC4541 mentions a zero-source address in a short
paragraph.

> 
> The reason is precisely because it's invalid for normal querier
> nodes and as such they would ignore us (rather than elect us
> and potentially disrupt things).
> 

Okay, right, RFC2710, section 6, "query received from a router with a lower IP
address" prevents that. But aren't RFC2710, section 5, "query received" and
RFC3810, section 5.1.14 preventing multicast listeners from processing our
query, too?

I'm not sure, but the _informational_ RFC4541 is not supposed to update the
general MLDv1/2 node (especially multicast listener) behaviour from the
proposed standards RFC2710/RFC3810, is it?

> Now granted we may also end up having other nodes ignoring our
> queries where we'd rather that they answered us with reports.
> However, this isn't as bad because the whole querying mechanism
> in the snooping code is merely an optimisation to speed up
> convergence primarily during start-up.  So if we don't see the
> reports straight away it's not a deal-breaker.

I'm not sure about that either whether it's just an optimization. Changing the
default setting to a disabled querier in the snooping code actually broke things
for me in a setup where no multicast router is present:

The thing is, with no querier on the link there are no periodic MLDv1 Reports /
MLDv2 Current State Reports (see RFC2710,  section 5. for instance, there's no
timer for the "Idle Listener" state; for RFC3810/MLDv2 I didn't find such a
timer either).

If creating a bridge interface after a multicast listener has sent all its
initial reports, then such a multicast listener will never be seen by our
bridge. Which either results in flooding the according multicast traffic on all
ports (because of another bug in the multicast snooping code, a bug which you've
actually fixed for IPv4 already, but not for IPv6, I think) if no other listener
joins after the bridge creation. Or results in this multicast listener not
receiving its traffic from the according IPv6 multicast address with a transient
flag if another listener joins on another port after creating the bridge.


Unfortunately if we were changing things back to sending multicast queries by
default, then this breaks things when another multicast router is present, one
which performs a proper querier protocol, urgh...

Maybe we'd need to implement a proper querier behaviour in the snooping code,
one as specified in RFC3810 for multicast routers, for instance?

And I'm also wondering what if yes the least harmful default settings would be
for the bridge multicast snooping for now.

> 
> Cheers,

Cheers, Linus
