From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART messages and interrupt pipe setup
Date: Wed, 13 Feb 2013 12:44:11 +0100
Message-ID: <87a9r8cub8.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<1357318289.5370.19.camel@dcbw.foobar.com>
	<1360176176.11742.16.camel@dcbw.foobar.com>
	<87ip655eqw.fsf@nemi.mork.no>
	<1360256793.2382.27.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44711 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933831Ab3BMLpE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 06:45:04 -0500
In-Reply-To: <1360256793.2382.27.camel@dcbw.foobar.com> (Dan Williams's
	message of "Thu, 07 Feb 2013 11:06:33 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

> It doesn't need to run exactly at probe, but it appears to need to be
> the first thing the driver does when communicating with the firmware =
to
> ensure clear state and whatnot.  Possibly like the QMI SYNC message t=
hat
> clears all the client IDs and resets the internal stack.  (the driver
> also sends a "shutdown" message to the firmware when unbinding).
>
> So I do think that somewhere around probe() is the best time to do th=
is,
> because it's best to initialize the device when the driver binds to i=
t
> and react to errors as soon as possible, rather than trying to set
> everything up on open/IFF_UP and then fail right before you want to
> actually use the device.  Late-fail is quite unhelpful for applicatio=
ns.
>
> I don't really care if it happens in probe() or somewhere else right
> after the driver is bound to the device, but it should be part of the
> initialization process.

I was looking for something else in the rndis_host driver right now and
noticed that it has the same sort of problem.  The generic_rndis_bind()
function will call rndis_command() which does

         usb_control_msg(.., USB_CDC_SEND_ENCAPSULATED_COMMAND, ..);
         usb_interrupt_msg(.., dev->status->desc.bEndpointAddress, .. )=
;
         for (count =3D 0; count < 10; count++) {
             usb_control_msg(.., USB_CDC_GET_ENCAPSULATED_RESPONSE, ..)=
;
             if (ok)
                return 0;
             msleep(20);
         }

Somewhat ugly, but it is a way to send and receive commands while
probing.  This driver also sends a command in unbind().

Looks like your patch would allow this to be solved a lot cleaner,
replacing the loop over USB_CDC_GET_ENCAPSULATED_RESPONSE with proper
interrupt endpoint handling.


Bj=C3=B8rn
