From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V7 2/2] openvswitch: 802.1ad: Flow handling,
 actions, and vlan parsing
Date: Thu, 30 Apr 2015 12:26:43 -0400
Message-ID: <554257C3.20701@gmail.com>
References: <1430261059-7920-1-git-send-email-thomasfherbert@gmail.com>	<1430261059-7920-3-git-send-email-thomasfherbert@gmail.com> <CALnjE+qtYW4JE5TT3WiOofe=Q+YkLEZ7e+MpJQYLs5f6wD3nvw@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	ccp@atcnet.net
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f48.google.com ([209.85.216.48]:42277 "EHLO
	mail-vn0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbD3Q0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:26:45 -0400
Received: by vnbf129 with SMTP id f129so7822199vnb.9
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 09:26:45 -0700 (PDT)
In-Reply-To: <CALnjE+qtYW4JE5TT3WiOofe=Q+YkLEZ7e+MpJQYLs5f6wD3nvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/15 9:27 PM, Pravin Shelar wrote:
> On Tue, Apr 28, 2015 at 3:44 PM, Thomas F Herbert
> <thomasfherbert@gmail.com> wrote:
>> Add support for 802.1ad including the ability to push and pop double
>> tagged vlans.
>>
> I saw multiple checkpatch.pl errors and warning.
>
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> ...
>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>> index 2dacc7b..6989451 100644
>> --- a/net/openvswitch/flow.c
>> +++ b/net/openvswitch/flow.c
>> @@ -298,21 +298,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
>>   static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>   {
>>          struct qtag_prefix {
>> -               __be16 eth_type; /* ETH_P_8021Q */
>> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>>                  __be16 tci;
>>          };
>> -       struct qtag_prefix *qp;
>> +       struct qtag_prefix *qp = (struct qtag_prefix *) skb->data;
>>
>> -       if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
>> -               return 0;
>> +       struct qinqtag_prefix {
>> +               __be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
>> +               __be16 tci;
>> +               __be16 inner_tpid; /* ETH_P_8021Q */
>> +               __be16 ctci;
>> +       };
>> +
>> +       if (likely(skb_vlan_tag_present(skb))) {
>> +
>> +               key->eth.tci = htons(skb->vlan_tci);
>> +
> I think there is bug in existing OVS where it does not check
> vlan_proto before populating the flow key. Can you send a separate
> patch to fix this issue?.
Pravin,

Thanks for your review.

OK. I will find and fix this bug.
>
> Checking for swkey->eth.tci does not make sense here. There is check
> for it in previous if condition.
>
>> +               __be16 eth_type;
>> +               eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
>> +               if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
>> +                   nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
> What about eth.ctci?
OK, yes the logic seems wrong so I will fix the check for ctci above and 
fix the  checkpatch issues and resubmit to net-next.


-- 
Thomas F. Herbert
