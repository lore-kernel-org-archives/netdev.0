From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART
 messages and interrupt pipe setup
Date: Thu, 07 Feb 2013 11:06:33 -0600
Message-ID: <1360256793.2382.27.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <1357318289.5370.19.camel@dcbw.foobar.com>
	 <1360176176.11742.16.camel@dcbw.foobar.com> <87ip655eqw.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759058Ab3BGRGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 12:06:17 -0500
In-Reply-To: <87ip655eqw.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 22:11 +0100, Bj=C3=B8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
>=20
> > As part of the initialization sequence, the driver sends a SYNC mes=
sage
> > via the control pipe to the firmware, which appears to request a
> > firmware restart.  The firmware responds with an indication via the
> > interrupt pipe set up by usbnet.  If the driver does not receive a
> > RESTART indication within a certain amount of time, it will periodi=
cally
> > send additional SYNC messages until it receives the RESTART indicat=
ion.
> >
> > Unfortunately, the interrupt URB is only submitted while the netdev
> > is open, which is usually not the case during initialization, and t=
hus
> > the firmware's RESTART indication is lost.  So the driver continues
> > sending SYNC messages, and eventually the firmware crashes when it
> > receives too many.  This leads to a wedged netdev.
> >
> > To ensure the firmware's RESTART indications can be received by the
> > driver, request that usbnet keep the interrupt URB active via
> > FLAG_INTR_ALWAYS.
> >
> > Second, move the code that sends the SYNC message out of the
> > bind() hook and after usbnet_probe() to ensure the interrupt URB
> > is set up before trying to use it.
>=20
> Given this description I am wondering if you couldn't just move the
> whole SYNC thing to a new reset() hook, using some private flag to ma=
ke
> sure it only runs once?  Does it really need to start at probe time?

It doesn't need to run exactly at probe, but it appears to need to be
the first thing the driver does when communicating with the firmware to
ensure clear state and whatnot.  Possibly like the QMI SYNC message tha=
t
clears all the client IDs and resets the internal stack.  (the driver
also sends a "shutdown" message to the firmware when unbinding).

So I do think that somewhere around probe() is the best time to do this=
,
because it's best to initialize the device when the driver binds to it
and react to errors as soon as possible, rather than trying to set
everything up on open/IFF_UP and then fail right before you want to
actually use the device.  Late-fail is quite unhelpful for applications=
=2E

I don't really care if it happens in probe() or somewhere else right
after the driver is bound to the device, but it should be part of the
initialization process.

Dan
