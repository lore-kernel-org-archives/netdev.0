From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: Session ID 0 with PPPoE
Date: Wed, 7 Mar 2007 15:32:05 +0100
Message-ID: <20070307143205.GJ28150@florz.florz.dyndns.org>
References: <20070304145617.GI28150@florz.florz.dyndns.org> <1173055606.12398.64.camel@kdsk1.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbdc34.pool.mediaWays.net ([217.187.220.52]:4686 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030474AbXCGOcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 09:32:18 -0500
Content-Disposition: inline
In-Reply-To: <1173055606.12398.64.camel@kdsk1.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> In the current  code SID 0 indicates that the socket is to be un-bound.

That are the semantics used by the kernel code, yes - but even pppd uses
different semantics (which can't quite work, of course ...).

> Supporting unbinding of the socket was intended to permit the PPPoE
> session to be reconnected without closing/reopening the socket; which
> would mean that you'd have to re-bind the PPPoE/PPP channel bindings.
> Thus it is conceivable to swap or renegotiate PPPoE connection
> underneath a PPP connection, hypothetically if anyone ever considered
> doing so.  Is that worth it?  I don't know.  One could eliminate that
> disconnect behavior and I don't think anyone would care.

Well, if _you_ don't even know ... =:-)

Anyway, if it is not to be eliminated, it should be represented some way
differently, I guess. Which probably would break backwards compatibility
at the userspace API completely, of course, which is a bad thing[tm], so
possibly simply changing the semantics to what is already assumed by most
userspace applications might be the way to go.

> I'll conceed that a SID of 0 could appear from outer space.   I've never
> seen that happening.

Now, the question is, of course: How many samples is this based on
(both, number of connection attempts and number of different peer
implementations)?

> The only way I see this being an issue is if a
> PPPoE server insists on giving you SID 0 and only SID 0 repeatedly.  And
> I've never seen *that* happening.

So, what you are saying is that pppd/kernel-PPP/-PPPoE is so unstable that
you shouldn't ever be using it without some cron job/wrapper that takes
care of restarts anyway, so some additional bug that causes pppd to exit
unexpectedly doesn't matter?

That is to say: If I didn't overlook anything, pppd (the rp-pppoe plugin,
that is) warns you if the PADS' session id field is 0 that the AC was
somehow violating the RFC, but then goes on, using 0 as the session id
anyway - thus calling connect() with a session id field of 0, obviously
assuming that this will bind to session id 0 - which it doesn't.

Now, when it invokes the PPPIOCGCHAN ioctl on that seemingly successfully
connect()ed socket, it gets an ENOTCONN - and exits with a fatal error.
And exiting with a fatal error isn't quite what I'd expect pppd to do
when the peer is behaving correctly according to the RFC, since that will
not just cause a retry that might be likely to give a different session
id and thus would cause the connection to finally be established with
some delay, but rather will break network connectivity until manual
intervention.

Of course, you could argue that this is somehow a bug in pppd, as it
doesn't use the kernel API correctly. But I assume that fixing the
kernel to support sid 0 rather than fixing pppd to "support" sid 0
(which would mean implementing an automatic retry when assigned
sid 0 by the AC) is somehow the better solution.

> If you'd really like to pursue this, I'll be happy to review and ack
> patches in this regard.  However, I don't see what there is to be
> actually gained by pursuing this.   I'm open to being convinced; what is
> the motivation behind this?  If there is a real problem here I'll be
> glad to get involved in fixing it myself.

Now, what is a "real problem"? I haven't noticed this being a problem for
me yet, no. But I have been using userspace RP-PPPOE until recently and
I am using a cron job that takes care of restarts in case pppd exits for
some reason, so it's rather unlikely that I'd notice if it did happen.

But isn't a problem that does occur seldom, is difficult to reproduce,
and has more than just temporary effect much worse a problem than something
that causes a crash every half an hour and thus is simple to come by using
debugging and doesn't surprise you the very moment you need things to
simply work?

Actually, IMO the major question is: Is there any application that does
(intentionally) make use of this session rebinding/unbinding? Since
simply dropping that probably would be the easiest fix to implement.

Florian
