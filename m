From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH linux v1 net-next 4/4] bonding: add netlink support for
 sys prio, actor sys mac, and port key
Date: Wed, 6 May 2015 00:07:07 -0700
Message-ID: <CAF2d9jhNFJUhJab0AXZ01BLjy-nRt=X0TyqdytNXQdYG2+pqjg@mail.gmail.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com>
 <73eb78d846c220d223f68a3b29f42eff011795fd.1430498637.git.jtoppins@cumulusnetworks.com>
 <CAF2d9jjKmYd7pVVVnsXQkGoysQy09Ro4VFA7a8etFYYTzv9+Ag@mail.gmail.com>
 <5547DB27.60608@cumulusnetworks.com> <5549693C.9080701@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33287 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbbEFHH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 03:07:28 -0400
Received: by obblk2 with SMTP id lk2so773327obb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 00:07:28 -0700 (PDT)
In-Reply-To: <5549693C.9080701@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 6:07 PM, Jonathan Toppins
<jtoppins@cumulusnetworks.com> wrote:
> On 5/4/15 4:48 PM, Jonathan Toppins wrote:
>>
>> On 5/1/15 7:15 PM, Mahesh Bandewar wrote:
>>>>
>>>>
>>>> @@ -548,6 +585,19 @@ static int bond_fill_info(struct sk_buff *skb,
>>>>                         bond->params.ad_select))
>>>>                  goto nla_put_failure;
>>>>
>>>> +       if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
>>>> +                       bond->params.ad_actor_sys_prio))
>>>> +               goto nla_put_failure;
>>>> +
>>>> +       if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
>>>> +                       bond->params.ad_user_port_key))
>>>> +               goto nla_put_failure;
>>>> +
>>>> +       if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
>>>> +                   sizeof(bond->params.ad_actor_system),
>>>> +                   &bond->params.ad_actor_system))
>>>> +               goto nla_put_failure;
>>>> +
>>>
>>> I think this does not make sense for MODE != 8023AD. Shouldn't this be
>>> inside next block which is for the 802.3ad mode?
>
>
> Agreed, the kernel should filter attributes not useful for that mode. Will
> move the sending of these attributes to be inside the mode check below.
>
>>>
>>>>          if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>>>                  struct ad_info info;
>>>>
>>>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>>> index d9cd192..6d6e502 100644
>>>> --- a/include/uapi/linux/if_link.h
>>>> +++ b/include/uapi/linux/if_link.h
>>>> @@ -417,6 +417,9 @@ enum {
>>>>          IFLA_BOND_AD_LACP_RATE,
>>>>          IFLA_BOND_AD_SELECT,
>>>>          IFLA_BOND_AD_INFO,
>>>> +       IFLA_BOND_AD_ACTOR_SYS_PRIO,
>>>> +       IFLA_BOND_AD_USER_PORT_KEY,
>>>> +       IFLA_BOND_AD_ACTOR_SYSTEM,
>>>
>>> Even though this is available / stored in bond->param, I feel that
>>> these belong to IFLA_BOND_AD_INFO_, no?
>>
>>
>> Can see it fitting in there. Not sure of the history of the AD_INFO_*
>> object. Evaluating implementation, will respond tomorrow with conclusion.
>
>
> So I did complete a rough implementation of this in both the kernel and
> iproute2 [1][2].
>
> After having implemented the example code it became clear that we should
> continue to divide based on write permissions. That being all current
> bonding attributes that are writable exist in "IFLA_BOND_*" and all
> "IFLA_BOND_AD_INFO*" attributes are read-only. By dividing this way it makes
> consumers of the API (f.e. iprotue2) pretty straight forward to implement in
> both the write and read cases. Also all IFLA_BOND_AD_INFO attributes I do
> not see getting converted to writable, as they are generated as a result of
> lacp negotiation with input from these new ad_ attributes, agree?
>
So far what we had was only LACP negotiated values but now that we
have variables that we are setting and are used for LACP negotiations
makes it little different.

I'm fine if the overall command structure makes sense and the
read-values are kept separate from write-values as you have mentioned
and is easier to parse.

> In the implementation code for iproute2 [2] a "submode" for defining ad_info
> attributes was needed to keep the parsing simple. This felt awkward because
> all other attributes just need to be listed, with no special submode beyond
> the link type.
>
> Summary, will send a v2 with the current implementation and change
> bond_fill_info() to only send these new ad attributes if the bond is in mode
> 4, will not modify lacp_rate or ad_select at this time. Will post v2
> tomorrow if no strong disagreements.
>
> Thanks!
>
> [1] https://github.com/jtoppins/net-next/tree/ad_actor-patches-v2
> [2] https://github.com/jtoppins/iproute2/tree/ad_actor-patches-v2
>
>>
>>>
>>>>          __IFLA_BOND_MAX,
>>>>   };
>>>>
>>>> --
>>>> 1.7.10.4
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
