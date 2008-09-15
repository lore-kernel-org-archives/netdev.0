From: Alex Sidorenko <asid@hp.com>
Subject: Bonding and Neighbour Discovery on IPv6-only devices
Date: Mon, 15 Sep 2008 13:35:16 -0400
Message-ID: <200809151335.16817.asid@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:5329 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814AbYIORfT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 13:35:19 -0400
Received: from smtp2.cup.hp.com (smtp2.cup.hp.com [16.89.216.28])
	by g1t0028.austin.hp.com (Postfix) with ESMTP id 3B42C1C73C
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 17:35:18 +0000 (UTC)
Received: from [16.212.5.36] (unknown [16.212.5.36])
	by smtp2.cup.hp.com (Postfix) with ESMTP id B40C735772D
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 17:09:50 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I suspect that there are some problems while switching slaves manually =
on=20
IPv6-only bonds. I have tested that this does not work on 2.6.18 kernel=
=20
(RHEL5). I looked at recent sources (2.6.26) and even though there were=
=20
multiple changes in bonding code, I still don't see how this could work=
=2E

Testing setup
-------------

Two ethernets enslaved (eth2 and eh3), active-backup bond has IPv6-only=
=20
address (no IPv4)

Everything works fine, but if we switch the slave doing

# ifenslave -c bond0 eth3

the incoming ping6 to this host stops for up to several minutes (waitin=
g until=20
the switch updates its caches).

Analysis
--------

Switching slaves invokes bond_change_active_slave(). In case of IPv4, w=
e send=20
gratuitous ARP doing bond_send_gratuitous_arp(). This informs switches =
that=20
our active slave has changed, they update their ARP-tables and there is=
 no=20
delay.

In case of IPv6 only I would have expected NS-packet to be sent (doing =
the=20
same work as gratuitous ARP). But testing shows that there are no packe=
ts=20
sent when we switch the slave (checked both by network traces and just=20
looking at the number of RX/TX packets per interface). So the switches =
are=20
unaware that active slave has changed and we have a delay.

Inspecting the sources, I hoped that we'll send NS as a result of migra=
ting=20
multicast addresses from one slave to another doing bond_mc_swap() and =
then=20
doing bond_resend_igmp_join_requests(). But this does not work either:

bond_mc_swap() tries to swap link-multicasts only (bond->dev->mc_list),=
 but=20
this does not work as we have users=3D2 and dev_mc_delete() does not de=
lete=20
addresses in this case. Here is what I see on slaves and bond (eth2 is=20
active, ip maddr show):

2: =A0 =A0 =A0eth2
=A0 =A0 =A0 =A0 link =A033:33:00:00:00:fb users 2
=A0 =A0 =A0 =A0 link =A033:33:ff:5c:fd:de users 2
=A0 =A0 =A0 =A0 link =A033:33:00:00:00:01 users 2
=A0 =A0 =A0 =A0 inet6 ff02::fb
=A0 =A0 =A0 =A0 inet6 ff02::1:ff5c:fdde
=A0 =A0 =A0 =A0 inet6 ff02::1
3: =A0 =A0 =A0eth3
=A0 =A0 =A0 =A0 link =A033:33:00:00:00:fb
=A0 =A0 =A0 =A0 link =A033:33:ff:5c:fd:de
=A0 =A0 =A0 =A0 link =A033:33:00:00:00:01
=A0 =A0 =A0 =A0 inet6 ff02::fb
=A0 =A0 =A0 =A0 inet6 ff02::1:ff5c:fdde
=A0 =A0 =A0 =A0 inet6 ff02::1
<snip>
7: =A0 =A0 =A0bond0
=A0 =A0 =A0 =A0 link =A033:33:00:00:00:fb
=A0 =A0 =A0 =A0 link =A033:33:ff:5c:fd:de
=A0 =A0 =A0 =A0 link =A033:33:00:00:00:01
=A0 =A0 =A0 =A0 inet6 ff02::fb
=A0 =A0 =A0 =A0 inet6 ff02::1:ff5c:fdde users 2
=A0 =A0 =A0 =A0 inet6 ff02::1


bond_resend_igmp_join_requests() works for IP-device only, not IPv6 - s=
o once=20
again, this does not help.

So how is it supposed to work for IPv6-only case? Please note that I am=
=20
talking about switching slaves via 'ifenslave -c', not disconnecting th=
e=20
cable (in the latter case the switch will see carrier lost and we'll ch=
ange=20
the slave device state sending an event).

Once again, the testing was done on a rather old (2.6.18) kernel, so I=20
apologize if this is already fixed in 2.6.26 (in this case I would appr=
eciate=20
if you briefly explain how this works).

Regards,
Alex
--=20
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
