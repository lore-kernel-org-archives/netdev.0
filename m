From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] bonding: allow to add vlans on top of empty bond
Date: Wed, 2 Jul 2014 10:46:52 +0200
Message-ID: <20140702084652.GA3015@minipsycho.orion>
References: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
 <CAG-2HqUKGoG5ZX26aYwv3quUU5RPtn5J1g6i4YzkXUc10u4c0w@mail.gmail.com>
 <26863.1403885330@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Gundersen <teg@jklm.no>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, vfalico@gmail.com,
	andy@greyhouse.net
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:56018 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbaGBIq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 04:46:59 -0400
Received: by mail-we0-f177.google.com with SMTP id u56so10703793wes.8
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 01:46:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <26863.1403885330@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 27, 2014 at 06:08:50PM CEST, jay.vosburgh@canonical.com wrote:
>Tom Gundersen <teg@jklm.no> wrote:
>
>>Hi Jiri,
>>
>>On Fri, Jun 27, 2014 at 4:13 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> This limitation maybe had some reason in the past, but now there is not
>>> one -> removing this.
>>
>>If this restriction is really no longer needed, it would be very
>>helpful if we could drop it. See for instnace
>><https://bugs.freedesktop.org/show_bug.cgi?id=76077#c5>.
>
>	The reason for the restriction is that, in the past, the bond
>did not have a MAC address until the first slave was added, so adding a
>VLAN wouldn't work properly.
>
>	Currently, a random MAC is assigned to the bond when there are
>no slaves, so that problem is no longer an issue (as presumably the VLAN
>can handle the MAC change when the first slave goes in to the bond).
>
>	While you're at it, you might want to also check and possibly
>remove some of the MAC-related warnings related to removing the last
>slave, e.g.,
>
>        if (!bond_has_slaves(bond)) {
>                bond_set_carrier(bond);
>                eth_hw_addr_random(bond_dev);
>
>                if (vlan_uses_dev(bond_dev)) {
>                        pr_warn("%s: Warning: clearing HW address of %s while it still has VLANs\n",
>                                bond_dev->name, bond_dev->name);
>                        pr_warn("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs\n",
>                                bond_dev->name);
>                }
>        }
>
>	This warning may not be useful any longer, since the MAC should
>update correctly without user action when re-adding the first slave.

I just checked. The vlan dev holds its addr. So when new slave is added,
bond addr is changed to it, but vlan addr remains the same. So the
second warning still stands.

The first one can be removed/changed as hw addr is not cleared but
randomly generated.

>
>	-J
>
>
>>Cheers,
>>
>>Tom
>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>  drivers/net/bonding/bond_main.c | 13 -------------
>>>  1 file changed, 13 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index 3a451b6..ffefb70 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1001,12 +1001,6 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
>>>         netdev_features_t mask;
>>>         struct slave *slave;
>>>
>>> -       if (!bond_has_slaves(bond)) {
>>> -               /* Disable adding VLANs to empty bond. But why? --mq */
>>> -               features |= NETIF_F_VLAN_CHALLENGED;
>>> -               return features;
>>> -       }
>>> -
>>>         mask = features;
>>>         features &= ~NETIF_F_ONE_FOR_ALL;
>>>         features |= NETIF_F_ALL_FOR_ALL;
>>> @@ -3956,13 +3950,6 @@ void bond_setup(struct net_device *bond_dev)
>>>         bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
>>>         bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
>>>
>>> -       /* At first, we block adding VLANs. That's the only way to
>>> -        * prevent problems that occur when adding VLANs over an
>>> -        * empty bond. The block will be removed once non-challenged
>>> -        * slaves are enslaved.
>>> -        */
>>> -       bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
>>> -
>>>         /* don't acquire bond device's netif_tx_lock when
>>>          * transmitting */
>>>         bond_dev->features |= NETIF_F_LLTX;
>>> --
>>> 1.9.0
>
>---
>	-Jay Vosburgh, jay.vosburgh@canonical.com
