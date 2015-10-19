From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH V3 1/2] bpf: control the trace data output on current
 cpu when perf sampling
Date: Mon, 19 Oct 2015 10:48:12 +0800
Message-ID: <562459EC.20700@huawei.com>
References: <1444981333-70429-1-git-send-email-xiakaixu@huawei.com> <1444981333-70429-2-git-send-email-xiakaixu@huawei.com> <562174CE.9070900@plumgrid.com>
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
In-Reply-To: <562174CE.9070900@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/10/17 6:06, Alexei Starovoitov =E5=86=99=E9=81=93:
> On 10/16/15 12:42 AM, Kaixu Xia wrote:
>> This patch adds the flag dump_enable to control the trace data
>> output process when perf sampling. By setting this flag and
>> integrating with ebpf, we can control the data output process and
>> get the samples we are most interested in.
>>
>> The bpf helper bpf_perf_event_dump_control() can control the
>> perf_event on current cpu.
>>
>> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
>> ---
>>   include/linux/perf_event.h      |  1 +
>>   include/uapi/linux/bpf.h        |  5 +++++
>>   include/uapi/linux/perf_event.h |  3 ++-
>>   kernel/bpf/verifier.c           |  3 ++-
>>   kernel/events/core.c            | 13 ++++++++++++
>>   kernel/trace/bpf_trace.c        | 44 +++++++++++++++++++++++++++++=
++++++++++++
>>   6 files changed, 67 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
>> index 092a0e8..2af527e 100644
>> --- a/include/linux/perf_event.h
>> +++ b/include/linux/perf_event.h
>> @@ -472,6 +472,7 @@ struct perf_event {
>>       struct irq_work            pending;
>>
>>       atomic_t            event_limit;
>> +    atomic_t            dump_enable;
>=20
> The naming is the hardest...
> How about calling it 'soft_enable' instead?
>=20
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -287,6 +287,11 @@ enum bpf_func_id {
>>        * Return: realm if !=3D 0
>>        */
>>       BPF_FUNC_get_route_realm,
>> +
>> +    /**
>> +     * u64 bpf_perf_event_dump_control(&map, index, flag)
>> +     */
>> +    BPF_FUNC_perf_event_dump_control,
>=20
> and this one is too long.
> May be bpf_perf_event_control() ?
>=20
> Daniel, any thoughts on naming?
>=20
>> --- a/include/uapi/linux/perf_event.h
>> +++ b/include/uapi/linux/perf_event.h
>> @@ -331,7 +331,8 @@ struct perf_event_attr {
>>                   comm_exec      :  1, /* flag comm events that are =
due to an exec */
>>                   use_clockid    :  1, /* use @clockid for time fiel=
ds */
>>                   context_switch :  1, /* context switch data */
>> -                __reserved_1   : 37;
>> +                dump_enable    :  1, /* don't output data on sample=
s */
>=20
> either comment or name is wrong.
> how about calling this one 'soft_disable',
> since you want zero to be default and the event should be on.
>=20
>> diff --git a/kernel/events/core.c b/kernel/events/core.c
>> index b11756f..74a16af 100644
>> --- a/kernel/events/core.c
>> +++ b/kernel/events/core.c
>> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_e=
vent *event,
>>           irq_work_queue(&event->pending);
>>       }
>>
>> +    if (!atomic_read(&event->dump_enable))
>> +        return ret;
>=20
> I'm not an expert in this piece of perf, but should it be 'return 0'
> instead ?
> and may be moved to is_sampling_event() check?
> Also please add unlikely().
>=20
>> +static void perf_event_check_dump_flag(struct perf_event *event)
>> +{
>> +    if (event->attr.dump_enable =3D=3D 1)it=20
>> +        atomic_set(&event->dump_enable, 1);
>> +    else
>> +        atomic_set(&event->dump_enable, 0);
>=20
> that looks like it breaks perf, since default for bits is zero
> and all events will be soft-disabled?
> How did you test it?
> Please add a test to samples/bpf/ for this feature.

It is really hard that adding a test to samples/bpf/. We need to implem=
ent most of
'perf record/report' commands from tools/perf/, like mmap(), dump trace=
, etc. Only
the perf_event_open syscall is really not enough.

Actually, this patch set is only the kernel space side, and it still ne=
eds the perf
user space side, you can find the necessary patches in Wang Nan's git t=
ree[1].
Based on Wang Nan's git tree, we can config BPF maps through perf cmdli=
ne.
We also need to confing attr->soft_disable in perf user side based on t=
ree[1]. so
it was not included in this patchset. I will send out the perf userspac=
e part after
this patch set is applied.

[1] git://git.kernel.org/pub/scm/linux/kernel/git/pi3orama/linux.git pe=
rf/ebpf
>=20
>=20
> .
>=20
