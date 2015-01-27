From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with
 IFLA_NET_NS_[PID|FD]
Date: Tue, 27 Jan 2015 13:23:44 +0100
Message-ID: <20150127122340.GA4338@omega>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150127093425.GA2698@omega>
 <54C7694C.2060709@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:57515 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbbA0MXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:23:52 -0500
Content-Disposition: inline
In-Reply-To: <54C7694C.2060709@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(removing the bounced mail address).

On Tue, Jan 27, 2015 at 11:32:44AM +0100, Nicolas Dichtel wrote:
> Le 27/01/2015 10:34, Alexander Aring a =C3=A9crit :
> >Hi,
> >
> >On Mon, Jan 26, 2015 at 10:28:12PM +0100, Nicolas Dichtel wrote:
> >>
> [snip]
> >>- ieee802154 uses also src_net and does not have NETIF_F_NETNS_LOCA=
L. Same
> >>   question: does this netdevice really supports x-netns?
> >
> >I am not sure if I understand exactly what you mean. First of all, I
> >didn't test anything about net namespaces for the ieee802154 branch.
> >In 802.15.4 branch we have two interfaces: wpan and 6LoWPAN.
> >
> >After running "grep -r "src_net" net" I found this is used in:
> >
> >net/ieee802154/6lowpan/core.c [0]
> Yes, I was talking about this.
>=20

ok.

> >
> >This file handles the IEEE 802.15.4 6LoWPAN interface to offering a
> >IPv6 interface with an IEEE 802.15.4 6LoWPAN adaption layer.
> >
> >To the codeline "dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]=
));".
> >By calling "ip link add link wpan0 name lowpan0 type lowpan" the
> >lowpan_newlink function will be called and we need to find the wpan =
interface
> >(returned as real_dev in this case).
> >
> >Namespace setting in wpan interface:
> >
> >Currently we don't use any net namespace settings there, also we don=
't
> >change the net namespace. The default net namespace for a wpan shoul=
e be
> >"init_net".
> Ok. After grepping for init_net, it seems to be used a lot in net/iee=
e802154/.
>=20

Yes, but the code in net/ieee802154 (except net/ieee802154/6lowpan) is =
only for
the WPAN interface. Currently the WPAN interface is created in mac80215=
4
implementation only [0].

> >
> >So this line could be also written as (I found also some others code=
 which search
> >the wpan interface in &init_net):
> >
> >diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/=
core.c
> >index 9dbe0d69..495c6ad 100644
> >--- a/net/ieee802154/6lowpan/core.c
> >+++ b/net/ieee802154/6lowpan/core.c
> >@@ -151,7 +151,7 @@ static int lowpan_newlink(struct net *src_net, s=
truct net_device *dev,
> >         if (!tb[IFLA_LINK])
> >                 return -EINVAL;
> >         /* find and hold real wpan device */
> >-       real_dev =3D dev_get_by_index(src_net, nla_get_u32(tb[IFLA_L=
INK]));
> >+       real_dev =3D dev_get_by_index(&init_net, nla_get_u32(tb[IFLA=
_LINK]));
> >         if (!real_dev)
> >                 return -ENODEV;
> >         if (real_dev->type !=3D ARPHRD_IEEE802154) {
> >
> >
> >
> >The above code is for finding the wpan interface (the real 802.15.4 =
L2 interface).
> >For the IEEE 802.15.4 6LoWPAN interface the whole IPv6 implementatio=
n is
> >used. This interface will be created inside function "newlink".
> >
> >Running "grep -r "src_net" net/ipv6" reports me alot uses of "src_ne=
t".
> >Don't know if this information is really necessary.
> >
> >Should I set now the NETIF_F_NETNS_LOCAL for both interface types?
> I think yes. If it's not set, a user may do:
> $ ip link add link wpan0 name lowpan0 type lowpan
> $ ip netns add foo
> $ ip link set lowpan0 netns foo
>=20

We should forbid that for the wpan interface. The code line:

real_dev =3D dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));

searches for the "wpan0" interface which is given by:
$ ip link add link wpan0 name lowpan0 type lowpan

The returned real_dev netdevice pointer is the wpan interface. The give=
n
"lowpan0" interface is a virtual interface for making IPv6 stuff.



=46or 6LoWPAN:

This interface is created in 6lowpan/core.c file and is used in the
whole IPv6 stack, because we set the skb->protocol to htons(ETH_P_IPV6)=
=2E [1]

The IPv6 stack uses alot of "src_net".

> The flag forbids the last command.
>=20
> Instead of your patch, what about this one:
>=20
> From d9a9cd22d5e1db1417b3ffb53cc020481dc761b2 Mon Sep 17 00:00:00 200=
1
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 27 Jan 2015 11:26:20 +0100
> Subject: [PATCH] ieee802154: forbid to create an iface in a netns !=3D=
 init_net
>=20
> 6LoWPAN currently doesn't supports netns.
>=20
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ieee802154/6lowpan/core.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/c=
ore.c
> index 055fbb71ba6f..fe8fd022042e 100644
> --- a/net/ieee802154/6lowpan/core.c
> +++ b/net/ieee802154/6lowpan/core.c
> @@ -126,6 +126,7 @@ static void lowpan_setup(struct net_device *dev)
>  	dev->header_ops		=3D &lowpan_header_ops;
>  	dev->ml_priv		=3D &lowpan_mlme;
>  	dev->destructor		=3D free_netdev;
> +	dev->features		|=3D NETIF_F_NETNS_LOCAL;
>  }
>=20
>  static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[=
])
> @@ -148,7 +149,9 @@ static int lowpan_newlink(struct net *src_net, st=
ruct
> net_device *dev,
>=20
>  	pr_debug("adding new link\n");
>=20
> -	if (!tb[IFLA_LINK])
> +	if (!tb[IFLA_LINK] ||
> +	    !net_eq(src_net, &init_net) ||
> +	    !net_eq(dev_net(dev), &init_net))
>  		return -EINVAL;
>  	/* find and hold real wpan device */
>  	real_dev =3D dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));

With the check of "!net_eq(src_net, &init_net)" we need to be sure
that the wpan interface is always in "init_net". This means we need
definitely a dev->features |=3D NETIF_F_NETNS_LOCAL; somewhere in [0].

To adding "dev->features |=3D NETIF_F_NETNS_LOCAL;" for a 6LoWPAN inter=
face,
I am not sure about this. I didn't test it yet and it will not break
anything, but we will lost the support for making net namespaces stuff
inside the IPv6/(netfilter) stack.


Summarize:

I would add the dev->features |=3D NETIF_F_NETNS_LOCAL; while wpan
interface generation and add only the !net_eq(src_net, &init_net) check
above. I suppose that src_net is the net namespace from "underlaying"
interface wpan by calling:

$ ip link add link wpan0 name lowpan0 type lowpan

- Alex

[0] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree=
/net/mac802154/iface.c#n532
[1] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree=
/net/ieee802154/6lowpan/rx.c#n25
