From: Henrik Austad <henrik@austad.us>
Subject: Re: [TSN RFC v2 0/9] TSN driver for the kernel
Date: Sat, 17 Dec 2016 10:05:54 +0100
Message-ID: <20161217090554.GA19737@icarus.home.austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
 <20161216220530.GA25258@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="k+w/mQv8wyuph6w0"
Cc: linux-kernel@vger.kernel.org, Henrik Austad <haustad@cisco.com>,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161216220530.GA25258@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Richard,

On Fri, Dec 16, 2016 at 11:05:30PM +0100, Richard Cochran wrote:
> On Fri, Dec 16, 2016 at 06:59:04PM +0100, henrik@austad.us wrote:
> > The driver is directed via ConfigFS as we need userspace to handle
> > stream-reservation (MSRP), discovery and enumeration (IEEE 1722.1) and
> > whatever other management is needed.
>=20
> I complained about configfs before, but you didn't listen.

Yes you did, I remember quite well, and no, I didn't listen :)

At the time, there were other issues that I had to address. The=20
configfs-part is fairly isolated. As I tried to explain the last round,=20
the *reason* I've used ConfigFS thus far, is because it makes it pretty=20
easy from userspace to signal the driver to create a new alsa-device.

And the reason I haven't changed configfs, is because so far, that part has=
=20
worked fairly well and have made testing quite easy. At this stage, *this*=
=20
is what is helpful, not a perfect interface. This does not mean that=20
configfs is set in stone.

To clearify:
I'm sending out a new set now because, what I have works _fairly_ well for=
=20
testing and a way to see what you can do with AVB. Using spotify to play=20
music on random machines is quite entertaining.

It is by no means -done-, nor do I consider it done. I have been tight on=
=20
time, and instead of sitting in an office polishing on some code, I thought=
=20
it better to send out a new (and not done) set of patches so that others=20
could see it still being worked on. If this turned out to be noise-only, I=
=20
appologize!

> > 2 new fields in netdev_ops have been introduced, and the Intel
> > igb-driver has been updated (as this an AVB-capable NIC which is
> > available as a PCI-e card).
>=20
> The igb hacks show that you are on the wrong track.  We can and should
> be able to support TSN without resorting to driver specific hacks and
> module parameters.

I was not able to find a sane way to change the mode of the NIC, some of=20
the settings required to enable Qav-mode must be done when bringing the=20
NIC up, so I needed hooks in _probe().

ANother elemnt needed is a way for tsn_core to ascertain if a NIC is=20
capable of TSN or not (this would be ndo_tsn_capable)

Then finally, you need to update values in a per-tx-queue manner when a new=
=20
stream is ready (hence ndo_tsn_link_configure).

What you mean by 'driver specific hacks' is not obvious though, TSN=20
requires a set of fairly standardized parameters (priority code points,=20
size of frames to send in a new stream and so on), adding this to the=20
hw-registers in the NIC is an operation that will be common for all=20
TSN-capable NICs.

> > Before reading on - this is not even beta, but I'd really appreciate if
> > people would comment on the overall architecture and perhaps provide
> > some pointers to where I should improve/fix/update
>=20
> As I said before about V1, this architecture stinks.=20

I like feedback when it's short, sweet and to the point
2 out of 3 ain't that bad ;)

> You appear to have continued hacking along and posted the same design=20
> again.  Did you even address any of the points I raised back then?

So you did raise a lot of good points the last round, and no, I have not=20
had the time to address them properly. That does not mean I do not *want*=
=20
to (apart from configfs actually having worked quite nicely thus far and=20
'shim' being a name I like ;)

=46rom the last round of discussion:

> 1. A proper userland stack for AVDECC, MAAP, FQTSS, and so on.  The
>    OpenAVB project does not offer much beyond simple examples.

Yes, I fully agree, as far as I know, no-one is working on this. That being=
=20
said, I have not paid much attention the userspace tooling lately. But all=
=20
of this must be handled in userspace, having avdecc in the kernel would be=
=20
an utter nightmare :)

> 2. A user space audio application that puts it all together, making
>   use of the services in #1, the linuxptp gPTP service, the ALSA
>   services, and the network connections.  This program will have all
>   the knowledge about packet formats, AV encodings, and the local HW
>   capabilities.  This program cannot yet be written, as we still need
>   some kernel work in the audio and networking subsystems.

And therein lies the problem. It cannot yet be written, so we have to start=
=20
in *some* end. And as I repeatedly stated in June, I'm at an RFC here,=20
trying to spark some interest and lure other developers in :)

