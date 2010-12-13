From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: System blocks (hangs) on ifconfig up
Date: Mon, 13 Dec 2010 13:37:12 +0100
Message-ID: <1292243832.2759.1.camel@edumazet-laptop>
References: <4D04E38A.1040605@trego.co.il>
	 <1292194983.3136.294.camel@localhost>  <4D05E400.7080409@trego.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Shmulik Hen <shmulik.hen@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	shemminger@vyatta.com
To: Shmulik Hen <shmulik@trego.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64993 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449Ab0LMMhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 07:37:18 -0500
Received: by wyb28 with SMTP id 28so5839057wyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 04:37:17 -0800 (PST)
In-Reply-To: <4D05E400.7080409@trego.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 11:14 +0200, Shmulik Hen a =C3=A9=
crit :
> On 12/13/2010 01:03 AM, Ben Hutchings wrote:
> > On Sun, 2010-12-12 at 17:00 +0200, Shmulik Hen wrote:
> >> Hello,
> >>
> >> My system is Ubuntu 10.04, running kernel 2.6.32-26-generic.
> >>
> >> Whenever I try to bring up a specific ethernet interface for the s=
econd
> >> time, my
> >> system becomes unresponsive for 60 seconds - i.e. no mouse, no key=
board, no
> >> screen refresh. etc.
> >>
> >> Looking at the driver's code, I could see that it's dev->open() me=
thod calls
> >> wait_event_interruptible_timeout() with a timeout of 60 seconds - =
exactly
> >> the delay I'm seeing.
> > That seems like a stupid thing for it to do.
> I agree...
> >> I have narrowed the code to a bare minimum (see below - loosely ba=
sed on
> >> dummy.c), which only calls mdelay(10000) in it's dev->open() metho=
d, and
> >> still, my system blocks for exactly 10 seconds when I run the foll=
owing
> >> sequence:
> >>
> >>   >  sudo ifconfig shmulik0 up
> >>   >  sudo ifconfig shmulik0 down
> >>   >  sudo ifconfig shmulik0 up
> >>
> >> At this point - the system is stuck for 10 seconds.
> > Bringing an interface up or down is a synchronous operation and is
> > serialised with most other network configuration operations.  So th=
is is
> > the expected behaviour.
> >
> > Ben.
> But why does this happen only the second time I run ifconfig up?
> How come the entire system is totally frozen?
> I can't even switch to other applications running. If I run 'top' in =
another
> console, it stops refreshing for the entire period.
>=20
> I'll try to explain better;
> The driver I'm referring to is part of an embedded system development=
 kit.
> It runs on the controlling side, which may be a PC or some Linux embe=
dded
> system. It exposes a virtual interface that allows to communicate via
> ethernet connection to a remote board, and performs the firmware down=
load
> to that board.
> Unfortunately, the firmware download stage is  done during dev->open(=
) of
> this virtual interface. The call to wait_event_interruptible_timeout(=
)
> is there to make sure the boot process of the remote board is complet=
e via a
> message. If all goes well the first time, there is no delay, but if t=
he=20
> operation
> fails for any reason the first time, and a second attempt is made (an=
other
> ifconfig up), we see the freezing.
>=20
> Since this driver is (mostly) closed source, I had to try and reprodu=
ce=20
> the situation
> in an all open-source driver - this is the sample code I attached to =
my=20
> original
> message. The call to mdelay() there is meant to simulate the delay of=
=20
> the original
> driver - it schedules.
>=20

mdelay() does a busy wait. If you are not SMP, this means a 'freeze'

If you want to schedule, you should use msleep()

> Obviously, the correct way to fix this is to separate the firmware=20
> download part
> from the dev->open() method, but this is not as simple as it may soun=
d - I'm
> currently working on this. In the mean time I'm looking for a simpler=
=20
> solution
> (or answer) to our problem.
>=20
> I'll appreciate any insight on this matter.
>=20
>      Thanks in advance,
>      Shmulik Hen.


