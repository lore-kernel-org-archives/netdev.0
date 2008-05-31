From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 18:46:14 -0400
Message-ID: <1212273974.28319.107.camel@tng>
References: <20080526115628.GA31316@elte.hu>
	 <20080529084524.GA24892@elte.hu>
	 <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
	 <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu>
	 <20080531060947.GA26441@elte.hu>
	 <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>
	 <20080531125428.GA22111@elte.hu>
	 <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi>
	 <20080531163501.GB22607@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:41343 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbYEaWpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 18:45:54 -0400
In-Reply-To: <20080531163501.GB22607@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-05-31 at 18:35 +0200, Ingo Molnar wrote:
> * Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>=20

> > ...setsockopt(listenfd, SOL_TCP, TCP_DEFER_ACCEPT, &val, sizeof(val=
))=20
> > seems to be the magic trick that is interestion here.
>=20
> seems to be used:
>=20
>  22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) =3D 62
>  22003 listen(4, 10)                     =3D 0
>  22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) =3D 0
>=20
> i'll queue up your reverts for testing in -tip.


So the code you will revert came from my fingers. The circumstances her=
e
make me nervous; while I'm at a loss to explain what might be going on
in particular, let me offer an apology in advance should the revert hel=
p
resolve the issue.

Here's what makes me nervous:

 * not a lot of code uses DEFER_ACCEPT.. frankly it was pretty broken
before 26 - but not broken this way .. the correlation of your bug usin=
g
it is significant.=20

 * in 26, a server TCP socket (with DA) goes to ESTABLISHED when the 3r=
d
part of the handshake is received (as normal without DA), but the socke=
t
isn't put on the accept queue until a real data packet arrives. (That's
the point of DA). In <=3D 25 this socket would have syn-recv until the
data packet arrived.

  - I did run tests where the server died in between the handshake bein=
g
completed and first data packet arriving - the client should see RST an=
d
the server socket should disappear. But maybe something was missed?

Do I understand this correctly, the server process is gone but the
socket is still in the table? And the client process is still there
waiting for the server to do something - having sent a bunch of data?

Do we know if any data bytes (not handshake bytes) have been consumed b=
y
the server side? If they were, that would seem to vindicate DA.

Also pointing away from DA is that you started seeing this with rc3 -
that code was included in rc1.Is that a firm observation, or maybe ther=
e
weren't enough datapoints to conclude that rc1 and rc2 were clean?

The most interesting patch is ec3c0982a2dd1e671bad8e9d26c28dcba0039d87
if anyone wants to eyeball it.



=20

