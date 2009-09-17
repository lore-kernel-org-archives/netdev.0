From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>
Subject: Re: Netlink API for bonding ?
Date: Thu, 17 Sep 2009 23:44:30 +0200
Message-ID: <4AB2ADBE.1060402@free.fr>
References: <4A9C33EA.7080008@free.fr> <20090831150000.4bcd1481@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:42612 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbZIQVog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 17:44:36 -0400
In-Reply-To: <20090831150000.4bcd1481@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 31 Aug 2009 22:34:50 +0200
> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
>=20
>> Stephen,
>>
>> Can you please describe the netlink API you plan to implement for bo=
nding ?
>>
>> Both Jiri Pirko and I plan to add some advanced active slave selecti=
on rules,=20
>> for more-than-two-slaves bonding configuration.
>>
>> Jay suggested that such advanced features be implemented in user spa=
ce, using=20
>> netlink to notify a daemon when slaves come up or fall down. I agree=
 with Jay,=20
>> but don't want to design something without having first a view at yo=
ur proposed=20
>> API for bonding.
>>
>> Do you plan to have some notification to user space, or only the abi=
lity to read=20
>> and set bonding configuration using netlink ?
>>
>> Thanks,
>>
>> 	Nicolas.
>=20
> No paper spec, but was looking to add interface similar to vlan and m=
acvlan.
> Just use (and extend if needed) existing rtnl_link_ops.
>=20
>=20
> Was not planning on adding a notification interface, thats good idea =
but
> really not what I was looking at.

What kind of notification system would you suggest to notify userland t=
hat a=20
given bond device just lose the current active slave ?

1/ Adding to the list of broadcast group (RTMGRP_*) for NETLINK_ROUTE p=
rotocol=20
in include/linux/rtnetlink.h.

2/ Registering a new NETLINK protocol NETLINK_BONDING in include/linux/=
netlink.h=20
and one of more broadcast groups for this new protocol ?

3/ Not using a broadcast group for notification, but expecting userland=
 to=20
register with the driver using a rtnl_link_ops attribut, to give its PI=
D, so the=20
driver can then send unicast netlink message to userland which would bi=
nd() on=20
NETLINK_ROUTE  ?

4/ Using NETLINK_GENERIC in some ways ?

Also, we need a way to ensure that userland is still available to decid=
e=20
quickly what to do when the active slave disappear. At least some sort =
of=20
timeout, that, when elapsed, would cause bonding driver to fall back to=
 the=20
normal behavior.

Should the notification message hold all the available information abou=
t the=20
current status of the bonding device, so that userland is able to decid=
e=20
quickly, without asking the driver to provide extra information ? This =
would=20
require the receiving buffer to be very large, and with a variable leng=
th,=20
because the status length depends on the number of slaves for this part=
icular=20
bonding device. Not really nice...

Another way would be to simply notify userland that "something happens =
to bond=20
device bondX", and expect userland to ask for the information, by first=
 asking=20
for the buffer size, then asking to fill the buffer. This would lead to=
 some=20
extra process time, that might be too long to be acceptable to select a=
 new=20
active slave.

Any comments ?

	Nicolas.
