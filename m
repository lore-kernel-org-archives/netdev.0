From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 3/3] qmi_wwan: Driver for WWAN devices requiring use of
 the QMI protocol
Date: Thu, 15 Dec 2011 11:52:10 -0600
Message-ID: <1323971530.23419.13.camel@dcbw.foobar.com>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
	 <1323750784-32608-4-git-send-email-bjorn@mork.no>
	 <1323882501.2077.3.camel@dcbw.foobar.com> <87r506b1ap.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751617Ab1LORvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 12:51:02 -0500
In-Reply-To: <87r506b1ap.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-15 at 11:02 +0100, Bj=C3=B8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
>=20
> > So I thought the protocol acronym stood for "Qualcomm MSM/Modem
> > Interface"  (see
> > https://www.codeaurora.org/gitweb/quic/le/?p=3Dkernel/msm.git;a=3Dc=
ommitdiff;h=3D5f6f87b51184e13b6c493012de787895d5d18765)
>=20
> That's probably correct.  Don't know where I got the messaging part
> from.  Should be corrected....
>=20
> > In any case, great work here.  But I'm a bit concerned about how al=
l
> > this should fit together.  QMI is a huge protocol that does everyth=
ing a
> > modem would ever want to do, and we'd likely want to be able to spe=
ak
> > QMI from userspace to the modem too so that modem managers can expo=
se
> > the full functionality of the modems.  For example Gobi modems have=
 a
> > very minimal AT command set and most of the functionality is expose=
d
> > over QMI or DM.  That's why the Qualcomm GobiNet driver also
> > exposed /dev/qmi for userspace access.
>=20
> Yes, I believe some interface should be exported.  But my primary goa=
l
> was to make something that would just work as an ethernet device with=
 a
> minimum of external userspace dependencies.  And this modem seems to
> have a fairly complete set of AT commands anyway.  Ideally I would wa=
nt
> to stick
>=20
>  auto wwan0
>  iface wwan0 inet dhcp
>=20
> in my /etc/network/interface and not need any application for that to
> work.  But I realize that I must enter a SIM PIN1 code first (unless
> disabled), and that most users will want to configure a specific APN
> (although the null APN "" most likely will work just fine).
>=20
> But I agree that eventually the full QMI protocol should be made
> available to userspace for other uses.  That should be fairly easy to=
 do
> if you just proxy the commands.  But I'm worring about the interface.
> Is the /dev/qmi from GobiNet acceptable?  Why isn't it merged yet?

It would have to be /dev/qmiX (in case you have more than one
QMI-capable card in the system) and it would also have to have the righ=
t
sysfs entries so that we could match the qmiX entry up with it's parent
USB interface.  Not entirely sure how to do that.

> Wouldn't something like netlink have been more suitable?  How about
> security and the ability to control privileges on a command to comman=
d
> basis?  And are there users?  Note that even the Windows application
> supplied with the modem uses AT commands for SMS sending/receiving et=
c.
> The snoop I did showed a very minimal set of QMI commands.  These wer=
e
> all Windows used for startup of the network interface (partly decoded=
 by
> me):

Huawei writes custom firmware for their dongles.  Gobi devices and othe=
r
devices that talk QMI don't  necessarily have such a full quite of AT
commands, yet they all talk the same QMI protocol.  It makes sense to
have a generic driver for this if we can.  That probably means a QMI
core (like you've got with the qmi_wwan stuff) and device-specific
drives.  The Huawei device would use the ECM-like stuff while the Gobi
bits would implement what gobi_net does.  They might even be almost the
same, I haven't looked in a while.  But they are similar enough that
they should be sharing most of the code.

But it gets more complicated.  We also have Novatel and Sierra devices
that are driven by different drivers (option for Novatel, and sierra fo=
r
Sierra) and both these vendors have Gobi-based devices that also speak
QMI, but have custom Ethernet interfaces too (sierra_net for example).

The point being that we need some mechanism for exposing QMI on all
these devices, but some of them (ie Huawei) also need to use QMI to mak=
e
the Ethernet bits happen.  Some don't.

[snip]

>=20
> > Second, does the modem actually respond to DHCP over the ECM interf=
ace?
>=20
> Yes.  And IMHO that's the only sensible thing to do.  Cannot be very
> difficult to implement that feature in the firmware.  It's not like y=
ou

Not quite, Option's method is just fine too (provide an AT command that
prints the IP and DNS information that you then assign to the
interface).  The devices are a lot more complicated than just doing
DHCP, and you're lucky that it works as easily as it does with the
Huawei part :)  Doesn't mean it should necessarily work that way all th=
e
time.

But companies don't necessarily like adding features to firmware.
That's a lot harder to change than features in the driver.  I worked
with Sierra a couple years ago to get the sierra_net driver accepted to
the kernel and in the first round the DHCP bits were in the driver.
Which was unacceptable.  They finally did move it to the firmware but
not all vendors are as easy to work with as Sierra was.

> need to write a dhcp server.  You know you have only a single client =
on
> the other end of a point-to-point link, and the address configuration=
 is
> given.  And all broadcast/multicast requires special treatment anyway=
=2E
> I actually thought about implementing the DHCP functionality in the
> driver before I knew that the firmware already provided this.
>=20
> FWIW, the Windows driver implementation also depends on DHCP for addr=
ess
> configuration .

Good to know.

> > If you take a look at the Android rmnet code (which is similar to y=
our
> > driver) you'll see they extract the IP address and DNS details from=
 the
> > QMI response.  Do we need to do that here too?
>=20
> Based on the above, I don't think so. =20
>=20
> And if you still want to extract address details without using DHCP,
> then that information is available via the AT^DHCP? command anyway.  =
You
> don't need QMI for that part.

Ok, also good to know.  Honestly I don't really understand why everyone
just uses cdc-ether or cdc-eem these days but apparently they don't.

Dan
