From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: open sockets preventing unregister_netdevice from completing
 in linux-next (next-20120724)
Date: Wed, 25 Jul 2012 16:38:48 +0200
Message-ID: <1343227128.2626.11157.camel@edumazet-glaptop>
References: <87boj4hs3k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63646 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933148Ab2GYOix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 10:38:53 -0400
Received: by bkwj10 with SMTP id j10so578466bkw.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 07:38:52 -0700 (PDT)
In-Reply-To: <87boj4hs3k.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 15:45 +0200, Bj=C3=B8rn Mork wrote:
> I am currently researching several power management regressions in
> linux-next as of next-20120724, spread over the PCI, USB and net
> subsystems. This one I believe belongs to the net subsystem, although=
 I
> definitely may be wrong, mixing these together.
>=20
> My test case is:
>=20
> - open a ssh connection over a USB network device (qmi_wwan - which i=
s why
>   I am looking at this, but I really don't think it's the driver this=
 time)
> - suspend laptop with netdev and ssh connection up
> - attempt to resume
>=20
> The USB device will be gone on resume because it is power cycled, so =
the
> drivers need to clean up, to let the device be rediscovered and bound
> again.  But this does not happen anymore in linux-next as long as som=
e
> socket is open.  Instead we have these messages:
>=20
>  Jul 25 15:13:11 nemi kernel: [ 7704.560306] unregister_netdevice: wa=
iting for wwan0 to become free. Usage count =3D 1
>  Jul 25 15:13:21 nemi kernel: [ 7714.800308] unregister_netdevice: wa=
iting for wwan0 to become free. Usage count =3D 1
>  Jul 25 15:13:31 nemi kernel: [ 7725.040316] unregister_netdevice: wa=
iting for wwan0 to become free. Usage count =3D 1
>=20
>=20
> There are quite a few problems with the system in this state.  Any wr=
ite
> to the power/control associated with that USB device will hang,
> presumably because the USB device does not exist anymore.  This will
> also make new attempts to suspend fail.  And the USB device is of cou=
rse
> not functional.  The driver has not yet had a chance to clean up any =
of
> the other devices associated with the dead USB device (wwan1,
> /dev/cdc-wdm0 and /dev/cdc-wdm1), so these ghost devices will appear =
as
> non- functional.  And new devices cannot be registered until the
> previous USB device is deleted and a new one created.
>=20
> Killing the ssh session let the unregister_netdevice continue and
> everything will be cleaned up and go back to normal.
>=20
> This is a regression compared to 3.5, where unregister_netdevice woul=
d
> succeed regardless of any open sockets. Or maybe the sockets were
> auto-reaped?  I don't know the inner details - just observing the
> results.
>=20
> The test case above is quite normal operational mode for me.  I often
> leave open sessions while suspending (because I intend to continue us=
ing
> them after resuming).  And I always forget that this won't work for t=
he
> USB modem case.  I don't really care either.  I expect the netdev to =
be
> removed, routes deleted and any sockets referencing either should jus=
t
> die or live on as zombies or whatever.  The important part is that th=
ey
> should not prevent deletion of a netdev when e.g. the physical device=
 is
> gone. That's the way things used to work.
>=20
>=20

Yes, we miss what was done with rt_cache_flush() : find all cached
routes and release all dev references...
