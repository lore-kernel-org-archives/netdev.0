From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix bond dev flags after convert to arphrd_ether
Date: Fri, 28 Aug 2015 10:38:59 -0700
Message-ID: <9BCE387A-CE53-48AD-9C6F-CCA9EA8E6EB1@cumulusnetworks.com>
References: <1436990983-1406-1-git-send-email-razor@blackwall.org> <1817.1436992353@famine> <92603003-58ED-46B1-B789-5D4765256FAC@cumulusnetworks.com> <21906.1440733165@nyx>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>, vfalico@gmail.com,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34476 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbbH1RjC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 13:39:02 -0400
Received: by pabzx8 with SMTP id zx8so69302493pab.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 10:39:02 -0700 (PDT)
In-Reply-To: <21906.1440733165@nyx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 27, 2015, at 8:39 PM, Jay Vosburgh <jay.vosburgh@canonical.com=
> wrote:
>=20
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> [...]
>> Restarting this thread because there=E2=80=99s actually a bug here, =
what you described with
>> the bonding destruction is true when the slaves are all destroyed bu=
t it isn=E2=80=99t true if they=E2=80=99re
>> just released, if you take a look at bond_slave_netdev_event() the b=
ond destruction happens
>> only on NETDEV_UNREGISTER and I just hit this bug by enslaving a non=
-ARPHRD_ETHER
>> device, releasing it and enslaving a ARPHRD_ETHER device so ether_se=
tup() path in bond_enslave
>> is hit and IFF_MASTER gets dropped:
>> 17: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc n=
oqueue state UP mode DEFAULT group default qlen 1000
>>   link/fddi 9a:33:c5:30:ff:a6 brd ff:ff:ff:ff:ff:ff
>> (release non-ARPHRD_ETHER slave)
>> (enslave ARPHRD_ETHER device)
>> 17: bond0: <BROADCAST,MULTICAST,LOWER_UP> mtu 1500 qdisc noqueue sta=
te UP mode DEFAULT group default qlen 1000
>>   link/ether 08:00:27:3c:13:57 brd ff:ff:ff:ff:ff:ff
>>=20
>> Notice the master flag is gone and of course on unload we get:
>> [57981.545547] ------------[ cut here ]------------
>> [57981.545567] WARNING: CPU: 0 PID: 13792 at fs/proc/generic.c:575 r=
emove_proc_entry+0x17e/0x190()
>> [57981.545572] remove_proc_entry: removing non-empty directory 'net/=
bonding', leaking at least 'bond0'
> [...]
>> We need to convert it back to ARPHRD_ETHER if releasing the last sla=
ve, because
>> we can=E2=80=99t destroy it (in some paths bond->dev is used after b=
ond_release()).
>> Basically we should make the case that if the bonding doesn=E2=80=99=
t have any slaves then it=E2=80=99s
>> always an ARPHRD_ETHER device.
>>=20
>> Thoughts ?
>=20
> 	I agree that it would be cleaner for bond_dev->type to switch
> back on release of last slave.  The options code (caller of
> bond_option_slaves_set) and bond_uninit() both reference the bond or =
dev
> after calling bond_release(), and would need changing if any release
> could destroy the bond itself.
>=20
> 	However, for the type change, there's the potentially tricky
> case of a nested non-ARPHRD_ETHER bond, e.g., bond0 -> bond1 -> ib0.
> This isn't a typical use case that I'm aware of, but I believe it's
> supported by the code.
>=20
> 	If ib0, the last slave, is released, bond1 will want to change
> to ARPHRD_ETHER, but bond0 is ARPHRD_INFINIBAND.  I suspect bonding w=
ill
> have to notice the NETDEV_PRE_TYPE_CHANGE and _POST_ notifiers and ta=
ke
> appropriate action (i.e., cascade the type change upwards).
>=20
> 	There might be similar issues with other devices stacked on top
> of the IB -> Ether type-changing bond; I'm not sure how many of those
> there may be, though, since many things won't stack over IB devices (=
or
> an IB-flavor bond).
>=20
Ugh right, this would be a problem. I=E2=80=99ll see if it can be handl=
ed well.

> 	If the type change works, then I don't think we would still need
> the "release and destroy" logic.
>=20
Right, that was my intention.

> 	-J
>=20
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com

I=E2=80=99ll look into this some more and if it works out I=E2=80=99ll =
post the patch.

Thanks,
 Nik