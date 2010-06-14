From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [2.6.35-rc3 regression] TCP connections on 'lo' interface
 randomly stall
Date: Mon, 14 Jun 2010 11:23:19 -0700
Message-ID: <20100614112319.9a2758f2.randy.dunlap@oracle.com>
References: <4C167093.2030308@archlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas =?ISO-8859-1?Q?B=E4chler?= <thomas@archlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:46261 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab0FNSYO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 14:24:14 -0400
In-Reply-To: <4C167093.2030308@archlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jun 2010 20:10:27 +0200 Thomas B=E4chler wrote:

> With 2.6.35-rc3, I cannot use TCP over the 'lo' interface any more. T=
his
> is reproduced easily by running 'ssh localhost' and executing a few
> commands inside the ssh session (if you are able to log in, 'ls -lhFR=
 /'
> does a good job) - the connection will stall completely after a very
> short time. As far as I can see, all applications are affected.
>=20
> It also seems that once a service is "stalled", I cannot open a new
> connection to the same TCP port anymore. However, I can open a
> connection to a different port until that one is stalled, too.
>=20
> Running wireshark, I can see that TCP retransmissions are sent, but
> never acknowledged.
>=20
> Bisection (starting with 7908a9e as good and v2.6.35-rc3 as bad) lead=
s
> to the following commit. Please CC me on replies to this issue. Thank=
s
> for your help.

Does this patch fix it for you?
http://lkml.org/lkml/2010/6/13/155


> commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Thu Jun 3 09:30:11 2010 +0000
>=20
>     net: deliver skbs on inactive slaves to exact matches
>=20
>     Currently, the accelerated receive path for VLAN's will
>     drop packets if the real device is an inactive slave and
>     is not one of the special pkts tested for in
>     skb_bond_should_drop().  This behavior is different then
>     the non-accelerated path and for pkts over a bonded vlan.
>=20
>     For example,
>=20
>     vlanx -> bond0 -> ethx
>=20
>     will be dropped in the vlan path and not delivered to any
>     packet handlers at all.  However,
>=20
>     bond0 -> vlanx -> ethx
>=20
>     and
>=20
>     bond0 -> ethx
>=20
>     will be delivered to handlers that match the exact dev,
>     because the VLAN path checks the real_dev which is not a
>     slave and netif_recv_skb() doesn't drop frames but only
>     delivers them to exact matches.
>=20
>     This patch adds a sk_buff flag which is used for tagging
>     skbs that would previously been dropped and allows the
>     skb to continue to skb_netif_recv().  Here we add
>     logic to check for the deliver_no_wcard flag and if it
>     is set only deliver to handlers that match exactly.  This
>     makes both paths above consistent and gives pkt handlers
>     a way to identify skbs that come from inactive slaves.
>     Without this patch in some configurations skbs will be
>     delivered to handlers with exact matches and in others
>     be dropped out right in the vlan path.
>=20
>     I have tested the following 4 configurations in failover modes
>     and load balancing modes.
>=20
>     # bond0 -> ethx
>=20
>     # vlanx -> bond0 -> ethx
>=20
>     # bond0 -> vlanx -> ethx
>=20
>     # bond0 -> ethx
>                 |
>       vlanx -> --
>=20
>     Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
