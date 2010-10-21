From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 04/14] vlan: Enable software emulation for vlan accleration.
Date: Thu, 21 Oct 2010 14:44:26 -0700
Message-ID: <AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-5-git-send-email-jesse@nicira.com>
	<1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53548 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab0JUVo1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:44:27 -0400
Received: by wwe15 with SMTP id 15so81315wwe.1
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:44:26 -0700 (PDT)
In-Reply-To: <1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 8:30 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2010-10-20 at 16:56 -0700, Jesse Gross wrote:
>> Currently users of hardware vlan accleration need to know whether
>> the device supports it before generating packets. =A0However, vlan
>> acceleration will soon be available in a more flexible manner so
>> knowing ahead of time becomes much more difficult. =A0This adds
>> a software fallback path for vlan packets on devices without the
>> necessary offloading support, similar to other types of hardware
>> accleration.
> [...]
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4c3ac53..1bfd96b 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1694,7 +1694,12 @@ static bool can_checksum_protocol(unsigned lo=
ng features, __be16 protocol)
>>
>> =A0static bool dev_can_checksum(struct net_device *dev, struct sk_bu=
ff *skb)
>> =A0{
>> - =A0 =A0 if (can_checksum_protocol(dev->features, skb->protocol))
>> + =A0 =A0 int features =3D dev->features;
>> +
>> + =A0 =A0 if (vlan_tx_tag_present(skb))
>> + =A0 =A0 =A0 =A0 =A0 =A0 features &=3D dev->vlan_features;
>> +
>> + =A0 =A0 if (can_checksum_protocol(features, skb->protocol))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
>>
>> =A0 =A0 =A0 if (skb->protocol =3D=3D htons(ETH_P_8021Q)) {
> [...]
>
> Additional context:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vlan_ethhdr *veh =3D (struct vl=
an_ethhdr *)skb->data;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (can_checksum_protocol(dev->feature=
s & dev->vlan_features,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0veh->h_vlan_encapsulated_proto))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return false;
> }
>
> I don't think this will do the right thing if the NIC does VLAN tag
> insertion and checksum offload with only one layer of VLAN
> encapsulation, but the skb has two layers of VLAN encapsulation.
>
> I think we actually want something like:
>
> static bool dev_can_checksum(struct net_device *dev, struct sk_buff *=
skb)
> {
> =A0 =A0 =A0 =A0__be16 protocol =3D skb->protocol;
> =A0 =A0 =A0 =A0int features =3D dev->features;
>
> =A0 =A0 =A0 =A0if (vlan_tx_tag_present(skb)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features &=3D dev->vlan_features;
> =A0 =A0 =A0 =A0} else if (skb->protocol =3D=3D htons(ETH_P_8021Q)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vlan_ethhdr *veh =3D (struct vl=
an_ethhdr *)skb->data;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0protocol =3D veh->h_vlan_encapsulated_=
proto;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0features &=3D dev->vlan_features;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return can_checksum_protocol(features, protocol);
> }
>
> Does that look right?

Thanks, good catch.  Yes, that looks right.  Will you submit a patch
to fix this?
