From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 10:31:10 +0100
Message-ID: <874nka3wgx.fsf@nemi.mork.no>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
	<CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33641 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509Ab2K1JbV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 04:31:21 -0500
In-Reply-To: <CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
	(Steve Glendinning's message of "Wed, 28 Nov 2012 08:34:59 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve@shawell.net> writes:

>>> udev->do_remote_wakeup is set in choose_wakeup() in
>>> drivers/usb/core/driver.c.  AFAICS it is always set as long as
>>> device_may_wakeup(&udev->dev) is true.
>>
>> That's right.  But is device_may_wakeup(&udev->dev) true?
>>
>> By default it wouldn't be.  The normal way to set it is for the user=
 or
>> a program to do:
>>
>>         echo enabled >/sys/bus/usb/devices/.../power/wakeup
>>
>> Of course, a driver could disregard the user's choice and set the fl=
ag
>> by itself.
>
> If I set that from userspace the system is able to resume, but I can'=
t
> work out how to successfully set this from the driver.  I believe the
> driver should be overriding this as if the user has asked for the
> device to wake on lan they're expecting this to resume the system.
>
> I've tried placing various combinations of device_set_wakeup_capable
> and device_set_wakeup_enable in different places (bind, suspend), but
> it still doesn't allow the device to resume from suspend.  How should
> I do this?

I may be completely wrong here, but this is how I believe it is suppose=
d
to work...  The device can be suspended for two possible reasons:

1) system suspend.  If the user want the device to wake the system, the=
n
   (s)he will do

       echo enabled >/sys/bus/usb/devices/.../power/wakeup

   If this isn't set, then there is no reason for the driver to request
   remote wakeup while the system is suspended.

2) autosuspend.  Any interface driver needing remote wakeup will set
   intf->needs_remote_wakeup, which makes autosuspend_check() set
   udev->do_remote_wakeup


If all my guesses and assumptions are right, then you want to set
intf->needs_remote_wakeup unconditionally.  This will make the USB core
enable remote wakeup on autosuspend.

Remote wakeup will not be enabled on system suspend unless the user (or
a userspace program on the users behalf) has requested it.


Bj=C3=B8rn
