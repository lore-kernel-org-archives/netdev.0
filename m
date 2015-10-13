From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output
 data on samples
Date: Tue, 13 Oct 2015 10:30:06 +0800
Message-ID: <561C6CAE.7080503@huawei.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com> <1444640563-159175-2-git-send-email-xiakaixu@huawei.com> <561C07E0.6070203@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<a.p.zijlstra@chello.nl>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561C07E0.6070203@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/10/13 3:20, Alexei Starovoitov =E5=86=99=E9=81=93:
> On 10/12/15 2:02 AM, Kaixu Xia wrote:
>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>> index f57d7fe..25e073d 100644
>> --- a/include/linux/bpf.h
>> +++ b/include/linux/bpf.h
>> @@ -39,6 +39,7 @@ struct bpf_map {
>>       u32 max_entries;
>>       const struct bpf_map_ops *ops;
>>       struct work_struct work;
>> +    atomic_t perf_sample_disable;
>>   };
>>
>>   struct bpf_map_type_list {
>> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
>> index 092a0e8..0606d1d 100644
>> --- a/include/linux/perf_event.h
>> +++ b/include/linux/perf_event.h
>> @@ -483,6 +483,8 @@ struct perf_event {
>>       perf_overflow_handler_t        overflow_handler;
>>       void                *overflow_handler_context;
>>
>> +    atomic_t            *sample_disable;
>=20
> this looks fragile and unnecessary.
> Why add such field to generic bpf_map and carry its pointer into perf=
_event?
> Single extra field in perf_event would have been enough.
> Even better is to avoid adding any fields.
> There is already event->state why not to use that?
> The proper perf_event_enable/disable are so heavy that another
> mechanism needed? cpu_function_call is probably too much to do
> from bpf program, but that can be simplified?
> Based on the use case from cover letter, sounds like you want
> something like soft_disable?
> Then extending event->state would make the most sense.
> Also consider the case of re-entrant event enable/disable.
> So inc/dec of a flag may be needed?

Thanks for your comments!
I've tried perf_event_enable/disable, but there is a warning caused
by cpu_function_call. The main reason as follows,
 int smp_call_function_single(...)
 {
	...
	WARN_ON_ONCE(cpu_online(this_cpu) && irqs_disabled()
		     && !oops_in_progress);
	...
}
So I added the extra atomic flag filed in order to avoid this problem.
>=20
>=20
> .
>=20
