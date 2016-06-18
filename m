From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Sun, 19 Jun 2016 00:45:50 +0200
Message-ID: <20160618224549.GF32724@icarus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kR3zbvD4cgoYnS/6"
Cc: Richard Cochran <richardcochran@gmail.com>,
	alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@linaro.org>,
	linux-media@vger.kernel.org
To: Takashi Sakamoto <o-takashi@sakamocchi.jp>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5764DA85.3050801@sakamocchi.jp>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--kR3zbvD4cgoYnS/6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 18, 2016 at 02:22:13PM +0900, Takashi Sakamoto wrote:
> Hi,

Hi Takashi,

You raise a lot of valid points and questions, I'll try to answer them.

edit: this turned out to be a somewhat lengthy answer. I have tried to=20
shorten it down somewhere. it is getting late and I'm getting increasingly=
=20
incoherent (Richard probably knows what I'm talking about ;) so I'll stop=
=20
for now.

Plase post a follow-up with everything that's not clear!
Thanks!

> Sorry to be late. In this weekday, I have little time for this thread
> because working for alsa-lib[1]. Besides, I'm not full-time developer
> for this kind of work. In short, I use my limited private time for this
> discussion.

Thank you for taking the time to reply to this thread then, it is much=20
appreciated

> On Jun 15 2016 17:06, Richard Cochran wrote:
> > On Wed, Jun 15, 2016 at 12:15:24PM +0900, Takashi Sakamoto wrote:
> >>> On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
> >>>> I have seen audio PLL/multiplier chips that will take, for example, a
> >>>> 10 kHz input and produce your 48 kHz media clock.  With the right HW
> >>>> design, you can tell your PTP Hardware Clock to produce a 10000 PPS,
> >>>> and you will have a synchronized AVB endpoint.  The software is all
> >>>> there already.  Somebody should tell the ALSA guys about it.
> >>
> >> Just from my curiosity, could I ask you more explanation for it in ALSA
> >> side?
> >=20
> > (Disclaimer: I really don't know too much about ALSA, expect that is
> > fairly big and complex ;)
>=20
> In this morning, I read IEEE 1722:2011 and realized that it quite
> roughly refers to IEC 61883-1/6 and includes much ambiguities to end
> applications.

As far as I know, 1722 aims to describe how the data is wrapped in AVTPDU=
=20
(and likewise for control-data), not how the end-station should implement=
=20
it.

If there are ambiguities, would you mind listing a few? It would serve as a=
=20
useful guide as to look for other pitfalls as well (thanks!)

> (In my opinion, the author just focuses on packet with timestamps,
> without enough considering about how to implement endpoint applications
> which perform semi-real sampling, fetching and queueing and so on, so as
> you. They're satisfied just by handling packet with timestamp, without
> enough consideration about actual hardware/software applications.)

You are correct, none of the standards explain exactly how it should be=20
implemented, only what the end result should look like. One target of this=
=20
collection of standards are embedded, dedicated AV equipment and the=20
authors have no way of knowing (nor should they care I think) the=20
underlying architecture of these.

> > Here is what I think ALSA should provide:
> >=20
> > - The DA and AD clocks should appear as attributes of the HW device.

This would be very useful and helpful when determining if the clock of the=
=20
HW time is falling behind or racing ahead of the gPTP time domain. It will=
=20
also help finding the capture time or calculating when a sample in the=20
buffer will be played back by the device.

> > - There should be a method for measuring the DA/AD clock rate with
> >   respect to both the system time and the PTP Hardware Clock (PHC)
> >   time.

as above.

> > - There should be a method for adjusting the DA/AD clock rate if
> >   possible.  If not, then ALSA should fall back to sample rate
> >   conversion.

This is not a requirement from the standard, but will help avoid costly=20
resampling. At least it should be possible to detect the *need* for=20
resampling so that we can try to avoid underruns.

> > - There should be a method to determine the time delay from the point
> >   when the audio data are enqueued into ALSA until they pass through
> >   the D/A converter.  If this cannot be known precisely, then the
> >   library should provide an estimate with an error bound.
> >=20
> > - I think some AVB use cases will need to know the time delay from A/D
> >   until the data are available to the local application.  (Distributed
> >   microphones?  I'm not too sure about that.)

yes, if you have multiple microphones that you want to combine into a=20
stream and do signal processing, some cases require sample-sync (so within=
=20
1 us accuracy for 48kHz).

> > - If the DA/AD clocks are connected to other clock devices in HW,
> >   there should be a way to find this out in SW.  For example, if SW
> >   can see the PTP-PHC-PLL-DA relationship from the above example, then
> >   it knows how to synchronize the DA clock using the network.
> >=20
> >   [ Implementing this point involves other subsystems beyond ALSA.  It
> >     isn't really necessary for people designing AVB systems, since
> >     they know their designs, but it would be nice to have for writing
> >     generic applications that can deal with any kind of HW setup. ]
>=20
> Depends on which subsystem decides "AVTP presentation time"[3].=20

Presentation time is either set by
a) Local sound card performing capture (in which case it will be 'capture=
=20
   time')
b) Local media application sending a stream accross the network=20
   (time when the sample should be played out remotely)
c) Remote media application streaming data *to* host, in which case it will=
=20
   be local presentation time on local  soundcard

