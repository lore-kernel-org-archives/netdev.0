From: =?ISO-8859-1?Q?Fran=E7ois_Cachereul?= <f.cachereul@alphalink.fr>
Subject: Re: [PATCH net] bonding: fix arp requests sends with isolated routes
Date: Mon, 17 Feb 2014 12:07:28 +0100
Message-ID: <5301ED70.5060304@alphalink.fr>
References: <52FE3D5B.6060103@alphalink.fr> <20140217093618.GA13038@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48797 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752046AbaBQLGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 06:06:19 -0500
In-Reply-To: <20140217093618.GA13038@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/02/2014 10:36, Veaceslav Falico a =E9crit :
> On Fri, Feb 14, 2014 at 04:59:23PM +0100, Fran=E7ois Cachereul wrote:
>> Make arp_send_all() try to send arp packets through slave devices ev=
ent
>> if no route to arp_ip_target is found. This is useful when the route
>> is in an isolated routing table with routing rule parameters like oi=
f or
>> iif in which case ip_route_output() return an error.
>> Thus, the arp packet is send without vlan and with the bond ip addre=
ss
>> as sender.
>=20
> I'm not sure I understand it completely, specifically I don't really
> understand the term "isolated routing table". Do you mean that it's a=
n
> routing table different from local/main, which is enabled by
> CONFIG_IP_MULTIPLE_TABLES=3Dy ? I think they should be all 'catched' =
by
> ip_route_output(), or am I missing something?

That what I meant, but like I said when the rule to lookup a table cont=
ains
iif or oif parameters (for example with the bond device value),
ip_route_output() can't lookup this table as flowi4_iif is set to
LOOPBACK_INDEX and we set flowi4_oif to 0 because we are searching for =
it.

>=20
> Anyway, with this fix bonding will send packets even if it doesn't fi=
nd
> route AND src addr (bond_confirm_addr() can return 0 if bond doesn't =
have
> the required ip assigned), which isn't good at all.

We may had a test to avoid this case but that should also be done if th=
e
route is found because bond_confirm_addr() could likewise return 0.

>=20
> If my assumption about the routing tables is correct and ip_route_out=
put()
> doesn't find addition tables, we should at least try to fix it via sc=
anning
> those tables.

ip_route_output() scan all tables for which the rule match parameters l=
ike
src network, dst network, oif or iif. In my case, it can't match iif or=
 oif.
If we want to search all tables in any configurations we would have to =
bypass
route lookup process or at least the "rule match" part. I don't know if=
 it's
a good idea.

Anyway, what I understand is that we are searching for a route only to =
find
a vlan to add to the output packet, but we don't care of the route. We =
just
want the packet to pass filtering switches to test the link.
I just propose a default configuration in order to succeed most time
(when we can't find any route) in a way to find a previous behavior in =
which
this use case worked.

> Sorry if I didn't understand you correctly...

No problem, you understand it well. Thanks for the reply.

>=20
>>
>> Signed-off-by: Fran=E7ois CACHEREUL <f.cachereul@alphalink.fr>
>> ---
>> This previously worked, the problem was added in 2.6.35 with vlan 0
>> added by default when the module 8021q is loaded. Before that no rou=
te
>> lookup was done if the bond device did not have any vlan. The proble=
m
>> now exists event if the module 8021q is not loaded.
>>
>> drivers/net/bonding/bond_main.c |    9 ++++++---
>> 1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 8676649..300e5b8 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2168,17 +2168,19 @@ static void bond_arp_send_all(struct bonding=
 *bond, struct slave *slave)
>>     for (i =3D 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
>>         pr_debug("basa: target %pI4\n", &targets[i]);
>>
>> +        vlan_id =3D 0;
>> +
>>         /* Find out through which dev should the packet go */
>>         rt =3D ip_route_output(dev_net(bond->dev), targets[i], 0,
>>                      RTO_ONLINK, 0);
>>         if (IS_ERR(rt)) {
>>             pr_debug("%s: no route to arp_ip_target %pI4\n",
>>                  bond->dev->name, &targets[i]);
>> -            continue;
>> +            /* no route found, trying with bond->dev */
>> +            addr =3D bond_confirm_addr(bond->dev, targets[i], 0);
>> +            goto rt_err_try;
>>         }
>>
>> -        vlan_id =3D 0;
>> -
>>         /* bond device itself */
>>         if (rt->dst.dev =3D=3D bond->dev)
>>             goto found;
>> @@ -2232,6 +2234,7 @@ static void bond_arp_send_all(struct bonding *=
bond, struct slave *slave)
>> found:
>>         addr =3D bond_confirm_addr(rt->dst.dev, targets[i], 0);
>>         ip_rt_put(rt);
>> +rt_err_try:
>>         bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>>                   addr, vlan_id);
>>     }
>> --=20
>> 1.7.10.4
>>
