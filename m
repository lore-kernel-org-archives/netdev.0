From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [E] Re: [PATCH net-next 1/2] net sched act_vlan: Change stats
 update to use per-core stats
Date: Wed, 11 Oct 2017 14:58:20 +0200
Message-ID: <20171011125820.GE2039@nanopsycho>
References: <1507689147-22941-1-git-send-email-manish.kurup@verizon.com>
 <d79cf8b2-4c67-1101-0405-afec1e9f89c7@mojatatu.com>
 <10f80e225811433d89d58f139fba8026@OMZP1LUMXCA01.uswin.ad.vzwcorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Manish Kurup <kurup.manish@gmail.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "aring@mojatatu.com" <aring@mojatatu.com>,
        "mrv@mojatatu.com" <mrv@mojatatu.com>
To: "Kurup, Manish B" <manish.kurup@verizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37079 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757413AbdJKM6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 08:58:22 -0400
Received: by mail-wm0-f68.google.com with SMTP id r68so1810126wmr.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 05:58:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <10f80e225811433d89d58f139fba8026@OMZP1LUMXCA01.uswin.ad.vzwcorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 02:35:50PM CEST, manish.kurup@verizon.com wrote:
>Hi Jamal, Yes, that's an indentation mismatch - I put in one tab too many. Shall fix before commit.

No top-posting please!


>
>Thanks,
>
>-Manish
>
>-----Original Message-----
>From: Jamal Hadi Salim [mailto:jhs@mojatatu.com] 
>Sent: Wednesday, October 11, 2017 8:28 AM
>To: Manish Kurup; xiyou.wangcong@gmail.com; jiri@resnulli.us; davem@davemloft.net; netdev@vger.kernel.org
>Cc: aring@mojatatu.com; mrv@mojatatu.com; Kurup, Manish B
>Subject: [E] Re: [PATCH net-next 1/2] net sched act_vlan: Change stats update to use per-core stats
>
>minus lk
>
>On 17-10-10 10:32 PM, Manish Kurup wrote:
>> The VLAN action maintains one set of stats across all cores, and uses 
>> a spinlock to synchronize updates to it from the same. Changed this to 
>> use a per-CPU stats context instead.
>> This change will result in better performance.
>> 
>> Signed-off-by: Manish Kurup <manish.kurup@verizon.com>
>> ---
>>   net/sched/act_vlan.c | 10 ++++++----
>>   1 file changed, 6 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c index 
>> 16eb067..14c262c 100644
>> --- a/net/sched/act_vlan.c
>> +++ b/net/sched/act_vlan.c
>> @@ -30,9 +30,10 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>>   	int err;
>>   	u16 tci;
>>   
>> -	spin_lock(&v->tcf_lock);
>>   	tcf_lastuse_update(&v->tcf_tm);
>> -	bstats_update(&v->tcf_bstats, skb);
>> +	bstats_cpu_update(this_cpu_ptr(v->common.cpu_bstats), skb);
>> +
>> +	spin_lock(&v->tcf_lock);
>>   	action = v->tcf_action;
>>   
>>   	/* Ensure 'data' points at mac_header prior calling vlan 
>> manipulating @@ -85,7 +86,8 @@ static int tcf_vlan(struct sk_buff 
>> *skb, const struct tc_action *a,
>>   
>>   drop:
>>   	action = TC_ACT_SHOT;
>> -	v->tcf_qstats.drops++;
>> +	qstats_drop_inc(this_cpu_ptr(v->common.cpu_qstats));
>> +
>>   unlock:
>>   	if (skb_at_tc_ingress(skb))
>>   		skb_pull_rcsum(skb, skb->mac_len); @@ -172,7 +174,7 @@ static int 
>> tcf_vlan_init(struct net *net, struct nlattr *nla,
>>   
>>   	if (!exists) {
>>   		ret = tcf_idr_create(tn, parm->index, est, a,
>> -				     &act_vlan_ops, bind, false);
>> +						&act_vlan_ops, bind, true);
>>
>
>Indentation mismatch here?
>
>Otherwise looks good to me.
>
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>cheers,
>jamal
