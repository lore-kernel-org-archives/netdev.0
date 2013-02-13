From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART
 messages and interrupt pipe setup
Date: Wed, 13 Feb 2013 10:34:19 -0600
Message-ID: <1360773259.1559.19.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <1357318289.5370.19.camel@dcbw.foobar.com>
	 <1360176176.11742.16.camel@dcbw.foobar.com> <87ip655eqw.fsf@nemi.mork.no>
	 <1360256793.2382.27.camel@dcbw.foobar.com> <87a9r8cub8.fsf@nemi.mork.no>
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
Received: from mx1.redhat.com ([209.132.183.28]:25683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759377Ab3BMQeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 11:34:46 -0500
In-Reply-To: <87a9r8cub8.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-13 at 12:44 +0100, Bj=C3=B8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
>=20
> > It doesn't need to run exactly at probe, but it appears to need to =
be
> > the first thing the driver does when communicating with the firmwar=
e to
> > ensure clear state and whatnot.  Possibly like the QMI SYNC message=
 that
> > clears all the client IDs and resets the internal stack.  (the driv=
er
> > also sends a "shutdown" message to the firmware when unbinding).
> >
> > So I do think that somewhere around probe() is the best time to do =
this,
> > because it's best to initialize the device when the driver binds to=
 it
> > and react to errors as soon as possible, rather than trying to set
> > everything up on open/IFF_UP and then fail right before you want to
> > actually use the device.  Late-fail is quite unhelpful for applicat=
ions.
> >
> > I don't really care if it happens in probe() or somewhere else righ=
t
> > after the driver is bound to the device, but it should be part of t=
he
> > initialization process.
>=20
> I was looking for something else in the rndis_host driver right now a=
nd
> noticed that it has the same sort of problem.  The generic_rndis_bind=
()
> function will call rndis_command() which does
>=20
>          usb_control_msg(.., USB_CDC_SEND_ENCAPSULATED_COMMAND, ..);
>          usb_interrupt_msg(.., dev->status->desc.bEndpointAddress, ..=
 );
>          for (count =3D 0; count < 10; count++) {
>              usb_control_msg(.., USB_CDC_GET_ENCAPSULATED_RESPONSE, .=
=2E);
>              if (ok)
>                 return 0;
>              msleep(20);
>          }
>=20
> Somewhat ugly, but it is a way to send and receive commands while
> probing.  This driver also sends a command in unbind().
>=20
> Looks like your patch would allow this to be solved a lot cleaner,
> replacing the loop over USB_CDC_GET_ENCAPSULATED_RESPONSE with proper
> interrupt endpoint handling.

It would end up being more "correct" but more complicated, because you'=
d
need to have rndis_command() block on a semaphore or something until th=
e
response was processed by a "status" handler, which neither rndis_host.=
c
or rndis_wlan.c actually implement.  The status handler would have to
know that something was waiting on it, and then package up the response
in some way that the rndis_command() (which is now blocking on the
status interrupt) can read it and return it to the caller.

More correct, more code, more complicated...  but probably still
worthwhile?

Dan
