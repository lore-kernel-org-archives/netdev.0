From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next RFC 4/4] openvswitch: Add meter action support
Date: Mon, 16 Oct 2017 00:06:57 -0700
Message-ID: <CABKoBm38Jn45p8HWYprw9JRHe-m4xaamW=_d25ReakTE7GB0_w@mail.gmail.com>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org>
 <1507847923-13612-5-git-send-email-azhou@ovn.org> <CAOrHB_AaUYb_s4Mp9gOBsH26P1CHcnEcLjPW8ZDeJxPCESP3pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, Greg Rose <gvrose8192@gmail.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:52691 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdJPHHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 03:07:41 -0400
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
        (Authenticated sender: azhou@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id C80F7FB87E
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:07:39 +0200 (CEST)
Received: by mail-pf0-f180.google.com with SMTP id e64so15148815pfk.9
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 00:07:39 -0700 (PDT)
In-Reply-To: <CAOrHB_AaUYb_s4Mp9gOBsH26P1CHcnEcLjPW8ZDeJxPCESP3pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 5:13 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Thu, Oct 12, 2017 at 3:38 PM, Andy Zhou <azhou@ovn.org> wrote:
>> Implements OVS kernel meter action support.
>>
>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>> ---
>>  include/uapi/linux/openvswitch.h |  1 +
>>  net/openvswitch/actions.c        | 12 ++++++++++++
>>  net/openvswitch/datapath.h       |  1 +
>>  net/openvswitch/flow_netlink.c   |  6 ++++++
>>  4 files changed, 20 insertions(+)
>>
>> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
>> index 325049a129e4..11fe1a06cdd6 100644
>> --- a/include/uapi/linux/openvswitch.h
>> +++ b/include/uapi/linux/openvswitch.h
>> @@ -835,6 +835,7 @@ enum ovs_action_attr {
>>         OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
>>         OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
>>         OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
>> +       OVS_ACTION_ATTR_METER,        /* u32 meter ID. */
>>
>>         __OVS_ACTION_ATTR_MAX,        /* Nothing past this will be accepted
>>                                        * from userspace. */
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index a54a556fcdb5..4eb160ac5a27 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -1210,6 +1210,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>>                 case OVS_ACTION_ATTR_POP_ETH:
>>                         err = pop_eth(skb, key);
>>                         break;
>> +
>> +               case OVS_ACTION_ATTR_METER:
>> +                       if (ovs_meter_execute(dp, skb, key, nla_get_u32(a))) {
>> +                               consume_skb(skb);
>> +                               return 0;
>> +                       }
>>                 }
>>
>>                 if (unlikely(err)) {
>> @@ -1341,6 +1347,12 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
>>         err = do_execute_actions(dp, skb, key,
>>                                  acts->actions, acts->actions_len);
>>
>> +       /* OVS action has dropped the packet, do not expose it
>> +        * to the user.
>> +        */
>> +       if (err == -ENODATA)
>> +               err = 0;
>> +
> I am not sure who is returning this error code?
Ah, this hunk was left over from experimenting with per band actions
list. Will remove. Thanks for catching this!
