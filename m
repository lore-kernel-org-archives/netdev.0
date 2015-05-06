From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH linux v1 net-next 4/4] bonding: add netlink support for
 sys prio, actor sys mac, and port key
Date: Tue, 05 May 2015 21:07:08 -0400
Message-ID: <5549693C.9080701@cumulusnetworks.com>
References: <cover.1430498637.git.jtoppins@cumulusnetworks.com> <73eb78d846c220d223f68a3b29f42eff011795fd.1430498637.git.jtoppins@cumulusnetworks.com> <CAF2d9jjKmYd7pVVVnsXQkGoysQy09Ro4VFA7a8etFYYTzv9+Ag@mail.gmail.com> <5547DB27.60608@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:34839 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbEFBHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 21:07:11 -0400
Received: by qcbgu10 with SMTP id gu10so57261351qcb.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 18:07:10 -0700 (PDT)
In-Reply-To: <5547DB27.60608@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/15 4:48 PM, Jonathan Toppins wrote:
> On 5/1/15 7:15 PM, Mahesh Bandewar wrote:
>>>
>>> @@ -548,6 +585,19 @@ static int bond_fill_info(struct sk_buff *skb,
>>>                         bond->params.ad_select))
>>>                  goto nla_put_failure;
>>>
>>> +       if (nla_put_u16(skb, IFLA_BOND_AD_ACTOR_SYS_PRIO,
>>> +                       bond->params.ad_actor_sys_prio))
>>> +               goto nla_put_failure;
>>> +
>>> +       if (nla_put_u16(skb, IFLA_BOND_AD_USER_PORT_KEY,
>>> +                       bond->params.ad_user_port_key))
>>> +               goto nla_put_failure;
>>> +
>>> +       if (nla_put(skb, IFLA_BOND_AD_ACTOR_SYSTEM,
>>> +                   sizeof(bond->params.ad_actor_system),
>>> +                   &bond->params.ad_actor_system))
>>> +               goto nla_put_failure;
>>> +
>> I think this does not make sense for MODE != 8023AD. Shouldn't this be
>> inside next block which is for the 802.3ad mode?

Agreed, the kernel should filter attributes not useful for that mode. 
Will move the sending of these attributes to be inside the mode check below.

>>
>>>          if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>>                  struct ad_info info;
>>>
>>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>> index d9cd192..6d6e502 100644
>>> --- a/include/uapi/linux/if_link.h
>>> +++ b/include/uapi/linux/if_link.h
>>> @@ -417,6 +417,9 @@ enum {
>>>          IFLA_BOND_AD_LACP_RATE,
>>>          IFLA_BOND_AD_SELECT,
>>>          IFLA_BOND_AD_INFO,
>>> +       IFLA_BOND_AD_ACTOR_SYS_PRIO,
>>> +       IFLA_BOND_AD_USER_PORT_KEY,
>>> +       IFLA_BOND_AD_ACTOR_SYSTEM,
>> Even though this is available / stored in bond->param, I feel that
>> these belong to IFLA_BOND_AD_INFO_, no?
>
> Can see it fitting in there. Not sure of the history of the AD_INFO_*
> object. Evaluating implementation, will respond tomorrow with conclusion.

So I did complete a rough implementation of this in both the kernel and 
iproute2 [1][2].

After having implemented the example code it became clear that we should 
continue to divide based on write permissions. That being all current 
bonding attributes that are writable exist in "IFLA_BOND_*" and all 
"IFLA_BOND_AD_INFO*" attributes are read-only. By dividing this way it 
makes consumers of the API (f.e. iprotue2) pretty straight forward to 
implement in both the write and read cases. Also all IFLA_BOND_AD_INFO 
attributes I do not see getting converted to writable, as they are 
generated as a result of lacp negotiation with input from these new ad_ 
attributes, agree?

In the implementation code for iproute2 [2] a "submode" for defining 
ad_info attributes was needed to keep the parsing simple. This felt 
awkward because all other attributes just need to be listed, with no 
special submode beyond the link type.

Summary, will send a v2 with the current implementation and change 
bond_fill_info() to only send these new ad attributes if the bond is in 
mode 4, will not modify lacp_rate or ad_select at this time. Will post 
v2 tomorrow if no strong disagreements.

Thanks!

[1] https://github.com/jtoppins/net-next/tree/ad_actor-patches-v2
[2] https://github.com/jtoppins/iproute2/tree/ad_actor-patches-v2
>
>>
>>>          __IFLA_BOND_MAX,
>>>   };
>>>
>>> --
>>> 1.7.10.4
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
