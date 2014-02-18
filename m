From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net] bonding: fix arp requests sends with isolated routes
Date: Mon, 17 Feb 2014 17:07:51 -0800
Message-ID: <4562.1392685671@death.nxdomain>
References: <52FE3D5B.6060103@alphalink.fr> <20140217.145635.1123180851794758928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.cachereul@alphalink.fr, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:50173 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbaBRBH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 20:07:57 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 17 Feb 2014 20:07:55 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0EAE06E8041
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 20:07:49 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1I17rf23670378
	for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 01:07:53 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1I17qlo018732
	for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 20:07:53 -0500
In-reply-to: <20140217.145635.1123180851794758928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
>Date: Fri, 14 Feb 2014 16:59:23 +0100
>
>> Make arp_send_all() try to send arp packets through slave devices ev=
ent
>> if no route to arp_ip_target is found. This is useful when the route
>> is in an isolated routing table with routing rule parameters like oi=
f or
>> iif in which case ip_route_output() return an error.
>> Thus, the arp packet is send without vlan and with the bond ip addre=
ss
>> as sender.
>>=20
>> Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
>> ---
>> This previously worked, the problem was added in 2.6.35 with vlan 0
>> added by default when the module 8021q is loaded. Before that no rou=
te
>> lookup was done if the bond device did not have any vlan. The proble=
m
>> now exists event if the module 8021q is not loaded.
>
>I don't like this at all, you're trying to paper over the fact that we
>can't set the flow key correctly at this point.
>
>Just assuming the route might be there and trying anyways is not reall=
y
>acceptable in my opinion.  There's a reason we do a route lookup at al=
l.

	The reason for the route lookup is to get a VLAN ID for the
outgoing ARP (if VLANs are configured above the bond), so it can be
correctly tagged.

	As Francois says, older versions of the bond_arp_send_all
function would skip the route lookup entirely if there were no VLANs
configured above the bond.  E.g., the original logic from a 2.6.32-era
kernel looks like:

	for (i =3D 0; (i < BOND_MAX_ARP_TARGETS); i++) {
[...]
		if (!bond->vlgrp) {
			pr_debug("basa: empty vlan: arp_send\n");
			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
				      bond->master_ip, 0);
			continue;
		}

		/*
		 * If VLANs are configured, we do a route lookup to
		 * determine which VLAN interface would be used, so we
		 * can tag the ARP with the proper VLAN tag.
		 */
		memset(&fl, 0, sizeof(fl));
		fl.fl4_dst =3D targets[i];
		fl.fl4_tos =3D RTO_ONLINK;

		rv =3D ip_route_output_key(&init_net, &rt, &fl);
[...]

	So, in the past, this particular case (oif / iif in route
selection) would "work," in the sense that an ARP would go out with no
VLAN ID, but only when there were known to be no VLANs configured above
the bond.  If any VLANs were configured above the bond, this case would
fail as we're seeing here.

	Nowadays, there is no easy way to tell if there are VLANs above
the bond, and there's generally a VID 0 configured anyway, so the route
lookup is unconditional.  In the case at issue here (the route lookup
for the arp_ip_target IP address fails), it's not possible for bonding
to determine what interface would be used, and therefore what VLAN tag
to use.

	Francois's patch would make bonding essentially take a best
guess of "no VLAN" and send an untagged ARP for any destination not
found in the regular (no iif, oif, etc, rule) routing table, which is
what used to happen for the "known no VLAN" case.

	With the patch, these ARPs may have an all-zero source IP
address (since the bond_confirm_addr call may not find a suitable sourc=
e
address for something it can't find a route to).  That is a legal ARP
(used for duplicate address detection according to RFC 2131), but when
last I tried it a couple of years ago, the replies won't pass
arp_validate (as the target IP of 0.0.0.0 in the reply doesn't match an=
y
of the bond's IP address), and I suspect that hasn't changed.

	In the days of yore code above, bonding kept track of what it
thought the bond's IP address was (bond->master_ip), and used that as
the source IP in the ARPs.  That wasn't always correct if the bond had
multiple IP addresses.

	So, ultimately, Francois is correct that this is a regression of
a behavior that used to work.  On the other hand, this patch isn't
really a complete restoration of the prior behavior.  It's no longer
possible to know that there aren't any VLANs above the bond, and so the
"no VLAN" guess is much less reliable than it used to be, plus the ARPs
that will be generated probably won't work with arp_validate.

	As much as I loathe adding more options to bonding, a manually
selected "force VLAN ID" for the arp_ip_target(s) would resolve this fo=
r
the minority of cases where the automatic VLAN ID selection does not
function.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
