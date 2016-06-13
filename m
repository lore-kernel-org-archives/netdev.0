From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 13 Jun 2016 15:00:59 +0200
Message-ID: <20160613130059.GA20320@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wRRV7LY7NUeQGEoC"
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	henrik@austad.us, Arnd Bergmann <arnd@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160613114713.GA9544@localhost.localdomain>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
> Henrik,

Hi Richard,

> On Sun, Jun 12, 2016 at 01:01:28AM +0200, Henrik Austad wrote:
> > There are at least one AVB-driver (the AV-part of TSN) in the kernel
> > already,
>=20
> Which driver is that?

drivers/net/ethernet/renesas/

> > however this driver aims to solve a wider scope as TSN can do
> > much more than just audio. A very basic ALSA-driver is added to the end
> > that allows you to play music between 2 machines using aplay in one end
> > and arecord | aplay on the other (some fiddling required) We have plans
> > for doing the same for v4l2 eventually (but there are other fishes to
> > fry first). The same goes for a TSN_SOCK type approach as well.
>=20
> Please, no new socket type for this.

The idea was to create a tsn-driver and then allow userspace to use it=20
either for media or for whatever else they'd like - and then a socket made=
=20
sense. Or so I thought :)

What is the rationale for no new sockets? To avoid cluttering? or do=20
sockets have a drawback I'm not aware of?

> > What remains
> > - tie to (g)PTP properly, currently using ktime_get() for presentation
> >   time
> > - get time from shim into TSN and vice versa
>=20
> ... and a whole lot more, see below.
>=20
> > - let shim create/manage buffer
>=20
> (BTW, shim is a terrible name for that.)

So something thin that is placed between to subystems should rather be=20
called.. flimsy? The point of the name was to indicate that it glued 2=20
pieces together. If you have a better suggestion, I'm all ears.

> [sigh]
>=20
> People have been asking me about TSN and Linux, and we've made some
> thoughts about it.  The interest is there, and so I am glad to see
> discussion on this topic.

I'm not aware of any such discussions, could you point me to where TSN has=
=20
been discussed, it would be nice to see other peoples thought on the matter=
=20
(which was one of the ideas behind this series in the first place)

> Having said that, your series does not even begin to address the real
> issues.=20

Well, in all honesty, I did say so :) It is marked as "very-RFC", and not=
=20
for being included in the kernel as-is. I also made a short list of the=20
most crucial bits missing.

I know there are real issues, but solving these won't matter if you don't=
=20
have anything useful to do with it. I decided to start by adding a thin=20
ALSA-driver and then continue to work with the kernel infrastructure.=20
Having something that works-ish makes it a lot easier to test and get=20
others interested in, especially when you are not deeply involved in a=20
subsystem.

At one point you get to where you need input from other more intimate with=
=20
then inner workings of the different subsystems to see how things should be=
=20
created without making too much of a mess. So where we are :)

My primary motivation was to
a) gather feedback (which you have provided, and for which I am very=20
   grateful)
b) get the discussion going on how/if TSN should be added to the kernel

> I did not review the patches too carefully (because the
> important stuff is missing), but surely configfs is the wrong
> interface for this.=20

Why is configfs wrong?

Unless you want to implement discovery and enumeration and srp-negotiation=
=20
in the kernel, you need userspace to handle this. Once userspace has done=
=20
all that (found priority-codes, streamIDs, vlanIDs and all the required=20
bits), then userspace can create a new link. For that I find ConfigFS to be=
=20
quite useful and up to the task.

In my opinion, it also makes for a much tidier and saner interface than=20
some obscure dark-magic ioctl()

> In the end, we will be able to support TSN using
> the existing networking and audio interfaces, adding appropriate
> extensions.

I surely hope so, but as I'm not deep into the networking part of the=20
kernel finding those appropriate extensions is hard - which is why we=20
started writing a standalone module-

> Your patch features a buffer shared by networking and audio.  This
> isn't strictly necessary for TSN, and it may be harmful.=20

At one stage, data has to flow in/out of the network, and whoever's using=
=20
TSN probably need to store data somewhere as well, so you need some form of=
=20
buffering at one place in the path the data flows through.

That being said, one of the bits on my plate is to remove the=20
"TSN-hosted-buffer" and let TSN read/write data via the shim_ops. What the=
=20
best set of functions where are, remain to be seen, but it should provide a=
=20
way to move data from either a single frame or a "few frames" to the shime=
=20
(err.. <descriptive word for a thin layer slapped between 2 largers=20
subsystems in the kernel> ;)

> The
> Listeners are supposed to calculate the delay from frame reception to
> the DA conversion.  They can easily include the time needed for a user
> space program to parse the frames, copy (and combine/convert) the
> data, and re-start the audio transfer.  A flexible TSN implementation
> will leave all of the format and encoding task to the userland.  After
> all, TSN will some include more that just AV data, as you know.

