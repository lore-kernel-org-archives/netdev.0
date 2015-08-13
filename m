From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 1/3] mpls: move mpls_route nexthop fields to
 a new nhlfe struct
Date: Thu, 13 Aug 2015 15:01:54 +0100
Message-ID: <55CCA352.70504@brocade.com>
References: <1439329548-50935-2-git-send-email-roopa@cumulusnetworks.com> <55CB9B3B.1060809@brocade.com> <55CC0C23.2050901@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ebiederm@xmission.com>,
	<netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:17457 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726AbbHMOCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 10:02:07 -0400
In-Reply-To: <55CC0C23.2050901@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/08/15 04:16, roopa wrote:
> On 8/12/15, 12:15 PM, Robert Shearman wrote:
>> On 11/08/15 22:45, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> moves mpls_route nexthop fields to a new mpls_nhlfe
>>> struct. mpls_nhlfe represents a mpls nexthop label forwarding entry.
>>> It prepares mpls route structure for multipath support.
>>>
>>> In the process moves mpls_route structure into internal.h.
>>
>> Is there a requirement for moving this and the new datastructures into
>> internal.h? I may have missed it, but I don't see any dependency on
>> this in this patch series.
>
> No dependency really. In my initial implementation of iptunnels I had
> some shared code and it had been in internal.h since then.
>   i don't share any of this with iptunnels now. But, if you see patch
> 3/3, there is a lot more macros I add with struct nhlfe etc and it is
> cleaner
> to move all this to a header file than keeping it in the .c file.

Ok, I have no strong preference.

>>
>>> Moves some of the code from mpls_route_add into a separate mpls
>>> nhlfe build function. changed mpls_rt_alloc to take number of
>>> nexthops as argument.
>>>
>>> A mpls route can point to multiple mpls_nhlfe. This patch
>>> does not support multipath yet, hence the rest of the changes
>>> assume that a mpls route points to a single mpls_nhlfe
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>>   net/mpls/af_mpls.c  |  225
>>> ++++++++++++++++++++++++++++-----------------------
>>>   net/mpls/internal.h |   35 ++++++++
>>>   2 files changed, 158 insertions(+), 102 deletions(-)
>>>
>>> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
>>> index 8c5707d..cf86e9d 100644
>>> --- a/net/mpls/af_mpls.c
>>> +++ b/net/mpls/af_mpls.c
>>> @@ -21,35 +21,6 @@
>>>   #endif
>>>   #include "internal.h"
>>>
>>> -#define LABEL_NOT_SPECIFIED (1<<20)
>>> -#define MAX_NEW_LABELS 2
>>> -
>>> -/* This maximum ha length copied from the definition of struct
>>> neighbour */
>>> -#define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
>>> -
>>> -enum mpls_payload_type {
>>> -    MPT_UNSPEC, /* IPv4 or IPv6 */
>>> -    MPT_IPV4 = 4,
>>> -    MPT_IPV6 = 6,
>>> -
>>> -    /* Other types not implemented:
>>> -     *  - Pseudo-wire with or without control word (RFC4385)
>>> -     *  - GAL (RFC5586)
>>> -     */
>>> -};
>>> -
>>> -struct mpls_route { /* next hop label forwarding entry */
>>> -    struct net_device __rcu *rt_dev;
>>> -    struct rcu_head        rt_rcu;
>>> -    u32            rt_label[MAX_NEW_LABELS];
>>> -    u8            rt_protocol; /* routing protocol that set this
>>> entry */
>>> -    u8                      rt_payload_type;
>>> -    u8            rt_labels;
>>> -    u8            rt_via_alen;
>>> -    u8            rt_via_table;
>>> -    u8            rt_via[0];
>>> -};
>>> -
>>>   static int zero = 0;
>>>   static int label_limit = (1 << 20) - 1;
>>>
>> ...
>>> @@ -281,13 +254,15 @@ struct mpls_route_config {
>>>       struct nl_info        rc_nlinfo;
>>>   };
>>>
>>> -static struct mpls_route *mpls_rt_alloc(size_t alen)
>>> +static struct mpls_route *mpls_rt_alloc(int num_nh)
>>>   {
>>>       struct mpls_route *rt;
>>>
>>> -    rt = kzalloc(sizeof(*rt) + alen, GFP_KERNEL);
>>> +    rt = kzalloc(sizeof(*rt) + (num_nh * sizeof(struct mpls_nhlfe)),
>>
>> How about this instead:
>>   offsetof(typeof(*rt), rt_nh[num_nh])
>> ?
>>
>> That way, you don't need to write out the type of rt_nh here.
> I don't mind, but i followed existing convention for this (especially
> the fib code).
> would prefer keeping it the current way.

I don't think we have to follow the ipv4 convention here, but again I 
have no strong preference.

>>
>>> +             GFP_KERNEL);
>>>       if (rt)
>>> -        rt->rt_via_alen = alen;
>>> +        rt->rt_nhn = num_nh;
>>> +
>>>       return rt;
>>>   }
>>>

> Thanks for the review.

Thank you for implementing this functionality.

Rob
