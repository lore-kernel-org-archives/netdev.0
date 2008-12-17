From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Wed, 17 Dec 2008 11:13:47 -0200
Message-ID: <20081217131347.GS14518@ghostprotocols.net>
References: <20081216111908.GI14518@ghostprotocols.net> <20081216.133200.229085084.davem@davemloft.net> <20081216222559.GR14518@ghostprotocols.net> <20081216.151151.220977047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerrit@erg.abdn.ac.uk, mirqus@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38819 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbYLQNOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 08:14:01 -0500
Content-Disposition: inline
In-Reply-To: <20081216.151151.220977047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Dec 16, 2008 at 03:11:51PM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Tue, 16 Dec 2008 20:25:59 -0200
> 
> > Em Tue, Dec 16, 2008 at 01:32:00PM -0800, David Miller escreveu:
> > > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > > Date: Tue, 16 Dec 2008 09:19:08 -0200
> > > 
> > > Whereas the DCCP case is right in the connection creation fast path
> > > and unconditionally executes, because it is trying to figure out what
> > > CCID algorithms it can advertise.
> > 
> > Well, there must be some way to locklessly advertise what was previously
> > loaded (and thus can't ever be unloaded).
> 
> This gets us back to my original objection.
> 
> Can these things be unloaded?  If not, and they get unconditionally
> all loaded up on the first DCCP connection, why make them seperate
> modules at all?
> 
> If they can get unloaded, then you need synchronization.
> 
> I would recommend that everything gets built into dccp.ko
> and thus the table is fixed and never changes and thus no
> locking nor any of this funny mod loading is needed at all.

Perhaps we can have something like we have with the tcp congestion
modules: the modules that are non experimental, because they are already
in an RFC and/or the implementation was deemed stable, should be linked
with dccp.ko and would by default be advertised, i.e. they are the system
wide available CCIDs as configured at kernel build time.

But then, if the user, after he creates the socket, on the slow path,
does a setsockopt asking for a newer CCID (CCID4 is in the works, for
instance) to be advertised for this specific connection or if it asks
for some in the static set of CCIDs _not_ to be advertised, then the
feature negotiation code will advertise the selected set.

Only applications wanting newer stuff will incur the cost of the synch
at connection time while the majority will not incur such costs by
using the penguin peed static CCIDs.

I.e. a VOIP app would say that it is not interested in CCID2, wanting
only CCID3 or CCID4.

IOW we're back to my suggestion on looking at
tcp_set_congestion_control(). :-)

- Arnaldo
