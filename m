From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding problem
Date: Mon, 08 Aug 2011 10:06:05 -0700
Message-ID: <26478.1312823165@death>
References: <CANMAZFUibmkyfWP2TyjwV6wtox6LNry2Gh3AtXB2KHnhGF80rQ@mail.gmail.com> <20110808162645.GT21309@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>,
	netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52757 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583Ab1HHRGP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 13:06:15 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p78GigT0010344
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 12:44:42 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p78H6DU0199228
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 13:06:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p78H6AIp019300
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 13:06:10 -0400
In-reply-to: <20110808162645.GT21309@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andy Gospodarek <andy@greyhouse.net> wrote:

>On Sun, Aug 07, 2011 at 03:00:30PM +0300, Eduard Sinelnikov wrote:
>> Hi,
>>=20
>> In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
>> In the function =C2=A0=E2=80=98bond_xmit_roundrobin=E2=80=99
>> The code check if the bond is active via
>> =E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
>> Which actually checks if the slave is backup or active
>> What is the meaning of slave being =C2=A0backup in round robin mode?
>> Correct me if I wrong but in round robin every slave should send a
>> packet, regardless of being active or backup.
>>=20
>> Thank you,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Eduard
>
>There probably is not a compelling reason to continue to have it.  The=
re
>may be a reason historically, but I'm not aware what that might be at
>this point.  For modes other than active-backup, the value of
>slave->link and slave->backup should always contain a value that
>indicates the slave is up and available for transmit.

	If you read Eduard's other posts regarding this, the actual
issue is that when changing from another mode into round-robin,
occasionally slaves will still be marked as "backup" and won't be used:

>Date: 	Mon, 8 Aug 2011 11:16:39 +0300
>Subject: On line Bonding configuration change fails
>From: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
>To: netdev@vger.kernel.org
>Sender: netdev-owner@vger.kernel.org
>
>Hi,
>
>My configuration is a follows:
>
>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| eth0 -------------->
>Ububntu | eth1 --------------> =C2=A0 =C2=A0Swith ------------> Other =
computer
>
>Scenario:
>=E2=80=A2 change the bond mode to active/backup
>=E2=80=A2 unplug some of the cable
>=E2=80=A2 plug-in the unplugged cable
>=E2=80=A2 change bond mode to round robin
>
>I can see that only one eth1 is sending data. When I unplug it the pin=
g stops.
>
>Is it a bug or some mis-configuration?
>
>In the kernel ( /drivers/net/bond/bond_main.c).
>In the function =C2=A0=E2=80=98bond_xmit_roundrobin
>=E2=80=99
>The code check if the bond is active via
>=E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
>Which actually checks if the slave is backup or active
>What is the meaning of backup in round robin?
>Correct me if I wrong but in round robin every slave should send a
>packet, regardless of being active or backup.

	So from looking at the code, it seems that the actual problem is
that when transitioning to round-robin mode, one or more slaves can
remain marked as "backup," and in round-robin mode, that won't ever
change.  We could probably work around that by removing the "is_active"
test (essentially declaring that "is_active" is only valid in
active-backup mode).  That might produce a few odd messages here and
there (when removing a slave or during a link failure, for example).

	From inspection, the bond_xmit_xor function likely has this same
problem.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
