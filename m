From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: lockdep trace from rc2.
Date: Mon, 25 Feb 2008 11:46:24 +0100
Message-ID: <1203936384.13162.77.camel@johannes.berg>
References: <20080225022237.GA3907@codemonkey.org.uk>
	 (sfid-20080225_030310_285221_71C3F1B9)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vJlE9+kA2kBjDDeid444"
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51743 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753960AbYBYKqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 05:46:31 -0500
In-Reply-To: <20080225022237.GA3907@codemonkey.org.uk> (sfid-20080225_030310_285221_71C3F1B9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vJlE9+kA2kBjDDeid444
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sun, 2008-02-24 at 21:22 -0500, Dave Jones wrote:
> https://bugzilla.redhat.com/show_bug.cgi?id=3D431038 has some more info,
> but the trace is below...
> I'll get an rc3 kernel built and ask the user to retest, but in case this
> isn't a known problem, I'm forwarding this here.

I can't fix it but I can explain it.

> Feb 24 17:53:21 cirithungol kernel: ip/10650 is trying to acquire lock:
> Feb 24 17:53:21 cirithungol kernel:  (events){--..}, at: [<c0436f9a>] flu=
sh_workqueue+0x0/0x85
> Feb 24 17:53:21 cirithungol kernel:=20
> Feb 24 17:53:21 cirithungol kernel: but task is already holding lock:
> Feb 24 17:53:21 cirithungol kernel:  (rtnl_mutex){--..}, at: [<c05cea31>]=
 rtnetlink_rcv+0x12/0x26
> Feb 24 17:53:21 cirithungol kernel:=20
> Feb 24 17:53:21 cirithungol kernel: which lock already depends on the new=
 lock.

What's happening here is that the linkwatch_work runs on the generic
schedule_work() workqueue.

> Feb 24 17:53:21 cirithungol kernel: -> #1 ((linkwatch_work).work){--..}:

The function that is called is linkwatch_event(), which acquires the
RTNL as you can see here:

> Feb 24 17:53:21 cirithungol kernel: -> #2 (rtnl_mutex){--..}:
> Feb 24 17:53:21 cirithungol kernel:        [<c04458f7>] __lock_acquire+0x=
a7c/0xbf4
> Feb 24 17:53:21 cirithungol kernel:        [<c05cea1d>] rtnl_lock+0xf/0x1=
1
> Feb 24 17:53:21 cirithungol kernel:        [<c04415dc>] tick_program_even=
t+0x31/0x55
> Feb 24 17:53:21 cirithungol kernel:        [<c0445ad9>] lock_acquire+0x6a=
/0x90
> Feb 24 17:53:21 cirithungol kernel:        [<c05cea1d>] rtnl_lock+0xf/0x1=
1
> Feb 24 17:53:21 cirithungol kernel:        [<c0638d21>] mutex_lock_nested=
+0xdb/0x271
> Feb 24 17:53:21 cirithungol kernel:        [<c05cea1d>] rtnl_lock+0xf/0x1=
1
> Feb 24 17:53:21 cirithungol kernel:last message repeated 2 times
> Feb 24 17:53:21 cirithungol kernel:        [<c05cf755>] linkwatch_event+0=
x8/0x22

The problem with that is that tulip_down() calls flush_scheduled_work()
while holding the RTNL:

> Feb 24 17:53:21 cirithungol kernel:        [<c0436f9a>] flush_workqueue+0=
x0/0x85
> Feb 24 17:53:21 cirithungol kernel:        [<c043702c>] flush_scheduled_w=
ork+0xd/0xf
> Feb 24 17:53:21 cirithungol kernel:        [<f8f4380a>] tulip_down+0x20/0=
x1a3 [tulip]
[...]
> Feb 24 17:53:21 cirithungol kernel:        [<c05cea3d>] rtnetlink_rcv+0x1=
e/0x26

(rtnetlink_rcv will acquire the RTNL)


The deadlock that can now happen is that linkwatch_work is scheduled on
the workqueue but not running yet. During tulip_down(),
flush_scheduled_work() is called which will wait for everything that is
scheduled to complete. Among those things could be linkwatch_event()
which will start running and try to acquire the RTNL. Because that is
already locked it will wait for the RTNL, but on the other hand we're
waiting for linkwatch_event() to finish while holding the RTNL.

The fix here would most likely be to not use flush_scheduled_work() but
rather cancel_work_sync().

This should be a correct change afaict, unless tulip has more work
structs than the media work.

@@ tulip_down
-	flush_scheduled_work();
+	cancel_work_sync(&tp->media_work);

johannes

--=-vJlE9+kA2kBjDDeid444
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8Kcf6Vg1VMiehFYAQLDTw/+LdWjbO9H+L3n3ap+94ASLvWvGMn7XBxA
G/36MNynSgF68Hrl6JYzx82FnSTxiXk3qdIwWRBbvLWTZ4sARBTO9XlBiwN79BHA
WKBKDlKnBwnlj8yD9Z9owHr/qnhDrkKrGE1dnfp2ftojOy6QRmpSoPkEqfr8Hmn3
7ArFid8okb4I4ghIN+hK6F2wlG1nQFOeWo8e58aN6uTTNvZ9arDjfmKfiM13tooE
ipOPS59KZ0dVZjujRCU7DbWHBF83R76EapKZtMJTDDTGHOpNqN04vLk4w8y31/09
/J6p/B01HxxQA/1sz2CLVFe9M71UCiYnsK7Y3wdFo41LOW3gSLzN/ZARES3+8mXx
1msAsomBwBdadV3ocoqHMtziSD4OE4YKylhJYDE0and04oTm++TZDZE3n4ktUoPa
Ez2fl8eA9iAmNCsVUd88ZrWzjfc6zcMUmpTDz9WcAM6FiNMBQslvDbxYDqjhI2nQ
M9430bFcRJ6fR+yXkaXlxvjuOx+snc43VfCwi4j541YqjXJ8sy3nQZUUB0s2F87Q
jg0a8r4p7ZA6CIPF0hEdZ5bHmMl3JPfzphnLQKJ8JAZmE6E0wIv3Br7Io2uLf4p1
FIRp7L3wRUA0vHmFaQ1ttat0KMTsY5qgEx5aOeMQWLPnv/1yOvWqmdkttUSo9hxE
9UDuJLWYoqo=
=QS/M
-----END PGP SIGNATURE-----

--=-vJlE9+kA2kBjDDeid444--

