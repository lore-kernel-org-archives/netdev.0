From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] qmi_wwan: Driver for WWAN devices requiring use of
 the QMI protocol
Date: Wed, 04 Jan 2012 14:57:34 -0600
Message-ID: <1325710654.7269.42.camel@d430>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	 <1323750784-32608-4-git-send-email-bjorn@mork.no>
	 <1323882501.2077.3.camel@dcbw.foobar.com> <87r506b1ap.fsf@nemi.mork.no>
	 <1323971530.23419.13.camel@dcbw.foobar.com> <874nx0bj1d.fsf@nemi.mork.no>
	 <1324055842.17587.18.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1324055842.17587.18.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-12-16 at 11:17 -0600, Dan Williams wrote:
> On Fri, 2011-12-16 at 17:03 +0100, Bj=C3=B8rn Mork wrote:
> > Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > > On Thu, 2011-12-15 at 11:02 +0100, Bj=C3=B8rn Mork wrote:
> > >
> > > But I agree that eventually the full QMI protocol should be made
> > >> available to userspace for other uses.  That should be fairly ea=
sy to do
> > >> if you just proxy the commands.  But I'm worring about the inter=
face.
> > >> Is the /dev/qmi from GobiNet acceptable?  Why isn't it merged ye=
t?
> > >
> > > It would have to be /dev/qmiX (in case you have more than one
> > > QMI-capable card in the system) and it would also have to have th=
e right
> > > sysfs entries so that we could match the qmiX entry up with it's =
parent
> > > USB interface.  Not entirely sure how to do that.
> >=20
> > The idea of creating multiple independent devices and then stitch t=
hem
> > together again using a sysfs API seems a little backwards to me.  H=
ow
> > about just use ioctls and forward both request and reply?  That won=
't
> > support unsolicited notifications, but otherwise it should be enoug=
h to
> > be useful.
>=20
> Typically adding more ioctls isn't well received.  Plus I don't think
> there's a huge reason to do so, because it's really just a stream
> protocol that's easily handled from a file descriptor.  ioctls add
> unecessary structure.  Netlink might be a better approach if we want
> something there, but any time you think of adding an ioctl you need t=
o
> start questioning that thought :)  I just don't think ioctls are real=
ly
> required in this instance.
>=20
> And we don't really have to stitch devices together; the QMI device i=
s
> really just a file descriptor with read/write operations.  It's not a=
ny
> different than a serial device like ttyUSB0.  And that fits just fine
> into the sysfs hierarchy just like the USB interfaces from the modem =
do,
> and the ethernet device from the modem does.  In sysfs they all have =
a
> common ancestor: the USB device they are provided by. That allows
> connection  managers to find out that ttyUSB0 and ttyUSB1 and usb0 ar=
e
> all owned by the same device, and that say usb0 is the network device
> that must be set up using ttyUSB0.  This is what allows hardware
> autodetection, otherwise users have to sit around editing files in /e=
tc
> to tell the machine things it should already know.
>=20
> > The attached patch implements straight QMI forwarding.  Note that i=
t is
> > only intended as a demo, and *not* a submission.  I have not yet de=
cided
> > whether this is a good idea or not, and I assume that the API shoul=
d
> > receive some more thought and blessings from others than me before
> > anything like this can be submitted.
> >=20
> > It should maybe even be extended to something a little less
> > driver/device specific.  I believe a common WWAN API for settings t=
hings
> > like PIN code and APN would be very useful, in the same way the wir=
eless
> > API has made WLAN usage possible without driver specific tools.
>=20
> Unfortunately there's really too much variation in WWAN modems to mak=
e
> this happen in the kernel.  It's really best left to userspace.  Plus=
,
> there are a *ton* of quirks for different devices.  On some devices y=
ou
> can send a command on any AT port, on others it has to be a specific =
AT
> port.  AT parsing isn't something we should be doing in the kernel, a=
nd
> most modems use AT at this point.  Others use QMI, some QCDM, some Cn=
S,
> some WMC, etc.  A common kernel-side WWAN API is just not going to
> happen.  But in userspace we have various projects like ModemManager
> that try to provide that generic API and abstract the differences
> between modems.  That's my primary interest in this.
>=20
> >=20
> > But anyway, the demo does work.  Using it to send this reqest for
> > firmware revision from userspace:
> >=20
> > 0000  01 0c 00 00 02 00 00 01  00 23 00 00 00
> >=20
> > partly decoded as:
> >=20
> > .tf =3D 0x01
> > .len =3D 0x000c
> > .ctrl =3D 0x00 control point
> > .service =3D 0x02
> > .qmicid =3D 0x00
> > .flags =3D 0x00 request
> > .tid =3D 0x0001
> > .msgid =3D 0x0023
> > .len =3D 000000
> >=20
> >=20
> > I get the expected reply:
> >=20
> > 0000  01 4c 00 80 02 00 02 01  00 23 00 40 00 02 04 00
> > 0010  00 00 00 00 01 36 00 4d  39 32 30 30 42 2d 53 43
> > 0020  41 51 44 42 5a 44 2d 33  2e 30 2e 33 35 30 30 32
> > 0030  35 54 20 20 31 20 20 5b  41 75 67 20 31 31 20 32
> > 0040  30 31 31 20 30 32 3a 30  30 3a 30 30 5d
> >=20
> > partly decoded as:
> >=20
> > .tf =3D 0x01
> > .len =3D 0x004c
> > .ctrl =3D 0x80 service
> > .service =3D 0x02
> > .qmicid =3D 0x00
> > .flags =3D 0x02 response
> > .tid =3D 0x0001
> > .msgid =3D 0x0023
> > .len =3D 0x0040
> > [0x02] (4) SUCCESS (0x0000) QMI_ERR_NONE
> > [0x01] (54) 4d 39 32 30 30 42 2d 53 43 41 51 44 42 5a 44 2d 33 2e 3=
0 2e 33 35 30 30 32 35 54 20 20 31 20 20 5b 41 75 67 20 31 31 20 32 30 =
31 31 20 30 32 3a 30 30 3a 30 30 5d   M9200B-SCAQDBZD-3.0.350025T  1  [=
Aug 11 2011 02:00:00]
> >=20
> >=20
> > This is while having an open connection and sending traffic over it=
 (not
> > that that should matter, but anyway..)
> >=20
> > > Huawei writes custom firmware for their dongles.=20
> >=20
> > Somehow I find that hard to believe.  I can believe that they *buil=
d* a
> > custom firmware, enabling a vendor specific set of options, setting
> > their own USB descriptors etc.  And maybe even write some vendor
> > specific feature.  But I would be surprised if most of their firmwa=
re
> > code didn't come directly from the chipset vendor example code.
>=20
> Yeah, I wasn't specific enough.  Everyone who uses a Qualcomm chipset
> and licenses the firmware sources can modify it.  Some vendors just u=
se
> the straight Qualcomm firmware (mostly no-name Asian manufacturers).
> But many vendors add their own AT commands, write custom protocols (C=
nS,
> WMC, etc), some add custom network transports (Sierra), etc.  Huawei =
has
> apparnetly decided to change the USB descriptors too.
>=20
> > And the same goes for every other dongle maker.
> >=20
> > > Gobi devices and other
> > > devices that talk QMI don't  necessarily have such a full quite o=
f AT
> > > commands, yet they all talk the same QMI protocol.  It makes sens=
e to
> > > have a generic driver for this if we can.  That probably means a =
QMI
> > > core (like you've got with the qmi_wwan stuff) and device-specifi=
c
> > > drives.  The Huawei device would use the ECM-like stuff while the=
 Gobi
> > > bits would implement what gobi_net does.  They might even be almo=
st the
> > > same, I haven't looked in a while.  But they are similar enough t=
hat
> > > they should be sharing most of the code.
> >=20
> > Yes, I absolutely agree. That's why I tried to keep the qmi specifi=
c
> > code as driver agnostic as possible.  Well, I could probably have d=
one
> > better, but it's a start..
>=20
> So the reason gobi_net wasn't accepted was that with Gobi 1000 and 20=
00
> chipsets, firmware needs to be loaded into the chip.  And that firmwa=
re
> isn't free; you have to get it from the Windows partition of your
> machine.  So davem rejected it because there was no way distros could
> really test it easily since the firmware isn't freely available.
>=20
> But now the Gobi 3000 stores firmware onboard, so it's worth another =
try
> to get gobi_net upstreamed.

I spent some time with the Pantech UML290 (a dual-mode CDMA/LTE device
based off MSM9xxx) and its network port is basically the same as the
Huawei and the Gobi devices; it uses control transfers for the QMI
commands and bulk transfers for the network data.  Interestingly, the
UML290 uses the "rawip" mode instead of 802.3 mode, so the incoming and
outgoing data is simply raw IP packets.  The IPv4 and IPv6 addresses of
the interface are determined either through QMI requests (IPv4) or
through WMC requests on a separate port (IPv6).  I'm hopeful that we
could switch the device over to 802.3 mode by just sending the right QM=
I
TLV as part of the CTL/Set Data Format command (0x26) using TLV 0x01
(CTL/Set Data Format Request/Format) and TLV 0x10 (CTL/Set Data Format
Request/Protocol).  But I'm not sure, I haven't tried it yet, and it's
obviously not something that Pantech is actually testing otherwise the
Windows driver would use 802.3 mode.

But what this says to me is that we do need a generic QMI driver for
devices that handles the network traffic and also QMI passthrough.  And
then separate interface drivers that handle the USB-level quirks like
your Huawei driver.  We already have the "gobi_net" driver that Elly
Jones from Google cleaned up back in 2009, but it's not split out like
you've done here and I haven't looked into what changes would need to b=
e
done for that.

I'm still somewhat uncomfortable with the amount of QMI logic in this
driver though, given that for the most part, we try to keep this sort o=
f
stuff out of the kernel and in userland.  It also gives the wrong
impression that the interface can actually be used like a normal
interface, where for the most part it cannot unless there is additional
control logic in userspace.  I don't view it as any different from
AT-based WWAN devices in this regard and I think treating it differentl=
y
from them is not the right approach.

Dan


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
