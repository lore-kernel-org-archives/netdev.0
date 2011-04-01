From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Thu, 31 Mar 2011 21:05:30 -0700
Message-ID: <BANLkTinHh6L7mtKp3G5x-6e7Z5-pTdvjYw@mail.gmail.com>
References: <alpine.DEB.2.00.1103302156270.17065@pokey.mtv.corp.google.com>
	<AANLkTimJR+SxeoiZnyP3_vyuK7Z+w_2G2gtUp7pZGZiR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21678 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab1DAEFd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 00:05:33 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p3145WcP012373
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 21:05:32 -0700
Received: from ywa1 (ywa1.prod.google.com [10.192.1.1])
	by kpbe12.cbf.corp.google.com with ESMTP id p3145UrI019991
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 21:05:31 -0700
Received: by ywa1 with SMTP id 1so2636115ywa.25
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 21:05:30 -0700 (PDT)
In-Reply-To: <AANLkTimJR+SxeoiZnyP3_vyuK7Z+w_2G2gtUp7pZGZiR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> BTW, the checks should take protocol into account. If, for example,
> device has NOCACHE_COPY and CSUM_IPV4, but not CSUM_IPV6, then it wil=
l
> take a hit for every IPv6 packet that needs checksumming in software.

If the HW does not do checksum for a protocol, then the checksum-copy
path is taken for packets so there should be no hit.  The logic of the
default setting is that if HW does not checksum offload, then there is
likely no benefit to turning on no cache copy; all the packets would
go through copy checksum.

> Maybe this can be taken into account when sk_route_caps are set?
>
> [...]
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 1a6e9eb..59b6ce9 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1407,7 +1407,7 @@ static int bond_compute_features(struct bondin=
g *bond)
>> =A0 =A0 =A0 =A0int i;
>>
>> =A0 =A0 =A0 =A0features &=3D ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES=
);
>> - =A0 =A0 =A0 features |=3D =A0NETIF_F_GSO_MASK | NETIF_F_NO_CSUM;
>> + =A0 =A0 =A0 features |=3D =A0NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | =
NETIF_F_NOCACHE_COPY;
>>
>> =A0 =A0 =A0 =A0if (!bond->first_slave)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> [...]
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 0b88eba..454abfd 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5444,6 +5444,13 @@ int register_netdevice(struct net_device *dev=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->features &=3D ~NETIF_F_GSO;
>> =A0 =A0 =A0 =A0}
>>
>> + =A0 =A0 =A0 /* Turn no cache copy off if HW isn't doing checksum *=
/
>> + =A0 =A0 =A0 if (!(dev->features & NETIF_F_ALL_CSUM) ||
>> + =A0 =A0 =A0 =A0 =A0 (dev->features & NETIF_F_NO_CSUM)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->wanted_features &=3D ~NETIF_F_NOC=
ACHE_COPY;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features &=3D ~NETIF_F_NOCACHE_CO=
PY;
>> + =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0/* Enable GRO and NETIF_F_HIGHDMA for vlans by defaul=
t,
>> =A0 =A0 =A0 =A0 * vlan_dev_init() will do the dev->features check, s=
o these features
>> =A0 =A0 =A0 =A0 * are enabled only if supported by underlying device=
=2E
>
> Why NO_CSUM is disabling NOCACHE_COPY? You combine those features in
> bonding code anyway.
>
This is likely loopback in which case no cache copy probably does not
help.  For bonding, no cache copy is only enabled when all slaves are
doing it.

> You didn't add netdev_fix_features() checks, so NOCACHE_COPY might be
> enabled via ethtool after device is registered even if driver doesn't
> support checksum offloads.
>
I don't see a reason to strictly enforce this.  It's not guaranteed
that if a driver doesn't support csum offload then no cache copy is
bad (again it's probably noop anyway because of copy-csum path).
Turning it on for loopback is a benefit if sender and receiver are in
different cache domains is good.

I do need to send another patch.  The skb_add_data function can also
use this.  I will create skb_do_copy_data_nocache and
skb_add_data_nocache to make the use of this explicit in each protocol
(TCP being the first supported).

Tom
