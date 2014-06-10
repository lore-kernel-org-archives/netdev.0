From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Tue, 10 Jun 2014 14:09:32 +0200
Message-ID: <874mzt55kz.fsf@nemi.mork.no>
References: <ln6m4k$q49$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Klink <flokli@flokli.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37217 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbaFJMJj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 08:09:39 -0400
In-Reply-To: <ln6m4k$q49$1@ger.gmane.org> (Florian Klink's message of "Tue, 10
	Jun 2014 12:20:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Klink <flokli@flokli.de> writes:

> Hi,
>
> I recently bought a notebook (Fujitsu Lifebook T904) with integrated
> 3G/4G modem (Sierra Wireless EM7305) thats powered by the cdc-wdm dri=
ver.
>
> It works without any problems on a fresh bootup using Networkmanager.
>
> However, after putting the notebook into standby and waking up again,
> I'm unable to get a connection (always reproducible, not signal quali=
ty
> related).

Does it work again if you restart NetworkManager and ModemManager at
this point?

Does it help to do

 echo  0 >/sys/bus/usb/devices/x-y/power/persist

prior to suspending the notebook?  You'll have to replace "x-y" with th=
e
correct USB bus and port number.  You can find this in e.g. the dmesg
output.  For example, if your log shows:

  qmi_wwan 2-4:1.8: cdc-wdm0: USB WDM device

then x-y =3D 2-4.


> I see the following error messages:
>
>
> Couldn't reload current power state: Transaction timed out
> [/dev/cdc-wdm1] No transaction matched in received message
> <warn> (cdc-wdm1) failed to connect modem: Transaction timed out
> <info> (cdc-wdm1): device state change: prepare -> failed (reason
> 'unknown') [40 120 1]
> modem_prepare_result: assertion 'state =3D=3D NM_DEVICE_STATE_PREPARE=
' failed
>
>
> It looks like a driver bug for me, like the device not woken up
> correctly. I attached the syslog.

It is certainly bad interaction between userspace and the driver.  We'l=
l
have to fight about where the bug is :-)

I believe the problem is that the modem is powered down when the
notebook is suspended, combined with the "USB device persistence"
feature and bad handling of "unexpected" states in ModemManager.
The result is that MM and the device/driver ends up with different view=
s
of the current modem state. But I might be completely wrong here.
Seeing kernel logs would have helped..

Initially I'd like to claim that this is a userspace problem.  But I'm
open to reconsider that view, given convincing arguments. It's not my
intention to reject this as "someone elses problem".

A short explanation of what's going on: The "USB device persistence"
feature just cannot work with 3G/LTE modem devices because they lose
necessary internal state on any power loss.  The persist feature makes
the modem reappear as exact the same device after resume, but with a
case of severe amnesia.  So why don't we just disable the feature when
it cannot work? The reason is that modems often are composite devices,
and many of them include card reader functions. USB device persistences
is critical for such devices. Consider suspending a card reader with a
mounted file system...

=46or this reason I really do not want to disable the persist feature,
even if it is pointless from a standalone modem point of view.  Instead
userspace should be able to cope with modems "suddendly" entering
unexpected states.

> I'm running Arch Linux amd64 with an 3.15.0-rc8 kernel, and
> NetworkManager 0.9.8.10.
>
> Is there anybody else who observed this behaviour?

Yes, I must admit I've seen similar behaviour.  The interaction between
system suspend and drivers/MM/NM is not good.

Could you please bring this up on the ModemManager list?


Bj=C3=B8rn
