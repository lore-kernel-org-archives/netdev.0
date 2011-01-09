From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 3/3] offloading: Force software GSO for multiple vlan tags.
Date: Sun, 9 Jan 2011 11:00:15 -0500
Message-ID: <AANLkTimo5ETBgoH4t+Hp9F-QVacdh5bC93rWV-fwYuC4@mail.gmail.com>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
	<1288390495-28923-3-git-send-email-jesse@nicira.com>
	<AANLkTi=dwVOeRZvVJu=ft2Sq_FSgcEficCc750gawOsH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56840 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab1AIQAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:00:16 -0500
Received: by ywl5 with SMTP id 5so7266020ywl.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:00:15 -0800 (PST)
In-Reply-To: <AANLkTi=dwVOeRZvVJu=ft2Sq_FSgcEficCc750gawOsH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/7 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
> Hi,
>
> Sorry for late reply, I noticed this patch only after it went to Linu=
s' tree.
>
> 2010/10/30 Jesse Gross <jesse@nicira.com>:
>> We currently use vlan_features to check for TSO support if there is
>> a vlan tag. =A0However, it's quite likely that the NIC is not able t=
o
>> do TSO when there is an arbitrary number of tags. =A0Therefore if th=
ere
>> is more than one tag (in-band or out-of-band), fall back to software
>> emulation.
>>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> CC: Ben Hutchings <bhutchings@solarflare.com>
>> ---
>> =A0include/linux/netdevice.h | =A0 =A07 +++----
>> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 16 ++++++++++++++++
>> =A02 files changed, 19 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 072652d..980c752 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -2234,6 +2234,8 @@ unsigned long netdev_fix_features(unsigned lon=
g features, const char *name);
>> =A0void netif_stacked_transfer_operstate(const struct net_device *ro=
otdev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0struct net_device *dev);
>>
>> +int netif_get_vlan_features(struct sk_buff *skb, struct net_device =
*dev);
>> +
>> =A0static inline int net_gso_ok(int features, int gso_type)
>> =A0{
>> =A0 =A0 =A0 =A0int feature =3D gso_type << NETIF_F_GSO_SHIFT;
>> @@ -2249,10 +2251,7 @@ static inline int skb_gso_ok(struct sk_buff *=
skb, int features)
>> =A0static inline int netif_needs_gso(struct net_device *dev, struct =
sk_buff *skb)
>> =A0{
>> =A0 =A0 =A0 =A0if (skb_is_gso(skb)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int features =3D dev->features;
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->protocol =3D=3D htons(ETH_P_8=
021Q) || skb->vlan_tci)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features &=3D dev->vla=
n_features;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int features =3D netif_get_vlan_featur=
es(skb, dev);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return (!skb_gso_ok(skb, features) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unlikely(skb->ip_summ=
ed !=3D CHECKSUM_PARTIAL));
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 8bdda70..8d74988 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1969,6 +1969,22 @@ static inline void skb_orphan_try(struct sk_b=
uff *skb)
>> =A0 =A0 =A0 =A0}
>> =A0}
>>
>> +int netif_get_vlan_features(struct sk_buff *skb, struct net_device =
*dev)
>> +{
>> + =A0 =A0 =A0 __be16 protocol =3D skb->protocol;
>> +
>> + =A0 =A0 =A0 if (protocol =3D=3D htons(ETH_P_8021Q)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vlan_ethhdr *veh =3D (struct vl=
an_ethhdr *)skb->data;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 protocol =3D veh->h_vlan_encapsulated_=
proto;
>> + =A0 =A0 =A0 } else if (!skb->vlan_tci)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev->features;
>> +
>> + =A0 =A0 =A0 if (protocol !=3D htons(ETH_P_8021Q))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev->features & dev->vlan_featu=
res;
>> + =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +}
>
> This clears all features for multiply-tagged frames. At least SG,
> FRAGLIST and HW_CSUM are perfectly valid for those frames.
>
> This doesn't really matter if this function stays used only in
> netif_needs_gso(). It's name and placement suggests otherwise, though=
=2E

You're right and in fact I have some upcoming changes that expands the
use of this function to places that do care about these offloads.
I've generalized it as you suggest.

Thanks.
