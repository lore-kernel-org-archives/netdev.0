From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] bonding: fix arp requests sends with isolated routes
Date: Mon, 17 Feb 2014 10:36:18 +0100
Message-ID: <20140217093618.GA13038@redhat.com>
References: <52FE3D5B.6060103@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Fran=E7ois?= Cachereul <f.cachereul@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbaBQJg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 04:36:28 -0500
Content-Disposition: inline
In-Reply-To: <52FE3D5B.6060103@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 04:59:23PM +0100, Fran=E7ois Cachereul wrote:
>Make arp_send_all() try to send arp packets through slave devices even=
t
>if no route to arp_ip_target is found. This is useful when the route
>is in an isolated routing table with routing rule parameters like oif =
or
>iif in which case ip_route_output() return an error.
>Thus, the arp packet is send without vlan and with the bond ip address
>as sender.

I'm not sure I understand it completely, specifically I don't really
understand the term "isolated routing table". Do you mean that it's an
routing table different from local/main, which is enabled by
CONFIG_IP_MULTIPLE_TABLES=3Dy ? I think they should be all 'catched' by
ip_route_output(), or am I missing something?

Anyway, with this fix bonding will send packets even if it doesn't find
route AND src addr (bond_confirm_addr() can return 0 if bond doesn't ha=
ve
the required ip assigned), which isn't good at all.

If my assumption about the routing tables is correct and ip_route_outpu=
t()
doesn't find addition tables, we should at least try to fix it via scan=
ning
those tables.

Sorry if I didn't understand you correctly...

>
>Signed-off-by: Fran=E7ois CACHEREUL <f.cachereul@alphalink.fr>
>---
>This previously worked, the problem was added in 2.6.35 with vlan 0
>added by default when the module 8021q is loaded. Before that no route
>lookup was done if the bond device did not have any vlan. The problem
>now exists event if the module 8021q is not loaded.
>
> drivers/net/bonding/bond_main.c |    9 ++++++---
> 1 file changed, 6 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bon=
d_main.c
>index 8676649..300e5b8 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2168,17 +2168,19 @@ static void bond_arp_send_all(struct bonding *=
bond, struct slave *slave)
> 	for (i =3D 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
> 		pr_debug("basa: target %pI4\n", &targets[i]);
>
>+		vlan_id =3D 0;
>+
> 		/* Find out through which dev should the packet go */
> 		rt =3D ip_route_output(dev_net(bond->dev), targets[i], 0,
> 				     RTO_ONLINK, 0);
> 		if (IS_ERR(rt)) {
> 			pr_debug("%s: no route to arp_ip_target %pI4\n",
> 				 bond->dev->name, &targets[i]);
>-			continue;
>+			/* no route found, trying with bond->dev */
>+			addr =3D bond_confirm_addr(bond->dev, targets[i], 0);
>+			goto rt_err_try;
> 		}
>
>-		vlan_id =3D 0;
>-
> 		/* bond device itself */
> 		if (rt->dst.dev =3D=3D bond->dev)
> 			goto found;
>@@ -2232,6 +2234,7 @@ static void bond_arp_send_all(struct bonding *bo=
nd, struct slave *slave)
> found:
> 		addr =3D bond_confirm_addr(rt->dst.dev, targets[i], 0);
> 		ip_rt_put(rt);
>+rt_err_try:
> 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
> 			      addr, vlan_id);
> 	}
>--=20
>1.7.10.4
>
