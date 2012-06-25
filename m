From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 11:37:20 +0800
Message-ID: <CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206232255.08319.oliver@neukum.org>
	<877guxhx44.fsf@nemi.mork.no>
	<201206241413.08339.oliver@neukum.org>
	<0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35576 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab2FYDhV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 23:37:21 -0400
In-Reply-To: <0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 25, 2012 at 1:47 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Oliver Neukum <oliver@neukum.org> wrote:
>>Am Sonntag, 24. Juni 2012, 11:34:19 schrieb Bj=F8rn Mork:
>>
>>> Sorry, I did not understand what you meant we should do here. =A0Th=
e
>>extra
>>> usb_set_intfdata(, NULL) in usbnet_disconnect() won't make any
>>> difference for that piece of code, will it?
>>
>>The point is that if it may be set to NULL, we always want it to be s=
et
>>to
>>NULL, so we catch bugs.
>>
>>> And the USB core ensures that intfdata is set to NULL before any
>>> reprobing, so that will never be a problem. =A0That's the reason wh=
y it
>>> seems redundant setting it in usbnet_disconnect().
>>
>>The point is that if there is a problem because intfdata is set to
>>NULL,
>>there is very likely a problem in form of a race condition, if intfda=
ta
>>were not set to NULL in usbnet's disconnect handler.

I don't agree on the assumption.

The current problem is caused by the set to NULL without any
protection or sync mechanism on it, and it is really a bug.

Also we didn't say the set to NULL will be cancelled, just delay
the clear until it is safe to do it, eg. after complete of unregister_n=
etdev()
and driver_info->unbind, when the previous .open/.close has been
completed already or the later ones will notice the disconnection
early and won't touch usb_get_intfdata() any more.


> Thanks for explaining. Yes, that makes sense to me as well.
>
> So then the original patch against qmi_wwan should go in, and we shou=
ld leave usbnet as it is. Are everyone comfortable with that?

I don't see any races caused by just removing usb_set_intfdata(, NULL)
or moving it after driver_info->unbind simply in usbnet_disconnect.

In fact, suppose that .open/.close and .disconnect are run on different=
 CPUs,
there are no any guarantee that .open/.close can always see the clear a=
ction
immediately. Also, the clear of intfdata may not be observed in .manage=
_power
since usb_set_intfdata(, NULL) may be completed after the lock wdm_mute=
x
operation.

So it is only the sync mechanism that  works on the race even the check=
 is
added in the patch.  Putting usb_set_intfdata(, NULL) after driver_info=
->unbind
should be OK, and it is a general solution for the problem.


Thanks,
--=20
Ming Lei