> This value is dominant to the number of events included in an IEC 61883-1=
=20
> packet. If this TSN subsystem decides it, most of these items don't need=
=20
> to be in ALSA.

Not sure if I understand this correctly.

TSN should have a reference to the timing-domain of each *local*=20
sound-device (for local capture or playback) as well as the shared=20
time-reference provided by gPTP.

Unless an End-station acts as GrandMaster for the gPTP-domain, time set=20
forth by gPTP is inmutable and cannot be adjusted. It follows that the=20
sample-frequency of the local audio-devices must be adjusted, or the=20
audio-streams to/from said devices must be resampled.

> As long as I know, the number of AVTPDU per second seems not to be
> fixed. So each application is not allowed to calculate the timestamp by
> its own way unless TSN implementation gives the information to each
> applications.

Before initiating a stream, an application needs to reserve a path and=20
bandwidth through the network. Every bridge (switch/router) must accept=20
this for the stream-allocation to succeed. If a single bridge along the way=
=20
declies, the entire stream is denied. The StreamID combined with traffic=20
class and destination address is used to uniquely identify the stream.

Once ready, frames leaving the End-station with the same StreamID will be=
=20
forwarded through the bridges to the End-station(s).

If you choose to transmit *less* than the bandwidth you reserved, that is=
=20
fine, but you cannot transmit *more*.

As to timestamps. When a talker transmit a frame, the timestamp in the=20
AVTPDU describes the presentation-time.

1) The Talker is a mic, and the timestamp will then be the capture-time=20
   of the sample.
2) For a Listener, the timestamp will be the presentation-time,=20
   the time when the *first* sample in the sample-set should be played (or=
=20
   aligned in an offline format with other samples).

The application should be part of the same gPTP-domain as all the other=20
nodes in the domain, and all the nodes share a common sense of time. That=
=20
means that time X will be the exact same time (or, within a sub-microsecond=
=20
error) for all the nodes in the same domain.

> For your information, in current ALSA implementation of IEC 61883-1/6 on
> IEEE 1394 bus, the presentation timestamp is decided in ALSA side. The
> number of isochronous packet transmitted per second is fixed by 8,000 in
> IEEE 1394, and the number of data blocks in an IEC 61883-1 packet is
> deterministic according to 'sampling transfer frequency' in IEC 61883-6
> and isochronous cycle count passed from Linux FireWire subsystem.

For an audio-stream, it will be very similar. The difference is the split=
=20
between class A and class B, the former is 8kHz frame-rate and a guaranteed=
=20
2ms latency accross the network (think required buffering at end-stations),=
=20
class B is 4kHz and a 50ms max latency. Class B is used for links=20
traversing 1 or 2 wireless links.

If you look at the avb-shim in the series, you see that for 48kHz, 2ch,=20
S16_LE, every frame is of the same size, 6 samples per frame, total of 24=
=20
bytes / frame. For class B, size doubles to 48 bytes as it transmits frames=
=20
4000 times / sec.

The 44.1 part is a bit more painful/messy/horrible, but is doable because=
=20
the stream-reservation only gives an *upper* bound of bandwidth.

