From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Tue, 24 Aug 2004 20:57:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824185703.GP26877@sunbeam.de.gnumonks.org>
References: <411C0FCE.9060906@crocetta.org> <1092401484.1043.30.camel@jzny.localdomain> <411CCB98.4080904@crocetta.org> <1092518370.2876.3.camel@jzny.localdomain> <20040816073530.GI15418@sunbeam2> <1092662998.2874.102.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OxpcHoRZqvs6WvX3"
Cc: sandr8@crocetta.org, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1092662998.2874.102.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OxpcHoRZqvs6WvX3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 16, 2004 at 09:29:59AM -0400, jamal wrote:
> > some later data.  It SHOULD not care whether this later data for the
> > same flow has bigger or smaller byte/packet counters. [and
> > it is very unlikely that the total will be lower, since then in the
> > timeframe [snapshot, terminations] more packets have to be dropped than
> > accepted.  Still, if this is documented with ctnetlink I'm perfectly
> > fine which such behaviour.
>=20
> I am too. Good stuff.
> I think 99.9% of accounting would be happy with getting data after the
> call is done; the other 0.01% may have to live with extra packets later
> which undo things.=20
> Are you working on something along the IPFIX protocol for transport?

Yes, I am working on the next generation of ulogd (ulogd-2).  It will
allow you to stack multiple plugins on top of each other, such as:

ctnetlink -> ipfix

or=20

ulog -> packet parser -> flow_aggrgation -> ipfix=20

or even exporting per-packet data in ipfix=20

ulog -> packet parser -> ipfix

It's far from complete, but I'm almost finished with the core and can
start to write the plugins:
http://svn.gnumonks.org/branches/ulog/ulogd2/

> Let me think about it.
> Clearly the best place to account for things is on the wire once the
> packet has left the box ;->=20

This is arguable.  Why not once the packet was receieved on the incoming
wire?  If you are Ingress router of your network, your ISP bills you for
the amout of traffic it sends to your ingress router.

OTOTH, for egress traffic I agree.

> How open are you to move accounting further down? My thoughts
> are along the lines of incrementing the contrack counters at the qdisc
> level. Since you transport after the structure has been deleted, it
> should work out fine and fair billing will be taken care of.

Sure, it can be done... but you need to grab ip_conntrack_lock in order
to do so.

> Has someone done experimented and figured how expensive it would be to
> do it at the qdisc level? Note, you can probably have a low level
> grained lock just for stats.

It doesn't help.  Currently we still have one global rwlock for all
conntrack's.  There are patches for per-bucket locking. =20

But well, as long as the usage count of ip_conntrack doesn't drop to
zero (which we're guaranteed since our skb still references it), and we
don't need to walk the hash table, we don't actually need to grab
ip_conntrack_lock.   A seperate accounting lock would be possible.

Somebody needs to implement this and run profiles...

> INC_STATS is generic (goes in the generic stats code in attached patch)
> and will have an ifdef for contrack billing (which includes unbilling
> depending on reason code). Reason code could be results that are now
> returned.
> As an example NET_XMIT_DROP is definetely unbilling while
> NET_XMIT_SUCCESS implies bill.=20

sounds fine to me.  But this basically means that we would hide
conntrack counters behind generic API - the counters themselves are
stored in our own data structure.

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

--OxpcHoRZqvs6WvX3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBK49/XaXGVTD0i/8RAh/fAJ9JZbKBMZlTS3f8WfMq+/tlPt0EQQCgspwE
6qpNZFQE59h2CBTfKOI2OoY=
=pyjO
-----END PGP SIGNATURE-----

--OxpcHoRZqvs6WvX3--
