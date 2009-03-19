From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 23:48:46 -0400
Message-ID: <49C1C09E.8050405@novell.com>
References: <49C16349.9030503@us.ibm.com>	<20090318.143844.173112261.davem@davemloft.net>	<49C16D7C.3080003@novell.com> <20090318.180355.228447835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig92404978001B3FBE2CBD5BC1"
Cc: vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:39578 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbZCSDqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 23:46:34 -0400
In-Reply-To: <20090318.180355.228447835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig92404978001B3FBE2CBD5BC1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Gregory Haskins <ghaskins@novell.com>
> Date: Wed, 18 Mar 2009 17:54:04 -0400
>
>  =20
>> Note that -rt doesnt typically context-switch under contention anymore=

>> since we introduced adaptive-locks.  Also note that the contention
>> against the lock is still contention, regardless of whether you have -=
rt
>> or not.  Its just that the slow-path to handle the contended case for
>> -rt is more expensive than mainline.  However, once you have the
>> contention as stated, you have already lost.
>>    =20
>
> First, contention is not implicitly a bad thing.
>  =20
However, when the contention in question is your top bottleneck, even
small improvements have the potential to yield large performance gains. :=
)

> Second, if the -rt kernel is doing adaptive spinning I see no
> reason why that adaptive spinning is not kicking in here
It does.  Things would be *much* worse if it wasn't.

>  to
> make this problem just go away.
>  =20
Well, "go away" is a relative term.  Before adaptive-locks, the box was
heavily context-switching under a network workload like we are
discussing, and that is where much of the performance was lost.=20
Adaptive-locks mitigate that particular problem so that spinlock_t
clients now more closely model mainline behavior (i.e. spin under
contention, at least when they can) and this brought -rt much closer to
what you expect for performance from mainline.

However, in -rt the contention path is, by necessity, still moderately
more heavy weight than a simple mainline spin (PI, etc), so any
contention will still hurt relatively more.   And obviously
adaptive-locks do nothing to address the contention itself.  Therefore,
as long as the contention remains it will have a higher impact in -rt.=20
But make no mistake: the contention can (and I believe does) affect both
trees.

To see this in action, try taking a moderately large smp system (8-way+)
and scaling the number of flows.  At 1 flow the stack is generally quite
capable of maintaining line-rate (at least up to GigE).  With two flows
this should result in each achieving roughly 50% of the line-rate, for a
sum total of line-rate.  But as you add flows to the equation, the
aggregate bandwidth typically starts to drop off to be something less
than line-rate (many times its actually much less).  And when this
happens, the contention in question is usually at the top of the charts
(thus all the interest in this thread).

> This lock is held for mere cycles, just to unlink an SKB from
> the networking qdisc, and then it is immediately released.
>  =20
To clarify: I haven't been looking at the stack code since last summer,
so some things may have changed since then.  However, the issue back
then from my perspective was the general backpressure in the qdisc
subsystem (e.g. dev->queue_lock), not just the skb head.lock per se.=20
This dev->queue_lock can be held for quite a long time, and the
mechanism in general scales poorly as the fabric speeds and core-counts
increase.  (It is arguable whether you would even want another buffering
layer on any reasonably fast interconnect, anyway.  It ultimately just
destabilizes the flows and is probably best left to the underlying
hardware which will typically have the proper facilities for
shaping/limiting, etc. However, that is a topic for another discussion ;)=
=2E)

One approach that we found yielded some significant improvements here
was to bypass the qdisc outright and do per-cpu lockless queuing.  One
thread/core could then simply aggregate the per-cpu buffers with only
minor contention between the egress (consuming) core and the producer
thread.  I realize that this solution as-is may not be feasible for
production use.  However, it did serve to prove the theory that backing
off cache-line pressures that scale with the core count *did* help the
stack make more forward progress per unit time (e.g. higher throughput)
as the number of flows increased.  The idea was more or less to refactor
the egress/TX path to be more per-cpu, similar to the methodology of the
ingress/RX side.

You could probably adapt this same concept to work harmoniously with the
qdisc infrastructure (though as previously indicated, I am not sure if
we would *want* to ;)).  Something to consider, anyway.

Regards,
-Greg




--------------enig92404978001B3FBE2CBD5BC1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknBwJ4ACgkQlOSOBdgZUxnEXQCffJj0zcwaubjTv4TCc3G0XXbE
F8UAn3vAjbPApDX2/FwBE7GbwwmXUk5V
=KqhC
-----END PGP SIGNATURE-----

--------------enig92404978001B3FBE2CBD5BC1--
