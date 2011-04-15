From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 11:53:10 -0700
Message-ID: <10227.1302893590@death>
References: <20110415184407.550abd88@pomiocik.lan> <4DA89114.9040900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTWljaGHFgiBHw7Nybnk=3D=3F=3D?=
	<mgorny@gentoo.org>, netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:44829 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab1DOSxR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 14:53:17 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FIgEYC003641
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 12:42:14 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FIrEhD073922
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 12:53:14 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FIrCf1021688
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 12:53:14 -0600
In-reply-to: <4DA89114.9040900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 15/04/2011 18:44, Micha=C5=82 G=C3=B3rny a =C3=A9crit :
>> Hello,
>>
>> I'd like to file a feature request for the bonding driver. Currently=
,
>> there is no way for userspace to know whether the driver actually ge=
ts
>> a MAC address. This results in the fact that dhcpcd sends MAC-less D=
HCP
>> packets through bonding device if it is started before bond gets any
>> slaves.
>
>A similar subject, involving bridge instead of bonding, was discussed =
a
>few weeks ago in this thread:
>http://marc.info/?l=3Dlinux-netdev&m=3D129939017116310&w=3D2
>
>In particular, I suggested to apply Stephen's suggestion not only to b=
ridge but also to bonding.
>
>(http://marc.info/?l=3Dlinux-netdev&m=3D129948385024680&w=3D2)
>
>A bonding device should not report link up to userspace until at least=
 one slave is present and up.
>
>And possibly, a bonding device should report link down if all slaves a=
re down or all slave were removed.
>
>Jay, Andy, does this sounds sensible to you?

	I was just reading their bug and doing an experiment; I don't
see that bonding reports carrier up until there's at least one slave
(even if it's configured up), e.g.,

# modprobe bonding
# ifconfig bond0 up
# cat /sys/class/net/bond0/carrier
0
# echo +eth5 > /sys/class/net/bond0/bonding/slaves
# cat /sys/class/net/bond0/carrier
1

	If there's a slave, there's a MAC assigned, since bond_enslave
sets the master's MAC before it calls bond_set_carrier.

	In bond_create, as soon as register_netdevice returns, we call
netif_carrier_off, and it stays off until bond_enslave runs
successfully.

	Is there some race window there between the register and the
netif_carrier_off?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
