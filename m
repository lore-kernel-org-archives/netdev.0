From: Yang Yingliang <zjutyyl@gmail.com>
Subject: Re: [PATCH net v3 1/2] net: sched: tbf: fix calculation of max_size
Date: Wed, 20 Nov 2013 20:50:59 +0800
Message-ID: <528CB033.7060107@gmail.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>	<1384845939-8424-2-git-send-email-yangyingliang@huawei.com>	<20131119103828.5697d5c9@redhat.com>	<528C1B13.5090701@huawei.com> <20131120110448.50b68d23@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, jpirko@redhat.com
To: jbrouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:63259 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab3KTMvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 07:51:13 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so5311762pab.6
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 04:51:13 -0800 (PST)
In-Reply-To: <20131120110448.50b68d23@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013/11/20 18:04, Jesper Dangaard Brouer wrote:
> On Wed, 20 Nov 2013 10:14:43 +0800
> Yang Yingliang <yangyingliang@huawei.com> wrote:
>> On 2013/11/19 17:38, Jesper Dangaard Brouer wrote:
>>> On Tue, 19 Nov 2013 15:25:38 +0800
>>> Yang Yingliang <yangyingliang@huawei.com> wrote:
>>>
> [...]
>>>> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>>>> index 68f9859..c194129 100644
>>>> --- a/net/sched/sch_tbf.c
>>>> +++ b/net/sched/sch_tbf.c
>>> [...]
>>>> @@ -339,30 +326,46 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
>>> [...]
>>>> +	for (n = 0; n < 65536; n++)
>>>> +		if (psched_l2t_ns(&q->rate, n) > q->buffer)
>>>> +			break;
>>>> +	max_size = min_t(u32, n, (256ULL << qopt->rate.cell_log) - 1);
>>> I'm a little uncertain about, if using the 65536 constant is okay, or
>>> considered "bad style".
>> I'll use a MACRO to instead of this constant in v4.
> I'm not saying you have to use a macro for this. I'm fine with using
> 65536 here, some other developers might have stronger opinions on this?
>
>
>>> I'm still a little confused/uncertain why we need the "qopt->rate.cell_log".
>>>
>> Because we need max_size be smaller than mtu(user input in bytes).
>> E.g. if user inputs like this "...  burst 100KB rate 100mbit mtu 4095",
>> without this patch, max_size is 4095.
>> But with this patch, if don't use cell_log, max_size is 102400.
>> I think it's not correct, so I used cell_log here.
>   
> Hmmmm... so you are using cell_log to approximate the MTU size, because
> struct tc_ratespec, does not contain the a mtu parameter.  You do
> realize this is only an approximation. (This also smells like a bad
> transition away from the userspace rate tables)

Hmmm... not exactly, cell_log can be input by user,
if input like this "...  burst 100KB/4 rate 100mbit mtu 4095",
with old calculation method, max_size would be 1023, but with
new calculation method, it's 65536. I use cell_log here make it
be same as before.
Maybe don't need be same, what's your opinion?
Thanks!

>
> What about the p->mtu parameter from struct tc_tbf_qopt.  I know it is
> in a "time" format... but hey, you are already using this parameter
> requoting your patch:
>
>
> On Tue, 19 Nov 2013 15:25:38 +0800
> Yang Yingliang <yangyingliang@huawei.com> wrote:
>
>> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>> index 68f9859..c194129 100644
>> --- a/net/sched/sch_tbf.c
>> +++ b/net/sched/sch_tbf.c
> [... cut ...]
>> @@ -339,30 +326,46 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
>>   	}
>>   	q->limit = qopt->limit;
>>   	q->mtu = PSCHED_TICKS2NS(qopt->mtu);
>> -	q->max_size = max_size;
>>   	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
>>   	q->tokens = q->buffer;
>>   	q->ptokens = q->mtu;
>>   
>>   	if (tb[TCA_TBF_RATE64])
>>   		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
>> -	psched_ratecfg_precompute(&q->rate, &rtab->rate, rate64);
>> -	if (ptab) {
>> +	psched_ratecfg_precompute(&q->rate, &qopt->rate, rate64);
>> +	if (!q->rate.rate_bytes_ps)
>> +		goto unlock_done;
>> +	for (n = 0; n < 65536; n++)
>> +		if (psched_l2t_ns(&q->rate, n) > q->buffer)
>> +			break;
>> +	max_size = min_t(u32, n, (256ULL << qopt->rate.cell_log) - 1);
>> +
>> +	if (qopt->peakrate.rate) {
>> +		int size = 0;
>>   		if (tb[TCA_TBF_PRATE64])
>>   			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
>> -		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
>> +		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
>> +		for (n = 0; n < 65536; n++)
>> +			if (psched_l2t_ns(&q->peak, n) > q->mtu)
> You are using q->mtu here, BUT why are you only doing this, when there
> is a qopt->peakrate.rate, set???  (I might have missed something)
>
When qopt->peakrate.rate is not set, q->mtu is 0.

Regards,
Yang

>> +				break;
>> +		size = min_t(u32, n, (256ULL << qopt->rate.cell_log) - 1);
>> +		max_size = min_t(u32, max_size, size);
>>   		q->peak_present = true;
>>   	} else {
>>   		q->peak_present = false;
>>   	}
>
