From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Tue, 14 Dec 2004 10:58:37 +0300
Message-ID: <1103011117.3430.24.camel@uganda>
References: <Xine.LNX.4.44.0412140143010.30724-100000@thoron.boston.redhat.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aMNZjhWFP46+fE4KfCMG"
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0412140143010.30724-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-aMNZjhWFP46+fE4KfCMG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2004-12-14 at 01:56 -0500, James Morris wrote:
> On Mon, 1 Nov 2004, Evgeniy Polyakov wrote:
>=20
> [Sorry for taking so long to get back to this].
>=20
> > > c) Async engine: scheduling/batching/routing etc.
> > >=20
> > > This seems to be the core of what you've developed so far.  I'm not s=
ure=20
> > > if we need pluggable load balancers.  How would the sysadmin select t=
he=20
> > > correct one?  The simpler this code is the better.
> >=20
> > By following command:
> > echo -en "simple_lb" > /sys/class/crypto_lb/lbs
> > or by sending [still not implemented] connector's(netlink) command.
>=20
> The real question was how would the sysadmin know which is the best load=20
> balancer to configure.  Start simple, make one good load balancer, and=20
> ponly create a pluggable framework only if a demonstratable need arises.

By reading documentation which will be written some day...
If it has only SW crypto it does not need scheduler at all - only very
simple switch,
but if system has diferent kinds of HW crypto cards, and sysadmin knows
about it's
capabilities it can be better to turn more advanced scheduler on - for
example one=20
which can take packet size into account.
It will be a bit slower while searching needed device, but will have big
win=20
when doing actual crypto processing.

> > > Overall I think it's a good start.  There are some chicken & egg type=
=20
> > > problems when you don't have GPL drivers, hardware or an existing asy=
nc=20
> > > API, so I'd imagine that this will all continue to evolve:  with more=
=20
> > > hardware we can write/incorporate more drivers, with more drivers we =
can=20
> > > further refine the async support and API etc.
> >=20
> > That is true, but I think not all parts of API should be exported as GP=
L
> > only.
>=20
> Why do you think this?

In my current acrypto tree I export all symbols as GPL except
crypto_session_alloc().
Lets greedy scums use at least bits of new functionality. :)

>=20
> > > Here are some issues that I noticed:
> > >=20
> > >=20
> > > What is main_crypto_device?  Is this a placeholder for when there are=
 no=20
> > > other devices registered?
> >=20
> > main_crypto_device is just virtual device into which all sessions are
> > placed along with specific crypto device queue.
> > it is usefull for cases when some driver decides that HW is broken and
> > marks itself like not working, then scheduler _may_ (simple_lb does not
> > have such feature) and actually _should_ move all sessions that are
> > placed into broken device's queue into other devices or drop them(call
> > callback with special session flag).
>=20
> No reason to drop them, just fall back to software.

SW is just one of the crypto devices, consider emebedded system without=20
gigantic processor time which can be spent doing crypto processing.
Or if it is asymmetric crypto?
If SW exists and is loaded into acrypto it _will_ be called if needed.


> > > Async & sync drivers need to both be treated as crypto drivers.
> > >=20
> > >=20
> > > static inline void crypto_route_free(struct crypto_route *rt)
> > > {
> > >         crypto_device_put(rt->dev);
> > >         rt->dev =3D NULL;
> > >         kfree(rt);
> > > }
> > >=20
> > > Why do you set rt->dev to NULL here?  It should not still be referenc=
eable=20
> > > at this point.
> >=20
> > crypto_route_free() can be called only from crypto_route_del() which
> > unlinks given route thus noone can reference rt->dev(but of course
> > asnyone can have it's private copy, obtained under the lock).
> > Any route access is guarded by route list lock.
>=20
> No, if you're about to kfree(rt), you cannot also be able to dereference=20
> it.

I mean reference to device,  not route.
Crypto route in this point can be accessed only through crypto_route_del
().
Any routing _must_ be accessed _only_ by crypto_route_* functions from=20
crypto_route.h which are always performed with proper locking.

> > > __crypto_route_del() etc:
> > >=20
> > > Why are you rolling your own list management and not using the list.h=
=20
> > > functions?
> >=20
> > It is more convenient here to use queue like sk_buf does.
>=20
> Use list.h or put what you need into list.h.

list.h will never have struct sk_buff_head or any other queueing
primitives.
crypto_route is not a list, it is a queue.

> > > +struct crypto_device_stat
> > > +{
> > > +       __u64                   scompleted;
> > > +       __u64                   sfinished;
> > > ...
> > >=20
> > > Please see how networking stats are implemented (e.g. netif_rx_stats)=
 and=20
> > > previous netdev discussions on 64-bit counters.  Please only use __u6=
4 and=20
> > > similar when exporting structures to userspace.
> >=20
> > I use __ prefix for any parameter that is exported to userspace.
>=20
> But this structure is not.

struct crypto_device_stat
{
	__u64			scompleted;
	__u64			sfinished;
	__u64			sstarted;
	__u64			kmem_failed;
};

Probably version mismatch...

> > I've seen several attempts to convert network statistic to 64bit values=
,
> > with backward compatibility it is not an easy task. Let's do not
> > catch this again.
>=20
> To clarifu: the best way to do this is to use per-cpu counters of unsigne=
d
> long and add them together in userspace.

It is the fastest way sure,=20
current acrypto statistic code is not fast, it takes a stat lock to
guarantee
that fields are changed atomically since some (per
session_crypto_initializer )
of them are used in scheduler.

>=20
> - James
--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-aMNZjhWFP46+fE4KfCMG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBvp0tIKTPhE+8wY0RAu/MAJ9Iwicz9CTQ0kQ3eQXtLAVIFgvh9wCfSX/2
LeIoQyk3UWwdBI1B5lttMd4=
=EG9R
-----END PGP SIGNATURE-----

--=-aMNZjhWFP46+fE4KfCMG--