Yes, or a ALSA-driver capable of same task. But yes, you need a way to=20
propagate the presentation-time (and maybe a timestamp for when a frame was=
=20
received) to the final destination of the samples. As far as I've been able=
=20
to tell, this is not possible in the kernel at the moment.

> Lets take a look at the big picture.  One aspect of TSN is already
> fully supported, namely the gPTP.  Using the linuxptp user stack and a
> modern kernel, you have a complete 802.1AS-2011 solution.

Yes, I thought so, which is also why I have put that to the side and why=20
I'm using ktime_get() for timestamps at the moment. There's also the issue=
=20
of hooking the time into ALSA/V4L2

> Here is what is missing to support audio TSN:
>=20
> * User Space
>=20
> 1. A proper userland stack for AVDECC, MAAP, FQTSS, and so on.  The
>    OpenAVB project does not offer much beyond simple examples.

yes, I've noticed. I've refered to an imaginary 'tsnctl' in the code, which=
=20
is supposed to be a "userspace catch-all for TSN-housekeeping". You=20
probably need a tsnd or similar as well to send keepalive frames etc.

> 2. A user space audio application that puts it all together, making
>    use of the services in #1, the linuxptp gPTP service, the ALSA
>    services, and the network connections.  This program will have all
>    the knowledge about packet formats, AV encodings, and the local HW
>    capabilities.  This program cannot yet be written, as we still need
>    some kernel work in the audio and networking subsystems.

Why? the whole point should be to make it as easy for userspace as=20
possible. If you need to tailor each individual media-appliation to use=20
AVB, it is not going to be very useful outside pro-Audio. Sure, there will=
=20
be challenges, but one key element here should be to *not* require=20
upgrading every single media application.

Then, back to the suggestion of adding a TSN_SOCKET (which you didn't like,=
=20
but can we agree on a term "raw interface to TSN", and mode of transport=20
can be defined later? ), was to let those applications that are TSN-aware=
=20
to do what they need to do, whether it is controlling robots or media=20
streams.


> * Kernel Space
>=20
> 1. Providing frames with a future transmit time.  For normal sockets,
>    this can be in the CMESG data.  For mmap'ed buffers, we will need a
>    new format.  (I think Arnd is working on a new layout.)

Ah, I was unaware of this, both CMESG and mmap buffers.

What is the accuracy of deferred transmit? If you have a class A stream,=20
you push out a new frame every 125 us, you may end up with=20
accuracy-constraints lower than that if you want to be able to state "send=
=20
frame X at time Y".

> 2. Time based qdisc for transmitted frames.  For MACs that support
>    this (like the i210), we only have to place the frame into the
>    correct queue.  For normal HW, we want to be able to reserve a time
>    window in which non-TSN frames are blocked.  This is some work, but
>    in the end it should be a generic solution that not only works
>    "perfectly" with TSN HW but also provides best effort service using
>    any NIC.

Yes, that would be very nice, and something like that is the ultimate goal=
=20
of the netdev_ops I added, even though it is a far way away from that now.

> 3. ALSA support for tunable AD/DA clocks.  The rate of the Listener's
>    DA clock must match that of the Talker and the other Listeners.
>    Either you adjust it in HW using a VCO or similar, or you do
>    adaptive sample rate conversion in the application. (And that is
>    another reason for *not* having a shared kernel buffer.)  For the
>    Talker, either you adjust the AD clock to match the PTP time, or
>    you measure the frequency offset.

Yes, this is something missing that must be adressed. And yes, I know=20
sharing a buffer the way the alsa-shim is currently doing is bad.

> 4. ALSA support for time triggered playback.  The patch series
>    completely ignore the critical issue of media clock recovery.  The
>    Listener must buffer the stream in order to play it exactly at a
>    specified time.  It cannot simply send the stream ASAP to the audio
>    HW, because some other Listener might need longer.  AFAICT, there
>    is nothing in ALSA that allows you to say, sample X should be
>    played at time Y.
>=20
> These are some ideas about implementing TSN.  Maybe some of it is
> wrong (especially about ALSA), but we definitely need a proper design
> to get the kernel parts right.  There is plenty of work to do, but we
> really don't need some hacky, in-kernel buffer with hard coded audio
> formats.

Well, the hard-coded audio format you refer to is placed with the avb_alsa=
=20
shim, avtp_du is part of the actual TSN-header so that is not audio-only.=
=20
And yes, it must be separated.

Apart from requiring media-applications to know about AVB, I don't think=20
we really disagree on anything. As I said, the main motivation for=20
submitting this now was to kick off a discussion, get some critical=20
response (your email was awesome - thanks!) and start steering the=20
development in the right direction.

Regards,

--=20
Henrik Austad

--wRRV7LY7NUeQGEoC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlderosACgkQ6k5VT6v45llX+gCg6ZYf4zcATylvYG2RDhbUv/k5
OzwAoNSUTIRUKWqxXGf1Bb8tDg8meaSn
=Z1nI
-----END PGP SIGNATURE-----

--wRRV7LY7NUeQGEoC--
