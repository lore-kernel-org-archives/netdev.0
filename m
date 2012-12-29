From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 17:01:01 +0100
Message-ID: <CAHXqBFL+Ycw4-_LRcOCT0bjhALE3HfVMB7YfcoCruu=zW5PN-g@mail.gmail.com>
References: <20121229092417.GA4038@paralelels.com> <1356789203.21409.3923.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Vagin <avagin@parallels.com>, netdev@vger.kernel.org,
	vvs@parallels.com,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:56370 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab2L2QIM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 11:08:12 -0500
Received: by mail-oa0-f43.google.com with SMTP id k1so10625179oag.2
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 08:08:11 -0800 (PST)
In-Reply-To: <1356789203.21409.3923.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/29 Eric Dumazet <eric.dumazet@gmail.com>:
> On Sat, 2012-12-29 at 13:24 +0400, Andrew Vagin wrote:
>> We found a few nodes, where network works slow in containers.
>>
>> For testing speed of TCP connections we use wget, which downloads is=
o
>> images from the internet.
>>
>> wget in the new netns reports only 1.5 MB/s, but wget in the root ne=
tns
>> reports 33MB/s.
>>
>> A few facts:
>>  * Experiments shows that window size for CT traffic does not increa=
ses
>>    up to ~900, however for host traffic window size increases up to =
~14000
>>  * packets are shuffled in the netns sometimes.
>>  * tso/gro/gso changes on interfaces does not help
>>  * issue was _NOT_ reproduced if kernel booted with maxcpus=3D1 or b=
nx2.disable_msi=3D1
>>
>> I reduced steps to reproduce:
>> * Create a new network namespace "test" and a veth pair.
>>   # ip netns add test
>>   # ip link add name veth0 type veth peer name veth1
>>
>> * Move veth1 into the netns test
>>   # ip link set veth1 netns test
>>
>> * Set ip address on veth1 and proper routing rules are added for thi=
s ip
>>   in the root netns.
>>   # ip link set up dev veth0;  ip link set up dev veth0
>>   # ip netns exec test ip a add REMOTE dev veth1
>>   # ip netns exec test ip r a default via veth1
>>   # ip r a REMOTE/32 via dev veth0
>>
>> Tcpdump for both cases are attached to this message.
>> tcpdump.host - wget in the root netns
>> tcpdump.netns.host - tcpdump for the host device, wget in the new ne=
tns
>> tcpdump.netns.veth - tcpdump for the veth1 device, wget in the new n=
etns
>>
>> 3.8-rc1 is used for experiments.
>>
>> Do you have any ideas where is a problem?
>
> veth has absolutely no offload features
>
> It needs some care...
>
> At the very miminum, let TCP coalesce do its job by allowing SG
>
> CC Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> for insights.

veth is just like a tunnel device. In terms of offloads, it can do anyt=
hing
we have software fallbacks for (in case packets get forwarded to real h=
ardware).

> Please try following patch :
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 95814d9..9fefeb3 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -259,6 +259,10 @@ static const struct net_device_ops veth_netdev_o=
ps =3D {
>         .ndo_set_mac_address =3D eth_mac_addr,
>  };
>
> +#define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO |=
   \
> +                      NETIF_F_HW_CSUM | NETIF_F_HIGHDMA |           =
   \
> +                      NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
> +
>  static void veth_setup(struct net_device *dev)
>  {
>         ether_setup(dev);
> @@ -269,9 +273,10 @@ static void veth_setup(struct net_device *dev)
>         dev->netdev_ops =3D &veth_netdev_ops;
>         dev->ethtool_ops =3D &veth_ethtool_ops;
>         dev->features |=3D NETIF_F_LLTX;
> +       dev->features |=3D VETH_FEATURES;
>         dev->destructor =3D veth_dev_free;
>
> -       dev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_R=
XCSUM;
> +       dev->hw_features =3D VETH_FEATURES;
>  }

You missed NETIF_F_RXCSUM in VETH_FEATURES. We might support
NETIF_F_ALL_TSO, not just the IPv4 version.

Best Regards,
Micha=C5=82 Miros=C5=82aw
