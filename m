From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Mon, 01 Nov 2004 08:58:59 +0300
Message-ID: <1099288738.5070.71.camel@uganda>
References: <Xine.LNX.4.44.0410311004290.677-100000@thoron.boston.redhat.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-J8oT7NTdkDfCwwhXz2hs"
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0410311004290.677-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-J8oT7NTdkDfCwwhXz2hs
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2004-10-31 at 19:05, James Morris wrote:
> > Please review and comment, I am open for discussion.
>=20
> Here is an initial review, based on the updated patch posted my Michael=20
> Ludwig.
>=20
> It's great to see this code being written rather than just discussed.
>=20
> Have you seen earlier discussions on hardware crypto requirements, some o=
f
> which are summarized at http://samba.org/~jamesm/crypto/hardware_notes.tx=
t
> , and further discussed on the cryptoapi list?

Yes, I have read it and many others.
I believe I've gathered all usefull features and implement them in a
right direction.

> Briefly, the main components required for hardware crypto support are:
>=20
> a) Crypto driver API
>=20
> This is for registering all types of crypto drivers, including the
> software algorithms and various hardware devices.  A feature of this API
> would be to communicate various capabilities and features of the driver t=
o
> the core crypto code.  Your code appears to at least partially provide
> such an API, although I'm not clear on exactly what it's suitable for all
> types of crypto drivers.  It looks to be heading in the right direction.
>=20
> The existing software drivers should be converted to the new API and the=20
> old API removed.

Or we can create some kind of bridge between old sync codebase and new
async API. Peaple are using sync API, async can live with it without
problems.

> b) Kernel crypto API
>=20
> This refers to the API used by general kernel code which needs to invoke
> crypto processing.  Currently we have a simple synchronous API.
>=20
> For hardware support we need an asynchronous API, which for example, woul=
d=20
> allow a caller to:
>=20
>  - allocate a crypto session, specifying preferences, algorithms to be=20
>    used etc.
>  - manage crypto session parameters (e.g. key info etc).
>  - batch and submit crypto operations
>  - receive completed operation results

I've put first tree into one function crypto_session_alloc(), although
there are mechanisms to manage crypto session after it is allocated.

> I would imagine that we would deprecate the existing sync API, convert=20
> existing users to the async API then eventually remove the sync API.
>=20
> This areas needs more analysis and development.
>=20
>=20
> c) Async engine: scheduling/batching/routing etc.
>=20
> This seems to be the core of what you've developed so far.  I'm not sure=20
> if we need pluggable load balancers.  How would the sysadmin select the=20
> correct one?  The simpler this code is the better.

By following command:
echo -en "simple_lb" > /sys/class/crypto_lb/lbs
or by sending [still not implemented] connector's(netlink) command.

>=20
> d) User API via filesystem.
>=20
> The user API issue has been discussed on the crypto API list previously. =
=20
> I have outlined some ideas for a pseudo filesytem API, although there are=
=20
> still some issues to be resolved.
>=20
>=20
> Overall I think it's a good start.  There are some chicken & egg type=20
> problems when you don't have GPL drivers, hardware or an existing async=20
> API, so I'd imagine that this will all continue to evolve:  with more=20
> hardware we can write/incorporate more drivers, with more drivers we can=20
> further refine the async support and API etc.

That is true, but I think not all parts of API should be exported as GPL
only.

> Code Review.
>=20
> Firstly, please follow Documentation/CodingStyle more closely.  Perhaps=20
> run Lindent over your code and have a look at the differences.

I waited this :)

> It's much easier to review and test the code if it is supplied as a patch
> against a recent Linus kernel, rather than a collection of files.  If you=
=20
> update your tree, please regenerate the patch rather than just send new=20
> files.

Sure. Files were sent for review, since they can be compiled as stand
alone module.

>=20
> Here are some issues that I noticed:
>=20
>=20
> What is main_crypto_device?  Is this a placeholder for when there are no=20
> other devices registered?

main_crypto_device is just virtual device into which all sessions are
placed along with specific crypto device queue.
it is usefull for cases when some driver decides that HW is broken and
marks itself like not working, then scheduler _may_ (simple_lb does not
have such feature) and actually _should_ move all sessions that are
placed into broken device's queue into other devices or drop them(call
callback with special session flag).
It is also usefull for the following situation:
consider situation when several slow devices has it's queues with some
sessions in it, then we add new fast crypto device, bu there are no new
sessions that can be pleced into it. Scheduler may decide to move
sessions from different slow device into new fast one.
All above cases can be easier to implement if we already have one queue
with all sessions in it, and scheduler should not go through all crypto
device's queues.

