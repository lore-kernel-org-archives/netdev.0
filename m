From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>
Subject: Re: [PATCH net] bonding: fix arp requests sends with isolated routes
Date: Tue, 18 Feb 2014 11:35:38 +0100
Message-ID: <5303377A.4020405@alphalink.fr>
References: <52FE3D5B.6060103@alphalink.fr> <20140217.145635.1123180851794758928.davem@davemloft.net> <4562.1392685671@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vfalico@redhat.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:45298 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754579AbaBRKe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 05:34:28 -0500
In-Reply-To: <4562.1392685671@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/02/2014 02:07, Jay Vosburgh a =C3=A9crit :
> David Miller <davem@davemloft.net> wrote:
>=20
>> From: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
>> Date: Fri, 14 Feb 2014 16:59:23 +0100
>>
>>> Make arp_send_all() try to send arp packets through slave devices e=
vent
>>> if no route to arp_ip_target is found. This is useful when the rout=
e
>>> is in an isolated routing table with routing rule parameters like o=
if or
>>> iif in which case ip_route_output() return an error.
>>> Thus, the arp packet is send without vlan and with the bond ip addr=
ess
>>> as sender.
>>>
>>> Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
>>> ---
>>> This previously worked, the problem was added in 2.6.35 with vlan 0
>>> added by default when the module 8021q is loaded. Before that no ro=
ute
>>> lookup was done if the bond device did not have any vlan. The probl=
em
>>> now exists event if the module 8021q is not loaded.
>>
>> I don't like this at all, you're trying to paper over the fact that =
we
>> can't set the flow key correctly at this point.
>>
>> Just assuming the route might be there and trying anyways is not rea=
lly
>> acceptable in my opinion.  There's a reason we do a route lookup at =
all.
>=20
> 	The reason for the route lookup is to get a VLAN ID for the
> outgoing ARP (if VLANs are configured above the bond), so it can be
> correctly tagged.
>=20
> 	As Francois says, older versions of the bond_arp_send_all
> function would skip the route lookup entirely if there were no VLANs
> configured above the bond.  E.g., the original logic from a 2.6.32-er=
a
> kernel looks like:
>=20
> 	for (i =3D 0; (i < BOND_MAX_ARP_TARGETS); i++) {
> [...]
> 		if (!bond->vlgrp) {
> 			pr_debug("basa: empty vlan: arp_send\n");
> 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
> 				      bond->master_ip, 0);
> 			continue;
> 		}
>=20
> 		/*
> 		 * If VLANs are configured, we do a route lookup to
> 		 * determine which VLAN interface would be used, so we
> 		 * can tag the ARP with the proper VLAN tag.
> 		 */
> 		memset(&fl, 0, sizeof(fl));
> 		fl.fl4_dst =3D targets[i];
> 		fl.fl4_tos =3D RTO_ONLINK;
>=20
> 		rv =3D ip_route_output_key(&init_net, &rt, &fl);
> [...]
>=20
> 	So, in the past, this particular case (oif / iif in route
> selection) would "work," in the sense that an ARP would go out with n=
o
> VLAN ID, but only when there were known to be no VLANs configured abo=
ve
> the bond.  If any VLANs were configured above the bond, this case wou=
ld
> fail as we're seeing here.
>=20
> 	Nowadays, there is no easy way to tell if there are VLANs above
> the bond, and there's generally a VID 0 configured anyway, so the rou=
te
> lookup is unconditional.  In the case at issue here (the route lookup
> for the arp_ip_target IP address fails), it's not possible for bondin=
g
> to determine what interface would be used, and therefore what VLAN ta=
g
> to use.
>=20
> 	Francois's patch would make bonding essentially take a best
> guess of "no VLAN" and send an untagged ARP for any destination not
> found in the regular (no iif, oif, etc, rule) routing table, which is
> what used to happen for the "known no VLAN" case.
>=20
> 	With the patch, these ARPs may have an all-zero source IP
> address (since the bond_confirm_addr call may not find a suitable sou=
rce
> address for something it can't find a route to).  That is a legal ARP
> (used for duplicate address detection according to RFC 2131), but whe=
n
> last I tried it a couple of years ago, the replies won't pass
> arp_validate (as the target IP of 0.0.0.0 in the reply doesn't match =
any
> of the bond's IP address), and I suspect that hasn't changed.

This problem exists already when a route is found. Currently,=20
bond_confirm_addr() call at the end of bond_arp_send_all() may already
not find a suitable source address, if for example a route and its
source address are not in the same network.

>=20
> 	In the days of yore code above, bonding kept track of what it
> thought the bond's IP address was (bond->master_ip), and used that as
> the source IP in the ARPs.  That wasn't always correct if the bond ha=
d
> multiple IP addresses.
>=20
> 	So, ultimately, Francois is correct that this is a regression of
> a behavior that used to work.  On the other hand, this patch isn't
> really a complete restoration of the prior behavior.  It's no longer
> possible to know that there aren't any VLANs above the bond, and so t=
he
> "no VLAN" guess is much less reliable than it used to be, plus the AR=
Ps
> that will be generated probably won't work with arp_validate.
>=20
> 	As much as I loathe adding more options to bonding, a manually
> selected "force VLAN ID" for the arp_ip_target(s) would resolve this =
for
> the minority of cases where the automatic VLAN ID selection does not
> function.

I had thought about adding an option but nothing I came with seemed goo=
d
enough. That's why I proposed this solution.=20
Maybe something like "ip_target:forced_vlan_id" per ip target for the=20
arp_ip_target option would do the trick. ':forced_vlan_id' would have t=
o
be omitted for automatic VLAN ID selection or set to -1 for no vlan id
(0 doesn't seem a good idea as it's used for priority tagged frames).
This way we keep current behavior.

If you're ok with this, I'll submit another patch with the modified
option.

>=20
> 	-J
>=20
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>=20
