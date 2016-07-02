From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Sat, 2 Jul 2016 16:07:51 +0200
Message-ID: <5777CAB7.9050007@cumulusnetworks.com>
References: <1467465978-28271-1-git-send-email-jhs@emojatatu.com>
 <5777C673.8000703@cumulusnetworks.com> <5777C976.4000402@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37673 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbcGBOHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 10:07:54 -0400
Received: by mail-wm0-f48.google.com with SMTP id a66so62265837wme.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 07:07:53 -0700 (PDT)
In-Reply-To: <5777C976.4000402@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/16 16:02, Jamal Hadi Salim wrote:
> On 16-07-02 09:49 AM, Nikolay Aleksandrov wrote:
>> On 02/07/16 15:26, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> Often redirecting or mirroring requires that we set the MAC address
>>> of the target device. While it is possible to pipe to a pedit action
>>> this obsoletes the need for that. This is justified feature because
>>> the dst MAC addresses rewrite is such a common use case.
>>>
>>> Sample usage:
>>> sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
>>> u32 match ip protocol 1 0xff flowid 1:2 \
>>> action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15
>>>
>>> This will match all icmp packets going out on dev $ETH and
>>> redirect them to dev $SPANPORT while setting their dst MAC address
>>> to 02:15:15:15:15:15
>>>
>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>> ---
>>>   include/net/tc_act/tc_mirred.h        |  4 +++-
>>>   include/uapi/linux/tc_act/tc_mirred.h |  7 ++++---
>>>   net/sched/act_mirred.c                | 20 +++++++++++++++++++-
>>>   3 files changed, 26 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
>>> index e891835..7e8bced 100644
>>> --- a/include/net/tc_act/tc_mirred.h
>>> +++ b/include/net/tc_act/tc_mirred.h
>>> @@ -6,10 +6,12 @@
>>>
>>>   struct tcf_mirred {
>>>       struct tcf_common    common;
>>> +    struct net_device __rcu    *tcfm_dev;
>>>       int            tcfm_eaction;
>>>       int            tcfm_ifindex;
>>>       int            tcfm_ok_push;
>>> -    struct net_device __rcu    *tcfm_dev;
>>> +    u8            eth_dst[ETH_ALEN];
>>> +    /* XXX 6 bytes hole here*/
>>>       struct list_head    tcfm_list;
>>>   };
>>>   #define to_mirred(a) \
>>> diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
>>> index 3d7a2b3..aaca1ff 100644
>>> --- a/include/uapi/linux/tc_act/tc_mirred.h
>>> +++ b/include/uapi/linux/tc_act/tc_mirred.h
>>> @@ -9,20 +9,21 @@
>>>   #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
>>>   #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
>>>   #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
>>> -
>>> +
>>>   struct tc_mirred {
>>>       tc_gen;
>>>       int                     eaction;   /* one of IN/EGRESS_MIRROR/REDIR */
>>>       __u32                   ifindex;  /* ifindex of egress port */
>>>   };
>>> -
>>> +
>>>   enum {
>>>       TCA_MIRRED_UNSPEC,
>>>       TCA_MIRRED_TM,
>>>       TCA_MIRRED_PARMS,
>>>       TCA_MIRRED_PAD,
>>> +    TCA_MIRRED_DMAC,
>>
>> Hi Jamal,
>> I think you should update "mirred_policy" in order to ensure that the attribute has
>> the minimum length for a mac address.
> 
> Good point. Will do in the next update.
> 
>> Also a minor suggestion - maybe err out on a
>> zero mac address, otherwise the user might think the operation was successful.
>>
> 
> Is a zero mac address wrong? What if that was policy intent?
> 

If you mean that you give the user ability to get rid of the mac, then okay. I said it
because it will seem like a successful operation and then the mac will not be dumped
or overwritten which will look like it wasn't set at all.

> cheers,
> jamal
> 
