From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Mon, 16 Aug 2004 09:35:30 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040816073530.GI15418@sunbeam2>
References: <411C0FCE.9060906@crocetta.org> <1092401484.1043.30.camel@jzny.localdomain> <411CCB98.4080904@crocetta.org> <1092518370.2876.3.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CjAlqr6ZqJYkDGFX"
Cc: sandr8@crocetta.org, devik@cdi.cz, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1092518370.2876.3.camel@jzny.localdomain>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--CjAlqr6ZqJYkDGFX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 14, 2004 at 05:21:31PM -0400, jamal wrote:

> > the conntrack stuff (actually that little part of code that adds=20
> > unbilling to ACCT in case of a drop) is something that comes later=20
> > (patch 4) and is not in the pkt sched part. please, don't let it=20
> > divert your mind from the real point. just forget it for the moment...
> >  [in any case it is _not_ in the pkt sched area and as i said in mail=
=20
> > 4/4 i don't like to put the variables into dev.c, that's why i am=20
> > there asking for alternatives]
>=20
> This actually seems to be the core issue.=20
> Correct me if i misunderstood what you are trying to achieve:=20
> Somewhere above, the netfilter code bills some packet. Packet gets=20
> all the way to the scheduler on egress.
> Scheduler drops packet although it has been billed already.
> You being a man looking for justice ;-> decides that was unfair and
> you are trying to undo it. Is this accurate?

Yes, that's how I understoo Allesandro's efforts.  While I don't think
it's worth being that precise (and rather change the definition of what
is being accounted to 'number of packets/bytes recevived in this flow').

> Also is their a corrective factor that happens once the _accounting_=20
> data has been shipped? Example:=20
> - account for packet
> - ship accounting data to some billing server
> - oops, unbill
> - what now?=20

Yes, this is a race condition.  However, I don't this is not very likely
to occurr, since the accounting data is by default only sent to
userspace via ctnetlink once the connection tracking entry is deleted.

Yes, you can read it while the connection is still alive, but this will
not reset/update the counters, but rather give you a current snapshot.
If you send this to your accounting server, the accounting server has to
cope with the fact that this intermediate snapshot can be updated by
some later data.  It SHOULD not care whether this later data for the
same flow has bigger or smaller byte/packet counters. [and
it is very unlikely that the total will be lower, since then in the
timeframe [snapshot, terminations] more packets have to be dropped than
accepted.  Still, if this is documented with ctnetlink I'm perfectly
fine which such behaviour.

> BTW, what happens if you clone the packet below netfilter and send
> several copies of it possibly over several different interfaces? This
> may happen with tc extensions.

oh yes, I think somebody has written a similar iptables target, too. I'm
not sure whether there is a good solution for the 'unbill' feature.  Do
you have any thoughts/recommendations for this?

> I think accounting is important - especially if it is almost free with
> contracking.

Totally agreed. =20

The reason for not delaying accounting update until qdisc has happened
is locking.  Then we would have to re-grab the conntrack write lock to
make the counter update... whrereas in my patch counter updates happen
while we are already under write lock for the timer/timeout update.

> Lets talk about this issue first instead of confusing it with everything
> else you have in other patches.

Also, if this 'unbill' feature gets into the kernel in some form, I
would definitely make it a CONFIG_ or sysctl... after all people could
be interested in the Rx side only...
=20
> cheers,
> jamal

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--CjAlqr6ZqJYkDGFX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBIGPCXaXGVTD0i/8RAuBqAJwMLWyrXpq50hxNF2yjkltUjau+xwCfeZWc
A2CGgAmva/zqWXH3/lrWzeg=
=Hddh
-----END PGP SIGNATURE-----

--CjAlqr6ZqJYkDGFX--
