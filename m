From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: open sockets preventing unregister_netdevice from completing in linux-next (next-20120724)
Date: Wed, 25 Jul 2012 15:45:35 +0200
Message-ID: <87boj4hs3k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52039 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933018Ab2GYNpn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 09:45:43 -0400
Received: from nemi.mork.no (ti0026a340-0677.bb.online.no [85.166.77.167])
	(authenticated bits=0)
	by canardo.mork.no (8.14.3/8.14.3) with ESMTP id q6PDjeu0015530
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 15:45:41 +0200
Received: from bjorn by nemi.mork.no with local (Exim 4.80)
	(envelope-from <bjorn@mork.no>)
	id 1Su1uB-0005uc-Km
	for netdev@vger.kernel.org; Wed, 25 Jul 2012 15:45:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am currently researching several power management regressions in
linux-next as of next-20120724, spread over the PCI, USB and net
subsystems. This one I believe belongs to the net subsystem, although I
definitely may be wrong, mixing these together.

My test case is:

- open a ssh connection over a USB network device (qmi_wwan - which is =
why
  I am looking at this, but I really don't think it's the driver this t=
ime)
- suspend laptop with netdev and ssh connection up
- attempt to resume

The USB device will be gone on resume because it is power cycled, so th=
e
drivers need to clean up, to let the device be rediscovered and bound
again.  But this does not happen anymore in linux-next as long as some
socket is open.  Instead we have these messages:

 Jul 25 15:13:11 nemi kernel: [ 7704.560306] unregister_netdevice: wait=
ing for wwan0 to become free. Usage count =3D 1
 Jul 25 15:13:21 nemi kernel: [ 7714.800308] unregister_netdevice: wait=
ing for wwan0 to become free. Usage count =3D 1
 Jul 25 15:13:31 nemi kernel: [ 7725.040316] unregister_netdevice: wait=
ing for wwan0 to become free. Usage count =3D 1


There are quite a few problems with the system in this state.  Any writ=
e
to the power/control associated with that USB device will hang,
presumably because the USB device does not exist anymore.  This will
also make new attempts to suspend fail.  And the USB device is of cours=
e
not functional.  The driver has not yet had a chance to clean up any of
the other devices associated with the dead USB device (wwan1,
/dev/cdc-wdm0 and /dev/cdc-wdm1), so these ghost devices will appear as
non- functional.  And new devices cannot be registered until the
previous USB device is deleted and a new one created.

Killing the ssh session let the unregister_netdevice continue and
everything will be cleaned up and go back to normal.

This is a regression compared to 3.5, where unregister_netdevice would
succeed regardless of any open sockets. Or maybe the sockets were
auto-reaped?  I don't know the inner details - just observing the
results.

The test case above is quite normal operational mode for me.  I often
leave open sessions while suspending (because I intend to continue usin=
g
them after resuming).  And I always forget that this won't work for the
USB modem case.  I don't really care either.  I expect the netdev to be
removed, routes deleted and any sockets referencing either should just
die or live on as zombies or whatever.  The important part is that they
should not prevent deletion of a netdev when e.g. the physical device i=
s
gone. That's the way things used to work.



Bj=C3=B8rn
