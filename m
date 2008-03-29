From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Sat, 29 Mar 2008 11:02:28 +0100
Message-ID: <1206784948.22530.128.camel@johannes.berg>
References: <20080328000013.GA8193@codemonkey.org.uk>
	 <20080328.173414.22278840.davem@davemloft.net>
	 <1206752049.22530.105.camel@johannes.berg>
	 <20080328.180631.91055366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xATTA5+q+/jrseKDTvel"
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40186 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbYC2KCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 06:02:37 -0400
In-Reply-To: <20080328.180631.91055366.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xATTA5+q+/jrseKDTvel
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[merging your two mails]

> The issue is that linkwatch goes: workqueue lock --> RTNL
>=20
> And thus taking workqueue lock within RTNL is deadlock
> prone no matter where you do it.

Which lock are you referring to here? There is no real runqueue lock
other than a spin-lock for the list. I think you may be misunderstanding
the lockdep output in a way I didn't anticipated when adding lockdep
debugging for workqueue stuff.

The actual work function is _not_ running with any locks held! The fact
that you see lockdep output there is because we tell lockdep we're
holding two locks, namely the "work" and the "workqueue". These are
fake, they aren't actually locks.

More importantly, those "locks" are locked and unlocked for every _run_
of the struct work function, not around the whole runqueue manipulation,
that part is done atomically without global locks.

So what you have is essentially
list_for_each_work
	lock(workqueue)
	lock(struct work)
	work->f();
	unlock(struct work)
	unlock(workqueue)

where both those locks are really only telling lockdep there are locks
to get it to warn about the deadlock scenario. Unfortunately Andrew
mangled the two patches into one when committing, so I can't point to
the changelog, but here are two links to the two patches adding this:
http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc1/2=
.6.23-rc1-mm2/broken-out/workqueue-debug-flushing-deadlocks-with-lockdep.pa=
tch
http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc1/2=
.6.23-rc1-mm2/broken-out/workqueue-debug-work-related-deadlocks-with-lockde=
p.patch

I think the "runqueue lock" you're referring to is the fake
"lock(workqueue)" which isn't around the whole runqueue manipulation but
only a lockdep helper to debug exactly the deadlock problem we're
talking about. I'm open to renaming it, but I don't think lockdep
supports formatting its output differently.

> I don't see how you can not race with the transition from
> scheduled to "executing" without taking the runqueue lock
> for the testing.

When you call cancel_work_sync(), the work struct will be grabbed by the
code (really __cancel_work_timer) and removed from the queue. That just
operates on bits and a spinlock, not locks held across the struct work
function execution, and ensures it is race-free without needing any such
locks.

> And it is crucial that the workqueue function doesn't
> execute "accidently" due to such a race before the module
> and thus the workqueue code is about to get potentially
> unloaded.

That is exactly what cancel_work_sync() guarantees, but not more. On
contrary, flush_workqueue() also guarantees that the work is run one
last time if it was scheduled at the time of the flush_workqueue() call.

However, as I just tried to explain, cancel_work_sync() _is_ safe to run
while holding the RTNL because it doesn't need any runqueue lock.

johannes

--=-xATTA5+q+/jrseKDTvel
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+4TsqVg1VMiehFYAQKOmxAAgMeblg283TInRDl9yRjTe4ywiEend+Fi
lLYvG6lyOkD3QFBYKKObx0+ERyg8Bq5GMSUZxkFOjaGA8QmhxuyLvmsm86ULAbQR
YqhASrmYKnvsQNQroGlHZCrYVGfW3IQ67M+yW8pWFXWJXingwVmMtO9g4y7T1hen
AB0HTOcLIQAZ8v9EVayuXCgfzSXF+xchBiUbEoH9iRHSj1/2tE406vjyxB9cCdcj
b+EEFINOAndUN6yd0M1KmHWp62GTn1kJqEwhCwfc9whEsvgDNqfxSBSlQhfF4WI5
3lT1IU1OopL4FUE9xOC0wyMNuvHOFVkSSfX2btarI4UX2G8Rs/VlIVQ3Od0MMDOk
dz1INLoANAjn9mA06QzP2DwlsqL303vJstXryIhffLGxBGVdEVTjSwKOZN2OXLCZ
I5jKNmE8UR4eMOAYSyy8MBb8Ih58X7LdYeuQlelo3bfhCQlOfn69SGSjQYSD0VoT
WiodM3LTsOsOD3ZAdOGp7RWQnHScIuCwz/E883j384FQZdKKEThpLBgcggzVVHHl
rxEVwB0aAZkR1mVvTu8ykV6GcbVyETkzFlWWg+xpnoNsQUUhmvTGNEpaY0RAmy/J
eNDMEEk6GXwHnQygtRoyiwhfEW7wAbqCTGA712rRb+27pQhlv4G/Qvjy0BAQHZVH
duHV+gNF3y8=
=IA6o
-----END PGP SIGNATURE-----

--=-xATTA5+q+/jrseKDTvel--