> In the TSN subsystem, like FireWire subsystem, callback for filling
> payload should have information of 'when the packet is scheduled to be
> transmitted'.=20

[ Given that you are part of a gPTP domain and that you share a common=20
  sense of what time it is *now* with all the other devices ]

A frame should be transmittet so that it will not arrive too late for it to=
=20
be presented. A class A link guarantees that a frame will be delivered=20
within 2ms. Then, by looking at the timestamp, you subtract the=20
delivery-time and you get when the frame should be sent at the latest.

> With the information, each application can calculate the
> number of event in the packet and presentation timestamp. Of cource,
> this timestamp should be handled as 'avtp_timestamp' in packet queueing.

Not sure if I understand what you are asking, but I think maybe I've=20
answered this above (re. 48kHz, 44.1khz and upper bound of framesize?)

> >> In ALSA, sampling rate conversion should be in userspace, not in kernel
> >> land. In alsa-lib, sampling rate conversion is implemented in shared o=
bject.
> >> When userspace applications start playbacking/capturing, depending on =
PCM
> >> node to access, these applications load the shared object and convert =
PCM
> >> frames from buffer in userspace to mmapped DMA-buffer, then commit the=
m.
> >=20
> > The AVB use case places an additional requirement on the rate
> > conversion.  You will need to adjust the frequency on the fly, as the
> > stream is playing.  I would guess that ALSA doesn't have that option?
>=20
> In ALSA kernel/userspace interfaces , the specification cannot be
> supported, at all.
>=20
> Please explain about this requirement, where it comes from, which
> specification and clause describe it (802.1AS or 802.1Q?). As long as I
> read IEEE 1722, I cannot find such a requirement.

1722 only describes how the L2 frames are constructed and transmittet. You=
=20
are correct that it does not mention adjustable clocks there.

- 802.1BA gives an overview of AVB

- 802.1Q-2011 Sec 34 and 35 describes forwarding and queueing and Stream=20
  Reservation (basically what the network needs in order to correctly=20
  prioritize TSN streams)

- 802.1AS-2011 (gPTP) describes the timing in great detail (from a PTP=20
  point of vew) and describes in more detail how the clocks should be=20
  syntonized (802.1AS-2011, 7.3.3).

Since the clock that drives the sample-rate for the DA/AD must be=20
controlled by the shared clock, the fact that gPTP can adjust the time=20
means that the DA/AD circuit needs to be adjustable as well.

note that an adjustable sample-clock is not a *requirement* but in general=
=20
you'd want to avoid resampling in software.

> (When considering about actual hardware codecs, on-board serial bus such
> as Inter-IC Sound, corresponding controller, immediate change of
> sampling rate is something imaginary for semi-realtime applications. And
> the idea has no meaning for typical playback/capture softwares.)

Yes, and no. When you play back a stored file to your soundcard, data is=20
pulled by the card from memory. So you only have a single timing-domain to=
=20
worry about. So I'd say the idea has meaning in normal scenarios as well,=
=20
you don't have to worry about it.

When you send a stream accross the network, you cannot let the Listener=20
pull data from you, you have to have some common sense of time in order to=
=20
send just enough data, and that is why the gPTP domain is so important.

802.1Q gives you low latency through the network, but more importantly, no=
=20
dropped frames. gPTP gives you a central reference to time.

> [1] [alsa-lib][PATCH 0/9 v3] ctl: add APIs for control element set
> http://mailman.alsa-project.org/pipermail/alsa-devel/2016-June/109274.html
> [2] IEEE 1722-2011
> http://ieeexplore.ieee.org/servlet/opac?punumber=3D5764873
> [3] 5.5 Timing and Synchronization
> op. cit.
> [4] 1394 Open Host Controller Interface Specification
> http://download.microsoft.com/download/1/6/1/161ba512-40e2-4cc9-843a-9231=
43f3456c/ohci_11.pdf

I hope this cleared some of the questions

--=20
Henrik Austad

--kR3zbvD4cgoYnS/6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldlzx0ACgkQ6k5VT6v45lmKBgCgiwCr2KOarjP1iQq1k8v+sth+
/8wAoM3n1IGRCf8oufEIF6pCpRdp9yKS
=QLqp
-----END PGP SIGNATURE-----

--kR3zbvD4cgoYnS/6--
