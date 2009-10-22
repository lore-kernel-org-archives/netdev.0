From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridging + load balancing bonding
Date: Thu, 22 Oct 2009 17:41:48 +0200
Message-ID: <4AE07D3C.3040702@gmail.com>
References: <20091022122339.GA20148@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57199 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756128AbZJVPls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 11:41:48 -0400
In-Reply-To: <20091022122339.GA20148@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans a =E9crit :
> Hi,
>=20
> We're using the following setup for bonding and bridging, to be able =
to put
> large amounts of data through multiple IDS analyzers:
>=20
>                              +---[br0]----+     +--- eth1 ---(IDS mac=
hine 1)
> (Span port from switch) -- eth0          bond0--+
>                                                 +--- eth2 ---(IDS mac=
hine 2)
>=20
> eth0 receives network traffic, which should be passed to machines whi=
ch are
> connected to eth1 and eth2. These machines run an IDS package, and th=
ere are
> two of those for performance reasons.
>=20
> bond0 is configured to load balance the packets using "balance-xor", =
in this
> case combined with xmit_hash_policy layer2.
>=20
> However, we're seeing problems: packets from one flow do not end up a=
t the
> same IDS machine.  This is because this selection is not based on the=
 source
> _and_ destination mac addresses of the original packet, but on the ma=
c
> address of the bonding device and the destination mac address of the
> package.
>=20
> This is also clear in the code:
> For example, in bond_main.c, in bond_xmit_hash_policy_l2:
> 	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
>=20
> Changing this to
> 	return (data->h_dest[5] ^ data->h_source[5]) % count;
> fixes our problems, but is this harmful for packets originating local=
ly (or
> being routed?)
>=20
> If not, can this be applied? Or does anyone have other ideas?
>=20

Hi Jasper

Very nice setup, and nice finding.

Dont locally generated (or outed) packets have h_source set to bond_dev=
->dev_addr anyway ?

So your solution might be the right fix...

About other ideas... I was thinking of TEE target (not in mainline unfo=
rtunatly) :

iptables -t mangle -A PREROUTING -i eth0 <some hash on mac addr>  -j TE=
E --gateway 192.168.99.1  # IDS1
iptables -t mangle -A PREROUTING -i eth0 !<some hash on mac addr>  -j T=
EE --gateway 192.168.99.2  # IDS2


