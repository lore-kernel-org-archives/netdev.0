From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Asynchronous crypto layer.
Date: Mon, 01 Nov 2004 08:12:52 +0300
Message-ID: <1099285972.5070.24.camel@uganda>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	 <20041030203550.GB6256@gate.ebshome.net>
	 <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
	 <20041030205630.GD6256@gate.ebshome.net>
	 <20041031012423.74b98698@zanzibar.2ka.mipt.ru>
	 <1099179687.1041.117.camel@jzny.localdomain>
	 <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>
	 <1099234559.1040.183.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-d3KlxGogRmLVGVXJBu/E"
Cc: netdev@oss.sgi.com, cryptoapi@lists.logix.cz,
        Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099234559.1040.183.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-d3KlxGogRmLVGVXJBu/E
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2004-10-31 at 17:56, jamal wrote:
> On Sun, 2004-10-31 at 04:13, Evgeniy Polyakov wrote:
> > On 30 Oct 2004 19:41:27 -0400
> > jamal <hadi@cyberus.ca> wrote:
>=20
> > > Can you explain the "rate" or "speed" parameter ?
> >=20
> > Driver writer can set "rate" parameter to any number from 0 to 64k -
> > and it will show speed of this driver in current mode/type/operation.
> [..]
> >=20
> > That mean that this driver perform des 6 time faster than aes, but=20
> > it should be fair numbers and somehow measured and compared to other
> > drivers.
> >=20
>=20
> So you have some init code that does testing? Or is this factor of six
> part of the spec provided by chip vendor?

Chip vendor, but what if vendor lies or it was measured in a different
setup than other vendor?
And what about software speeds?

> > This also can be achieved by qlen parameter - if driver writer sets
> > it to bigger walue then in this mode driver/hardware works faster.
> > But driver writer can set qlen in a too big value just because
> > it want it to be such without any means of driver/hardware capabilities=
.
> > It is not forbidden.
> >=20
>=20
> It is no different than say the way you will do ethernet drivers.
> DMA ring sizes and link speeds. harder for ethernet drivers if link
> speeds change (Linux net scheduling assumes fixed speed ;->)
>=20
> > And the last and the most interesting one is following:
> > we create per session initialiser parameter "session_processin_time"=20
> > which will be sum of the time slices when driver performed operation=20
> > on session, since we alredy has "scomplete" paramenter which is equal=20
> > to the amount of completed(processed) session then we have _fair_ speed=
=20
> > of the driver/hardware in a given mode/operation/type.
> >=20
> > Of course load blancer should select device with the lowest
> > session_processing_time/scompleted.
> >=20
> > I think third variant is what we want. I will think of it some more
> > and will implement soon.
> >=20
>=20
> I think you should be able to have multiple, configurable LB algos.

Second is already implemented.
Third I posted to my TODO.
Should we add "rate" or will use "qlen" instead?

> > > I havent studied your code, however, what Eugene is pointing out is
> > > valuable detail/feedback.
> > >
> > > You should have in your queuing towards the crypto chip ability to
> > > batch. i.e sort of nagle-like "wait until we have 10 packets/20KB or =
20
> > > jiffies" before you send everything in the queue to the chip.
> >=20
> > That is exactly how crypto driver should be written.
> > Driver has it's queue and number of session in it, so it and only it
> > can decide when begin to process them in the most effective way.
> >=20
>=20
> This should be above driver, really.
> =20
> You should have one or more queues where the scheduler feeds off and
> shoves to hardware. Perhaps several levels:

There are already several queues - one per crypto device.
Scheduler decides what device should handle given session,=20
and put session into selected device's queue and calls ->data_ready()
device's callback.
It is device that can handle several session per one "travel" of it's
queue.
Or do you say that scheduler can hold session until number of such
session becomes more than threshold and then post them at once to some
device's queue?
Why it is needed? That can be implemented easily by splitting
crypto_session_alloc() into two parts like James sugests, but I do not
see a reason for it. What if no session will be allocated in the near
future? Then first session will sit in a vacuum for a long while it=20
could be already processed even non effectively.

> ->LB-+
>      +-> device1 scheduler --> driver queues/rings.
>      |
>      |
>      +-> device2 scheduler --> driver queues/rings.
>      |
>      .
>      .
>      +-> devicen scheduler --> driver queues/rings.
>=20
> If you look at the linux traffic control, the stuff below LB is how it
> behaves. That should be generic enough to _not_ sit in the driver.
> This allows for adding smart algorithms to it; fe: qos, rate limiting,
> feedback to LB so it could make smarter decisions etc.

It does not sit in the driver.
Ethernet device has hard_start_xmit() which takes only one skb just
because hardware can not handle several packets at once.
Crypto devices [often] have ability to handle several sessions at once,=20
that is why struct crypto_device has queue from which device can take
sessions more than one in a time.

Sessions are placed into device's queue by scheduler which has some
algorithms inside(like qos), but then driver can get one session and
process it - thus it will looks like netdevice, but it also can take
several sessions and process them at once, netdev just can not do it.

> > > As he points out (and i am sure he can back it with data ;->), that
> > > given the setup cost, packet size, algo and CPU and bus speed, it may
> > > not make sense to use the chip at all ;->
> >=20
> > Michal has numbers - pure hardware beats soft in a certain setups
> > in a fully synchronous schema, let's work SW and HW in parallel.
> >=20
> > Of course SW can encrypt 64 byte faster than it will be transfered to
> > old ISA crypto card, but it worth to do it for compressing with LZW
> > 9000 bytes jumbo frame.
> >=20
>=20
> Would be interesting. I have seen the numbers from Eugene and they are=20
> quiet intriguing - but they are for the sync mode.
>=20
> cheers,
> jamal
>=20

--=20
	Evgeniy Polyakov

Crash is better than data corruption. -- Art Grabowski

--=-d3KlxGogRmLVGVXJBu/E
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBhcXUIKTPhE+8wY0RAkyXAKCYOKSW1z2BSFoG0iqhE2tfLqxPHACgkWkO
XndqZ9iwcg25jNPlIdVmgdE=
=JUJe
-----END PGP SIGNATURE-----

--=-d3KlxGogRmLVGVXJBu/E--
