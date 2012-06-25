From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 15:15:21 +0800
Message-ID: <CACVXFVNUv6w5OjSZdQDbcLEPpDU5vO_Nmarm+fAfh0RkkL_hdg@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
	<CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
	<201206250815.39466.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:49383 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab2FYHPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 03:15:22 -0400
In-Reply-To: <201206250815.39466.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 25, 2012 at 2:15 PM, Oliver Neukum <oliver@neukum.org> wrote:
> Am Montag, 25. Juni 2012, 05:37:20 schrieb Ming Lei:

>> The current problem is caused by the set to NULL without any
>> protection or sync mechanism on it, and it is really a bug.
>
> Minidrivers can test for NULL.
> That may not be enough and locking may be needed.

Any locking isn't needed if the set to NULL is put after
driver_info->unbind,  since ->unbind will call subdriver->disconnect,
which will hold the open/disconnect lock of wdm_mutex.

>
>> Also we didn't say the set to NULL will be cancelled, just delay
>> the clear until it is safe to do it, eg. after complete of unregister_netdev()
>> and driver_info->unbind, when the previous .open/.close has been
>> completed already or the later ones will notice the disconnection
>> early and won't touch usb_get_intfdata() any more.
>
> We can move to after unregister_netdev()
> I am unhappy with it going after unbind.
>

Could you let us know the reason? I think it may let the
patch not necessary.

>> I don't see any races caused by just removing usb_set_intfdata(, NULL)
>> or moving it after driver_info->unbind simply in usbnet_disconnect.
>
> They are not caused. They are harder to detect.
>
>> In fact, suppose that .open/.close and .disconnect are run on different CPUs,
>> there are no any guarantee that .open/.close can always see the clear action
>> immediately. Also, the clear of intfdata may not be observed in .manage_power
>> since usb_set_intfdata(, NULL) may be completed after the lock wdm_mutex
>> operation.
>
> Sure, it is a debugging aid. It has the drawback that minidrivers have
> to be able to deal with intfdata being NULL. That is not hard to do.

The check isn't needed if the set to NULL is put after  driver_info->unbind
in usbnet_disconnect.

I think we can add the comment on it to avoid the unnecessary check.

Thanks,
-- 
Ming Lei
