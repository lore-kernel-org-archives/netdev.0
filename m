From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] bonding: fix bond dev flags after convert to arphrd_ether
Date: Thu, 27 Aug 2015 20:39:25 -0700
Message-ID: <21906.1440733165@nyx>
References: <1436990983-1406-1-git-send-email-razor@blackwall.org> <1817.1436992353@famine> <92603003-58ED-46B1-B789-5D4765256FAC@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>, vfalico@gmail.com,
	David Miller <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:51860 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbH1Djd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 23:39:33 -0400
In-reply-to: <92603003-58ED-46B1-B789-5D4765256FAC@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
[...]
>Restarting this thread because there=E2=80=99s actually a bug here, wh=
at you described with
>the bonding destruction is true when the slaves are all destroyed but =
it isn=E2=80=99t true if they=E2=80=99re
>just released, if you take a look at bond_slave_netdev_event() the bon=
d destruction happens
>only on NETDEV_UNREGISTER and I just hit this bug by enslaving a non-A=
RPHRD_ETHER
>device, releasing it and enslaving a ARPHRD_ETHER device so ether_setu=
p() path in bond_enslave
>is hit and IFF_MASTER gets dropped:
>17: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noq=
ueue state UP mode DEFAULT group default qlen 1000
>    link/fddi 9a:33:c5:30:ff:a6 brd ff:ff:ff:ff:ff:ff
>(release non-ARPHRD_ETHER slave)
>(enslave ARPHRD_ETHER device)
>17: bond0: <BROADCAST,MULTICAST,LOWER_UP> mtu 1500 qdisc noqueue state=
 UP mode DEFAULT group default qlen 1000
>    link/ether 08:00:27:3c:13:57 brd ff:ff:ff:ff:ff:ff
>
>Notice the master flag is gone and of course on unload we get:
>[57981.545547] ------------[ cut here ]------------
>[57981.545567] WARNING: CPU: 0 PID: 13792 at fs/proc/generic.c:575 rem=
ove_proc_entry+0x17e/0x190()
>[57981.545572] remove_proc_entry: removing non-empty directory 'net/bo=
nding', leaking at least 'bond0'
[...]
>We need to convert it back to ARPHRD_ETHER if releasing the last slave=
, because
>we can=E2=80=99t destroy it (in some paths bond->dev is used after bon=
d_release()).
>Basically we should make the case that if the bonding doesn=E2=80=99t =
have any slaves then it=E2=80=99s
>always an ARPHRD_ETHER device.
>
>Thoughts ?

	I agree that it would be cleaner for bond_dev->type to switch
back on release of last slave.  The options code (caller of
bond_option_slaves_set) and bond_uninit() both reference the bond or de=
v
after calling bond_release(), and would need changing if any release
could destroy the bond itself.

	However, for the type change, there's the potentially tricky
case of a nested non-ARPHRD_ETHER bond, e.g., bond0 -> bond1 -> ib0.
This isn't a typical use case that I'm aware of, but I believe it's
supported by the code.

	If ib0, the last slave, is released, bond1 will want to change
to ARPHRD_ETHER, but bond0 is ARPHRD_INFINIBAND.  I suspect bonding wil=
l
have to notice the NETDEV_PRE_TYPE_CHANGE and _POST_ notifiers and take
appropriate action (i.e., cascade the type change upwards).

	There might be similar issues with other devices stacked on top
of the IB -> Ether type-changing bond; I'm not sure how many of those
there may be, though, since many things won't stack over IB devices (or
an IB-flavor bond).

	If the type change works, then I don't think we would still need
the "release and destroy" logic.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
