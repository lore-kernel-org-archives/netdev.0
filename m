From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 14:48:18 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104211436540.1939-100000@iolanthe.rowland.org>
References: <BANLkTinhmAfe1V2SvoY+J6Tu_DdnZMoYgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, USB list <linux-usb@vger.kernel.org>
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:47558 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752542Ab1DUSsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 14:48:19 -0400
In-Reply-To: <BANLkTinhmAfe1V2SvoY+J6Tu_DdnZMoYgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2011, Paul Stewart wrote:

> > The driver needs better coordination between open/stop and
> > resume/suspend. =A0The interrupt and receive URBs are supposed to b=
e
> > active whenever the interface is up and not suspended, right? =A0Wh=
ich
> > means that usbnet_resume() shouldn't submit anything if the interfa=
ce
> > isn't up.
>=20
> How do we define "up" here (from a network perspective there are many
> ways to interpret that)?  How does this concept compare to the user's
> "ifconfig up/down" state?

I don't know the details of how network drivers are supposed to work. =20
But it doesn't matter -- for your purposes you should define "up" to=20
mean "whenever the URBs are supposed to be active (unless the interface=
=20
is suspended)".

>  What call do I use in usbnet_resume() to
> tell that the interface isn't up?  Currently I'm using netif_running(=
)
> which responds true in this condition, which is why I'm resorting to
> the flag.

Again, I don't know.  However, the URBs get submitted from within
usbnet_open() and killed within usbnet_stop(), right?  Therefore you
can use any condition which gets set to True in usbnet_open() and set
to False in usbnet_stop().  (If nothing else is suitable, use a flag of
your own.)  And be careful of the edge case: Since usbnet_open() itself
performs a resume operation, you need to make sure the resume takes
place before the condition becomes True -- otherwise the URBs will get
submitted twice.

One more thing to keep in mind: If the kernel is built without PM
support, the resume and suspend routines will never get called. =20
Therefore they must not be the only places where URBs are submitted and
killed.

Alan Stern

