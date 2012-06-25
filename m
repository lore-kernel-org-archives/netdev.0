From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 08:15:39 +0200
Message-ID: <201206250815.39466.oliver@neukum.org>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no> <0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com> <CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Marius =?iso-8859-1?q?Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:39520 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2FYGPj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:15:39 -0400
In-Reply-To: <CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 25. Juni 2012, 05:37:20 schrieb Ming Lei:
> On Mon, Jun 25, 2012 at 1:47 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> > Oliver Neukum <oliver@neukum.org> wrote:
> >>Am Sonntag, 24. Juni 2012, 11:34:19 schrieb Bj=F8rn Mork:
> >>
> >>> Sorry, I did not understand what you meant we should do here.  Th=
e
> >>extra
> >>> usb_set_intfdata(, NULL) in usbnet_disconnect() won't make any
> >>> difference for that piece of code, will it?
> >>
> >>The point is that if it may be set to NULL, we always want it to be=
 set
> >>to
> >>NULL, so we catch bugs.
> >>
> >>> And the USB core ensures that intfdata is set to NULL before any
> >>> reprobing, so that will never be a problem.  That's the reason wh=
y it
> >>> seems redundant setting it in usbnet_disconnect().
> >>
> >>The point is that if there is a problem because intfdata is set to
> >>NULL,
> >>there is very likely a problem in form of a race condition, if intf=
data
> >>were not set to NULL in usbnet's disconnect handler.
>=20
> I don't agree on the assumption.
>=20
> The current problem is caused by the set to NULL without any
> protection or sync mechanism on it, and it is really a bug.

Minidrivers can test for NULL.
That may not be enough and locking may be needed.

> Also we didn't say the set to NULL will be cancelled, just delay
> the clear until it is safe to do it, eg. after complete of unregister=
_netdev()
> and driver_info->unbind, when the previous .open/.close has been
> completed already or the later ones will notice the disconnection
> early and won't touch usb_get_intfdata() any more.

We can move to after unregister_netdev()
I am unhappy with it going after unbind.

> > Thanks for explaining. Yes, that makes sense to me as well.
> >
> > So then the original patch against qmi_wwan should go in, and we sh=
ould leave usbnet as it is. Are everyone comfortable with that?
>=20
> I don't see any races caused by just removing usb_set_intfdata(, NULL=
)
> or moving it after driver_info->unbind simply in usbnet_disconnect.

They are not caused. They are harder to detect.

> In fact, suppose that .open/.close and .disconnect are run on differe=
nt CPUs,
> there are no any guarantee that .open/.close can always see the clear=
 action
> immediately. Also, the clear of intfdata may not be observed in .mana=
ge_power
> since usb_set_intfdata(, NULL) may be completed after the lock wdm_mu=
tex
> operation.

Sure, it is a debugging aid. It has the drawback that minidrivers have
to be able to deal with intfdata being NULL. That is not hard to do.

	Regards
		Oliver
