From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with IFLA_NET_NS_[PID|FD]
Date: Tue, 27 Jan 2015 11:32:44 +0100
Message-ID: <54C7694C.2060709@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com> <20150127093425.GA2698@omega>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	dmitry.tarnyagin@lockless.no, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:39498 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619AbbA0Kcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 05:32:47 -0500
Received: by mail-we0-f178.google.com with SMTP id k48so14031411wev.9
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 02:32:46 -0800 (PST)
In-Reply-To: <20150127093425.GA2698@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/01/2015 10:34, Alexander Aring a =C3=A9crit :
> Hi,
>
> On Mon, Jan 26, 2015 at 10:28:12PM +0100, Nicolas Dichtel wrote:
>>
[snip]
>> - ieee802154 uses also src_net and does not have NETIF_F_NETNS_LOCAL=
=2E Same
>>    question: does this netdevice really supports x-netns?
>
> I am not sure if I understand exactly what you mean. First of all, I
> didn't test anything about net namespaces for the ieee802154 branch.
> In 802.15.4 branch we have two interfaces: wpan and 6LoWPAN.
>
> After running "grep -r "src_net" net" I found this is used in:
>
> net/ieee802154/6lowpan/core.c [0]
Yes, I was talking about this.

>
> This file handles the IEEE 802.15.4 6LoWPAN interface to offering a
> IPv6 interface with an IEEE 802.15.4 6LoWPAN adaption layer.
>
> To the codeline "dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK])=
);".
> By calling "ip link add link wpan0 name lowpan0 type lowpan" the
> lowpan_newlink function will be called and we need to find the wpan i=
nterface
> (returned as real_dev in this case).
>
> Namespace setting in wpan interface:
>
> Currently we don't use any net namespace settings there, also we don'=
t
> change the net namespace. The default net namespace for a wpan shoule=
 be
> "init_net".
Ok. After grepping for init_net, it seems to be used a lot in net/ieee8=
02154/.

>
> So this line could be also written as (I found also some others code =
which search
> the wpan interface in &init_net):
>
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/c=
ore.c
> index 9dbe0d69..495c6ad 100644
> --- a/net/ieee802154/6lowpan/core.c
> +++ b/net/ieee802154/6lowpan/core.c
> @@ -151,7 +151,7 @@ static int lowpan_newlink(struct net *src_net, st=
ruct net_device *dev,
>          if (!tb[IFLA_LINK])
>                  return -EINVAL;
>          /* find and hold real wpan device */
> -       real_dev =3D dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LI=
NK]));
> +       real_dev =3D dev_get_by_index(&init_net, nla_get_u32(tb[IFLA_=
LINK]));
>          if (!real_dev)
>                  return -ENODEV;
>          if (real_dev->type !=3D ARPHRD_IEEE802154) {
>
>
>
> The above code is for finding the wpan interface (the real 802.15.4 L=
2 interface).
> For the IEEE 802.15.4 6LoWPAN interface the whole IPv6 implementation=
 is
> used. This interface will be created inside function "newlink".
>
> Running "grep -r "src_net" net/ipv6" reports me alot uses of "src_net=
".
> Don't know if this information is really necessary.
>
> Should I set now the NETIF_F_NETNS_LOCAL for both interface types?
I think yes. If it's not set, a user may do:
$ ip link add link wpan0 name lowpan0 type lowpan
$ ip netns add foo
$ ip link set lowpan0 netns foo

The flag forbids the last command.

Instead of your patch, what about this one:

 From d9a9cd22d5e1db1417b3ffb53cc020481dc761b2 Mon Sep 17 00:00:00 2001
=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 27 Jan 2015 11:26:20 +0100
Subject: [PATCH] ieee802154: forbid to create an iface in a netns !=3D =
init_net

6LoWPAN currently doesn't supports netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
  net/ieee802154/6lowpan/core.c | 5 ++++-
  1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/cor=
e.c
index 055fbb71ba6f..fe8fd022042e 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -126,6 +126,7 @@ static void lowpan_setup(struct net_device *dev)
  	dev->header_ops		=3D &lowpan_header_ops;
  	dev->ml_priv		=3D &lowpan_mlme;
  	dev->destructor		=3D free_netdev;
+	dev->features		|=3D NETIF_F_NETNS_LOCAL;
  }

  static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[]=
)
@@ -148,7 +149,9 @@ static int lowpan_newlink(struct net *src_net, stru=
ct=20
net_device *dev,

  	pr_debug("adding new link\n");

-	if (!tb[IFLA_LINK])
+	if (!tb[IFLA_LINK] ||
+	    !net_eq(src_net, &init_net) ||
+	    !net_eq(dev_net(dev), &init_net))
  		return -EINVAL;
  	/* find and hold real wpan device */
  	real_dev =3D dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
--=20
2.2.2