> Async & sync drivers need to both be treated as crypto drivers.
>=20
>=20
> static inline void crypto_route_free(struct crypto_route *rt)
> {
>         crypto_device_put(rt->dev);
>         rt->dev =3D NULL;
>         kfree(rt);
> }
>=20
> Why do you set rt->dev to NULL here?  It should not still be referenceabl=
e=20
> at this point.

crypto_route_free() can be called only from crypto_route_del() which
unlinks given route thus noone can reference rt->dev(but of course
asnyone can have it's private copy, obtained under the lock).
Any route access is guarded by route list lock.

>=20
> __crypto_route_del() etc:
>=20
> Why are you rolling your own list management and not using the list.h=20
> functions?

It is more convenient here to use queue like sk_buf does.

>=20
> +struct crypto_device_stat
> +{
> +       __u64                   scompleted;
> +       __u64                   sfinished;
> ...
>=20
> Please see how networking stats are implemented (e.g. netif_rx_stats) and=
=20
> previous netdev discussions on 64-bit counters.  Please only use __u64 an=
d=20
> similar when exporting structures to userspace.

I use __ prefix for any parameter that is exported to userspace.
I've seen several attempts to convert network statistic to 64bit values,
with backward compatibility it is not an easy task. Let's do not
catch this again.

> Struct ordring:
>=20
> +       u16                     priority;
> +
> +       u64                     id;
> +       u64                     dev_id;
> +
> +       u32                     flags;
>=20
> The struct will be better aligned if you put the smaller fields first
> (although there may be cases where you want cache-hot items at the front)=
. =20
> Also, why the gaps between fields?
>=20

All they are created with cache alignment in mind - above cut is
following:
struct crypto_session_initializer
{
	u16			operation;
	u16			type;
	u16			mode;
	u16			priority;

	u64			id;
	u64			dev_id;

	u32			flags;

	u32			bdev;

	crypto_callback_t	callback;
};

>=20
> __crypto_device_add():
>=20
> Please split device initialization and linking into distinct functions. =20
> The initialization should probably be done in e.g. crypto_device_alloc()=20
> instead of this.

No problem. I gave it such name since __crypto_device_add() is called
only from crypto_device_add() (and main_crypto_device initialisation
routing).

> +       struct crypto_device *__dev, *n;
>=20
> Please use a name other than __dev here.  Underscored variable names are=20
> generally used for things like local variables in macros, not local=20
> temporary variables in functions.

Ok.

> void crypto_device_remove(struct crypto_device *dev):
>=20
> Don't loop waiting for the device to become free.  Also, you're schedulin=
g=20
> inside a spinlock.  This code needs to be re-thought in general to ensure=
=20
> that a device is always destroyed safely.

No, lock is already freed there.
The sequence is following:
grab the lock.
search given device
unlink it
free the lock // after it nobody can add new sessions to the given
device
wait until device becomes free - it should be called from device's
module_exit() function, thus we are in a process context.
while waiting(device finishes it's sessions processing) we
reschedule itself.
return.

> crypto_lb_unregister():
>=20
> I think this has already been raised.  Please don't do things like this. =
=20
> I'm not sure we need loadable load balancers yet, although in any case,=20
> if we always need one loaded, then make a default one that cannot be=20
> unloaded or replaces the last lb.

We have several IO schedulers.
I believe different hardware setups will requere different load
balancers - for example for setups with only fast devices we can use
just simple_lb, for setups with mixed devices we need to think of
session moving between them.

Simple_lb is fast but it does not have some features, advanced1_lb for
example can have some tricky algorithm to select crypto device and/or=20
have some thoughts about session moving...

But I think that we need one unloadable crypto load balancer which will
be used if all others are removed/unused.

I add it to my TODO.

>=20
> Where is crypto_session_alloc() used?  It's difficult to evaluate the cod=
e
> more deeply without seeing such primitives in use.

I've sent several files in a first e-mail that are called like=20
consumer.c slow_consumer.c - it is crypto consumers, actually they=20
just call crypto_session_alloc() with appropriate parameters...

>=20
> Thanks for doing this work and hope this helps,

Thank you.

>=20
> - James
--=20
	Evgeniy Polyakov

Crash is better than data corruption. -- Art Grabowski

--=-J8oT7NTdkDfCwwhXz2hs
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBhdCiIKTPhE+8wY0RAnh5AJ9tyXyDCND/xMEbG/uPixri6XK7ywCeMBRk
tFQnfpAjZ8DJ5R2Vg+t4wcM=
=Qqax
-----END PGP SIGNATURE-----

--=-J8oT7NTdkDfCwwhXz2hs--
