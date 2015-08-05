From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 18:31:55 +0800
Message-ID: <55C1E61B.1040808@huawei.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com> <1438678696-88289-4-git-send-email-xiakaixu@huawei.com> <20150805100425.GZ25159@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805100425.GZ25159@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/8/5 18:04, Peter Zijlstra =E5=86=99=E9=81=93:
> On Tue, Aug 04, 2015 at 08:58:15AM +0000, Kaixu Xia wrote:
>> diff --git a/kernel/events/core.c b/kernel/events/core.c
>> index 6251b53..726ca1b 100644
>> --- a/kernel/events/core.c
>> +++ b/kernel/events/core.c
>> @@ -8599,6 +8599,25 @@ struct perf_event_attr *perf_event_attrs(stru=
ct perf_event *event)
>>  	return &event->attr;
>>  }
>> =20
>> +u64 perf_event_read_internal(struct perf_event *event)
>=20
> Maybe: perf_event_read_local(), as this is this function only works f=
or
> events active on the current CPU.
>=20
>> +{
>> +	if (!event)
>> +		return -EINVAL;
>> +
>> +	if (unlikely(event->state !=3D PERF_EVENT_STATE_ACTIVE))
>> +		return -EINVAL;
>=20
> You can return perf_event_count() in that case.
>=20
>> +
>> +	if (event->oncpu !=3D raw_smp_processor_id() &&
>=20
> That _must_ be smp_processor_id(). If that gives a warning (ie.
> preemption is not disabled or we're not affine to this one cpu) then =
the
> warning is valid.
>=20
>> +	    event->ctx->task !=3D current)
>=20
> Write it like:
>=20
> 	if (event->ctx->task !=3D current &&
> 	    event->oncpu !=3D smp_processor_id())
>=20
> That way you'll not evaluate smp_processor_id() for current task even=
ts.
>=20
>> +		return -EINVAL;
>> +
>> +	if (unlikely(event->attr.inherit))
>> +		return -EINVAL;
>=20
> This should be in your accept function, inherited events should never
> get this far.
>=20
> You need IRQs disabled while calling __perf_event_read(), did you tes=
t
> with lockdep enabled?

Thanks for your review! I've not tested it, will do that from now on.
>=20
>> +	__perf_event_read(event);
>> +	return perf_event_count(event);
>> +}
>=20
> Also, you probably want a WARN_ON(in_nmi()) there, this function is
> _NOT_ NMI safe.
>=20
>=20
>=20
> .
>=20
