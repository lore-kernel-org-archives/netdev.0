From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V10 3/4] 802.1AD: Flow handling, actions and
 vlan parsing
Date: Thu, 04 Jun 2015 18:00:39 -0400
Message-ID: <5570CA87.3030909@gmail.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>	<1433267444-26025-4-git-send-email-thomasfherbert@gmail.com>	<CALnjE+p8tuUFoXOFvfrp154rb80o_8XhtJ+Z8RrL1Y67kw12jw@mail.gmail.com>	<55709674.8070808@gmail.com> <CALnjE+r3C07mfEv5KsHjkVhDi0f2TYZwW+ATY=i7J=gek-YadA@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36086 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbbFDWAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 18:00:41 -0400
Received: by qgep100 with SMTP id p100so22361445qge.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 15:00:41 -0700 (PDT)
In-Reply-To: <CALnjE+r3C07mfEv5KsHjkVhDi0f2TYZwW+ATY=i7J=gek-YadA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/15 4:39 PM, Pravin Shelar wrote:
> On Thu, Jun 4, 2015 at 11:18 AM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> On 6/4/15 1:45 PM, Pravin Shelar wrote:
>>>
>>> On Tue, Jun 2, 2015 at 10:50 AM, Thomas F Herbert
>>> <thomasfherbert@gmail.com> wrote:
>>>>
>>>> Add support for 802.1ad including the ability to push and pop double
>>>> tagged vlans.
>>>>
>>>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>>>> ---
>>>>    net/openvswitch/flow.c | 82
>>>> ++++++++++++++++++++++++++++++++++++++++++--------
>>>>    net/openvswitch/flow.h |  3 ++
>>>>    2 files changed, 73 insertions(+), 12 deletions(-)
>>>>
>>>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>>>> index 2dacc7b..9c73a2e 100644
>>>> --- a/net/openvswitch/flow.c
>>>> +++ b/net/openvswitch/flow.c
>>>> @@ -298,21 +298,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>>>>    static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>>>    {
>>>>           struct qtag_prefix {
>>>> -               __be16 eth_type; /* ETH_P_8021Q */
>>>> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>>>>                   __be16 tci;
>>>>           };
>>>> -       struct qtag_prefix *qp;
>>>> +       struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
>>>>
>>>> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) +
>>>> sizeof(__be16)))
>>>> +       struct qinqtag_prefix {
>>>> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>>>> +               __be16 tci;
>>>> +               __be16 inner_tpid; /* ETH_P_8021Q */
>>>> +               __be16 ctci;
>>>> +       };
>>>> +
>>>
>>> ...
>>>
>>>>
>>>> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
>>>> index a076e44..fa83c61 100644
>>>> --- a/net/openvswitch/flow.h
>>>> +++ b/net/openvswitch/flow.h
>>>> @@ -134,6 +134,9 @@ struct sw_flow_key {
>>>>                   u8     src[ETH_ALEN];   /* Ethernet source address. */
>>>>                   u8     dst[ETH_ALEN];   /* Ethernet destination address.
>>>> */
>>>>                   __be16 tci;             /* 0 if no VLAN,
>>>> VLAN_TAG_PRESENT set otherwise. */
>>>> +               __be16 ctci;            /* 0 if no CVLAN,
>>>> VLAN_TAG_PRESENT set
>>>> +                                        * otherwise.
>>>> +                                        */
>>>>                   __be16 type;            /* Ethernet frame type. */
>>>>           } eth;
>>>>           union {
>>>> --
>>>> 2.1.0
>>>>
>>> Currently you have restricted the datapath implementation to support
>>> only 8021AD. We can extend this to support double tagging by adding
>>> inner_tpid field to struct sw_flow_key. OVS netlink interface already
>>> allows this type of configuration. So is there reason not to do it in
>>> this series?
>>
>> Pravin, thanks for the review.
>>
>> In the original implementation, I thought I would make only the minimally
>> necessary changes and I have been carrying that forward through each
>> revision.
>>
>> If only one tag, tci is present that implies tpid of 0x8100, if two tags are
>> present, both tci and ctci, that implies a tpid of 0x88a8 and this is in
>> fact how the code works and is how it supports both 802.1q and 802.1ad. The
>> tpid's are not strictly necessary in the flow key for both 802.1q and
>> 802.1ad to work. OF doesn't support the ability to push and pop vlans with
>> non valid tpid's so there's no ambiguity.
>>
>> Contrarily and despite my comment above, although not strictly necessary, I
>> don't have any objection to adding the tpid and to the flow key and I can
>> make it work either way.
>>
> inner_tpid is must here. We need to pass this information up to the
> userspace when we serialize the flow-key. Otherwise we would loose
> this information.
Right, I understand the need for this and my code currently deduces the 
tpid by the combination or absence of the tci and ctci.
> I think we can add another struct to represent inner-vlan which keep
> track of the tci and tpid.
OK, I do think what you suggest is a better way to do it and will 
simplify the code quite a bit. I will make the change, add the struct 
with both the inner tci and the tpid to the struct.  I will also make 
the corresponding change for in the user space patch. I will get code 
and tested and submit is as V11.
>


-- 
Thomas F. Herbert
