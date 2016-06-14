From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 14 Jun 2016 11:30:00 +0200
Message-ID: <20160614093000.GB21689@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613130059.GA20320@sisyphus.home.austad.us>
 <20160613193208.GA2441@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BwCQnh7xodEAoBMC"
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160613193208.GA2441@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BwCQnh7xodEAoBMC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 13, 2016 at 09:32:10PM +0200, Richard Cochran wrote:
> On Mon, Jun 13, 2016 at 03:00:59PM +0200, Henrik Austad wrote:
> > On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
> > > Which driver is that?
> >=20
> > drivers/net/ethernet/renesas/
>=20
> That driver is merely a PTP capable MAC driver, nothing more.
> Although AVB is in the device name, the driver doesn't implement
> anything beyond the PTP bits.

Yes, I think they do the rest from userspace, not sure though :)

> > What is the rationale for no new sockets? To avoid cluttering? or do=20
> > sockets have a drawback I'm not aware of?
>=20
> The current raw sockets will work just fine.  Again, there should be a
> application that sits in between with the network socket and the audio
> interface.

So loop data from kernel -> userspace -> kernelspace and finally back to=20
userspace and the media application? I agree that you need a way to pipe=20
the incoming data directly from the network to userspace for those TSN=20
users that can handle it. But again, for media-applications that don't know=
=20
(or care) about AVB, it should be fed to ALSA/v4l2 directly and not jump=20
between kernel and userspace an extra round.

I get the point of not including every single audio/video encoder in the=20
kernel, but raw audio should be piped directly to alsa. V4L2 has a way of=
=20
piping encoded video through the system and to the media application (in=20
order to support cameras that to encoding). The same approach should be=20
doable for AVB, no? (someone from alsa/v4l2 should probably comment on=20
this)

> > Why is configfs wrong?
>=20
> Because the application will use the already existing network and
> audio interfaces to configure the system.

Configuring this via the audio-interface is going to be a challenge since=
=20
you need to configure the stream through the network before you can create=
=20
the audio interface. If not, you will have to either drop data or block the=
=20
caller until the link has been fully configured.

This is actually the reason why configfs is used in the series now, as it=
=20
allows userspace to figure out all the different attributes and configure=
=20
the link before letting ALSA start pushing data.

> > > Lets take a look at the big picture.  One aspect of TSN is already
> > > fully supported, namely the gPTP.  Using the linuxptp user stack and a
> > > modern kernel, you have a complete 802.1AS-2011 solution.
> >=20
> > Yes, I thought so, which is also why I have put that to the side and wh=
y=20
> > I'm using ktime_get() for timestamps at the moment. There's also the is=
sue=20
> > of hooking the time into ALSA/V4L2
>=20
> So lets get that issue solved before anything else.  It is absolutely
> essential for TSN.  Without the synchronization, you are only playing
> audio over the network.  We already have software for that.

Yes, I agree, presentation-time and local time needs to be handled=20
properly. The same for adjusting sample-rate etc. This is a lot of work, so=
=20
I hope you can understand why I started out with a simple approach to spark=
=20
a discussion before moving on to the larger bits.

> > > 2. A user space audio application that puts it all together, making
> > >    use of the services in #1, the linuxptp gPTP service, the ALSA
> > >    services, and the network connections.  This program will have all
> > >    the knowledge about packet formats, AV encodings, and the local HW
> > >    capabilities.  This program cannot yet be written, as we still need
> > >    some kernel work in the audio and networking subsystems.
> >=20
> > Why?
>=20
> Because user space is right place to place the knowledge of the myriad
> formats and options.

Se response above, better to let anything but uncompressed raw data trickle=
=20
through.

> > the whole point should be to make it as easy for userspace as=20
> > possible. If you need to tailor each individual media-appliation to use=
=20
> > AVB, it is not going to be very useful outside pro-Audio. Sure, there w=
ill=20
> > be challenges, but one key element here should be to *not* require=20
> > upgrading every single media application.
> >=20
> > Then, back to the suggestion of adding a TSN_SOCKET (which you didn't l=
ike,=20
> > but can we agree on a term "raw interface to TSN", and mode of transpor=
t=20
> > can be defined later? ), was to let those applications that are TSN-awa=
re=20
> > to do what they need to do, whether it is controlling robots or media=
=20
> > streams.
>=20
> First you say you don't want ot upgrade media applications, but then
> you invent a new socket type.  That is a contradiction in terms.

Hehe, no, bad phrasing on my part. I want *both* (hence the shim-interface)=
=20
:)

> Audio apps already use networking, and they already use the audio
> subsystem.  We need to help them get their job done by providing the
> missing kernel interfaces.  They don't need extra magic buffering the
> kernel.  They already can buffer audio data by themselves.

Yes, I know some audio apps "use networking", I can stream netradio, I can=
=20
use jack to connect devices using RTP and probably a whole lot of other=20
applications do similar things. However, AVB is more about using the=20
network as a virtual sound-card. For the media application, it should not=
=20
have to care if the device it is using is a soudncard inside the box or a=
=20
set of AVB-capable speakers somewhere on the network.

> > > * Kernel Space
> > >=20
> > > 1. Providing frames with a future transmit time.  For normal sockets,
> > >    this can be in the CMESG data.  For mmap'ed buffers, we will need a
> > >    new format.  (I think Arnd is working on a new layout.)
> >=20
> > Ah, I was unaware of this, both CMESG and mmap buffers.
> >=20
> > What is the accuracy of deferred transmit? If you have a class A stream=
,=20
> > you push out a new frame every 125 us, you may end up with=20
> > accuracy-constraints lower than that if you want to be able to state "s=
end=20
> > frame X at time Y".
>=20
> I have no idea what you are asking here.

I assumed that when you had a mmap'd buffer you'd have to specify a point=
=20
in time at which the frame should be sent. And since a class A has a 125us=
=20
interval of sending frames, you have to be able to send frames with enough=
=20
accuray to that. That's a pretty strict deadline coming from userspace. But=
=20
as they say, never assume.

I have a lot to dig into, and I've gotten a lot of very useful pointers. I=
=20
should be busy for a while

--=20
Henrik Austad

--BwCQnh7xodEAoBMC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldfzpgACgkQ6k5VT6v45llNyACg1S6RQAZXdtgThRcX3qXrR0UV
EH8AoKb4CquWIFkaIKv3fpPLxCKWR4na
=PTPK
-----END PGP SIGNATURE-----

--BwCQnh7xodEAoBMC--
