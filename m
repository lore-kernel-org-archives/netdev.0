From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next 1/4] bpf: add helper bpf_perf_read_counter_time
 for perf event array map
Date: Fri, 1 Sep 2017 14:01:31 -0700
Message-ID: <8d1f83e7-da7a-075c-0931-eb669134ed24@fb.com>
References: <20170901165357.465121-1-yhs@fb.com>
 <20170901165357.465121-2-yhs@fb.com>
 <a1905aeb-b49f-d4e8-91ee-a28a92869da1@fb.com>
 <20170901205040.GU6524@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Peter Zijlstra <peterz@infradead.org>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43916 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752367AbdIAVCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 17:02:36 -0400
In-Reply-To: <20170901205040.GU6524@worktop.programming.kicks-ass.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/1/17 1:50 PM, Peter Zijlstra wrote:
> On Fri, Sep 01, 2017 at 01:29:17PM -0700, Alexei Starovoitov wrote:
> 
>>> +BPF_CALL_4(bpf_perf_read_counter_time, struct bpf_map *, map, u64, flags,
>>> +	struct bpf_perf_counter_time *, buf, u32, size)
>>> +{
>>> +	struct perf_event *pe;
>>> +	u64 now;
>>> +	int err;
>>> +
>>> +	if (unlikely(size != sizeof(struct bpf_perf_counter_time)))
>>> +		return -EINVAL;
>>> +	err = get_map_perf_counter(map, flags, &buf->counter, &pe);
>>> +	if (err)
>>> +		return err;
>>> +
>>> +	calc_timer_values(pe, &now, &buf->time.enabled, &buf->time.running);
>>> +	return 0;
>>> +}
>>
>> Peter,
>> I believe we're doing it correctly above.
>> It's a copy paste of the same logic as in total_time_enabled/running.
>> We cannot expose total_time_enabled/running to bpf, since they are
>> different counters. The above two are specific to bpf usage.
>> See commit log.
> 
> No, the patch is atrocious and the usage is wrong.
> 
> Exporting a function called 'calc_timer_values' is a horrible violation
> of the namespace.
> 
> And its wrong because it should be done in conjunction with
> perf_event_read_local(). You cannot afterwards call this because you
> don't know if the event was active when you read it and you don't have
> temporal guarantees; that is, reading these timestamps long after or
> before the read is wrong, and this interface allows it.

Thanks for explanation. Will push the read/calculate time 
enabled/running inside the perf_event_read_local then.

> 
> So no, sorry this is just fail.
> 
