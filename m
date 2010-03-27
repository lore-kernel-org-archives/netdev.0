From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Sat, 27 Mar 2010 11:26:58 -0300
Message-ID: <20100327142658.GO3625@ghostprotocols.net>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com> <4BAA4EE4.3090900@nortel.com> <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com> <4BAA69BF.3080600@nortel.com> <84621a61003241255i74282f53v3bb0111808895401@mail.gmail.com> <84621a61003270619p6b4fe81bi24bb1961aba77ffb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <cfriesen@nortel.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Brandon Black <blblack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40389 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348Ab0C0O1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 10:27:05 -0400
Content-Disposition: inline
In-Reply-To: <84621a61003270619p6b4fe81bi24bb1961aba77ffb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Mar 27, 2010 at 08:19:09AM -0500, Brandon Black escreveu:
> On Wed, Mar 24, 2010 at 2:55 PM, Brandon Black <blblack@gmail.com> wr=
ote:
> > On Wed, Mar 24, 2010 at 2:36 PM, Chris Friesen <cfriesen@nortel.com=
> wrote:
> >> Consider the case where you want to do some other useful work in
> >> addition to running your network server. =A0Every cpu cycle spent =
on the
> >> network server is robbed from the other work. =A0In this scenario =
you want
> >> to handle packets as efficiently as possible, so the timeout-based
> >> behaviour is better since it is more likely to give you multiple p=
ackets
> >> per syscall.
> >
> > That's a good point, I tend to tunnelvision on the dedicated server
> > scenario. =A0I should probably have a user-level option for
> > timeout-based operation as well, since the decision here gets to th=
e
> > systems admin/engineering level and will be situational.
>=20
> I've been playing with the timeout argument to recvmmsg as well now,
> and I'm struggling to see how one would ever use it correctly with th=
e
> current implementation.  It seems to rely on the assumption of a
> never-ending stream of tightly-spaced input packets?  It seems like i=
t

As said by somebody else in this recent discussion (perhaps Chris), it
is based on the maximum latency acceptable.

If minimum latency is desired, use a zero timeout and get as many
packets get queued up while the application is processing the last
batch.

If instead more packets are desired per batch and some latency is
acceptable, use a timeout.

10 Gbit/s interfaces were the target but results with simple app
published when the syscall was posted initially showed that even on 1
1 Gbit/s eth this helped.

> was meant for usage on blocking sockets.  Given a blocking socket wit=
h
> timeout 0 (infinite), and a recvmmsg timeout of 100us, if you had a
> very steady stream of input packets, it recvmmsg would pull in all of
> them that it could within a max timeframe of (100us +
> time_to_execute_one_recvmsg).  However, any disruption to the input
> stream for a time-window of N would result in delaying some
> already-received packets by N.  For example, consider the case that 2
> packets are already queued when you invoke recvmmsg(), but then the
> next packet doesn't arrive for another 300ms.  In this scenario, you'=
d
> end up with recvmmsg() blocking for 300ms and then returning all 3
> packets, two of which have been delayed way beyond the specified
> timeout.

And that is a use case that is fixed by your patch, thanks, now we cove=
r
more use cases :-)

- Arnaldo
