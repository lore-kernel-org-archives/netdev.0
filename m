From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 09:43:46 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104210937360.1939-100000@iolanthe.rowland.org>
References: <BANLkTi=N3T-V8VNOcbKu6COKvbEHqMoAog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, <linux-usb@vger.kernel.org>,
	<davem@davemloft.net>, <greg@kroah.com>
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:59362 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751366Ab1DUNnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 09:43:47 -0400
In-Reply-To: <BANLkTi=N3T-V8VNOcbKu6COKvbEHqMoAog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Apr 2011, Paul Stewart wrote:

> On Wed, Apr 20, 2011 at 2:08 PM, Alan Stern <stern@rowland.harvard.ed=
u> wrote:
> > On Tue, 19 Apr 2011, Paul Stewart wrote:
> >
> >> Set a flag if the interrupt URB completes with ENOENT as this
> >> occurs legitimately during system suspend. =A0When the usbnet_bh
> >> is called after resume, test this flag and try once to resubmit
> >> the interrupt URB.
> >
> > No doubt there's a good reason for doing things this way, but it is=
n't
> > clear. =A0Why wait until usbnet_bh() is called after resume? =A0Why=
 not
> > resubmit the interrupt URB _during_ usbnet_resume()?
>=20
> Actually, I was doing this in the bh because of feedback I had gained
> early in this process about not doing submit_urb in the resume().

Do you have a URL for that feedback?  In general, there's no reason not=
=20
to resubmit URBs during a resume callback; lots of drivers do it.  But=20
usbnet may have some special requirements of its own that I'm not aware=
=20
of.

>  If
> that issue doesn't exist, that makes my work a lot easier.  In testin=
g
> I found that just setting this to happen in the bh might be problemat=
ic
> due to firing too early, so this is good news.
>=20
> >=A0This would seem
> > to be the logical approach, seeing as how usbnet_suspend() kills th=
e
> > interrupt URB.
>=20
> Aha!  But you'll see from the current version of my patch that we don=
't
> actually ever kill the interrupt URB.  It gets killed all on its own =
(by the
> hcd?) and handed back to us in intr_complete().  This last bit about =
the
> complete function being called was lost on me for a while which is wh=
y
> in a previous iteration of the patch I was trying to kill the urb in =
suspend().

Why not kill the interrupt URB while suspending?  It's the proper thing
to do.  Otherwise you run the risk that an event might happen at just
the wrong time, causing the interrupt URB to complete normally, but
_after_ the driver has finished suspending.  There's a good chance the=20
driver would not process the event correctly.

Alan Stern

