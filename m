From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with
 IFLA_NET_NS_[PID|FD]
Date: Tue, 27 Jan 2015 21:26:20 +0100
Message-ID: <20150127202617.GA13654@omega>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150127093425.GA2698@omega>
 <54C7694C.2060709@6wind.com>
 <20150127122340.GA4338@omega>
 <54C7928F.9010002@6wind.com>
 <20150127140620.GA8941@omega>
 <54C7A5B7.60103@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:40146 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbbA0U02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:26:28 -0500
Content-Disposition: inline
In-Reply-To: <54C7A5B7.60103@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 03:50:31PM +0100, Nicolas Dichtel wrote:
> Le 27/01/2015 15:06, Alexander Aring a =C3=A9crit :
> >Hi,
> >
> >On Tue, Jan 27, 2015 at 02:28:47PM +0100, Nicolas Dichtel wrote:
> >...
> [snip]
> >>
> >>I don't know how wpan0 is created and if this interface can be crea=
ted directly
> >>in another netns than init_net.
> >>
> >
> >no it can't. The wpan0 interface can be created via the 802.15.4
> >userspace tools and we don't have such option for namespaces. It
> >should be always to init_net while creation.
> Even with 'ip netns exec foo iwpan ...'?
>=20

I did a quick test:

diff --git a/net/mac802154/iface.c b/net/mac802154/iface.c
index 6fb6bdf..df55b42 100644
--- a/net/mac802154/iface.c
+++ b/net/mac802154/iface.c
@@ -590,6 +590,11 @@ ieee802154_if_add(struct ieee802154_local *local, =
const char *name,
        list_add_tail_rcu(&sdata->list, &local->interfaces);
        mutex_unlock(&local->iflist_mtx);
=20
+       if (net_eq(dev_net(ndev), &init_net))
+               printk(KERN_INFO "it's init_net\n");
+       else
+               printk(KERN_INFO "it's not init_net\n");

With this patch and running:

ip netns exec foo iwpan phy phy0 interface add bar%d type node

I got a:

[   52.032956] it's init_net

It's also init_net when I run with "ip netns exec foo iwpan ..."

> >
> >>>
> >>>
> >>>Summarize:
> >>>
> >>>I would add the dev->features |=3D NETIF_F_NETNS_LOCAL; while wpan
> >>>interface generation and add only the !net_eq(src_net, &init_net) =
check
> >>>above. I suppose that src_net is the net namespace from "underlayi=
ng"
> >>>interface wpan by calling:
> >>>
> >>>$ ip link add link wpan0 name lowpan0 type lowpan
> >>No. src_net is the netns where the ip command is launched. With thi=
s patch, my
> >
> >ah, and when no "ip netns" is given it's default to init_net?
> The default netns is the netns where your shell is running :)

Now, I understood how basically that works (I think).

> It may be different from init_net when you are playing on a virtual m=
achine. On
> a physical machine, it's usually init_net.
>=20

ok.

> >
> >
> >Okay, then I agree with that both interfaces should be set
> >
> >dev->features |=3D NETIF_F_NETNS_LOCAL
> Ok.
>=20
> >
> >because both interfaces should started with "init_net" as default
> >namespace. For wpan interface this should always be in "init_net",
> >because we don't set anything while creation.
> Not sure this is true. It's probably possible to create it directly i=
n another
> netns (with 'ip netns exec' or because your system is a virtual machi=
ne that
> runs over a namespaces construction (see docker [0], lxc [1], etc).
>=20
> [0] https://www.docker.com/
> [1] https://linuxcontainers.org/
>=20

ah, ok.

> >
> >For 6LoWPAN interface this should also always in the same namespace =
like
> >the wpan interface and not diffrent namespace between link (wpan) an=
d
> >virtual (6LoWPAN) interface.
> >
> >Do you agree with that?
> Yes.
>=20
> But I still wonder if we should add a check about dev_net(dev) !=3D i=
nit_net in
> net/ieee802154/6lowpan/core.c.
> If my understanding is correct:
>  - wpan can be created directly in a netns !=3D init_net
>  - 6lowpan must be in the same netns than wpan
>  - code under net/ieee802154 only works in init_net, thus 6lowpan onl=
y works
>    in init_net.
>=20
> Do you agree?

yes. I will put the last item on my ToDo list if we can do more netns
stuff there.

> What about this (based on net-next)?
>=20

There are some little issues, see below.

> From 5ca1c46c68e4e4381b2f7e284f5dadeb28a53b2f Mon Sep 17 00:00:00 200=
1
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 27 Jan 2015 11:26:20 +0100
> Subject: [PATCH] wpan/6lowpan: fix netns settings
>=20

use "ieee802154:" instead "wpan/6lowpan:".

Can you rebase this patch on bluetooth-next?

> 6LoWPAN currently doesn't supports x-netns and works only in init_net=
=2E
>=20
> With this patch, we ensure that:
>  - the wpan interface cannot be moved to another netns;
>  - the 6lowpan interface cannot be moved to another netns;
>  - the wpan interface is in the same netns than the 6lowpan interface=
;
>  - the 6lowpan interface is in init_net.
>=20
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ieee802154/6lowpan/core.c | 6 ++++--
>  net/mac802154/iface.c         | 1 +
>  2 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/c=
ore.c
> index 055fbb71ba6f..dfd3c6007f60 100644
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
> @@ -148,10 +149,11 @@ static int lowpan_newlink(struct net *src_net, =
struct
> net_device *dev,
>=20
>  	pr_debug("adding new link\n");
>=20
> -	if (!tb[IFLA_LINK])
> +	if (!tb[IFLA_LINK] ||
> +	    !net_eq(dev_net(dev), &init_net))
>  		return -EINVAL;
>  	/* find and hold real wpan device */
> -	real_dev =3D dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
> +	real_dev =3D dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LIN=
K]));
>  	if (!real_dev)
>  		return -ENODEV;
>  	if (real_dev->type !=3D ARPHRD_IEEE802154) {
> diff --git a/net/mac802154/iface.c b/net/mac802154/iface.c
> index 6fb6bdf9868c..b67da8d578b4 100644
> --- a/net/mac802154/iface.c
> +++ b/net/mac802154/iface.c
> @@ -475,6 +475,7 @@ static void ieee802154_if_setup(struct net_device=
 *dev)
>  	dev->mtu		=3D IEEE802154_MTU;
>  	dev->tx_queue_len	=3D 300;
>  	dev->flags		=3D IFF_NOARP | IFF_BROADCAST;
> +	dev->features		|=3D NETIF_F_NETNS_LOCAL;

We should set this inside the cfg802154_netdev_notifier_call function
and NETDEV_REGISTER case. This can be found in "net/ieee802154/core.c".=
 [0]

The branch "net/mac802154" affects 802.15.4 SoftMAC interfaces only. We
currently support SoftMAC only, but further we support HardMAC drivers.
The HardMAC drivers doesn't use the "net/mac802154" branch and call
netdev_register in driver layer.

When we do it in cfg802154_netdev_notifier_call then this will be set
for SoftMAC and HardMAC drivers (when we have a HardMAC driver). The
same behaviour can also be found in wireless implementation. [1]

- Alex

[0] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree=
/net/ieee802154/core.c#n227
[1] http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree=
/net/wireless/core.c#n1000
