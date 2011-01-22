From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Bonding on bond
Date: Sat, 22 Jan 2011 23:57:22 +0100
Message-ID: <4D3B60D2.30309@gmail.com>
References: <4D374A8F.2020303@gmail.com> <20110120153110.GA3931@midget.suse.cz> <4D385F0B.1010000@gmail.com> <4202.1295553193@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Bohac <jbohac@suse.cz>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58409 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738Ab1AVW5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 17:57:25 -0500
Received: by wyb28 with SMTP id 28so2996279wyb.19
        for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 14:57:23 -0800 (PST)
In-Reply-To: <4202.1295553193@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/01/2011 20:53, Jay Vosburgh a =C3=A9crit :
> 	I'm in agreement that, by and large, nesting of bonds is
> pointless.  However, I suspect that there are users out in the world =
who
> are happily doing so, and this patch may shut them down.

Hi Jay,

I tested the following nested bonding configuration:

bond1 : eth1 + eth3, in balance-rr mode.
bond2 : eth0 + eth2, in balance-rr mode.
bond0 : bond1 + bond2, in active-backup mode.

The egress path apparently works not so bad, even if I didn't take time=
 yet to check proper load=20
balancing nor fail over.

However, the ingress path doesn't work at all. bond0 is unable to recei=
ve any packets (ARP or IP).

It doesn't sound surprising to me, having a look at the current code in=
 __netif_receive_skb() :

>         /*
>          * bonding note: skbs received on inactive slaves should only
>          * be delivered to pkt handlers that are exact matches.  Also
>          * the deliver_no_wcard flag will be set.  If packet handlers
>          * are sensitive to duplicate packets these skbs will need to
>          * be dropped at the handler.
>          */
>         null_or_orig =3D NULL;
>         orig_dev =3D skb->dev;
>         master =3D ACCESS_ONCE(orig_dev->master);
>         if (skb->deliver_no_wcard)
>                 null_or_orig =3D orig_dev;
>         else if (master) {
>                 if (skb_bond_should_drop(skb, master)) {
>                         skb->deliver_no_wcard =3D 1;
>                         null_or_orig =3D orig_dev; /* deliver only ex=
act match */
>                 } else
>                         skb->dev =3D master;
>         }

The skb_bond_should_drop() and skb->dev =3D master logic is only applie=
d at a single level.

After this code, skb->dev is the master dev of the receiving dev, but s=
kb->dev->master can be !=3D=20
NULL, if another level of bonding exists. Nothing obvious would cause t=
he packet to be delivered to=20
this possible higher level bonding interface (skb->dev->master).

Is something else expected to call __netif_receive_skb() again, with th=
e current skb, to cause=20
another level of bonding to be reachable? For as far as I understand, n=
othing will, but I might have=20
missed something.

> 	I've not tested with nesting in a while; I know it used to work
> (at least for limited cases, typically an active-backup bond with a p=
air
> of balance-xor or balance-rr or sometimes 802.3ad enslaved to it), bu=
t
> has never really been a deliberate feature.  Is nesting now utterly
> broken, as suggested by the list of problems above?

I don't know whether someone really use nested bonding, but I can hardl=
y imagine how one can have it=20
works with current kernel, except for a pure egress application, withou=
t any feedback from the=20
network. And such very specific application wouldn't even be able to re=
ceive an ARP reply...

> 	If nesting really doesn't work and is going to be disabled, then
> at a minimum it should also have an update to the documentation
> explaining this.

At least, we should explain that nesting bonding interfaces is known to=
 be mostly broken and=20
unsupported.

That being said, we still miss a way to achieve a simple configuration =
with several links doing load=20
balancing to a switch and one or several links doing fail over to anoth=
er switch, both switches=20
*not* being 802.3ad capable.

Should we arrange for bonding to be allowed to nest, for this purpose, =
or should we find a way to=20
setup this configuration with a single level of bonding ? I would prefe=
r the second, but...

	Nicolas.