Also, I really do not want a media-application to care about _where_ the=20
frames are going. Sure, I see the issue of configuring a link, but that can=
=20
be done from _outside_ the media-application. VLC (or aplay, or totem, or=
=20
=2E. take your pick) should not have to worry about this.

Applications that require finer control over timestamping is easier to=20
adapt to AVB than all the others, I'd rather add special knobs for those=20
who are interested than adding a set of knobs that -all- applications must=
=20
be aware of.

Could be that we are talking about the same thing, just from different=20
perspectives.

> * Kernel Space
>
> 1. Providing frames with a future transmit time.  For normal sockets,
>    this can be in the CMESG data.  For mmap'ed buffers, we will need a
>    new format.  (I think Arnd is working on a new layout.)

I need to revisit that discussion again I think.

> 2. Time based qdisc for transmitted frames.  For MACs that support
>    this (like the i210), we only have to place the frame into the
>    correct queue.  For normal HW, we want to be able to reserve a time
>    window in which non-TSN frames are blocked. This is some work, but
>    in the end it should be a generic solution that not only works
>    "perfectly"  with TSN HW but also provides best effort service using
>    any NIC.

Yes, indeed, that would be one good solution, and quite a lot of work.

> 3. ALSA support for tunable AD/DA clocks.  The rate of the Listener's
>    DA clock must match that of the Talker and the other Listeners.

To nitpick a bit, all AD/DAs should match that of the gPTP grandmaster=20
(which in most settings would be the Talker). But yes, you need to adjust=
=20
the AD/DA. SRC is slow and painful, best to avoid.

>    Either you adjust it in HW using a VCO or similar, or you do
>    adaptive sample rate conversion in the application. (And that is
>    another reason for *not* having a shared kernel buffer.)  For the
>    Talker, either you adjust the AD clock to match the PTP time, or
>    you measure the frequency offset.

Yes, some hook into adjusting the clock is needed, I wonder if this is=20
possible via V4L2, or of the monitor-world is a completely different beast.

> 4. ALSA support for time triggered playback.  The patch series
>    completely ignore the critical issue of media clock recovery.  The=20
>    Listener must buffer the stream in order to play it exactly at a=20
>    specified time. It cannot simply send the stream ASAP to the audio=20
>    HW, because some other Listener might need longer.  AFAICT, there is=
=20
>    nothing in ALSA that allows you to say, sample X should be played at=
=20
>    time Y.

Yes, and this requires a lot of change to ALSA (and probably something in=
=20
V4L2 as well?), so before we get to that, perhaps have a set of patches=20
that does this best effort and *then* work on getting time-triggered=20
playback into the kernel?

Another item that was brought up last round was getting timing-information=
=20
to/from ALSA, See driver/media/avb/avb_alsa.c, as a start it updates the=20
time for last incoming/outgoing frame so that userspace can get that=20
information. Probably buggy as heck :)

* Back to your email from last night*

> You are trying to put tons of code into the kernel that really belongs
> in user space, and at the same time, you omit critical functions that
> only the kernel can provide.

Some (well, to be honest, most) of the of the critical functions that my=20
driver omits, are omitted because they require substantial effort to=20
implement - and befor there's a need for this, that won't happen. So,=20
consider the TSN-driver such a need!

I'd love to use a qdisc that uses a time-triggered transmit, that would=20
drop the need for a lot of the stuff in tsn_core.c. The same goes for=20
time-triggered playback in media.

> > There are at least one AVB-driver (the AV-part of TSN) in the kernel
> > already.
>=20
> And which driver is that?

Ah, a proverbial slip of the changelog, we visited this the last iteration,=
=20
that would be the ravb-driver (which is an AVB capable NIC), but it does=20
not include much in the way of AVB-support *In* kernel. Sorry about that!

Since then, the iMX7 from NXP has arrived, and this also has HW-support for=
=20
TSN, but not in the kernel AFAICT.

So, the next issue I plan to tackle, is how I do buffers, the current=20
approach where tsn_core allocates memory is on its way out and I'll let the=
=20
shim (which means alsa/v4l2) will provide a buffer. Then I'll start looking=
=20
at qdisc.

Thanks!

--=20
Henrik Austad

--k+w/mQv8wyuph6w0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhU//IACgkQ6k5VT6v45lmROACcDMFU9d+2qzl3YOPAeMrIzBiu
bOgAn3cTKKUvHnJEkXdK4BbgGKIgjGXA
=1LBw
-----END PGP SIGNATURE-----

--k+w/mQv8wyuph6w0--
