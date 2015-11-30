From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Mon, 30 Nov 2015 21:01:32 +0900
Message-ID: <CAPA1RqB8uc3vTOi4HXMdU3LREvmcKnUk=ygf3aax1kVZ+wcwJw@mail.gmail.com>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: network dev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35026 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbbK3MBd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 07:01:33 -0500
Received: by obbnk6 with SMTP id nk6so124521847obb.2
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 04:01:32 -0800 (PST)
In-Reply-To: <1448884508-5235-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2015-11-30 20:55 GMT+09:00 Bj=C3=B8rn Mork <bjorn@mork.no>:
> Generating a random ifid for devices with no L2 header
> at all, allowing such devices to take part in IPv6
> autoconfiguration. The tuntap driver is one example of
> a driver where such an ifid would be useful.
>
> Note that as there is no persistence, new addresses
> will be generated every time an interface is brought up:
>
>  # ip -6 addr show dev tun0
>  8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 state UN=
KNOWN qlen 500
>      inet6 fe80::eef2:111c:f270:92ba/64 scope link
>         valid_lft forever preferred_lft forever
>  # ip link set tun0 down
>  # ip link set tun0 up
>  # ip -6 addr show dev tun0
>  8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 state UN=
KNOWN qlen 500
>      inet6 fe80::eec0:48d0:6b52:8835/64 scope link
>         valid_lft forever preferred_lft forever
>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> I'm planning raw-ip support for the qmi_wwan driver.  And
> the feedback from primary users (ModemManager++) is that
> a headerless netdev is preferred over a fake ethernet
> device. The current plan is to model this after 'tun'
> devices, using ARPHRD_NONE as type.
>
> But these devices will need an IPv6 link local address for
> full SLAAC support.  I am therefore wondering if an approach
> like this patch will be acceptable, or if I should look for
> some other solution?
>
>
>
> Bj=C3=B8rn
>
>
>  net/ipv6/addrconf.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index d84742f003a9..6cf3cae691a5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -53,6 +53,7 @@
>  #include <linux/if_arp.h>
>  #include <linux/if_arcnet.h>
>  #include <linux/if_infiniband.h>
> +#include <linux/random.h>
>  #include <linux/route.h>
>  #include <linux/inetdevice.h>
>  #include <linux/init.h>
> @@ -2026,6 +2027,13 @@ static int addrconf_ifid_ip6tnl(u8 *eui, struc=
t net_device *dev)
>         return 0;
>  }
>
> +static int addrconf_ifid_random(u8 *eui, struct net_device *dev)
> +{
> +       get_random_bytes(eui, 8);
> +       eui[0] |=3D 0x02;
> +       return 0;
> +}
> +

Since random identifier is locally assigned, drop the global bit
instead if setting it.

--yoshfuji
