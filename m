From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC PATCH 2/7] vlan: Centralize handling of hardware acceleration.
Date: Thu, 14 Oct 2010 15:23:31 -0700
Message-ID: <AANLkTikDymb5OGkmxZkAZwvr-uUPK64jcmxsV1sFOfEX@mail.gmail.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
	<1287000177-7126-3-git-send-email-jesse@nicira.com>
	<1287004334.2649.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58838 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab0JNWXf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 18:23:35 -0400
Received: by iwn35 with SMTP id 35so105129iwn.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 15:23:35 -0700 (PDT)
In-Reply-To: <1287004334.2649.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 13, 2010 at 2:12 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 13 octobre 2010 =E0 13:02 -0700, Jesse Gross a =E9crit :
>> +#define VLAN_N_VID =A0 =A0 =A0 =A0 =A0 4096
>>
>
> This should be a patch on its own (change VLAN_GROUP_ARRAY_LEN to
> VLAN_N_ID), because this patch is too big.

That's fine, I separated it out.

>
> Please try to not change too many things at once, you remove many
> temporary variables and this only makes review very time consuming.

=46or what's worth, it used to be worse: originally all seven of these
patches were one...

>> =A0#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODUL=
E)
>> +/* Must be invoked with rcu_read_lock or with RTNL. */
>> +static inline struct net_device *vlan_find_dev(struct net_device *r=
eal_dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0u16 vlan_id)
>> +{
>> + =A0 =A0 struct vlan_group *grp =3D rcu_dereference(real_dev->vlgrp=
);
>> +
>
> This rcu_dereference() doesnt match the comment.
>
> You might want rcu_dereference_rtnl() instead and use CONFIG_PROVE_RC=
U

Sure, I changed it to use rcu_dereference_rtnl().

>> =A0static inline int netif_needs_gso(struct net_device *dev, struct =
sk_buff *skb)
>> =A0{
>> + =A0 =A0 int features =3D dev->features;
>> +
>> + =A0 =A0 if (skb->protocol =3D=3D htons(ETH_P_8021Q) || skb->vlan_t=
ci)
>> + =A0 =A0 =A0 =A0 =A0 =A0 features &=3D dev->vlan_features;
>> +
>> =A0 =A0 =A0 return skb_is_gso(skb) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0(!skb_gso_ok(skb, dev->features) ||
>> + =A0 =A0 =A0 =A0 =A0 =A0(!skb_gso_ok(skb, features) ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlikely(skb->ip_summed !=3D CHECKSUM_PA=
RTIAL));
>
>
> Maybe reorder tests to common case, avoiding some uneeded computation=
s
> if !skb_is_gso()

That's a good idea, thanks.

>> -void vlan_hwaccel_do_receive(struct sk_buff *skb)
>> -{
>> - =A0 =A0 struct net_device *dev =3D skb->dev;
>
> this temporary variable was nice for a better code readability

I changed all these references to use vlan_dev.

>
>> - =A0 =A0 struct vlan_rx_stats =A0 =A0 *rx_stats;
>> + =A0 =A0 if (netpoll_receive_skb(skb))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NET_RX_DROP;
>>
>> - =A0 =A0 skb->dev =3D vlan_dev_real_dev(dev);
>
>> =A0 =A0 =A0 netif_nit_deliver(skb);
> Strange you dont change netif_nit_deliver() ?

netif_nit_deliver() is used in pretty much the same manner that it was
before, which is why I didn't change it.  Specifically, it can already
handle pulling the tag out of skb->vlan_tci on the underlying device.
tcpdump works as expected after my changes.  Is there something that
you think I'm missing?

> I believe this stuff is a great idea, but you should take more time t=
o
> make your patches more understandable.
>
> Given 2.6.36 is about to be released, and Netfilter Workshop 2010 beg=
ins
> in few days, there is no hurry, because there is no chance we add so
> many fundamental changes before three weeks at least.
>
> I believe this patch (2/7), should be split in small units, maybe 3 o=
r 4
> different patches.

Thanks for the review Eric.  I made the above changes plus broke this
patch down into 4 separate components (and you're right, it is much
easier to look through).  I'll hold onto the series until things open
up again.  In the meantime I'll also try to convert over more of the
drivers.

Thanks again.
